import '../../models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  final String? message;
  Unauthenticated({this.message});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class PasswordResetEmailSent extends AuthState {
  final String email;
  PasswordResetEmailSent(this.email);
}
