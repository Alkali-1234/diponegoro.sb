import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'sound_model.freezed.dart';
// optional: Since our Person class is serializable, we must add this line.
// But if Person was not serializable, we could skip it.
part 'sound_model.g.dart';

@unfreezed
class Sound with _$Sound {
  factory Sound({
    required String title,
    required String path,
    int? startingSeconds,
    double? startingVolume,
  }) = _Sound;

  factory Sound.fromJson(Map<String, Object?> json) => _$SoundFromJson(json);
}
