import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux_app/data/mock_data.dart';
import 'package:flux_app/models/video_item.dart';
import 'package:flux_app/providers/gallery_provider.dart';
import 'package:flux_app/services/video_launcher_service.dart';
import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_spacing.dart';
import 'package:flux_app/theme/app_typography.dart';
import 'package:flux_app/widgets/filter_chip_row.dart';
import 'package:flux_app/widgets/video_card.dart';

/// Tab 2 — searchable, filterable grid of recorded videos.
class VideoGalleryScreen extends ConsumerWidget {
  const VideoGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gallery = ref.watch(galleryProvider);
    final notifier = ref.read(galleryProvider.notifier);
    final videos = gallery.visibleVideos;

    return RefreshIndicator(
      onRefresh: notifier.loadRecordings,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.md,
          AppSpacing.marginMobile,
          AppSpacing.lg,
        ),
        children: [
        // Search field
        TextField(
          decoration: InputDecoration(
            hintText: 'Search your gallery...',
            hintStyle:
                AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
            prefixIcon:
                const Icon(Icons.search, color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding:
                const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilterChipRow(
          filters: MockData.galleryFilters,
          selectedIndex: gallery.filterIndex,
          onSelect: notifier.filter,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Recent Uploads', style: AppTypography.titleMd),
            const Spacer(),
            Text(
              'View all',
              style: AppTypography.labelMd.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (gallery.isLoading && gallery.videos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (videos.isEmpty)
          const _EmptyGallery()
        else
          for (final video in videos) ...[
            VideoCard(
              video: video,
              onAction: (action) => _onAction(context, ref, video, action),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  void _onAction(
    BuildContext context,
    WidgetRef ref,
    VideoItem video,
    VideoCardAction action,
  ) {
    switch (action) {
      case VideoCardAction.watch:
        _watch(context, video);
      case VideoCardAction.saveToGallery:
        _saveToGallery(context, ref, video);
      case VideoCardAction.rename:
        _rename(context, ref, video);
      case VideoCardAction.delete:
        _confirmDelete(context, ref, video);
    }
  }

  Future<void> _watch(BuildContext context, VideoItem video) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await VideoLauncherService.instance.open(video.filePath);
    if (!result.ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Could not open recording'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveToGallery(
    BuildContext context,
    WidgetRef ref,
    VideoItem video,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(galleryProvider.notifier).saveToGallery(video);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Saved to Flux album' : 'Could not save to gallery'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    VideoItem video,
  ) async {
    final controller = TextEditingController(text: video.title);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        title: Text('Rename recording', style: AppTypography.titleMd),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTypography.bodyLg,
          decoration: InputDecoration(
            hintText: 'New name',
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'CANCEL',
              style: AppTypography.labelMd.copyWith(color: AppColors.onSurface),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(
              'RENAME',
              style: AppTypography.labelMd.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == video.title) return;
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(galleryProvider.notifier).rename(video, newName);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Renamed' : 'Rename failed (name in use?)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VideoItem video,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        title: Text('Delete recording?', style: AppTypography.titleMd),
        content: Text(
          '"${video.title}" will be permanently removed.',
          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'CANCEL',
              style: AppTypography.labelMd.copyWith(color: AppColors.onSurface),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'DELETE',
              style: AppTypography.labelMd.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      await ref.read(galleryProvider.notifier).delete(video);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Recording deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

/// Shown when no recordings exist yet.
class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No recordings yet',
            style: AppTypography.titleMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your captured recordings will appear here.',
            style: AppTypography.bodySm
                .copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
