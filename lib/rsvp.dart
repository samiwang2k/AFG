import 'package:flutter/material.dart';

class RSVPPage extends StatefulWidget {
  const RSVPPage({super.key});

  @override
  RSVPPageState createState() => RSVPPageState();
}

class RSVPPageState extends State<RSVPPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSVP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            ElevatedButton(
              onPressed: () {
                // Handle submission
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
