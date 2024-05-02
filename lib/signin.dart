import 'package:afg/main.dart';
import 'package:flutter/material.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  SignInFormState createState() => SignInFormState();
}

class SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      // Add Material widget here
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signIn();
                }
              },
              child: const Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignUpForm()),
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() async {
    String? userId = await signInWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );
    if (userId != null) {
      if (mounted) {
        // Sign-in successful, navigate to the main content
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const FirstRoute()),
        );
      }
    } else {
      if (mounted) {
        // Sign-in failed, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in failed')),
        );
      }
    }
  }
}