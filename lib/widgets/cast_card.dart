import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/cast_member.dart';

class CastCard extends StatelessWidget {
  final CastMember member;

  const CastCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          ClipOval(
            child: member.profileUrl.isEmpty
                ? _placeholder()
                : Image.network(
                    member.profileUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _placeholder();
                    },
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            member.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            member.character,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      color: kCard,
      child: const Icon(Icons.person, color: Colors.white54, size: 36),
    );
  }
}
