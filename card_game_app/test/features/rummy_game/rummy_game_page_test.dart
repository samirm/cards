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
    testWidgets('Builds successfully and shows initial UI', (WidgetTester tester) async {
      await pumpRummyGamePage(tester);
      expect(find.byType(RummyGamePage), findsOneWidget);
      // Implicitly checks that no major errors occurred during build/initial animations.
    });

    testWidgets('Deck and Discard Pile Display and Order', (WidgetTester tester) async {
      await pumpRummyGamePage(tester);

      final deckAreaFinder = find.byKey(const Key('deck_area'));
      final discardPileAreaFinder = find.byKey(const Key('discard_pile_area'));

      expect(deckAreaFinder, findsOneWidget);
      expect(discardPileAreaFinder, findsOneWidget);

      // Verify deck content (face-down card)
      final deckCardWidgetFinder = find.descendant(of: deckAreaFinder, matching: find.byType(PlayingCardWidget));
      expect(deckCardWidgetFinder, findsOneWidget);
      PlayingCardWidget deckCardWidget = tester.widget<PlayingCardWidget>(deckCardWidgetFinder);
      expect(deckCardWidget.isFaceUp, isFalse);

      // Verify discard pile content (face-up card)
      final discardCardWidgetFinder = find.descendant(of: discardPileAreaFinder, matching: find.byType(PlayingCardWidget));
      expect(discardCardWidgetFinder, findsOneWidget);
      PlayingCardWidget discardCardWidget = tester.widget<PlayingCardWidget>(discardCardWidgetFinder);
      expect(discardCardWidget.isFaceUp, isTrue);
      expect(discardCardWidget.card, isNotNull);

      // Verify placeholders are NOT initially visible (using AppLocalizations)
      final BuildContext context = tester.element(find.byType(RummyGamePage));
      expect(find.text(AppLocalizations.of(context)!.emptyDeckPlaceholder, skipOffstage: false), findsNothing);
      expect(find.text(AppLocalizations.of(context)!.emptyDiscardPlaceholder, skipOffstage: false), findsNothing);

      // Verify order: Deck before Discard within their Row
      final Row middleRow = tester.widget<Row>(find.ancestor(of: deckAreaFinder, matching: find.byType(Row)));
      expect(middleRow.mainAxisAlignment, MainAxisAlignment.start);

      final List<Widget> middleRowChildren = middleRow.children;
      int deckIndex = -1;
      int discardIndex = -1;
      for(int i=0; i<middleRowChildren.length; ++i) {
        if (middleRowChildren[i].key == const Key('deck_area')) deckIndex = i;
        if (middleRowChildren[i].key == const Key('discard_pile_area')) discardIndex = i;
      }
      expect(deckIndex, lessThan(discardIndex), reason: "Deck should appear before discard pile");
      expect(middleRowChildren[deckIndex + 1] is SizedBox && (middleRowChildren[deckIndex + 1] as SizedBox).width == 16, isTrue, reason: "Spacing SizedBox not found or incorrect width");
    });

    testWidgets('Drag-and-Drop Reordering - Card to Beginning', (WidgetTester tester) async {
      await pumpRummyGamePage(tester);
      final RummyGamePageState state = tester.state(find.byType(RummyGamePage));
      if (state._playerHandCards.length < 2) return; // Skip if not enough cards

      PlayingCard cardToDrag = state._playerHandCards[1]; // Second card
      PlayingCard targetCard = state._playerHandCards[0]; // First card

      final Finder draggableCardFinder = find.byWidgetPredicate(
        (widget) => widget is Draggable<PlayingCard> && widget.data == cardToDrag);
      final Finder targetCardVisualFinder = find.byWidgetPredicate(
        (widget) => widget is PlayingCardWidget && widget.card == targetCard && widget.isFaceUp == true);

      await tester.drag(draggableCardFinder, tester.getCenter(targetCardVisualFinder));
      await tester.pumpAndSettle();

      expect(state._playerHandCards[0], equals(cardToDrag), reason: "Dragged card should now be at index 0");
      expect(state._playerHandCards[1], equals(targetCard), reason: "Original first card should now be at index 1");
    });

    testWidgets('Drag-and-Drop Reordering - Card to End', (WidgetTester tester) async {
      await pumpRummyGamePage(tester);
      final RummyGamePageState state = tester.state(find.byType(RummyGamePage));
      if (state._playerHandCards.isEmpty) return;

      PlayingCard cardToDrag = state._playerHandCards[0]; // First card

      final Finder draggableCardFinder = find.byWidgetPredicate(
        (widget) => widget is Draggable<PlayingCard> && widget.data == cardToDrag);
      final Finder endOfHandTargetFinder = find.byKey(const Key('end_of_hand_drag_target'));

      expect(endOfHandTargetFinder, findsOneWidget, reason: "End-of-hand drag target not found");

      await tester.drag(draggableCardFinder, tester.getCenter(endOfHandTargetFinder));
      await tester.pumpAndSettle();

      expect(state._playerHandCards.last, equals(cardToDrag), reason: "Dragged card should now be the last card");
    });

     testWidgets('Visual Shift on Drag Over - State Check', (WidgetTester tester) async {
      await pumpRummyGamePage(tester);
      final RummyGamePageState state = tester.state(find.byType(RummyGamePage));
      if (state._playerHandCards.length < 2) return;

      PlayingCard cardToDrag = state._playerHandCards[0];
      PlayingCard cardToHoverOver = state._playerHandCards[1];

      final Finder draggableCardFinder = find.byWidgetPredicate(
          (widget) => widget is Draggable<PlayingCard> && widget.data == cardToDrag);

      // Find the DragTarget associated with the cardToHoverOver (second card)
      // This requires finding the PlayingCardWidget, then its parent Draggable, then its parent DragTarget.
      // For simplicity, we'll find the PlayingCardWidget and use its center.
      final Finder hoverTargetVisualFinder = find.byWidgetPredicate(
          (widget) => widget is PlayingCardWidget && widget.card == cardToHoverOver && widget.isFaceUp == true);

      expect(draggableCardFinder, findsOneWidget);
      expect(hoverTargetVisualFinder, findsOneWidget);

      final Offset hoverLocation = tester.getCenter(hoverTargetVisualFinder);
      final TestGesture gesture = await tester.startGesture(tester.getCenter(draggableCardFinder));
      await tester.pump(); // Start drag
      await gesture.moveTo(hoverLocation);
      await tester.pump(); // Pump for onWillAccept/onMove to fire

      expect(state._dragHoverTargetIndex, equals(1), reason: "Hover index should be 1 (index of second card)");

      await gesture.moveBy(const Offset(0, 50)); // Move away from the target
      await tester.pump(); // Pump for onLeave to fire
      expect(state._dragHoverTargetIndex, isNull, reason: "Hover index should be null after leaving target");

      await gesture.up(); // Release drag
      await tester.pumpAndSettle();
    });

    testWidgets('Exclusive Turn Highlight', (WidgetTester tester) async {
      await pumpRummyGamePage(tester);
      final RummyGamePageState state = tester.state(find.byType(RummyGamePage));
      expect(state._currentPlayer, isNotNull, reason: "Current player should be set");

      // Wait for turn indicator animation to be active (half cycle)
      await tester.pump(const Duration(milliseconds: 375));

      final playerHandContainerFinder = find.byKey(const Key('player_hand_container'));
      final opponentHandContainerFinder = find.byKey(const Key('opponent_hand_container'));

      final Container playerHandContainer = tester.widget<Container>(playerHandContainerFinder);
      final Container opponentHandContainer = tester.widget<Container>(opponentHandContainerFinder);

      if (state._currentPlayer == Player.user) {
        expect(playerHandContainer.decoration, isNotNull, reason: "Player's hand should have decoration if current player");
        expect((playerHandContainer.decoration! as BoxDecoration).boxShadow, isNotEmpty, reason: "Player's hand shadow should be visible");
        expect(opponentHandContainer.decoration, isNull, reason: "Opponent's hand should NOT have decoration");
      } else { // Player.opponent
        expect(opponentHandContainer.decoration, isNotNull, reason: "Opponent's hand should have decoration if current player");
        expect((opponentHandContainer.decoration! as BoxDecoration).boxShadow, isNotEmpty, reason: "Opponent's hand shadow should be visible");
        expect(playerHandContainer.decoration, isNull, reason: "Player's hand should NOT have decoration");
      }
    });
  });
}
