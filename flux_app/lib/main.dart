import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux_app/screens/home_shell.dart';
import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_theme.dart';
import 'package:flux_app/theme/app_typography.dart';

void main() => runApp(const ProviderScope(child: FluxApp()));

class FluxApp extends StatelessWidget {
  const FluxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flux',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const FluxSplash(),
    );
  }
}

/// Brief branded splash shown on cold start, then hands off to the shell.
class FluxSplash extends StatefulWidget {
  const FluxSplash({super.key});

  @override
  State<FluxSplash> createState() => _FluxSplashState();
}

class _FluxSplashState extends State<FluxSplash> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => const HomeShell(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Text(
          'Flux',
          style: AppTypography.displayLg.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
