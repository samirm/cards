import 'package:card_game_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.aboutPageTitle),
      ),
      body: Center(
        child: Text(AppLocalizations.of(context)!.aboutPageTitle),
      ),
    );
  }
}
