import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    debugPrint(jsonEncode(adeganListJson));
    return jsonEncode(adeganListJson);
  }
}

//* State

class AdeganList extends Notifier<List<Adegan>> {
  Future<void> initialize() async {
    if (ref.read(isInitializedProvider)) return;
    print("Initializing AdeganList ${ref.read(isInitializedProvider)}");
    Directory appDocDir = await getApplicationDocumentsDirectory().then((value) => value);
    //* Create directories
    Directory adeganDir = Directory("${appDocDir.path}/adegan");
    if (!await adeganDir.exists()) {
      print("Creating adegan directory");
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

class HomePage extends ConsumerWidget {
  HomePage({super.key, required this.title});

  final String title;

  //* AUDIO PLAYER KEY
  final GlobalKey<AudioPlayerWidgetState> audioPlayerKey = GlobalKey<AudioPlayerWidgetState>();

  final adeganTitleController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    final adeganList = ref.watch(adeganListProvider);
    final adeganListNotifier = ref.watch(adeganListProvider.notifier);
    final isInitialized = ref.watch(isInitializedProvider.notifier).state;
    final currentMouseHovering = ref.watch(currentMouseHoveringProvider);
    final currentEditingAdeganTitle = ref.watch(currentEditingAdeganTitleProvider);

    ref.listen<List<Adegan>>(adeganListProvider, (previous, adeganList) async {
      debugPrint("Saving adegan list");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("adeganList", AdeganFunctions.exportAdeganListToJson(adeganList));
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
            future: !isInitialized ? adeganListNotifier.initialize() : null,
            builder: (context, snapshot) {
              return isInitialized
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "diponegoro.sb",
                              style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                                onPressed: () {
                                  //TODO : IMPLEMENT SETTINGS
                                },
                                icon: Icon(Icons.settings, color: theme.colorScheme.onBackground))
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: adeganList.length + 1,
                            itemBuilder: (context, adeganIndex) {
                              Adegan adegan = adeganList.isEmpty || adeganIndex == adeganList.length ? Adegan(title: "", sounds: []) : adeganList[adeganIndex];
                              return adeganIndex != adeganList.length && adeganList.isNotEmpty
                                  ? Container(
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
                                              Expanded(
                                                  child: TapRegion(
                                                onTapInside: (event) {
                                                  adeganTitleController.text = adegan.title;
                                                  ref.read(currentEditingAdeganTitleProvider.notifier).state = adeganIndex;
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
                                              GestureDetector(
                                                onTap: () {
                                                  adeganListNotifier.removeAdegan(adegan);
                                                },
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
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
                                              shrinkWrap: true,
                                              itemCount: adegan.sounds.length + 1,
                                              itemBuilder: (context, index) {
                                                Sound sound = adegan.sounds.isEmpty || index == adegan.sounds.length ? Sound(title: "", path: "") : adegan.sounds[index];
                                                return index == adegan.sounds.length || adegan.sounds.isEmpty
                                                    ? IconButton(
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
                                                        ))
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
                                                              IconButton(onPressed: () => adeganListNotifier.updateAdegan(adegan.copyWith(sounds: adegan.sounds.where((element) => element != sound).toList()), adeganIndex), icon: const Icon(Icons.delete, color: Colors.red)),
                                                              const SizedBox(width: 8.0),
                                                              IconButton(
                                                                onPressed: () => debugPrint("fade in"),
                                                                icon: const Icon(Icons.north_east, color: Colors.blue),
                                                              ),
                                                              const SizedBox(width: 8.0),
                                                              IconButton(
                                                                onPressed: () async {
                                                                  await audioPlayerKey.currentState!.setAsset(sound.path);
                                                                  audioPlayerKey.currentState!.play(null);
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
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: IconButton(
                                          onPressed: () {
                                            adeganListNotifier.addAdegan(Adegan(title: "Adegan ${adeganList.length + 1}", sounds: []));
                                          },
                                          icon: Icon(
                                            Icons.add_rounded,
                                            color: theme.colorScheme.onBackground,
                                            size: 48,
                                          )),
                                    );
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        AudioPlayerWidget(key: audioPlayerKey),
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.onBackground,
                      ),
                    );
            }),
      ),
    );
  }
}

//* Sound Settings State
final selectedFilePathProvider = StateProvider<String?>((ref) {
  return null;
});

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
      File(oldSound.path).delete();
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
    adegan.sounds[soundIndex] = Sound(title: sound.title, path: newSoundFile?.path ?? sound.path);
    final adeganListNotifier = ref.read(adeganListProvider.notifier);
    adeganListNotifier.updateAdegan(adegan, adeganIndex);
    ref.read(selectedFilePathProvider.notifier).state = null;
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
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
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
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

  Future<void> setAsset(String path) async {
    await player.setAsset(path);
  }

  Future<void> play(int? startingMilliseconds) async {
    await player.play();
    if (startingMilliseconds != null) {
      player.seek(Duration(milliseconds: startingMilliseconds));
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.secondary, borderRadius: BorderRadius.circular(8.0), border: Border.all(color: theme.secondary)),
      child: Row(
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
                              inactiveColor: Colors.grey,
                              value: 0,
                              onChanged: (value) {},
                              min: 0,
                              max: 0,
                            )
                          : Slider(
                              value: position.inMilliseconds.toDouble(),
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
    );
  }
}
