import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexi/auth/authentication/bloc/auth_event.dart';
import 'package:nexi/auth/authentication/bloc/auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(const AuthState.initial()) {
    // Obsługa różnych typów zdarzeń autoryzacji
    on<AuthEvent>((event, emit) async {
      await event.map(
        login: (e) => _login(emit, e.email, e.password),
        register: (e) => _register(emit, e.email, e.password, e.username),
        logout: (e) => _logout(emit),
        resetPassword: (e) => _resetPassword(emit, e.email),
        clearError: (e) {
          emit(const AuthState.initial()); // Reset błędów do stanu początkowego
          return Future.value();
        },
      );
    });
  }

  // Logowanie istniejącego użytkownika.
  Future<void> _login(Emitter<AuthState> emit, String email, String password) async {
    emit(const AuthState.loading());
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      // Wymaganie potwierdzenia adresu e-mail
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        emit(const AuthState.error('Email not verified. Please check your inbox.'));
        return;
      }

      _emitAuthenticated(emit, user);

    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(_mapAuthError(e.code)));
    }
  }

  // Rejestracja nowego użytkownika + zapis w bazie danych.
  Future<void> _register(Emitter<AuthState> emit, String email, String password, String username) async {
    emit(const AuthState.loading());
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      // Tworzymy wpis użytkownika w Realtime Database
      await FirebaseDatabase.instance.ref('users/${user!.uid}').set({
        'uid': user.uid,
        'email': user.email,
        'username': username,
        'friendIds': [],
        'createdAt': ServerValue.timestamp,
      });

      // Jeśli email niepotwierdzony — wysyłamy weryfikację
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        emit(const AuthState.emailVerificationSent());
      } else {
        _emitAuthenticated(emit, user);
      }

    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(_mapAuthError(e.code)));
    }
  }

  // Wylogowanie użytkownika.
  Future<void> _logout(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _auth.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error('Logout error.'));
    }
  }

  // Wysłanie linku resetującego hasło.
  Future<void> _resetPassword(Emitter<AuthState> emit, String email) async {
    emit(const AuthState.loading());
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(const AuthState.passwordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(_mapAuthError(e.code)));
    }
  }

  // Emituje stan zalogowanego użytkownika lub błąd.
  void _emitAuthenticated(Emitter<AuthState> emit, User? user) {
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.error('User not found.'));
    }
  }

  // Mapowanie kodów błędów Firebase na przyjazne komunikaty.
  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email': return 'Invalid email.';
      case 'user-disabled': return 'User is blocked.';
      case 'user-not-found': return 'User not found.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'Email is already in use.';
      case 'operation-not-allowed': return 'Operation denied.';
      case 'weak-password': return 'Weak password.';
      default: return 'Authentication error.';
    }
  }
}
