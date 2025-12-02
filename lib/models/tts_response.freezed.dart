// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tts_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NormalizationOptions _$NormalizationOptionsFromJson(Map<String, dynamic> json) {
  return _NormalizationOptions.fromJson(json);
}

/// @nodoc
mixin _$NormalizationOptions {
  /// Normalizes input text to make it easier for the model to say
  bool get normalize => throw _privateConstructorUsedError;

  /// Transforms units like 10KB to 10 kilobytes
  bool get unitNormalization => throw _privateConstructorUsedError;

  /// Changes urls so they can be properly pronounced by kokoro
  bool get urlNormalization => throw _privateConstructorUsedError;

  /// Changes emails so they can be properly pronounced by kokoro
  bool get emailNormalization => throw _privateConstructorUsedError;

  /// Replaces (s) with s so some words get pronounced correctly
  bool get optionalPluralizationNormalization =>
      throw _privateConstructorUsedError;

  /// Changes phone numbers so they can be properly pronounced by kokoro
  bool get phoneNormalization => throw _privateConstructorUsedError;

  /// Replaces the remaining symbols after normalization with their words
  bool get replaceRemainingSymbols => throw _privateConstructorUsedError;

  /// Serializes this NormalizationOptions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NormalizationOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NormalizationOptionsCopyWith<NormalizationOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NormalizationOptionsCopyWith<$Res> {
  factory $NormalizationOptionsCopyWith(NormalizationOptions value,
          $Res Function(NormalizationOptions) then) =
      _$NormalizationOptionsCopyWithImpl<$Res, NormalizationOptions>;
  @useResult
  $Res call(
      {bool normalize,
      bool unitNormalization,
      bool urlNormalization,
      bool emailNormalization,
      bool optionalPluralizationNormalization,
      bool phoneNormalization,
      bool replaceRemainingSymbols});
}

