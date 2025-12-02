// lib/utils/audio_url_helper_stub.dart
// Stub for non-web platforms

String createBlobUrl(String base64Audio) {
  // Not used on native platforms
  return 'data:audio/mpeg;base64,$base64Audio';
}

void revokeBlobUrl(String url) {
  // No-op on native platforms
}
