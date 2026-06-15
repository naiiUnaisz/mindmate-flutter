import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_belajar/bloc/auth/auth_bloc.dart';
import 'package:application_belajar/bloc/auth/auth_event.dart';
import 'package:application_belajar/bloc/auth/auth_state.dart';
import 'package:application_belajar/screens/auth/auth_widgets.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});
  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _codes = List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _codes) { c.dispose(); }
    super.dispose();
  }

  String get _fullCode => _codes.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.verificationSuccess) {
          context.read<AuthBloc>().add(AuthReset());
          Navigator.pushNamed(context, '/new-password');
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
          context.read<AuthBloc>().add(AuthReset());
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FBF9),
        body: Stack(children: [
          const AuthBackgroundBlobs(),
          SafeArea(child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20))),
                  const Expanded(child: Text('Verification', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)))),
                  const SizedBox(width: 36),
                ]),
                const SizedBox(height: 48),
                const Text('Enter Verification Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                const SizedBox(height: 28),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) {
                  return Container(width: 56, height: 56, margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5)),
                    child: Center(child: TextField(
                      controller: _codes[i], textAlign: TextAlign.center, keyboardType: TextInputType.number, maxLength: 1,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(counterText: '', border: InputBorder.none, contentPadding: EdgeInsets.zero),
                      onChanged: (v) { if (v.isNotEmpty && i < 3) {
                        FocusScope.of(context).nextFocus();
                      } else if (v.isEmpty && i > 0) { FocusScope.of(context).previousFocus(); } },
                    )),
                  );
                })),
                const SizedBox(height: 20),
                Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("If you didn't receive a code, ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF6B7280))),
                  GestureDetector(
                    onTap: () {
                      context.read<AuthBloc>().add(ResendCodeRequested());
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Kode verifikasi baru telah dikirim'), backgroundColor: Colors.green.shade400, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                    },
                    child: const Text('Resend', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7C3AED), decoration: TextDecoration.underline, decorationColor: Color(0xFF7C3AED))),
                  ),
                ])),
                const SizedBox(height: 32),
                AuthPrimaryButton(text: 'Next', onPressed: () => context.read<AuthBloc>().add(VerificationCodeSubmitted(code: _fullCode))),
                const SizedBox(height: 32),
                const AuthOrDivider(),
                const SizedBox(height: 24),
                AuthSocialRow(),
                const SizedBox(height: 48),
                const Center(child: Text("Don't have an account ?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF6B7280)))),
                const SizedBox(height: 16),
                AuthOutlinedButton(text: 'Sign Up', onPressed: () => Navigator.pushNamed(context, '/signup')),
                const SizedBox(height: 32),
              ],
            )),
          )),
        ]),
      ),
    );
  }
}
