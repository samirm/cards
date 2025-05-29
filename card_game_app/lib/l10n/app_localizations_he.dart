// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'Card Game App';

  @override
  String get mainMenuNewGame => 'New Game';

  @override
  String get mainMenuOptions => 'Options';

  @override
  String get mainMenuAbout => 'About';

  @override
  String get mainMenuTitle => 'Main Menu';

  @override
  String get newGamePageTitle => 'Select Game Type';

  @override
  String get optionsPageTitle => 'Options';

  @override
  String get aboutPageTitle => 'About';

  @override
  String get gameTypeSelectionTitle => 'Select Game Type';

  @override
  String get gameTypeRummy => 'Rummy';

  @override
  String get gameTypeSolitaire => 'Solitaire';

  @override
  String get gameTypeDurak => 'Durak';

  @override
  String get rummyGameTitle => 'Rummy';
}
