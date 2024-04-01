import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    print("Updated adegan at index $index");
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

class HomePage extends ConsumerWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    final adeganList = ref.watch(adeganListProvider);
    final adeganListNotifier = ref.watch(adeganListProvider.notifier);
    final isInitialized = ref.watch(isInitializedProvider.notifier).state;

    ref.listen<List<Adegan>>(adeganListProvider, (adeganList, previous) async {
      print("Saving adeganList");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("adeganList", AdeganFunctions.exportAdeganListToJson(adeganList!));
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        title: Text(title, style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
      ),
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
                            itemCount: adeganList.length,
                            itemBuilder: (context, adeganIndex) {
                              Adegan adegan = adeganList[adeganIndex];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(adegan.title, style: textTheme.displayMedium),
                                    const SizedBox(height: 16.0),
                                    Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: adegan.sounds.length,
                                        itemBuilder: (context, index) {
                                          Sound sound = adegan.sounds[adeganIndex];
                                          return Padding(
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
                                                    IconButton(
                                                      onPressed: () => debugPrint("fade in"),
                                                      icon: const Icon(Icons.north_east, color: Colors.blue),
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    IconButton(
                                                      onPressed: () => debugPrint(sound.path),
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
                        ),
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

  Future<void> saveSoundSettings(WidgetRef ref, Sound sound, int adeganIndex, int soundIndex, BuildContext context) async {
    final adeganList = ref.read(adeganListProvider);
    Adegan adegan = adeganList[adeganIndex];
    adegan.sounds[soundIndex] = sound;
    final adeganListNotifier = ref.read(adeganListProvider.notifier);
    adeganListNotifier.updateAdegan(adegan, adeganIndex);
    ref.read(selectedFilePathProvider.notifier).state = null;
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
                        onPressed: () {
                          // TODO: IMPLEMENT
                        },
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
                        onPressed: () => saveSoundSettings(ref, Sound(title: titleController.text, path: selectedFilePath ?? sound.path), adeganIndex, soundIndex, context),
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
