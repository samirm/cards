import 'package:flutter/material.dart';
import 'package:card_game_app/l10n/app_localizations.dart';

class NewGamePage extends StatelessWidget {
  const NewGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newGamePageTitle),
      ),
      body: Center(
        child: Text(AppLocalizations.of(context)!.newGamePageTitle),
      ),
    );
  }
}
