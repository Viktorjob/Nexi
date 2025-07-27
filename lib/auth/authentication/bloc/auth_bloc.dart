import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexi/auth/authentication/bloc/auth_event.dart';
import 'package:nexi/auth/authentication/bloc/auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.map(
        login: (e) => _login(emit, e.email, e.password),
        register: (e) => _register(emit, e.email, e.password, e.username),
        logout: (e) => _logout(emit),
        resetPassword: (e) => _resetPassword(emit, e.email),
        clearError: (e) {
          emit(const AuthState.initial());
          return Future.value();
        },
      );
    });
  }

  Future<void> _login(Emitter<AuthState> emit, String email, String password) async {
    emit(const AuthState.loading());
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

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


  Future<void> _register(Emitter<AuthState> emit, String email, String password, String username) async {
    emit(const AuthState.loading());
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      // Сохраняем профиль в Realtime Database
      await FirebaseDatabase.instance.ref('users/${user!.uid}').set({
        'uid': user.uid,
        'email': user.email,
        'username': username,
        'friendIds': [],   // массив в realtime db тоже поддерживается
        'createdAt': ServerValue.timestamp,
      });

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

  Future<void> _logout(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      await _auth.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error('Logout error.'));
    }
  }


  Future<void> _resetPassword(Emitter<AuthState> emit, String email) async {
    emit(const AuthState.loading());
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(const AuthState.passwordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(_mapAuthError(e.code)));
    }
  }


  void _emitAuthenticated(Emitter<AuthState> emit, User? user) {
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.error('User not found.'));
    }
  }



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