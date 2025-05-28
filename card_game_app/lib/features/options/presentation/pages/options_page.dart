import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.optionsPageTitle),
      ),
      body: Center(
        child: Text(AppLocalizations.of(context)!.optionsPageTitle),
      ),
    );
  }
}
