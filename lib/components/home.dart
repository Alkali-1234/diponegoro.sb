import 'dart:convert';
import 'dart:io';
import 'package:diponegoro_sb/actions.dart';
import 'package:diponegoro_sb/components/info_dialog.dart';
import 'package:diponegoro_sb/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import '../models/adegan_model/adegan_model.dart';
import '../models/sound_model/sound_model.dart';

class AdeganFunctions {
  static getAdeganListFromJson(json) {
    List<Adegan> adeganList = [];
    for (var adegan in json) {
      adeganList.add(Adegan.fromJson(jsonDecode(adegan)));
    }
    return adeganList;
  }

  static exportAdeganListToJson(List<Adegan> adeganList) {
    List<String> adeganListJson = [
      for (var adegan in adeganList) jsonEncode(adegan.toJson())
    ];
    logger.d(jsonEncode(adeganListJson));
    return jsonEncode(adeganListJson);
  }

  static removeAdegan(int index, WidgetRef ref) async {
    final adeganList = ref.read(adeganListProvider);
    final adegan = adeganList[index];
    for (var sound in adegan.sounds) {
      if (File(sound.path).existsSync()) await File(sound.path).delete();
    }
    final adeganListNotifier = ref.read(adeganListProvider.notifier);
    adeganListNotifier.removeAdegan(adegan);
  }

  static deleteSound(int adeganIndex, int soundIndex, WidgetRef ref) async {
    final adeganList = ref.read(adeganListProvider);
    final adegan = adeganList[adeganIndex];
    final sound = adegan.sounds[soundIndex];
    if (File(sound.path).existsSync()) await File(sound.path).delete();
    final adeganListNotifier = ref.read(adeganListProvider.notifier);
    adeganListNotifier.updateAdegan(adegan.copyWith(sounds: adegan.sounds.where((element) => element != sound).toList()), adeganIndex);
  }
}

//* State

class AdeganList extends Notifier<List<Adegan>> {
  Future<void> initialize() async {
    if (ref.read(isInitializedProvider)) return;
    logger.i("Initializing AdeganList ${ref.read(isInitializedProvider)}");
    Directory appDocDir = await getApplicationDocumentsDirectory().then((value) => value);
    //* Create directories
    Directory adeganDir = Directory("${appDocDir.path}/adegan");
    if (!await adeganDir.exists()) {
      logger.i("Creating adegan directory");
      await adeganDir.create();
      //* Create example adegan
      Directory exampleAdegan = Directory("${adeganDir.path}/adegan1/");
      await exampleAdegan.create();
      File exampleAdeganFile = File("${exampleAdegan.path}/adegan1.mp3");
      await exampleAdeganFile.writeAsBytes([
        1,
        2,
        3,
        4,
        5
      ]);

      Adegan adegan = Adegan(
        title: "Adegan 1",
        sounds: [],
      );
      adegan.sounds.add(Sound(
        title: "Adegan 1",
        path: exampleAdeganFile.path,
      ));
      addAdegan(adegan);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("adeganList")) {
      List<Adegan> adeganList = AdeganFunctions.getAdeganListFromJson(jsonDecode(prefs.getString("adeganList")!));
      state = adeganList;
    }

    if (!prefs.containsKey("adeganList")) {
      List<Adegan> adeganList = [
        Adegan(
          title: "Adegan 1",
          sounds: [
            Sound(
              title: "Adegan 1",
              path: "${adeganDir.path}/adegan1/adegan1.mp3",
            ),
          ],
        ),
      ];
      state = adeganList;
      prefs.setString("adeganList", AdeganFunctions.exportAdeganListToJson(adeganList));
    }
    ref.read(isInitializedProvider.notifier).state = true;
  }

  void addAdegan(Adegan adegan) {
    state = [
      ...state,
      adegan
    ];
  }

  void removeAdegan(Adegan adegan) {
    state = state.where((element) => element != adegan).toList();
  }

