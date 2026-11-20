import 'cast_member.dart';

class Movie {
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  final int id;
  final String title;
  final int year;
  final double rating;
  final String posterUrl;
  final String overview;
  final List<String> genres;
  final bool watched;
  final String director;
  final List<CastMember> cast;

  const Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.posterUrl,
    required this.overview,
    required this.genres,
    this.watched = false,
    this.director = '',
    this.cast = const [],
  });

  String get yearLabel => year == 0 ? 'TBA' : '$year';

  bool get hasRating => rating > 0;

  String get ratingLabel => hasRating ? '$rating' : 'Belum dinilai';

  factory Movie.fromJson(Map<String, dynamic> json) {
    final String releaseDate = json['release_date'] ?? '';
    final String? posterPath = json['poster_path'];
    final List<dynamic> genreList = json['genres'] ?? [];
    final num voteAverage = json['vote_average'] ?? 0;
    final Map<String, dynamic> credits = json['credits'] ?? {};
    final List<dynamic> crewList = credits['crew'] ?? [];
    final List<dynamic> castList = credits['cast'] ?? [];

    return Movie(
      id: json['id'],
      title: json['title'] ?? '',
      year: releaseDate.length >= 4
          ? int.tryParse(releaseDate.substring(0, 4)) ?? 0
          : 0,
      rating: double.parse(voteAverage.toStringAsFixed(1)),
      posterUrl: posterPath == null ? '' : '$imageBaseUrl$posterPath',
      overview: json['overview'] ?? '',
      genres: genreList.map((genre) => genre['name'] as String).toList(),
      director: crewList
          .where((person) => person['job'] == 'Director')
          .map((person) => person['name'] as String)
          .join(', '),
      cast: castList
          .take(10)
          .map((person) => CastMember.fromJson(person))
          .toList(),
    );
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    final String genreText = map['genres'] ?? '';

    return Movie(
      id: map['id'],
      title: map['title'] ?? '',
      year: map['year'] ?? 0,
      rating: (map['rating'] as num? ?? 0).toDouble(),
      posterUrl: map['poster_url'] ?? '',
      overview: map['overview'] ?? '',
      genres: genreText.isEmpty ? [] : genreText.split(','),
      watched: map['watched'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'rating': rating,
      'poster_url': posterUrl,
      'overview': overview,
      'genres': genres.join(','),
      'watched': watched ? 1 : 0,
    };
  }
}
