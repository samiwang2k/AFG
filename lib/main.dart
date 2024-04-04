import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'event.dart';
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

Future<void> addEvent(Event event) async {
  Map<String, dynamic> eventMap = event.toMap();
  await firestore.collection('events').add(eventMap);
}

Future<void> readPoint() async {
  await firestore.collection('points').get().then((event) {
    Map<String, dynamic> data = event.docs.last.data();
    Point pt = Point.defined(data['x'], data['y']);
    if (kDebugMode) {
      print(pt);
    }
  });
}

class FirstRoute extends StatefulWidget {
  const FirstRoute({super.key});

  @override
  FirstRouteState createState() => FirstRouteState();
}

class FirstRouteState extends State<FirstRoute> {
  TextEditingController myController = TextEditingController();
  String userInput = '';
  Point? point;
  void printUserInput() {
    if (kDebugMode) {
      print(userInput);
    }
  }

  Point? createPoint(String inputted) {
    List<String> coordinates = inputted.split(',');
    if (coordinates.length == 2) {
      double x = double.tryParse(coordinates[0]) ?? 0.0;
      double y = double.tryParse(coordinates[1]) ?? 0.0;
      Point rval = Point.defined(x, y);
      return rval;
    }
    return null;
  }

  void createEvent() {
    List<String> jevents = userInput.split(' ');
    Event event = Event(
      name: jevents[0],
      date: jevents[1],
      location: createPoint(
          jevents[2]), // Assuming createPoint can handle a default value
      hostName: jevents.last,
    );
    if (kDebugMode) {
      print(event);
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

                createEvent();
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
  ThirdRouteState createState() => ThirdRouteState();
}

class ThirdRouteState extends State<ThirdRoute> {
  final List<Container> _boxes = []; // List to store the boxes
  final Point pointy = Point();

  BoxDecoration myBoxDecoration() {
    return const BoxDecoration(
      border: Border(
        top: BorderSide(
          //                   <--- left side
          color: Color.fromARGB(255, 124, 124, 124),
          width: 200,
        ),
        bottom: BorderSide(
          //                    <--- top side
          color: Color.fromARGB(255, 124, 124, 124),
          width: 200,
        ),
      ),
    );
  }

  void _addBox() {
    setState(() {
      _boxes.add(Container(
        width: 200,
        height: 100,
        color: Colors.white,
        margin: const EdgeInsets.only(top: 20),
        decoration: myBoxDecoration(),
        child: Text('($pointy)'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: _addBox,
                child: const Text('Add Box'),
              ),
              ..._boxes, // Spread operator to add all boxes to the column
            ],
          ),
          // ignore: avoid_print
          onTap: () => {print("Card tapped.")},
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
