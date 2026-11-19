import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/movie.dart';
import '../routes/app_routes.dart';
import '../services/movie_service.dart';
import '../widgets/movie_card.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
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
    if (query == _query) return;
    _query = query;
    _loadFirstPage();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<List<Movie>> _fetch(int page) {
    if (_query.isEmpty) {
      return _movieService.getPopularMovies(page: page);
    }
    return _movieService.searchMovies(_query, page: page);
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Gagal memuat film berikutnya')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
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
          ),
        ),
        Expanded(child: _buildContent()),
      ],
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
          ElevatedButton(
            onPressed: _loadFirstPage,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
