import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexi/auth/authentication/bloc/auth_bloc.dart';
import 'package:nexi/auth/authentication/bloc/auth_event.dart';
import 'package:nexi/auth/authentication/bloc/auth_state.dart';


class LoginScreen extends StatefulWidget {
  final String? errorMessage;

  const LoginScreen({super.key, this.errorMessage});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.errorMessage!), backgroundColor: Colors.red),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Minimum 6 characters' : null,
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
                      else ...[
                        ElevatedButton(
                          onPressed: _submitLogin,
                          child: const Text('Login'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Text('Sign up.'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/reset'),
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ],
                  );
                },
              ),



            ],
          ),
        ),
      ),
    );
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthEvent.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      ));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}