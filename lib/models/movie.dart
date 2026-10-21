class Movie {
  final int id;
  final String title;
  final int year;
  final double rating;
  final String posterUrl;
  final String overview;
  final List<String> genres;

  const Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.posterUrl,
    required this.overview,
    required this.genres,
  });
}