import 'package:diponegoro_sb/components/home.dart';
import 'package:diponegoro_sb/constants.dart';
import 'package:flutter/material.dart';

//* Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'diponegoro.sb',
      theme: darkTheme,
      home: HomePage(title: "diponegoro.sb"),
    );
  }
}
