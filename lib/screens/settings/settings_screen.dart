import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindmate/config/theme.dart';
import 'package:mindmate/networks/api_client.dart';
import 'package:mindmate/utils/notification_helper.dart';

/// Setting screen matching the MindMate design.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _breakReminder = false;
  bool _streakReminder = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email')?.toLowerCase();
    final prefix = email != null ? '${email}_' : '';
    setState(() {
      _breakReminder = prefs.getBool('${prefix}break_reminder') ?? false;
      _streakReminder = prefs.getBool('${prefix}streak_reminder') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email')?.toLowerCase();
    final prefKey = email != null ? '${email}_$key' : key;
    await prefs.setBool(prefKey, value);

    // Sync to backend
    ApiClient().updateSettings({'settings': {key: value}});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════
              // HEADER
              // ═══════════════════════════════════════
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 28,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Setting',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28), // Balance for center alignment
                ],
              ),
              const SizedBox(height: 32),

              // ═══════════════════════════════════════
              // NOTIFICATION SECTION
              // ═══════════════════════════════════════
              const Text(
                'Notification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsGroup(
                children: [
                  _SettingsSwitchItem(
                    label: 'Break Reminder',
                    value: _breakReminder,
                    onChanged: (val) {
                      setState(() => _breakReminder = val);
                      _saveSetting('break_reminder', val);
                      if (val) {
                        NotificationHelper.scheduleBreakReminder();
                      } else {
                        NotificationHelper.cancelBreakReminder();
                      }
                    },
                  ),
                  _SettingsSwitchItem(
                    label: 'Streak Reminder',
                    value: _streakReminder,
                    onChanged: (val) {
                      setState(() => _streakReminder = val);
                      _saveSetting('streak_reminder', val);
                      if (val) {
                        NotificationHelper.scheduleStreakReminder();
                      } else {
                        NotificationHelper.cancelStreakReminder();
                      }
                    },
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ═══════════════════════════════════════
              // ABOUT SECTION
              // ═══════════════════════════════════════
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsGroup(
                children: [
                  _SettingsItem(label: 'Privacy Policy', onTap: () => Navigator.pushNamed(context, '/privacy-policy')),
                  _SettingsItem(label: 'Application Version', onTap: () => Navigator.pushNamed(context, '/app-version'), isLast: true),
                ],
              ),
              const SizedBox(height: 32),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _SettingsItem({
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF374151), // Darker chevron as in design
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Color(0xFFF3F4F6)),
          ),
      ],
    );
  }
}

class _SettingsSwitchItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _SettingsSwitchItem({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(!value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    // Purple-ish track color when off, darker purple when on
                    color: value 
                        ? AppColors.primary.withValues(alpha: 0.8) 
                        : const Color(0xFF9CA3AF).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
