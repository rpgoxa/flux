import 'package:flutter/material.dart';

import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_spacing.dart';
import 'package:flux_app/theme/app_typography.dart';

/// Shared top bar: "Flux" wordmark + notifications action.
/// Placed inside the shell's [SafeArea]; not used as a Scaffold appBar slot.
class FluxAppBar extends StatelessWidget {
  const FluxAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Text(
              'Flux',
              style: AppTypography.headlineLgMobile
                  .copyWith(color: AppColors.primary),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
              color: AppColors.onSurfaceVariant,
              iconSize: 28,
            ),
          ],
        ),
    );
  }
}
