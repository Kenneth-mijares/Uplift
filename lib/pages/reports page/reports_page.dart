import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  
  State<ReportsPage> createState() => _ReportsPageState();
  
}

class _ReportsPageState extends State<ReportsPage> {
  int completedExercisesCount = 0;
  String latestExerciseDate = '';
  late Stream<QuerySnapshot> _reportsStream;

  @override
  void initState() {
    super.initState();
    _fetchReportsData();
    _reportsStream = _getReportsStream();
  }

  Future<void> _fetchReportsData() async {
    try {
      // Get the current user's ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the reports subcollection for the current user
      QuerySnapshot reportsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('reports')
          .orderBy('dateOfCompletion', descending: true)
          .get();

      if (reportsSnapshot.docs.isNotEmpty) {
        setState(() {
          // Update the count of completed exercises
          completedExercisesCount = reportsSnapshot.docs.length;

          // Get the date of the latest exercise
          Timestamp latestTimestamp = reportsSnapshot.docs.first['dateOfCompletion'];
          DateTime latestDate = latestTimestamp.toDate();
          latestExerciseDate = '${latestDate.month}/${latestDate.day}/${latestDate.year}';
        });
      }
    } catch (e) {
      print('Error fetching reports data: $e');
    }
  }

  Stream<QuerySnapshot> _getReportsStream() {
    // Get the current user's ID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Stream the reports subcollection for the current user
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('reports')
        .orderBy('dateOfCompletion', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 111, 128, 222),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blue box with text
          Expanded(
            flex: 2,
            child: Container(
              color: const Color.fromARGB(255, 111, 128, 222),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$completedExercisesCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Completed Exercises',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        latestExerciseDate.isNotEmpty
                            ? latestExerciseDate
                            : 'No Data',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Latest Exercise Date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded section with tabs
          Expanded(
            flex: 4,
            child: DefaultTabController(
              length: 2, // Number of tabs
              child: Column(
                children: [
                  // TabBar
                  const TabBar(
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Reports'),
                    ],
                    labelColor: Color.fromARGB(255, 111, 128, 222),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color.fromARGB(255, 111, 128, 222),
                  ),
                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Content for Tab 1
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: const Center(
                            child: Text(
                              'Currently no Data',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        // Content for Tab 2: List of Reports
                        StreamBuilder<QuerySnapshot>(
                          stream: _reportsStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return const Center(child: Text('Error loading reports'));
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Center(child: Text('No reports available'));
                            }

                            var reports = snapshot.data!.docs;

                            return ListView.builder(
                              itemCount: reports.length,
                              itemBuilder: (context, index) {
                                var report = reports[index];
                                DateTime completionDate = report['dateOfCompletion'].toDate();
                                String formattedDate = '${completionDate.month}/${completionDate.day}/${completionDate.year}';
                                String exerciseName = report['exerciseName'];
                                String completionStatus = report['completionStatus'] ?? 'Not Available';

                                return ListTile(
                                  title: Text(exerciseName),
                                  subtitle: Text('$formattedDate - $completionStatus'),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
