// lib/utils/web_audio_player_web.dart
// Web implementation using native HTML5 Audio
// Migrated from dart:html to package:web + dart:js_interop

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

class WebAudioPlayer {
  web.HTMLAudioElement? _audio;
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();
  Timer? _positionTimer;
  Duration? _duration;

  /// Callback when audio completes
  void Function()? onComplete;

  WebAudioPlayer() {
    _audio = web.HTMLAudioElement();
    _setupListeners();
  }

  void _startPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final audio = _audio;
      if (audio != null && audio.currentTime.isFinite) {
        _positionController
            .add(Duration(milliseconds: (audio.currentTime * 1000).round()));
      }
    });
  }

  void _stopPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  void _setupListeners() {
    final audio = _audio;
    if (audio == null) return;

    // Use addEventListener with JSFunction callbacks for package:web
    audio.addEventListener(
      'play',
      ((web.Event event) {
        _playingController.add(true);
        _startPositionUpdates();
      }).toJS,
    );

    audio.addEventListener(
      'pause',
      ((web.Event event) {
        _playingController.add(false);
        _stopPositionUpdates();
      }).toJS,
    );

    audio.addEventListener(
      'ended',
      ((web.Event event) {
        _playingController.add(false);
        _stopPositionUpdates();
        // Call completion callback
        onComplete?.call();
      }).toJS,
    );

    audio.addEventListener(
      'durationchange',
      ((web.Event event) {
        if (audio.duration.isFinite) {
          _duration = Duration(milliseconds: (audio.duration * 1000).round());
        }
      }).toJS,
    );
  }

  Future<Duration?> setUrl(String url) async {
    final audio = _audio;
    if (audio == null) return null;

    final completer = Completer<Duration?>();
    var completed = false;

    // Listen for metadata loaded
    void Function(web.Event)? onLoadedMetadata;
    void Function(web.Event)? onError;

    onLoadedMetadata = (web.Event event) {
      if (completed) return;
      completed = true;
      if (audio.duration.isFinite) {
        _duration = Duration(milliseconds: (audio.duration * 1000).round());
        completer.complete(_duration);
      } else {
        completer.complete(null);
      }
    };

    onError = (web.Event event) {
      if (completed) return;
      completed = true;
      completer.completeError(Exception('Failed to load audio'));
    };

    audio.addEventListener('loadedmetadata', onLoadedMetadata.toJS);
    audio.addEventListener('error', onError.toJS);

    // Set the source
    audio.src = url;
    audio.load();

    // Add timeout
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        completed = true;
        return null;
      },
    );
  }

  Future<void> play() async {
    await _audio?.play().toDart;
  }

  Future<void> pause() async {
    _audio?.pause();
  }

  Future<void> stop() async {
    final audio = _audio;
    if (audio != null) {
      audio.pause();
      audio.currentTime = 0;
    }
    _playingController.add(false);
    _stopPositionUpdates();
  }

  Future<void> seek(Duration position) async {
    final audio = _audio;
    if (audio != null) {
      audio.currentTime = position.inMilliseconds / 1000.0;
    }
  }

  Future<void> setSpeed(double speed) async {
    final audio = _audio;
    if (audio != null) {
      audio.playbackRate = speed;
    }
  }

  Duration? get duration => _duration;

  Stream<Duration> get positionStream => _positionController.stream;

  Stream<bool> get playingStream => _playingController.stream;

  void dispose() {
    _positionTimer?.cancel();
    _audio?.pause();
    _audio = null;
    _positionController.close();
    _playingController.close();
  }
}

/// Factory function to create WebAudioPlayer
WebAudioPlayer createWebAudioPlayer() => WebAudioPlayer();
