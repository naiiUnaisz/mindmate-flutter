import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindmate/bloc/auth/auth_bloc.dart';
import 'package:mindmate/bloc/auth/auth_event.dart';
import 'package:mindmate/bloc/auth/auth_state.dart';
import 'package:mindmate/screens/auth/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.forgotPasswordSuccess) {
          context.read<AuthBloc>().add(AuthReset());
          Navigator.pushNamed(context, '/verification');
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<AuthBloc>().add(AuthReset());
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FBF9),
        body: Stack(
          children: [
            const AuthBackgroundBlobs(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── App Bar ──
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF1F2937),
                                size: 20,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Forgot Password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          const SizedBox(width: 36),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // ── Subtitle ──
                      const Text(
                        'Enter Email Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Email field ──
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'Email Addres',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16),

                      // ── Back to Sign In ──
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Back to Sign In',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Send to Email button ──
                      AuthPrimaryButton(
                        text: 'Send to Email',
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                ForgotPasswordSubmitted(email: _emailController.text),
                              );
                        },
                      ),

                      const SizedBox(height: 48),

                      // ── Don't have an account? + Sign Up button ──
                      const Center(
                        child: Text(
                          "Don't have an account ?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      AuthOutlinedButton(
                        text: 'Sign Up',
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
