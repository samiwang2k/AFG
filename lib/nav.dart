// import 'package:google_nav_bar/google_nav_bar.dart';
// import 'package:line_icons/line_icons.dart';

// import 'jevent.dart';
// import 'point.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// //import 'event.dart';
// import 'firebase_options.dart';
// //import 'point.dart';


// final firestore = FirebaseFirestore.instance;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MaterialApp(
//     title: 'Navigation Basics',
//     home: FirstRoute(),
//   ));
// }

// Future<void> addPoint(Point point) async {
//   Map<String, dynamic> pointMap = point.toMap();
//   await firestore.collection('points').add(pointMap);
// }

// Future<void> addEvent(Jevent event) async {
//   Map<String, dynamic> eventMap = event.toMap();
//   await firestore.collection('events').add(eventMap);
// }

// Future<void> readPoint() async {
//   await firestore.collection('points').get().then((event) {
//     Map<String, dynamic> data = event.docs.last.data();
//     Point pt = Point.defined(data['x'], data['y']);
//     if (kDebugMode) {
//       print(pt);
//     }
//   });
// }
// void nav() => runApp(MaterialApp(
//       builder: (context, child) {
//         return Directionality(textDirection: TextDirection.ltr, child: child!);
//       },
//       title: 'GNav',
//       theme: ThemeData(
//         primaryColor: Colors.grey[800],
//       ),
//       home: const FirstRoute(),
//     ));

// class FirstRoute extends StatefulWidget {
//   const FirstRoute({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _FirstRouteState createState() => _FirstRouteState();
// }

// class _FirstRouteState extends State<FirstRoute> {
//   TextEditingController mc1 = TextEditingController();
//   TextEditingController mc2 = TextEditingController();
//   TextEditingController mc3 = TextEditingController();
//   TextEditingController mc4 = TextEditingController();


//   String userInput = '';
//   Point? point;
//   void printUserInput() {
//     if (kDebugMode) {
//       print(userInput);
//     }
//   }

//   Point? createPoint(String inputted) {
//     List<String> coordinates = inputted.split(',');
//     if (coordinates.length == 2) {
//       double x = double.tryParse(coordinates[0]) ?? 0.0;
//       double y = double.tryParse(coordinates[1]) ?? 0.0;
//       Point rval = Point.defined(x, y);
//       return rval;
//     }
//     return null;
//   }
//   String? name;
//   String? date;
//   String? host;
//   String? place;

//   String createEvent(String textyInput) {
//     List<String> jevents = textyInput.split('#');
//     Jevent event = Jevent(
//       name: jevents[0],
//       date: jevents[1],
//       location: createPoint(
//           jevents[2]), // Assuming createPoint can handle a default value
//       hostName: jevents.last,
//     );
//     if (kDebugMode) {
//       print(event);
//     }
//     return event.toString();
//   }
//   String? please= 'press to work(please)';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('First Route'),
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//  controller: mc1,
//  textInputAction: TextInputAction.next,
//  onEditingComplete: () => FocusScope.of(context).nextFocus(),
//  onChanged: (val1) {
//     setState(() {
//       name = val1;
//     });
//  },
//  decoration: const InputDecoration(
//     hintText: 'Enter your name', // Hint for the name field
//  ),
// ),
// TextField(
//  controller: mc2,
//  textInputAction: TextInputAction.next,
//  onEditingComplete: () => FocusScope.of(context).nextFocus(),
//  onChanged: (val2) {
//     setState(() {
//       date = val2;
//     });
//  },
//  decoration: const InputDecoration(
//     hintText: 'Enter the date', // Hint for the date field
//  ),
// ),
// TextField(
//  controller: mc3,
//  textInputAction: TextInputAction.next,
//  onEditingComplete: () => FocusScope.of(context).nextFocus(),
//  onChanged: (val3) {
//     setState(() {
//       place = val3;
//     });
//  },
//  decoration: const InputDecoration(
//     hintText: 'Enter the place', // Hint for the place field
//  ),
// ),
// TextField(
//  controller: mc4,
//  textInputAction: TextInputAction.done,
//  onEditingComplete: () => FocusScope.of(context).unfocus(),
//  onChanged: (val4) {
//     setState(() {
//       host = val4;
//     });
//  },
//  decoration: const InputDecoration(
//     hintText: 'Enter the host', // Hint for the host field
//  ),
// ), ElevatedButton(
//  onPressed: () {
//     // Assuming createEvent is a function that takes a String parameter
//     setState(() {
//           please = createEvent('$name#$date#$place#$host');
//         });
//         if (kDebugMode) {
//           print(please);
//         }
    
