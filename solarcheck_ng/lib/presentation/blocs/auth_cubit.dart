import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? name;
  final String? email;
  final String? error;

  const AuthState({this.status = AuthStatus.unknown, this.name, this.email, this.error});

  AuthState copyWith({AuthStatus? status, String? name, String? email, String? error}) {
    return AuthState(
      status: status ?? this.status,
      name: name ?? this.name,
      email: email ?? this.email,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, name, email, error];
}

/// Drives the local-only authentication flow: checks for an existing
/// session on startup and exposes login/signup/logout backed by
/// [AuthRepository] (Hive on-device storage, no server involved).
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  AuthCubit({AuthRepository? repository}) : _repository = repository ?? AuthRepository.instance, super(const AuthState());

  void checkSession() {
    if (_repository.isLoggedIn) {
      emit(AuthState(status: AuthStatus.authenticated, name: _repository.currentUserName, email: _repository.currentUserEmail));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signUp({required String name, required String email, required String password}) async {
    final result = await _repository.signUp(name: name, email: email, password: password);
    if (result.isSuccess) {
      emit(AuthState(status: AuthStatus.authenticated, name: result.name, email: result.email));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated, error: 'An account with that email already exists'));
    }
  }

  Future<void> login({required String email, required String password}) async {
    final result = await _repository.login(email: email, password: password);
    if (result.isSuccess) {
      emit(AuthState(status: AuthStatus.authenticated, name: result.name, email: result.email));
    } else {
      final message = result.status == AuthResultStatus.notFound
          ? 'No account found for that email'
          : 'Incorrect email or password';
      emit(state.copyWith(status: AuthStatus.unauthenticated, error: message));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
