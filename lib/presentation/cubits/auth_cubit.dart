import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/domain/entities/user_profile.dart';
import 'package:marcadores_mundial_app/domain/usecases/sign_up.dart';
import 'package:marcadores_mundial_app/domain/usecases/sign_in.dart';
import 'package:marcadores_mundial_app/domain/usecases/sign_out.dart';
import 'package:marcadores_mundial_app/domain/usecases/send_password_reset.dart';
import 'package:marcadores_mundial_app/domain/usecases/resend_confirmation_email.dart';
import 'package:marcadores_mundial_app/domain/usecases/check_email_confirmed.dart';
import 'package:marcadores_mundial_app/domain/usecases/get_current_profile.dart';
import 'package:marcadores_mundial_app/domain/usecases/complete_profile.dart';

enum AuthStatus { initial, guest, unconfirmed, incompleteProfile, authenticated }

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? error;
  final bool isLoading;
  final String? successMessage;
  final String? pendingEmail; // email used for signup, persisted until confirmed

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isLoading = false,
    this.successMessage,
    this.pendingEmail,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? error,
    bool? isLoading,
    String? successMessage,
    String? pendingEmail,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      pendingEmail: pendingEmail ?? this.pendingEmail,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  final SignUp _signUp;
  final SignIn _signIn;
  final SignOut _signOut;
  final SendPasswordReset _sendPasswordReset;
  final ResendConfirmationEmail _resendConfirmationEmail;
  final CheckEmailConfirmed _checkEmailConfirmed;
  final GetCurrentProfile _getCurrentProfile;
  final CompleteProfile _completeProfile;

  AuthCubit({
    required SignUp signUp,
    required SignIn signIn,
    required SignOut signOut,
    required SendPasswordReset sendPasswordReset,
    required ResendConfirmationEmail resendConfirmationEmail,
    required CheckEmailConfirmed checkEmailConfirmed,
    required GetCurrentProfile getCurrentProfile,
    required CompleteProfile completeProfile,
  })  : _signUp = signUp,
        _signIn = signIn,
        _signOut = signOut,
        _sendPasswordReset = sendPasswordReset,
        _resendConfirmationEmail = resendConfirmationEmail,
        _checkEmailConfirmed = checkEmailConfirmed,
        _getCurrentProfile = getCurrentProfile,
        _completeProfile = completeProfile,
        super(const AuthState());

  Future<void> checkSession() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final profile = await _getCurrentProfile();
      if (profile != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: profile,
          isLoading: false,
        ));
        return;
      }

      // No profile — check if there's a session at all
      if (!_signIn.repository.hasSession) {
        emit(state.copyWith(status: AuthStatus.guest, isLoading: false));
        return;
      }

      // Has session but no profile — check email confirmation
      final confirmed = await _checkEmailConfirmed();
      if (!confirmed) {
        emit(state.copyWith(status: AuthStatus.unconfirmed, isLoading: false));
        return;
      }

      emit(state.copyWith(status: AuthStatus.incompleteProfile, isLoading: false));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.guest, isLoading: false));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      await _signUp(email, password);
      // After signup the user needs to confirm email
      emit(state.copyWith(
        status: AuthStatus.unconfirmed,
        isLoading: false,
        pendingEmail: email,
        successMessage: 'Correo de verificación enviado. Revisa tu bandeja de entrada.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final user = await _signIn(email, password);
      // After sign in, determine next step
      final confirmed = await _checkEmailConfirmed();
      if (!confirmed) {
        emit(state.copyWith(
          status: AuthStatus.unconfirmed,
          user: user,
          pendingEmail: email,
          isLoading: false,
        ));
        return;
      }
      if (!user.hasCompletedProfile) {
        emit(state.copyWith(
          status: AuthStatus.incompleteProfile,
          user: user,
          isLoading: false,
        ));
        return;
      }
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> signOut() async {
    await _signOut();
    emit(const AuthState(status: AuthStatus.guest));
  }

  Future<void> sendPasswordReset(String email) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      await _sendPasswordReset(email);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Correo de recuperación enviado. Revisa tu bandeja de entrada.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> resendConfirmationEmail() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final email = state.pendingEmail ?? state.user?.email;
      if (email == null || email.isEmpty) {
        emit(state.copyWith(isLoading: false, error: 'Email no disponible'));
        return;
      }
      await _resendConfirmationEmail(email);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Correo reenviado. Revisa tu bandeja de entrada.',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> refreshStatus() async {
    final confirmed = await _checkEmailConfirmed();
    if (!confirmed) {
      emit(state.copyWith(status: AuthStatus.unconfirmed));
      return;
    }
    final profile = await _getCurrentProfile();
    if (profile == null || !profile.hasCompletedProfile) {
      emit(state.copyWith(
        status: AuthStatus.incompleteProfile,
        user: profile,
      ));
      return;
    }
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: profile,
    ));
  }

  Future<void> completeProfile({
    required String nombre,
    required String apellido,
    required String telefono,
    required int edad,
    required bool aceptaPoliticas,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final user = await _completeProfile(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        edad: edad,
        aceptaPoliticas: aceptaPoliticas,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void clearError() => emit(state.copyWith(clearError: true));
  void clearSuccess() => emit(state.copyWith(clearSuccess: true));
}
