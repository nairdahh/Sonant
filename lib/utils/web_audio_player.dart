// lib/utils/web_audio_player.dart
// Web-specific audio player using HTML5 Audio element

// Conditional import
export 'web_audio_player_stub.dart'
    if (dart.library.html) 'web_audio_player_web.dart';
