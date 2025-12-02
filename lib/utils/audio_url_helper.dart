// lib/utils/audio_url_helper.dart

import 'package:flutter/foundation.dart';

// Conditional import for web
import 'audio_url_helper_stub.dart'
    if (dart.library.html) 'audio_url_helper_web.dart' as platform;

/// Converts base64 audio data to a playable URL
/// On Web: Creates a Blob URL for better performance
/// On Native: Returns data URI (works fine)
String createAudioUrl(String base64Audio) {
  if (kIsWeb) {
    return platform.createBlobUrl(base64Audio);
  }

  // Native platforms can use data URI
  return 'data:audio/mpeg;base64,$base64Audio';
}
