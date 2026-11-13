import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const PlayerScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _video;
  ChewieController? _chewie;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _video = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _video.initialize();
    _chewie = ChewieController(
      videoPlayerController: _video, autoPlay: true, allowFullScreen: true,
      aspectRatio: _video.value.aspectRatio,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _video.dispose(); _chewie?.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text(widget.title)),
      body: Center(
        child: _chewie != null
            ? AspectRatio(aspectRatio: _video.value.aspectRatio, child: Chewie(controller: _chewie!))
            : const CircularProgressIndicator(color: Colors.red),
      ),
    );
  }
}
