import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cineshelf/main.dart';
import 'package:cineshelf/models/genre.dart';
import 'package:cineshelf/models/movie.dart';

void main() {
  test('Movie.fromJson membaca data dari API detail', () {
    final movie = Movie.fromJson({
      'id': 27205,
      'title': 'Inception',
      'release_date': '2010-07-15',
      'vote_average': 8.367,
      'poster_path': '/abc.jpg',
      'overview': 'Sinopsis',
      'genres': [
        {'id': 28, 'name': 'Action'},
        {'id': 878, 'name': 'Science Fiction'},
      ],
    });

    expect(movie.id, 27205);
    expect(movie.title, 'Inception');
    expect(movie.year, 2010);
    expect(movie.rating, 8.4);
    expect(movie.posterUrl, 'https://image.tmdb.org/t/p/w500/abc.jpg');
    expect(movie.genres, ['Action', 'Science Fiction']);
  });

  test('Movie.fromJson aman jika data dari API list tidak lengkap', () {
    final movie = Movie.fromJson({
      'id': 1,
      'title': 'Tanpa Poster',
      'release_date': '',
      'vote_average': 0,
      'poster_path': null,
      'genre_ids': [28],
    });

    expect(movie.year, 0);
    expect(movie.rating, 0.0);
    expect(movie.posterUrl, '');
    expect(movie.genres, isEmpty);
  });

  test('Movie.fromJson membaca sutradara dan pemeran dari credits', () {
    final movie = Movie.fromJson({
      'id': 27205,
      'title': 'Inception',
      'credits': {
        'crew': [
          {'name': 'Christopher Nolan', 'job': 'Director'},
          {'name': 'Hans Zimmer', 'job': 'Original Music Composer'},
          {'name': 'Emma Thomas', 'job': 'Director'},
        ],
        'cast': List.generate(
          12,
          (index) => {
            'name': 'Aktor $index',
            'character': 'Tokoh $index',
            'profile_path': index == 0 ? '/foto.jpg' : null,
          },
        ),
      },
    });

    expect(movie.director, 'Christopher Nolan, Emma Thomas');
    expect(movie.cast.length, 10);
    expect(movie.cast[0].name, 'Aktor 0');
    expect(movie.cast[0].character, 'Tokoh 0');
    expect(
      movie.cast[0].profileUrl,
      'https://image.tmdb.org/t/p/w185/foto.jpg',
    );
    expect(movie.cast[1].profileUrl, '');
  });

  test(
    'Movie.fromJson tanpa credits menghasilkan sutradara dan pemeran kosong',
    () {
      final movie = Movie.fromJson({'id': 1, 'title': 'Dari List'});

      expect(movie.director, '');
      expect(movie.cast, isEmpty);
    },
  );

  test('Movie.toMap dan Movie.fromMap menghasilkan data yang sama', () {
    const movie = Movie(
      id: 27205,
      title: 'Inception',
      year: 2010,
      rating: 8.4,
      posterUrl: 'https://image.tmdb.org/t/p/w500/abc.jpg',
      overview: 'Sinopsis',
      genres: ['Action', 'Science Fiction'],
    );

    final map = movie.toMap();
    final result = Movie.fromMap(map);

    expect(map['genres'], 'Action,Science Fiction');
    expect(map['poster_url'], movie.posterUrl);
    expect(result.id, movie.id);
    expect(result.title, movie.title);
    expect(result.year, movie.year);
    expect(result.rating, movie.rating);
    expect(result.posterUrl, movie.posterUrl);
    expect(result.overview, movie.overview);
    expect(result.genres, movie.genres);
  });

  test('Movie.fromMap aman jika genre kosong', () {
    final movie = Movie.fromMap({
      'id': 1,
      'title': 'Tanpa Genre',
      'year': 2020,
      'rating': 7,
      'poster_url': '',
      'overview': '',
      'genres': '',
    });

    expect(movie.rating, 7.0);
    expect(movie.genres, isEmpty);
    expect(movie.watched, isFalse);
  });

  test('Movie.toMap dan Movie.fromMap menyimpan status watched', () {
    const movie = Movie(
      id: 2,
      title: 'Sudah Ditonton',
      year: 2021,
      rating: 8.0,
      posterUrl: '',
      overview: '',
      genres: [],
      watched: true,
    );

    final map = movie.toMap();

    expect(map['watched'], 1);
    expect(map.containsKey('added_at'), isFalse);
    expect(map.containsKey('director'), isFalse);
    expect(map.containsKey('cast'), isFalse);
    expect(Movie.fromMap(map).watched, isTrue);
    expect(Movie.fromMap({...map, 'watched': 0}).watched, isFalse);
  });

  test('Genre.fromJson membaca id dan nama', () {
    final genre = Genre.fromJson({'id': 28, 'name': 'Action'});

    expect(genre.id, 28);
    expect(genre.name, 'Action');
  });

  testWidgets('Home menampilkan search bar', (WidgetTester tester) async {
    await tester.pumpWidget(const CineShelfApp());

    expect(find.text('Cari film...'), findsOneWidget);
  });

  testWidgets('Navigasi bawah memakai label Beranda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CineShelfApp());

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('Ikon info membuka halaman About dengan atribusi TMDB', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CineShelfApp());

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.text('Versi 1.0.0'), findsOneWidget);
    expect(
      find.text(
        'This product uses the TMDB API but is not endorsed or certified by TMDB.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Data film dan poster disediakan oleh TMDB.'),
      findsOneWidget,
    );
  });
}
