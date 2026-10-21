import '../models/movie.dart';

class MovieService {
  static const List<Movie> _movies = [
    Movie(
      id: 27205,
      title: 'Inception',
      year: 2010,
      rating: 8.8,
      posterUrl: 'https://www.themoviedb.org/t/p/w1280/xlaY2zyzMfkhk0HSC5VUwzoZPU1.jpg',
      overview:
          'Seorang pencuri rahasia lewat teknologi berbagi mimpi diberi tugas '
          'yang berkebalikan: menanamkan sebuah ide ke dalam pikiran pewaris '
          'sebuah perusahaan besar.',
      genres: ['Aksi', 'Fiksi Ilmiah', 'Petualangan'],
    ),
    Movie(
      id: 157336,
      title: 'Interstellar',
      year: 2014,
      rating: 8.7,
      posterUrl: 'https://www.themoviedb.org/t/p/w1280/yQvGrMoipbRoddT0ZR8tPoR7NfX.jpg',
      overview:
          'Ketika bumi semakin tidak layak huni, sekelompok astronot melewati '
          'lubang cacing untuk mencari planet baru bagi umat manusia.',
      genres: ['Petualangan', 'Drama', 'Fiksi Ilmiah'],
    ),
    Movie(
      id: 155,
      title: 'The Dark Knight',
      year: 2008,
      rating: 9.0,
      posterUrl: 'https://www.themoviedb.org/t/p/w1280/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      overview:
          'Batman berusaha menumpas kejahatan di Gotham, tetapi muncul Joker '
          'yang mengacaukan kota dan menguji batas moral semua orang.',
      genres: ['Drama', 'Aksi', 'Kriminal'],
    ),
    Movie(
      id: 496243,
      title: 'Parasite',
      year: 2019,
      rating: 8.5,
      posterUrl: 'https://www.themoviedb.org/t/p/w1280/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg',
      overview:
          'Sebuah keluarga miskin perlahan menyusup bekerja di rumah keluarga '
          'kaya, sampai sebuah rahasia mengubah segalanya.',
      genres: ['Komedi', 'Thriller', 'Drama'],
    ),
    Movie(
      id: 324857,
      title: 'Spider-Man: Into the Spider-Verse',
      year: 2018,
      rating: 8.4,
      posterUrl: 'https://www.themoviedb.org/t/p/w1280/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg',
      overview:
          'Miles Morales, remaja Brooklyn, menjadi Spider-Man dan bertemu para '
          'Spider-Man dari dimensi lain untuk menghentikan ancaman bagi seluruh '
          'realitas.',
      genres: ['Animasi', 'Aksi', 'Petualangan', 'Fiksi Ilmiah'],
    ),
  ];

  Future<List<Movie>> getPopularMovies() async {
    await Future.delayed(const Duration(seconds: 1));
    return _movies;
  }

  Future<List<Movie>> searchMovies(String query) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final keyword = query.toLowerCase();
    return _movies
        .where((movie) => movie.title.toLowerCase().contains(keyword))
        .toList();
  }

  Future<Movie> getMovieDetail(int id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _movies.firstWhere((movie) => movie.id == id);
  }
}