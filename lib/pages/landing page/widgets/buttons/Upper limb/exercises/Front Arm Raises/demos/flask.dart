import 'package:flutter/material.dart';

class Flask extends StatefulWidget {
  @override
  _FlaskState createState() => _FlaskState();
}

class _FlaskState extends State<Flask> {
  String videoFeedUrl = 'http://192.168.177.116:5000';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Monitoring'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Exercise Monitoring with Face and Pose Detection'),
            SizedBox(height: 20),
            Image.network(videoFeedUrl),  // This will display the live video stream
          ],
        ),
      ),
    );
  }
}
