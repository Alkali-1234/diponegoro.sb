import 'package:diponegoro_sb/logger.dart';

import 'components/home.dart';
import 'package:flutter/material.dart';

class TogglePlaybackIntent extends Intent {
  const TogglePlaybackIntent();
}

class TogglePlaybackAction extends Action<TogglePlaybackIntent> {
  TogglePlaybackAction(this.playbackKey);

  final GlobalKey<AudioPlayerWidgetState> playbackKey;

  @override
  void invoke(covariant TogglePlaybackIntent intent) {
    playbackKey.currentState?.togglePlayback();
    logger.d("TogglePlaybackAction invoked");
  }
}

class IncreaseVolumeIntent extends Intent {
  const IncreaseVolumeIntent();
}

class IncreaseVolumeAction extends Action<IncreaseVolumeIntent> {
  IncreaseVolumeAction(this.playbackKey);

  final GlobalKey<AudioPlayerWidgetState> playbackKey;

  @override
  void invoke(covariant IncreaseVolumeIntent intent) {
    playbackKey.currentState?.adjustVolume(0.005);
    logger.d("IncreaseVolumeAction invoked");
  }
}

class DecreaseVolumeIntent extends Intent {
  const DecreaseVolumeIntent();
}

class DecreaseVolumeAction extends Action<DecreaseVolumeIntent> {
  DecreaseVolumeAction(this.playbackKey);

  final GlobalKey<AudioPlayerWidgetState> playbackKey;

  @override
  void invoke(covariant DecreaseVolumeIntent intent) {
    playbackKey.currentState?.adjustVolume(-0.005);
    logger.d("DecreaseVolumeAction invoked");
  }
}
