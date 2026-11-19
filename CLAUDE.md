# CineShelf

Aplikasi Flutter katalog film + daftar tonton (watchlist) untuk mata kuliah PAPB (IF2514704, dosen Bowo Nugroho).
Pemilik: Riza (Informatika ITK). Komunikasi: Bahasa Indonesia santai, jawaban singkat.

## Use case (6, sudah disetujui dosen, jangan diubah)
Istilah "Favorit" sudah diganti jadi "Daftar Tonton"; fungsinya tetap sama.
1. Melihat daftar film (Home)
2. Mencari film (search bar di Home)
3. Melihat detail film (DetailScreen)
4. Tambah ke daftar tonton (tombol di Detail)
5. Melihat daftar tonton (tab Daftar Tonton)
6. Hapus dari daftar tonton (ikon sampah di Daftar Tonton, toggle di Detail)

## Struktur lib/
constants/app_colors.dart (kNavy, kCard, kOrange)
models/movie.dart (fromJson untuk API, toMap/fromMap untuk database)
routes/app_routes.dart
screens/ main_screen, home_screen, detail_screen, watchlist_screen
services/ movie_service.dart, watchlist_service.dart (singleton, sqflite)
widgets/ movie_card.dart, poster_image.dart

## Arsitektur
- Layar tidak boleh memanggil http atau database langsung. Semua data lewat service.
- MovieService punya 3 method: getPopularMovies(), searchMovies(query), getMovieDetail(id).
  Signature jangan berubah supaya layar tidak perlu diedit.
- WatchlistService punya 4 method async: getWatchlist(), isInWatchlist(id), add(movie), remove(id).
- Navigasi pakai named routes: home di `routes`, detail di `onGenerateRoute` (arguments: int movieId).
- Async pakai FutureBuilder (loading, error + tombol coba lagi, kosong, data).
- Selalu cek `if (!mounted) return;` setelah await sebelum setState atau context.

## Data
- Film dari TMDB (http): base URL https://api.themoviedb.org/3, header Authorization: Bearer <token>.
  Endpoint /movie/popular, /search/movie?query=..., /movie/{id}. Poster: https://image.tmdb.org/t/p/w500.
- Daftar tonton disimpan di sqflite (package sqflite + path), file cineshelf.db, versi 1.
  Database dibuka lazy di WatchlistService, bukan di main.
- Tabel watchlist: id INTEGER PRIMARY KEY (id TMDB), title TEXT, year INTEGER, rating REAL,
  poster_url TEXT, overview TEXT, genres TEXT (dipisah koma), watched INTEGER DEFAULT 0,
  added_at TEXT (ISO 8601). Urutan tampil: added_at terbaru dulu.

## Gaya kode
- Tanpa komentar. Kode bersih dan sederhana karena akan dijelaskan ke dosen.
- Pakai widget dasar (Row, Column, Expanded, ListView.builder), hindari trik rumit.
- Setelah mengubah kode, jelaskan singkat apa yang berubah dan kenapa.

## Keamanan
- API key dan Read Access Token TMDB jangan pernah di-hardcode di file yang di-commit.
- Simpan di lib/config/api_config.dart dan tambahkan ke .gitignore.
- Jangan tampilkan atau commit token di chat, log, atau pesan commit.

## Rencana berikutnya
- Publikasi (minggu 15-16).
