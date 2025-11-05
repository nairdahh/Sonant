// lib/models/tts_response.dart

class TtsResponse {
  final String? audioUrl;
  final List<SpeechMark> speechMarks;

  TtsResponse({this.audioUrl, required this.speechMarks});
}

class SpeechMark {
  final double time;
  final String type;
  final int start;
  final int end;
  final String value;

  SpeechMark({
    required this.time,
    required this.type,
    required this.start,
    required this.end,
    required this.value,
  });

  factory SpeechMark.fromJson(Map<String, dynamic> json) {
    return SpeechMark(
      time: json['time'],
      type: json['type'],
      start: json['start'],
      end: json['end'],
      value: json['value'],
    );
  }
}
