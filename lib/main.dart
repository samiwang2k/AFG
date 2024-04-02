import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'point.dart';

final firestore = FirebaseFirestore.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
}

Future<void> addPoint(Point point) async {
  Map<String, dynamic> pointMap = point.toMap();
  await firestore.collection('points').add(pointMap);
}

Future<void> readPoint() async {
  await firestore.collection('points').get().then((event) {
    Map<String, dynamic> data = event.docs.last.data();
    Point pt = Point(data['x'], data['x']);
    if (kDebugMode) {
      print(pt);
    }
  });
}

class FirstRoute extends StatefulWidget {
  const FirstRoute({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FirstRouteState createState() => _FirstRouteState();
}

class _FirstRouteState extends State<FirstRoute> {
  TextEditingController myController = TextEditingController();
  String userInput = '';
  Point? point;
  void printUserInput() {
    if (kDebugMode) {
      print(userInput);
    }
  }

  void createPoint() {
    List<String> coordinates = userInput.split(',');
    if (coordinates.length == 2) {
      double x = double.tryParse(coordinates[0]) ?? 0.0;
      double y = double.tryParse(coordinates[1]) ?? 0.0;
      point = Point(x, y);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: myController,
          onChanged: (value) {
            setState(() {
              userInput = value;
            });
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromRGBO(126, 224, 129, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondRoute()),
                );
                printUserInput();
                createPoint();
                addPoint(point!);
              },
              child: const Text('Second',
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThirdRoute()),
                );
              },
              child: const Text('Third'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromRGBO(126, 224, 129, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FirstRoute()),
                );
              },
              child: const Text('First',
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThirdRoute()),
                );
                readPoint();
              },
              child: const Text('Third'),
            ),
          ],
        ),
      ),
    );
  }
}



class ThirdRoute extends StatefulWidget {
 const ThirdRoute({super.key});

 @override
 // ignore: library_private_types_in_public_api
 _ThirdRouteState createState() => _ThirdRouteState();
}

class _ThirdRouteState extends State<ThirdRoute> {
 final List<Container> _boxes = []; // List to store the boxes

 void _addBox() {
    setState(() {
      _boxes.add(Container(
        width: 200,
        height: 100,
        color: Colors.blue,
        margin: const EdgeInsets.only(top: 20),
      ));
    });
 }

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Third Route'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: _addBox,
            child: const Text('Add Box'),
          ),
          ..._boxes, // Spread operator to add all boxes to the column
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromRGBO(126, 224, 129, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const FirstRoute()),
                );
              },
              child: const Text('First!'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const SecondRoute()),
                );
              },
              child: const Text('Second'),
            ),
          ],
        ),
      ),
    );
 }
}



class Themes extends StatelessWidget {
  const Themes({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
