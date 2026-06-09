import 'package:flutter/material.dart';

/// Privacy Policy screen matching the MindMate design.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ═══════════════════════════════════════
            // HEADER
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
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
                        'Privacy Policy',
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
            ),
            
            // ═══════════════════════════════════════
            // CONTENT
            // ═══════════════════════════════════════
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'MindMate collects only the information needed to support its core features, such as tasks, productivity progress, activity logs, and basic profile details. We may also collect limited non-personal device data to help improve app performance and stability. Any files or content you add (such as notes or attachments) remain on your device unless you choose to enable cloud backup.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Your data is used solely to help you track tasks, visualize progress, generate productivity insights, and ensure the app functions properly. We do not sell, trade, or share your personal information with third parties. If MindMate uses analytics or crash reporting tools, they only receive anonymous usage data.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'You are always in control of your data. You can view, edit, or delete your tasks and records at any time. Uninstalling the app may remove all locally stored data. MindMate may request optional permissions (such as notifications or storage access), but these are not required for the main functionality.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'MindMate is not intended for children under the age of 13. We may update this Privacy Policy occasionally, and the most recent version will always be available within the app.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
