import 'package:flutter/material.dart';
import 'package:card_game_app/features/main_menu/presentation/pages/main_menu_page.dart';
// import 'package:card_game_app/features/new_game/presentation/pages/new_game_page.dart'; // Removed
import 'package:card_game_app/features/options/presentation/pages/options_page.dart';
import 'package:card_game_app/features/about/presentation/pages/about_page.dart';
import 'package:card_game_app/features/game_selection/presentation/pages/game_type_selection_page.dart'; // Added
import 'package:card_game_app/features/rummy_game/presentation/pages/rummy_game_page.dart'; // Added

// TODO: Define routes
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainMenuPage());
      case '/new_game':
        return MaterialPageRoute(builder: (_) => const GameTypeSelectionPage()); // Changed
      case '/rummy_game': // Added
        return MaterialPageRoute(builder: (_) => const RummyGamePage()); // Added
      case '/options':
        return MaterialPageRoute(builder: (_) => const OptionsPage());
      case '/about':
        return MaterialPageRoute(builder: (_) => const AboutPage());
      // case '/settings':
      //   return MaterialPageRoute(builder: (_) => SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
