//Import libraries
import 'package:flutter/material.dart';
import 'package:storyplayer/design.dart';

//Main function
void main() {
  runApp(const Main());
}
// class for homepage
//main class
class Main extends StatelessWidget {
  const Main({super.key});

  // root object
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: const Color.fromARGB(255, 0, 0, 0),
      debugShowCheckedModeBanner: false,
      title: 'Yasincan',
      theme: ThemeData(
        // theme
        primarySwatch: Colors.red,
      ),
      home: const design(),
    );
  }
}
// for main design check design.dart
