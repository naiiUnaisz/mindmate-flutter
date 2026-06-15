import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:application_belajar/config/theme.dart';
import 'package:application_belajar/utils/theme_service.dart';
import 'package:application_belajar/networks/api_client.dart';

/// Setting screen matching the MindMate design.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyMoodReminder = false;
  bool _journalSummary = false;
  bool _isDarkMode = false;

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
      _dailyMoodReminder = prefs.getBool('${prefix}daily_mood_reminder') ?? false;
      _journalSummary = prefs.getBool('${prefix}journal_summary') ?? false;
      _isDarkMode = prefs.getBool('theme_dark') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email')?.toLowerCase();
    final prefKey = email != null ? '${email}_$key' : key;
    await prefs.setBool(prefKey, value);
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
              // ACCOUNT SECTION
              // ═══════════════════════════════════════
              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              _SettingsGroup(
                children: [
                  _SettingsItem(label: 'Change Password', onTap: () => Navigator.pushNamed(context, '/change-password'), isLast: true),
                ],
              ),
              const SizedBox(height: 24),

              // ═══════════════════════════════════════
              // APPEARANCE SECTION
              // ═══════════════════════════════════════
              const Text(
                'Appearance',
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
                    label: 'Dark Mode',
                    value: _isDarkMode,
                    onChanged: (val) {
                      setState(() => _isDarkMode = val);
                      setThemeMode(val);
                      ApiClient().updateSettings({'theme_dark': val});
                    },
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
                    label: 'Daily mood reminder',
                    value: _dailyMoodReminder,
                    onChanged: (val) {
                      setState(() => _dailyMoodReminder = val);
                      _saveSetting('daily_mood_reminder', val);
                      ApiClient().updateSettings({'daily_mood_reminder': val});
                    },
                  ),
                  _SettingsSwitchItem(
                    label: 'Journal summary',
                    value: _journalSummary,
                    onChanged: (val) {
                      setState(() => _journalSummary = val);
                      _saveSetting('journal_summary', val);
                      ApiClient().updateSettings({'journal_summary': val});
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

              // ═══════════════════════════════════════
              // BOTTOM EXTRA LIST (as in design)
              // ═══════════════════════════════════════
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _SettingsItem(label: 'Change Password', onTap: () => Navigator.pushNamed(context, '/change-password'), hasBackground: false, isLast: true),
                  ],
                ),
              ),
              
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
  final bool hasBackground;

  const _SettingsItem({
    required this.label,
    required this.onTap,
    this.isLast = false,
    this.hasBackground = true,
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
        if (!isLast && !hasBackground)
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
