enum Suit {
  hearts,
  diamonds,
  clubs,
  spades,
}

enum Rank {
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
  ace;

  int get value {
    switch (this) {
      case Rank.two: return 2;
      case Rank.three: return 3;
      case Rank.four: return 4;
      case Rank.five: return 5;
      case Rank.six: return 6;
      case Rank.seven: return 7;
      case Rank.eight: return 8;
      case Rank.nine: return 9;
      case Rank.ten: return 10;
      case Rank.jack: return 11;
      case Rank.queen: return 12;
      case Rank.king: return 13;
      case Rank.ace: return 14; // Ace high by default
    }
  }
}

class PlayingCard {
  final Suit suit;
  final Rank rank;

  const PlayingCard({required this.suit, required this.rank});

  @override
  String toString() {
    String rankStr = rank.toString().split('.').last;
    String suitStr = suit.toString().split('.').last;
    return '${rankStr[0].toUpperCase()}${rankStr.substring(1)} of ${suitStr[0].toUpperCase()}${suitStr.substring(1)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayingCard &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;
}
