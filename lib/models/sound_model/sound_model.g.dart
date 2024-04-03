// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SoundImpl _$$SoundImplFromJson(Map<String, dynamic> json) => _$SoundImpl(
      title: json['title'] as String,
      path: json['path'] as String,
      startingSeconds: json['startingSeconds'] as int?,
      startingVolume: (json['startingVolume'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$SoundImplToJson(_$SoundImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'path': instance.path,
      'startingSeconds': instance.startingSeconds,
      'startingVolume': instance.startingVolume,
    };
