import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helper/global.dart'; // Import global helper functions.  Make sure this is correctly implemented.
import '../helper/pref.dart'; // Import preference helper functions. Make sure this is correctly implemented.
import '../widget/custom_loading.dart'; // Import custom loading widget. Make sure this widget is correctly implemented.
import 'home_screen.dart'; // Import your home screen.
import 'onboarding_screen.dart'; // Import your onboarding screen.

/// The splash screen displayed when the app starts.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('SplashScreenState initState called'); // Print statement for debugging.
    _checkNavigation(); // Call navigation logic in initState.
  }

  /// Navigates to the appropriate screen (onboarding or home) based on app state.
  Future<void> _checkNavigation() async {
    print('_checkNavigation started'); // Print statement for debugging.
    // Simulate a 3-second splash screen duration.
    await Future.delayed(const Duration(seconds: 3));
    print('Splash screen delay finished'); // Print statement for debugging.

    // Check if it's the first time the app is launched (onboarding).
    if (Pref.showOnboarding) {
      print('Showing onboarding screen'); // Print statement for debugging.
      Pref.showOnboarding =
          false; // Important: Update the preference. Make sure Pref.showOnboarding is settable.
      Get.offAll(() =>
          const OnboardingScreen()); // Use Get.offAll to replace the route. This prevents the user from being able to go back to the splash screen.
          //SignUpPage());
    } else {
      print('Showing home screen'); // Print statement for debugging.
      Get.offAll(() =>
          const HomeScreen()); // Use Get.offAll to replace the route. This prevents the user from being able to go back to the splash screen.
    }
    print('_checkNavigation finished'); // Print statement for debugging.
  }

  @override
  Widget build(BuildContext context) {
    print('SplashScreenState build called'); // Print statement for debugging.
    // Use the global mq variable. Make sure it is initialized before the build method is called.
    mq = MediaQuery.of(context).size;
    print('Screen size: $mq'); // Print statement for debugging.

    return Scaffold(
      body: SizedBox(
        width: double.infinity, // Make the container take up the full screen width.
        child: Column(
          children: [
            const Spacer(
                flex:
                    2), // Use Spacer to push content to the top and bottom, with flex to control how much space each takes.
            // Logo Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20), // Rounded corners for the card.
              ),
              elevation: 4, // Add a shadow to the card.
              child: Padding(
                padding: EdgeInsets.all(
                    mq.width *
                        0.025), // Use mq for responsive padding,  0.025 is 2.5% of screen width
                child: Image.asset(
                  'assets/images/logo.png', // Make sure the path is correct.
                  width:
                      mq.width *
                      0.45, // Use mq for responsive width, 0.45 is 45% of screen width
                ),
              ),
            ),
            const Spacer(),
            // Lottie Loading Animation
            const CustomLoading(), // Make sure this widget is correctly implemented.  It should display a loading animation.
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
