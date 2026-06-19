import 'package:flutter/material.dart';

import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_spacing.dart';
import 'package:flux_app/theme/app_typography.dart';

/// A capture-source toggle (Microphone / Camera) shown on the record home grid.
class CaptureToggleCard extends StatelessWidget {
  const CaptureToggleCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primary : AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: AppTypography.labelMd),
          const SizedBox(height: AppSpacing.sm),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.secondaryContainer,
            trackOutlineColor:
                const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
