import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindmate/config/theme.dart';
import 'package:mindmate/bloc/profile/profile_bloc.dart';
import 'package:mindmate/bloc/profile/profile_event.dart';
import 'package:mindmate/bloc/profile/profile_state.dart';
import 'package:mindmate/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  String _gender = '';
  DateTime? _dateOfBirth;

  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();

  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _initFromUser(User user) {
    if (_initialized) return;
    _initialized = true;
    _nameController = TextEditingController(text: user.name);
    _usernameController = TextEditingController(text: user.username);
    _gender = user.gender;
    _dateOfBirth = user.dateOfBirth;
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
        final bytes = await picked.readAsBytes();
        setState(() {
          _profileImageBytes = bytes;
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  /// Build avatar widget: new picked file > existing saved avatar > placeholder
  Widget _buildAvatarContent(User user) {
    // New image just picked from gallery
    if (_profileImageBytes != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              _profileImageBytes!,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
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
        ],
      );
    }

    // Existing saved avatar from user profile
    final existingAvatar = user.avatar;
    if (existingAvatar != null && existingAvatar.isNotEmpty) {
      Widget imgWidget;
      if (!existingAvatar.startsWith('http') &&
          !existingAvatar.startsWith('/')) {
        try {
          final bytes = base64Decode(existingAvatar);
          imgWidget = Image.memory(
            bytes,
            width: 110,
            height: 110,
            fit: BoxFit.cover,
          );
        } catch (_) {
          imgWidget = Image.network(
            existingAvatar,
            width: 110,
            height: 110,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _avatarPlaceholder(),
          );
        }
      } else {
        imgWidget = Image.network(
          existingAvatar,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _avatarPlaceholder(),
        );
      }
      return Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: imgWidget),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
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
        ],
      );
    }

    // No avatar yet — show placeholder
    return _avatarPlaceholder();
  }

  Widget _avatarPlaceholder() {
    return Column(
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
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    final currentUser = context.read<ProfileBloc>().state.user;

    String? avatarBase64;
    if (_profileImageBytes != null) {
      avatarBase64 = base64Encode(_profileImageBytes!);
    }

    if (!context.mounted) return;
    final updated = currentUser.copyWith(
      name: name,
      username: _usernameController.text.trim(),
      gender: _gender,
      dateOfBirth: _dateOfBirth,
      avatar: avatarBase64,
    );
    context.read<ProfileBloc>().add(UpdateUser(user: updated));

    // Wait for the update to complete before popping
    await for (final state in context.read<ProfileBloc>().stream) {
      if (state.status == ProfileStatus.updated) break;
      if (state.status == ProfileStatus.error) break;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileBloc>().state.user;
    _initFromUser(user);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
          child: Column(
            children: [
              Center(
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
                      color: const Color(0xFFE8DFFF),
                      image: _profileImageBytes != null
                          ? DecorationImage(
                              image: MemoryImage(_profileImageBytes!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _buildAvatarContent(user),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ═══════════════════════════════════════
              // NAME
              // ═══════════════════════════════════════
              _ProfileField(
                controller: _nameController,
                icon: Icons.badge_outlined,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 20),

              // ═══════════════════════════════════════
              // USERNAME
              // ═══════════════════════════════════════
              _ProfileField(
                controller: _usernameController,
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 20),

              // ═══════════════════════════════════════
              // EMAIL (read-only)
              // ═══════════════════════════════════════
              _ReadOnlyField(value: user.email, icon: Icons.shield_outlined),
              const SizedBox(height: 20),

              // ═══════════════════════════════════════
              // GENDER
              // ═══════════════════════════════════════
              _GenderField(
                value: _gender,
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 20),

              // ═══════════════════════════════════════
              // DATE OF BIRTH
              // ═══════════════════════════════════════
              _DateOfBirthField(date: _dateOfBirth, onTap: _pickDate),

              const SizedBox(height: 48),

              // ═══════════════════════════════════════
              // SAVE BUTTON
              // ═══════════════════════════════════════
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _save(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Save',
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
// GENDER DROPDOWN
// ═══════════════════════════════════════════════════════════════════════════

class _GenderField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _GenderField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: const _FieldPlaceholder(
            icon: Icons.wc_outlined,
            text: 'Select Gender',
          ),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(vertical: 14),
          icon: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.arrow_drop_down, color: Color(0xFF9CA3AF)),
          ),
          items: ['male', 'female']
              .map(
                (g) => DropdownMenuItem(
                  value: g,
                  child: Row(
                    children: [
                      const SizedBox(width: 36),
                      Text(
                        g[0].toUpperCase() + g.substring(1),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DATE OF BIRTH PICKER FIELD
// ═══════════════════════════════════════════════════════════════════════════

class _DateOfBirthField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _DateOfBirthField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.cake_outlined,
                size: 22,
                color: Color(0xFF7C3AED),
              ),
            ),
            Text(
              date != null
                  ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}'
                  : 'Date of Birth',
              style: TextStyle(
                fontSize: 15,
                color: date != null
                    ? const Color(0xFF374151)
                    : const Color(0xFFD1D5DB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PLACEHOLDER WIDGET (for dropdown hint)
// ═══════════════════════════════════════════════════════════════════════════

class _FieldPlaceholder extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FieldPlaceholder({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 14),
        Text(
          text,
          style: const TextStyle(fontSize: 15, color: Color(0xFFD1D5DB)),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROFILE INPUT FIELD (icon + text + underline)
// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// READ-ONLY FIELD (for email)
// ═══════════════════════════════════════════════════════════════════════════

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final IconData icon;

  const _ReadOnlyField({required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(icon, size: 22, color: const Color(0xFF9CA3AF)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;

  const _ProfileField({
    required this.controller,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 22,
        ),
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
