import 'dart:math';

import 'package:flutter/material.dart';

/// Animated bar visualizer for the active-recording HUD (cosmetic only).
class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer({super.key, this.barCount = 40});

  final int barCount;

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  )..repeat();

  final _random = Random();
  late List<double> _heights =
      List.generate(widget.barCount, (_) => _random.nextDouble() * 0.8 + 0.1);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.value < 0.1) {
        setState(() {
          _heights = List.generate(
            widget.barCount,
            (_) => _random.nextDouble() * 0.8 + 0.1,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < widget.barCount; i++) ...[
            _Bar(
              heightFactor: _heights[i],
              opacity: _centerWeightedOpacity(i),
            ),
            if (i != widget.barCount - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }

  double _centerWeightedOpacity(int index) {
    final centerDist =
        (index - widget.barCount / 2).abs() / (widget.barCount / 2);
    return (0.8 - centerDist * 0.6).clamp(0.15, 0.8).toDouble();
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.heightFactor, required this.opacity});

  final double heightFactor;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 4,
      height: 128 * heightFactor,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
