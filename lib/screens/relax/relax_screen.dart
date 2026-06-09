import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_belajar/bloc/profile/profile_bloc.dart';
import 'package:application_belajar/bloc/profile/profile_state.dart';
import 'package:application_belajar/screens/relax/relax_category_screen.dart';
import 'package:application_belajar/widgets/unlock_content_dialog.dart';

class RelaxScreen extends StatefulWidget {
  const RelaxScreen({super.key});

  @override
  State<RelaxScreen> createState() => _RelaxScreenState();
}

class _RelaxScreenState extends State<RelaxScreen> {
  @override
  Widget build(BuildContext context) {
    // Dummy data for top picks
    final List<Map<String, dynamic>> topPicks = [
      {
        'name': 'Tiktok',
        'icon': Icons.music_note,
        'imagePath': 'assets/images/tiktok.jpg',
        'iconBg': Colors.black,
        'iconColor': Colors.white,
        'coin': 30,
        'time': 30,
      },
      {
        'name': 'Instagram',
        'icon': Icons.camera_alt,
        'imagePath': 'assets/images/instagram.jpg',
        'iconBg': const Color(0xFFE1306C),
        'iconColor': Colors.white,
        'coin': 30,
        'time': 30,
        'gradient': const LinearGradient(
          colors: [Color(0xFFf9ce34), Color(0xFFee2a7b), Color(0xFF6228d7)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      },
      {
        'name': 'Spotify',
        'icon': Icons.music_note, // Approximate
        'imagePath': 'assets/images/spotify.jpg',
        'iconBg': const Color(0xFF1DB954),
        'iconColor': Colors.black,
        'coin': 30,
        'time': 30,
      },
      {
        'name': 'Roblox',
        'icon': Icons.crop_square_rounded,
        'imagePath': 'assets/images/roblox.jpg',
        'iconBg': const Color(0xFF0055D1), // approximate
        'iconColor': Colors.white,
        'coin': 30,
        'time': 30,
      },
      {
        'name': 'Youtube',
        'icon': Icons.play_arrow_rounded,
        'imagePath': 'assets/images/youtube.jpg',
        'iconBg': Colors.white,
        'iconColor': const Color(0xFFFF0000),
        'coin': 30,
        'time': 30,
      },
      {
        'name': 'Block Blast',
        'icon': Icons.grid_view_rounded,
        'imagePath': 'assets/images/block_blast.jpg',
        'iconBg': const Color(0xFF10B981), // approximate colorful
        'iconColor': Colors.yellow,
        'coin': 30,
        'time': 30,
        'gradient': const LinearGradient(
          colors: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                24,
                20,
                24,
                120,
              ), // Bottom padding for navbar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Center(
                    child: Text(
                      'Relax',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Coin',
                          value: '${state.user.coins} Coin',
                          valueColor: const Color(0xFFFBBF24), // Yellow
                          iconWidget: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBBF24),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Current Streak',
                          value: '${state.user.streak} Day',
                          valueColor: const Color(0xFFEF4444), // Red
                          iconWidget: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2), // Light red bg
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.local_fire_department_rounded,
                                size: 16,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Categories Title
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categories Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryItem(
                        context,
                        icon: Icons.music_note_outlined,
                        label: 'Music',
                      ),
                      _buildCategoryItem(
                        context,
                        icon: Icons.movie_outlined,
                        label: 'Movie',
                      ),
                      _buildCategoryItem(
                        context,
                        icon: Icons.sports_esports_outlined,
                        label: 'Game',
                      ),
                      _buildCategoryItem(
                        context,
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Social',
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Top Picks Title
                  const Text(
                    'Top Picks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Top Picks List
                  Column(
                    children: List.generate(topPicks.length, (index) {
                      return _buildTopPickItem(
                        context,
                        topPicks[index],
                        state,
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color valueColor,
    required Widget iconWidget,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, {required IconData icon, required String label}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RelaxCategoryScreen(categoryTitle: label),
          ),
        );
      },
      child: Container(
        width: 76,
        height: 86,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
        ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: const Color(0xFF1F2937)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTopPickItem(
    BuildContext context,
    Map<String, dynamic> pick,
    ProfileState state,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // App Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: pick['gradient'] == null ? pick['iconBg'] : null,
              gradient: pick['gradient'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: pick['imagePath'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      pick['imagePath'],
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(pick['icon'], color: pick['iconColor'], size: 28),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(pick['icon'], color: pick['iconColor'], size: 28),
                  ),
          ),
          const SizedBox(width: 16),
          // App Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pick['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Coin
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBBF24),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${pick['coin']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Clock
                    const Icon(
                      Icons.schedule,
                      size: 14,
                      color: Color(0xFF1F2937),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${pick['time']} m',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Buy Button
          GestureDetector(
            onTap: () {
              UnlockContentDialog.show(context, item: pick);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED), // Purple
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Buy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
