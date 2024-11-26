import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Stream<QuerySnapshot> _reportsStream;

  @override
  void initState() {
    super.initState();
    _reportsStream = _getReportsStream();
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _reportsStream,
        builder: (context, snapshot) {
          int completedExercisesCount = 0;
          String latestExerciseDate = 'No Data';

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var reports = snapshot.data!.docs;
            completedExercisesCount = reports.length;

            Timestamp latestTimestamp = reports.first['dateOfCompletion'];
            DateTime latestDate = latestTimestamp.toDate();
            latestExerciseDate =
                '${latestDate.month}/${latestDate.day}/${latestDate.year}';
          }

          return Column(
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
                            latestExerciseDate,
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
                  length: 1, // Number of tabs
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Reports'),
                        ],
                        labelColor: Color.fromARGB(255, 111, 128, 222),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Color.fromARGB(255, 111, 128, 222),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // List of Reports with Card UI and Color Logic for Text Color
                            snapshot.connectionState == ConnectionState.waiting
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : snapshot.hasError
                                    ? const Center(
                                        child: Text('Error loading reports'),
                                      )
                                    : snapshot.data!.docs.isEmpty
                                        ? const Center(
                                            child: Text('No reports available'),
                                          )
                                        : ListView.builder(
                                            itemCount: snapshot.data!.docs.length,
                                            itemBuilder: (context, index) {
                                              var report = snapshot.data!.docs[index];
                                              DateTime completionDate =
                                                  report['dateOfCompletion'].toDate();
                                              String formattedDate =
                                                  '${completionDate.month}/${completionDate.day}/${completionDate.year}';
                                              String exerciseName =
                                                  report['exerciseName'];
                                              String completionStatus =
                                                  report['completionStatus'] ??
                                                      'Not Available';

                                              // Define the text color based on completion status
                                              Color statusColor;
                                              if (completionStatus == 'Completed') {
                                                statusColor = Colors.green;
                                              } else if (completionStatus == 'Partial') {
                                                statusColor = Colors.orange;
                                              } else {
                                                statusColor = Colors.black;
                                              }

                                              return Card(
                                                margin: const EdgeInsets.symmetric(
                                                    vertical: 8.0, horizontal: 16.0),
                                                elevation: 4,
                                                child: ListTile(
                                                  leading: const Icon(
                                                    Icons.fitness_center,
                                                    color: Color.fromARGB(255, 111, 128, 222),
                                                  ),
                                                  title: Text(
                                                    exerciseName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    '$formattedDate -',
                                                    style: TextStyle(color: statusColor),
                                                  ),
                                                  trailing: Text(
                                                    completionStatus,
                                                    style: TextStyle(
                                                      color: statusColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
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
          );
        },
      ),
    );
  }
}
