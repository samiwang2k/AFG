import 'package:flutter/material.dart';

// Define a StatefulWidget named RSVPPage.
class RSVPPage extends StatefulWidget {
  // Define the constructor for RSVPPage.
  // Use super.key to pass the key to the superclass constructor.
  const RSVPPage({super.key});

  // Override the createState method to return an instance of RSVPPageState.
  @override
  RSVPPageState createState() => RSVPPageState();
}

// Define the State class for RSVPPage, which extends State<RSVPPage>.
class RSVPPageState extends State<RSVPPage> {
  // Declare TextEditingController instances for the name and phone number fields.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Override the build method to describe the part of the user interface represented by the RSVPPage widget.
  @override
  Widget build(BuildContext context) {
    // Return a Scaffold widget to provide a framework for the app's visual layout.
    return Scaffold(
      // Define the AppBar widget for the Scaffold.
      appBar: AppBar(
        // Set the title of the AppBar.
        title: const Text('RSVP'),
      ),
      // Define the body of the Scaffold.
      body: Padding(
        // Add padding around the content.
        padding: const EdgeInsets.all(16.0),
        // Define the child of the Padding widget.
        child: Column(
          // Add children to the Column widget.
          children: <Widget>[
            // Add a TextFormField for name input.
            TextFormField(
              // Assign the TextEditingController to the TextFormField for name.
              controller: _nameController,
              // Define the decoration for the TextFormField.
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            // Add a TextFormField for phone number input.
            TextFormField(
              // Assign the TextEditingController to the TextFormField for phone number.
              controller: _phoneController,
              // Define the decoration for the TextFormField.
              decoration: const InputDecoration(labelText: 'Phone Number'),
              // Set the keyboardType to phone to ensure a numeric keyboard is displayed.
              keyboardType: TextInputType.phone,
            ),
            // Add an ElevatedButton to submit the form.
            ElevatedButton(
              // Define the onPressed callback for the ElevatedButton.
              onPressed: () {
                // Handle form submission here.
                // For example, you might want to validate the form and then process the input.
              },
              // Define the child widget for the ElevatedButton.
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
