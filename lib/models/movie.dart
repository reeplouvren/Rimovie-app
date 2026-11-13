class Movie {
  final String id;
  final String title;
  final String slug;
  final String synopsis;
  final String posterUrl;
  final String videoUrl;
  final int year;
  final double rating;
  final List<String> genres;

  Movie({
    required this.id, required this.title, required this.slug,
    required this.synopsis, required this.posterUrl, required this.videoUrl,
    required this.year, required this.rating, required this.genres,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '', title: json['title'] ?? '', slug: json['slug'] ?? '',
      synopsis: json['synopsis'] ?? '', posterUrl: json['poster_url'] ?? '',
      videoUrl: json['video_url'] ?? '', year: json['year'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      genres: List<String>.from(json['genre'] ?? []),
    );
  }
}
