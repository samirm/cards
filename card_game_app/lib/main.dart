import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Generated file - current S.delegate is similar
// import 'app_router.dart'; // Assuming app_router.dart is created
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
      // title: 'Card Game App', // Will be set by AppLocalizations
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //   useMaterial3: true, // This was not in the original prompt's target but is good to keep
      // ),
      // locale: locale, // Set the locale
      // localizationsDelegates: AppLocalizations.localizationsDelegates, // Commented out
      // localizationsDelegates: [ // Current setup, to be commented
      //   S.delegate, 
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: AppLocalizations.supportedLocales, // Commented out
      // supportedLocales: S.delegate.supportedLocales, // Current setup, to be commented
      // onGenerateRoute: AppRouter.generateRoute, // Optional: if using a router
      
      // Placeholder until other files are fully integrated
      home: Scaffold(
        appBar: AppBar(title: const Text('Card Game App')),
        body: const Center(child: Text('Setup in progress...')),
      ),
      // Remove the direct MyHomePage instantiation if using a router or specific initial screen.
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Keep MyHomePage or remove if it's no longer the entry point / being replaced by router
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Keep or modify theme
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
