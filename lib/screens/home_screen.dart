import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/movie.dart';
import '../routes/app_routes.dart';
import '../services/movie_service.dart';
import '../widgets/movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MovieService _movieService = MovieService();
  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _movieService.getPopularMovies();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _moviesFuture = query.isEmpty
          ? _movieService.getPopularMovies()
          : _movieService.searchMovies(query);
    });
  }

  void _retry() {
    setState(() {
      _moviesFuture = _movieService.getPopularMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cari film...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: kOrange),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: _searchController.clear,
                    ),
              filled: true,
              fillColor: kCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Movie>>(
            future: _moviesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _buildError();
              }
              final movies = snapshot.data ?? [];
              if (movies.isEmpty) {
                return const Center(
                  child: Text(
                    'Film tidak ditemukan',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              return ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return MovieCard(
                    movie: movie,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      Navigator.pushNamed(
                        context,
                        AppRoutes.detail,
                        arguments: movie.id,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
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
            'Gagal memuat data',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _retry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}