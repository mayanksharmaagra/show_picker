// lib/services/tmdb_service.dart

import 'package:dio/dio.dart';

import '../data/Suggestion.dart';

class TmdbService {
  final Dio _dio = Dio();
  static const String _base      = 'https://api.themoviedb.org/3';
  static const String _imageBase = 'https://image.tmdb.org/t/p/w500';

  /// Enriches a single suggestion with TMDB data
  Future<Suggestion> enrichSuggestion(Suggestion s, String apiKey) async {
    try {
      // Search multi — finds both movies and TV
      final searchRes = await _dio.get(
        '$_base/search/multi',
        queryParameters: {
          'api_key':       apiKey,
          'query':         s.title,
          // 'include_adult': true,
        },
      );

      final results = searchRes.data['results'] as List;
      if (results.isEmpty) return s;

      // Pick best match: prefer same type as Claude suggested
      final item = _pickBestMatch(results, s);
      if (item == null) return s;

      s.id = item['id'];
      s.media_type = item['media_type']; // 'movie' or 'tv'
      s.vote_average = (item['vote_average'] as num?)?.toDouble();
      s.vote_count = item['vote_count'];
      s.overview = item['overview'];
      s.popularity = (item['popularity'] as num?)?.toDouble();
      s.backdrop_path = item['backdrop_path'] != null
          ? '$_imageBase${item['backdrop_path']}'
          : null;
      s.poster_path = item['poster_path'] != null
          ? '$_imageBase${item['poster_path']}'
          : null;
      s.release_date = item['release_date'] ?? item['first_air_date'];

      // Fetch runtime from detail endpoint
      s.runtime = await _fetchRuntime(item['id'], item['media_type'], apiKey);

    } catch (_) {
      // TMDB fail = still show card without poster
    }
    return s;
  }

  Map<String, dynamic>? _pickBestMatch(List results, Suggestion s) {
    // Filter to only movie/tv types (exclude person results)
    final filtered = results
        .where((r) => r['media_type'] == 'movie' || r['media_type'] == 'tv')
        .toList();

    if (filtered.isEmpty) return null;

    // Prefer type matching Claude's suggestion
    final preferredType = s.type == 'series' ? 'tv' : 'movie';
    final preferred = filtered.where((r) => r['media_type'] == preferredType);
    return preferred.isNotEmpty
        ? preferred.first
        : filtered.first;
  }

  Future<int?> _fetchRuntime(int id, String mediaType, String apiKey) async {
    try {
      if (mediaType == 'movie') {
        final res = await _dio.get(
          '$_base/movie/$id',
          queryParameters: {'api_key': apiKey},
        );
        return res.data['runtime'] as int?;
      } else {
        // For TV: get average episode runtime
        final res = await _dio.get(
          '$_base/tv/$id',
          queryParameters: {'api_key': apiKey},
        );
        final runtimes = res.data['episode_run_time'] as List?;
        return runtimes != null && runtimes.isNotEmpty
            ? runtimes.first as int
            : null;
      }
    } catch (_) {
      return null;
    }
  }
}