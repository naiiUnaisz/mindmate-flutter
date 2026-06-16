import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindmate/bloc/auth/auth_bloc.dart';
import 'package:mindmate/bloc/auth/auth_event.dart';
import 'package:mindmate/bloc/auth/auth_state.dart';
import 'package:mindmate/screens/auth/auth_widgets.dart';
import 'package:mindmate/bloc/task/task_bloc.dart';
import 'package:mindmate/bloc/task/task_event.dart';
import 'package:mindmate/bloc/profile/profile_bloc.dart';
import 'package:mindmate/bloc/profile/profile_event.dart';
import 'package:mindmate/bloc/mood/mood_bloc.dart';
import 'package:mindmate/bloc/mood/mood_event.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _signupHandled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state.status == AuthStatus.signupSuccess && !_signupHandled) {
          _signupHandled = true;

          final email = _emailController.text.trim();
          final prefs = await SharedPreferences.getInstance();
          if (!context.mounted) return;
          await prefs.setString('current_user_email', email.toLowerCase());
          if (!context.mounted) return;

          context.read<MoodBloc>().add(LoadMoodHistory());
          context.read<TaskBloc>().add(LoadTasks());
          context.read<ProfileBloc>().add(LoadProfile());

          context.read<AuthBloc>().add(AuthReset());

          Navigator.of(context).pushNamedAndRemoveUntil('/main', (_) => false);
        } else if (state.status == AuthStatus.failure) {
          _signupHandled = false;
          if (!mounted) return;
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
                      const SizedBox(height: 48),

                      // ── Title ──
                      const Text(
                        'Create Your Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please enter your email account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Username field ──
                      AuthTextField(
                        controller: _nameController,
                        hintText: 'Username',
                        prefixIcon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.text,
                      ),

                      const SizedBox(height: 18),

                      // ── Email field ──
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'Email Addres',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 18),

                      // ── Password field ──
                      BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (prev, curr) => prev.signupObscure != curr.signupObscure,
                        builder: (context, state) {
                          return AuthTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: state.signupObscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.signupObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF9CA3AF),
                                size: 20,
                              ),
                              onPressed: () => context.read<AuthBloc>().add(ToggleSignupObscure()),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // ── Confirm Password field ──
                      BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (prev, curr) => prev.signupConfirmObscure != curr.signupConfirmObscure,
                        builder: (context, state) {
                          return AuthTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm Password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: state.signupConfirmObscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.signupConfirmObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF9CA3AF),
                                size: 20,
                              ),
                              onPressed: () => context.read<AuthBloc>().add(ToggleSignupConfirmObscure()),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // ── Sign Up button ──
                      BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (p, c) => p.status != c.status,
                        builder: (context, state) {
                          return AuthPrimaryButton(
                            text: state.status == AuthStatus.loading ? 'Loading...' : 'Sign Up',
                            onPressed: state.status == AuthStatus.loading ? null : () {
                              context.read<AuthBloc>().add(SignupSubmitted(
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    confirmPassword: _confirmPasswordController.text,
                                  ));
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 36),

                      // ── Already have an account? Log In ──
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account ? ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7C3AED),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF7C3AED),
                                ),
                              ),
                            ),
                          ],
                        ),
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