/// @nodoc
class _$NormalizationOptionsCopyWithImpl<$Res,
        $Val extends NormalizationOptions>
    implements $NormalizationOptionsCopyWith<$Res> {
  _$NormalizationOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NormalizationOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? normalize = null,
    Object? unitNormalization = null,
    Object? urlNormalization = null,
    Object? emailNormalization = null,
    Object? optionalPluralizationNormalization = null,
    Object? phoneNormalization = null,
    Object? replaceRemainingSymbols = null,
  }) {
    return _then(_value.copyWith(
      normalize: null == normalize
          ? _value.normalize
          : normalize // ignore: cast_nullable_to_non_nullable
              as bool,
      unitNormalization: null == unitNormalization
          ? _value.unitNormalization
          : unitNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      urlNormalization: null == urlNormalization
          ? _value.urlNormalization
          : urlNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      emailNormalization: null == emailNormalization
          ? _value.emailNormalization
          : emailNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      optionalPluralizationNormalization: null ==
              optionalPluralizationNormalization
          ? _value.optionalPluralizationNormalization
          : optionalPluralizationNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      phoneNormalization: null == phoneNormalization
          ? _value.phoneNormalization
          : phoneNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      replaceRemainingSymbols: null == replaceRemainingSymbols
          ? _value.replaceRemainingSymbols
          : replaceRemainingSymbols // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NormalizationOptionsImplCopyWith<$Res>
    implements $NormalizationOptionsCopyWith<$Res> {
  factory _$$NormalizationOptionsImplCopyWith(_$NormalizationOptionsImpl value,
          $Res Function(_$NormalizationOptionsImpl) then) =
      __$$NormalizationOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool normalize,
      bool unitNormalization,
      bool urlNormalization,
      bool emailNormalization,
      bool optionalPluralizationNormalization,
      bool phoneNormalization,
      bool replaceRemainingSymbols});
}

/// @nodoc
class __$$NormalizationOptionsImplCopyWithImpl<$Res>
    extends _$NormalizationOptionsCopyWithImpl<$Res, _$NormalizationOptionsImpl>
    implements _$$NormalizationOptionsImplCopyWith<$Res> {
  __$$NormalizationOptionsImplCopyWithImpl(_$NormalizationOptionsImpl _value,
      $Res Function(_$NormalizationOptionsImpl) _then)
      : super(_value, _then);

  /// Create a copy of NormalizationOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? normalize = null,
    Object? unitNormalization = null,
    Object? urlNormalization = null,
    Object? emailNormalization = null,
    Object? optionalPluralizationNormalization = null,
    Object? phoneNormalization = null,
    Object? replaceRemainingSymbols = null,
  }) {
    return _then(_$NormalizationOptionsImpl(
      normalize: null == normalize
          ? _value.normalize
          : normalize // ignore: cast_nullable_to_non_nullable
              as bool,
      unitNormalization: null == unitNormalization
          ? _value.unitNormalization
          : unitNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      urlNormalization: null == urlNormalization
          ? _value.urlNormalization
          : urlNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      emailNormalization: null == emailNormalization
          ? _value.emailNormalization
          : emailNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      optionalPluralizationNormalization: null ==
              optionalPluralizationNormalization
          ? _value.optionalPluralizationNormalization
          : optionalPluralizationNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      phoneNormalization: null == phoneNormalization
          ? _value.phoneNormalization
          : phoneNormalization // ignore: cast_nullable_to_non_nullable
              as bool,
      replaceRemainingSymbols: null == replaceRemainingSymbols
          ? _value.replaceRemainingSymbols
          : replaceRemainingSymbols // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NormalizationOptionsImpl implements _NormalizationOptions {
  const _$NormalizationOptionsImpl(
      {this.normalize = true,
      this.unitNormalization = false,
      this.urlNormalization = true,
      this.emailNormalization = true,
      this.optionalPluralizationNormalization = true,
      this.phoneNormalization = true,
      this.replaceRemainingSymbols = true});

  factory _$NormalizationOptionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NormalizationOptionsImplFromJson(json);

  /// Normalizes input text to make it easier for the model to say
  @override
  @JsonKey()
  final bool normalize;

  /// Transforms units like 10KB to 10 kilobytes
  @override
  @JsonKey()
  final bool unitNormalization;

  /// Changes urls so they can be properly pronounced by kokoro
  @override
  @JsonKey()
  final bool urlNormalization;

  /// Changes emails so they can be properly pronounced by kokoro
  @override
  @JsonKey()
  final bool emailNormalization;

  /// Replaces (s) with s so some words get pronounced correctly
  @override
  @JsonKey()
  final bool optionalPluralizationNormalization;

  /// Changes phone numbers so they can be properly pronounced by kokoro
  @override
  @JsonKey()
  final bool phoneNormalization;

  /// Replaces the remaining symbols after normalization with their words
  @override
  @JsonKey()
  final bool replaceRemainingSymbols;

  @override
  String toString() {
    return 'NormalizationOptions(normalize: $normalize, unitNormalization: $unitNormalization, urlNormalization: $urlNormalization, emailNormalization: $emailNormalization, optionalPluralizationNormalization: $optionalPluralizationNormalization, phoneNormalization: $phoneNormalization, replaceRemainingSymbols: $replaceRemainingSymbols)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NormalizationOptionsImpl &&
            (identical(other.normalize, normalize) ||
                other.normalize == normalize) &&
            (identical(other.unitNormalization, unitNormalization) ||
                other.unitNormalization == unitNormalization) &&
            (identical(other.urlNormalization, urlNormalization) ||
                other.urlNormalization == urlNormalization) &&
            (identical(other.emailNormalization, emailNormalization) ||
                other.emailNormalization == emailNormalization) &&
            (identical(other.optionalPluralizationNormalization,
                    optionalPluralizationNormalization) ||
                other.optionalPluralizationNormalization ==
                    optionalPluralizationNormalization) &&
            (identical(other.phoneNormalization, phoneNormalization) ||
                other.phoneNormalization == phoneNormalization) &&
            (identical(
                    other.replaceRemainingSymbols, replaceRemainingSymbols) ||
                other.replaceRemainingSymbols == replaceRemainingSymbols));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      normalize,
      unitNormalization,
      urlNormalization,
      emailNormalization,
      optionalPluralizationNormalization,
      phoneNormalization,
      replaceRemainingSymbols);

  /// Create a copy of NormalizationOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NormalizationOptionsImplCopyWith<_$NormalizationOptionsImpl>
      get copyWith =>
          __$$NormalizationOptionsImplCopyWithImpl<_$NormalizationOptionsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NormalizationOptionsImplToJson(
      this,
    );
  }
}

abstract class _NormalizationOptions implements NormalizationOptions {
  const factory _NormalizationOptions(
      {final bool normalize,
      final bool unitNormalization,
      final bool urlNormalization,
      final bool emailNormalization,
      final bool optionalPluralizationNormalization,
      final bool phoneNormalization,
      final bool replaceRemainingSymbols}) = _$NormalizationOptionsImpl;

