import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/genre.dart';
import '../models/movie.dart';
import '../routes/app_routes.dart';
import '../services/movie_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/random_movie_sheet.dart';

enum MovieCategory { popular, topRated, nowPlaying, genre }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MovieService _movieService = MovieService();
  Timer? _debounce;
  String _lastText = '';

  List<Movie> _movies = [];
  int _page = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _hasError = false;
  String _query = '';
  int _requestId = 0;

  List<Genre> _genres = [];
  MovieCategory _category = MovieCategory.popular;
  int? _selectedGenreId;

  final Random _random = Random();
  final Set<int> _shownRandomIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _loadGenres();
    _loadFirstPage();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final text = _searchController.text;
    if (text == _lastText) return;
    _lastText = text;
    _debounce?.cancel();

    final query = text.trim();
    if (query.isEmpty) {
      setState(() {});
      _changeQuery('');
      return;
    }

    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _changeQuery(query);
    });
  }

  void _changeQuery(String query) {
    if (query == _query && _category == MovieCategory.popular) return;
    _query = query;
    _category = MovieCategory.popular;
    _selectedGenreId = null;
    _loadFirstPage();
  }

  void _selectChip(MovieCategory category, int? genreId) {
    FocusScope.of(context).unfocus();
    if (category == _category &&
        genreId == _selectedGenreId &&
        _searchController.text.isEmpty) {
      return;
    }
    _debounce?.cancel();
    _lastText = '';
    _searchController.clear();
    _query = '';
    _category = category;
    _selectedGenreId = genreId;
    _loadFirstPage();
  }

  void _retry() {
    if (_genres.isEmpty) {
      _loadGenres();
    }
    _loadFirstPage();
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await _movieService.getGenres();
      if (!mounted) return;
      setState(() {
        _genres = genres;
      });
    } catch (e) {
      return;
    }
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<List<Movie>> _fetch(int page) {
    if (_query.isNotEmpty) {
      return _movieService.searchMovies(_query, page: page);
    }
    switch (_category) {
      case MovieCategory.topRated:
        return _movieService.getTopRatedMovies(page: page);
      case MovieCategory.nowPlaying:
        return _movieService.getNowPlayingMovies(page: page);
      case MovieCategory.genre:
        return _movieService.getMoviesByGenre(_selectedGenreId!, page: page);
      case MovieCategory.popular:
        return _movieService.getPopularMovies(page: page);
    }
  }

  void _addMovies(List<Movie> movies) {
    final ids = _movies.map((movie) => movie.id).toSet();
    for (final movie in movies) {
      if (ids.add(movie.id)) {
        _movies.add(movie);
      }
    }
  }

  Future<void> _loadFirstPage() async {
    _requestId++;
    final requestId = _requestId;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    setState(() {
      _movies = [];
      _page = 1;
      _isLoading = true;
      _isLoadingMore = false;
      _hasMore = true;
      _hasError = false;
    });

    try {
      final movies = await _fetch(1);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _addMovies(movies);
        _hasMore = movies.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    final requestId = _requestId;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final movies = await _fetch(_page + 1);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _page++;
        _addMovies(movies);
        _hasMore = movies.isNotEmpty;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _isLoadingMore = false;
      });
      _showMessage('Gagal memuat film berikutnya');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<Movie?> _loadRandomMovie() async {
    final page = _random.nextInt(10) + 1;
    final movies = await _movieService.getReleasedMovies(page: page);
    if (movies.isEmpty) return null;
    final newMovies = movies
        .where((movie) => !_shownRandomIds.contains(movie.id))
        .toList();
    final choices = newMovies.isEmpty ? movies : newMovies;
    final movie = choices[_random.nextInt(choices.length)];
    _shownRandomIds.add(movie.id);
    return _movieService.getMovieDetail(movie.id);
  }

  Future<void> _openRandomMovie() async {
    FocusScope.of(context).unfocus();
    final movieId = await showRandomMovieSheet(context, _loadRandomMovie);
    if (!mounted || movieId == null) return;
    Navigator.pushNamed(context, AppRoutes.detail, arguments: movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Expanded(child: _buildSearchField()),
              const SizedBox(width: 4),
              _buildRandomButton(),
            ],
          ),
        ),
        _buildCategoryChips(),
        if (_shownCategory == MovieCategory.nowPlaying) _buildNowPlayingNote(),
        if (_genres.isNotEmpty) _buildGenreChips(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Cari film...',
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: kOrange),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: _searchController.clear,
              ),
        filled: true,
        fillColor: kCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRandomButton() {
    return Semantics(
      label: 'Film acak',
      button: true,
      child: Tooltip(
        message: 'Film acak',
        excludeFromSemantics: true,
        child: InkWell(
          onTap: _openRandomMovie,
          borderRadius: BorderRadius.circular(12),
          child: const ExcludeSemantics(
            child: SizedBox(
              width: 48,
              height: 48,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.casino_outlined, color: kOrange),
                  SizedBox(height: 2),
                  Text(
                    'Acak',
                    maxLines: 1,
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  MovieCategory? get _shownCategory {
    if (_searchController.text.trim().isNotEmpty) return null;
    return _category;
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      child: Row(
        children: [
          _buildCategoryChip('Populer', MovieCategory.popular),
          const SizedBox(width: 8),
          _buildCategoryChip('Rating Tertinggi', MovieCategory.topRated),
          const SizedBox(width: 8),
          _buildCategoryChip('Sedang Tayang', MovieCategory.nowPlaying),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, MovieCategory category) {
    return Expanded(
      child: ChoiceChip(
        label: SizedBox(
          width: double.infinity,
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
        ),
        selected: _shownCategory == category,
        onSelected: (_) => _selectChip(category, null),
        showCheckmark: false,
        selectedColor: kOrange,
        backgroundColor: kCard,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        labelPadding: EdgeInsets.zero,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _buildNowPlayingNote() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: Colors.white38),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Data TMDB (Indonesia), bisa beda dengan jadwal bioskop',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChips() {
    final category = _shownCategory;
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _genres.length,
        itemBuilder: (context, index) {
          final genre = _genres[index];
          return _buildChip(
            genre.name,
            MovieCategory.genre,
            genre.id,
            category == MovieCategory.genre && _selectedGenreId == genre.id,
          );
        },
      ),
    );
  }

  Widget _buildChip(
    String label,
    MovieCategory category,
    int? genreId,
    bool selected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => _selectChip(category, genreId),
          showCheckmark: false,
          selectedColor: kOrange,
          backgroundColor: kCard,
          side: BorderSide.none,
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return _buildError();
    }
    if (_movies.isEmpty) {
      return const Center(
        child: Text(
          'Film tidak ditemukan',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _isLoadingMore ? _movies.length + 1 : _movies.length,
      itemBuilder: (context, index) {
        if (index == _movies.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final movie = _movies[index];
        return MovieCard(
          movie: movie,
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.pushNamed(context, AppRoutes.detail, arguments: movie.id);
          },
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: kOrange, size: 48),
          const SizedBox(height: 8),
          const Text(
            'Gagal memuat data',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _retry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
