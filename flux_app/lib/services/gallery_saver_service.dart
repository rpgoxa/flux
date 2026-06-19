import 'package:flutter/services.dart';

/// Copies a recording into the phone's public gallery (Movies/Flux) via a
/// native channel. Handles the MediaStore vs legacy-storage split on Android.
class GallerySaverService {
  GallerySaverService._();
  static final GallerySaverService instance = GallerySaverService._();

  static const _channel = MethodChannel('flux_app/gallery_saver');

  /// Returns true if the file was exported to the gallery.
  Future<bool> saveToGallery(String videoPath) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'saveToGallery',
        {'videoPath': videoPath},
      );
      return result != null;
    } on PlatformException {
      return false;
    }
  }
}
