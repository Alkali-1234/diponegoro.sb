import "package:diponegoro_sb/components/home.dart";
import "package:diponegoro_sb/models/sound_model/sound_model.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:diponegoro_sb/main.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("integration test", () {
    testWidgets("confirm load and info dialog", (widgetTester) async {
      await widgetTester.pumpWidget(const ProviderScope(child: App()));
      //* Expect loading
      expect(find.byKey(loadingKey), findsOneWidget);
      //* Wait for the app to load
      while (find.byKey(loadingKey).evaluate().isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
      //* Expect the home page
      expect(find.byKey(homeKey), findsOneWidget);

      //* Open the info dialog
      await widgetTester.tap(find.byKey(infoButtonKey));
      await widgetTester.pumpAndSettle();

      //* Expect my text
      expect(find.text("@Alkali-1234"), findsAny);

      //* Expect copyright text
      expect(find.text("Copyright 2024 M. Algazel Faizun"), findsAny);

      //* Close the dialog by tapping outside
      await widgetTester.tapAt(const Offset(0, 0));
      await widgetTester.pumpAndSettle();
    });

    testWidgets("confirm add and modify adegan list", (widgetTester) async {
      await widgetTester.pumpWidget(const ProviderScope(child: App()));
      //* Expect loading
      expect(find.byKey(loadingKey), findsOneWidget);
      //* Wait for the app to load
      while (find.byKey(loadingKey).evaluate().isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 300));
        await widgetTester.pumpAndSettle();
      }
      //* Expect the home page
      expect(find.byKey(homeKey), findsOneWidget);

      //* Expect the plus button
      expect(find.byKey(addAdeganButtonKey), findsOneWidget);

      //* press the plus button
      await widgetTester.tap(find.byKey(addAdeganButtonKey));
      await widgetTester.pumpAndSettle();

      //* Expect the adegan to be added
      expect(find.byElementType(ReorderableDelayedDragStartListener), findsOneWidget);

      //* Edit the adegan
      await widgetTester.tap(find.text("Adegan 1"));
      await widgetTester.pumpAndSettle();

      //* Expect text field
      expect(find.byElementType(TextField), findsOneWidget);

      //* Change the text
      await widgetTester.enterText(find.byElementType(TextField), "edited");
      await widgetTester.pumpAndSettle();

      //* Save the text
      await widgetTester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await widgetTester.pumpAndSettle();

      //* Expect the adegan to be edited
      expect(find.textContaining("edited"), findsOneWidget);
    });

    testWidgets("test sound modify dialog", (widgetTester) async {
      //* Load the sound modify dialog
      await widgetTester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: SoundSettingsDialog(sound: Sound(title: "test", path: ""), adeganIndex: 0, soundIndex: 0)),
        ),
      ));

      //* Expect the title
      expect(find.byKey(titleFieldKey), findsOneWidget);

      //* Expect pick sound button
      expect(find.byKey(pickSoundButtonKey), findsOneWidget);

      //* Expect the save button
      expect(find.byKey(saveSoundKey), findsOneWidget);

      //* Expect discard button
      expect(find.byKey(discardSoundKey), findsOneWidget);
    });
  });
}
