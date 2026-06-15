import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindmate/bloc/profile/profile_bloc.dart';
import 'package:mindmate/bloc/profile/profile_event.dart';
import 'package:mindmate/networks/api_client.dart';
import 'package:mindmate/utils/notification_helper.dart';

class AbsenDialog extends StatelessWidget {
  final String appName;
  final int? sessionId;

  const AbsenDialog({
    super.key,
    required this.appName,
    this.sessionId,
  });

  static Future<void> show(
    BuildContext context, {
    required String appName,
    int? sessionId,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AbsenDialog(appName: appName, sessionId: sessionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8DFFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Session Complete!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have finished your $appName session.\nTime to get back to work!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await NotificationHelper.cancelRelaxReminder();
                    final res = await ApiClient().completeAppSession();
                    if (context.mounted) {
                      if (res['status'] == 200) {
                        final data = res['data'];
                        if (data is Map<String, dynamic> && data['status'] == 'fined') {
                          final fineAmount = data['fine_amount'] ?? 0;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('You were late! Deducted $fineAmount coins as penalty.'),
                              backgroundColor: Colors.orange.shade400,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Great! No penalty for being on time.'),
                              backgroundColor: Colors.green.shade400,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                        context.read<ProfileBloc>().add(LoadProfile());
                      }
                    }
                  } catch (_) {}
                  if (context.mounted) Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Absen & Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
