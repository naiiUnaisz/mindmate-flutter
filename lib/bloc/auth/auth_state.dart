import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading,
  loginSuccess,
  signupSuccess,
  forgotPasswordSuccess,
  verificationSuccess,
  newPasswordSuccess,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String errorMessage;
  final String? email;

  // ── Obscure toggles ──
  final bool loginObscure;
  final bool signupObscure;
  final bool signupConfirmObscure;
  final bool newPasswordObscure;
  final bool confirmNewPasswordObscure;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage = '',
    this.email,
    this.loginObscure = true,
    this.signupObscure = true,
    this.signupConfirmObscure = true,
    this.newPasswordObscure = true,
    this.confirmNewPasswordObscure = true,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? email,
    bool clearEmail = false,
    bool? loginObscure,
    bool? signupObscure,
    bool? signupConfirmObscure,
    bool? newPasswordObscure,
    bool? confirmNewPasswordObscure,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      email: clearEmail ? null : email ?? this.email,
      loginObscure: loginObscure ?? this.loginObscure,
      signupObscure: signupObscure ?? this.signupObscure,
      signupConfirmObscure: signupConfirmObscure ?? this.signupConfirmObscure,
      newPasswordObscure: newPasswordObscure ?? this.newPasswordObscure,
      confirmNewPasswordObscure:
          confirmNewPasswordObscure ?? this.confirmNewPasswordObscure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        email,
        loginObscure,
        signupObscure,
        signupConfirmObscure,
        newPasswordObscure,
        confirmNewPasswordObscure,
      ];
}
