import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux_app/models/recording_state.dart';
import 'package:flux_app/providers/recording_provider.dart';
import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_spacing.dart';
import 'package:flux_app/theme/app_typography.dart';
import 'package:flux_app/widgets/audio_visualizer.dart';
import 'package:flux_app/widgets/save_recording_dialog.dart';

/// Full-screen immersive HUD shown while recording (pushed over the shell).
class ActiveRecordingScreen extends ConsumerStatefulWidget {
  const ActiveRecordingScreen({super.key});

  @override
  ConsumerState<ActiveRecordingScreen> createState() =>
      _ActiveRecordingScreenState();
}

class _ActiveRecordingScreenState
    extends ConsumerState<ActiveRecordingScreen> {
  @override
  void initState() {
    super.initState();
    // countdown → recording once the HUD is on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recordingProvider.notifier).begin();
    });
  }

  void _togglePause() {
    final notifier = ref.read(recordingProvider.notifier);
    if (ref.read(recordingProvider).phase == RecordingPhase.paused) {
      notifier.resume();
    } else {
      notifier.pause();
    }
  }

  Future<void> _stop() async {
    await ref.read(recordingProvider.notifier).stop();
    if (!mounted) return;
    await SaveRecordingDialog.show(context);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.recordingBackdrop,
      body: SafeArea(
        child: Column(
          children: [
            // Status + timer
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.lg),
              child: _RecordingHeader(),
            ),
            // Visualizer
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: AudioVisualizer(),
                ),
              ),
            ),
            // Controls
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: _RecordingControls(
                onStop: _stop,
                onPause: _togglePause,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingHeader extends ConsumerWidget {
  const _RecordingHeader();

  static String _format(int totalSeconds) {
    final h = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed = ref.watch(
      recordingProvider.select((s) => s.elapsedSeconds),
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'RECORDING',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(_format(elapsed), style: AppTypography.timer),
        const SizedBox(height: AppSpacing.base),
        Text(
          'High Fidelity Mono • 48kHz',
          style: AppTypography.bodySm
              .copyWith(color: Colors.white.withValues(alpha: 0.6)),
        ),
      ],
    );
  }
}

class _RecordingControls extends StatelessWidget {
  const _RecordingControls({required this.onStop, required this.onPause});

  final VoidCallback onStop;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SecondaryControl(icon: Icons.pause, onTap: onPause),
            const SizedBox(width: AppSpacing.md),
            _StopButton(onTap: onStop),
            const SizedBox(width: AppSpacing.md),
            const _SecondaryControl(icon: Icons.bookmark_border),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'TAP TO STOP AND SAVE',
          style: AppTypography.labelMd.copyWith(
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _SecondaryControl extends StatelessWidget {
  const _SecondaryControl({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1),
              blurRadius: 40,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),
      ),
    );
  }
}
