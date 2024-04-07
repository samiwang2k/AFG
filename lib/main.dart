// ignore_for_file: library_private_types_in_public_api

import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

import 'event.dart';
import 'point.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'event.dart';
import 'firebase_options.dart';
//import 'point.dart';
import 'package:firebase_auth/firebase_auth.dart';
final firestore = FirebaseFirestore.instance;


Future<String?> signInWithEmailPassword(String email, String password) async {
 try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // The user is signed in, return the user ID
    return userCredential.user?.uid;
 } on FirebaseAuthException catch (e) {
    // Handle sign-in errors
    print(e.message);
    return null;
 }
}

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
 );

 // Check if the user is already signed in
 final user = FirebaseAuth.instance.currentUser;
 if (user != null) {
    // User is already signed in, navigate to the main content
    runApp(const MaterialApp(
      title: 'AFG',
      home: FirstRoute(),
    ));
 } else {
    // User is not signed in, show the SignInForm
    runApp(MaterialApp(
      title: 'AFG',
      home: SignInForm(),
    ));
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

String createEvent(String textyInput) {
  List<String> jevents = textyInput.split('#');
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
  return event.toString();
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

void nav() => runApp(MaterialApp(
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.ltr, child: child!);
      },
      title: 'GNav',
      theme: ThemeData(
        primaryColor: Colors.grey[800],
      ),
      home: const FirstRoute(),
    ));

class FirstRoute extends StatefulWidget {
  const FirstRoute({super.key});

  @override
  _FirstRouteState createState() => _FirstRouteState();
}

class _FirstRouteState extends State<FirstRoute> {
  String? please = 'press to work(please)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: LineIcons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: LineIcons.search,
                  text: 'Search',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
                ),
              ],
              selectedIndex: 0,
              onTabChange: (index) {
                switch (index) {
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SecondRoute()),
                    );

                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ThirdRoute()),
                    );
                    break;
                  default:
                    break;
                }
              },
            ),
          ),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: LineIcons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: LineIcons.search,
                  text: 'Search',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
                ),
              ],
              selectedIndex: 1,
              onTabChange: (index) {
                switch (index) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FirstRoute()),
                    );
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ThirdRoute()),
                    );
                    break;
                  default:
                    break;
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ThirdRoute extends StatefulWidget {
  const ThirdRoute({super.key});

  @override
  _ThirdRouteState createState() => _ThirdRouteState();
}

class _ThirdRouteState extends State<ThirdRoute> {
  String? please = 'hi';
  TextEditingController mc1 = TextEditingController();
  TextEditingController mc2 = TextEditingController();
  TextEditingController mc3 = TextEditingController();
  TextEditingController mc4 = TextEditingController();

  String userInput = '';
  Point? point;

  void printUserInput() {
    if (kDebugMode) {
      print(userInput);
    }
  }

  String? name;
  String? date;
  String? host;
  String? place;
  bool _showTextFields = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Third Route'),
        automaticallyImplyLeading: false,
      ),
      body: Column(children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showTextFields = true;
            });
          },
          child: const Text('Please!',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
        ),
        if (_showTextFields) // Correctly placed conditional rendering
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: mc1,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  onChanged: (val1) {
                    setState(() {
                      name = val1;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter your name', // Hint for the name field
                  ),
                ),
                TextField(
                  controller: mc2,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  onChanged: (val2) {
                    setState(() {
                      date = val2;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter the date', // Hint for the date field
                  ),
                ),
                TextField(
                  controller: mc3,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  onChanged: (val3) {
                    setState(() {
                      place = val3;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter the place', // Hint for the place field
                  ),
                ),
                TextField(
                  controller: mc4,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () => FocusScope.of(context).unfocus(),
                  onChanged: (val4) {
                    setState(() {
                      host = val4;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter the host', // Hint for the host field
                  ),
                ),
              ],
            ),
          )
      ]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: LineIcons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: LineIcons.search,
                  text: 'Search',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
                ),
              ],
              selectedIndex: 2,
              onTabChange: (index) {
                switch (index) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FirstRoute()),
                    );
                    break;
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SecondRoute()),
                    );
                    break;
                  default:
                    break;
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
class SignInForm extends StatefulWidget {
 @override
 _SignInFormState createState() => _SignInFormState();
}



class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material( // Add Material widget here
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signIn();
                }
              },
              child: const Text('Sign In'),
            ), ElevatedButton(
 onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SignUpForm()),
    );
 },
 child: const Text('Sign Up'),
),

          ],
        ),
      ),
    );
  }

void _signIn() async {
 String? userId = await signInWithEmailPassword(
    _emailController.text,
    _passwordController.text,
 );
 if (userId != null) {
    // Sign-in successful, navigate to the main content
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const FirstRoute()),
    );
 } else {
    // Sign-in failed, show an error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sign-in failed')),
    );
 }
}

}
Future<String?> signUpWithEmailPassword(String email, String password) async {
 try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // The user is signed up, return the user ID
    return userCredential.user?.uid;
 } on FirebaseAuthException catch (e) {
    // Handle sign-up errors
    print(e.message);
    return null;
 }
}
class SignUpForm extends StatefulWidget {
 @override
 _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
 final _formKey = GlobalKey<FormState>();
 final _emailController = TextEditingController();
 final _passwordController = TextEditingController();

 @override
 Widget build(BuildContext context) {
    return Material(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                 return 'Please enter your email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                 return 'Please enter your password';
                }
                return null;
              },
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                 _signUp();
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
 }

 void _signUp() async {
    String? userId = await signUpWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );
    if (userId != null) {
      // Sign-up successful, navigate to the main content
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const FirstRoute()),
      );
    } else {
      // Sign-up failed, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed')),
      );
    }
 }
}
