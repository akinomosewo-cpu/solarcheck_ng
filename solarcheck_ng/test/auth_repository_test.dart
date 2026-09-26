import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:solarcheck_ng/data/auth_repository.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('solarcheck_auth_test');
    Hive.init(tempDir.path);
    await AuthRepository.instance.init();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    await AuthRepository.instance.clearAllForTesting();
  });

  group('AuthRepository', () {
    test('signUp stores the account and logs the user in', () async {
      final result = await AuthRepository.instance.signUp(
        name: 'Ada Lovelace',
        email: 'Ada@Example.com',
        password: 'secret1',
      );

      expect(result.isSuccess, isTrue);
      expect(AuthRepository.instance.isLoggedIn, isTrue);
      expect(AuthRepository.instance.currentUserEmail, 'ada@example.com');
      expect(AuthRepository.instance.currentUserName, 'Ada Lovelace');
    });

    test('signUp rejects a duplicate email', () async {
      await AuthRepository.instance.signUp(name: 'Ada', email: 'ada@example.com', password: 'secret1');
      final result = await AuthRepository.instance.signUp(name: 'Someone Else', email: 'ada@example.com', password: 'other123');

      expect(result.status, AuthResultStatus.emailAlreadyExists);
    });

    test('login succeeds with correct credentials and fails with wrong password', () async {
      await AuthRepository.instance.signUp(name: 'Bola', email: 'bola@example.com', password: 'rightpass');
      await AuthRepository.instance.logout();

      final wrong = await AuthRepository.instance.login(email: 'bola@example.com', password: 'wrongpass');
      expect(wrong.status, AuthResultStatus.invalidCredentials);
      expect(AuthRepository.instance.isLoggedIn, isFalse);

      final correct = await AuthRepository.instance.login(email: 'bola@example.com', password: 'rightpass');
      expect(correct.isSuccess, isTrue);
      expect(AuthRepository.instance.isLoggedIn, isTrue);
    });

    test('login fails for an email that was never registered', () async {
      final result = await AuthRepository.instance.login(email: 'nobody@example.com', password: 'whatever');
      expect(result.status, AuthResultStatus.notFound);
    });

    test('logout clears the session', () async {
      await AuthRepository.instance.signUp(name: 'Chidi', email: 'chidi@example.com', password: 'password1');
      expect(AuthRepository.instance.isLoggedIn, isTrue);

      await AuthRepository.instance.logout();
      expect(AuthRepository.instance.isLoggedIn, isFalse);
      expect(AuthRepository.instance.currentUserEmail, isNull);
    });

    test('passwords are stored salted and hashed, never in plain text', () async {
      const box = 'auth_users_box';
      await AuthRepository.instance.signUp(name: 'Emeka', email: 'emeka@example.com', password: 'mypassword');

      final usersBox = Hive.box(box);
      final record = Map<String, dynamic>.from(usersBox.get('emeka@example.com') as Map);
      final salt = record['salt'] as String;
      final storedHash = record['passwordHash'] as String;

      expect(storedHash, isNot(equals('mypassword')));
      expect(storedHash, equals(sha256.convert(utf8.encode('$salt:mypassword')).toString()));

      // Different accounts get different salts, so identical passwords hash differently.
      await AuthRepository.instance.signUp(name: 'Ngozi', email: 'ngozi@example.com', password: 'mypassword');
      final otherRecord = Map<String, dynamic>.from(usersBox.get('ngozi@example.com') as Map);
      expect(otherRecord['salt'], isNot(equals(salt)));
      expect(otherRecord['passwordHash'], isNot(equals(storedHash)));
    });
  });
}
