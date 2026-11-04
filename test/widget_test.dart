import 'package:flutter_test/flutter_test.dart';

import 'package:cineshelf/main.dart';
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

  testWidgets('Home menampilkan search bar', (WidgetTester tester) async {
    await tester.pumpWidget(const CineShelfApp());

    expect(find.text('Cari film...'), findsOneWidget);
  });
}
