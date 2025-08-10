import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:nexi/auth/authentication/bloc/auth_bloc.dart';
import 'package:nexi/auth/authentication/bloc/auth_state.dart';
import 'package:nexi/firebase_options.dart';
import 'package:nexi/auth/screens/verify_email_screen.dart';
import 'package:nexi/auth/screens/login_screen.dart';
import 'package:nexi/auth/screens/registration_screen.dart';
import 'package:nexi/auth/screens/reset_password_screen.dart';
import 'package:nexi/ui/screens_messenger/HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dostarczamy AuthBloc do całej aplikacji, zarządzającego stanem autoryzacji
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Reagujemy na różne stany autoryzacji i wyświetlamy odpowiednie ekrany
            return state.map(
              initial: (_) => const LoginScreen(),
              loading: (_) => const Scaffold(
                  body: Center(child: CircularProgressIndicator())),
              authenticated: (s) => HomeScreen(user: s.user),
              unauthenticated: (_) => const LoginScreen(),
              error: (s) => LoginScreen(errorMessage: s.message),
              passwordResetSent: (_) => const ResetPasswordScreen(),
              emailVerificationSent: (_) {
                final user = FirebaseAuth.instance.currentUser!;
                return VerifyEmailScreen(user: user); 
              },
            );
          },
        ),
        // Definicja rout dla nawigacji
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/reset': (context) => const ResetPasswordScreen(),
        },
      ),
    );
  }
}