//  },
//  child: Text(please!,
//     style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
// )

//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 20,
//               color: Colors.black.withOpacity(.1),
//             )
//           ],
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
//             child: GNav(
//               rippleColor: Colors.grey[300]!,
//               hoverColor: Colors.grey[100]!,
//               gap: 8,
//               activeColor: Colors.black,
//               iconSize: 24,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               duration: const Duration(milliseconds: 400),
//               tabBackgroundColor: Colors.grey[100]!,
//               color: Colors.black,
//               tabs: const [
//                 GButton(
//                   icon: LineIcons.home,
//                   text: 'Home',
//                 ),
//                 GButton(
//                   icon: LineIcons.search,
//                   text: 'Search',
//                 ),
//                 GButton(
//                   icon: LineIcons.user,
//                   text: 'Profile',
//                 ),
//               ],
//               selectedIndex: 0,
//               onTabChange: (index) {
//                 switch (index) {
//                   case 1:
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const SecondRoute()),
//                     );
                    
//                     break;
//                   case 2:
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const ThirdRoute()),
//                     );
//                     break;
//                   default:
//                     break;
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SecondRoute extends StatelessWidget {
//   const SecondRoute({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Second Route'),
//         automaticallyImplyLeading: false,
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 20,
//               color: Colors.black.withOpacity(.1),
//             )
//           ],
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
//             child: GNav(
//               rippleColor: Colors.grey[300]!,
//               hoverColor: Colors.grey[100]!,
//               gap: 8,
//               activeColor: Colors.black,
//               iconSize: 24,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               duration: const Duration(milliseconds: 400),
//               tabBackgroundColor: Colors.grey[100]!,
//               color: Colors.black,
//               tabs: const [
//                 GButton(
//                   icon: LineIcons.home,
//                   text: 'Home',
//                 ),
//                 GButton(
//                   icon: LineIcons.search,
//                   text: 'Search',
//                 ),
//                 GButton(
//                   icon: LineIcons.user,
//                   text: 'Profile',
//                 ),
//               ],
//               selectedIndex: 1,
//               onTabChange: (index) {
//                 switch (index) {
//                   case 0:
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const FirstRoute()),
//                     );
//                     break;
//                   case 2:
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const ThirdRoute()),
//                     );
//                     break;
//                   default:
//                     break;
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ThirdRoute extends StatelessWidget {
//   const ThirdRoute({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Third Route'),
//         automaticallyImplyLeading: false,
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 20,
//               color: Colors.black.withOpacity(.1),
//             )
//           ],
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
//             child: GNav(
//               rippleColor: Colors.grey[300]!,
//               hoverColor: Colors.grey[100]!,
//               gap: 8,
//               activeColor: Colors.black,
//               iconSize: 24,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               duration: const Duration(milliseconds: 400),
//               tabBackgroundColor: Colors.grey[100]!,
//               color: Colors.black,
//               tabs: const [
//                 GButton(
//                   icon: LineIcons.home,
//                   text: 'Home',
//                 ),
//                 GButton(
//                   icon: LineIcons.search,
//                   text: 'Search',
//                 ),
//                 GButton(
//                   icon: LineIcons.user,
//                   text: 'Profile',
//                 ),
//               ],
//               selectedIndex: 2,
//               onTabChange: (index) {
//                 switch (index) {
//                   case 0:
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const FirstRoute()),
//                     );
//                     break;
//                   case 1:
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const SecondRoute()),
//                     );
//                     break;
//                   default:
//                     break;
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
