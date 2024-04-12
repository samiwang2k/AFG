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
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Text('This is the detail page for $title'),
      ),
    );
  }
}
