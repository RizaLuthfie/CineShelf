import '../models/movie.dart';

class FavoriteService {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  final List<Movie> _favorites = [];

  Future<List<Movie>> getFavorites() async {
    return List<Movie>.from(_favorites);
  }

  Future<bool> isFavorite(int movieId) async {
    return _favorites.any((movie) => movie.id == movieId);
  }

  Future<void> add(Movie movie) async {
    final exists = _favorites.any((m) => m.id == movie.id);
    if (!exists) {
      _favorites.add(movie);
    }
  }

  Future<void> remove(int movieId) async {
    _favorites.removeWhere((movie) => movie.id == movieId);
  }
}