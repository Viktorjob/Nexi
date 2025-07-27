import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexi/auth/authentication/bloc/auth_bloc.dart';
import 'package:nexi/auth/authentication/bloc/auth_event.dart';
import 'package:nexi/auth/authentication/bloc/auth_state.dart';
import 'package:nexi/auth/screens/verify_email_screen.dart';


class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}


class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is EmailVerificationSent) {
          final user = FirebaseAuth.instance.currentUser!;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => VerifyEmailScreen(user: user)),
          );
        }
      },

      child: Scaffold(
      appBar: AppBar(title: const Text('Registration')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value!.isEmpty ? 'Enter username' : null,
              ),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Minimum 6 characters' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm password'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final String? errorMessage = state.maybeMap(
                    error: (s) => s.message,
                    orElse: () => null,
                  );

                  final bool isLoading = state is Loading;

                  return Column(
                    children: [
                      if (errorMessage != null)
                        Text(errorMessage, style: const TextStyle(color: Colors.red)),

                      if (isLoading)
                        const CircularProgressIndicator()
                      else...[
                        ElevatedButton(
                          onPressed: _submitRegistration,
                          child: const Text('Register'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back'),
                        ),
                      ]
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthEvent.clearError());
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthEvent.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      ));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}