import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/movie.dart';
import '../services/favorite_service.dart';
import '../services/movie_service.dart';
import '../widgets/poster_image.dart';

class DetailScreen extends StatefulWidget {
  final int movieId;

  const DetailScreen({super.key, required this.movieId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final MovieService _movieService = MovieService();
  final FavoriteService _favoriteService = FavoriteService.instance;

  late Future<Movie> _movieFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _movieFuture = _movieService.getMovieDetail(widget.movieId);
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final status = await _favoriteService.isFavorite(widget.movieId);
    if (!mounted) return;
    setState(() {
      _isFavorite = status;
    });
  }

  Future<void> _toggleFavorite(Movie movie) async {
    if (_isFavorite) {
      await _favoriteService.remove(movie.id);
    } else {
      await _favoriteService.add(movie);
    }
    if (!mounted) return;
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _retry() {
    setState(() {
      _movieFuture = _movieService.getMovieDetail(widget.movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      appBar: AppBar(
        backgroundColor: kNavy,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Detail Film',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Movie>(
        future: _movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildError();
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(Movie movie) {
    final double posterWidth = MediaQuery.of(context).size.width * 0.5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: PosterImage(
              url: movie.posterUrl,
              width: posterWidth,
              height: posterWidth * 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            movie.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text('${movie.year}', style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: kOrange, size: 20),
              const SizedBox(width: 4),
              Text(
                '${movie.rating} / 10',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: movie.genres
                .map(
                  (genre) => Chip(
                    label: Text(genre),
                    backgroundColor: kCard,
                    side: const BorderSide(color: kOrange),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sinopsis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            movie.overview,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _toggleFavorite(movie),
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              label: Text(
                _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFavorite ? kCard : kOrange,
                foregroundColor: Colors.white,
                side: _isFavorite ? const BorderSide(color: kOrange) : null,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: kOrange, size: 48),
          const SizedBox(height: 8),
          const Text(
            'Gagal memuat detail film',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _retry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}