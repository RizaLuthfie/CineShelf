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
models/movie.dart (fromJson untuk API, toMap/fromMap untuk database), models/genre.dart (id, name, fromJson)
routes/app_routes.dart
screens/ main_screen, home_screen, detail_screen, watchlist_screen, about_screen
services/ movie_service.dart, watchlist_service.dart (singleton, sqflite)
widgets/ movie_card.dart, poster_image.dart

## Arsitektur
- Layar tidak boleh memanggil http atau database langsung. Semua data lewat service.
- MovieService punya 5 method: getPopularMovies({page = 1}), searchMovies(query, {page = 1}),
  getMovieDetail(id), getGenres(), getMoviesByGenre(genreId, {page = 1}). Semua mengembalikan
  Future; page dikirim sebagai query parameter ke TMDB.
- WatchlistService punya 4 method async: getWatchlist(), isInWatchlist(id), add(movie), remove(id).
- Navigasi pakai named routes: home dan about di `routes`, detail di `onGenerateRoute` (arguments: int movieId).
- Halaman About dibuka dari ikon info_outline di AppBar MainScreen.
- Detail dan Daftar Tonton pakai FutureBuilder (loading, error + tombol coba lagi, kosong, data).
- Home pakai state manual untuk scroll tak terbatas: _movies, _page, _isLoading, _isLoadingMore,
  _hasMore, _hasError, _query, dan _requestId (hasil request lama diabaikan). ScrollController
  memuat halaman berikutnya saat dekat ujung bawah (200 px). Film dengan id sama dilewati.
  Gagal muat halaman berikutnya cukup SnackBar, daftar tidak dihapus. Ganti query = reset ke
  halaman 1 dan scroll ke atas. Debounce pencarian 500 ms.
- Filter genre di Home: baris ChoiceChip horizontal di bawah search ("Semua" + genre dari
  getGenres(), dimuat sekali di initState; gagal = baris disembunyikan). State _selectedGenreId
  (null = Semua). Sumber daftar: query tidak kosong -> searchMovies, genre terpilih ->
  getMoviesByGenre, selain itu getPopularMovies.
- Genre vs search: pilih genre = kosongkan search (set _lastText dulu, batalkan debounce) lalu
  muat halaman 1 genre. Mengetik saat genre terpilih = chip "Semua" langsung tampil terpilih,
  _selectedGenreId di-null-kan saat pencarian jalan (setelah debounce). Hapus teks = populer.
- Selalu cek `if (!mounted) return;` setelah await sebelum setState atau context.

## Data
- Film dari TMDB (http): base URL https://api.themoviedb.org/3, header Authorization: Bearer <token>.
  Endpoint /movie/popular, /search/movie?query=..., /movie/{id}, /genre/movie/list,
  /discover/movie?with_genres=... Poster: https://image.tmdb.org/t/p/w500.
- Daftar tonton disimpan di sqflite (package sqflite + path), file cineshelf.db, versi 1.
  Database dibuka lazy di WatchlistService, bukan di main.
- Tabel watchlist: id INTEGER PRIMARY KEY (id TMDB), title TEXT, year INTEGER, rating REAL,
  poster_url TEXT, overview TEXT, genres TEXT (dipisah koma), watched INTEGER DEFAULT 0,
  added_at TEXT (ISO 8601). Urutan tampil: added_at terbaru dulu.
- Kolom watched dipakai untuk status "Sudah ditonton" (setWatched di WatchlistService).

## Asset dan atribusi TMDB
- Asset didaftarkan per folder di pubspec.yaml: assets/icon/ (logo.png) dan assets/images/ (tmdb_logo.svg).
- Logo TMDB pakai flutter_svg (SvgPicture.asset), lebih kecil dari logo CineShelf, warna dan rasio tidak diubah.
- Teks atribusi wajib persis: "This product uses the TMDB API but is not endorsed or certified by TMDB."
- Jangan jalankan dart format pada seluruh folder (bisa menyentuh api_config.dart); format per file saja.

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
