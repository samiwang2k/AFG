// import 'package:afg/main.dart';
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
  String email = "";
  String password = "";
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Restrict column size
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center child widgets
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  email = value;
                  return null;
                },
              ),
              const SizedBox(height: 20.0), // Add space between fields
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  password = value;
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 20.0), // Add space between fields
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center buttons
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle:
                          const TextStyle(fontSize: 16.0, color: Colors.black),
                      elevation: 0.0,
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: const BorderSide(color: Colors.black, width: 2.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0), // Double padding for longer button
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _signIn();
                      }
                    },
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(width: 20.0), // Space between buttons
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle:
                          const TextStyle(fontSize: 16.0, color: Colors.black),
                      elevation: 0.0,
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: const BorderSide(color: Colors.black, width: 2.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0), // Double padding for longer button
                    ),
                    onPressed: () {},
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
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
