import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:psyconnect/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RefreshTokenEvent>(_onRefreshToken);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse(
            'https://psy-backend-production.up.railway.app/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': event.email, 'password': event.password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        emit(AuthAuthenticated(
            user: user,
            token: data['access_token'],
            refreshToken: data['refresh_token'],
            expiresIn: data['expires_in'] ?? 3600));
      } else {
        emit(AuthError('Login gagal: ${response.body}'));
      }
    } catch (e) {
      emit(AuthError('Terjadi kesalahan: $e'));
    }
  }

  Future<void> _onRefreshToken(
      RefreshTokenEvent event, Emitter<AuthState> emit) async {
    emit(AuthRefreshing());
    try {
      final response = await http.post(
        Uri.parse(
            'https://psy-backend-production.up.railway.app/api/v1/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': event.refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(TokenRefreshed(
            token: data['access_token'],
            refreshToken: data['refresh_token'] ?? event.refreshToken,
            expiresIn: data['expires_in'] ?? 3600));
      } else {
        emit(AuthError('Refresh token gagal'));
        emit(AuthInitial()); // Kembali ke state awal
      }
    } catch (e) {
      emit(AuthError('Refresh token error: $e'));
      emit(AuthInitial()); // Kembali ke state awal
    }
  }
}
