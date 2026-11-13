class Movie {
  final String id, title, slug, synopsis, posterUrl, backdropUrl;
  final int year;
  final double rating;
  final List<String> genres;

  Movie({required this.id, required this.title, required this.slug, required this.synopsis, required this.posterUrl, required this.backdropUrl, required this.year, required this.rating, required this.genres});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'], title: json['title'], slug: json['slug'],
      synopsis: json['synopsis'] ?? '', posterUrl: json['poster_url'] ?? '',
      backdropUrl: json['backdrop_url'] ?? '', year: json['year'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      genres: List<String>.from(json['genre'] ?? []),
    );
  }
}

class Episode {
  final String id, videoUrl, title;
  final int episodeNumber;

  Episode({required this.id, required this.videoUrl, required this.title, required this.episodeNumber});

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'], videoUrl: json['video_url'] ?? '',
      title: json['title'] ?? '', episodeNumber: json['episode_number'] ?? 0,
    );
  }
}
