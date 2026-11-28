import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/movie.dart';

class WatchlistService {
  WatchlistService._();
  WatchlistService.withDatabase(this._database);
  static final WatchlistService instance = WatchlistService._();

  static const String _tableName = 'watchlist';

  Database? _database;

  Future<Database> _getDatabase() async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final String databasePath = await getDatabasesPath();
    return openDatabase(
      join(databasePath, 'cineshelf.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            title TEXT,
            year INTEGER,
            rating REAL,
            poster_url TEXT,
            overview TEXT,
            genres TEXT,
            watched INTEGER DEFAULT 0,
            added_at TEXT
          )
        ''');
      },
    );
  }

  Future<List<Movie>> getWatchlist() async {
    final db = await _getDatabase();
    final rows = await db.query(_tableName, orderBy: 'added_at DESC');
    return rows.map((row) => Movie.fromMap(row)).toList();
  }

  Future<bool> isInWatchlist(int movieId) async {
    final db = await _getDatabase();
    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [movieId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> add(Movie movie) async {
    final db = await _getDatabase();
    final row = {
      ...movie.toMap(),
      'added_at': DateTime.now().toIso8601String(),
    };
    await db.insert(
      _tableName,
      row,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> update(Movie movie) async {
    final db = await _getDatabase();
    await db.update(
      _tableName,
      {
        'title': movie.title,
        'year': movie.year,
        'rating': movie.rating,
        'poster_url': movie.posterUrl,
        'overview': movie.overview,
        'genres': movie.genres.join(','),
      },
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<void> setWatched(int movieId, bool watched) async {
    final db = await _getDatabase();
    await db.update(
      _tableName,
      {'watched': watched ? 1 : 0},
      where: 'id = ?',
      whereArgs: [movieId],
    );
  }

  Future<void> remove(int movieId) async {
    final db = await _getDatabase();
    await db.delete(_tableName, where: 'id = ?', whereArgs: [movieId]);
  }
}
