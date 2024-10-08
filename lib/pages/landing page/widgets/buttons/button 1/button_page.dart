import 'package:capstone/pages/landing%20page/widgets/buttons/button%201/side_arm_raises.dart';
import 'package:flutter/material.dart';

class ButtonPage extends StatelessWidget {
  const ButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List of page widgets (each from a separate file)
    final List<Widget> pages = [
      const SideArmRaises(),
      //const Page2(),
      //const Page3(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Item List'),
      ),
      body: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Go to Page ${index + 1}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => pages[index], // Navigate to the selected page
                ),
              );
            },
          );
        },
      ),
    );
  }
}