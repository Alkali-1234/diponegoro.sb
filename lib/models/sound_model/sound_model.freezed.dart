// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sound_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Sound _$SoundFromJson(Map<String, dynamic> json) {
  return _Sound.fromJson(json);
}

/// @nodoc
mixin _$Sound {
  String get title => throw _privateConstructorUsedError;
  set title(String value) => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  set path(String value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SoundCopyWith<Sound> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SoundCopyWith<$Res> {
  factory $SoundCopyWith(Sound value, $Res Function(Sound) then) =
      _$SoundCopyWithImpl<$Res, Sound>;
  @useResult
  $Res call({String title, String path});
}

/// @nodoc
class _$SoundCopyWithImpl<$Res, $Val extends Sound>
    implements $SoundCopyWith<$Res> {
  _$SoundCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? path = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SoundImplCopyWith<$Res> implements $SoundCopyWith<$Res> {
  factory _$$SoundImplCopyWith(
          _$SoundImpl value, $Res Function(_$SoundImpl) then) =
      __$$SoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String path});
}

/// @nodoc
class __$$SoundImplCopyWithImpl<$Res>
    extends _$SoundCopyWithImpl<$Res, _$SoundImpl>
    implements _$$SoundImplCopyWith<$Res> {
  __$$SoundImplCopyWithImpl(
      _$SoundImpl _value, $Res Function(_$SoundImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? path = null,
  }) {
    return _then(_$SoundImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SoundImpl with DiagnosticableTreeMixin implements _Sound {
  _$SoundImpl({required this.title, required this.path});

  factory _$SoundImpl.fromJson(Map<String, dynamic> json) =>
      _$$SoundImplFromJson(json);

  @override
  String title;
  @override
  String path;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Sound(title: $title, path: $path)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Sound'))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('path', path));
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SoundImplCopyWith<_$SoundImpl> get copyWith =>
      __$$SoundImplCopyWithImpl<_$SoundImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SoundImplToJson(
      this,
    );
  }
}

abstract class _Sound implements Sound {
  factory _Sound({required String title, required String path}) = _$SoundImpl;

  factory _Sound.fromJson(Map<String, dynamic> json) = _$SoundImpl.fromJson;

  @override
  String get title;
  set title(String value);
  @override
  String get path;
  set path(String value);
  @override
  @JsonKey(ignore: true)
  _$$SoundImplCopyWith<_$SoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
