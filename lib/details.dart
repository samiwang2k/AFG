import 'package:afg/jevent.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
 final Jevent title;

 DetailPage({Key? key, required this.title}) : super(key: key);

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title.name!),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Text('This is the detail page for $title'),
      ),
    );
 }
}
