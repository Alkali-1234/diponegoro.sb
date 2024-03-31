import 'package:diponegoro_sb/components/settings.dart';
import 'package:flutter/material.dart';
import 'components/home.dart';

class Routes {
  Routes(this.context);
  final BuildContext context;

  final Map<String, Widget Function(BuildContext)> routes = {
    Routes.home: (context) => const HomePage(title: 'SOUNDBOARD (100% REAL NO FAKE)'),
    Routes.settings: (context) => const SettingsPage(),
  };

  static const String home = '/';
  static const String settings = '/settings';
}
