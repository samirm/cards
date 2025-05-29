import 'package:flutter/material.dart';
import 'package:card_game_app/core/models/playing_card.dart';

// Helper functions (can be part of the class or outside)
String getRankSymbol(Rank rank) {
  switch (rank) {
    case Rank.ace: return 'A';
    case Rank.king: return 'K';
    case Rank.queen: return 'Q';
    case Rank.jack: return 'J';
    case Rank.ten: return '10';
    case Rank.nine: return '9';
    case Rank.eight: return '8';
    case Rank.seven: return '7';
    case Rank.six: return '6';
    case Rank.five: return '5';
    case Rank.four: return '4';
    case Rank.three: return '3';
    case Rank.two: return '2';
    default: return rank.toString().split('.').last[0].toUpperCase();
  }
}

String getSuitSymbol(Suit suit) {
  switch (suit) {
    case Suit.hearts: return '♥';
    case Suit.diamonds: return '♦';
    case Suit.clubs: return '♣';
    case Suit.spades: return '♠';
    default: return '?';
  }
}

Color getSuitColor(Suit suit) {
  switch (suit) {
    case Suit.hearts:
    case Suit.diamonds:
      return Colors.red;
    default:
      return Colors.black;
  }
}

class PlayingCardWidget extends StatelessWidget {
  static const double defaultWidth = 60.0;
  static const double defaultHeight = 90.0;

  final PlayingCard? card;
  final bool isFaceUp;
  final double width;
  final double height;

  const PlayingCardWidget({
    super.key, 
    this.card,
    this.isFaceUp = true,
    this.width = defaultWidth, 
    this.height = defaultHeight, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: (isFaceUp && card != null) ? Colors.white : Colors.blueGrey,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: (isFaceUp && card != null)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    getRankSymbol(card!.rank),
                    style: TextStyle(
                      fontSize: 20, // Adjust as needed
                      fontWeight: FontWeight.bold,
                      color: getSuitColor(card!.suit),
                    ),
                  ),
                  Text(
                    getSuitSymbol(card!.suit),
                    style: TextStyle(
                      fontSize: 18, // Adjust as needed
                      color: getSuitColor(card!.suit),
                    ),
                  ),
                ],
              ),
            )
          : null, // No child for face-down or null card, just the background
    );
  }
}
