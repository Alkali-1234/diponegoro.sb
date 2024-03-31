// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adegan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Adegan _$AdeganFromJson(Map<String, dynamic> json) {
  return _Person.fromJson(json);
}

/// @nodoc
mixin _$Adegan {
  String get title => throw _privateConstructorUsedError;
  set title(String value) => throw _privateConstructorUsedError;
  List<Sound> get sounds => throw _privateConstructorUsedError;
  set sounds(List<Sound> value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AdeganCopyWith<Adegan> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdeganCopyWith<$Res> {
  factory $AdeganCopyWith(Adegan value, $Res Function(Adegan) then) =
      _$AdeganCopyWithImpl<$Res, Adegan>;
  @useResult
  $Res call({String title, List<Sound> sounds});
}

/// @nodoc
class _$AdeganCopyWithImpl<$Res, $Val extends Adegan>
    implements $AdeganCopyWith<$Res> {
  _$AdeganCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? sounds = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sounds: null == sounds
          ? _value.sounds
          : sounds // ignore: cast_nullable_to_non_nullable
              as List<Sound>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonImplCopyWith<$Res> implements $AdeganCopyWith<$Res> {
  factory _$$PersonImplCopyWith(
          _$PersonImpl value, $Res Function(_$PersonImpl) then) =
      __$$PersonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, List<Sound> sounds});
}

/// @nodoc
class __$$PersonImplCopyWithImpl<$Res>
    extends _$AdeganCopyWithImpl<$Res, _$PersonImpl>
    implements _$$PersonImplCopyWith<$Res> {
  __$$PersonImplCopyWithImpl(
      _$PersonImpl _value, $Res Function(_$PersonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? sounds = null,
  }) {
    return _then(_$PersonImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      sounds: null == sounds
          ? _value.sounds
          : sounds // ignore: cast_nullable_to_non_nullable
              as List<Sound>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonImpl with DiagnosticableTreeMixin implements _Person {
  _$PersonImpl({required this.title, required this.sounds});

  factory _$PersonImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonImplFromJson(json);

  @override
  String title;
  @override
  List<Sound> sounds;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Adegan(title: $title, sounds: $sounds)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Adegan'))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('sounds', sounds));
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      __$$PersonImplCopyWithImpl<_$PersonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonImplToJson(
      this,
    );
  }
}

abstract class _Person implements Adegan {
  factory _Person({required String title, required List<Sound> sounds}) =
      _$PersonImpl;

  factory _Person.fromJson(Map<String, dynamic> json) = _$PersonImpl.fromJson;

  @override
  String get title;
  set title(String value);
  @override
  List<Sound> get sounds;
  set sounds(List<Sound> value);
  @override
  @JsonKey(ignore: true)
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
