import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameTypeSelectionPage extends StatelessWidget {
  const GameTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.gameTypeSelectionTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/rummy_game');
              },
              child: Text(AppLocalizations.of(context)!.gameTypeRummy),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.gameTypeSolitaire,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.gameTypeDurak,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
