/// Lifecycle phases for a recording session.
enum RecordingPhase { idle, countdown, recording, paused, saving }

/// Immutable snapshot of the recording session.
class RecordingState {
  const RecordingState({
    this.phase = RecordingPhase.idle,
    this.duration = Duration.zero,
    this.micEnabled = true,
    this.cameraEnabled = false,
    this.filePath,
    this.errorMessage,
    this.elapsedSeconds = 0,
  });

  final RecordingPhase phase;
  final Duration duration;
  final bool micEnabled;
  final bool cameraEnabled;
  final String? filePath;
  final String? errorMessage;
  final int elapsedSeconds;

  bool get isActive =>
      phase == RecordingPhase.recording || phase == RecordingPhase.paused;

  RecordingState copyWith({
    RecordingPhase? phase,
    Duration? duration,
    bool? micEnabled,
    bool? cameraEnabled,
    String? filePath,
    bool clearFilePath = false,
    String? errorMessage,
    bool clearError = false,
    int? elapsedSeconds,
  }) {
    return RecordingState(
      phase: phase ?? this.phase,
      duration: duration ?? this.duration,
      micEnabled: micEnabled ?? this.micEnabled,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
      filePath: clearFilePath ? null : (filePath ?? this.filePath),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}
