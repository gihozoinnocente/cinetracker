import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'screens/main_navigation.dart';
import 'screens/movie_details_screen.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TMDB Movie App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.black87,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black87,
            elevation: 0,
          ),
          textTheme: const TextTheme().apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black87,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.white54,
          ),
        ),
        home: const MainNavigation(),
        routes: {
          '/movie-details': (context) => const MovieDetailsScreen(),
          '/search': (context) => const SearchScreen(),
        },
      ),
    );
  }
}