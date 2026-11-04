import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/movie.dart';

class MovieService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $tmdbReadAccessToken',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? query,
  ]) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final http.Response response;
    try {
      response = await http.get(uri, headers: _headers);
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

  Future<List<Movie>> getPopularMovies() async {
    final data = await _get('/movie/popular');
    return _parseList(data);
  }

  Future<List<Movie>> searchMovies(String query) async {
    final data = await _get('/search/movie', {'query': query});
    return _parseList(data);
  }

  Future<Movie> getMovieDetail(int id) async {
    final data = await _get('/movie/$id');
    return Movie.fromJson(data);
  }
}
