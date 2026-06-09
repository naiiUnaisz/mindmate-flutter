import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_belajar/bloc/auth/auth_bloc.dart';
import 'package:application_belajar/bloc/auth/auth_event.dart';
import 'package:application_belajar/bloc/auth/auth_state.dart';
import 'package:application_belajar/screens/auth/auth_widgets.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});
  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.newPasswordSuccess) {
          context.read<AuthBloc>().add(AuthReset());
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Password berhasil diubah. Silakan login kembali.'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
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
                const Text('Enter New Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                const SizedBox(height: 20),
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (p, c) => p.newPasswordObscure != c.newPasswordObscure,
                  builder: (context, state) {
                    return AuthTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: state.newPasswordObscure,
                      suffixIcon: IconButton(
                        icon: Icon(state.newPasswordObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF), size: 20),
                        onPressed: () => context.read<AuthBloc>().add(ToggleNewPasswordObscure()),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                const Text('Confirm New Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                const SizedBox(height: 20),
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (p, c) => p.confirmNewPasswordObscure != c.confirmNewPasswordObscure,
                  builder: (context, state) {
                    return AuthTextField(
                      controller: _confirmController,
                      hintText: 'Confirm Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: state.confirmNewPasswordObscure,
                      suffixIcon: IconButton(
                        icon: Icon(state.confirmNewPasswordObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF), size: 20),
                        onPressed: () => context.read<AuthBloc>().add(ToggleConfirmNewPasswordObscure()),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                AuthPrimaryButton(
                  text: 'Save Password',
                  onPressed: () => context.read<AuthBloc>().add(SaveNewPasswordSubmitted(
                    password: _passwordController.text,
                    confirmPassword: _confirmController.text,
                  )),
                ),
                const SizedBox(height: 32),
              ],
            )),
          )),
        ]),
      ),
    );
  }
}
