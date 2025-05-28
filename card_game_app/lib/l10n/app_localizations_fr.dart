// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get gameTitle => 'Jeu de Rami';

  @override
  String get drawCard => 'Piocher';

  @override
  String get discardPile => 'Défausse';

  @override
  String get yourTurn => 'À votre tour';

  @override
  String get suitHearts => 'Cœurs';

  @override
  String get suitDiamonds => 'Diamonds';

  @override
  String get suitClubs => 'Clubs';

  @override
  String get suitSpades => 'Spades';

  @override
  String get rankAce => 'Ace';

  @override
  String get rankKing => 'King';
}
