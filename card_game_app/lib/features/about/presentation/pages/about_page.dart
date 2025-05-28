import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
