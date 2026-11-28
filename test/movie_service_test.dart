import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:cineshelf/models/movie.dart';
import 'package:cineshelf/services/movie_service.dart';

void main() {
  test('Daftar film memakai en-US, daftar genre memakai id-ID', () async {
    final requests = <Uri>[];
    final service = MovieService(
      client: MockClient((request) async {
        requests.add(request.url);
        return http.Response(jsonEncode({'results': [], 'genres': []}), 200);
      }),
    );

    await service.getPopularMovies();
    await service.getTopRatedMovies();
    await service.getNowPlayingMovies();
    await service.getReleasedMovies();
    await service.searchMovies('batman');
    await service.getMoviesByGenre(28);
    await service.getGenres();

    expect(requests.length, 7);
    for (final url in requests.take(6)) {
      expect(url.queryParameters['language'], 'en-US');
    }
    expect(requests[6].path, '/3/genre/movie/list');
    expect(requests[6].queryParameters['language'], 'id-ID');
  });

  test('Daftar genre disimpan dan tidak dimuat ulang', () async {
    var count = 0;
    final service = MovieService(
      client: MockClient((request) async {
        count++;
        return http.Response(
          jsonEncode({
            'genres': [
              {'id': 28, 'name': 'Laga'},
            ],
          }),
          200,
        );
      }),
    );

    await service.getGenres();
    final genres = await service.getGenres();

    expect(count, 1);
    expect(genres.first.name, 'Laga');
  });

  group('Aturan judul', () {
    test('Film Indonesia memakai original_title', () {
      final movie = Movie.fromJson({
        'id': 1,
        'title': 'The Siege at Thorn High',
        'original_title': 'Pengepungan di Bukit Duri',
        'original_language': 'id',
      });
      expect(movie.title, 'Pengepungan di Bukit Duri');
    });

    test('Film lain memakai title en-US', () {
      final movie = Movie.fromJson({
        'id': 2,
        'title': 'Kalki 2898-AD',
        'original_title': 'కల్కి 2898 ఏ.డి',
        'original_language': 'te',
      });
      expect(movie.title, 'Kalki 2898-AD');
    });

    test('Film Indonesia tanpa original_title memakai title', () {
      final movie = Movie.fromJson({
        'id': 3,
        'title': 'English Title',
        'original_title': '',
        'original_language': 'id',
      });
      expect(movie.title, 'English Title');
    });
  });

  Map<String, dynamic> translation(
    String language,
    String country,
    String overview,
  ) {
    return {
      'iso_3166_1': country,
      'iso_639_1': language,
      'name': 'Nama',
      'english_name': 'Name',
      'data': {
        'homepage': '',
        'overview': overview,
        'runtime': 0,
        'tagline': '',
        'title': '',
      },
    };
  }

  Map<String, dynamic> detailJson({List<dynamic> translations = const []}) {
    return {
      'id': 1,
      'title': 'The Odyssey',
      'original_title': 'The Odyssey',
      'original_language': 'en',
      'overview': 'English overview',
      'genres': [
        {'id': 28, 'name': 'Action'},
        {'id': 99999, 'name': 'Unknown'},
      ],
      'translations': {'translations': translations},
    };
  }

  MovieService detailService(
    Map<String, dynamic> detail, {
    bool genreFails = false,
    List<Uri>? requests,
  }) {
    return MovieService(
      client: MockClient((request) async {
        requests?.add(request.url);
        if (request.url.path.endsWith('/genre/movie/list')) {
          if (genreFails) return http.Response('', 500);
          return http.Response(
            jsonEncode({
              'genres': [
                {'id': 28, 'name': 'Laga'},
              ],
            }),
            200,
          );
        }
        return http.Response(jsonEncode(detail), 200);
      }),
    );
  }

  test('Detail satu request en-US dengan credits dan translations', () async {
    final requests = <Uri>[];
    final service = detailService(detailJson(), requests: requests);

    final movie = await service.getMovieDetail(1);

    final detailRequests = requests.where((url) => url.path == '/3/movie/1');
    expect(detailRequests.length, 1);
    expect(detailRequests.first.queryParameters['language'], 'en-US');
    expect(
      detailRequests.first.queryParameters['append_to_response'],
      'credits,translations',
    );
    expect(movie.title, 'The Odyssey');
  });

  test('Detail memakai overview Indonesia dari translations', () async {
    final service = detailService(
      detailJson(
        translations: [
          translation('fr', 'FR', 'Français'),
          translation('id', 'ID', 'Sinopsis Indonesia'),
        ],
      ),
    );

    final movie = await service.getMovieDetail(1);

    expect(movie.overview, 'Sinopsis Indonesia');
  });

  test('Translations dibaca dari tingkat kedua, bukan list datar', () async {
    final detail = detailJson(
      translations: [translation('id', 'ID', 'Sinopsis Indonesia')],
    );
    expect(detail['translations'], isA<Map>());
    expect(detail['translations']['translations'], isA<List>());
    final service = detailService(detail);

    final movie = await service.getMovieDetail(1);

    expect(movie.overview, 'Sinopsis Indonesia');
  });

  test('Detail mengutamakan terjemahan id dengan negara ID', () async {
    final service = detailService(
      detailJson(
        translations: [
          translation('id', 'XX', 'Sinopsis lain'),
          translation('id', 'ID', 'Sinopsis Indonesia'),
        ],
      ),
    );

    final movie = await service.getMovieDetail(1);

    expect(movie.overview, 'Sinopsis Indonesia');
  });

  test('Detail memakai overview en-US jika terjemahan id kosong', () async {
    final service = detailService(
      detailJson(translations: [translation('id', 'ID', '   ')]),
    );

    final movie = await service.getMovieDetail(1);

    expect(movie.overview, 'English overview');
  });

  test('Detail memakai overview en-US jika tidak ada terjemahan id', () async {
    final service = detailService(detailJson());

    final movie = await service.getMovieDetail(1);

    expect(movie.overview, 'English overview');
  });

  test('Genre Detail diterjemahkan, id tidak dikenal memakai en-US', () async {
    final service = detailService(detailJson());

    final movie = await service.getMovieDetail(1);

    expect(movie.genres, ['Laga', 'Unknown']);
  });

  test('Genre Detail memakai nama en-US jika daftar genre gagal', () async {
    final service = detailService(detailJson(), genreFails: true);

    final movie = await service.getMovieDetail(1);

    expect(movie.genres, ['Action', 'Unknown']);
  });
}
