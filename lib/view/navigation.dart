import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:translator/view/home.dart';

class NavigationProgress extends StatefulWidget {
  NavigationProgress({super.key});

  @override
  State<NavigationProgress> createState() => _NavigationProgressState();
}

class _NavigationProgressState extends State<NavigationProgress> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _initialNavigationCompleted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialNavigationCompleted) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        _initialNavigationCompleted = true;
      });
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   Future.delayed(const Duration(seconds: 3), () {
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (context) => const HomeScreen()),
  //     );
  //   });

  //   return Navigator(
  //     key: navigatorKey,
  //     onGenerateRoute: (settings) => MaterialPageRoute(
  //       builder: (context) => _buildContent(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF9906B), // Set the background color here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/TRANSLATOR.png', width: 350, height: 350),
            SizedBox(
              width: 350, // Adjust the width as needed
              height: 100, // Adjust the height as needed
              child: LottieBuilder.asset(
                'assets/loader.json',
              ),
            ),
          ],
        ),
      );
    }
  }
}
