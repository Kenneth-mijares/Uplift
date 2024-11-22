import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teachable/teachable.dart';

class Html extends StatefulWidget {
  const Html({super.key});

  @override
  State<Html> createState() => _HtmlState();
}

class _HtmlState extends State<Html> {
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
                      path: "assets/html/index.html",
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