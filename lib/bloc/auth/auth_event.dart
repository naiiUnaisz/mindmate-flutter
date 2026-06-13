import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// ── Toggle visibility events ──
class ToggleLoginObscure extends AuthEvent {}

class ToggleSignupObscure extends AuthEvent {}

class ToggleSignupConfirmObscure extends AuthEvent {}

class ToggleNewPasswordObscure extends AuthEvent {}

class ToggleConfirmNewPasswordObscure extends AuthEvent {}

// ── Form submission events ──
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignupSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const SignupSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, password, confirmPassword];
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String email;

  const ForgotPasswordSubmitted({required this.email});

  @override
  List<Object?> get props => [email];
}

class VerificationCodeSubmitted extends AuthEvent {
  final String code;

  const VerificationCodeSubmitted({required this.code});

  @override
  List<Object?> get props => [code];
}

class ResendCodeRequested extends AuthEvent {}

class SaveNewPasswordSubmitted extends AuthEvent {
  final String password;
  final String confirmPassword;

  const SaveNewPasswordSubmitted({
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [password, confirmPassword];
}

// ── Reset state ──
class AuthReset extends AuthEvent {}
