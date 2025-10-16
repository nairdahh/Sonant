// lib/services/polly_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart'; // ✅ Import pentru AudioPlayer
import '../models/polly_response.dart';
import 'package:aws_polly_api/polly-2016-06-10.dart';

class PollyService {
  final String? _accessKey = dotenv.env['AWS_ACCESS_KEY_ID'];
  final String? _secretKey = dotenv.env['AWS_SECRET_ACCESS_KEY'];
  final String? _region = dotenv.env['AWS_REGION'];

  // AWS Polly are o limită de 3000 caractere per request
  static const int maxCharsPerRequest = 2900;

  // Metoda optimizată pentru texte lungi (cărți)
  Future<PollyResponse?> synthesizeSpeech(
    String text, {
    String voiceId = 'Joanna',
    Function(double)? onProgress,
  }) async {
    if (_accessKey == null || _secretKey == null || _region == null) {
      debugPrint('EROARE CRITICĂ: Cheile AWS nu s-au încărcat din .env!');
      return null;
    }

    try {
      // ❌ NU mai împărțim textul - generăm direct
      // Dacă textul e prea lung pentru AWS Polly (>3000), îl trunChiem
      String textToSynthesize = text;
      if (text.length > maxCharsPerRequest) {
        debugPrint(
            '⚠️ Text prea lung (${text.length} caractere), trunChiem la $maxCharsPerRequest');
        textToSynthesize = text.substring(0, maxCharsPerRequest);
      }

      // Procesăm direct, fără împărțire
      return await _synthesizeShortText(textToSynthesize, voiceId);
    } catch (e) {
      debugPrint('Eroare în PollyService: $e');
      return null;
    }
  }

  // Sintetizare pentru texte scurte
  Future<PollyResponse?> _synthesizeShortText(
      String text, String voiceId) async {
    final client = Polly(
      region: _region!,
      credentials: AwsClientCredentials(
        accessKey: _accessKey!,
        secretKey: _secretKey!,
      ),
    );

    final voice = _getVoiceIdFromString(voiceId);
    final engine = _getEngineForVoice(voiceId);

    // Obținem Speech Marks
    debugPrint("--> Cerere pentru Speech Marks...");
    final speechMarksResponse = await client.synthesizeSpeech(
      outputFormat: OutputFormat.json,
      text: text,
      voiceId: voice,
      engine: engine,
      speechMarkTypes: [SpeechMarkType.word],
    );

    List<SpeechMark> speechMarks = [];
    if (speechMarksResponse.audioStream != null) {
      final bytes = speechMarksResponse.audioStream!;
      final responseBody = utf8.decode(bytes);
      final lines = responseBody.split('\n').where((line) => line.isNotEmpty);
      speechMarks =
          lines.map((line) => SpeechMark.fromJson(json.decode(line))).toList();
    }
    debugPrint("--> Speech Marks primite: ${speechMarks.length} cuvinte.");

    // Obținem audio
    debugPrint("--> Cerere pentru Audio MP3...");
    final audioResponse = await client.synthesizeSpeech(
      outputFormat: OutputFormat.mp3,
      text: text,
      voiceId: voice,
      engine: engine,
    );

    String? audioUrl;
    if (audioResponse.audioStream != null) {
      final audioBytes = audioResponse.audioStream!;
      final base64Audio = base64Encode(audioBytes);
      audioUrl = 'data:audio/mpeg;base64,$base64Audio';
    }
    debugPrint("--> Audio MP3 primit și codat.");

    client.close();
    return PollyResponse(audioUrl: audioUrl, speechMarks: speechMarks);
  }

