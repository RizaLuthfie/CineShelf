import 'package:cineshelf/models/movie.dart';
import 'package:cineshelf/services/watchlist_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

class FakeDatabase implements Database {
  final Map<int, Map<String, Object?>> rows = {};
  String? lastWhere;

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    lastWhere = where;
    final int id = whereArgs!.first as int;
    final row = rows[id];
    if (row == null) return 0;
    row.addAll(values);
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const latest = Movie(
    id: 1,
    title: 'Judul Baru',
    year: 2025,
    rating: 8.4,
    posterUrl: 'https://image.tmdb.org/t/p/w500/baru.jpg',
    overview: 'Sinopsis baru',
    genres: ['Aksi', 'Drama'],
  );

  test('update memperbarui data tanpa mengubah watched dan added_at', () async {
    final db = FakeDatabase();
    db.rows[1] = {
      'id': 1,
      'title': 'Judul Lama',
      'year': 0,
      'rating': 0.0,
      'poster_url': '',
      'overview': '',
      'genres': '',
      'watched': 1,
      'added_at': '2026-01-01T10:00:00.000',
    };
    final service = WatchlistService.withDatabase(db);

    await service.update(latest);

    final row = db.rows[1]!;
    expect(db.lastWhere, 'id = ?');
    expect(row['title'], 'Judul Baru');
    expect(row['year'], 2025);
    expect(row['rating'], 8.4);
    expect(row['poster_url'], 'https://image.tmdb.org/t/p/w500/baru.jpg');
    expect(row['overview'], 'Sinopsis baru');
    expect(row['genres'], 'Aksi,Drama');
    expect(row['watched'], 1);
    expect(row['added_at'], '2026-01-01T10:00:00.000');
  });

  test('update tidak menambah baris untuk film yang belum tersimpan', () async {
    final db = FakeDatabase();
    final service = WatchlistService.withDatabase(db);

    await service.update(latest);

    expect(db.rows, isEmpty);
  });
}
