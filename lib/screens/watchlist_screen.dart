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
  late Future<List<Movie>> _watchlistFuture;

  @override
  void initState() {
    super.initState();
    _watchlistFuture = _watchlistService.getWatchlist();
  }

  void _reload() {
    setState(() {
      _watchlistFuture = _watchlistService.getWatchlist();
    });
  }

  Future<void> _removeFromWatchlist(Movie movie) async {
    await _watchlistService.remove(movie.id);
    if (!mounted) return;
    _reload();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${movie.title} dihapus dari daftar tonton')),
    );
  }

  Future<void> _openDetail(Movie movie) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.detail,
      arguments: movie.id,
    );
    if (!mounted) return;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: _watchlistFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
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
                ElevatedButton(
                  onPressed: _reload,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          );
        }
        final watchlist = snapshot.data ?? [];
        if (watchlist.isEmpty) {
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
          itemCount: watchlist.length,
          itemBuilder: (context, index) {
            final movie = watchlist[index];
            return MovieCard(
              movie: movie,
              onTap: () => _openDetail(movie),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
                onPressed: () => _removeFromWatchlist(movie),
              ),
            );
          },
        );
      },
    );
  }
}
