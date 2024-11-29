import 'package:flutter/foundation.dart';
import '../services/api_services.dart';
import '../models/movie.dart';

class MovieProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Movie> _trendingMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _watchlist = [];
  bool _isLoading = false;

  MovieProvider() {
    _initializeWatchlist();
  }

  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get watchlist => _watchlist;
  bool get isLoading => _isLoading;

  Future<void> _initializeWatchlist() async {
    _watchlist = await _apiService.getWatchlist();
    notifyListeners();
  }

  Future<void> fetchTrendingMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      _trendingMovies = await _apiService.getTrendingMovies();
    } catch (e) {
      print('Error fetching trending movies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchMovies(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchMovies(query);
    } catch (e) {
      print('Error searching movies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToWatchlist(Movie movie) async {
    final success = await _apiService.addToWatchlist(movie);
    if (success && !_watchlist.contains(movie)) {
      _watchlist.add(movie);
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(Movie movie) async {
    final success = await _apiService.removeFromWatchlist(movie);
    if (success) {
      _watchlist.removeWhere((m) => m.id == movie.id);
      notifyListeners();
    }
  }

  bool isInWatchlist(Movie movie) {
    return _watchlist.any((m) => m.id == movie.id);
  }
}