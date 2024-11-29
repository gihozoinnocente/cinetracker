import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class ApiService {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  // Replace this with your actual API key from TMDB
  static const String apiKey = '5450b8e64819d18515f5fd20ad123e7a';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Bearer token authorization
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1NDUwYjhlNjQ4MTlkMTg1MTVmNWZkMjBhZDEyM2U3YSIsIm5iZiI6MTczMjE4MTIyNi43MjI3NzcxLCJzdWIiOiI2NzNlZjk3Yjc2NGRhNDI1MWU4Nzc4NzAiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.prZI5XCdlSsJ7NqgDmdSExdI_-cEdazbHBfxdo2hI5c', // Replace with your access token
  };

  Future<String?> getMovieTrailerKey(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videos = (data['results'] as List);
        
        // First try to find official trailer
        final officialTrailer = videos.firstWhere(
          (video) => 
            video['type'] == 'Trailer' && 
            video['site'] == 'YouTube' &&
            video['official'] == true,
          orElse: () => null,
        );

        // If no official trailer, get any trailer
        final anyTrailer = videos.firstWhere(
          (video) => 
            video['type'] == 'Trailer' && 
            video['site'] == 'YouTube',
          orElse: () => null,
        );

        // If no trailer, get any video
        final anyVideo = videos.firstWhere(
          (video) => video['site'] == 'YouTube',
          orElse: () => null,
        );

        final videoData = officialTrailer ?? anyTrailer ?? anyVideo;
        return videoData?['key'];
      }
      return null;
    } catch (e) {
      print('Error getting movie trailer: $e');
      return null;
    }
  }

  // Get movie details with videos
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey&append_to_response=videos,credits'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get trending movies
  Future<List<Movie>> getTrendingMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'),
        headers: _headers,
      );

      print('Trending movies response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
      } else {
        print('Error response: ${response.body}');
        throw Exception(
            'Failed to load trending movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTrendingMovies: $e');
      throw Exception('Network error: $e');
    }
  }

  // Search movies
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'),
        headers: _headers,
      );

      print('Search movies response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to search movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchMovies: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get movie details
  // Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey'),
  //       headers: _headers,
  //     );

  //     print('Movie details response: ${response.statusCode}');
  //     print('Response body: ${response.body}');

  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       print('Error response: ${response.body}');
  //       throw Exception('Failed to load movie details: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error in getMovieDetails: $e');
  //     throw Exception('Network error: $e');
  //   }
  // }

  // Get watchlist
  Future<List<Movie>> getWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = prefs.getStringList('watchlist') ?? [];
      return watchlistJson
          .map((item) => Movie.fromJson(json.decode(item)))
          .toList();
    } catch (e) {
      print('Error getting watchlist: $e');
      return [];
    }
  }

  // Add to watchlist in local storage
  Future<bool> addToWatchlist(Movie movie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> watchlistJson = prefs.getStringList('watchlist') ?? [];

      // Check if movie already exists in watchlist
      if (!watchlistJson.any((item) {
        final decoded = json.decode(item);
        return decoded['id'] == movie.id;
      })) {
        watchlistJson.add(json.encode(movie.toJson()));
        await prefs.setStringList('watchlist', watchlistJson);
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding to watchlist: $e');
      return false;
    }
  }

  // Remove from watchlist in local storage
  Future<bool> removeFromWatchlist(Movie movie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> watchlistJson = prefs.getStringList('watchlist') ?? [];

      watchlistJson.removeWhere((item) {
        final decoded = json.decode(item);
        return decoded['id'] == movie.id;
      });

      await prefs.setStringList('watchlist', watchlistJson);
      return true;
    } catch (e) {
      print('Error removing from watchlist: $e');
      return false;
    }
  }

  // Check if movie is in watchlist
  Future<bool> isInWatchlist(int movieId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistJson = prefs.getStringList('watchlist') ?? [];

      return watchlistJson.any((item) {
        final decoded = json.decode(item);
        return decoded['id'] == movieId;
      });
    } catch (e) {
      print('Error checking watchlist status: $e');
      return false;
    }
  }

  // Future<String?> getMovieTrailerKey(int movieId) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey'),
  //       headers: _headers,
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final videos = data['results'] as List;

  //       // First try to find official trailer
  //       final officialTrailer = videos.firstWhere(
  //         (video) =>
  //             video['type'] == 'Trailer' &&
  //             video['site'] == 'YouTube' &&
  //             video['official'] == true,
  //         orElse: () => null,
  //       );

  //       // If no official trailer, get any trailer
  //       final anyTrailer = videos.firstWhere(
  //         (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
  //         orElse: () => null,
  //       );

  //       // If no trailer, get any video
  //       final anyVideo = videos.firstWhere(
  //         (video) => video['site'] == 'YouTube',
  //         orElse: () => null,
  //       );

  //       final videoData = officialTrailer ?? anyTrailer ?? anyVideo;
  //       return videoData?['key'];
  //     }
  //     return null;
  //   } catch (e) {
  //     print('Error getting movie trailer: $e');
  //     return null;
  //   }
  // }
}
