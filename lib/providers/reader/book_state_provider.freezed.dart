// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_state_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BookState {
  ParsedBook? get currentBook => throw _privateConstructorUsedError;
  SavedBook? get savedBook => throw _privateConstructorUsedError;
  int get currentPageIndex => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;

  /// Create a copy of BookState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookStateCopyWith<BookState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookStateCopyWith<$Res> {
  factory $BookStateCopyWith(BookState value, $Res Function(BookState) then) =
      _$BookStateCopyWithImpl<$Res, BookState>;
  @useResult
  $Res call(
      {ParsedBook? currentBook,
      SavedBook? savedBook,
      int currentPageIndex,
      bool isLoading});
}

/// @nodoc
class _$BookStateCopyWithImpl<$Res, $Val extends BookState>
    implements $BookStateCopyWith<$Res> {
  _$BookStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentBook = freezed,
    Object? savedBook = freezed,
    Object? currentPageIndex = null,
    Object? isLoading = null,
  }) {
    return _then(_value.copyWith(
      currentBook: freezed == currentBook
          ? _value.currentBook
          : currentBook // ignore: cast_nullable_to_non_nullable
              as ParsedBook?,
      savedBook: freezed == savedBook
          ? _value.savedBook
          : savedBook // ignore: cast_nullable_to_non_nullable
              as SavedBook?,
      currentPageIndex: null == currentPageIndex
          ? _value.currentPageIndex
          : currentPageIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookStateImplCopyWith<$Res>
    implements $BookStateCopyWith<$Res> {
  factory _$$BookStateImplCopyWith(
          _$BookStateImpl value, $Res Function(_$BookStateImpl) then) =
      __$$BookStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ParsedBook? currentBook,
      SavedBook? savedBook,
      int currentPageIndex,
      bool isLoading});
}

/// @nodoc
class __$$BookStateImplCopyWithImpl<$Res>
    extends _$BookStateCopyWithImpl<$Res, _$BookStateImpl>
    implements _$$BookStateImplCopyWith<$Res> {
  __$$BookStateImplCopyWithImpl(
      _$BookStateImpl _value, $Res Function(_$BookStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentBook = freezed,
    Object? savedBook = freezed,
    Object? currentPageIndex = null,
    Object? isLoading = null,
  }) {
    return _then(_$BookStateImpl(
      currentBook: freezed == currentBook
          ? _value.currentBook
          : currentBook // ignore: cast_nullable_to_non_nullable
              as ParsedBook?,
      savedBook: freezed == savedBook
          ? _value.savedBook
          : savedBook // ignore: cast_nullable_to_non_nullable
              as SavedBook?,
      currentPageIndex: null == currentPageIndex
          ? _value.currentPageIndex
          : currentPageIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$BookStateImpl implements _BookState {
  const _$BookStateImpl(
      {this.currentBook,
      this.savedBook,
      this.currentPageIndex = 0,
      this.isLoading = false});

  @override
  final ParsedBook? currentBook;
  @override
  final SavedBook? savedBook;
  @override
  @JsonKey()
  final int currentPageIndex;
  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'BookState(currentBook: $currentBook, savedBook: $savedBook, currentPageIndex: $currentPageIndex, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookStateImpl &&
            (identical(other.currentBook, currentBook) ||
                other.currentBook == currentBook) &&
            (identical(other.savedBook, savedBook) ||
                other.savedBook == savedBook) &&
            (identical(other.currentPageIndex, currentPageIndex) ||
                other.currentPageIndex == currentPageIndex) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, currentBook, savedBook, currentPageIndex, isLoading);

  /// Create a copy of BookState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookStateImplCopyWith<_$BookStateImpl> get copyWith =>
      __$$BookStateImplCopyWithImpl<_$BookStateImpl>(this, _$identity);
}

abstract class _BookState implements BookState {
  const factory _BookState(
      {final ParsedBook? currentBook,
      final SavedBook? savedBook,
      final int currentPageIndex,
      final bool isLoading}) = _$BookStateImpl;

  @override
  ParsedBook? get currentBook;
  @override
  SavedBook? get savedBook;
  @override
  int get currentPageIndex;
  @override
  bool get isLoading;

  /// Create a copy of BookState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookStateImplCopyWith<_$BookStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
