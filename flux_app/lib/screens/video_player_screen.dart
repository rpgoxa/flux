import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_spacing.dart';
import 'package:flux_app/theme/app_typography.dart';

/// Fullscreen, themed player for a single recording. Allows rotation while
/// open and restores portrait + system UI on dispose.
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.filePath,
    required this.title,
  });

  final String filePath;
  final String title;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _initError = false;
  String? _errorDetail;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _init();
  }

  Future<void> _init() async {
    final path = widget.filePath;
    final file = File(path);

    final exists = await file.exists();
    final size = exists ? await file.length() : 0;
    debugPrint('[Flux] play path=$path exists=$exists size=$size');

    if (!exists) {
      _fail('File not found.\n$path');
      return;
    }
    if (size <= 0) {
      _fail('File is empty (0 bytes) — recording likely failed.\n$path');
      return;
    }

    final controller = VideoPlayerController.file(file);
    try {
      await controller.initialize();
      // ExoPlayer decode failures surface on the value, not as a throw.
      if (controller.value.hasError) {
        final desc = controller.value.errorDescription ?? 'unknown decode error';
        await controller.dispose();
        _fail('Playback error: $desc\nsize=${_fmtSize(size)}\n$path');
        return;
      }
      await controller.setLooping(false);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.addListener(_onTick);
      setState(() => _controller = controller);
      await controller.play();
    } catch (e, st) {
      debugPrint('[Flux] init failed: $e\n$st');
      await controller.dispose();
      _fail('Could not play this recording.\n$e\nsize=${_fmtSize(size)}\n$path');
    }
  }

  void _fail(String detail) {
    if (!mounted) return;
    setState(() {
      _initError = true;
      _errorDetail = detail;
    });
  }

  void _onTick() {
    final c = _controller;
    // Surface a runtime decode error that appears after init.
    if (c != null && c.value.hasError && !_initError) {
      _fail(
        'Playback error: ${c.value.errorDescription ?? "unknown"}\n'
        '${widget.filePath}',
      );
      return;
    }
    if (mounted) setState(() {});
  }

  static String _fmtSize(int bytes) {
    final mb = bytes / (1024 * 1024);
    return mb >= 1 ? '${mb.toStringAsFixed(1)} MB' : '$bytes B';
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null) return;
    setState(() {
      c.value.isPlaying ? c.pause() : c.play();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildBody()),
            // Back button (always visible)
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: _CircleIcon(
                icon: Icons.arrow_back,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_initError) return _PlayerError(detail: _errorDetail);

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _controlsVisible = !_controlsVisible),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio == 0
                  ? 16 / 9
                  : controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          if (_controlsVisible) _Controls(controller: controller, onPlayPause: _togglePlay),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller, required this.onPlayPause});

  final VideoPlayerController controller;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    return Container(
      color: Colors.black26,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.onPrimary,
                size: 40,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Text(
                  _fmt(value.position),
                  style: AppTypography.bodySm.copyWith(color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppColors.primary,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _fmt(value.duration),
                  style: AppTypography.bodySm.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  const _PlayerError({this.detail});

  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Could not play this recording',
              style: AppTypography.bodyLg.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            if (detail != null) ...[
              const SizedBox(height: AppSpacing.sm),
              SelectableText(
                detail!,
                style: AppTypography.bodySm.copyWith(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
