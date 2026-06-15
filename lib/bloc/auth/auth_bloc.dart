import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindmate/bloc/auth/auth_event.dart';
import 'package:mindmate/bloc/auth/auth_state.dart';
import 'package:mindmate/networks/api_client.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient _client = ApiClient();

  AuthBloc() : super(const AuthState()) {
    on<ToggleLoginObscure>(_onToggleLoginObscure);
    on<ToggleSignupObscure>(_onToggleSignupObscure);
    on<ToggleSignupConfirmObscure>(_onToggleSignupConfirmObscure);
    on<ToggleNewPasswordObscure>(_onToggleNewPasswordObscure);
    on<ToggleConfirmNewPasswordObscure>(_onToggleConfirmNewPasswordObscure);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<VerificationCodeSubmitted>(_onVerificationCodeSubmitted);
    on<ResendCodeRequested>(_onResendCodeRequested);
    on<SaveNewPasswordSubmitted>(_onSaveNewPasswordSubmitted);
    on<AuthReset>(_onAuthReset);
  }

  void _onToggleLoginObscure(ToggleLoginObscure event, Emitter<AuthState> emit) {
    emit(state.copyWith(loginObscure: !state.loginObscure, status: AuthStatus.initial));
  }

  void _onToggleSignupObscure(ToggleSignupObscure event, Emitter<AuthState> emit) {
    emit(state.copyWith(signupObscure: !state.signupObscure, status: AuthStatus.initial));
  }

  void _onToggleSignupConfirmObscure(ToggleSignupConfirmObscure event, Emitter<AuthState> emit) {
    emit(state.copyWith(signupConfirmObscure: !state.signupConfirmObscure, status: AuthStatus.initial));
  }

  void _onToggleNewPasswordObscure(ToggleNewPasswordObscure event, Emitter<AuthState> emit) {
    emit(state.copyWith(newPasswordObscure: !state.newPasswordObscure, status: AuthStatus.initial));
  }

  void _onToggleConfirmNewPasswordObscure(ToggleConfirmNewPasswordObscure event, Emitter<AuthState> emit) {
    emit(state.copyWith(confirmNewPasswordObscure: !state.confirmNewPasswordObscure, status: AuthStatus.initial));
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    if (event.email.trim().isEmpty || event.password.trim().isEmpty) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Please fill all fields'));
      return;
    }
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final res = await _client.login(event.email.trim(), event.password);
      if (res['status'] == 200) {
        emit(state.copyWith(status: AuthStatus.loginSuccess));
      } else {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: res['message']?.toString() ?? 'Login failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Network error occurred'));
    }
  }

  Future<void> _onSignupSubmitted(SignupSubmitted event, Emitter<AuthState> emit) async {
    if (event.name.trim().isEmpty || event.email.trim().isEmpty || event.password.trim().isEmpty || event.confirmPassword.trim().isEmpty) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Please fill all fields'));
      return;
    }
    if (event.password != event.confirmPassword) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Passwords do not match'));
      return;
    }
    if (event.name.trim().isEmpty) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Please enter your name'));
      return;
    }
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final res = await _client.register(event.name.trim(), event.email.trim(), event.password);
      if (res['status'] == 201) {
        emit(state.copyWith(status: AuthStatus.signupSuccess));
      } else {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: res['message']?.toString() ?? 'Registration failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Network error occurred'));
    }
  }

  Future<void> _onForgotPasswordSubmitted(ForgotPasswordSubmitted event, Emitter<AuthState> emit) async {
    if (event.email.trim().isEmpty) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Please enter your email'));
      return;
    }
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final res = await _client.forgotPassword(event.email.trim());
      if (res['status'] == 200) {
        emit(state.copyWith(status: AuthStatus.forgotPasswordSuccess, email: event.email.trim()));
      } else {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: res['message']?.toString() ?? 'Failed to send code',
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Network error occurred'));
    }
  }

  Future<void> _onVerificationCodeSubmitted(VerificationCodeSubmitted event, Emitter<AuthState> emit) async {
    if (event.code.length < 4) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Enter the 4-digit verification code'));
      return;
    }
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final res = await _client.verifyCode(event.code);
      if (res['status'] == 200) {
        emit(state.copyWith(status: AuthStatus.verificationSuccess));
      } else {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: res['message']?.toString() ?? 'Verification code is incorrect',
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Network error occurred'));
    }
  }

  Future<void> _onResendCodeRequested(ResendCodeRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final email = state.email ?? '';
      await _client.forgotPassword(email);
      emit(state.copyWith(status: AuthStatus.initial));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.initial));
    }
  }

  Future<void> _onSaveNewPasswordSubmitted(SaveNewPasswordSubmitted event, Emitter<AuthState> emit) async {
    if (event.password.trim().isEmpty || event.confirmPassword.trim().isEmpty) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Please fill all fields'));
      return;
    }
    if (event.password != event.confirmPassword) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Passwords do not match'));
      return;
    }
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final res = await _client.resetPassword(event.password, event.confirmPassword);
      if (res['status'] == 200) {
        emit(state.copyWith(status: AuthStatus.newPasswordSuccess));
      } else {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: res['message']?.toString() ?? 'Failed to change password',
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Network error occurred'));
    }
  }

  void _onAuthReset(AuthReset event, Emitter<AuthState> emit) {
    emit(const AuthState());
  }
}
