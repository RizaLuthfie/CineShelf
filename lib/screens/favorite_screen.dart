import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/movie.dart';
import '../routes/app_routes.dart';
import '../services/favorite_service.dart';
import '../widgets/movie_card.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteService _favoriteService = FavoriteService.instance;
  late Future<List<Movie>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _favoriteService.getFavorites();
  }

  void _reload() {
    setState(() {
      _favoritesFuture = _favoriteService.getFavorites();
    });
  }

  Future<void> _removeFavorite(Movie movie) async {
    await _favoriteService.remove(movie.id);
    if (!mounted) return;
    _reload();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${movie.title} dihapus dari favorit')),
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
      future: _favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Gagal memuat favorit',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        final favorites = snapshot.data ?? [];
        if (favorites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border, color: kOrange, size: 64),
                SizedBox(height: 12),
                Text(
                  'Belum ada film favorit',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final movie = favorites[index];
            return MovieCard(
              movie: movie,
              onTap: () => _openDetail(movie),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
                onPressed: () => _removeFavorite(movie),
              ),
            );
          },
        );
      },
    );
  }
}