  factory _NormalizationOptions.fromJson(Map<String, dynamic> json) =
      _$NormalizationOptionsImpl.fromJson;

  /// Normalizes input text to make it easier for the model to say
  @override
  bool get normalize;

  /// Transforms units like 10KB to 10 kilobytes
  @override
  bool get unitNormalization;

  /// Changes urls so they can be properly pronounced by kokoro
  @override
  bool get urlNormalization;

  /// Changes emails so they can be properly pronounced by kokoro
  @override
  bool get emailNormalization;

  /// Replaces (s) with s so some words get pronounced correctly
  @override
  bool get optionalPluralizationNormalization;

  /// Changes phone numbers so they can be properly pronounced by kokoro
  @override
  bool get phoneNormalization;

  /// Replaces the remaining symbols after normalization with their words
  @override
  bool get replaceRemainingSymbols;

  /// Create a copy of NormalizationOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NormalizationOptionsImplCopyWith<_$NormalizationOptionsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PhonemeResult _$PhonemeResultFromJson(Map<String, dynamic> json) {
  return _PhonemeResult.fromJson(json);
}

/// @nodoc
mixin _$PhonemeResult {
  String get phonemes => throw _privateConstructorUsedError;
  List<int> get tokens => throw _privateConstructorUsedError;

  /// Serializes this PhonemeResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhonemeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhonemeResultCopyWith<PhonemeResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhonemeResultCopyWith<$Res> {
  factory $PhonemeResultCopyWith(
          PhonemeResult value, $Res Function(PhonemeResult) then) =
      _$PhonemeResultCopyWithImpl<$Res, PhonemeResult>;
  @useResult
  $Res call({String phonemes, List<int> tokens});
}

