// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reader_settings_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReaderSettings {
  ReaderTypeface get typeface => throw _privateConstructorUsedError;
  double get fontScale => throw _privateConstructorUsedError;
  double get lineHeightScale => throw _privateConstructorUsedError;
  bool get useJustifyAlignment => throw _privateConstructorUsedError;
  bool get immersiveMode => throw _privateConstructorUsedError;

  /// Create a copy of ReaderSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReaderSettingsCopyWith<ReaderSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReaderSettingsCopyWith<$Res> {
  factory $ReaderSettingsCopyWith(
          ReaderSettings value, $Res Function(ReaderSettings) then) =
      _$ReaderSettingsCopyWithImpl<$Res, ReaderSettings>;
  @useResult
  $Res call(
      {ReaderTypeface typeface,
      double fontScale,
      double lineHeightScale,
      bool useJustifyAlignment,
      bool immersiveMode});
}

/// @nodoc
class _$ReaderSettingsCopyWithImpl<$Res, $Val extends ReaderSettings>
    implements $ReaderSettingsCopyWith<$Res> {
  _$ReaderSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReaderSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? typeface = null,
    Object? fontScale = null,
    Object? lineHeightScale = null,
    Object? useJustifyAlignment = null,
    Object? immersiveMode = null,
  }) {
    return _then(_value.copyWith(
      typeface: null == typeface
          ? _value.typeface
          : typeface // ignore: cast_nullable_to_non_nullable
              as ReaderTypeface,
      fontScale: null == fontScale
          ? _value.fontScale
          : fontScale // ignore: cast_nullable_to_non_nullable
              as double,
      lineHeightScale: null == lineHeightScale
          ? _value.lineHeightScale
          : lineHeightScale // ignore: cast_nullable_to_non_nullable
              as double,
      useJustifyAlignment: null == useJustifyAlignment
          ? _value.useJustifyAlignment
          : useJustifyAlignment // ignore: cast_nullable_to_non_nullable
              as bool,
      immersiveMode: null == immersiveMode
          ? _value.immersiveMode
          : immersiveMode // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReaderSettingsImplCopyWith<$Res>
    implements $ReaderSettingsCopyWith<$Res> {
  factory _$$ReaderSettingsImplCopyWith(_$ReaderSettingsImpl value,
          $Res Function(_$ReaderSettingsImpl) then) =
      __$$ReaderSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ReaderTypeface typeface,
      double fontScale,
      double lineHeightScale,
      bool useJustifyAlignment,
      bool immersiveMode});
}

/// @nodoc
class __$$ReaderSettingsImplCopyWithImpl<$Res>
    extends _$ReaderSettingsCopyWithImpl<$Res, _$ReaderSettingsImpl>
    implements _$$ReaderSettingsImplCopyWith<$Res> {
  __$$ReaderSettingsImplCopyWithImpl(
      _$ReaderSettingsImpl _value, $Res Function(_$ReaderSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReaderSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? typeface = null,
    Object? fontScale = null,
    Object? lineHeightScale = null,
    Object? useJustifyAlignment = null,
    Object? immersiveMode = null,
  }) {
    return _then(_$ReaderSettingsImpl(
      typeface: null == typeface
          ? _value.typeface
          : typeface // ignore: cast_nullable_to_non_nullable
              as ReaderTypeface,
      fontScale: null == fontScale
          ? _value.fontScale
          : fontScale // ignore: cast_nullable_to_non_nullable
              as double,
      lineHeightScale: null == lineHeightScale
          ? _value.lineHeightScale
          : lineHeightScale // ignore: cast_nullable_to_non_nullable
              as double,
      useJustifyAlignment: null == useJustifyAlignment
          ? _value.useJustifyAlignment
          : useJustifyAlignment // ignore: cast_nullable_to_non_nullable
              as bool,
      immersiveMode: null == immersiveMode
          ? _value.immersiveMode
          : immersiveMode // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ReaderSettingsImpl implements _ReaderSettings {
  const _$ReaderSettingsImpl(
      {this.typeface = ReaderTypeface.serif,
      this.fontScale = 1.0,
      this.lineHeightScale = 1.0,
      this.useJustifyAlignment = true,
      this.immersiveMode = false});

  @override
  @JsonKey()
  final ReaderTypeface typeface;
  @override
  @JsonKey()
  final double fontScale;
  @override
  @JsonKey()
  final double lineHeightScale;
  @override
  @JsonKey()
  final bool useJustifyAlignment;
  @override
  @JsonKey()
  final bool immersiveMode;

  @override
  String toString() {
    return 'ReaderSettings(typeface: $typeface, fontScale: $fontScale, lineHeightScale: $lineHeightScale, useJustifyAlignment: $useJustifyAlignment, immersiveMode: $immersiveMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReaderSettingsImpl &&
            (identical(other.typeface, typeface) ||
                other.typeface == typeface) &&
            (identical(other.fontScale, fontScale) ||
                other.fontScale == fontScale) &&
            (identical(other.lineHeightScale, lineHeightScale) ||
                other.lineHeightScale == lineHeightScale) &&
            (identical(other.useJustifyAlignment, useJustifyAlignment) ||
                other.useJustifyAlignment == useJustifyAlignment) &&
            (identical(other.immersiveMode, immersiveMode) ||
                other.immersiveMode == immersiveMode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, typeface, fontScale,
      lineHeightScale, useJustifyAlignment, immersiveMode);

  /// Create a copy of ReaderSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReaderSettingsImplCopyWith<_$ReaderSettingsImpl> get copyWith =>
      __$$ReaderSettingsImplCopyWithImpl<_$ReaderSettingsImpl>(
          this, _$identity);
}

abstract class _ReaderSettings implements ReaderSettings {
  const factory _ReaderSettings(
      {final ReaderTypeface typeface,
      final double fontScale,
      final double lineHeightScale,
      final bool useJustifyAlignment,
      final bool immersiveMode}) = _$ReaderSettingsImpl;

  @override
  ReaderTypeface get typeface;
  @override
  double get fontScale;
  @override
  double get lineHeightScale;
  @override
  bool get useJustifyAlignment;
  @override
  bool get immersiveMode;

  /// Create a copy of ReaderSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReaderSettingsImplCopyWith<_$ReaderSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
