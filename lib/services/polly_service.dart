// lib/services/polly_service.dart - CLIENT pentru Firebase Cloud Functions

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/polly_response.dart';

class PollyService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Pentru development local cu emulator
  PollyService() {
    if (kDebugMode) {
      // ✅ ACTIVAT pentru development local
      // try {
      //  _functions.useFunctionsEmulator('localhost', 5001);
      //  debugPrint('🔧 Using Firebase Functions Emulator on localhost:5001');
      // } catch (e) {
      //  debugPrint('⚠️ Could not connect to emulator: $e');
      //  debugPrint('   Make sure to run: firebase emulators:start');
      // }
    }
  }

  /// Sintetizează speech folosind Firebase Cloud Function
  /// 🔒 AWS credentials rămân SIGURE pe server!
  Future<PollyResponse?> synthesizeSpeech(
    String text, {
    String voiceId = 'Joanna',
    String engine = 'neural',
    Function(double)? onProgress,
  }) async {
    try {
      // ✅ Verifică autentificarea
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ User not authenticated');
        return null;
      }

      debugPrint('🎵 Calling Cloud Function: synthesizeSpeech');
      debugPrint('   Text length: ${text.length} chars');
      debugPrint('   Voice: $voiceId');

      // Limitare text (AWS Polly max 3000 chars)
      String textToSynthesize = text;
      if (text.length > 2900) {
        debugPrint('⚠️ Text truncated: ${text.length} → 2900 chars');
        textToSynthesize = text.substring(0, 2900);
      }

      // 📞 Apelează Cloud Function
      final callable = _functions.httpsCallable(
        'synthesizeSpeech',
        options: HttpsCallableOptions(
          timeout: const Duration(minutes: 5), // Pentru texte lungi
        ),
      );

      final result = await callable.call<Map<String, dynamic>>({
        'text': textToSynthesize,
        'voiceId': voiceId,
        'engine': engine,
      });

      final data = result.data;

      // Parse response
      final audioUrl = data['audioUrl'] as String?;
      final speechMarksData = data['speechMarks'] as List<dynamic>?;

      if (audioUrl == null || speechMarksData == null) {
        debugPrint('❌ Invalid response from Cloud Function');
        return null;
      }

      // Convertim speech marks
      final speechMarks = speechMarksData
          .map((mark) => SpeechMark.fromJson(mark as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Audio received: ${audioUrl.length} chars (base64)');
      debugPrint('✅ Speech marks: ${speechMarks.length} words');

      return PollyResponse(
        audioUrl: audioUrl,
        speechMarks: speechMarks,
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ Firebase Functions error:');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Details: ${e.details}');

      // Erori user-friendly
      String userMessage;
      switch (e.code) {
        case 'unauthenticated':
          userMessage =
              'Trebuie să fii autentificat pentru a folosi text-to-speech';
          break;
        case 'invalid-argument':
          userMessage = 'Text invalid sau prea lung (max 3000 caractere)';
          break;
        case 'resource-exhausted':
          userMessage = 'Limită de utilizare atinsă. Încearcă mai târziu';
          break;
        default:
          userMessage = 'Eroare la generarea audio: ${e.message}';
      }

      // Aici poți afișa un SnackBar sau Dialog
      debugPrint('💬 User message: $userMessage');

      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return null;
    }
  }

  /// Obține lista vocilor disponibile
  Future<List<VoiceInfo>?> listVoices() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final callable = _functions.httpsCallable('listVoices');
      final result = await callable.call<Map<String, dynamic>>();

      final voicesData = result.data['voices'] as List<dynamic>;
      return voicesData
          .map((v) => VoiceInfo.fromJson(v as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error listing voices: $e');
      return null;
    }
  }
}

// Model pentru informații voce
class VoiceInfo {
  final String id;
  final String language;
  final String gender;
  final String engine;

  VoiceInfo({
    required this.id,
    required this.language,
    required this.gender,
    required this.engine,
  });

  factory VoiceInfo.fromJson(Map<String, dynamic> json) {
    return VoiceInfo(
      id: json['id'] as String,
      language: json['language'] as String,
      gender: json['gender'] as String,
      engine: json['engine'] as String,
    );
  }
}
