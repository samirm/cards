import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_game_app/app_router.dart';
import 'package:card_game_app/core/models/playing_card.dart';
import 'package:card_game_app/core/widgets/playing_card_widget.dart';
import 'package:card_game_app/features/rummy_game/presentation/pages/rummy_game_page.dart';
import 'package:card_game_app/l10n/app_localizations.dart'; // For AppLocalizations
import 'package:flutter_localizations/flutter_localizations.dart'; // For Global delegates

// Helper to pump RummyGamePage with necessary setup
Future<void> pumpRummyGamePage(WidgetTester tester) async {
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
      initialRoute: '/rummy_game', // Directly navigate to RummyGamePage
    ),
  );
  // Wait for initial animations (dealing) and discard pile setup to complete.
  // The dealing animation is 3000ms. The status listener for discard card runs after that.
  // Add a bit more buffer.
  await tester.pumpAndSettle(const Duration(milliseconds: 3500));
}

void main() {
  group('RummyGamePage Widget Tests', () {
    testWidgets('Deck and Discard Pile Display', (WidgetTester tester) async {
      await pumpRummyGamePage(tester);

      // Verify one face-down card for the deck
      final deckFinder = find.byKey(const Key('deck_area'));
      expect(deckFinder, findsOneWidget);
      PlayingCardWidget deckCardWidget = tester.widget<PlayingCardWidget>(
        find.descendant(of: deckFinder, matching: find.byType(PlayingCardWidget))
      );
      expect(deckCardWidget.isFaceUp, isFalse);

      // Verify one face-up card for the discard pile
      final discardPileFinder = find.byKey(const Key('discard_pile_area'));
      expect(discardPileFinder, findsOneWidget);
      PlayingCardWidget discardCardWidget = tester.widget<PlayingCardWidget>(
         find.descendant(of: discardPileFinder, matching: find.byType(PlayingCardWidget))
      );
      expect(discardCardWidget.isFaceUp, isTrue);
      expect(discardCardWidget.card, isNotNull);

      // Verify placeholders are NOT initially visible
      expect(find.text('Empty Deck', skipOffstage: false), findsNothing); // Assuming these texts are from AppLocalizations now
      expect(find.text('Empty Discard Pile', skipOffstage: false), findsNothing);
    });

    testWidgets('Drag-and-Drop Reordering of Player Hand', (WidgetTester tester) async {
      await pumpRummyGamePage(tester);

      final RummyGamePageState state = tester.state(find.byType(RummyGamePage));
      // Ensure there are at least 2 cards to test reordering
      if (state._playerHandCards.length < 2) {
        // This shouldn't happen with current dealing logic (10 cards)
        debugPrint('Skipping reorder test: Not enough cards in player hand.');
        return;
      }

      PlayingCard firstCard = state._playerHandCards[0];
      PlayingCard secondCard = state._playerHandCards[1]; // Target to drop before

      // Finder for the Draggable widget associated with the first card.
      // We need to be careful to find the Draggable within the player's hand.
      final Finder draggableFirstCardFinder = find.byWidgetPredicate(
        (widget) => widget is Draggable<PlayingCard> && widget.data == firstCard,
        description: 'Draggable for the first card',
      );
      expect(draggableFirstCardFinder, findsOneWidget, reason: 'Could not find Draggable for first card');
      
      // Finder for the DragTarget widget associated with the second card.
       final Finder targetSecondCardFinder = find.byWidgetPredicate(
        (widget) => widget is DragTarget<PlayingCard> && (widget.key as ValueKey<PlayingCard>?)?.value == secondCard,
         description: 'DragTarget for the second card',
      );
      // Note: The above DragTarget finder is not quite right as DragTarget doesn't directly expose its 'card'
      // We built DragTarget<PlayingCard> where the builder returns Draggable<PlayingCard> which has child Padding->PlayingCardWidget
      // The DragTarget itself doesn't have a key related to the card in its current implementation.
      // A simpler way is to find the Draggable of the target card, then find its parent DragTarget.
      // Or, more simply, drag the first card onto the *visual representation* of the second card.

      final Finder secondCardVisualFinder = find.byWidgetPredicate(
        (widget) => widget is PlayingCardWidget && widget.card == secondCard && widget.isFaceUp == true,
        description: 'Visual representation of the second card in player hand'
      );
      expect(secondCardVisualFinder, findsOneWidget, reason: 'Could not find visual for second card');

      await tester.drag(draggableFirstCardFinder, tester.getCenter(secondCardVisualFinder));
      await tester.pumpAndSettle();

      // Verify new order: firstCard should now be before secondCard (if it wasn't already)
      // Or, if it was [A, B, C] and A is dragged to B, it becomes [A, B, C] if logic is "insert before"
      // and target is B. If A is dragged to C, it becomes [B, A, C].
      // The current logic is "insert before target". So if card 0 is dragged to card 1, it inserts at index 1.
      // Original: [card0, card1, card2, ...]
      // Drag card0 onto card1: _playerHandCards.removeAt(0); _playerHandCards.insert(1, card0); -> [card1, card0, card2]
      expect(state._playerHandCards[0], equals(secondCard), reason: "Second card should now be at index 0");
      expect(state._playerHandCards[1], equals(firstCard), reason: "First card should now be at index 1");
    });

    testWidgets('Turn Indication - Player User Starts', (WidgetTester tester) async {
      // This test is tricky due to randomness. We can't guarantee who starts.
      // A better approach would be to allow injecting the Random or first player for testability.
      // For now, we'll pump and check if *either* hand has the indication.
      
      await pumpRummyGamePage(tester);
      final RummyGamePageState state = tester.state(find.byType(RummyGamePage));
      expect(state._currentPlayer, isNotNull, reason: "Current player should be set");

      // Wait for turn indicator animation to be active
      await tester.pump(const Duration(milliseconds: 400)); // Half of one pulse cycle

      final playerHandContainerFinder = find.byKey(const Key('player_hand_container'));
      final opponentHandContainerFinder = find.byKey(const Key('opponent_hand_container'));

      final playerHandWidget = tester.widget<Container>(playerHandContainerFinder);
      final opponentHandWidget = tester.widget<Container>(opponentHandContainerFinder);
      
      // Check for Transform (lift) and BoxDecoration (highlight)
      bool playerHasIndication = false;
      if (tester.widget(find.ancestor(of: playerHandContainerFinder, matching: find.byType(Transform))) is Transform) {
         Transform playerTransform = tester.widget(find.ancestor(of: playerHandContainerFinder, matching: find.byType(Transform)));
         if ((playerTransform.transform.getTranslation().y) < 0) playerHasIndication = true;
      }
      if (playerHandWidget.decoration != null && (playerHandWidget.decoration as BoxDecoration).boxShadow != null) {
         playerHasIndication = true;
      }


      bool opponentHasIndication = false;
      if (tester.widget(find.ancestor(of: opponentHandContainerFinder, matching: find.byType(Transform))) is Transform) {
        Transform opponentTransform = tester.widget(find.ancestor(of: opponentHandContainerFinder, matching: find.byType(Transform)));
        if ((opponentTransform.transform.getTranslation().y) < 0) opponentHasIndication = true;
      }
       if (opponentHandWidget.decoration != null && (opponentHandWidget.decoration as BoxDecoration).boxShadow != null) {
         opponentHasIndication = true;
      }
      
      // Only one should have the indication active.
      expect(playerHasIndication ^ opponentHasIndication, isTrue, reason: "Exactly one player's hand should show turn indication");

      if (state._currentPlayer == Player.user) {
        expect(playerHasIndication, isTrue, reason: "Player's hand should be indicated if _currentPlayer is user");
        // Check that some animation value has taken effect for shadow
        expect((playerHandWidget.decoration as BoxDecoration).boxShadow![0].spreadRadius, greaterThan(0));
      } else { // Player.opponent
        expect(opponentHasIndication, isTrue, reason: "Opponent's hand should be indicated if _currentPlayer is opponent");
        expect((opponentHandWidget.decoration as BoxDecoration).boxShadow![0].spreadRadius, greaterThan(0));
      }
    });
  });
}