  // Sintetizare pentru texte lungi (împărțim în bucăți)
  Future<PollyResponse?> _synthesizeLongText(
    String text,
    String voiceId,
    Function(double)? onProgress,
  ) async {
    debugPrint(
        "--> Text lung detectat (${text.length} caractere), împărțim în bucăți...");

    // Împărțim textul în bucăți la granițe de propoziții
    final chunks = _splitTextIntoChunks(text, maxCharsPerRequest);
    debugPrint("--> Text împărțit în ${chunks.length} bucăți");

    List<SpeechMark> allSpeechMarks = [];
    List<Uint8List> allAudioBytes = [];
    int totalTimeOffset = 0;
    int totalCharOffset = 0;

    // Creăm un AudioPlayer temporar pentru a măsura duratele reale
    final tempPlayer = AudioPlayer();

    try {
      for (int i = 0; i < chunks.length; i++) {
        if (onProgress != null) {
          onProgress((i + 1) / chunks.length);
        }

        debugPrint("--> Procesăm bucata ${i + 1}/${chunks.length}...");

        final chunkResponse = await _synthesizeShortText(chunks[i], voiceId);

        if (chunkResponse == null) {
          debugPrint("Eroare la procesarea bucății $i");
          continue;
        }

        // Obținem durata REALĂ a audio-ului generat
        int realDuration = 0;
        if (chunkResponse.audioUrl != null) {
          try {
            // Încărcăm audio-ul temporar pentru a citi durata
            await tempPlayer.setUrl(chunkResponse.audioUrl!);
            realDuration = tempPlayer.duration?.inMilliseconds ?? 0;
            debugPrint("   Durată reală audio: ${realDuration}ms");
          } catch (e) {
            debugPrint("   Eroare la citirea duratei: $e");
            // Fallback la estimare dacă citirea duratei eșuează
            final wordsInChunk = chunks[i].split(' ').length;
            realDuration = (wordsInChunk / 2.5 * 1000).round();
          }
        }

        // Adăugăm speech marks cu offset-ul REAL de timp
        for (var mark in chunkResponse.speechMarks) {
          allSpeechMarks.add(SpeechMark(
            time: mark.time + totalTimeOffset,
            type: mark.type,
            start: mark.start + totalCharOffset,
            end: mark.end + totalCharOffset,
            value: mark.value,
          ));
        }

        // Decodăm audio-ul și îl adăugăm
        if (chunkResponse.audioUrl != null) {
          final base64Data = chunkResponse.audioUrl!.split(',')[1];
          final audioBytes = base64Decode(base64Data);
          allAudioBytes.add(audioBytes);
        }

        // Actualizăm offset-urile cu valorile REALE
        totalTimeOffset += realDuration;
        totalCharOffset += chunks[i].length;

        // Pauză între requests pentru a evita rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } finally {
      // Curățăm player-ul temporar
      await tempPlayer.dispose();
    }

    // Combinăm toate audio-urile
    final combinedAudioBytes = allAudioBytes.expand((x) => x).toList();
    final base64Audio = base64Encode(combinedAudioBytes);
    final audioUrl = 'data:audio/mpeg;base64,$base64Audio';

    debugPrint(
        "--> Procesare completă: ${allSpeechMarks.length} cuvinte totale");
    debugPrint(
        "--> Durată totală audio: ${totalTimeOffset}ms (${(totalTimeOffset / 1000 / 60).toStringAsFixed(1)} minute)");

    return PollyResponse(audioUrl: audioUrl, speechMarks: allSpeechMarks);
  }

  // Împarte textul în bucăți la granițe de propoziții
  List<String> _splitTextIntoChunks(String text, int maxLength) {
    List<String> chunks = [];
    List<String> sentences = text.split(RegExp(r'[.!?]\s+'));

    String currentChunk = '';
    for (var sentence in sentences) {
      if (currentChunk.length + sentence.length > maxLength &&
          currentChunk.isNotEmpty) {
        chunks.add(currentChunk.trim());
        currentChunk = '$sentence. ';
      } else {
        currentChunk += '$sentence. ';
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }

    return chunks;
  }

  Engine? _getEngineForVoice(String voiceIdString) {
    final neuralVoices = [
      'Joanna',
      'Ivy',
      'Justin',
      'Kendra',
      'Kimberly',
      'Salli',
      'Joey',
      'Matthew',
      'Amy',
      'Emma',
      'Brian'
    ];

    return neuralVoices.contains(voiceIdString)
        ? Engine.neural
        : Engine.standard;
  }

  VoiceId _getVoiceIdFromString(String voiceIdString) {
    final voiceMap = {
      'Joanna': VoiceId.joanna,
      'Matthew': VoiceId.matthew,
      'Ivy': VoiceId.ivy,
      'Justin': VoiceId.justin,
      'Kendra': VoiceId.kendra,
      'Kimberly': VoiceId.kimberly,
      'Salli': VoiceId.salli,
      'Joey': VoiceId.joey,
      'Amy': VoiceId.amy,
      'Emma': VoiceId.emma,
      'Brian': VoiceId.brian,
      'Geraint': VoiceId.geraint,
      'Nicole': VoiceId.nicole,
      'Russell': VoiceId.russell,
    };

    return voiceMap[voiceIdString] ?? VoiceId.joanna;
  }
}
