import 'package:flutter/material.dart';

class RSVPPage extends StatefulWidget {
  @override
  _RSVPPageState createState() => _RSVPPageState();
}

class _RSVPPageState extends State<RSVPPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RSVP'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            ElevatedButton(
              onPressed: () {
                // Handle submission
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
