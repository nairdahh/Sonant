// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'highlight_state_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HighlightData {
  int get currentPageIndex => throw _privateConstructorUsedError;
  int get currentWordIndex => throw _privateConstructorUsedError;
  List<WordHighlight> get wordHighlights => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Create a copy of HighlightData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HighlightDataCopyWith<HighlightData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HighlightDataCopyWith<$Res> {
  factory $HighlightDataCopyWith(
          HighlightData value, $Res Function(HighlightData) then) =
      _$HighlightDataCopyWithImpl<$Res, HighlightData>;
  @useResult
  $Res call(
      {int currentPageIndex,
      int currentWordIndex,
      List<WordHighlight> wordHighlights,
      bool isActive});
}

/// @nodoc
class _$HighlightDataCopyWithImpl<$Res, $Val extends HighlightData>
    implements $HighlightDataCopyWith<$Res> {
  _$HighlightDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HighlightData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPageIndex = null,
    Object? currentWordIndex = null,
    Object? wordHighlights = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      currentPageIndex: null == currentPageIndex
          ? _value.currentPageIndex
          : currentPageIndex // ignore: cast_nullable_to_non_nullable
              as int,
      currentWordIndex: null == currentWordIndex
          ? _value.currentWordIndex
          : currentWordIndex // ignore: cast_nullable_to_non_nullable
              as int,
      wordHighlights: null == wordHighlights
          ? _value.wordHighlights
          : wordHighlights // ignore: cast_nullable_to_non_nullable
              as List<WordHighlight>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HighlightDataImplCopyWith<$Res>
    implements $HighlightDataCopyWith<$Res> {
  factory _$$HighlightDataImplCopyWith(
          _$HighlightDataImpl value, $Res Function(_$HighlightDataImpl) then) =
      __$$HighlightDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentPageIndex,
      int currentWordIndex,
      List<WordHighlight> wordHighlights,
      bool isActive});
}

/// @nodoc
class __$$HighlightDataImplCopyWithImpl<$Res>
    extends _$HighlightDataCopyWithImpl<$Res, _$HighlightDataImpl>
    implements _$$HighlightDataImplCopyWith<$Res> {
  __$$HighlightDataImplCopyWithImpl(
      _$HighlightDataImpl _value, $Res Function(_$HighlightDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of HighlightData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPageIndex = null,
    Object? currentWordIndex = null,
    Object? wordHighlights = null,
    Object? isActive = null,
  }) {
    return _then(_$HighlightDataImpl(
      currentPageIndex: null == currentPageIndex
          ? _value.currentPageIndex
          : currentPageIndex // ignore: cast_nullable_to_non_nullable
              as int,
      currentWordIndex: null == currentWordIndex
          ? _value.currentWordIndex
          : currentWordIndex // ignore: cast_nullable_to_non_nullable
              as int,
      wordHighlights: null == wordHighlights
          ? _value._wordHighlights
          : wordHighlights // ignore: cast_nullable_to_non_nullable
              as List<WordHighlight>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$HighlightDataImpl implements _HighlightData {
  const _$HighlightDataImpl(
      {this.currentPageIndex = -1,
      this.currentWordIndex = -1,
      final List<WordHighlight> wordHighlights = const [],
      this.isActive = false})
      : _wordHighlights = wordHighlights;

  @override
  @JsonKey()
  final int currentPageIndex;
  @override
  @JsonKey()
  final int currentWordIndex;
  final List<WordHighlight> _wordHighlights;
  @override
  @JsonKey()
  List<WordHighlight> get wordHighlights {
    if (_wordHighlights is EqualUnmodifiableListView) return _wordHighlights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wordHighlights);
  }

  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'HighlightData(currentPageIndex: $currentPageIndex, currentWordIndex: $currentWordIndex, wordHighlights: $wordHighlights, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HighlightDataImpl &&
            (identical(other.currentPageIndex, currentPageIndex) ||
                other.currentPageIndex == currentPageIndex) &&
            (identical(other.currentWordIndex, currentWordIndex) ||
                other.currentWordIndex == currentWordIndex) &&
            const DeepCollectionEquality()
                .equals(other._wordHighlights, _wordHighlights) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentPageIndex,
      currentWordIndex,
      const DeepCollectionEquality().hash(_wordHighlights),
      isActive);

  /// Create a copy of HighlightData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HighlightDataImplCopyWith<_$HighlightDataImpl> get copyWith =>
      __$$HighlightDataImplCopyWithImpl<_$HighlightDataImpl>(this, _$identity);
}

abstract class _HighlightData implements HighlightData {
  const factory _HighlightData(
      {final int currentPageIndex,
      final int currentWordIndex,
      final List<WordHighlight> wordHighlights,
      final bool isActive}) = _$HighlightDataImpl;

  @override
  int get currentPageIndex;
  @override
  int get currentWordIndex;
  @override
  List<WordHighlight> get wordHighlights;
  @override
  bool get isActive;

  /// Create a copy of HighlightData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HighlightDataImplCopyWith<_$HighlightDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
