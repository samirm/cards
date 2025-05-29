import 'package:flutter/material.dart';
import 'package:card_game_app/l10n/app_localizations.dart';
import 'package:card_game_app/core/models/deck.dart';
import 'package:card_game_app/core/models/playing_card.dart';
import 'package:card_game_app/core/widgets/playing_card_widget.dart';

// Removed AnimatedCardData class

class RummyGamePage extends StatefulWidget {
  const RummyGamePage({super.key});

  @override
  State<RummyGamePage> createState() => _RummyGamePageState();
}

class _RummyGamePageState extends State<RummyGamePage> with SingleTickerProviderStateMixin {
  late Deck _deck;
  List<PlayingCard> _playerHandCards = []; // Stores all 10 cards for player
  List<PlayingCard> _opponentHandCards = []; // Stores all 10 cards for opponent

  late AnimationController _dealingAnimationController;
  late Animation<int> _currentCardDealingAnimation;
  
  @override
  void initState() {
    super.initState();
    _deck = Deck();
    _deck.shuffle();

    // Deal cards upfront to stable lists
    _playerHandCards = _deck.deal(10);
    _opponentHandCards = _deck.deal(10);

    _dealingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000), // e.g., 150ms per card for 20 cards
      vsync: this,
    );

    _currentCardDealingAnimation = IntTween(begin: 0, end: 19).animate(_dealingAnimationController)
      ..addListener(() {
        setState(() {
          // This will trigger build, which will use the animation value
          // to determine how many cards to show from _playerHandCards and _opponentHandCards
        });
      });
      // Removed addStatusListener for this simplified animation

    _dealingAnimationController.forward();
  }

  @override
  void dispose() {
    _dealingAnimationController.dispose();
    super.dispose();
  }

  Widget _buildHandUI(List<PlayingCard> handCards, int cardsToShow, bool isPlayerHand) {
    List<PlayingCard> visibleCards = [];
    if (cardsToShow > 0 && cardsToShow <= handCards.length) {
      visibleCards = handCards.sublist(0, cardsToShow);
    } else if (cardsToShow > handCards.length) {
      visibleCards = handCards; // Show all if animation value somehow exceeds count
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      height: PlayingCardWidget.defaultHeight + 16, // Card height + padding
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: visibleCards.map((card) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: PlayingCardWidget(
                card: card,
                isFaceUp: isPlayerHand,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int animationValue = _currentCardDealingAnimation.value;

    // Determine number of cards to show for player
    int numPlayerCardsToShow = 0;
    if (animationValue >= 0) { // Card 0 is player's first
      numPlayerCardsToShow = (animationValue / 2).floor() + 1;
    }
    if (numPlayerCardsToShow > 10) numPlayerCardsToShow = 10;

    // Determine number of cards to show for opponent
    int numOpponentCardsToShow = 0;
    if (animationValue >= 1) { // Card 1 is opponent's first
       numOpponentCardsToShow = ((animationValue -1) / 2).floor() + 1;
    }
    if (numOpponentCardsToShow > 10) numOpponentCardsToShow = 10;


    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.rummyGameTitle),
      ),
      backgroundColor: const Color(0xFF35654d), // Green felt color
      body: Column(
        children: <Widget>[
          // Opponent's Hand (Top)
          _buildHandUI(_opponentHandCards, numOpponentCardsToShow, false),
          const Spacer(), // Pushes opponent's hand to top, player's to bottom
          // Player's Hand (Bottom)
          _buildHandUI(_playerHandCards, numPlayerCardsToShow, true),
        ],
      ),
    );
  }
}