  void updateAdegan(Adegan adegan, int index) {
    state = state.map((e) => e == state[index] ? adegan : e).toList();
  }

  void reorderAdegan(int oldIndex, int newIndex) {
    List<Adegan> adeganList = state;
    Adegan adegan = adeganList.removeAt(oldIndex);
    if (newIndex != adeganList.length) {
      adeganList.insert(newIndex, adegan);
    } else {
      adeganList.add(adegan);
    }
    state = adeganList;
  }

  List<Adegan> get adeganList => state;

  @override
  List<Adegan> build() {
    return [];
  }
}

final adeganListProvider = NotifierProvider<AdeganList, List<Adegan>>(AdeganList.new);

final getAdeganList = Provider<List<Adegan>>((ref) {
  final adg = ref.watch(adeganListProvider);
  return adg;
});

final isInitializedProvider = StateProvider<bool>((ref) {
  return false;
});

final currentMouseHoveringProvider = StateProvider<int?>((ref) {
  return null;
});

final currentEditingAdeganTitleProvider = StateProvider<int?>((ref) {
  return null;
});

//* Keys for testing
final loadingKey = UniqueKey();
final homeKey = UniqueKey();
final infoButtonKey = UniqueKey();
final addAdeganButtonKey = UniqueKey();

class HomePage extends ConsumerWidget {
  HomePage({super.key, required this.title});

  final String title;

  //* AUDIO PLAYER KEY
  final GlobalKey<AudioPlayerWidgetState> audioPlayerKey = GlobalKey<AudioPlayerWidgetState>();

  final adeganTitleController = TextEditingController();

  final adeganListViewController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    final adeganList = ref.watch(adeganListProvider);
    final adeganListNotifier = ref.watch(adeganListProvider.notifier);
    final isInitialized = ref.watch(isInitializedProvider.notifier).state;
    final currentMouseHovering = ref.watch(currentMouseHoveringProvider);
    final currentEditingAdeganTitle = ref.watch(currentEditingAdeganTitleProvider);

    FocusNode focusNode = FocusNode();

