import 'dart:io';

/// A recorded video on disk plus derived display metadata.
class VideoItem {
  const VideoItem({
    required this.filePath,
    required this.title,
    required this.createdAt,
    required this.fileSizeBytes,
    this.thumbnailPath,
    this.durationMs,
    this.isNew = false,
  });

  final String filePath;
  final String title;
  final DateTime createdAt;
  final int fileSizeBytes;
  final String? thumbnailPath;
  final int? durationMs;
  final bool isNew;

  factory VideoItem.fromFile({
    required File file,
    required int sizeBytes,
    required DateTime createdAt,
    int? durationMs,
    String? thumbnailPath,
    bool isNew = false,
  }) {
    return VideoItem(
      filePath: file.path,
      title: _titleFromPath(file.path),
      createdAt: createdAt,
      fileSizeBytes: sizeBytes,
      durationMs: durationMs,
      thumbnailPath: thumbnailPath,
      isNew: isNew,
    );
  }

  static String _titleFromPath(String path) {
    final name = path.split(Platform.pathSeparator).last.split('/').last;
    return name.toLowerCase().endsWith('.mp4')
        ? name.substring(0, name.length - 4)
        : name;
  }

  /// mm:ss (falls back to 00:00 when duration could not be parsed).
  String get duration {
    final ms = durationMs;
    if (ms == null || ms <= 0) return '00:00';
    final total = ms ~/ 1000;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Human-readable file size (MB, or KB for tiny files).
  String get sizeLabel {
    final mb = fileSizeBytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    final kb = fileSizeBytes / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }

  /// Relative time ("Just now", "5 min ago", "Yesterday", date).
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final y = createdAt.year;
    final mo = createdAt.month.toString().padLeft(2, '0');
    final d = createdAt.day.toString().padLeft(2, '0');
    return '$y-$mo-$d';
  }
}
