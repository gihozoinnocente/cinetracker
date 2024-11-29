# CineTracker - Movie Discovery App

## Overview
CineTracker is a modern movie discovery application built with Flutter that helps users explore, search, and track their favorite movies using the TMDB API.

## Features
- Browse trending and popular movies
- Search movies with real-time suggestions
- View detailed movie information
- Save favorites to watchlist
- Rate and review movies
- Share movies with friends
- Dark/Light theme support
- Offline support for saved movies

## Technical Stack
- **Framework**: Flutter
- **API**: TMDB (The Movie Database)
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Network**: http package
- **Image Caching**: cached_network_image
- **Database**: sqflite (for offline support)

## Project Structure
```
lib/
├── config/
│   ├── api_config.dart
│   ├── theme.dart
│   └── routes.dart
├── models/
│   ├── movie.dart
│   ├── cast.dart
│   └── review.dart
├── providers/
│   ├── movie_provider.dart
│   ├── auth_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── movie_carousel.dart
│   │   └── category_list.dart
│   ├── details/
│   │   ├── movie_details_screen.dart
│   │   ├── cast_list.dart
│   │   └── review_section.dart
│   ├── search/
│   │   └── search_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── services/
│   ├── api_service.dart
│   ├── database_service.dart
│   └── auth_service.dart
├── widgets/
│   ├── movie_card.dart
│   ├── rating_bar.dart
│   └── error_widget.dart
└── utils/
    ├── constants.dart
    └── helpers.dart
```

## Screens and Features

### 1. Home Screen
- Featured movie carousel
- Trending movies section
- Popular movies section
- Top rated movies section
- Genre-based categories
- Quick access to search and profile

### 2. Movie Details Screen
- Full movie overview
- Cast and crew information
- User ratings and reviews
- Similar movie suggestions
- Add to watchlist functionality
- Share movie option

### 3. Search Screen
- Real-time search suggestions
- Advanced filtering options
- Search history
- Genre filtering
- Year and rating filters

### 4. Profile Screen
- Watchlist management
- Viewing history
- User ratings and reviews
- App settings
- Theme toggle

## Getting Started

1. Clone the repository
2. Get TMDB API key:
   - Sign up at https://www.themoviedb.org/signup
   - Go to Settings -> API
   - Generate API key
3. Create `.env` file:
   ```
   TMDB_API_KEY=your_api_key_here
   ```
4. Run the app:
   ```bash
   flutter pub get
   flutter run
   ```

## Design Patterns Used
- Repository Pattern for data management
- Provider Pattern for state management
- Factory Pattern for object creation
- Singleton Pattern for services
- Observer Pattern for state updates

## Future Improvements
- User authentication
- Social features
- Offline-first architecture
- Push notifications
- Advanced search filters
- Movie recommendations
- TV shows support

## Performance Considerations
- Image caching
- Lazy loading
- Pagination
- Response caching
- Rate limiting