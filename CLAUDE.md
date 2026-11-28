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
models/movie.dart (fromJson untuk API, toMap/fromMap untuk database), models/genre.dart (id, name, fromJson),
models/cast_member.dart (name, character, profileUrl, fromJson)
routes/app_routes.dart
screens/ main_screen, home_screen, detail_screen, watchlist_screen, about_screen
services/ movie_service.dart, watchlist_service.dart (singleton, sqflite)
widgets/ movie_card.dart, poster_image.dart, cast_card.dart

## Arsitektur
- Layar tidak boleh memanggil http atau database langsung. Semua data lewat service.
- MovieService punya 8 method: getPopularMovies({page = 1}), getTopRatedMovies({page = 1}),
  getNowPlayingMovies({page = 1}), getReleasedMovies({page = 1}), searchMovies(query, {page = 1}),
  getMovieDetail(id), getGenres(), getMoviesByGenre(genreId, {page = 1}). Semua mengembalikan
  Future; page dikirim sebagai query parameter ke TMDB. getNowPlayingMovies memakai /discover/movie dengan
  region=ID, with_release_type=2|3, release_date.gte = 30 hari lalu, release_date.lte = hari ini
  (yyyy-MM-dd, diformat manual lewat _formatDate), sort_by=popularity.desc, include_adult=false.
  getReleasedMovies memakai /discover/movie dengan sort_by=popularity.desc, release_date.lte =
  hari ini (_formatDate), include_adult=false, vote_count.gte=50 (hanya film yang sudah rilis).
  searchMovies dan getMoviesByGenre juga mengirim include_adult=false secara eksplisit.
- Bahasa: language ditambahkan di _get (default 'en-US'). Semua daftar film dan detail memakai
  en-US; hanya getGenres memakai id-ID. MovieService menerima http.Client opsional di konstruktor
  (untuk test pakai MockClient).
- Aturan judul (Movie.fromJson): original_language == 'id' -> original_title (kalau kosong setelah
  trim, pakai title); selain itu title en-US.
- getGenres menyimpan hasil di _genres (cache per instance MovieService), dipanggil ulang tanpa
  request baru.
- getMovieDetail: satu request /movie/{id} en-US dengan append_to_response=credits,translations.
  Overview dari translations.translations entri iso_639_1 'id' (data.overview, tidak kosong
  setelah trim), selain itu overview en-US. Nama genre diterjemahkan per id lewat getGenres
  (id-ID); gagal memuat atau id tidak ada = nama en-US. Detail menampilkan
  "Sinopsis belum tersedia." kalau overview tetap kosong.
- Tampilan data kosong lewat getter di Movie (bukan kolom database): yearLabel (year 0 -> "TBA"),
  hasRating (rating > 0), ratingLabel (rating 0 -> "Belum dinilai"). Dipakai di MovieCard
  (Home dan Daftar Tonton) dan Detail. Tanpa rating: ikon star_border white38 dan teks white54;
  Detail menambah " / 10" hanya kalau hasRating.
- Movie punya director (String, default '') dan cast (List<CastMember>, default const []).
  fromJson membaca credits kalau ada: director = crew dengan job 'Director' (digabung koma),
  cast = 10 pertama dari credits.cast. toMap/fromMap tidak menyimpan director dan cast.
- Detail menampilkan "Sutradara: ..." di bawah rating (kalau tidak kosong) dan bagian "Pemeran"
  setelah sinopsis (ListView horizontal tinggi 175, item CastCard lebar 90; disembunyikan kalau
  cast kosong). Foto profil w185, placeholder ikon person. Nama karakter maksimal 2 baris
  (ellipsis).
- WatchlistService punya method async: getWatchlist(), isInWatchlist(id), add(movie), update(movie),
  setWatched(id, watched), remove(id). update memperbarui title, year, rating, poster_url, overview,
  genres untuk id itu (watched dan added_at tetap; film yang belum tersimpan tidak ditambah).
  Konstruktor WatchlistService.withDatabase(db) untuk test (Database palsu).
- Detail memperbarui data Daftar Tonton: setelah getMovieDetail berhasil (_loadMovie), _syncWatchlist
  memanggil update kalau isInWatchlist true. Jalan di latar belakang, maksimal sekali per buka Detail
  (_hasSyncedWatchlist), gagal diabaikan tanpa SnackBar.
- Navigasi pakai named routes: home dan about di `routes`, detail di `onGenerateRoute` (arguments: int movieId).
- Halaman About dibuka dari ikon info_outline di AppBar MainScreen.
- Label navigasi bawah: "Beranda" (ikon home) dan tab Daftar Tonton. Nama rute, file, dan kelas
  tetap home/HomeScreen.
- Detail pakai FutureBuilder (loading, error + tombol coba lagi, kosong, data).
- Daftar Tonton pakai state lokal: _movies (List<Movie>), _isLoading, _hasError. Database dimuat
  sekali di initState (loading hanya saat itu atau "Coba lagi"). Centang = ganti film di _movies
  (salinan dengan watched dibalik, lewat _withWatched) lalu setWatched; hapus = removeAt lalu
  remove. Gagal tulis = kembalikan perubahan lokal + SnackBar "Gagal memperbarui daftar tonton".
  Kembali dari Detail = muat ulang diam-diam (tanpa indikator). Kartu pakai key ValueKey(movie.id)
  agar scroll dan gambar tidak ter-reset.
