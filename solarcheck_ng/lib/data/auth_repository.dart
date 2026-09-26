import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Result of an authentication attempt.
enum AuthResultStatus { success, invalidCredentials, emailAlreadyExists, notFound }

class AuthResult {
  final AuthResultStatus status;
  final String? name;
  final String? email;
  const AuthResult(this.status, {this.name, this.email});
  bool get isSuccess => status == AuthResultStatus.success;
}

/// Local-only authentication store backed by Hive. There is no backend for
/// this app, so credentials (name, email, salted password hash) live in a
/// Hive box on-device, and a separate "session" box tracks whether the
/// current device is logged in so returning users can skip straight to the
/// dashboard.
class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  static const _usersBoxName = 'auth_users_box';
  static const _sessionBoxName = 'auth_session_box';

  Box? _usersBox;
  Box? _sessionBox;

  /// Must be called once, after [Hive.initFlutter], before any other method.
  Future<void> init() async {
    _usersBox = await Hive.openBox(_usersBoxName);
    _sessionBox = await Hive.openBox(_sessionBoxName);
  }

  Box get _users => _usersBox ?? (throw StateError('AuthRepository.init() has not been called'));
  Box get _session => _sessionBox ?? (throw StateError('AuthRepository.init() has not been called'));

  static String _hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  /// Whether a user is currently logged in on this device.
  bool get isLoggedIn => _session.get('loggedInEmail') != null;

  /// The logged-in user's display name, if any.
  String? get currentUserName => _session.get('loggedInName') as String?;

  /// The logged-in user's email, if any.
  String? get currentUserEmail => _session.get('loggedInEmail') as String?;

  /// Registers a new local account. Fails with [AuthResultStatus.emailAlreadyExists]
  /// if the email is already registered.
  Future<AuthResult> signUp({required String name, required String email, required String password}) async {
    final normalizedEmail = _normalizeEmail(email);
    if (_users.containsKey(normalizedEmail)) {
      return const AuthResult(AuthResultStatus.emailAlreadyExists);
    }
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    await _users.put(normalizedEmail, {
      'name': name.trim(),
      'email': normalizedEmail,
      'salt': salt,
      'passwordHash': _hash(password, salt),
    });
    await _setSession(name: name.trim(), email: normalizedEmail);
    return AuthResult(AuthResultStatus.success, name: name.trim(), email: normalizedEmail);
  }

  /// Validates credentials against the locally stored account.
  Future<AuthResult> login({required String email, required String password}) async {
    final normalizedEmail = _normalizeEmail(email);
    final record = _users.get(normalizedEmail);
    if (record == null) {
      return const AuthResult(AuthResultStatus.notFound);
    }
    final map = Map<String, dynamic>.from(record as Map);
    final expectedHash = map['passwordHash'] as String;
    final salt = map['salt'] as String;
    if (_hash(password, salt) != expectedHash) {
      return const AuthResult(AuthResultStatus.invalidCredentials);
    }
    final name = map['name'] as String;
    await _setSession(name: name, email: normalizedEmail);
    return AuthResult(AuthResultStatus.success, name: name, email: normalizedEmail);
  }

  Future<void> _setSession({required String name, required String email}) async {
    await _session.put('loggedInEmail', email);
    await _session.put('loggedInName', name);
  }

  Future<void> logout() async {
    await _session.delete('loggedInEmail');
    await _session.delete('loggedInName');
  }

  /// Test-only helper to reset stored state between tests.
  Future<void> clearAllForTesting() async {
    await _users.clear();
    await _session.clear();
  }
}
