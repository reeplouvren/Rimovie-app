import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';

class PlayerScreen extends StatefulWidget {
  final Movie movie;
  final List<Episode> episodes;
  const PlayerScreen({super.key, required this.movie, required this.episodes});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _video;
  ChewieController? _chewie;
  int currentEpIndex = 0;

  @override
  void initState() {
    super.initState();
    _initPlayer(widget.episodes[0].videoUrl);
  }

  Future<void> _initPlayer(String url) async {
    if (_chewie != null) {
      _video.dispose();
      _chewie!.dispose();
    }
    
    _video = VideoPlayerController.networkUrl(Uri.parse(url));
    await _video.initialize();
    _chewie = ChewieController(
      videoPlayerController: _video, autoPlay: true, allowFullScreen: true, aspectRatio: _video.value.aspectRatio,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _video.dispose(); _chewie?.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isSeries = widget.episodes.length > 1 || widget.episodes[0].episodeNumber != 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(backgroundColor: const Color(0xFF0F0F0F), iconTheme: const IconThemeData(color: Colors.white), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.black,
              child: _chewie != null
                  ? AspectRatio(aspectRatio: _video.value.aspectRatio, child: Chewie(controller: _chewie!))
                  : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.greenAccent))),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.movie.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(' ${widget.movie.rating}', style: const TextStyle(color: Colors.amber)),
                      const SizedBox(width: 12),
                      Text('${widget.movie.year} | ', style: const TextStyle(color: Colors.grey)),
                      Text(widget.movie.genres.join(', '), style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.movie.synopsis, style: const TextStyle(color: Colors.white70, height: 1.5)),
                ],
              ),
            ),
            if (isSeries) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Pilih Episode', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.episodes.length,
                  itemBuilder: (context, index) {
                    bool isSelected = index == currentEpIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() => currentEpIndex = index);
                        _initPlayer(widget.episodes[index].videoUrl);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF333333) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? Colors.greenAccent : Colors.grey[800]!),
                        ),
                        child: Text(
                          widget.episodes[index].episodeNumber.toString().padLeft(2, '0'),
                          style: TextStyle(color: isSelected ? Colors.greenAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
