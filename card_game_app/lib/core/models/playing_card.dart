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
  ace,
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
