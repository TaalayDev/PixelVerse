// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'background_image_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BackgroundImageState {
  Uint8List? get image => throw _privateConstructorUsedError;
  double get opacity => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BackgroundImageStateCopyWith<BackgroundImageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackgroundImageStateCopyWith<$Res> {
  factory $BackgroundImageStateCopyWith(BackgroundImageState value,
          $Res Function(BackgroundImageState) then) =
      _$BackgroundImageStateCopyWithImpl<$Res, BackgroundImageState>;
  @useResult
  $Res call({Uint8List? image, double opacity});
}

/// @nodoc
class _$BackgroundImageStateCopyWithImpl<$Res,
        $Val extends BackgroundImageState>
    implements $BackgroundImageStateCopyWith<$Res> {
  _$BackgroundImageStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = freezed,
    Object? opacity = null,
  }) {
    return _then(_value.copyWith(
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
      opacity: null == opacity
          ? _value.opacity
          : opacity // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BackgroundImageStateImplCopyWith<$Res>
    implements $BackgroundImageStateCopyWith<$Res> {
  factory _$$BackgroundImageStateImplCopyWith(_$BackgroundImageStateImpl value,
          $Res Function(_$BackgroundImageStateImpl) then) =
      __$$BackgroundImageStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Uint8List? image, double opacity});
}

/// @nodoc
class __$$BackgroundImageStateImplCopyWithImpl<$Res>
    extends _$BackgroundImageStateCopyWithImpl<$Res, _$BackgroundImageStateImpl>
    implements _$$BackgroundImageStateImplCopyWith<$Res> {
  __$$BackgroundImageStateImplCopyWithImpl(_$BackgroundImageStateImpl _value,
      $Res Function(_$BackgroundImageStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = freezed,
    Object? opacity = null,
  }) {
    return _then(_$BackgroundImageStateImpl(
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
      opacity: null == opacity
          ? _value.opacity
          : opacity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$BackgroundImageStateImpl extends _BackgroundImageState {
  const _$BackgroundImageStateImpl({this.image, this.opacity = 0.3})
      : super._();

  @override
  final Uint8List? image;
  @override
  @JsonKey()
  final double opacity;

  @override
  String toString() {
    return 'BackgroundImageState(image: $image, opacity: $opacity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackgroundImageStateImpl &&
            const DeepCollectionEquality().equals(other.image, image) &&
            (identical(other.opacity, opacity) || other.opacity == opacity));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(image), opacity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BackgroundImageStateImplCopyWith<_$BackgroundImageStateImpl>
      get copyWith =>
          __$$BackgroundImageStateImplCopyWithImpl<_$BackgroundImageStateImpl>(
              this, _$identity);
}

abstract class _BackgroundImageState extends BackgroundImageState {
  const factory _BackgroundImageState(
      {final Uint8List? image,
      final double opacity}) = _$BackgroundImageStateImpl;
  const _BackgroundImageState._() : super._();

  @override
  Uint8List? get image;
  @override
  double get opacity;
  @override
  @JsonKey(ignore: true)
  _$$BackgroundImageStateImplCopyWith<_$BackgroundImageStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
