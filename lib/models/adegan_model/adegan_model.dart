// This file is "main.dart"
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import '../sound_model/sound_model.dart';

part 'adegan_model.freezed.dart';
// optional: Since our Person class is serializable, we must add this line.
// But if Person was not serializable, we could skip it.
part 'adegan_model.g.dart';

@unfreezed
class Adegan with _$Adegan {
  factory Adegan({
    required String title,
    required List<Sound> sounds,
  }) = _Person;

  factory Adegan.fromJson(Map<String, Object?> json) => _$AdeganFromJson(json);
}
