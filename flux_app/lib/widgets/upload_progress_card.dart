import 'package:flutter/material.dart';

import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_spacing.dart';
import 'package:flux_app/theme/app_typography.dart';

/// Static "uploading" panel shown at the foot of the gallery (visual only).
class UploadProgressCard extends StatelessWidget {
  const UploadProgressCard({
    super.key,
    this.fileName = 'Setup Tour 2024.mp4',
    this.progress = 0.78,
  });

  final String fileName;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Uploading Video', style: AppTypography.titleMd),
              const Spacer(),
              Text(
                '$percent%',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rendering "$fileName"',
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.secondary),
                ),
              ),
              const Icon(Icons.close, color: AppColors.onSurfaceVariant, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