- Home pakai state manual untuk scroll tak terbatas: _movies, _page, _isLoading, _isLoadingMore,
  _hasMore, _hasError, _query, dan _requestId (hasil request lama diabaikan). ScrollController
  memuat halaman berikutnya saat dekat ujung bawah (200 px). Film dengan id sama dilewati.
  Gagal muat halaman berikutnya cukup SnackBar, daftar tidak dihapus. Ganti query = reset ke
  halaman 1 dan scroll ke atas. Debounce pencarian 500 ms.
- Kategori + genre di Home: dua baris ChoiceChip di bawah search. Baris 1 (kategori): satu Row
  berisi tiga chip Expanded sama lebar (tidak scroll, label FittedBox scaleDown agar tidak
  terpotong): "Populer", "Rating Tertinggi", "Sedang Tayang", selalu tampil. Saat Sedang Tayang
  aktif, tampil catatan satu baris di bawahnya (Row: ikon info_outline 14 + Text ellipsis,
  white38 ukuran 11): "Data TMDB (Indonesia), bisa beda dengan jadwal bioskop". Baris 2 (genre): ListView horizontal genre dari
  getGenres() (dimuat sekali di initState; gagal = baris genre disembunyikan). Saling eksklusif:
  pilih genre = tidak ada chip kategori aktif, pilih kategori = genre dikosongkan. Default
  Populer. State: enum MovieCategory { popular, topRated, nowPlaying, genre } di _category dan
  _selectedGenreId (dipakai kalau _category = genre). Sumber daftar: query tidak kosong ->
  searchMovies, selain itu ikut _category: popular -> getPopularMovies, topRated ->
  getTopRatedMovies, nowPlaying -> getNowPlayingMovies, genre -> getMoviesByGenre.
- Chip vs search (_selectChip): pilih chip = kosongkan search (set _lastText dulu, batalkan
  debounce) lalu muat halaman 1 sumber itu. Saat ada teks di kolom search (setelah trim), semua
  chip kategori dan genre tampil tidak aktif; _category di-reset ke popular saat pencarian jalan
  (setelah debounce). Setelah teks dikosongkan atau tombol X ditekan, daftar kembali ke Populer
  dan chip Populer aktif.
  "Coba lagi" memuat ulang sumber aktif.
- Film Acak di Home: tombol InkWell 48x48 berisi Column (ikon Icons.casino_outlined + teks "Acak"
  fontSize 11 white70), tooltip dan Semantics label "Film acak", di kanan search bar dalam satu Row (HomeScreen tidak punya Scaffold sendiri, jadi bukan FAB; tidak menutupi daftar
  atau bottom nav). Tekan = getReleasedMovies(page acak 1-10), pilih satu film acak (utamakan id yang belum
  ada di Set _shownRandomIds; kalau semua sudah pernah muncul, acak biasa; id terpilih
  ditambahkan ke Set, tidak disimpan permanen), buka detail
  lewat AppRoutes.detail (sama seperti tap kartu). Selama memuat (_isLoadingRandom) tombol nonaktif
  dan menampilkan indikator kecil. Hasil kosong = SnackBar "Film acak tidak ditemukan", gagal =
  SnackBar "Gagal memuat film acak". Tidak mengubah kategori, genre, atau search.
- Selalu cek `if (!mounted) return;` setelah await sebelum setState atau context.

## Data
- Film dari TMDB (http): base URL https://api.themoviedb.org/3, header Authorization: Bearer <token>.
  Endpoint /movie/popular, /search/movie?query=..., /movie/{id}, /genre/movie/list,
  /discover/movie?with_genres=..., /movie/top_rated (Sedang Tayang dan Film Acak juga lewat /discover/movie, lihat di atas). Poster: https://image.tmdb.org/t/p/w500.
- Daftar tonton disimpan di sqflite (package sqflite + path), file cineshelf.db, versi 1.
  Database dibuka lazy di WatchlistService, bukan di main.
- Tabel watchlist: id INTEGER PRIMARY KEY (id TMDB), title TEXT, year INTEGER, rating REAL,
  poster_url TEXT, overview TEXT, genres TEXT (dipisah koma), watched INTEGER DEFAULT 0,
  added_at TEXT (ISO 8601). Urutan tampil: added_at terbaru dulu.
- Kolom watched dipakai untuk status "Sudah ditonton" (setWatched di WatchlistService).

## Asset dan atribusi TMDB
- Asset didaftarkan per folder di pubspec.yaml: assets/icon/ (logo.png) dan assets/images/ (tmdb_logo.svg).
- Ikon aplikasi lewat flutter_launcher_icons (blok flutter_icons di pubspec.yaml): image_path
  assets/icon/logo.png; ikon adaptive Android dengan latar #051131 dan foreground
  assets/icon/logo_foreground.png. Generate ulang dengan `dart run flutter_launcher_icons`.
- Splash Android berlatar navy #051131 (@color/ic_launcher_background di values/colors.xml):
  Android 12+ lewat android:windowSplashScreenBackground di LaunchTheme (values-v31 dan
  values-night-v31/styles.xml); di bawah 12 lewat drawable/ dan drawable-v21/launch_background.xml
  (latar solid warna itu).
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

## Signing release Android
- android/app/build.gradle.kts membaca android/key.properties (storePassword, keyPassword, keyAlias,
  storeFile) kalau file itu ada, lalu membuat signingConfigs "release" dan memakainya di buildTypes.release.
- storeFile dibaca relatif terhadap folder android/app (atau pakai path absolut).
- Kalau key.properties tidak ada, build release fallback ke kunci debug dan mencetak
  "key.properties tidak ditemukan, build release memakai kunci debug". flutter run (debug) tetap jalan.
- key.properties, *.jks, dan *.keystore ada di .gitignore. Jangan baca, tampilkan, atau commit isinya.

## Rencana berikutnya
- Publikasi (minggu 15-16).
