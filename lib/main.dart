import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:puzzle_app/home.view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnimatedSplashScreen(
        splashIconSize: MediaQuery.of(context).size.width / 2,
        splash: Lottie.asset(
          "assets/puzzle_anim.json",
          width: MediaQuery.of(context).size.width / 1.5,
        ),
        nextScreen: HomeView(),
        splashTransition: SplashTransition.rotationTransition,
      ),
    );
  }
}
