import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:card_game_app/app_router.dart';
import 'package:card_game_app/features/main_menu/presentation/pages/main_menu_page.dart';
// import 'package:card_game_app/features/new_game/presentation/pages/new_game_page.dart'; // Replaced by GameTypeSelectionPage
import 'package:card_game_app/features/game_selection/presentation/pages/game_type_selection_page.dart';
import 'package:card_game_app/features/rummy_game/presentation/pages/rummy_game_page.dart';
import 'package:card_game_app/core/widgets/playing_card_widget.dart';
import 'package:card_game_app/features/options/presentation/pages/options_page.dart';
import 'package:card_game_app/features/about/presentation/pages/about_page.dart';
import 'package:card_game_app/l10n/app_localizations.dart';

void main() {
  // Helper function to pump the app with localization and routing
  Future<void> pumpApp(WidgetTester tester, {String initialRoute = '/', Duration? settleDuration}) async {
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
    // If a specific settleDuration is provided, use it. Otherwise, default pumpAndSettle.
    if (settleDuration != null) {
      await tester.pumpAndSettle(settleDuration);
    } else {
      await tester.pumpAndSettle();
    }
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
    testWidgets('Navigate to GameTypeSelectionPage and back', (WidgetTester tester) async {
      await pumpApp(tester);

      // Tap "New Game" button
      await tester.tap(find.widgetWithText(ElevatedButton, 'New Game'));
      await tester.pumpAndSettle();

      // Verify GameTypeSelectionPage is displayed
      expect(find.byType(GameTypeSelectionPage), findsOneWidget);
      // Title of GameTypeSelectionPage is "Select Game Type"
      expect(find.text('Select Game Type'), findsOneWidget); 

      // Verify AppBar and back button
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify back to MainMenuPage
      expect(find.byType(MainMenuPage), findsOneWidget);
      expect(find.text('Main Menu'), findsOneWidget); // Main Menu title
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
      expect(find.text('Main Menu'), findsOneWidget); // Main Menu title
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
      expect(find.text('Main Menu'), findsOneWidget); // Main Menu title
    });
  });

  group('GameTypeSelectionPage Tests', () {
    testWidgets('GameTypeSelectionPage renders correctly', (WidgetTester tester) async {
      await pumpApp(tester, initialRoute: '/new_game');

      expect(find.byType(GameTypeSelectionPage), findsOneWidget);
      expect(find.text('Select Game Type'), findsOneWidget); // AppBar title
      expect(find.widgetWithText(ElevatedButton, 'Rummy'), findsOneWidget);
      expect(find.text('Solitaire'), findsOneWidget);
      expect(find.text('Durak'), findsOneWidget);
    });

    testWidgets('Navigate from MainMenu to GameTypeSelection to RummyGamePage', (WidgetTester tester) async {
      await pumpApp(tester); // Start on MainMenuPage

      // Navigate to GameTypeSelectionPage
      await tester.tap(find.widgetWithText(ElevatedButton, 'New Game'));
      await tester.pumpAndSettle();
      expect(find.byType(GameTypeSelectionPage), findsOneWidget);

      // Tap "Rummy" button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Rummy'));
      // Allow time for RummyGamePage initState and animation controller to potentially start
      // but not necessarily for the full dealing animation yet.
      await tester.pumpAndSettle(const Duration(milliseconds: 500)); 

      // Verify RummyGamePage is displayed
      expect(find.byType(RummyGamePage), findsOneWidget);
      expect(find.text('Rummy'), findsOneWidget); // RummyGamePage AppBar title
    });
  });

  group('RummyGamePage Tests', () {
    testWidgets('RummyGamePage initial rendering, dealing animation, and card visibility', (WidgetTester tester) async {
      await pumpApp(tester, initialRoute: '/rummy_game');

      // Verify initial rendering
      expect(find.byType(RummyGamePage), findsOneWidget);
      expect(find.text('Rummy'), findsOneWidget); // AppBar title

      // Verify background color
      final Scaffold scaffold = tester.widget(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF35654d));

      // Wait for the dealing animation to complete (duration is 3000ms in RummyGamePage)
      // Using pumpAndSettle with a duration slightly longer.
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify player's hand (10 face-up cards)
      expect(
        find.byWidgetPredicate((widget) => widget is PlayingCardWidget && widget.isFaceUp == true && widget.card != null),
        findsNWidgets(10),
        reason: "Should find 10 face-up cards for the player",
      );

      // Verify opponent's hand (10 face-down cards)
      expect(
        find.byWidgetPredicate((widget) => widget is PlayingCardWidget && widget.isFaceUp == false && widget.card != null),
        findsNWidgets(10),
        reason: "Should find 10 face-down cards for the opponent",
      );
    });
  });
}
