import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

Future<void> addSignup(String? string) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentReference userDocRef = firestore.collection('users').doc(userId);

  // Fetch the user's document
  DocumentSnapshot userDocSnapshot = await userDocRef.get();

  // Check if the user's document exists and has an events array
  if (userDocSnapshot.exists &&
      (userDocSnapshot.data() as Map<String, dynamic>).containsKey('signups')) {
    await userDocRef.update({
      'signups': FieldValue.arrayUnion([string]),
    });
  } else {
    // If the events array does not exist, create it with the new event
    await userDocRef.set({
      'signups': [string],
    }, SetOptions(merge: true)); // Use merge to avoid overwriting other fields
  }
}
