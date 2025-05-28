import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:card_game_app/app_router.dart';
import 'package:card_game_app/features/main_menu/presentation/pages/main_menu_page.dart';
import 'package:card_game_app/features/new_game/presentation/pages/new_game_page.dart';
import 'package:card_game_app/features/options/presentation/pages/options_page.dart';
import 'package:card_game_app/features/about/presentation/pages/about_page.dart';
import 'package:card_game_app/l10n/app_localizations.dart';

void main() {
  // Helper function to pump the app with localization and routing
  Future<void> pumpApp(WidgetTester tester, {String initialRoute = '/'}) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'), // Test with English locale
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: initialRoute,
      ),
    );
    await tester.pumpAndSettle(); // Wait for initial frame and any animations
  }

  group('MainMenuPage Rendering Tests', () {
    testWidgets('MainMenuPage displays title and buttons', (WidgetTester tester) async {
      await pumpApp(tester);

      // Verify MainMenuPage is rendered (initial route is '/')
      expect(find.byType(MainMenuPage), findsOneWidget);

      // Verify AppBar title
      // Note: AppLocalizations.of(context) is tricky to test directly in AppBar title
      // without a live context. We'll look for the text directly.
      // If AppLocalizations.of(context)!.mainMenuTitle is "Main Menu"
      expect(find.text('Main Menu'), findsOneWidget); // This assumes 'Main Menu' is the title text

      // Verify buttons with localized text
      expect(find.widgetWithText(ElevatedButton, 'New Game'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Options'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'About'), findsOneWidget);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Navigate to NewGamePage and back', (WidgetTester tester) async {
      await pumpApp(tester);

      // Tap "New Game" button
      await tester.tap(find.widgetWithText(ElevatedButton, 'New Game'));
      await tester.pumpAndSettle();

      // Verify NewGamePage is displayed
      expect(find.byType(NewGamePage), findsOneWidget);
      expect(find.text('New Game'), findsOneWidget); // Page content/title

      // Verify AppBar and back button
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify back to MainMenuPage
      expect(find.byType(MainMenuPage), findsOneWidget);
      expect(find.text('Main Menu'), findsOneWidget);
    });

    testWidgets('Navigate to OptionsPage and back', (WidgetTester tester) async {
      await pumpApp(tester);

      // Tap "Options" button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Options'));
      await tester.pumpAndSettle();

      // Verify OptionsPage is displayed
      expect(find.byType(OptionsPage), findsOneWidget);
      expect(find.text('Options'), findsOneWidget); // Page content/title

      // Verify AppBar and back button
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify back to MainMenuPage
      expect(find.byType(MainMenuPage), findsOneWidget);
       expect(find.text('Main Menu'), findsOneWidget);
    });

    testWidgets('Navigate to AboutPage and back', (WidgetTester tester) async {
      await pumpApp(tester);

      // Tap "About" button
      await tester.tap(find.widgetWithText(ElevatedButton, 'About'));
      await tester.pumpAndSettle();

      // Verify AboutPage is displayed
      expect(find.byType(AboutPage), findsOneWidget);
      expect(find.text('About'), findsOneWidget); // Page content/title

      // Verify AppBar and back button
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify back to MainMenuPage
      expect(find.byType(MainMenuPage), findsOneWidget);
      expect(find.text('Main Menu'), findsOneWidget);
    });
  });
}
