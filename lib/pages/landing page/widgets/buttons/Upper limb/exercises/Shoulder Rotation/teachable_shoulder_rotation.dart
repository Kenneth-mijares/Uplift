import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teachable/teachable.dart';

class TeachableShoulderRotation extends StatefulWidget {
  const TeachableShoulderRotation({super.key});

  @override
  State<TeachableShoulderRotation> createState() => _TeachableSidearmState();
}

class _TeachableSidearmState extends State<TeachableShoulderRotation> {
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
                      path: "assets/html/shoulder_rotation.html",
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