import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// A utility class for managing app preferences using Hive.
class Pref {
  static late Box _box; // Late initialization of the Hive Box.

  /// Initializes Hive and opens the 'myData' box.  This should be called early in the app's lifecycle.
  static Future<void> initialize() async {
    print("Pref: Initializing..."); // Print statement to indicate start of initialization.
    // Initialize Hive with the appropriate directory, depending on the platform.
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // For mobile platforms, get the application documents directory.
      final appDocumentDirectory = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDirectory.path); // Set the Hive path.
      print(
          "Pref: Hive initialized with path: ${appDocumentDirectory.path}"); // Print the path.
    } else if (kIsWeb) {
      // For web, use 'web_hive' as the Hive path.
      Hive.init('web_hive');
      print("Pref: Hive initialized for web with path: 'web_hive'");
    }

    // Open the Hive box named 'myData'.  This is where preferences are stored.
    _box = await Hive.openBox('myData');
    print("Pref: Hive box 'myData' opened successfully."); // Print success.
  }

  /// Getter for the 'showOnboarding' preference.  Defaults to true if not set.
  static bool get showOnboarding =>
      _box.get('showOnboarding', defaultValue: true);
  /// Setter for the 'showOnboarding' preference.
  static set showOnboarding(bool v) {
    _box.put('showOnboarding', v);
    print("Pref: set showOnboarding to: $v");
  }

  /// Getter for the 'isDarkMode' preference.  Defaults to false if not set.
  static bool get isDarkMode => _box.get('isDarkMode') ?? false;
  /// Setter for the 'isDarkMode' preference.
  static set isDarkMode(bool v) {
    _box.put('isDarkMode', v);
    print("Pref: set isDarkMode to: $v");
  }

  /// Getter for the 'isGridMode' preference. Defaults to false if not set.
  static bool get isGridMode => _box.get('isGridMode', defaultValue: false);
  /// Setter for the 'isGridMode' preference.
  static set isGridMode(bool v) {
    _box.put('isGridMode', v);
    print("Pref: set isGridMode to: $v");
  }

  /// Getter for the 'defaultTheme' preference.  Returns the appropriate ThemeMode.
  static ThemeMode get defaultTheme {
    // If 'isDarkMode' is not set, return the system's theme mode.
    if (!_box.containsKey('isDarkMode')) {
      print("Pref: defaultTheme is system default.");
      return ThemeMode.system;
    }
    // Return dark or light mode based on the 'isDarkMode' preference.
    final themeMode =
        _box.get('isDarkMode') ? ThemeMode.dark : ThemeMode.light;
    print("Pref: defaultTheme is: $themeMode");
    return themeMode;
  }
}

