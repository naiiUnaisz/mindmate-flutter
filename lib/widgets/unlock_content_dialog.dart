import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:application_belajar/bloc/profile/profile_bloc.dart';
import 'package:application_belajar/bloc/profile/profile_event.dart';
import 'package:application_belajar/widgets/mascot_painter.dart';
import 'package:application_belajar/widgets/coin_widget.dart';

class UnlockContentDialog extends StatelessWidget {
  final String appName;
  final String description;
  final String? imagePath;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final LinearGradient? gradient;
  final int coinPrice;
  final int duration;
  final String? appUrl;
  final String? storeUrl;

  const UnlockContentDialog({
    super.key,
    required this.appName,
    required this.description,
    this.imagePath,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.gradient,
    required this.coinPrice,
    required this.duration,
    this.appUrl,
    this.storeUrl,
  });

  /// App URLs (HTTPS App Links — Android intercepts these if app is installed)
  static const Map<String, String> _appUrls = {
    'spotify': 'https://open.spotify.com',
    'joox': 'https://www.joox.com',
    'youtube music': 'https://music.youtube.com',
    'apple music': 'https://music.apple.com',
    'netflix': 'https://www.netflix.com',
    'disney+': 'https://www.disneyplus.com',
    'iqiyi': 'https://www.iq.com',
    'youtube': 'https://www.youtube.com',
    'prime video': 'https://www.primevideo.com',
    'viu': 'https://www.viu.com',
    'wetv': 'https://wetv.vip',
    'vidio': 'https://www.vidio.com',
    'tiktok': 'https://www.tiktok.com',
    'instagram': 'https://www.instagram.com',
    'snapchat': 'https://www.snapchat.com',
    'line': 'https://line.me',
    'facebook': 'https://www.facebook.com',
    'x': 'https://x.com',
    'minecraft': 'https://www.minecraft.net',
    'mobile legends': 'https://m.mobilelegends.com',
    'roblox': 'https://www.roblox.com',
    'genshin': 'https://genshin.hoyoverse.com',
    'block blast': 'https://blockblast.io',
    'subway surfers': 'https://subwaysurfers.com',
    'hay day': 'https://supercell.com/en/games/hayday',
    'robbery bob': 'https://play.google.com/store/apps/details?id=com.chillingo.robberybob.free.google',
  };

  /// Play Store URL mappings (fallback when app not installed)
  static const Map<String, String> _storeUrls = {
    'spotify': 'https://play.google.com/store/apps/details?id=com.spotify.music',
    'joox': 'https://play.google.com/store/apps/details?id=com.tencent.ibg.joox',
    'youtube music': 'https://play.google.com/store/apps/details?id=com.google.android.apps.youtube.music',
    'apple music': 'https://play.google.com/store/apps/details?id=com.apple.android.music',
    'netflix': 'https://play.google.com/store/apps/details?id=com.netflix.mediaclient',
    'disney+': 'https://play.google.com/store/apps/details?id=com.disney.disneyplus',
    'iqiyi': 'https://play.google.com/store/apps/details?id=com.iqiyi.i18n',
    'youtube': 'https://play.google.com/store/apps/details?id=com.google.android.youtube',
    'prime video': 'https://play.google.com/store/apps/details?id=com.amazon.avod.thirdpartyclient',
    'viu': 'https://play.google.com/store/apps/details?id=com.vuclip.viu',
    'wetv': 'https://play.google.com/store/apps/details?id=com.tencent.ig.video',
    'vidio': 'https://play.google.com/store/apps/details?id=com.vidio.android',
    'tiktok': 'https://play.google.com/store/apps/details?id=com.zhiliaoapp.musically',
    'instagram': 'https://play.google.com/store/apps/details?id=com.instagram.android',
    'snapchat': 'https://play.google.com/store/apps/details?id=com.snapchat.android',
    'line': 'https://play.google.com/store/apps/details?id=jp.naver.line.android',
    'facebook': 'https://play.google.com/store/apps/details?id=com.facebook.katana',
    'x': 'https://play.google.com/store/apps/details?id=com.twitter.android',
    'minecraft': 'https://play.google.com/store/apps/details?id=com.mojang.minecraftpe',
    'mobile legends': 'https://play.google.com/store/apps/details?id=com.mobile.legends',
    'roblox': 'https://play.google.com/store/apps/details?id=com.roblox.client',
    'genshin': 'https://play.google.com/store/apps/details?id=com.miHoYo.GenshinImpact',
    'block blast': 'https://play.google.com/store/apps/details?id=com.block.juggle',
    'subway surfers': 'https://play.google.com/store/apps/details?id=com.kiloo.subwaysurf',
    'hay day': 'https://play.google.com/store/apps/details?id=com.supercell.hayday',
    'robbery bob': 'https://play.google.com/store/apps/details?id=com.chillingo.robberybob.free.google',
  };

