import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teachable/teachable.dart';

class TeachableSidearm extends StatefulWidget {
  const TeachableSidearm({super.key});

  @override
  State<TeachableSidearm> createState() => _TeachableSidearmState();
}

class _TeachableSidearmState extends State<TeachableSidearm> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("pose classifier"),
      ),
      body: Stack(
        children: [
          Container(
            child: Column(
              children: <Widget>[

                Expanded(
                  child: Container(
                    child: Teachable(
                      path: "assets/html/sidearm.html",
                      results: (res) {
                          // Recieve JSON data here

                          // Convert json to usable format
                          var resp = jsonDecode(res); 
                          print("The values are $resp");
                      },
                  ),
                  )
                )

              ],
            ),
          )
        ],
      ),
    );
  }
}