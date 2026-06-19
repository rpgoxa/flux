import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flux_app/models/video_item.dart';
import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_spacing.dart';
import 'package:flux_app/theme/app_typography.dart';

/// Actions exposed by the card's three-dot menu.
enum VideoCardAction { watch, saveToGallery, rename, delete }

/// Media card: 16:9 thumbnail with badges, channel avatar, title and meta.
class VideoCard extends StatelessWidget {
  const VideoCard({super.key, required this.video, this.onAction});

  final VideoItem video;
  final ValueChanged<VideoCardAction>? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _Thumbnail(path: video.thumbnailPath),
                if (video.isNew)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: _Badge(
                      text: 'NEW',
                      color: AppColors.primary,
                      textColor: AppColors.onPrimary,
                    ),
                  ),
                Positioned(
                  bottom: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: _Badge(
                    text: video.duration,
                    color: Colors.black54,
                    textColor: Colors.white,
                  ),
                ),
                if (onAction != null)
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: _CardMenu(onAction: onAction!),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    color: AppColors.surfaceContainerHigh,
                    child: const Icon(
                      Icons.videocam,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMd,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${video.sizeLabel} • ${video.timeAgo}',
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardMenu extends StatelessWidget {
  const _CardMenu({required this.onAction});

  final ValueChanged<VideoCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: PopupMenuButton<VideoCardAction>(
        icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
        padding: EdgeInsets.zero,
        color: AppColors.surfaceContainerLowest,
        onSelected: onAction,
        itemBuilder: (context) => [
          _item(VideoCardAction.watch, Icons.play_arrow, 'Watch'),
          _item(VideoCardAction.saveToGallery, Icons.save_alt, 'Save to Gallery'),
          _item(VideoCardAction.rename, Icons.edit_outlined, 'Rename'),
          _item(VideoCardAction.delete, Icons.delete_outline, 'Delete'),
        ],
      ),
    );
  }

  PopupMenuItem<VideoCardAction> _item(
    VideoCardAction action,
    IconData icon,
    String label,
  ) {
    final isDelete = action == VideoCardAction.delete;
    final color = isDelete ? AppColors.primary : AppColors.onSurface;
    return PopupMenuItem<VideoCardAction>(
      value: action,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.bodyLg.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final p = path;
    if (p != null && File(p).existsSync()) {
      return Image.file(
        File(p),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ThumbFallback(),
      );
    }
    return const _ThumbFallback();
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          color: AppColors.onSurfaceVariant,
          size: 36,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
    required this.textColor,
  });

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: AppTypography.labelMd
            .copyWith(color: textColor, fontSize: 10, letterSpacing: 0.5),
      ),
    );
  }
}
