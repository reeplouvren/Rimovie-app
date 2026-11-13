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

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final data = await Supabase.instance.client.from('movies').select().order('created_at', ascending: false);
      setState(() {
        movies = (data as List).map((e) => Movie.fromJson(e)).toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> openPlayer(Movie movie) async {
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
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(backgroundColor: Color(0xFF0F0F0F), body: Center(child: CircularProgressIndicator(color: Colors.green)));

    // Ambil 1 film untuk banner utama, sisa film untuk list
    Movie? featuredMovie = movies.isNotEmpty ? movies.first : null;
    List<Movie> otherMovies = movies.length > 1 ? movies.sublist(1) : [];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Latar hitam ala Vision+
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Short TV'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Unduhan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Aku'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Bar (Logo & Search)
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
                        child: const TextField(
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Sistas',
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Mencari', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            // 2. Menu Kategori (Sedang tren, dll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildMenuChip('LIVEll', Colors.red),
                  _buildMenuChip('Sedang tren', Colors.white, isBold: true),
                  _buildMenuChip('MangoTV', Colors.orange),
                  _buildMenuChip('Film', Colors.grey),
                  _buildMenuChip('TV', Colors.grey),
                ],
              ),
            ),

            // 3. Banner Utama (Hero)
            if (featuredMovie != null)
              GestureDetector(
                onTap: () => openPlayer(featuredMovie),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: featuredMovie.posterUrl,
                      height: 220, width: double.infinity, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(height: 220, color: Colors.grey[900]),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, const Color(0xFF0F0F0F)],
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(featuredMovie.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('${featuredMovie.year} | ${featuredMovie.genres.join(", ")}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                              child: IconButton(
                                icon: const Icon(Icons.play_arrow, color: Colors.black),
                                onPressed: () => openPlayer(featuredMovie),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

            // 4. Judul Bagian
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

            // 5. Filter Kategori (Semua, K-Drama, dll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: Row(
                children: [
                  _buildFilterChip('Semua', isActive: true),
                  _buildFilterChip('Drama AI'),
                  _buildFilterChip('Indo Drama'),
                  _buildFilterChip('C-Drama'),
                  _buildFilterChip('K-Drama'),
                ],
              ),
            ),

            // 6. Grid Poster Bernomor
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 8, mainAxisSpacing: 16,
              ),
              itemCount: otherMovies.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => openPlayer(otherMovies[index]),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: otherMovies[index].posterUrl, fit: BoxFit.cover, width: double.infinity,
                                errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(otherMovies[index].title, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      // Badge Nomor Peringkat
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
