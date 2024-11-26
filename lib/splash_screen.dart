import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_map_api/MyHomeScreen/my_home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: Duration(seconds: 5), // Total animation duration
      vsync: this,
    );

    // Define the bouncing animation
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -300.0, end: 50.0).chain(CurveTween(curve: Curves.easeOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 50.0, end: -30.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -30.0, end: 30.0).chain(CurveTween(curve: Curves.easeOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 30.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 1),
    ]).animate(_controller);

    // Start the animation
    _controller.forward();

    // Navigate to the next screen after animation ends
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomeScreen()),
      );
      // Add your navigation logic here
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Center(
            child: Transform.translate(
              offset: Offset(0, _animation.value), // Vertical movement
              child: child,
            ),
          );
        },
        child: Image.asset(
          'assets/Black.png',
          width: 500,
          height: 500,
        ),
      ),
    );
  }
}
