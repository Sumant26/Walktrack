import 'package:flutter/material.dart';
import 'package:walktrack/screens/home_screen.dart';

void main() {
  runApp(const WalkTrackApp());
}

class WalkTrackApp extends StatelessWidget {
  const WalkTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WalkTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          surface: Colors.black,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
