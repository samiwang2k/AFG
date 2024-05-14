import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  // Constructor for MyApp that takes a key as an argument.
  const MyApp({super.key});

  // Overriding the build method to return the UI for the MyApp.
  @override
  Widget build(BuildContext context) {
    // Defining the app title.
    const String appTitle = 'Flutter layout demo';
    // Returning a MaterialApp widget with the app title and home set to a Scaffold.
    return MaterialApp(
      // Setting the title of the app.
      title: appTitle,
      // Setting the home of the app to a Scaffold widget.
      home: Scaffold(
        // Setting the AppBar of the Scaffold with the app title.
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        // Setting the body of the Scaffold to a SingleChildScrollView to enable scrolling.
        body: SingleChildScrollView(
          // Adding padding around the content.
          padding: const EdgeInsets.all(12),
          // Defining the children of the Column widget.
          child: Column(children: [
            // Calling the buildCard method with an argument of 1.
            buildCard(1),
            // Adding space between the cards.
            const SizedBox(height: 12),
            // Calling the buildCard method with an argument of 2.
            buildCard(2),
            // Adding space between the cards.
            const SizedBox(height: 12),
            // Calling the buildCard method with an argument of 3.
            buildCard(3),
            // Adding space between the cards.
            const SizedBox(height: 12),
            // Calling the buildCard method with an argument of 4.
            buildCard(4),
            // Adding space between the cards.
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  // Method to build a Card widget with a listWidget.
  Widget buildCard(int i) => Card(
        // Setting the child of the Card to the result of the listWidget method.
        child: listWidget(
          const Text('test'),
        ),
      );

  // Placeholder method for listWidget that currently does nothing.
  listWidget(Text text) {}
}
