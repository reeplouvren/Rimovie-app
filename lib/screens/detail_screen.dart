import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import 'player_screen.dart';

class DetailScreen extends StatelessWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text(movie.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(imageUrl: movie.posterUrl, height: 300, width: double.infinity, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(height: 300, color: Colors.grey[900])),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('⭐ ${movie.rating} • ${movie.year}', style: const TextStyle(color: Colors.amber)),
                  const SizedBox(height: 16),
                  Text(movie.synopsis, style: const TextStyle(color: Colors.white70, height: 1.5)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(videoUrl: movie.videoUrl, title: movie.title))),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('TONTON SEKARANG', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
