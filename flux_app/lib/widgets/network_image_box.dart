import 'package:flutter/material.dart';

import 'package:flux_app/theme/app_colors.dart';

/// Network image with a graceful colored fallback (placeholder URLs may expire).
class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_outlined,
  });

  final String url;
  final BoxFit fit;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(color: AppColors.surfaceContainerHigh);
      },
      errorBuilder: (context, _, __) => ColoredBox(
        color: AppColors.surfaceContainerHigh,
        child: Icon(fallbackIcon, color: AppColors.secondaryFixedDim),
      ),
    );
  }
}
