// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NormalizationOptionsImpl _$$NormalizationOptionsImplFromJson(
        Map<String, dynamic> json) =>
    _$NormalizationOptionsImpl(
      normalize: json['normalize'] as bool? ?? true,
      unitNormalization: json['unitNormalization'] as bool? ?? false,
      urlNormalization: json['urlNormalization'] as bool? ?? true,
      emailNormalization: json['emailNormalization'] as bool? ?? true,
      optionalPluralizationNormalization:
          json['optionalPluralizationNormalization'] as bool? ?? true,
      phoneNormalization: json['phoneNormalization'] as bool? ?? true,
      replaceRemainingSymbols: json['replaceRemainingSymbols'] as bool? ?? true,
    );

Map<String, dynamic> _$$NormalizationOptionsImplToJson(
        _$NormalizationOptionsImpl instance) =>
    <String, dynamic>{
      'normalize': instance.normalize,
      'unitNormalization': instance.unitNormalization,
      'urlNormalization': instance.urlNormalization,
      'emailNormalization': instance.emailNormalization,
      'optionalPluralizationNormalization':
          instance.optionalPluralizationNormalization,
      'phoneNormalization': instance.phoneNormalization,
      'replaceRemainingSymbols': instance.replaceRemainingSymbols,
    };

_$PhonemeResultImpl _$$PhonemeResultImplFromJson(Map<String, dynamic> json) =>
    _$PhonemeResultImpl(
      phonemes: json['phonemes'] as String,
      tokens: (json['tokens'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$$PhonemeResultImplToJson(_$PhonemeResultImpl instance) =>
    <String, dynamic>{
      'phonemes': instance.phonemes,
      'tokens': instance.tokens,
    };

_$TtsResponseImpl _$$TtsResponseImplFromJson(Map<String, dynamic> json) =>
    _$TtsResponseImpl(
      audioUrl: json['audioUrl'] as String?,
      speechMarks: (json['speechMarks'] as List<dynamic>)
          .map((e) => SpeechMark.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TtsResponseImplToJson(_$TtsResponseImpl instance) =>
    <String, dynamic>{
      'audioUrl': instance.audioUrl,
      'speechMarks': instance.speechMarks,
    };

_$SpeechMarkImpl _$$SpeechMarkImplFromJson(Map<String, dynamic> json) =>
    _$SpeechMarkImpl(
      time: (json['time'] as num).toDouble(),
      type: json['type'] as String,
      start: (json['start'] as num).toInt(),
      end: (json['end'] as num).toInt(),
      value: json['value'] as String,
      sentenceStart: (json['sentenceStart'] as num?)?.toInt(),
      sentenceEnd: (json['sentenceEnd'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$SpeechMarkImplToJson(_$SpeechMarkImpl instance) =>
    <String, dynamic>{
      'time': instance.time,
      'type': instance.type,
      'start': instance.start,
      'end': instance.end,
      'value': instance.value,
      'sentenceStart': instance.sentenceStart,
      'sentenceEnd': instance.sentenceEnd,
    };
