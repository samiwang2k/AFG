import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String hostName;

  const DetailPage(
      {super.key,
      required this.title,
      required this.date,
      required this.location,
      required this.hostName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Text(
              title,
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(location),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Host:$hostName'),
                
              ],
            ),
            const Text('Date:'),
            Text(date),
          ],
        ),
      ),
    );
  }
}