part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RefreshTokenEvent extends AuthEvent {
  final String refreshToken;

  const RefreshTokenEvent(this.refreshToken);

  @override
  List<Object> get props => [refreshToken];
}