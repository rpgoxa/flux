import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// SharedPreferences keys.
const _kQuality = 'flux_quality';
const _kSaveToPhotos = 'flux_save_to_photos';

/// Loads persisted recording prefs on startup and writes through on every
/// change so settings survive app restarts. Async because reading prefs is
/// async; the settings UI shows a brief loader on first load.
class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsState(
      quality: _readQuality(prefs),
      saveToPhotos: prefs.getBool(_kSaveToPhotos) ?? true,
    );
  }

  QualityPreset _readQuality(SharedPreferences prefs) {
    final name = prefs.getString(_kQuality);
    if (name == null) return QualityPreset.medium;
    return QualityPreset.values
        .firstWhere((q) => q.name == name, orElse: () => QualityPreset.medium);
  }

  /// Current state regardless of async phase; falls back to defaults.
  SettingsState get _current => state.valueOrNull ?? const SettingsState();

  Future<void> setQuality(QualityPreset preset) async {
    state = AsyncData(_current.copyWith(quality: preset));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kQuality, preset.name);
  }

  /// Selector callback — maps the tapped index to a preset.
  Future<void> selectQualityIndex(int index) =>
      setQuality(QualityPreset.values[index]);

  Future<void> setSaveToPhotos(bool value) async {
    state = AsyncData(_current.copyWith(saveToPhotos: value));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSaveToPhotos, value);
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
