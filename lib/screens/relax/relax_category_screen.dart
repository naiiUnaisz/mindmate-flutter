import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_belajar/bloc/profile/profile_bloc.dart';
import 'package:application_belajar/bloc/profile/profile_state.dart';
import 'package:application_belajar/widgets/unlock_content_dialog.dart';

class RelaxCategoryScreen extends StatelessWidget {
  final String categoryTitle;

  const RelaxCategoryScreen({super.key, required this.categoryTitle});

  List<Map<String, dynamic>> _getCategoryData() {
    switch (categoryTitle.toLowerCase()) {
      case 'music':
        return [
          {
            'name': 'Spotify',
            'icon': Icons.music_note,
            'imagePath': 'assets/images/spotify.jpg',
            'iconBg': const Color(0xFF1DB954),
            'iconColor': Colors.black,
            'coin': 30,
            'time': 30,
          },
          {
            'name': 'Joox',
            'icon': Icons.album,
            'imagePath': 'assets/images/joox.jpg',
            'iconBg': const Color(0xFF13CA66),
            'iconColor': Colors.white,
            'coin': 30,
            'time': 30,
          },
          {
            'name': 'Youtube Music',
            'icon': Icons.play_circle_fill,
            'imagePath': 'assets/images/youtube_music.jpg',
            'iconBg': Colors.white,
            'iconColor': const Color(0xFFFF0000),
            'coin': 30,
            'time': 30,
          },
          {
            'name': 'Apple Music',
            'icon': Icons.music_note,
            'imagePath': 'assets/images/apple_music.jpg',
            'iconBg': const Color(0xFFFA243C),
            'iconColor': Colors.white,
            'coin': 30,
            'time': 30,
          },
        ];
      case 'movie':
        return [
          {
            'name': 'Netflix',
            'icon': Icons.movie,
            'imagePath': 'assets/images/netflix.jpg',
            'iconBg': Colors.black,
            'iconColor': const Color(0xFFE50914),
            'coin': 20,
            'time': 30,
          },
          {
            'name': 'Disney+',
            'icon': Icons.add,
            'imagePath': 'assets/images/disney.jpg',
            'iconBg': const Color(0xFF113CCF),
            'iconColor': Colors.white,
            'gradient': const LinearGradient(
              colors: [Color(0xFF00154F), Color(0xFF113CCF)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            'coin': 20,
            'time': 30,
          },
          {
            'name': 'Iqiyi',
            'icon': Icons.play_arrow,
            'imagePath': 'assets/images/iqiyi.jpg',
            'iconBg': const Color(0xFF00D150),
            'iconColor': Colors.white,
            'coin': 20,
            'time': 30,
          },
          {
            'name': 'Youtube',
            'icon': Icons.play_arrow_rounded,
            'imagePath': 'assets/images/youtube.jpg',
            'iconBg': Colors.white,
            'iconColor': const Color(0xFFFF0000),
            'coin': 20,
            'time': 30,
          },
          {
            'name': 'Prime Video',
            'icon': Icons.check_circle_outline,
            'imagePath': 'assets/images/prime_video.jpg',
            'iconBg': const Color(0xFF00A8E1),
            'iconColor': Colors.white,
            'coin': 20,
            'time': 30,
          },
          {
            'name': 'Viu',
            'icon': Icons.play_arrow,
            'imagePath': 'assets/images/viu.jpg',
            'iconBg': const Color(0xFFFFCC00),
            'iconColor': Colors.white,
            'coin': 20,
            'time': 30,
          },
          {
            'name': 'WeTV',
            'icon': Icons.play_arrow,
            'imagePath': 'assets/images/wetv.jpg',
            'iconBg': const Color(0xFF00C2FF),
            'iconColor': Colors.white,
            'coin': 20,
            'time': 30,
          },
          {
            'name': 'Vidio',
            'icon': Icons.play_arrow,
            'imagePath': 'assets/images/vidio.jpg',
            'iconBg': const Color(0xFFE2002C),
            'iconColor': Colors.white,
            'coin': 20,
            'time': 30,
          },
        ];
      case 'game':
        return [
          {
            'name': 'Minecraft',
            'icon': Icons.grid_3x3,
            'imagePath': 'assets/images/minecraft.jpg',
            'iconBg': const Color(0xFF5B8731),
            'iconColor': Colors.white,
            'coin': 30,
            'time': 30,
          },
          {
            'name': 'Mobile Legends',
            'icon': Icons.sports_esports,
            'imagePath': 'assets/images/mobile_legends.jpg',
            'iconBg': const Color(0xFF1F2B5B),
            'iconColor': Colors.amber,
            'coin': 30,
            'time': 30,
          },
          {
            'name': 'Robbery Bob',
            'icon': Icons.directions_run,
            'imagePath': 'assets/images/robbery_bob.jpg',
            'iconBg': const Color(0xFF3B82F6),
            'iconColor': Colors.white,
            'coin': 30,
            'time': 30,
          },
          {
            'name': 'Genshin',
            'icon': Icons.auto_awesome,
            'imagePath': 'assets/images/genshin.jpg',
            'iconBg': Colors.white,
            'iconColor': const Color(0xFF3B82F6),
            'coin': 30,
            'time': 30,
          },
          {
            'name': 'Block Blast',
            'icon': Icons.grid_view_rounded,
            'imagePath': 'assets/images/block_blast.jpg',
            'iconBg': const Color(0xFF10B981),
            'iconColor': Colors.yellow,
            'gradient': const LinearGradient(
              colors: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            'coin': 30,
            'time': 30,
          },
          {
            'name': 'Roblox',
            'icon': Icons.crop_square_rounded,
            'imagePath': 'assets/images/roblox.jpg',
            'iconBg': const Color(0xFF0055D1),
            'iconColor': Colors.white,
            'coin': 30,
            'time': 30,
          },
          {
            'name': 'Subway Surfers',
            'icon': Icons.directions_run,
            'imagePath': 'assets/images/subway_surfers.jpg',
            'iconBg': const Color(0xFFFACC15),
            'iconColor': Colors.white,
            'coin': 30,
            'time': 30,
          },
          {
            'name': 'Hay Day',
            'icon': Icons.pets,
            'imagePath': 'assets/images/hay_day.jpg',
            'iconBg': const Color(0xFFEAB308),
            'iconColor': Colors.white,
            'coin': 30,
            'time': 30,
          },
        ];
      case 'social media':
      case 'social':
        return [
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
            'coin': 20,
            'time': 30,
            'gradient': const LinearGradient(
              colors: [Color(0xFFf9ce34), Color(0xFFee2a7b), Color(0xFF6228d7)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          },
          {
            'name': 'Snapchat',
            'icon': Icons.snapchat,
            'imagePath': 'assets/images/snapchat.jpg',
            'iconBg': const Color(0xFFFFFC00),
            'iconColor': Colors.black,
            'coin': 20,
            'time': 30,
          },
          {
            'name': 'Line',
            'icon': Icons.chat_bubble,
            'imagePath': 'assets/images/line.jpg',
            'iconBg': const Color(0xFF00C300),
            'iconColor': Colors.white,
            'coin': 20,
            'time': 30,
          },
          {
            'name': 'Facebook',
            'icon': Icons.facebook,
            'imagePath': 'assets/images/facebook.jpg',
            'iconBg': const Color(0xFF1877F2),
            'iconColor': Colors.white,
            'coin': 20,
            'time': 30,
          },
          {
            'name': 'X',
            'icon': Icons.close,
            'imagePath': 'assets/images/x.jpg',
            'iconBg': Colors.black,
            'iconColor': Colors.white,
            'coin': 20,
            'time': 30,
          },
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _getCategoryData();
    // The actual title might be just 'Social' in the menu, but we want 'Social Media'
    final displayTitle = categoryTitle.toLowerCase() == 'social'
        ? 'Social Media'
        : categoryTitle;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1F2937),
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      displayTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  // Placeholder to balance the row for centering
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Grid
            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 24,
                          mainAxisSpacing:
                              32, // Increased spacing for the overlapping icon
                          childAspectRatio:
                              0.75, // Adjust ratio for the tall cards
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildGridItem(context, items[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Background Card
        Container(
          margin: const EdgeInsets.only(
            top: 32,
          ), // Space for the overlapping icon
          padding: const EdgeInsets.only(
            top: 48,
            bottom: 20,
            left: 12,
            right: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item['name'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    '${item['coin']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Clock
                  const Icon(
                    Icons.schedule,
                    size: 14,
                    color: Color(0xFF1F2937),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item['time']} m',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Buy Button
              GestureDetector(
                onTap: () {
                  UnlockContentDialog.show(context, item: item);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED), // Purple
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
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
        ),
        // Overlapping Icon
        Positioned(
          top: 0,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: item['gradient'] == null ? item['iconBg'] : null,
              gradient: item['gradient'],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: item['imagePath'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      item['imagePath'],
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(item['icon'], color: item['iconColor'], size: 32),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(item['icon'], color: item['iconColor'], size: 32),
                  ),
          ),
        ),
      ],
    );
  }
}
