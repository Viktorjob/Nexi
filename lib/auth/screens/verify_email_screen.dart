import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexi/ui/screens_messenger/HomeScreen.dart';


class VerifyEmailScreen extends StatefulWidget {
  final User user;

  const VerifyEmailScreen({required this.user, Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late Timer _timer; // Timer sprawdzający co kilka sekund status weryfikacji
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instancja Firebase Auth

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck(); // Uruchamiamy cykliczne sprawdzanie
  }

  // Funkcja uruchamia timer, który co 5 sekund odświeża dane użytkownika
  // i sprawdza, czy adres e-mail został zweryfikowany
  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _auth.currentUser?.reload(); // Odświeżenie danych z Firebase
      final isVerified = _auth.currentUser?.emailVerified ?? false;
      print('Checking email verification: $isVerified');

      if (isVerified) {
        timer.cancel(); // Zatrzymanie timera
        if (mounted) { // Sprawdzenie, czy widget nadal jest w drzewie
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(user: _auth.currentUser!),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Zatrzymanie timera po opuszczeniu ekranu
    super.dispose(); // Wywołanie sprzątania z klasy bazowej
  }

  // Funkcja wysyła ponownie e-mail weryfikacyjny
  void _resendEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email has been resent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending email: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: const Text("Confirm your email"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "A confirmation email has been sent to your inbox. Please check it",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Przycisk do ponownego wysłania maila
            ElevatedButton(
              onPressed: _resendEmail,
              child: const Text("Resend"),
            ),
          ],
        ),
      ),
    );
  }
}
