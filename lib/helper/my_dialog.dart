import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widget/custom_loading.dart'; // Import for the loading indicator widget.

/// A utility class for displaying custom dialogs and snackbars.
class MyDialog {
  /// Displays a snackbar with the given title, message, and background color.
  ///
  /// The snackbar is shown using GetX's `Get.snackbar` method.
  static void _showSnackbar(String title, String msg, Color bgColor) {
    print('Showing snackbar: $title, message: $msg, color: $bgColor'); // Debug
    Get.snackbar(
      title, // Title of the snackbar.
      msg, // Message text of the snackbar.
      backgroundColor:
          bgColor.withOpacity(0.7), // Background color with opacity.
      colorText: Colors
          .white, // Text color of the title and message.
      snackPosition: SnackPosition.BOTTOM, // Position at the bottom
      duration: const Duration(seconds: 3), // Show for 3 seconds.
      borderRadius: 10, // Rounded corners
      margin: const EdgeInsets.all(10), // Add some margin
    );
  }

  /// Displays an info snackbar with a blue background.
  ///
  /// Uses the [_showSnackbar] method with a predefined title and color.
  static void info(String msg) {
    print('Displaying info dialog with message: $msg'); // Debug
    _showSnackbar('Info', msg, Colors.blue);
  }

  /// Displays a success snackbar with a green background.
  ///
  /// Uses the [_showSnackbar] method with a predefined title and color.
  static void success(String msg) {
    print('Displaying success dialog with message: $msg'); // Debug
    _showSnackbar('Success', msg, Colors.green);
  }

  /// Displays an error snackbar with a red background.
  ///
  /// Uses the [_showSnackbar] method with a predefined title and color.
  static void error(String msg) {
    print('Displaying error dialog with message: $msg'); // Debug
    _showSnackbar('Error', msg, Colors.redAccent);
  }

  /// Displays a loading dialog with a [CustomLoading] widget.
  ///
  /// The dialog is non-dismissible, meaning the user cannot tap outside to close it.
  static void showLoadingDialog() {
    print('Displaying loading dialog'); // Debug
    Get.dialog(
      const Center(
          child:
              CustomLoading()), // Use the custom loading indicator.
      barrierDismissible:
          false, // Prevent dismissing by tapping outside.
      // You can add more dialog customization options here if needed.
    );
  }

  /// Closes the currently displayed dialog or snackbar.
  static void close() {
    print('Closing dialog/snackbar'); // Debug
    Get.back(); // Use GetX's back() to close.
  }

  static void errors({
    required String title,
    required String message,
    bool showSnackbar = false,
  }) {
    if (showSnackbar) {
      Get.snackbar(
        title,
        message,
        colorText: Colors.white,
        backgroundColor: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.dialog(
        AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  // Add other dialog methods (success, info) with similar structure
  static void successes(String message, {String title = 'Success'}) {
    Get.snackbar(
      title,
      message,
      colorText: Colors.white,
      backgroundColor: Colors.green,
    );
  }

  static void infos(String message, {String title = 'Info'}) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
