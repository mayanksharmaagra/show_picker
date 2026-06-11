class Suggestion {
  final String title;
  final int year;
  final String reason;
  final String type;       // "movie" or "series" from AI
  
  // TMDB Enriched Fields
  int? id;
  String? poster_path;
  String? backdrop_path;
  double? vote_average;
  int? vote_count;
  String? overview;
  String? media_type;      // confirmed by TMDB: "movie" or "tv"
  String? release_date;
  double? popularity;
  int? runtime;

  Suggestion({
    required this.title,
    required this.year,
    required this.reason,
    required this.type,
    this.id,
    this.poster_path,
    this.backdrop_path,
    this.vote_average,
    this.vote_count,
    this.overview,
    this.media_type,
    this.release_date,
    this.popularity,
    this.runtime,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      title:  json['title']  as String,
      year:   json['year']   as int,
      reason: json['reason'] as String,
      type:   json['type']   as String? ?? 'movie',
    );
  }
}