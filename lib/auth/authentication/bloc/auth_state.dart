import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_state.freezed.dart';

//  możliwe stany
@freezed
class AuthState with _$AuthState {

  const factory AuthState.initial() = Initial;
  const factory AuthState.loading() = Loading;
  const factory AuthState.authenticated(User user) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.emailVerificationSent() = EmailVerificationSent;
  const factory AuthState.error(String message) = Error;
  const factory AuthState.passwordResetSent() = PasswordResetSent;


}