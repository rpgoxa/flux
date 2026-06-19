import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux_app/models/video_item.dart';
import 'package:flux_app/services/gallery_saver_service.dart';
import 'package:flux_app/services/storage_service.dart';

/// Gallery list + active category filter, backed by on-disk recordings.
class GalleryState {
  const GalleryState({
    this.videos = const [],
    this.filterIndex = 0,
    this.isLoading = false,
  });

  final List<VideoItem> videos;
  final int filterIndex;
  final bool isLoading;

  /// Videos after applying the active time-bucket filter chip.
  List<VideoItem> get visibleVideos {
    final now = DateTime.now();
    return videos.where((v) {
      switch (filterIndex) {
        case 1: // Today
          return v.createdAt.year == now.year &&
              v.createdAt.month == now.month &&
              v.createdAt.day == now.day;
        case 2: // This Week
          return now.difference(v.createdAt).inDays < 7;
        case 3: // This Month
          return v.createdAt.year == now.year && v.createdAt.month == now.month;
        default: // All
          return true;
      }
    }).toList();
  }

  GalleryState copyWith({
    List<VideoItem>? videos,
    int? filterIndex,
    bool? isLoading,
  }) {
    return GalleryState(
      videos: videos ?? this.videos,
      filterIndex: filterIndex ?? this.filterIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GalleryNotifier extends Notifier<GalleryState> {
  @override
  GalleryState build() {
    Future.microtask(loadRecordings);
    return const GalleryState(isLoading: true);
  }

  /// Rescan the recordings directory from disk.
  Future<void> loadRecordings() async {
    state = state.copyWith(isLoading: true);
    final videos = await StorageService.instance.scan();
    state = state.copyWith(videos: videos, isLoading: false);
  }

  /// Select the active filter chip.
  void filter(int index) => state = state.copyWith(filterIndex: index);

  /// Delete a recording (file + thumbnail) and drop it from the list.
  Future<void> delete(VideoItem item) async {
    await StorageService.instance.delete(item);
    state = state.copyWith(
      videos: state.videos.where((v) => v.filePath != item.filePath).toList(),
    );
  }

  /// Export a recording to the phone's public gallery. Returns success.
  Future<bool> saveToGallery(VideoItem item) {
    return GallerySaverService.instance.saveToGallery(item.filePath);
  }

  /// Rename a recording on disk; rescans on success. Returns success.
  Future<bool> rename(VideoItem item, String newTitle) async {
    final newPath = await StorageService.instance.renameRecording(item, newTitle);
    if (newPath == null) return false;
    await loadRecordings();
    return true;
  }
}

final galleryProvider =
    NotifierProvider<GalleryNotifier, GalleryState>(GalleryNotifier.new);
