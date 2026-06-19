import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux_app/providers/settings_provider.dart';
import 'package:flux_app/theme/app_colors.dart';
import 'package:flux_app/theme/app_spacing.dart';
import 'package:flux_app/theme/app_typography.dart';
import 'package:flux_app/widgets/quality_selector.dart';
import 'package:flux_app/widgets/section_header.dart';
import 'package:flux_app/widgets/settings_card.dart';

/// Tab 3 — recording preferences and app info.
class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return settingsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => Center(
        child: Text('Could not load settings', style: AppTypography.bodyLg),
      ),
      data: (settings) => _buildSettings(context, settings, notifier),
    );
  }

  Widget _buildSettings(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.md,
        AppSpacing.marginMobile,
        AppSpacing.lg,
      ),
      children: [
        // Video Quality
        const SectionHeader(icon: Icons.high_quality, title: 'Video Quality'),
        const SizedBox(height: AppSpacing.sm),
        QualitySelector(
          options: const ['Low', 'Medium', 'High', 'Ultra'],
          selectedIndex: settings.quality.index,
          onSelect: notifier.selectQualityIndex,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          child: Text('Balance performance and clarity.'),
        ),
        const SizedBox(height: AppSpacing.md),

        // Save to Photos
        SettingsCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(Icons.photo_library, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Save to Photos', style: AppTypography.titleMd),
                    Text(
                      'Automatically back up media',
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.saveToPhotos,
                onChanged: notifier.setSaveToPhotos,
                activeColor: Colors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.surfaceContainerHighest,
                trackOutlineColor:
                    const WidgetStatePropertyAll(Colors.transparent),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // About Flux
        const SectionHeader(icon: Icons.info_outline, title: 'About Flux'),
        const SizedBox(height: AppSpacing.sm),
        SettingsCard(
          child: Column(
            children: const [
              _InfoRow(label: 'Version', trailingText: '2.4.0 (Red Panda)'),
              Divider(),
              _InfoRow(label: 'Privacy Policy', chevron: true),
              Divider(),
              _InfoRow(label: 'Terms of Service', chevron: true),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Branding flourish
        Opacity(
          opacity: 0.3,
          child: Column(
            children: [
              Transform.rotate(
                angle: 0.21,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.xl + 4),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'MADE FOR CREATORS',
                style:
                    AppTypography.labelMd.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.trailingText,
    this.chevron = false,
  });

  final String label;
  final String? trailingText;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyLg)),
          if (trailingText != null)
            Text(
              trailingText!,
              style:
                  AppTypography.labelMd.copyWith(color: AppColors.secondary),
            ),
          if (chevron)
            const Icon(Icons.chevron_right, color: AppColors.secondary),
        ],
      ),
    );
  }
}
