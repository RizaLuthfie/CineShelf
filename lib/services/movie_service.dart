import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/genre.dart';
import '../models/movie.dart';

class MovieService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  final http.Client _client;
  List<Genre>? _genres;

  MovieService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $tmdbReadAccessToken',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? query,
    String language = 'en-US',
  ]) async {
    final uri = Uri.parse('$_baseUrl$path')
        .replace(queryParameters: {...?query, 'language': language});
    final http.Response response;
    try {
      response = await _client.get(uri, headers: _headers);
    } catch (e) {
      throw Exception('Gagal memuat data: tidak ada koneksi');
    }
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data: status ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  List<Movie> _parseList(Map<String, dynamic> data) {
    final List<dynamic> results = data['results'] ?? [];
    return results.map((item) => Movie.fromJson(item)).toList();
  }

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final data = await _get('/movie/popular', {'page': '$page'});
    return _parseList(data);
  }

  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    final data = await _get('/movie/top_rated', {'page': '$page'});
    return _parseList(data);
  }

  Future<List<Movie>> getNowPlayingMovies({int page = 1}) async {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 30));
    final data = await _get('/discover/movie', {
      'region': 'ID',
      'with_release_type': '2|3',
      'release_date.gte': _formatDate(start),
      'release_date.lte': _formatDate(today),
      'sort_by': 'popularity.desc',
      'include_adult': 'false',
      'page': '$page',
    });
    return _parseList(data);
  }

  Future<List<Movie>> getReleasedMovies({int page = 1}) async {
    final data = await _get('/discover/movie', {
      'sort_by': 'popularity.desc',
      'release_date.lte': _formatDate(DateTime.now()),
      'include_adult': 'false',
      'vote_count.gte': '50',
      'page': '$page',
    });
    return _parseList(data);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final data = await _get('/search/movie', {
      'query': query,
      'include_adult': 'false',
      'page': '$page',
    });
    return _parseList(data);
  }

  Future<Movie> getMovieDetail(int id) async {
    final data = await _get('/movie/$id', {
      'append_to_response': 'credits,translations',
    });
    final indonesianOverview = _indonesianOverview(data);
    if (indonesianOverview.isNotEmpty) {
      data['overview'] = indonesianOverview;
    }
    data['genres'] = await _translateGenres(data['genres'] ?? []);
    return Movie.fromJson(data);
  }

  String _indonesianOverview(Map<String, dynamic> data) {
    final Map<String, dynamic> translations = data['translations'] ?? {};
    final List<dynamic> list = translations['translations'] ?? [];
    String result = '';
    for (final item in list) {
      if (item['iso_639_1'] != 'id') continue;
      final Map<String, dynamic> info = item['data'] ?? {};
      final String overview = (info['overview'] ?? '').trim();
      if (overview.isEmpty) continue;
      if (item['iso_3166_1'] == 'ID') return overview;
      if (result.isEmpty) result = overview;
    }
    return result;
  }

  Future<List<dynamic>> _translateGenres(List<dynamic> genres) async {
    final Map<int, String> names = {};
    try {
      final indonesianGenres = await getGenres();
      for (final genre in indonesianGenres) {
        names[genre.id] = genre.name;
      }
    } catch (e) {
      return genres;
    }
    return genres
        .map(
          (genre) => {
            'id': genre['id'],
            'name': names[genre['id']] ?? genre['name'],
          },
        )
        .toList();
  }

  Future<List<Genre>> getGenres() async {
    final cached = _genres;
    if (cached != null) return cached;
    final data = await _get('/genre/movie/list', null, 'id-ID');
    final List<dynamic> genres = data['genres'] ?? [];
    final result = genres.map((item) => Genre.fromJson(item)).toList();
    _genres = result;
    return result;
  }

  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final data = await _get('/discover/movie', {
      'with_genres': '$genreId',
      'include_adult': 'false',
      'page': '$page',
    });
    return _parseList(data);
  }
}
