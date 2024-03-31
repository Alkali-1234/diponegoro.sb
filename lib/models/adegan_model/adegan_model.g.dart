// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adegan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PersonImpl _$$PersonImplFromJson(Map<String, dynamic> json) => _$PersonImpl(
      title: json['title'] as String,
      sounds: (json['sounds'] as List<dynamic>)
          .map((e) => Sound.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PersonImplToJson(_$PersonImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'sounds': instance.sounds,
    };
