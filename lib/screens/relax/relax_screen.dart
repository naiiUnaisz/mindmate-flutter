import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindmate/bloc/profile/profile_bloc.dart';
import 'package:mindmate/bloc/profile/profile_state.dart';
import 'package:mindmate/screens/relax/relax_category_screen.dart';
import 'package:mindmate/widgets/unlock_content_dialog.dart';
import 'package:mindmate/widgets/absen_dialog.dart';
import 'package:mindmate/networks/api_client.dart';
import 'package:mindmate/utils/notification_helper.dart';

class RelaxScreen extends StatefulWidget {
  const RelaxScreen({super.key});

  @override
  State<RelaxScreen> createState() => _RelaxScreenState();
}

class _RelaxScreenState extends State<RelaxScreen> {
  List<Map<String, dynamic>> _allApps = [];

  @override
  void initState() {
    super.initState();
    _loadApps();
    _checkActiveSession();
  }

  Future<void> _checkActiveSession() async {
    try {
      final res = await ApiClient().getActiveSession();
      if (res['status'] == 200 && res['data'] != null) {
        final sessionData = res['data'];
        if (sessionData is Map<String, dynamic>) {
          final expiredAt = sessionData['expired_at'] as String?;
          final appName = sessionData['app_name'] as String? ?? 'Entertainment';
          final sessionId = sessionData['session_id'];
          if (expiredAt != null) {
            final expiry = DateTime.tryParse(expiredAt);
            if (expiry != null) {
              if (DateTime.now().isAfter(expiry)) {
                // Session expired - show absen dialog
                if (mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      AbsenDialog.show(context, appName: appName, sessionId: sessionId);
                    }
                  });
                }
              } else {
                // Session still active - schedule reminder if not already scheduled
                NotificationHelper.scheduleRelaxReminder(
                  appName: appName,
                  expiresAt: expiry,
                  minutesBeforeExpiry: 2,
                );
              }
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _loadApps() async {
    try {
      final res = await ApiClient().getApps();
      if (res['status'] == 200 && res['apps'] != null) {
        final apps = (res['apps'] as List).cast<Map<String, dynamic>>();
        if (mounted) {
          setState(() {
            _allApps = apps.map((a) => _mapApp(a)).toList();
          });
        }
      }
    } catch (_) {}
  }

  Map<String, dynamic> _mapApp(Map<String, dynamic> app) {
    return {
      'id': app['id'],
      'name': app['name'] ?? '',
      'icon': Icons.apps,
      'imagePath': app['icon'] ?? '',
      'iconBg': const Color(0xFF7C3AED),
      'iconColor': Colors.white,
      'coin': app['coin_cost'] ?? 30,
      'time': app['duration'] ?? 30,
      'category': (app['category'] ?? '').toString().toLowerCase(),
    };
  }

  List<Map<String, dynamic>> get _topPicks =>
      _allApps.isNotEmpty ? _allApps : _defaultTopPicks();

  List<Map<String, dynamic>> _appsByCategory(String category) {
    if (_allApps.isNotEmpty) {
      return _allApps
          .where((a) => (a['category'] as String) == category.toLowerCase())
          .toList();
    }
    return [];
  }

  List<Map<String, dynamic>> _defaultTopPicks() {
    return [
      {
        'name': 'Tiktok',
        'icon': Icons.music_note,
        'imagePath': 'assets/images/tiktok.jpg',
        'iconBg': Colors.black,
        'iconColor': Colors.white,
        'coin': 20,
        'time': 15,
        'category': 'social_media',
      },
      {
        'name': 'Instagram',
        'icon': Icons.camera_alt,
        'imagePath': 'assets/images/instagram.jpg',
        'iconBg': const Color(0xFFE1306C),
        'iconColor': Colors.white,
        'coin': 20,
        'time': 15,
        'gradient': const LinearGradient(
          colors: [Color(0xFFf9ce34), Color(0xFFee2a7b), Color(0xFF6228d7)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        'category': 'social_media',
      },
      {
        'name': 'Spotify',
        'icon': Icons.music_note,
        'imagePath': 'assets/images/spotify.jpg',
        'iconBg': const Color(0xFF1DB954),
        'iconColor': Colors.black,
        'coin': 20,
        'time': 15,
        'category': 'music',
      },
      {
        'name': 'Roblox',
        'icon': Icons.crop_square_rounded,
        'imagePath': 'assets/images/roblox.jpg',
        'iconBg': const Color(0xFF0055D1),
        'iconColor': Colors.white,
        'coin': 20,
        'time': 15,
        'category': 'game',
      },
      {
        'name': 'Youtube',
        'icon': Icons.play_arrow_rounded,
        'imagePath': 'assets/images/youtube.jpg',
        'iconBg': Colors.white,
        'iconColor': Color(0xFFFF0000),
        'coin': 100,
        'time': 60,
        'category': 'movie',
      },
      {
        'name': 'Block Blast',
        'icon': Icons.grid_view_rounded,
        'imagePath': 'assets/images/block_blast.jpg',
        'iconBg': const Color(0xFF10B981),
        'iconColor': Colors.yellow,
        'coin': 20,
        'time': 15,
        'gradient': const LinearGradient(
          colors: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'category': 'game',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          valueColor: const Color(0xFFFBBF24),
                          iconWidget: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBBF24),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.star, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Current Streak',
                          value: '${state.user.streak} Day',
                          valueColor: const Color(0xFFEF4444),
                          iconWidget: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFEF4444)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Categories
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryItem(context, icon: Icons.music_note_outlined, label: 'Music', category: 'music'),
                      _buildCategoryItem(context, icon: Icons.movie_outlined, label: 'Movie', category: 'movie'),
                      _buildCategoryItem(context, icon: Icons.sports_esports_outlined, label: 'Game', category: 'game'),
                      _buildCategoryItem(context, icon: Icons.chat_bubble_outline_rounded, label: 'Social', category: 'social_media'),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Top Picks
                  const Text(
                    'Top Picks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Column(
                    children: List.generate(_topPicks.length, (index) {
                      return _buildTopPickItem(context, _topPicks[index], state);
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
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: valueColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, {required IconData icon, required String label, required String category}) {
    return GestureDetector(
      onTap: () {
        final apps = _appsByCategory(category);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RelaxCategoryScreen(
              categoryTitle: label,
              apps: apps.isNotEmpty ? apps : null,
            ),
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
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPickItem(BuildContext context, Map<String, dynamic> pick, ProfileState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
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
                      width: 48, height: 48, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Center(child: Icon(pick['icon'], color: pick['iconColor'], size: 28)),
                    ),
                  )
                : Center(child: Icon(pick['icon'], color: pick['iconColor'], size: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pick['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 14, height: 14,
                      decoration: const BoxDecoration(color: Color(0xFFFBBF24), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('${pick['coin']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule, size: 14, color: Color(0xFF1F2937)),
                    const SizedBox(width: 4),
                    Text('${pick['time']} m', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final paid = await UnlockContentDialog.show(context, item: pick);
              if (paid && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${pick['name']} session started! Check your notifications.'),
                    backgroundColor: Colors.green.shade400,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Buy', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
