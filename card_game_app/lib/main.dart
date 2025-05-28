import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Generated file - current S.delegate is similar
import 'app_router.dart'; // Assuming app_router.dart is created
// import 'features/rummy_game/presentation/providers/locale_provider.dart'; // Assuming locale_provider.dart is created

void main() {
  runApp(
    const ProviderScope( // Added const
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final locale = ref.watch(localeProvider); // Watch the locale provider - Commented out as per prompt

    return MaterialApp(
      title: 'Card Game App', // Will be set by AppLocalizations
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //   useMaterial3: true, // This was not in the original prompt's target but is good to keep
      // ),
      // locale: locale, // Set the locale
      localizationsDelegates: AppLocalizations.localizationsDelegates, // Commented out
      // localizationsDelegates: [ // Current setup, to be commented
      //   S.delegate, 
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      supportedLocales: AppLocalizations.supportedLocales, // Commented out
      // supportedLocales: S.delegate.supportedLocales, // Current setup, to be commented
      onGenerateRoute: AppRouter.generateRoute, // Optional: if using a router
      onGenerateTitle: (BuildContext context) {
        // Attempt to use AppLocalizations.of(context) for the title
        // Provide a fallback title if AppLocalizations.of(context) is null
        return AppLocalizations.of(context)?.appTitle ?? 'Card Game App';
      },
      // Remove the direct MyHomePage instantiation if using a router or specific initial screen.
    );
  }
}
