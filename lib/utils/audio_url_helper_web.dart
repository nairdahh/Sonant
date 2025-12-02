// lib/utils/audio_url_helper_web.dart
// Web-specific implementation using Blob URLs
// Migrated from dart:html to package:web + dart:js_interop

import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

String createBlobUrl(String base64Audio) {
  try {
    // Decode base64 to bytes
    final bytes = base64Decode(base64Audio);

    debugPrint('🎵 Creating Blob URL: ${bytes.length} bytes');

    // Create JSUint8Array from Dart bytes
    final jsArray = bytes.toJS;

    // Create Blob from bytes with proper MIME type
    final blobParts = [jsArray].toJS;
    final options = web.BlobPropertyBag(type: 'audio/mpeg');
    final blob = web.Blob(blobParts, options);

    // Create URL for the Blob
    final url = web.URL.createObjectURL(blob);

    debugPrint('🎵 Blob URL created: ${url.substring(0, 50)}...');

    return url;
  } catch (e) {
    debugPrint('❌ Blob creation error: $e');
    // Fallback to data URI if Blob creation fails
    return 'data:audio/mpeg;base64,$base64Audio';
  }
}

void revokeBlobUrl(String url) {
  if (url.startsWith('blob:')) {
    try {
      web.URL.revokeObjectURL(url);
    } catch (_) {
      // Ignore errors
    }
  }
}