    ref.listen<List<Adegan>>(adeganListProvider, (previous, adeganList) async {
      logger.i("Saving adegan list");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("adeganList", AdeganFunctions.exportAdeganListToJson(adeganList));
    });

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.space): const TogglePlaybackIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyW): const IncreaseVolumeIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyS): const DecreaseVolumeIntent(),
        //* Increase/Decrease Volume Large
        LogicalKeySet(LogicalKeyboardKey.keyM): const IncreaseVolumeLargeIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyN): const DecreaseVolumeLargeIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          TogglePlaybackIntent: TogglePlaybackAction(audioPlayerKey),
          IncreaseVolumeIntent: IncreaseVolumeAction(audioPlayerKey),
          DecreaseVolumeIntent: DecreaseVolumeAction(audioPlayerKey),
          //* Large
          IncreaseVolumeLargeIntent: IncreaseVolumeLargeAction(audioPlayerKey),
          DecreaseVolumeLargeIntent: DecreaseVolumeLargeAction(audioPlayerKey),
        },
        child: FocusScope(
          autofocus: true,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder(
                  future: !isInitialized ? adeganListNotifier.initialize() : null,
                  builder: (context, snapshot) {
                    return isInitialized
                        ? Column(
                            key: homeKey,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      image: DecorationImage(image: AssetImage("assets/d_sb_logo.png"), fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Text(
                                    "diponegoro.sb",
                                    style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                      key: infoButtonKey,
                                      onPressed: () {
                                        showDialog(context: context, builder: (context) => const InfoDialog());
                                      },
                                      icon: Icon(Icons.info, color: theme.colorScheme.onBackground))
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              Expanded(
                                child: ListView(
                                  controller: adeganListViewController,
                                  physics: const ClampingScrollPhysics(),
                                  children: [
                                    ReorderableListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      buildDefaultDragHandles: false,
                                      onReorder: (oldIndex, newIndex) {
                                        if (newIndex > adeganList.length) return;
                                        adeganListNotifier.reorderAdegan(oldIndex, newIndex > oldIndex ? newIndex - 1 : newIndex);
                                      },
                                      itemCount: adeganList.length,
                                      itemBuilder: (context, adeganIndex) {
                                        Adegan adegan = adeganList[adeganIndex];
                                        return Container(
                                          key: ValueKey("adegan${adeganIndex}_${adegan.title}"),
                                          margin: const EdgeInsets.only(top: 16.0),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.secondary,
                                            border: Border.all(color: theme.colorScheme.secondary),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  ReorderableDragStartListener(
                                                      index: adeganIndex,
                                                      child: MouseRegion(
                                                        cursor: SystemMouseCursors.grab,
                                                        child: Icon(
                                                          Icons.drag_indicator,
                                                          color: theme.colorScheme.onBackground,
                                                        ),
                                                      )),
                                                  const SizedBox(width: 8.0),
                                                  Expanded(
                                                      child: TapRegion(
                                                    onTapInside: (event) {
                                                      adeganTitleController.text = adegan.title;
                                                      ref.read(currentEditingAdeganTitleProvider.notifier).state = adeganIndex;
                                                      FocusScope.of(context).requestFocus(focusNode);
                                                    },
                                                    onTapOutside: (event) {
                                                      if (currentEditingAdeganTitle != adeganIndex) return;
                                                      ref.read(currentEditingAdeganTitleProvider.notifier).state = null;
                                                      adeganListNotifier.updateAdegan(adegan.copyWith(title: adeganTitleController.text), adeganIndex);
                                                    },
                                                    child: MouseRegion(
                                                        cursor: SystemMouseCursors.text,
                                                        onEnter: (event) => ref.read(currentMouseHoveringProvider.notifier).state = adeganIndex,
                                                        onExit: (event) => ref.read(currentMouseHoveringProvider.notifier).state = null,
                                                        child: currentEditingAdeganTitle != adeganIndex
                                                            ? AnimatedContainer(
                                                                duration: const Duration(milliseconds: 200),
                                                                padding: const EdgeInsets.all(8.0),
                                                                decoration: BoxDecoration(
                                                                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                                                  border: currentMouseHovering == adeganIndex ? Border.all(color: theme.colorScheme.secondary) : Border.all(color: Colors.transparent),
                                                                ),
                                                                child: Text(adegan.title, style: textTheme.displayMedium))
                                                            : TextField(
                                                                focusNode: focusNode,
                                                                controller: adeganTitleController,
                                                                cursorColor: theme.colorScheme.onBackground,
                                                                style: textTheme.displayMedium,
                                                                decoration: InputDecoration(
                                                                  labelText: "Title",
                                                                  labelStyle: textTheme.displayMedium,
                                                                  fillColor: theme.colorScheme.primary,
                                                                  filled: true,
                                                                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8.0)),
                                                                ),
                                                              )),
                                                  )),
                                                  const SizedBox(width: 8.0),
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    child: GestureDetector(
                                                      onTap: () => AdeganFunctions.removeAdegan(adeganIndex, ref),
                                                      child: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(height: 16.0),
                                              Container(
                                                padding: const EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary,
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: ListView.builder(
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: adegan.sounds.length + 1,
                                                  itemBuilder: (context, index) {
                                                    Sound sound = adegan.sounds.isEmpty || index == adegan.sounds.length ? Sound(title: "", path: "") : adegan.sounds[index];
                                                    return index == adegan.sounds.length || adegan.sounds.isEmpty
                                                        ? Semantics(
                                                            button: true,
                                                            label: "Add sound",
                                                            child: IconButton(
                                                                onPressed: () {
                                                                  adeganListNotifier.updateAdegan(
                                                                      adegan.copyWith(sounds: [
                                                                        ...adegan.sounds,
                                                                        Sound(title: "Sound ${index + 1}", path: "")
                                                                      ]),
                                                                      adeganIndex);
                                                                },
                                                                icon: Icon(
                                                                  Icons.add,
                                                                  color: theme.colorScheme.onBackground,
                                                                )),
                                                          )
                                                        : Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                            child: ListTile(
                                                              hoverColor: theme.colorScheme.primaryContainer,
                                                              onTap: () => showDialog(
                                                                context: context,
                                                                builder: (context) => SoundSettingsDialog(
                                                                  sound: sound,
                                                                  adeganIndex: adeganIndex,
                                                                  soundIndex: index,
                                                                ),
                                                              ),
                                                              leading: Icon(Icons.music_note, color: theme.colorScheme.onBackground),
                                                              title: Text(sound.title, style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                                                              trailing: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  IconButton(onPressed: () => AdeganFunctions.deleteSound(adeganIndex, index, ref), icon: const Icon(Icons.delete, color: Colors.red)),
                                                                  const SizedBox(width: 8.0),
                                                                  IconButton(
                                                                    onPressed: () async {
                                                                      if (sound.path.isEmpty) {
                                                                        showDialog(
                                                                            context: context,
                                                                            builder: (context) => AlertDialog(
                                                                                    title: Text(
                                                                                      "Error",
                                                                                      style: textTheme.displayMedium,
                                                                                    ),
                                                                                    content: Text("Sound path is empty", style: textTheme.displaySmall),
                                                                                    actions: [
                                                                                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK", style: textTheme.displaySmall))
                                                                                    ]));
                                                                        return;
                                                                      }
                                                                      await audioPlayerKey.currentState!.setAsset(sound.path);
                                                                      audioPlayerKey.currentState!.fadeIn(sound.startingSeconds ?? 0, sound.startingVolume ?? 1.0);
                                                                    },
                                                                    icon: const Icon(Icons.north_east, color: Colors.blue),
                                                                  ),
                                                                  const SizedBox(width: 8.0),
                                                                  IconButton(
                                                                    onPressed: () async {
                                                                      if (sound.path.isEmpty) {
                                                                        showDialog(
                                                                            context: context,
                                                                            builder: (context) => AlertDialog(
                                                                                    title: Text(
                                                                                      "Error",
                                                                                      style: textTheme.displayMedium,
                                                                                    ),
                                                                                    content: Text("Sound path is empty", style: textTheme.displaySmall),
                                                                                    actions: [
                                                                                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK", style: textTheme.displaySmall))
                                                                                    ]));
                                                                        return;
                                                                      }
                                                                      await audioPlayerKey.currentState!.setAsset(sound.path);
                                                                      audioPlayerKey.currentState!.play(sound.startingSeconds ?? 0, sound.startingVolume ?? 1.0);
                                                                    },
                                                                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                                                                  ),
                                                                ],
                                                              ),
                                                            ));
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    //* Add adegan
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: IconButton(
                                          key: addAdeganButtonKey,
                                          onPressed: () {
                                            adeganListNotifier.addAdegan(Adegan(title: "Adegan ${adeganList.length + 1}", sounds: []));
                                          },
                                          icon: Icon(
                                            Icons.add_rounded,
                                            color: theme.colorScheme.onBackground,
                                            size: 48,
                                          )),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              AudioPlayerWidget(key: audioPlayerKey),
                            ],
                          )
                        : Center(
                            child: CircularProgressIndicator(
                              key: loadingKey,
                              color: theme.colorScheme.onBackground,
                            ),
                          );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}

//* Sound Settings State
final selectedFilePathProvider = StateProvider<String?>((ref) {
  return null;
});

final startingSecondsProvider = StateProvider<int?>((ref) {
  return null;
});

final startingVolumeProvider = StateProvider<double?>((ref) {
  return null;
});

//* Keys for testing
final titleFieldKey = UniqueKey();
final pickSoundButtonKey = UniqueKey();
final saveSoundKey = UniqueKey();
final discardSoundKey = UniqueKey();

class SoundSettingsDialog extends ConsumerWidget {
  SoundSettingsDialog({super.key, required this.sound, required this.adeganIndex, required this.soundIndex});
  final Sound sound;
  final int adeganIndex;
  final int soundIndex;

  //* Controllers
  late final TextEditingController titleController = TextEditingController(text: sound.title);

  void pickSoundFile(WidgetRef ref) async {
    final file = await FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: false);
    if (file != null) {
      ref.read(selectedFilePathProvider.notifier).state = file.files.single.path;
    }
  }

  Future<void> saveSoundSettings(WidgetRef ref, Sound sound, int adeganIndex, int soundIndex, BuildContext context, Sound oldSound) async {
    //* Save sound
    final selectedFilePath = ref.read(selectedFilePathProvider);
    File? newSoundFile;
    if (selectedFilePath != null) {
      if (File(oldSound.path).existsSync()) File(oldSound.path).delete();
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      //* Create directory
      Directory soundDir = await Directory("${appDocumentsDir.path}/adegan$adeganIndex/sound$soundIndex").create(recursive: true);
      //* Random ID
      int randomId = DateTime.now().millisecondsSinceEpoch;
      newSoundFile = await File(selectedFilePath).copy("${soundDir.path}/${sound.title.replaceAll(" ", "_")}_$randomId.mp3");
    }

    //* Update adegan
    final adeganList = ref.read(adeganListProvider);
    Adegan adegan = adeganList[adeganIndex];
    adegan.sounds[soundIndex] = Sound(title: sound.title, path: newSoundFile?.path ?? sound.path, startingSeconds: ref.read(startingSecondsProvider), startingVolume: ref.read(startingVolumeProvider));
    final adeganListNotifier = ref.read(adeganListProvider.notifier);
    adeganListNotifier.updateAdegan(adegan, adeganIndex);

    //* Reset states
    ref.read(selectedFilePathProvider.notifier).state = null;
    ref.read(startingSecondsProvider.notifier).state = null;
    ref.read(startingVolumeProvider.notifier).state = null;
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    final selectedFilePath = ref.watch(selectedFilePathProvider);
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        cursorColor: theme.onBackground,
                        style: textTheme.displaySmall,
                        controller: titleController,
                        key: titleFieldKey,
                        decoration: InputDecoration(
                          labelText: "Title",
                          labelStyle: textTheme.displaySmall,
                          fillColor: theme.primary,
                          filled: true,
                          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8.0)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    key: pickSoundButtonKey,
                    onPressed: () => pickSoundFile(ref),
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: theme.primary,
                      textStyle: textTheme.displaySmall,
                      side: BorderSide(color: theme.secondary),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder,
                          color: theme.onBackground,
                        ),
                        const SizedBox(width: 8.0),
                        Text(selectedFilePath ?? sound.path.split("/").last, style: textTheme.displaySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text("Starting Time/Volume", style: textTheme.displaySmall),
                const SizedBox(height: 8.0),
                //* Starting time
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StartingTimeSettingsWidget(
                      onChanged: (value) {
                        ref.read(startingSecondsProvider.notifier).state = value;
                      },
                      initialValue: sound.startingSeconds ?? 0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: StartingVolumeSettingsWidget(
                        onChanged: (value) {
                          ref.read(startingVolumeProvider.notifier).state = value;
                        },
                        initialValue: sound.startingVolume ?? 1.0,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: saveSoundKey,
                        onPressed: () => saveSoundSettings(ref, Sound(title: titleController.text, path: selectedFilePath ?? sound.path), adeganIndex, soundIndex, context, sound),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green),
                        child: Text("Save", style: textTheme.displaySmall),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: ElevatedButton(
                        key: discardSoundKey,
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red),
                        child: Text("Discard", style: textTheme.displaySmall),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key});

  @override
  State<AudioPlayerWidget> createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer player = AudioPlayer();

  Future<void> adjustVolume(double value) async {
    //* Check if value is going to 0
    if (player.volume + value < 0) {
      await player.setVolume(0);
      setState(() {});
      return;
    }

    //* Check if value is going to 1
    if (player.volume + value > 1) {
      await player.setVolume(1);
      setState(() {});
      return;
    }
    await player.setVolume(player.volume + value);
    setState(() {});
  }

  Future<void> togglePlayback() async {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
    setState(() {});
  }

  Future<void> setAsset(String path) async {
    await player.setAsset(path);
  }

  Future<void> play(int startingSeconds, double startingVolume) async {
    await player.seek(Duration(seconds: startingSeconds));
    await player.setVolume(startingVolume);
    setState(() {
      player.play();
    });
  }

  Future doFadeIn(double startingVolume) async {
    if (player.volume < startingVolume - 0.01) {
      await player.setVolume(player.volume + 0.01);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 50));
      if (player.playing == false) return;
      doFadeIn(startingVolume);
    }
  }

  Future<void> fadeIn(int startingSeconds, double startingVolume) async {
    await player.seek(Duration(seconds: startingSeconds));
    await player.setVolume(0);
    player.play();
    doFadeIn(startingVolume);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.secondary, borderRadius: BorderRadius.circular(8.0), border: Border.all(color: theme.secondary)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (player.playing)
                IconButton(
                    onPressed: () => setState(() {
                          player.stop();
                        }),
                    icon: const Icon(Icons.stop, color: Colors.red)),
              if (!player.playing)
                IconButton(
                    onPressed: () => setState(() {
                          player.play();
                        }),
                    icon: const Icon(Icons.play_arrow, color: Colors.green)),
              //* Progress bar with volume visualiser
              Expanded(
                child: StreamBuilder<Duration?>(
                  stream: player.durationStream,
                  builder: (context, snapshot) {
                    final duration = snapshot.data;
                    return StreamBuilder<Duration>(
                        stream: player.positionStream,
                        builder: (context, snapshot) {
                          var position = snapshot.data;
                          return (position == null || duration == null || player.audioSource == null)
                              ? Slider(
                                  thumbColor: theme.onBackground,
                                  activeColor: Colors.blue,
                                  secondaryActiveColor: Colors.blue,
                                  overlayColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                                  inactiveColor: Colors.grey,
                                  value: 0,
                                  onChanged: (value) {},
                                  min: 0,
                                  max: 0,
                                )
                              : Slider(
                                  thumbColor: theme.onBackground,
                                  activeColor: Colors.blue,
                                  secondaryActiveColor: Colors.blue,
                                  overlayColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                                  inactiveColor: Colors.grey,
                                  value: duration.inMilliseconds != 0 ? position.inMilliseconds.toDouble() : 0,
                                  onChanged: (value) {
                                    player.seek(Duration(milliseconds: value.toInt()));
                                  },
                                  min: 0,
                                  max: duration.inMilliseconds.toDouble(),
                                );
                        });
                  },
                ),
              ),
              //* Time display
              StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data;
                    return Text(position != null ? "${position.inMinutes}:${position.inSeconds % 60}" : "nil", style: textTheme.displaySmall);
                  }),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              //* VOLUME
              IconButton(onPressed: null, icon: Icon(Icons.volume_up, color: theme.onBackground)),
              Expanded(child: StreamBuilder(stream: player.volumeStream, builder: (context, snapshot) => Slider(min: 0, max: 1, thumbColor: theme.onBackground, activeColor: Colors.blue, secondaryActiveColor: Colors.blue, inactiveColor: theme.primary, value: snapshot.data ?? 0, onChanged: (value) => player.setVolume(value)))),
              const SizedBox(width: 8.0),

              //* Volume Val
              StreamBuilder<double>(
                  stream: player.volumeStream,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Text("null :(", style: textTheme.displaySmall);
                    } else {
                      return Text("${(snapshot.data! * 100).round()}%", style: textTheme.displaySmall);
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }
}

//* Starting Time Settings
class StartingTimeSettingsWidget extends StatefulWidget {
  const StartingTimeSettingsWidget({super.key, required this.onChanged, required this.initialValue});
  final Function(int) onChanged;
  final int initialValue;

  @override
  State<StartingTimeSettingsWidget> createState() => _StartingTimeSettingsWidgetState();
}

class _StartingTimeSettingsWidgetState extends State<StartingTimeSettingsWidget> {
  late final hourController = TextEditingController(text: (widget.initialValue ~/ 3600).toString());
  late final minuteController = TextEditingController(text: ((widget.initialValue % 3600) ~/ 60).toString());
  late final secondController = TextEditingController(text: (widget.initialValue % 60).toString());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IntrinsicWidth(
          child: TextField(
            //* Only allow numbers
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            controller: hourController,
            onChanged: (value) {
              widget.onChanged(int.parse(value) * 3600 + int.parse(minuteController.text) * 60 + int.parse(secondController.text));
            },
            cursorColor: Theme.of(context).colorScheme.onBackground,
            style: Theme.of(context).textTheme.displaySmall,
            decoration: InputDecoration(
              labelText: "H",
              labelStyle: Theme.of(context).textTheme.displaySmall,
              fillColor: Theme.of(context).colorScheme.primary,
              filled: true,
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ),
        Text(" : ", style: Theme.of(context).textTheme.displaySmall),
        IntrinsicWidth(
          child: TextField(
            //* Only allow numbers
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            controller: minuteController,
            onChanged: (value) {
              widget.onChanged(int.parse(hourController.text) * 3600 + int.parse(value) * 60 + int.parse(secondController.text));
            },
            cursorColor: Theme.of(context).colorScheme.onBackground,
            style: Theme.of(context).textTheme.displaySmall,
            decoration: InputDecoration(
              labelText: "M",
              labelStyle: Theme.of(context).textTheme.displaySmall,
              fillColor: Theme.of(context).colorScheme.primary,
              filled: true,
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ),
        Text(" : ", style: Theme.of(context).textTheme.displaySmall),
        IntrinsicWidth(
          child: TextField(
            //* Only allow numbers
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            controller: secondController,
            onChanged: (value) {
              widget.onChanged(int.parse(hourController.text) * 3600 + int.parse(minuteController.text) * 60 + int.parse(value));
            },
            cursorColor: Theme.of(context).colorScheme.onBackground,
            style: Theme.of(context).textTheme.displaySmall,
            decoration: InputDecoration(
              labelText: "S",
              labelStyle: Theme.of(context).textTheme.displaySmall,
              fillColor: Theme.of(context).colorScheme.primary,
              filled: true,
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ),
      ],
    );
  }
}

//* Starting Volume Settings
class StartingVolumeSettingsWidget extends StatefulWidget {
  const StartingVolumeSettingsWidget({super.key, required this.onChanged, required this.initialValue});
  final Function(double) onChanged;
  final double initialValue;

  @override
  State<StartingVolumeSettingsWidget> createState() => _StartingVolumeSettingsWidgetState();
}

class _StartingVolumeSettingsWidgetState extends State<StartingVolumeSettingsWidget> {
  late double value = widget.initialValue;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
      ),
      child: Row(
        children: [
          Expanded(child: Slider(value: value, onChanged: (v) => setState(() => value = v), onChangeEnd: (value) => widget.onChanged(value), min: 0, max: 1, thumbColor: Theme.of(context).colorScheme.onBackground, activeColor: Colors.blue, secondaryActiveColor: Colors.blue, inactiveColor: Theme.of(context).colorScheme.primary)),
          const SizedBox(width: 8.0),
          Text("${(value * 100).toStringAsFixed(0)}%", style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(width: 20.0),
        ],
      ),
    );
  }
}
