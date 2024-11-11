import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '100',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
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
                        'Oct 23, 2024',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
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
                      Tab(text: 'Tab 1'),
                      Tab(text: 'Tab 2'),
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
                              'Content for Tab 1',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        // Content for Tab 2
                        Container(
             
                          padding: const EdgeInsets.all(16.0),
                          child: const Center(
                            child: Text(
                              'Content for Tab 2',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 24,
                              ),
                            ),
                          ),
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
