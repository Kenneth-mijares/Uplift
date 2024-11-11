import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveExerciseReport({
    required String exerciseName,
    required DateTime dateOfCompletion,
    required String completionStatus, // Added completion status
  }) async {
    try {
      // Get the current user's ID
      String userId = _auth.currentUser!.uid;

      // Reference to the user's document and the 'reports' subcollection
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      CollectionReference reportsCollection = userDoc.collection('reports');

      // Add the report to the 'reports' subcollection
      await reportsCollection.add({
        'exerciseName': exerciseName,
        'dateOfCompletion': dateOfCompletion,
        'completionStatus': completionStatus, // Save completion status
      });

      print('Report saved successfully');
    } catch (e) {
      print('Error saving report: $e');
    }
  }
}
