import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb_movie_app/main.dart';  // Update this import to match your app name
 
void main() {
  testWidgets('TMDB Movie App Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
 
    // Verify that we have a title
    expect(find.text('TMDB Movies'), findsOneWidget);
 
    // Verify that we have bottom navigation items
    expect(find.byIcon(Icons.movie), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
 
    // Test navigation
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pumpAndSettle();
    expect(find.text('My Watchlist'), findsOneWidget);
 
    // Go back to movies
    await tester.tap(find.byIcon(Icons.movie));
    await tester.pumpAndSettle();
    expect(find.text('TMDB Movies'), findsOneWidget);
  });
}