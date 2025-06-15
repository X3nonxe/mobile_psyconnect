part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRefreshing extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final String token;
  final String? refreshToken;
  final int expiresIn;

  const AuthAuthenticated({
    required this.user,
    required this.token,
    required this.refreshToken,
    this.expiresIn = 3600,
  });

  @override
  List<Object> get props => [user, token];
}

class TokenRefreshed extends AuthState {
  final String token;
  final String refreshToken;
  final int expiresIn;

  const TokenRefreshed({
    required this.token,
    required this.refreshToken,
    this.expiresIn = 3600,
  });

  @override
  List<Object> get props => [token, refreshToken, expiresIn];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
