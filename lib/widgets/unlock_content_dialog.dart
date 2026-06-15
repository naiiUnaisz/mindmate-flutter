import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mindmate/bloc/profile/profile_bloc.dart';
import 'package:mindmate/bloc/profile/profile_event.dart';
import 'package:mindmate/networks/api_client.dart';
import 'package:mindmate/utils/notification_helper.dart';
import 'package:mindmate/widgets/coin_widget.dart';

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
  final int? appId;
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
    this.appId,
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

  /// Android package names for direct app launch (no browser redirect)
  static const Map<String, String> _androidPackages = {
    'spotify': 'com.spotify.music',
    'joox': 'com.tencent.ibg.joox',
    'youtube music': 'com.google.android.apps.youtube.music',
    'apple music': 'com.apple.android.music',
    'netflix': 'com.netflix.mediaclient',
    'disney+': 'com.disney.disneyplus',
    'iqiyi': 'com.iqiyi.i18n',
    'youtube': 'com.google.android.youtube',
    'prime video': 'com.amazon.avod.thirdpartyclient',
    'viu': 'com.vuclip.viu',
    'wetv': 'com.tencent.ig.video',
    'vidio': 'com.vidio.android',
    'tiktok': 'com.zhiliaoapp.musically',
    'instagram': 'com.instagram.android',
    'snapchat': 'com.snapchat.android',
    'line': 'jp.naver.line.android',
    'facebook': 'com.facebook.katana',
    'x': 'com.twitter.android',
    'minecraft': 'com.mojang.minecraftpe',
    'mobile legends': 'com.mobile.legends',
    'roblox': 'com.roblox.client',
    'genshin': 'com.miHoYo.GenshinImpact',
    'block blast': 'com.block.juggle',
    'subway surfers': 'com.kiloo.subwaysurf',
    'hay day': 'com.supercell.hayday',
    'robbery bob': 'com.chillingo.robberybob.free.google',
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

  /// Show this dialog from anywhere. Returns true if the user paid.
  static Future<bool> show(
    BuildContext context, {
    required Map<String, dynamic> item,
  }) async {
    final name = (item['name'] as String? ?? '').toLowerCase();
    final result = await showDialog<bool>(
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
        appId: item['id'],
        appUrl: item['appUrl'] ?? _appUrls[name],
        storeUrl: item['storeUrl'] ?? _storeUrls[name],
      ),
    );
    return result ?? false;
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
            content: const Text('Not enough coins! Complete tasks to earn more coins.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    if (appId != null) {
      final purchaseRes = await ApiClient().purchaseApp(appId!);
      if (purchaseRes['status'] != 200 && purchaseRes['status'] != 201) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(purchaseRes['message'] ?? 'Failed to purchase app'),
              backgroundColor: Colors.red.shade400,
            ),
          );
        }
        return;
      }
      
      final startRes = await ApiClient().startRelaxSession(appId!, duration);
      if (startRes['status'] != 200 && startRes['status'] != 201) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(startRes['message'] ?? 'Failed to start session'),
              backgroundColor: Colors.red.shade400,
            ),
          );
        }
        return;
      }
      // Re-fetch profile to update coins
      if (context.mounted) {
        context.read<ProfileBloc>().add(LoadProfile());
      }

      // Schedule relax session reminder (2 min before expiry)
      final expiredAt = startRes['data']?['expired_at'] as String?;
      if (expiredAt != null) {
        final expiry = DateTime.tryParse(expiredAt);
        if (expiry != null) {
          NotificationHelper.scheduleRelaxReminder(
            appName: appName,
            expiresAt: expiry,
            minutesBeforeExpiry: 2,
          );
        }
      }
    } else {
      // Deduct coins & close dialog with success result
      context.read<ProfileBloc>().add(SpendCoins(amount: coinPrice));
    }
    
    if (context.mounted) Navigator.pop(context, true);

    final nameLower = appName.toLowerCase();

    // 1) Try to open directly in the native app using Android package name
    final packageName = _androidPackages[nameLower];
    if (packageName != null) {
      try {
        final launched = await launchUrl(
          Uri.parse('https://$nameLower.com'),
          mode: LaunchMode.externalNonBrowserApplication,
        );
        if (launched) return;
      } catch (_) {}
      // Fallback: try intent:// scheme with package name
      try {
        final intentUri = Uri.parse(
          'intent://package/$packageName#Intent;package=$packageName;end',
        );
        final launched = await launchUrl(intentUri, mode: LaunchMode.externalNonBrowserApplication);
        if (launched) return;
      } catch (_) {}
    }

    // 2) Try app URL directly (some apps register HTTPS deep links)
    if (appUrl != null && appUrl!.isNotEmpty) {
      try {
        final launched = await launchUrl(
          Uri.parse(appUrl!),
          mode: LaunchMode.externalNonBrowserApplication,
        );
        if (launched) return;
      } catch (_) {}
    }

    // 3) App not installed → redirect to Play Store
    if (storeUrl != null && storeUrl!.isNotEmpty) {
      try {
        await launchUrl(
          Uri.parse(storeUrl!),
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {}
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$appName is not installed. Redirecting to Play Store...'),
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
          content: Text('$appName not found. Please install from the Play Store.'),
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
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main card — exact size: 333x342, top: 74px
          Container(
            margin: const EdgeInsets.only(top: 74),
            width: 333,
            height: 342,
            decoration: BoxDecoration(
              color: const Color(0xFFE8DFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                // Close button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Color(0xFF4B5563)),
                    ),
                  ),
                ),
                // ── Body content ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                    children: [
                      const Text(
                        'Unlock this Content?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'You will unlock:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // App info card
                      Container(
                        width: 225,
                        padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
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
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(appName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                                      const SizedBox(height: 2),
                                      Text(description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF6B7280))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 1, color: Color(0xFFF3F4F6)),
                            const SizedBox(height: 8),
                            _buildInfoRow('Price', '$coinPrice', isCoin: true),
                            const SizedBox(height: 4),
                            _buildInfoRow('Duration', '$duration minutes', isCoin: false),
                            const SizedBox(height: 4),
                            _buildInfoRow('Your coins', '$userCoins', isCoin: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Proceed with this purchase?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7658B2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _launchApp(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7658B2),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7658B2).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'Pay $coinPrice Coins',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ],
            ),
          ),

          // Mascot — protrudes from top of card
          Positioned(
            top: 0,
            child: Image.asset(
              'assets/maskot/unlockkonten.png',
              width: 152,
              height: 106,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_not_supported_outlined,
                size: 60,
                color: Color(0xFF7C3AED),
              ),
            ),
          ),
        ],
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
