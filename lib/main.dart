import 'package:chool_check/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ),
  );
}
