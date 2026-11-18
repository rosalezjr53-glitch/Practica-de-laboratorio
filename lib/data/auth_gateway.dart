import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  const AppUser({required this.id, required this.email});

  final String id;
  final String email;
}

abstract interface class AuthGateway {
  Stream<AppUser?> get userChanges;
  Future<void> signIn(String email, String password);
  Future<void> register(String email, String password);
  Future<void> signOut();
}

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;

  AppUser? _map(User? user) =>
      user == null ? null : AppUser(id: user.uid, email: user.email ?? '');

  @override
  Stream<AppUser?> get userChanges => _auth.authStateChanges().map(_map);

  @override
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

class LocalAuthGateway implements AuthGateway {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  @override
  Stream<AppUser?> get userChanges async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn(String email, String password) async {
    if (email.trim().isEmpty || password.length < 6) {
      throw ArgumentError('Revisa el correo y usa al menos 6 caracteres.');
    }
    _setUser(email);
  }

  @override
  Future<void> register(String email, String password) =>
      signIn(email, password);

  void _setUser(String email) {
    _currentUser = AppUser(id: email.trim().toLowerCase(), email: email.trim());
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}
