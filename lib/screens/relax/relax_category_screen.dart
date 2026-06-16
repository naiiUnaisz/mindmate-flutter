import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindmate/bloc/profile/profile_bloc.dart';
import 'package:mindmate/bloc/profile/profile_state.dart';
import 'package:mindmate/widgets/unlock_content_dialog.dart';

class RelaxCategoryScreen extends StatelessWidget {
  final String categoryTitle;
  final List<Map<String, dynamic>>? apps;

  const RelaxCategoryScreen({
    super.key,
    required this.categoryTitle,
    this.apps,
  });

  List<Map<String, dynamic>> _getCategoryData() {
    if (apps != null) return apps!;

    // Fallback dummy data jika API tidak menyediakan data kategori
    switch (categoryTitle.toLowerCase()) {
      case 'music':
        return [
          _dummyItem(
            'Spotify',
            Icons.music_note,
            'assets/images/spotify.jpg',
            const Color(0xFF1DB954),
            Colors.black,
            20,
            15,
          ),
          _dummyItem(
            'Joox',
            Icons.album,
            'assets/images/joox.jpg',
            const Color(0xFF13CA66),
            Colors.white,
            20,
            15,
          ),
          _dummyItem(
            'Youtube Music',
            Icons.play_circle_fill,
            'assets/images/youtube_music.jpg',
            Colors.white,
            const Color(0xFFFF0000),
            20,
            15,
          ),
          _dummyItem(
            'Apple Music',
            Icons.music_note,
            'assets/images/apple_music.jpg',
            const Color(0xFFFA243C),
            Colors.white,
            20,
            15,
          ),
        ];
      case 'movie':
        return [
          _dummyItem(
            'Netflix',
            Icons.movie,
            'assets/images/netflix.jpg',
            Colors.black,
            const Color(0xFFE50914),
            100,
            60,
          ),
          _dummyItem(
            'Disney+',
            Icons.add,
            'assets/images/disney.jpg',
            const Color(0xFF113CCF),
            Colors.white,
            100,
            60,
            gradient: const LinearGradient(
              colors: [Color(0xFF00154F), Color(0xFF113CCF)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          _dummyItem(
            'Iqiyi',
            Icons.play_arrow,
            'assets/images/iqiyi.jpg',
            const Color(0xFF00D150),
            Colors.white,
            100,
            60,
          ),
          _dummyItem(
            'Youtube',
            Icons.play_arrow_rounded,
            'assets/images/youtube.jpg',
            Colors.white,
            const Color(0xFFFF0000),
            100,
            60,
          ),
          _dummyItem(
            'Prime Video',
            Icons.check_circle_outline,
            'assets/images/prime_video.jpg',
            const Color(0xFF00A8E1),
            Colors.white,
            100,
            60,
          ),
          _dummyItem(
            'Viu',
            Icons.play_arrow,
            'assets/images/viu.jpg',
            const Color(0xFFFFCC00),
            Colors.white,
            100,
            60,
          ),
          _dummyItem(
            'WeTV',
            Icons.play_arrow,
            'assets/images/wetv.jpg',
            const Color(0xFF00C2FF),
            Colors.white,
            100,
            60,
          ),
          _dummyItem(
            'Vidio',
            Icons.play_arrow,
            'assets/images/vidio.jpg',
            const Color(0xFFE2002C),
            Colors.white,
            100,
            60,
          ),
        ];
      case 'game':
        return [
          _dummyItem(
            'Minecraft',
            Icons.grid_3x3,
            'assets/images/minecraft.jpg',
            const Color(0xFF5B8731),
            Colors.white,
            20,
            15,
          ),
          _dummyItem(
            'Mobile Legends',
            Icons.sports_esports,
            'assets/images/mobile_legends.jpg',
            const Color(0xFF1F2B5B),
            Colors.amber,
            20,
            15,
          ),
          _dummyItem(
            'Robbery Bob',
            Icons.directions_run,
            'assets/images/robbery_bob.jpg',
            const Color(0xFF3B82F6),
            Colors.white,
            20,
            15,
          ),
          _dummyItem(
            'Genshin',
            Icons.auto_awesome,
            'assets/images/genshin.jpg',
            Colors.white,
            const Color(0xFF3B82F6),
            20,
            15,
          ),
          _dummyItem(
            'Block Blast',
            Icons.grid_view_rounded,
            'assets/images/block_blast.jpg',
            const Color(0xFF10B981),
            Colors.yellow,
            20,
            15,
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          _dummyItem(
            'Roblox',
            Icons.crop_square_rounded,
            'assets/images/roblox.jpg',
            const Color(0xFF0055D1),
            Colors.white,
            20,
            15,
          ),
          _dummyItem(
            'Subway Surfers',
            Icons.directions_run,
            'assets/images/subway_surfers.jpg',
            const Color(0xFFFACC15),
            Colors.white,
            20,
            15,
          ),
          _dummyItem(
            'Hay Day',
            Icons.pets,
            'assets/images/hay_day.jpg',
            const Color(0xFFEAB308),
            Colors.white,
            20,
            15,
          ),
        ];
      case 'social media':
      case 'social':
        return [
          _dummyItem(
            'Tiktok',
            Icons.music_note,
            'assets/images/tiktok.jpg',
            Colors.black,
            Colors.white,
            20,
            15,
          ),
          _dummyItem(
            'Instagram',
            Icons.camera_alt,
            'assets/images/instagram.jpg',
            const Color(0xFFE1306C),
            Colors.white,
            20,
            15,
            gradient: const LinearGradient(
              colors: [Color(0xFFf9ce34), Color(0xFFee2a7b), Color(0xFF6228d7)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          _dummyItem(
            'Snapchat',
            Icons.snapchat,
            'assets/images/snapchat.jpg',
            const Color(0xFFFFFC00),
            Colors.black,
            20,
            15,
          ),
          _dummyItem(
            'Line',
            Icons.chat_bubble,
            'assets/images/line.jpg',
            const Color(0xFF00C300),
            Colors.white,
            20,
            15,
          ),
          _dummyItem(
            'Facebook',
            Icons.facebook,
            'assets/images/facebook.jpg',
            const Color(0xFF1877F2),
            Colors.white,
            20,
            15,
          ),
          _dummyItem(
            'X',
            Icons.close,
            'assets/images/x.jpg',
            Colors.black,
            Colors.white,
            20,
            15,
          ),
        ];
      default:
        return [];
    }
  }

  Map<String, dynamic> _dummyItem(
    String name,
    IconData icon,
    String imagePath,
    Color iconBg,
    Color iconColor,
    int coin,
    int time, {
    LinearGradient? gradient,
  }) {
    return {
      'name': name,
      'icon': icon,
      'imagePath': imagePath,
      'iconBg': iconBg,
      'iconColor': iconColor,
      'coin': coin,
      'time': time,
      'gradient': ?gradient,
    };
  }

  @override
  Widget build(BuildContext context) {
    final items = _getCategoryData();
    final displayTitle = categoryTitle.toLowerCase() == 'social'
        ? 'Social Media'
        : categoryTitle;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                          mainAxisSpacing: 32,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _buildGridItem(context, items[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Map<String, dynamic> item) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 32),
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
              GestureDetector(
                onTap: () async {
                  final paid = await UnlockContentDialog.show(
                    context,
                    item: item,
                  );
                  if (paid && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${item['name']} session started! Check your notifications.',
                        ),
                        backgroundColor: Colors.green.shade400,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
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
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          item['icon'],
                          color: item['iconColor'],
                          size: 32,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      item['icon'],
                      color: item['iconColor'],
                      size: 32,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
