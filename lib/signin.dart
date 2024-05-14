import 'package:afg/main.dart';
import 'package:flutter/material.dart';

// Defining a StatefulWidget named SignInForm.
class SignInForm extends StatefulWidget {
  // Constructor for SignInForm that takes a key as an argument.
  const SignInForm({super.key});

  // Overriding the createState method to return an instance of SignInFormState.
  @override
  SignInFormState createState() => SignInFormState();
}

// Defining the state for SignInForm.
class SignInFormState extends State<SignInForm> {
  // Creating a GlobalKey for the Form widget to validate the form.
  final _formKey = GlobalKey<FormState>();
  // Creating TextEditingController instances for email and password fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Initializing email and password variables.
  String email = "";
  String password = "";

  // Overriding the build method to return the UI for the SignInForm.
  @override
  Widget build(BuildContext context) {
    // Using Material widget to provide material design visual layout structure.
    return Material(
      // Using Form widget to create a form with validation.
      child: Form(
        // Assigning the form key to the Form widget.
        key: _formKey,
        // Padding the form to create space around the form.
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 20.0),
          // Using Column widget to arrange children vertically.
          child: Column(
            // Restricting the column size to the minimum required by its children.
            mainAxisSize: MainAxisSize.min,
            // Centering the child widgets horizontally.
            crossAxisAlignment: CrossAxisAlignment.center,
            // Defining the children of the column.
            children: [
              // Text form field for email input.
              TextFormField(
                // Assigning the email controller to the text field.
                controller: _emailController,
                // Setting the decoration for the text field.
                decoration: const InputDecoration(labelText: 'Email'),
                // Validator function for the email field.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Updating the email variable with the entered value.
                  email = value;
                  return null;
                },
              ),
              // Adding space between the email and password fields.
              const SizedBox(height: 20.0),
              // Text form field for password input.
              TextFormField(
                // Assigning the password controller to the text field.
                controller: _passwordController,
                // Setting the decoration for the text field.
                decoration: const InputDecoration(labelText: 'Password'),
                // Validator function for the password field.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  // Updating the password variable with the entered value.
                  password = value;
                  return null;
                },
                // Setting the text field to obscure the input.
                obscureText: true,
              ),
              // Adding space between the password field and the buttons.
              const SizedBox(height: 20.0),
              // Row widget to arrange the sign-in and sign-up buttons horizontally.
              Row(
                // Centering the buttons horizontally.
                mainAxisAlignment: MainAxisAlignment.center,
                // Defining the buttons.
                children: [
                  // Sign-in button.
                  ElevatedButton(
                    // Styling the button.
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
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    ),
                    // On press, validate the form and call the _signIn method.
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _signIn();
                      }
                    },
                    // Button text.
                    child: const Text('Sign In'),
                  ),
                  // Adding space between the buttons.
                  const SizedBox(width: 20.0),
                  // Sign-up button.
                  ElevatedButton(
                    // Styling the button.
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
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    ),
                    // On press, do nothing for now.
                    onPressed: () {},
                    // Button text.
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

  // Method to handle sign-in logic.
  void _signIn() async {
    // Attempting to sign in with the entered email and password.
    String? userId = await signInWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );
    // If sign-in is successful, navigate to the main content.
    if (userId != null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const FirstRoute()),
        );
      }
    } else {
      // If sign-in fails, show an error message.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in failed')),
        );
      }
    }
  }
}
