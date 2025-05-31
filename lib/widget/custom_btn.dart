import 'package:flutter/material.dart';
import '../helper/global.dart'; // Import for global helper functions

/// A custom button widget used throughout the application.
class CustomBtn extends StatelessWidget {
  final String text; // The text to display on the button.
  final VoidCallback onTap; // The callback function to execute when the button is pressed.

  const CustomBtn({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    print('CustomBtn build called with text: $text'); // Print statement for debugging.

    return Align(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(), // Rounded button shape.
          elevation: 0, // No shadow.
          backgroundColor:
              Theme.of(context).colorScheme.primary, // Use primary color from the theme.
          textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500), // Text style for the button.
          minimumSize: Size(
              mq.width * .4,
              50), // Minimum size of the button,  mq is likely from global.dart.
        ),
        onPressed: onTap, // Assign the provided onTap callback.
        child: Text(text), // Display the provided text on the button.
      ),
    );
  }
}

