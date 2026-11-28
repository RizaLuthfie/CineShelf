import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/movie.dart';
import 'poster_image.dart';

Future<int?> showRandomMovieSheet(
  BuildContext context,
  Future<Movie?> Function() loadMovie,
) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: kCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => RandomMovieSheet(loadMovie: loadMovie),
  );
}

class RandomMovieSheet extends StatefulWidget {
  final Future<Movie?> Function() loadMovie;

  const RandomMovieSheet({super.key, required this.loadMovie});

  @override
  State<RandomMovieSheet> createState() => _RandomMovieSheetState();
}

class _RandomMovieSheetState extends State<RandomMovieSheet> {
  Movie? _movie;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final movie = await widget.loadMovie();
      if (!mounted) return;
      setState(() {
        _movie = movie;
        _isLoading = false;
        if (movie == null) {
          _error = 'Film acak tidak ditemukan';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _movie = null;
        _isLoading = false;
        _error = 'Gagal memuat film acak';
      });
    }
  }

  void _openDetail() {
    Navigator.pop(context, _movie!.id);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 230, child: _buildBody()),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _load,
                    child: const Text('Acak Lagi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || _movie == null
                        ? null
                        : _openDetail,
                    child: const Text('Lihat Detail'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: kOrange, size: 48),
            const SizedBox(height: 8),
            Text(_error, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }
    final movie = _movie!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PosterImage(url: movie.posterUrl, width: 120, height: 180),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                movie.yearLabel,
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    movie.hasRating ? Icons.star : Icons.star_border,
                    color: movie.hasRating ? kOrange : Colors.white38,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      movie.ratingLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: movie.hasRating ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                movie.overview.trim().isEmpty
                    ? 'Sinopsis belum tersedia.'
                    : movie.overview,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
