// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//  @override
//  Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Your app name',
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Your Title here'),
//         ),
//         body: OpenStreetMapSearchAndPick(
//           buttonColor: Colors.blue,
//           buttonText: 'Set Current Location',
//           onPicked: (pickedData) {
//             if (kDebugMode) {
//               print(pickedData.latLong.latitude);
//             }
//             if (kDebugMode) {
//               print(pickedData.latLong.longitude);
//             }
//             if (kDebugMode) {
//               print(pickedData.address);
//             }
//           },
//         ),
//       ),
//     );
//  }
// }
