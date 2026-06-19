import 'package:flutter/material.dart';

import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_spacing.dart';
import 'package:flux_app/theme/app_typography.dart';

/// The three primary destinations.
enum FluxTab { record, gallery, settings }

/// Bottom navigation matching the design: active tab is a filled pill.
class FluxBottomNav extends StatelessWidget {
  const FluxBottomNav({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final FluxTab current;
  final ValueChanged<FluxTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile,
            AppSpacing.xs,
            AppSpacing.marginMobile,
            AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.radio_button_checked,
                label: 'Record',
                active: current == FluxTab.record,
                onTap: () => onSelect(FluxTab.record),
              ),
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Gallery',
                active: current == FluxTab.gallery,
                onTap: () => onSelect(FluxTab.gallery),
              ),
              _NavItem(
                icon: Icons.settings,
                label: 'Settings',
                active: current == FluxTab.settings,
                onTap: () => onSelect(FluxTab.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        active ? AppColors.onPrimaryContainer : AppColors.secondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.base),
            Text(label, style: AppTypography.labelMd.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
