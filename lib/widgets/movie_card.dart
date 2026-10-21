import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/movie.dart';
import 'poster_image.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final Widget? trailing;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final double posterWidth = MediaQuery.of(context).size.width * 0.25;

    return Card(
      color: kCard,
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PosterImage(
                url: movie.posterUrl,
                width: posterWidth,
                height: posterWidth * 1.5,
              ),
              const SizedBox(width: 12),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.year}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: kOrange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${movie.rating}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}