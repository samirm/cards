import 'package:card_game_app/core/models/playing_card.dart';

// Function to check for a Set (3 or 4 of a kind)
bool isValidSet(List<PlayingCard> cards) {
  if (cards.length < 3 || cards.length > 4) {
    return false;
  }
  if (cards.isEmpty) return false; // Should not happen with length check, but good practice

  final Rank firstRank = cards.first.rank;
  // Check if all cards have the same rank
  if (!cards.every((card) => card.rank == firstRank)) {
    return false;
  }

  // Check for duplicate suits (e.g., two Ace of Spades) - this implies unique cards
  // This check assumes cards in a set must be of different suits.
  // Standard Rummy: sets are same rank, different suits.
  if (cards.length == 3) {
    return cards[0].suit != cards[1].suit &&
           cards[0].suit != cards[2].suit &&
           cards[1].suit != cards[2].suit;
  }
  if (cards.length == 4) {
    return cards[0].suit != cards[1].suit &&
           cards[0].suit != cards[2].suit &&
           cards[0].suit != cards[3].suit &&
           cards[1].suit != cards[2].suit &&
           cards[1].suit != cards[3].suit &&
           cards[2].suit != cards[3].suit;
  }
  return false; // Should be covered by length check, but as a fallback.
}

// Function to check for a Run (3 or more sequential cards of the same suit)
bool isValidRun(List<PlayingCard> cards) {
  if (cards.length < 3) return false;
  if (cards.isEmpty) return false;

  final Suit firstSuit = cards.first.suit;
  // Check if all cards have the same suit
  if (!cards.every((card) => card.suit == firstSuit)) {
    return false;
  }

  // Sort cards by rank value (Ace is 14 by default)
  List<PlayingCard> sortedCards = List.from(cards);
  sortedCards.sort((a, b) => a.rank.value.compareTo(b.rank.value));

  // Check for standard sequence (e.g., 5-6-7, J-Q-K, 10-J-Q-K-A)
  bool standardSequence = true;
  for (int i = 0; i < sortedCards.length - 1; i++) {
    if (sortedCards[i+1].rank.value != sortedCards[i].rank.value + 1) {
      standardSequence = false;
      break;
    }
  }
  if (standardSequence) return true;

  // Check for A-2-3 sequence (Ace as low)
  // This requires Ace (value 14), Two (value 2), Three (value 3)
  // If Rank.ace.value is 14 (Ace high by default)
  if (sortedCards.length == 3) { // A-2-3 run is exactly 3 cards
    // After sorting by default value (Ace=14), A-2-3 would be [Two, Three, Ace]
    bool hasAce = sortedCards.any((c) => c.rank == Rank.ace);
    bool hasTwo = sortedCards.any((c) => c.rank == Rank.two);
    bool hasThree = sortedCards.any((c) => c.rank == Rank.three);

    if (hasAce && hasTwo && hasThree) {
      // Specifically check if the sorted order is Two, Three, Ace for A-2-3 run
      if (sortedCards[0].rank == Rank.two &&
          sortedCards[1].rank == Rank.three &&
          sortedCards[2].rank == Rank.ace) {
        return true;
      }
    }
  }

  return false;
}