  /// Show this dialog from anywhere
  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> item,
  }) {
    final name = (item['name'] as String? ?? '').toLowerCase();
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => UnlockContentDialog(
        appName: item['name'] ?? '',
        description: item['description'] ?? _getDefaultDescription(item['name'] ?? ''),
        imagePath: item['imagePath'],
        icon: item['icon'] ?? Icons.apps,
        iconBg: item['iconBg'] ?? Colors.grey,
        iconColor: item['iconColor'] ?? Colors.white,
        gradient: item['gradient'],
        coinPrice: item['coin'] ?? 0,
        duration: item['time'] ?? 30,
        appUrl: item['appUrl'] ?? _appUrls[name],
        storeUrl: item['storeUrl'] ?? _storeUrls[name],
      ),
    );
  }

  static String _getDefaultDescription(String name) {
    switch (name.toLowerCase()) {
      case 'tiktok':
        return 'Watch trending, take a break.';
      case 'instagram':
        return 'Scroll, like, and unwind.';
      case 'spotify':
        return 'Listen to your favorite music.';
      case 'youtube':
        return 'Watch videos and relax.';
      case 'netflix':
        return 'Stream movies and shows.';
      case 'roblox':
        return 'Play and have fun.';
      case 'minecraft':
        return 'Build and explore worlds.';
      case 'mobile legends':
        return 'Battle with friends, 5v5.';
      case 'genshin':
        return 'Explore Teyvat adventure.';
      case 'block blast':
        return 'Puzzle fun, clear blocks.';
      case 'facebook':
        return 'Connect with friends.';
      case 'snapchat':
        return 'Share fun snaps.';
      case 'line':
        return 'Chat with friends.';
      case 'x':
        return 'See what\'s happening.';
      default:
        return 'Enjoy your break time.';
    }
  }

  Future<void> _launchApp(BuildContext context) async {
    // Check coin balance
    final state = context.read<ProfileBloc>().state;
    if (state.user.coins < coinPrice) {
      Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Koin tidak cukup! Selesaikan task untuk mendapatkan koin.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    // Deduct coins & close dialog
    context.read<ProfileBloc>().add(SpendCoins(amount: coinPrice));
    Navigator.pop(context);

    // 1) Try to open directly in the app (NOT browser)
    if (appUrl != null && appUrl!.isNotEmpty) {
      try {
        final launched = await launchUrl(
          Uri.parse(appUrl!),
          mode: LaunchMode.externalNonBrowserApplication,
        );
        if (launched) return; // App opened successfully!
      } catch (_) {
        // App not installed — externalNonBrowserApplication throws if no app handles it
      }
    }

    // 2) App not installed → redirect to Play Store
    if (storeUrl != null && storeUrl!.isNotEmpty) {
      try {
        await launchUrl(
          Uri.parse(storeUrl!),
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        // Store also failed
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$appName belum terinstall. Mengarahkan ke Play Store...'),
            backgroundColor: Colors.orange.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    // 3) Fallback
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$appName tidak ditemukan. Silakan install dari Play Store.'),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userCoins = context.read<ProfileBloc>().state.user.coins;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0ECFA),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top section with mascot + confetti ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0D4F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: CustomPaint(
                    painter: _ConfettiPainter(),
                  ),
                ),
                // Mascot (centered, overflows top slightly)
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: CustomPaint(
                        painter: MascotPainter(waveArm: true),
                      ),
                    ),
                  ),
                ),
                // Floating coin (top-right of mascot)
                const Positioned(
                  top: 18,
                  right: 50,
                  child: CoinWidget(size: 24),
                ),
                // Close button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Color(0xFF4B5563)),
                    ),
                  ),
                ),
              ],
            ),

            // ── Body content ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  // Title
                  const Text(
                    'Unlock this Content?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'You will unlock:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App info card with price/duration inside
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // App row
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: gradient == null ? iconBg : null,
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: imagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(imagePath!, width: 48, height: 48, fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Center(child: Icon(icon, color: iconColor, size: 24)),
                                      ),
                                    )
                                  : Center(child: Icon(icon, color: iconColor, size: 24)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(appName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                                  const SizedBox(height: 2),
                                  Text(description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF6B7280))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        const SizedBox(height: 10),
                        // Price row
                        _buildInfoRow('Price', '$coinPrice', isCoin: true),
                        const SizedBox(height: 6),
                        _buildInfoRow('Duration', '$duration minutes', isCoin: false),
                        const SizedBox(height: 6),
                        _buildInfoRow('Your coins', '$userCoins', isCoin: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Proceed text
                  const Text(
                    'Proceed with this purchase?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Pay button
                  GestureDetector(
                    onTap: () => _launchApp(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Pay $coinPrice Coins',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildInfoRow(String label, String value, {required bool isCoin}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF6B7280))),
        Row(
          children: [
            if (isCoin) ...[
              const CoinWidget(size: 16),
              const SizedBox(width: 4),
            ],
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
          ],
        ),
      ],
    );
  }
}

/// Custom painter for confetti/sparkle decorations in the dialog header
class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent layout

    // Confetti colors matching the design
    final colors = [
      const Color(0xFFFBBF24), // Gold/yellow
      const Color(0xFF7C3AED), // Purple
      const Color(0xFFF472B6), // Pink
      const Color(0xFF34D399), // Green
      const Color(0xFF60A5FA), // Blue
      const Color(0xFFFB923C), // Orange
    ];

    // Draw small rectangles (confetti pieces)
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final w = 3.0 + random.nextDouble() * 6;
      final h = 2.0 + random.nextDouble() * 4;
      final angle = random.nextDouble() * pi;
      final color = colors[random.nextInt(colors.length)];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(1),
        ),
        Paint()..color = color.withValues(alpha: 0.7),
      );
      canvas.restore();
    }

    // Draw small stars
    for (int i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = 3.0 + random.nextDouble() * 5;
      final color = colors[random.nextInt(colors.length)];

      _drawStar(canvas, Offset(x, y), starSize, color.withValues(alpha: 0.8));
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) - pi / 4;
      final outerX = center.dx + cos(angle) * size;
      final outerY = center.dy + sin(angle) * size;
      final innerAngle = angle + pi / 4;
      final innerX = center.dx + cos(innerAngle) * size * 0.35;
      final innerY = center.dy + sin(innerAngle) * size * 0.35;
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
