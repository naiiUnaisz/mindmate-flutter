import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:application_belajar/config/theme.dart';

/// Edit Profile screen matching the MindMate design.
///
/// - Square (rounded corners) avatar that can be tapped to pick a photo
/// - 4 input fields with left icons + underline borders
/// - "Continue" outlined purple button
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'An yujin');
  final _usernameController = TextEditingController(text: '@yujinhere');
  final _emailController = TextEditingController(text: 'anyujin@gmail.com');
  final _passwordController = TextEditingController(text: '12345678');

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _profileImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open gallery. Please restart the app.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
          child: Column(
            children: [
              // ═══════════════════════════════════════
              // TITLE
              // ═══════════════════════════════════════
              const Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ═══════════════════════════════════════
              // SQUARE AVATAR (tap to pick photo)
              // ═══════════════════════════════════════
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      color: const Color(0xFFF3E8FF),
                      image: _profileImage != null
                          ? DecorationImage(
                              image: FileImage(_profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profileImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ═══════════════════════════════════════
              // FORM FIELDS
              // ═══════════════════════════════════════

              _ProfileField(
                controller: _nameController,
                icon: Icons.badge_outlined,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 20),

              _ProfileField(
                controller: _usernameController,
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 20),

              _ProfileField(
                controller: _emailController,
                icon: Icons.shield_outlined,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 20),

              _ProfileField(
                controller: _passwordController,
                icon: Icons.lock_outline_rounded,
                iconColor: AppColors.primary,
                obscureText: true,
              ),

              const SizedBox(height: 48),

              // ═══════════════════════════════════════
              // CONTINUE BUTTON
              // ═══════════════════════════════════════
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROFILE INPUT FIELD (icon + text + underline)
// ═══════════════════════════════════════════════════════════════════════════

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final bool obscureText;

  const _ProfileField({
    required this.controller,
    required this.icon,
    required this.iconColor,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Color(0xFF374151),
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 22),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
