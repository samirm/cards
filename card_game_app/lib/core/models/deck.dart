import 'dart:math'; // For Random
import 'playing_card.dart';

class Deck {
  late List<PlayingCard> _cards;

  // Constructor: Initializes _cards with a standard 52-card deck.
  Deck() {
    _cards = [];
    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        _cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }
  }

  // Method shuffle(): Randomizes the order of cards in _cards.
  void shuffle() {
    _cards.shuffle(Random());
  }

  // Method deal(int numberOfCards):
  // Removes numberOfCards from the end of _cards and returns them.
  List<PlayingCard> deal(int numberOfCards) {
    if (numberOfCards > _cards.length) {
      // Or throw an exception, or return all remaining cards
      numberOfCards = _cards.length; 
    }
    List<PlayingCard> dealtCards = _cards.sublist(_cards.length - numberOfCards);
    _cards.removeRange(_cards.length - numberOfCards, _cards.length);
    return dealtCards;
  }

  // Method dealOne(): Removes and returns a single card from the end of _cards, or null if empty.
  PlayingCard? dealOne() {
    if (_cards.isEmpty) {
      return null;
    }
    return _cards.removeLast();
  }

  // Optional helper method isEmpty():
  // Returns true if the deck has no cards.
  bool get isEmpty => _cards.isEmpty;

  // Optional helper method remainingCards():
  // Returns the number of cards left in the deck.
  int get remainingCards => _cards.length;

  // For testing or verification purposes
  @override
  String toString() {
    return 'Deck with $remainingCards cards remaining.';
  }
}
