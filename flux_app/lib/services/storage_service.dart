import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flux_app/models/video_item.dart';

/// Reads recorded MP4s from the engine's output directory and builds
/// [VideoItem]s with thumbnails + metadata. Plain singleton — providers call it.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _thumbChannel = MethodChannel('flux_app/thumbnail');

  /// Engine writes to getExternalFilesDir(null), which maps to
  /// getExternalStorageDirectory() on the Dart side.
  Future<Directory> _recordingsDir() async {
    final dir = await getExternalStorageDirectory();
    return dir ?? await getApplicationDocumentsDirectory();
  }

  /// Scan the recordings dir and return items newest-first.
  /// Corrupted/unreadable files are skipped, not thrown.
  Future<List<VideoItem>> scan() async {
    final Directory dir;
    try {
      dir = await _recordingsDir();
      if (!await dir.exists()) return const [];
    } on Exception {
      return const [];
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.mp4'))
        .toList();

    final items = <VideoItem>[];
    for (final file in files) {
      try {
        final stat = await file.stat();
        if (stat.size <= 0) continue; // empty/interrupted capture
        final durationMs = await _readDurationMs(file);
        final thumbnailPath = await _thumbnail(file.path);
        items.add(VideoItem.fromFile(
          file: file,
          sizeBytes: stat.size,
          createdAt: stat.modified,
          durationMs: durationMs,
          thumbnailPath: thumbnailPath,
        ));
      } on Exception {
        continue; // skip corrupted entry
      }
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// Generate a cached JPEG thumbnail for [videoPath] via the native
  /// MediaMetadataRetriever channel; null on failure.
  Future<String?> _thumbnail(String videoPath) async {
    try {
      return await _thumbChannel.invokeMethod<String>(
        'generate',
        {'videoPath': videoPath},
      );
    } on PlatformException {
      return null;
    }
  }

  /// Delete the recording + its cached thumbnail. Returns false on failure.
  Future<bool> delete(VideoItem item) async {
    try {
      final file = File(item.filePath);
      if (await file.exists()) await file.delete();
      final thumb = item.thumbnailPath;
      if (thumb != null) {
        final tf = File(thumb);
        if (await tf.exists()) await tf.delete();
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Delete a single file by path (used by discard). Best-effort.
  Future<void> deletePath(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } on Exception {
      // best-effort cleanup
    }
  }

  /// Rename the MP4 on disk to [newTitle].mp4 in the same directory.
  /// Drops the stale cached thumbnail (a rescan regenerates it).
  /// Returns the new path, or null on failure / name clash / invalid name.
  Future<String?> renameRecording(VideoItem item, String newTitle) async {
    try {
      final src = File(item.filePath);
      if (!await src.exists()) return null;

      final clean = _sanitizeName(newTitle);
      if (clean.isEmpty) return null;

      final dir = src.parent.path;
      final newPath = '$dir${Platform.pathSeparator}$clean.mp4';
      if (newPath == item.filePath) return item.filePath; // unchanged
      if (await File(newPath).exists()) return null; // name taken

      await src.rename(newPath);

      final thumb = item.thumbnailPath;
      if (thumb != null) {
        final tf = File(thumb);
        if (await tf.exists()) await tf.delete();
      }
      return newPath;
    } on Exception {
      return null;
    }
  }

  /// Strip path separators / illegal filename chars and any .mp4 suffix.
  String _sanitizeName(String input) {
    var v = input.trim().replaceAll(RegExp(r'[\/\\:*?"<>|]'), '_');
    if (v.toLowerCase().endsWith('.mp4')) v = v.substring(0, v.length - 4);
    return v.trim();
  }

  // --- Pure-Dart MP4 duration (mvhd atom) — avoids a media-info dependency. ---

  Future<int?> _readDurationMs(File file) async {
    RandomAccessFile? raf;
    try {
      raf = await file.open();
      final len = await raf.length();
      const window = 2 * 1024 * 1024;

      // MediaRecorder writes moov (with mvhd) at the end after stop().
      final tailLen = len < window ? len : window;
      await raf.setPosition(len - tailLen);
      final tail = await raf.read(tailLen);
      final fromTail = _scanMvhd(tail);
      if (fromTail != null) return fromTail;

      // Fallback: some muxers put moov up front.
      final headLen = len < window ? len : window;
      await raf.setPosition(0);
      final head = await raf.read(headLen);
      return _scanMvhd(head);
    } on Exception {
      return null;
    } finally {
      await raf?.close();
    }
  }

  /// Find the 'mvhd' box in a byte window and compute duration in ms.
  int? _scanMvhd(Uint8List b) {
    final data = ByteData.sublistView(b);
    for (var i = 0; i + 4 <= b.length; i++) {
      // 'mvhd' = 6d 76 68 64
      if (b[i] == 0x6d && b[i + 1] == 0x76 && b[i + 2] == 0x68 && b[i + 3] == 0x64) {
        final p = i + 4; // first byte after the box type = version
        if (p >= b.length) return null;
        final version = b[p];
        try {
          if (version == 0) {
            final tsOff = p + 1 + 3 + 4 + 4; // version+flags + creation + modified
            final durOff = tsOff + 4;
            if (durOff + 4 > b.length) return null;
            final timescale = data.getUint32(tsOff);
            final duration = data.getUint32(durOff);
            if (timescale == 0) return null;
            return (duration * 1000 / timescale).round();
          } else if (version == 1) {
            final tsOff = p + 1 + 3 + 8 + 8;
            final durOff = tsOff + 4;
            if (durOff + 8 > b.length) return null;
            final timescale = data.getUint32(tsOff);
            final duration = data.getUint64(durOff);
            if (timescale == 0) return null;
            return (duration * 1000 / timescale).round();
          }
        } on Exception {
          return null;
        }
      }
    }
    return null;
  }
}
