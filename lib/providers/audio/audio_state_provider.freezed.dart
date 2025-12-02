// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_state_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AudioStateData {
  bool get isPlaying => throw _privateConstructorUsedError;
  double get volume => throw _privateConstructorUsedError;
  double get playbackSpeed => throw _privateConstructorUsedError;
  String get selectedVoice => throw _privateConstructorUsedError;

  /// Create a copy of AudioStateData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioStateDataCopyWith<AudioStateData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioStateDataCopyWith<$Res> {
  factory $AudioStateDataCopyWith(
          AudioStateData value, $Res Function(AudioStateData) then) =
      _$AudioStateDataCopyWithImpl<$Res, AudioStateData>;
  @useResult
  $Res call(
      {bool isPlaying,
      double volume,
      double playbackSpeed,
      String selectedVoice});
}

/// @nodoc
class _$AudioStateDataCopyWithImpl<$Res, $Val extends AudioStateData>
    implements $AudioStateDataCopyWith<$Res> {
  _$AudioStateDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioStateData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? volume = null,
    Object? playbackSpeed = null,
    Object? selectedVoice = null,
  }) {
    return _then(_value.copyWith(
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      playbackSpeed: null == playbackSpeed
          ? _value.playbackSpeed
          : playbackSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      selectedVoice: null == selectedVoice
          ? _value.selectedVoice
          : selectedVoice // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioStateDataImplCopyWith<$Res>
    implements $AudioStateDataCopyWith<$Res> {
  factory _$$AudioStateDataImplCopyWith(_$AudioStateDataImpl value,
          $Res Function(_$AudioStateDataImpl) then) =
      __$$AudioStateDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isPlaying,
      double volume,
      double playbackSpeed,
      String selectedVoice});
}

/// @nodoc
class __$$AudioStateDataImplCopyWithImpl<$Res>
    extends _$AudioStateDataCopyWithImpl<$Res, _$AudioStateDataImpl>
    implements _$$AudioStateDataImplCopyWith<$Res> {
  __$$AudioStateDataImplCopyWithImpl(
      _$AudioStateDataImpl _value, $Res Function(_$AudioStateDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of AudioStateData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? volume = null,
    Object? playbackSpeed = null,
    Object? selectedVoice = null,
  }) {
    return _then(_$AudioStateDataImpl(
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      playbackSpeed: null == playbackSpeed
          ? _value.playbackSpeed
          : playbackSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      selectedVoice: null == selectedVoice
          ? _value.selectedVoice
          : selectedVoice // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AudioStateDataImpl implements _AudioStateData {
  const _$AudioStateDataImpl(
      {this.isPlaying = false,
      this.volume = 1.0,
      this.playbackSpeed = 1.0,
      this.selectedVoice = 'af_bella'});

  @override
  @JsonKey()
  final bool isPlaying;
  @override
  @JsonKey()
  final double volume;
  @override
  @JsonKey()
  final double playbackSpeed;
  @override
  @JsonKey()
  final String selectedVoice;

  @override
  String toString() {
    return 'AudioStateData(isPlaying: $isPlaying, volume: $volume, playbackSpeed: $playbackSpeed, selectedVoice: $selectedVoice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioStateDataImpl &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.playbackSpeed, playbackSpeed) ||
                other.playbackSpeed == playbackSpeed) &&
            (identical(other.selectedVoice, selectedVoice) ||
                other.selectedVoice == selectedVoice));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isPlaying, volume, playbackSpeed, selectedVoice);

  /// Create a copy of AudioStateData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioStateDataImplCopyWith<_$AudioStateDataImpl> get copyWith =>
      __$$AudioStateDataImplCopyWithImpl<_$AudioStateDataImpl>(
          this, _$identity);
}

abstract class _AudioStateData implements AudioStateData {
  const factory _AudioStateData(
      {final bool isPlaying,
      final double volume,
      final double playbackSpeed,
      final String selectedVoice}) = _$AudioStateDataImpl;

  @override
  bool get isPlaying;
  @override
  double get volume;
  @override
  double get playbackSpeed;
  @override
  String get selectedVoice;

  /// Create a copy of AudioStateData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioStateDataImplCopyWith<_$AudioStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
