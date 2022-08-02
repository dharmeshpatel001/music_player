import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:music_player/screens/home_screen.dart';
import 'package:page_transition/page_transition.dart';

class AnimatedSplashPage extends StatefulWidget {
  const AnimatedSplashPage({Key? key}) : super(key: key);

  @override
  State<AnimatedSplashPage> createState() => _AnimatedSplashPageState();
}

class _AnimatedSplashPageState extends State<AnimatedSplashPage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        duration: 2000,
        splash: ClipRRect(
          borderRadius: BorderRadius.circular(200),
          child: const Image(
            image: AssetImage('assets/logo.png'),
          ),
        ),
        nextScreen: const MusicPlayer(),
        splashTransition: SplashTransition.slideTransition,
        // pageTransitionType: PageTransitionType.topToBottom,
        backgroundColor: Colors.white);
  }
}
