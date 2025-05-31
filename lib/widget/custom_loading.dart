import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie animation package.

/// A custom loading indicator widget that uses a Lottie animation.
class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    print('CustomLoading build called'); // Print statement for debugging
    return Lottie.asset(
      'assets/lottie/loading.json', // Path to the Lottie animation file.
      width: 150, // Width of the loading animation.
      // Handles errors that may occur during the loading of the Lottie animation.
      errorBuilder: (context, error, stackTrace) {
        print('Error loading Lottie animation: $error, stackTrace: $stackTrace'); // Print error details
        // Display a simple circular progress indicator as a fallback in case the Lottie animation fails to load.
        return const CircularProgressIndicator();
      },
    );
  }
}

