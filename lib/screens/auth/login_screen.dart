import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:application_belajar/bloc/auth/auth_bloc.dart';
import 'package:application_belajar/bloc/auth/auth_event.dart';
import 'package:application_belajar/bloc/auth/auth_state.dart';
import 'package:application_belajar/screens/auth/auth_widgets.dart';
import 'package:application_belajar/bloc/task/task_bloc.dart';
import 'package:application_belajar/bloc/task/task_event.dart';
import 'package:application_belajar/bloc/profile/profile_bloc.dart';
import 'package:application_belajar/bloc/profile/profile_event.dart';
import 'package:application_belajar/bloc/mood/mood_bloc.dart';
import 'package:application_belajar/bloc/mood/mood_event.dart';
import 'package:application_belajar/networks/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final String email = googleUser.email;
      final String name = googleUser.displayName ?? email.split('@').first;

      // Try login first
      final res = await ApiClient().login(email, 'google_auth_${email.hashCode}');
      if (res['status'] == 200) {
        if (!context.mounted) return;
        _emailController.text = email;
        _loginSuccess(context, email);
        return;
      }

      // If login fails, register with Google account
      final regRes = await ApiClient().register(name, email, 'google_auth_${email.hashCode}');
      if (regRes['status'] == 201) {
        if (!context.mounted) return;
        _emailController.text = email;
        _loginSuccess(context, email);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(regRes['message']?.toString() ?? 'Google Sign-In gagal'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In gagal. Periksa koneksi internet Anda.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loginSuccess(BuildContext context, String email) async {
    context.read<AuthBloc>().add(AuthReset());
    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;
    await prefs.setString('current_user_email', email);
    if (!context.mounted) return;
    context.read<MoodBloc>().add(LoadMoodHistory());
    context.read<TaskBloc>().add(LoadTasks());
    context.read<ProfileBloc>().add(LoadProfile());
    Navigator.of(context).pushNamedAndRemoveUntil('/main', (_) => false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state.status == AuthStatus.loginSuccess) {
          context.read<AuthBloc>().add(AuthReset());
          final email = _emailController.text;
          final prefs = await SharedPreferences.getInstance();
          if (!context.mounted) return;
          await prefs.setString('current_user_email', email);
          if (!context.mounted) return;
          context.read<MoodBloc>().add(LoadMoodHistory());
          context.read<TaskBloc>().add(LoadTasks());
          context.read<ProfileBloc>().add(LoadProfile());
          Navigator.of(context).pushNamedAndRemoveUntil('/main', (_) => false);
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
                      const SizedBox(height: 48),

                      // ── Welcome title ──
                      const Text(
                        'Welcome 👋',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Log in to continue to your account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 36),

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
                        buildWhen: (prev, curr) => prev.loginObscure != curr.loginObscure,
                        builder: (context, state) {
                          return AuthTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: state.loginObscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.loginObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF9CA3AF),
                                size: 20,
                              ),
                              onPressed: () => context.read<AuthBloc>().add(ToggleLoginObscure()),
                            ),
                          );
                        },
                      ),

                      // ── Forgot Password ──
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Log In button ──
                      BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (p, c) => p.status != c.status,
                        builder: (context, state) {
                          return AuthPrimaryButton(
                            text: state.status == AuthStatus.loading ? 'Loading...' : 'Log In',
                            onPressed: state.status == AuthStatus.loading ? null : () {
                              context.read<AuthBloc>().add(LoginSubmitted(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ));
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // ── Or Login with divider ──
                      const AuthOrDivider(),

                      const SizedBox(height: 24),

                      // ── Social login buttons ──
                      AuthSocialRow(
                        onGoogleTap: () => _handleGoogleSignIn(context),
                      ),

                      const SizedBox(height: 36),

                      // ── Don't have an account? Sign Up ──
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account ? ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/signup'),
                              child: const Text(
                                'Sign Up',
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
