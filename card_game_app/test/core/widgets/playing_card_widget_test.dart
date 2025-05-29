import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_game_app/core/models/playing_card.dart';
import 'package:card_game_app/core/widgets/playing_card_widget.dart';

void main() {
  // Helper function to pump PlayingCardWidget within a MaterialApp and Scaffold
  Future<void> pumpCardWidget(WidgetTester tester, PlayingCardWidget cardWidget) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: cardWidget),
        ),
      ),
    );
    await tester.pumpAndSettle(); // Ensure widget is fully rendered
  }

  // Sample card for tests
  const PlayingCard sampleCard = PlayingCard(suit: Suit.spades, rank: Rank.ace);

  group('PlayingCardWidget Dimension Tests', () {
    testWidgets('Renders with default dimensions', (WidgetTester tester) async {
      const PlayingCardWidget cardWidget = PlayingCardWidget(card: sampleCard);
      await pumpCardWidget(tester, cardWidget);

      // Find the Container rendered by PlayingCardWidget
      // PlayingCardWidget's root is a Container.
      final Finder containerFinder = find.descendant(
        of: find.byType(PlayingCardWidget),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsOneWidget);

      // Verify its size
      expect(tester.getSize(containerFinder), const Size(60.0, 90.0));
    });

    testWidgets('Renders with custom dimensions', (WidgetTester tester) async {
      const PlayingCardWidget cardWidget = PlayingCardWidget(
        card: sampleCard,
        width: 80.0,
        height: 120.0,
      );
      await pumpCardWidget(tester, cardWidget);

      // Find the Container rendered by PlayingCardWidget
      final Finder containerFinder = find.descendant(
        of: find.byType(PlayingCardWidget),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsOneWidget);

      // Verify its size
      expect(tester.getSize(containerFinder), const Size(80.0, 120.0));
    });
  });
}
