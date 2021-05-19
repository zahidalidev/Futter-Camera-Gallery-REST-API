import 'package:flutter/material.dart';
import 'package:futter_camera_gallery_api/Widgets/MyAppBar.dart';
import 'package:futter_camera_gallery_api/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera, Gallery, Crop, Compress, Constraint, API',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home:
          MyHomePage(title: 'Camera, Gallery, Crop, Compress, Constraint, API'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Home(),
    );
  }
}
