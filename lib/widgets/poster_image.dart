import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PosterImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const PosterImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder(const CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (context, error, stackTrace) {
          return _placeholder(const Icon(Icons.movie, color: Colors.white54));
        },
      ),
    );
  }

  Widget _placeholder(Widget child) {
    return Container(
      width: width,
      height: height,
      color: kNavy,
      child: Center(child: child),
    );
  }
}