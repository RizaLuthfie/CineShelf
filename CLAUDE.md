# CineShelf

Aplikasi Flutter katalog film + favorit untuk mata kuliah PAPB (IF2514704, dosen Bowo Nugroho).
Pemilik: Riza (Informatika ITK). Komunikasi: Bahasa Indonesia santai, jawaban singkat.

## Use case (6, sudah disetujui dosen, jangan diubah)
1. Melihat daftar film (Home)
2. Mencari film (search bar di Home)
3. Melihat detail film (DetailScreen)
4. Tambah ke favorit (tombol di Detail)
5. Melihat daftar favorit (tab Favorit)
6. Hapus dari favorit (ikon sampah di Favorit, toggle di Detail)

## Struktur lib/
constants/app_colors.dart (kNavy, kCard, kOrange)
models/movie.dart
routes/app_routes.dart
screens/ main_screen, home_screen, detail_screen, favorite_screen
services/ movie_service.dart, favorite_service.dart (singleton, in-memory)
widgets/ movie_card.dart, poster_image.dart

## Arsitektur
- Layar tidak boleh memanggil http langsung. Semua data lewat service.
- MovieService punya 3 method: getPopularMovies(), searchMovies(query), getMovieDetail(id).
  Signature jangan berubah supaya layar tidak perlu diedit.
- Navigasi pakai named routes: home di `routes`, detail di `onGenerateRoute` (arguments: int movieId).
- Async pakai FutureBuilder (loading, error + tombol coba lagi, kosong, data).
- Selalu cek `if (!mounted) return;` setelah await sebelum setState atau context.

## Gaya kode
- Tanpa komentar. Kode bersih dan sederhana karena akan dijelaskan ke dosen.
- Pakai widget dasar (Row, Column, Expanded, ListView.builder), hindari trik rumit.
- Setelah mengubah kode, jelaskan singkat apa yang berubah dan kenapa.

## Keamanan
- API key dan Read Access Token TMDB jangan pernah di-hardcode di file yang di-commit.
- Simpan di lib/config/api_config.dart dan tambahkan ke .gitignore.
- Jangan tampilkan atau commit token di chat, log, atau pesan commit.

## TUGAS SEKARANG (kelas besok): hit API TMDB + routing
Ganti isi MovieService dari data dummy ke TMDB asli:
- Tambah package `http` (flutter pub add http).
- Base URL: https://api.themoviedb.org/3
- Auth: header Authorization: Bearer <Read Access Token>, Accept: application/json
- Endpoint: /movie/popular, /search/movie?query=..., /movie/{id}
- Poster: https://image.tmdb.org/t/p/w500 + poster_path
- Tambah Movie.fromJson. Perhatikan: list API memberi genre_ids, detail API memberi genres [{id, name}].
  Rating dari vote_average, tahun dari 4 karakter pertama release_date.
- Tangani error (try/catch, status code != 200 -> throw) supaya UI menampilkan "Gagal memuat data".
- Android: pastikan <uses-permission android:name="android.permission.INTERNET"/> ada di
  android/app/src/main/AndroidManifest.xml.
- Routing: named routes sudah ada. Verifikasi alurnya tetap jalan dengan id film dari API.

## Rencana berikutnya
- sqflite untuk favorit (minggu 13-14), publikasi (minggu 15-16).