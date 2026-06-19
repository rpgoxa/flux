import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux_app/providers/recording_provider.dart';
import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_spacing.dart';
import 'package:flux_app/theme/app_typography.dart';

/// Confirmation dialog shown when the user stops a recording.
/// Save/Discard drive the recording state machine (saving → idle).
class SaveRecordingDialog extends ConsumerWidget {
  const SaveRecordingDialog({super.key, this.fileName = 'Flux-Recording-042.wav'});

  final String fileName;

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (_) => const SaveRecordingDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(recordingProvider).filePath;
    final displayName =
        path != null ? path.split('/').last : fileName;
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Save Recording?', style: AppTypography.titleMd),
            const SizedBox(height: AppSpacing.xs),
            Text(
              displayName,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: 'DISCARD',
                    background: AppColors.surfaceContainerHigh,
                    foreground: AppColors.onSurface,
                    onTap: () {
                      ref.read(recordingProvider.notifier).discard();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _DialogButton(
                    label: 'SAVE',
                    background: AppColors.primary,
                    foreground: AppColors.onPrimary,
                    onTap: () {
                      final messenger = ScaffoldMessenger.of(context);
                      ref.read(recordingProvider.notifier).save();
                      Navigator.of(context).pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Recording saved'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Text(
          label,
          style: AppTypography.labelMd.copyWith(color: foreground),
        ),
      ),
    );
  }
}
