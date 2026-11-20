import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/movie.dart';
import '../routes/app_routes.dart';
import '../services/watchlist_service.dart';
import '../widgets/movie_card.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final WatchlistService _watchlistService = WatchlistService.instance;
  List<Movie> _movies = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    try {
      final movies = await _watchlistService.getWatchlist();
      if (!mounted) return;
      setState(() {
        _movies = movies;
        _isLoading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _loadWatchlist();
  }

  Movie _withWatched(Movie movie, bool watched) {
    return Movie(
      id: movie.id,
      title: movie.title,
      year: movie.year,
      rating: movie.rating,
      posterUrl: movie.posterUrl,
      overview: movie.overview,
      genres: movie.genres,
      watched: watched,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleWatched(Movie movie) async {
    final index = _movies.indexWhere((item) => item.id == movie.id);
    if (index == -1) return;
    final updated = _withWatched(movie, !movie.watched);
    setState(() {
      _movies[index] = updated;
    });
    try {
      await _watchlistService.setWatched(movie.id, updated.watched);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final currentIndex = _movies.indexWhere((item) => item.id == movie.id);
        if (currentIndex != -1) {
          _movies[currentIndex] = movie;
        }
      });
      _showMessage('Gagal memperbarui daftar tonton');
    }
  }

  Future<void> _removeFromWatchlist(Movie movie) async {
    final index = _movies.indexWhere((item) => item.id == movie.id);
    if (index == -1) return;
    setState(() {
      _movies.removeAt(index);
    });
    try {
      await _watchlistService.remove(movie.id);
      if (!mounted) return;
      _showMessage('${movie.title} dihapus dari daftar tonton');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final position = index > _movies.length ? _movies.length : index;
        _movies.insert(position, movie);
      });
      _showMessage('Gagal memperbarui daftar tonton');
    }
  }

  Future<void> _openDetail(Movie movie) async {
    await Navigator.pushNamed(context, AppRoutes.detail, arguments: movie.id);
    if (!mounted) return;
    try {
      final movies = await _watchlistService.getWatchlist();
      if (!mounted) return;
      setState(() {
        _movies = movies;
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage('Gagal memperbarui daftar tonton');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: kOrange, size: 48),
            const SizedBox(height: 8),
            const Text(
              'Gagal memuat daftar tonton',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _retry, child: const Text('Coba lagi')),
          ],
        ),
      );
    }
    if (_movies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border, color: kOrange, size: 64),
            SizedBox(height: 12),
            Text(
              'Daftar tontonmu masih kosong',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return Opacity(
          key: ValueKey(movie.id),
          opacity: movie.watched ? 0.6 : 1,
          child: MovieCard(
            movie: movie,
            onTap: () => _openDetail(movie),
            trailing: _buildActions(movie),
          ),
        );
      },
    );
  }

  Widget _buildActions(Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                movie.watched ? Icons.check_circle : Icons.check_circle_outline,
                color: movie.watched ? kOrange : Colors.white54,
              ),
              onPressed: () => _toggleWatched(movie),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white54),
              onPressed: () => _removeFromWatchlist(movie),
            ),
          ],
        ),
        if (movie.watched)
          const Text(
            'Sudah ditonton',
            style: TextStyle(color: kOrange, fontSize: 12),
          ),
      ],
    );
  }
}