/// @nodoc
class _$PhonemeResultCopyWithImpl<$Res, $Val extends PhonemeResult>
    implements $PhonemeResultCopyWith<$Res> {
  _$PhonemeResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhonemeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phonemes = null,
    Object? tokens = null,
  }) {
    return _then(_value.copyWith(
      phonemes: null == phonemes
          ? _value.phonemes
          : phonemes // ignore: cast_nullable_to_non_nullable
              as String,
      tokens: null == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhonemeResultImplCopyWith<$Res>
    implements $PhonemeResultCopyWith<$Res> {
  factory _$$PhonemeResultImplCopyWith(
          _$PhonemeResultImpl value, $Res Function(_$PhonemeResultImpl) then) =
      __$$PhonemeResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String phonemes, List<int> tokens});
}

/// @nodoc
class __$$PhonemeResultImplCopyWithImpl<$Res>
    extends _$PhonemeResultCopyWithImpl<$Res, _$PhonemeResultImpl>
    implements _$$PhonemeResultImplCopyWith<$Res> {
  __$$PhonemeResultImplCopyWithImpl(
      _$PhonemeResultImpl _value, $Res Function(_$PhonemeResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of PhonemeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phonemes = null,
    Object? tokens = null,
  }) {
    return _then(_$PhonemeResultImpl(
      phonemes: null == phonemes
          ? _value.phonemes
          : phonemes // ignore: cast_nullable_to_non_nullable
              as String,
      tokens: null == tokens
          ? _value._tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhonemeResultImpl implements _PhonemeResult {
  const _$PhonemeResultImpl(
      {required this.phonemes, required final List<int> tokens})
      : _tokens = tokens;

  factory _$PhonemeResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhonemeResultImplFromJson(json);

  @override
  final String phonemes;
  final List<int> _tokens;
  @override
  List<int> get tokens {
    if (_tokens is EqualUnmodifiableListView) return _tokens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tokens);
  }

  @override
  String toString() {
    return 'PhonemeResult(phonemes: $phonemes, tokens: $tokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhonemeResultImpl &&
            (identical(other.phonemes, phonemes) ||
                other.phonemes == phonemes) &&
            const DeepCollectionEquality().equals(other._tokens, _tokens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, phonemes, const DeepCollectionEquality().hash(_tokens));

  /// Create a copy of PhonemeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhonemeResultImplCopyWith<_$PhonemeResultImpl> get copyWith =>
      __$$PhonemeResultImplCopyWithImpl<_$PhonemeResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhonemeResultImplToJson(
      this,
    );
  }
}

abstract class _PhonemeResult implements PhonemeResult {
  const factory _PhonemeResult(
      {required final String phonemes,
      required final List<int> tokens}) = _$PhonemeResultImpl;

  factory _PhonemeResult.fromJson(Map<String, dynamic> json) =
      _$PhonemeResultImpl.fromJson;

  @override
  String get phonemes;
  @override
  List<int> get tokens;

  /// Create a copy of PhonemeResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhonemeResultImplCopyWith<_$PhonemeResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TtsResponse _$TtsResponseFromJson(Map<String, dynamic> json) {
  return _TtsResponse.fromJson(json);
}

/// @nodoc
mixin _$TtsResponse {
  String? get audioUrl => throw _privateConstructorUsedError;
  List<SpeechMark> get speechMarks => throw _privateConstructorUsedError;

  /// Serializes this TtsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TtsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TtsResponseCopyWith<TtsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TtsResponseCopyWith<$Res> {
  factory $TtsResponseCopyWith(
          TtsResponse value, $Res Function(TtsResponse) then) =
      _$TtsResponseCopyWithImpl<$Res, TtsResponse>;
  @useResult
  $Res call({String? audioUrl, List<SpeechMark> speechMarks});
}

/// @nodoc
class _$TtsResponseCopyWithImpl<$Res, $Val extends TtsResponse>
    implements $TtsResponseCopyWith<$Res> {
  _$TtsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TtsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audioUrl = freezed,
    Object? speechMarks = null,
  }) {
    return _then(_value.copyWith(
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      speechMarks: null == speechMarks
          ? _value.speechMarks
          : speechMarks // ignore: cast_nullable_to_non_nullable
              as List<SpeechMark>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TtsResponseImplCopyWith<$Res>
    implements $TtsResponseCopyWith<$Res> {
  factory _$$TtsResponseImplCopyWith(
          _$TtsResponseImpl value, $Res Function(_$TtsResponseImpl) then) =
      __$$TtsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? audioUrl, List<SpeechMark> speechMarks});
}

/// @nodoc
class __$$TtsResponseImplCopyWithImpl<$Res>
    extends _$TtsResponseCopyWithImpl<$Res, _$TtsResponseImpl>
    implements _$$TtsResponseImplCopyWith<$Res> {
  __$$TtsResponseImplCopyWithImpl(
      _$TtsResponseImpl _value, $Res Function(_$TtsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TtsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audioUrl = freezed,
    Object? speechMarks = null,
  }) {
    return _then(_$TtsResponseImpl(
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      speechMarks: null == speechMarks
          ? _value._speechMarks
          : speechMarks // ignore: cast_nullable_to_non_nullable
              as List<SpeechMark>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TtsResponseImpl implements _TtsResponse {
  const _$TtsResponseImpl(
      {required this.audioUrl, required final List<SpeechMark> speechMarks})
      : _speechMarks = speechMarks;

  factory _$TtsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TtsResponseImplFromJson(json);

  @override
  final String? audioUrl;
  final List<SpeechMark> _speechMarks;
  @override
  List<SpeechMark> get speechMarks {
    if (_speechMarks is EqualUnmodifiableListView) return _speechMarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_speechMarks);
  }

  @override
  String toString() {
    return 'TtsResponse(audioUrl: $audioUrl, speechMarks: $speechMarks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TtsResponseImpl &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            const DeepCollectionEquality()
                .equals(other._speechMarks, _speechMarks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, audioUrl, const DeepCollectionEquality().hash(_speechMarks));

  /// Create a copy of TtsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TtsResponseImplCopyWith<_$TtsResponseImpl> get copyWith =>
      __$$TtsResponseImplCopyWithImpl<_$TtsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TtsResponseImplToJson(
      this,
    );
  }
}

abstract class _TtsResponse implements TtsResponse {
  const factory _TtsResponse(
      {required final String? audioUrl,
      required final List<SpeechMark> speechMarks}) = _$TtsResponseImpl;

  factory _TtsResponse.fromJson(Map<String, dynamic> json) =
      _$TtsResponseImpl.fromJson;

  @override
  String? get audioUrl;
  @override
  List<SpeechMark> get speechMarks;

  /// Create a copy of TtsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TtsResponseImplCopyWith<_$TtsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SpeechMark _$SpeechMarkFromJson(Map<String, dynamic> json) {
  return _SpeechMark.fromJson(json);
}

/// @nodoc
mixin _$SpeechMark {
  double get time => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get start => throw _privateConstructorUsedError;
  int get end => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  int? get sentenceStart => throw _privateConstructorUsedError;
  int? get sentenceEnd => throw _privateConstructorUsedError;

  /// Serializes this SpeechMark to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpeechMark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpeechMarkCopyWith<SpeechMark> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpeechMarkCopyWith<$Res> {
  factory $SpeechMarkCopyWith(
          SpeechMark value, $Res Function(SpeechMark) then) =
      _$SpeechMarkCopyWithImpl<$Res, SpeechMark>;
  @useResult
  $Res call(
      {double time,
      String type,
      int start,
      int end,
      String value,
      int? sentenceStart,
      int? sentenceEnd});
}

/// @nodoc
class _$SpeechMarkCopyWithImpl<$Res, $Val extends SpeechMark>
    implements $SpeechMarkCopyWith<$Res> {
  _$SpeechMarkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpeechMark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? type = null,
    Object? start = null,
    Object? end = null,
    Object? value = null,
    Object? sentenceStart = freezed,
    Object? sentenceEnd = freezed,
  }) {
    return _then(_value.copyWith(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as int,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as int,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      sentenceStart: freezed == sentenceStart
          ? _value.sentenceStart
          : sentenceStart // ignore: cast_nullable_to_non_nullable
              as int?,
      sentenceEnd: freezed == sentenceEnd
          ? _value.sentenceEnd
          : sentenceEnd // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpeechMarkImplCopyWith<$Res>
    implements $SpeechMarkCopyWith<$Res> {
  factory _$$SpeechMarkImplCopyWith(
          _$SpeechMarkImpl value, $Res Function(_$SpeechMarkImpl) then) =
      __$$SpeechMarkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double time,
      String type,
      int start,
      int end,
      String value,
      int? sentenceStart,
      int? sentenceEnd});
}

/// @nodoc
class __$$SpeechMarkImplCopyWithImpl<$Res>
    extends _$SpeechMarkCopyWithImpl<$Res, _$SpeechMarkImpl>
    implements _$$SpeechMarkImplCopyWith<$Res> {
  __$$SpeechMarkImplCopyWithImpl(
      _$SpeechMarkImpl _value, $Res Function(_$SpeechMarkImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpeechMark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? type = null,
    Object? start = null,
    Object? end = null,
    Object? value = null,
    Object? sentenceStart = freezed,
    Object? sentenceEnd = freezed,
  }) {
    return _then(_$SpeechMarkImpl(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as int,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as int,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      sentenceStart: freezed == sentenceStart
          ? _value.sentenceStart
          : sentenceStart // ignore: cast_nullable_to_non_nullable
              as int?,
      sentenceEnd: freezed == sentenceEnd
          ? _value.sentenceEnd
          : sentenceEnd // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpeechMarkImpl implements _SpeechMark {
  const _$SpeechMarkImpl(
      {required this.time,
      required this.type,
      required this.start,
      required this.end,
      required this.value,
      this.sentenceStart,
      this.sentenceEnd});

  factory _$SpeechMarkImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpeechMarkImplFromJson(json);

  @override
  final double time;
  @override
  final String type;
  @override
  final int start;
  @override
  final int end;
  @override
  final String value;
  @override
  final int? sentenceStart;
  @override
  final int? sentenceEnd;

  @override
  String toString() {
    return 'SpeechMark(time: $time, type: $type, start: $start, end: $end, value: $value, sentenceStart: $sentenceStart, sentenceEnd: $sentenceEnd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeechMarkImpl &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.sentenceStart, sentenceStart) ||
                other.sentenceStart == sentenceStart) &&
            (identical(other.sentenceEnd, sentenceEnd) ||
                other.sentenceEnd == sentenceEnd));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, time, type, start, end, value, sentenceStart, sentenceEnd);

  /// Create a copy of SpeechMark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpeechMarkImplCopyWith<_$SpeechMarkImpl> get copyWith =>
      __$$SpeechMarkImplCopyWithImpl<_$SpeechMarkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpeechMarkImplToJson(
      this,
    );
  }
}

abstract class _SpeechMark implements SpeechMark {
  const factory _SpeechMark(
      {required final double time,
      required final String type,
      required final int start,
      required final int end,
      required final String value,
      final int? sentenceStart,
      final int? sentenceEnd}) = _$SpeechMarkImpl;

  factory _SpeechMark.fromJson(Map<String, dynamic> json) =
      _$SpeechMarkImpl.fromJson;

  @override
  double get time;
  @override
  String get type;
  @override
  int get start;
  @override
  int get end;
  @override
  String get value;
  @override
  int? get sentenceStart;
  @override
  int? get sentenceEnd;

  /// Create a copy of SpeechMark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpeechMarkImplCopyWith<_$SpeechMarkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
