import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux_app/providers/recording_provider.dart';
import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_spacing.dart';
import 'package:flux_app/theme/app_typography.dart';
import 'package:flux_app/widgets/capture_toggle_card.dart';
import 'package:flux_app/widgets/record_button.dart';
import 'package:flux_app/screens/active_recording_screen.dart';

/// Tab 1 — the landing screen with the big record button and capture toggles.
class RecordHomeScreen extends ConsumerWidget {
  const RecordHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recording = ref.watch(recordingProvider);
    final notifier = ref.read(recordingProvider.notifier);

    void startRecording() {
      notifier.start();
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ActiveRecordingScreen()),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.xl,
        AppSpacing.marginMobile,
        AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              Text(
                'Ready to start?',
                style: AppTypography.headlineLgMobile,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Tap the button below to begin recording.',
                style:
                    AppTypography.bodyLg.copyWith(color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              RecordButton(onTap: startRecording),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: CaptureToggleCard(
                      icon: Icons.mic,
                      label: 'Microphone',
                      value: recording.micEnabled,
                      onChanged: notifier.setMic,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: CaptureToggleCard(
                      icon: Icons.videocam,
                      label: 'Camera',
                      value: recording.cameraEnabled,
                      onChanged: notifier.setCamera,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
