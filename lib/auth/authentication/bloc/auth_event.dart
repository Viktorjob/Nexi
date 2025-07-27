import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.login(String email, String password) = Login;
  const factory AuthEvent.register(String email, String password, String username) = Register;
  const factory AuthEvent.logout() = Logout;
  const factory AuthEvent.resetPassword(String email) = ResetPassword;
  const factory AuthEvent.clearError() = ClearError;

}