import 'dart:convert';
import 'dart:io';
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
    if (state.isNotEmpty) return;
    print("Initializing AdeganList ${state.isEmpty}");
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

  void updateAdegan(Adegan adegan) {
    state = state.map((e) => e == adegan ? adegan : e).toList();
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

final isInitialized = StateProvider<bool>((ref) {
  final adg = ref.read(adeganListProvider);
  return adg.isNotEmpty;
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    final adeganList = ref.watch(adeganListProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        title: Text(title, style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
            future: ref.read(adeganListProvider.notifier).initialize(),
            builder: (context, snapshot) {
              return adeganList.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text("Adegan List", style: textTheme.displayMedium, textAlign: TextAlign.center)),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: adeganList.length,
                            itemBuilder: (context, index) {
                              Adegan adegan = adeganList[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(adegan.title, style: textTheme.displayMedium),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: adegan.sounds.length,
                                    itemBuilder: (context, index) {
                                      Sound sound = adegan.sounds[index];
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: ListTile(
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
                                ],
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
