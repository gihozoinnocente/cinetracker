import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_services.dart';
import 'video_player_screen.dart';
import 'package:intl/intl.dart';

class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({Key? key}) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? movieDetails;
  String? trailerKey;
  bool isLoading = true;
  bool isInWatchlist = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final movieId = ModalRoute.of(context)!.settings.arguments as int;
    _loadMovieDetails(movieId);
    _loadTrailer(movieId);
  }

  Future<void> _loadMovieDetails(int movieId) async {
    try {
      final details = await _apiService.getMovieDetails(movieId);
      setState(() {
        movieDetails = details;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading movie details: $e')),
        );
      }
    }
  }

  Future<void> _loadTrailer(int movieId) async {
    try {
      final key = await _apiService.getMovieTrailerKey(movieId);
      setState(() {
        trailerKey = key;
      });
    } catch (e) {
      print('Error loading trailer: $e');
    }
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat.currency(symbol: '\$');
    return formatter.format(amount);
  }

  String _formatRuntime(int? runtime) {
    if (runtime == null) return 'N/A';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return '${hours}h ${minutes}m';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (movieDetails == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load movie details')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: 'https://image.tmdb.org/t/p/original${movieDetails!['backdrop_path']}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.black12,
                      child: const Icon(Icons.error),
                    ),
                  ),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                movieDetails!['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Title and Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          movieDetails!['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${movieDetails!['vote_average'].toStringAsFixed(1)}/10',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Release Year, Runtime, Rating
                  Row(
                    children: [
                      Text(
                        DateFormat('yyyy').format(
                          DateTime.parse(movieDetails!['release_date']),
                        ),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _formatRuntime(movieDetails!['runtime']),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          movieDetails!['adult'] ? '18+' : 'PG',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Watch Trailer Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: trailerKey != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    videoKey: trailerKey!,
                                    title: movieDetails!['title'],
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Watch Trailer'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Overview
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movieDetails!['overview'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Movie Info
                  const Text(
                    'Movie Info',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Genre', 
                    (movieDetails!['genres'] as List)
                        .map((genre) => genre['name'])
                        .join(', '),
                  ),
                  _buildInfoRow('Release Date', 
                    DateFormat.yMMMMd().format(
                      DateTime.parse(movieDetails!['release_date']),
                    ),
                  ),
                  _buildInfoRow(
                    'Budget', 
                    _formatCurrency(movieDetails!['budget']),
                  ),
                  _buildInfoRow(
                    'Revenue', 
                    _formatCurrency(movieDetails!['revenue']),
                  ),
                  _buildInfoRow(
                    'Original Language',
                    movieDetails!['original_language'].toString().toUpperCase(),
                  ),
                  _buildInfoRow(
                    'Production',
                    (movieDetails!['production_companies'] as List)
                        .map((company) => company['name'])
                        .join(', '),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Rating',
                          '${movieDetails!['vote_average'].toStringAsFixed(1)}/10',
                          Icons.star,
                        ),
                        _buildStatItem(
                          'Votes',
                          NumberFormat.compact()
                              .format(movieDetails!['vote_count']),
                          Icons.people,
                        ),
                        _buildStatItem(
                          'Popularity',
                          NumberFormat.compact()
                              .format(movieDetails!['popularity']),
                          Icons.trending_up,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isInWatchlist = !isInWatchlist;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isInWatchlist
                    ? 'Added to watchlist'
                    : 'Removed from watchlist',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Icon(
          isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}