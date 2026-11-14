import 'login_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import 'player_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> movies = [];
  bool loading = true;
  int _currentIndex = 0;
  
  // Variabel untuk Banner Auto-Slide
  final PageController _pageController = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _currentBannerIndex = 0;
String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  void _startAutoSlide(int totalMovies) {
    _timer?.cancel();
    if (totalMovies <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentBannerIndex < (totalMovies > 4 ? 3 : totalMovies - 1)) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> fetchMovies() async {
    try {
      final data = await Supabase.instance.client.from('movies').select().order('created_at', ascending: false);
      setState(() {
        movies = (data as List).map((e) => Movie.fromJson(e)).toList();
        loading = false;
        _startAutoSlide(movies.length);
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> openPlayer(Movie movie) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Belum Login', style: TextStyle(color: Colors.white)),
          content: const Text('Silakan login atau daftar terlebih dahulu untuk menonton film ini.', style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Batal', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              }, 
              child: const Text('Login Sekarang')
            ),
          ],
        )
      );
      return;
    }

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)));
    final data = await Supabase.instance.client.from('episodes').select().eq('movie_id', movie.id).order('episode_number', ascending: true);
    final episodes = (data as List).map((e) => Episode.fromJson(e)).toList();
    if (mounted) Navigator.pop(context);
    if (episodes.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(movie: movie, episodes: episodes)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video belum tersedia')));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(backgroundColor: Color(0xFF0F0F0F), body: Center(child: CircularProgressIndicator(color: Colors.green)));

List<Movie> filteredMovies = movies.where((movie) {
  return movie.title.toLowerCase().contains(_searchQuery);
}).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_display_rounded), label: 'Short TV'),
          BottomNavigationBarItem(icon: Icon(Icons.download_for_offline_rounded), label: 'Unduhan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Aku'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 35, height: 35,
                      decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(8)),
                      child: const Center(child: Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                    child: Container(
  height: 40,
  decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)),
  child: TextField(
    onChanged: (value) {
      setState(() {
        _searchQuery = value.toLowerCase();
      });
    },
    style: const TextStyle(color: Colors.white, fontSize: 14),
    decoration: const InputDecoration(
      hintText: 'Cari film...',
      hintStyle: TextStyle(color: Colors.grey),
      prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
      border: InputBorder.none,
      contentPadding: EdgeInsets.only(top: 10),
      ),
    ),
  ),
),
                    const SizedBox(width: 12),
                    const Text('Cari', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildMenuChip('BARU', Colors.greenAccent, isBold: true),
                  _buildMenuChip('AI Drama', Colors.white, isBold: true),
                  _buildMenuChip('Film Indie', Colors.orange),
                  _buildMenuChip('Animasi', Colors.grey),
                  _buildMenuChip('Drama Korea', Colors.grey),
                  _buildMenuChip('Film Barat', Colors.grey),
                  _buildMenuChip('Dokumenter', Colors.grey),
                  _buildMenuChip('Horor', Colors.grey),
                  _buildMenuChip('Komedi', Colors.grey),
                  _buildMenuChip('Trending', Colors.grey),
                ],
              ),
            ),

            // BANNER AUTO-SLIDE
            if (movies.isNotEmpty)
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: movies.length > 4 ? 4 : movies.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final Movie bannerMovie = movies[index];
                    return GestureDetector(
                      onTap: () => openPlayer(bannerMovie),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: bannerMovie.posterUrl.isNotEmpty 
                                    ? bannerMovie.posterUrl 
                                    : 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=1000&auto=format&fit=crop',
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter, 
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16, left: 16, right: 16,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(bannerMovie.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Text('${bannerMovie.year} | ${bannerMovie.genres.join(", ")}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                                      child: IconButton(
                                        icon: const Icon(Icons.play_arrow, color: Colors.black),
                                        onPressed: () => openPlayer(bannerMovie),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Peringkat Film', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Semua >', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: Row(
                children: [
                  _buildFilterChip('Semua', isActive: true),
                  _buildFilterChip('psycho'),
                  _buildFilterChip('fantasy'),
                  _buildFilterChip('Romance'),
                  _buildFilterChip('Horror'),
                  _buildFilterChip('DLL'),
                ],
              ),
            ),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 8, mainAxisSpacing: 16,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => openPlayer(movies[index]),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: movies[index].posterUrl, fit: BoxFit.cover, width: double.infinity,
                                errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(movies[index].title, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      Positioned(
                        top: 0, left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: index == 0 ? Colors.pink : (index == 1 ? Colors.orange : Colors.amber),
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                          ),
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuChip(String text, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _buildFilterChip(String text, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF333333) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: Colors.grey[800]!),
      ),
      child: Text(text, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 13)),
    );
  }
}
