import 'package:flutter/material.dart';
import 'package:google_map_api/MyHomeScreen/my_home_screen.dart';
import 'package:google_map_api/TransformLatLongToAddress/transform_latlng.dart';
import 'package:google_map_api/GetUserLocation/get_user_location.dart';
import 'package:google_map_api/splash_screen.dart';


import 'MyPolyLine/my_polyLine.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Light Theme
      darkTheme: ThemeData.dark(), // Dark Theme
      themeMode: ThemeMode.dark, // Use system setting by default

      home: MyHomeScreen(),
    );
  }
}

