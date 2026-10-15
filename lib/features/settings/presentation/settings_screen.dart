import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accessibility/widgets/accessible_radio_group.dart';
import '../../../core/accessibility/widgets/accessible_switch_tile.dart';
import '../../../core/accessibility/widgets/adjustable_value.dart';
import '../../../core/accessibility/widgets/headings.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/providers/core_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/entities/app_settings.dart';
import 'settings_controller.dart';

/// Versión mostrada en "Acerca de" (igual que `version` en pubspec.yaml).
const appVersion = '1.0.0';

/// Ajustes (UI.md §4.10). Cada grupo empieza con un encabezado; los cambios
/// se guardan y se anuncian al instante.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    void changed(String setting, String value) =>
        ref.read(announcerProvider).announce(l10n.settingsChanged(setting, value));

    String rateText(double r) => l10n.resultSpeedValue(r.toStringAsFixed(1));
    double round(double v) => (v * 10).round() / 10;
    final rate = settings.speechRate;

    final themeLabels = {
      ThemePreference.sistema: l10n.themeSystem,
      ThemePreference.claro: l10n.themeLight,
      ThemePreference.oscuro: l10n.themeDark,
      ThemePreference.altoContraste: l10n.themeHighContrast,
    };

    final detailOptions = [
      RadioOption(value: NivelDetalle.breve, label: l10n.detailBrief, description: l10n.detailBriefDescription),
      RadioOption(
        value: NivelDetalle.estandar,
        label: l10n.detailStandard,
        description: l10n.detailStandardDescription,
      ),
      RadioOption(
        value: NivelDetalle.exhaustivo,
        label: l10n.detailExhaustive,
        description: l10n.detailExhaustiveDescription,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: ScreenTitle(l10n.settingsTitle)),
      body: ResponsiveBody(
        children: [
          SectionHeader(l10n.settingsVoiceHeader, padding: const EdgeInsets.only(bottom: 8)),
          AdjustableValue(
            label: l10n.settingsSpeechRate,
            valueText: rateText(rate),
            increasedValueText: rateText(rate + 0.1),
            decreasedValueText: rateText(rate - 0.1),
            onIncrease: rate < AppSettings.maxSpeechRate - 0.05
                ? () => controller.update((s) => s.copyWith(speechRate: round(rate + 0.1)))
                : null,
            onDecrease: rate > AppSettings.minSpeechRate + 0.05
                ? () => controller.update((s) => s.copyWith(speechRate: round(rate - 0.1)))
                : null,
          ),

          SectionHeader(l10n.settingsDescriptionHeader),
          Text(l10n.settingsDetailLevel, style: Theme.of(context).textTheme.titleSmall),
          AccessibleRadioGroup<NivelDetalle>(
            options: detailOptions,
            selected: settings.nivelDetalle,
            onChanged: (value) {
              controller.update((s) => s.copyWith(nivelDetalle: value));
              changed(
                l10n.settingsDetailLevel,
                detailOptions.firstWhere((o) => o.value == value).label,
              );
            },
          ),

          SectionHeader(l10n.settingsAppearanceHeader),
          Text(l10n.themeHeader, style: Theme.of(context).textTheme.titleSmall),
          AccessibleRadioGroup<ThemePreference>(
            options: [
              for (final entry in themeLabels.entries)
                RadioOption(value: entry.key, label: entry.value),
            ],
            selected: settings.themePreference,
            onChanged: (value) {
              controller.update((s) => s.copyWith(themePreference: value));
              changed(l10n.themeHeader, themeLabels[value]!);
            },
          ),
          const SizedBox(height: 8),
          Text(l10n.settingsTextSizeNote, style: Theme.of(context).textTheme.bodySmall),

          SectionHeader(l10n.settingsFeedbackHeader),
          AccessibleSwitchTile(
            title: l10n.settingsVibration,
            value: settings.hapticsEnabled,
            onChanged: (value) {
              controller.update((s) => s.copyWith(hapticsEnabled: value));
              changed(l10n.settingsVibration, value ? l10n.settingsOn : l10n.settingsOff);
            },
          ),

          SectionHeader(l10n.settingsAboutHeader),
          Text(l10n.settingsVersion(appVersion), style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
