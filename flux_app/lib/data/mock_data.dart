import 'package:flux_app/models/video_item.dart';

/// Static placeholder content used only to populate the interface.
/// Replace with real data sources when functionality lands.
abstract final class MockData {
  static const galleryFilters = <String>[
    'All',
    'Today',
    'This Week',
    'This Month',
  ];

  /// No seeded videos — the gallery starts empty and fills with real
  /// recordings as they are captured.
  static const videos = <VideoItem>[];
}
