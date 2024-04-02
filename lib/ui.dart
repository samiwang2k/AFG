import 'package:flutter/material.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Flutter layout demo';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
            buildCard(1),
            const SizedBox(height: 12),
            buildCard(2),
            const SizedBox(height: 12),
            buildCard(3),
            const SizedBox(height: 12),
            buildCard(4),
            const SizedBox(height: 12),
          ]
          )
        ),
      ),
    );
  }

  Widget buildCard(int i) => Card(
    child: listWidget(
      Text('test'),
    )
  );




  listWidget(Text text) {}}