import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexi/auth/authentication/bloc/auth_bloc.dart';
import 'package:nexi/auth/authentication/bloc/auth_event.dart';
import 'package:nexi/auth/authentication/bloc/auth_state.dart';
import 'package:nexi/auth/screens/login_screen.dart';

class ResetPasswordSuccessScreen extends StatelessWidget {
  const ResetPasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Successful')),
      body: const Center(
        child: Text('Check your email to reset your password'),
      ),
    );
  }
}
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password reset')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Enter your email to reset your password'),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 20),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  state.mapOrNull(
                    passwordResetSent: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('An email has been sent to your inbox')),
                      );
                      Navigator.pop(context);
                    },
                    error: (s) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(s.message), backgroundColor: Colors.red),
                      );
                    },
                  );
                },
                builder: (context, state) {
                  return state.maybeMap(
                    loading: (_) => const CircularProgressIndicator(),
                    orElse: () => Column(
                      children: [
                        ElevatedButton(
                          onPressed: _resetPassword,
                          child: const Text('Reset password'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text('Back'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthEvent.resetPassword(_emailController.text.trim()));
    }
  }
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthEvent.clearError());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}