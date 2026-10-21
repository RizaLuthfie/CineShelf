import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'routes/app_routes.dart';
import 'screens/detail_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const CineShelfApp());
}

class CineShelfApp extends StatelessWidget {
  const CineShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineShelf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kNavy,
        colorScheme: const ColorScheme.dark(primary: kOrange),
      ),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const MainScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.detail) {
          final movieId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => DetailScreen(movieId: movieId),
          );
        }
        return null;
      },
    );
  }
}