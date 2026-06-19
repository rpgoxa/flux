import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flux_app/services/recording_service.dart';

/// Capture quality presets. Index order matches the on-screen selector
/// (Low / Medium / High / Ultra); resolution + frame rate derive from the
/// preset, and each maps to a native [RecordingQuality] tier.
enum QualityPreset {
  low,
  medium,
  high,
  ultra;

  String get resolution => switch (this) {
        QualityPreset.low => '720p',
        QualityPreset.medium => '1080p',
        QualityPreset.high => '1080p',
        QualityPreset.ultra => 'Native',
      };

  int get frameRate => switch (this) {
        QualityPreset.low => 30,
        QualityPreset.medium => 30,
        QualityPreset.high => 60,
        QualityPreset.ultra => 60,
      };

  /// Tier handed to the native screen-capture engine.
  RecordingQuality get recordingQuality => switch (this) {
        QualityPreset.low => RecordingQuality.low,
        QualityPreset.medium => RecordingQuality.medium,
        QualityPreset.high => RecordingQuality.high,
        QualityPreset.ultra => RecordingQuality.ultra,
      };
}

/// Immutable recording-preferences snapshot.
class SettingsState {
  const SettingsState({
    this.quality = QualityPreset.medium,
    this.saveToPhotos = true,
  });

  final QualityPreset quality;
  final bool saveToPhotos;

  SettingsState copyWith({QualityPreset? quality, bool? saveToPhotos}) {
    return SettingsState(
      quality: quality ?? this.quality,
      saveToPhotos: saveToPhotos ?? this.saveToPhotos,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void setQuality(QualityPreset preset) =>
      state = state.copyWith(quality: preset);

  /// Selector callback — maps the tapped index to a preset.
  void selectQualityIndex(int index) =>
      state = state.copyWith(quality: QualityPreset.values[index]);

  void setSaveToPhotos(bool value) =>
      state = state.copyWith(saveToPhotos: value);
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
