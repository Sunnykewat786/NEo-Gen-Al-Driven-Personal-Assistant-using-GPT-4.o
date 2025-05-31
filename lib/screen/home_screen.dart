import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../helper/global.dart'; // Import global helper functions
import '../helper/pref.dart'; // Import preference helper functions
import '../model/home_type.dart'; // Import the HomeType model
import '../widget/home_card.dart'; // Import the HomeCard widget

/// The main screen of the application, displaying a list or grid of home options.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Use RxBool for reactive state management.  These variables automatically update the UI when their values change.
  final RxBool _isDarkMode = Get.isDarkMode.obs; // Observable for dark mode state
  final RxBool _isGridMode =
      false.obs; // Observable for grid/list view mode state

  @override
  void initState() {
    super.initState();
    print('HomeScreenState initState called'); // Print statement for debugging

    // Set system UI mode (edge-to-edge) for immersive experience.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Initialize the state variables with values from shared preferences.
    _isDarkMode.value = Pref.isDarkMode;
    _isGridMode.value = Pref.isGridMode;

    // Ensure onboarding is not shown again when the user is on the home screen.
    Pref.showOnboarding = false;
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreenState build called'); // Print statement for debugging
    // Use WillPopScope to prevent the user from accidentally exiting the app with the back button.
    return WillPopScope(
      onWillPop: () async {
        print('Back button pressed, preventing exit'); // Print statement
        return false; // Return false to prevent popping the route.
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(appName), // Display the app name in the app bar.
          actions: [
            // Settings button in the app bar.
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed:
                  _showSettingsMenu, // Call the function to show the settings menu.
            ),
          ],
        ),
        // Use Obx to rebuild the body whenever _isGridMode changes.
        body: Obx(
          () {
            print('Rebuilding body, isGridMode: $_isGridMode'); // Print statement
            return _isGridMode.value ? _buildGridView() : _buildListView();
          },
        ),
      ),
    );
  }

  /// Displays the settings menu as an AlertDialog.
  void _showSettingsMenu() {
    print('_showSettingsMenu called'); // Print statement for debugging
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text("Settings", textAlign: TextAlign.center), // Centered title
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12)), // Rounded corners for the dialog
          content: Column(
            mainAxisSize: MainAxisSize.min, // Make the column size to fit its children
            children: [
              // Theme setting option
              _buildSettingOption(
                Icons.brightness_6,
                "Theme: ${_isDarkMode.value ? "Dark" : "Light"}",
                _toggleTheme,
              ),
              // View mode setting option
              _buildSettingOption(
                Icons.grid_view,
                "View: ${_isGridMode.value ? "Grid" : "List"}",
                _toggleListGrid,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a ListTile for a setting option.
  ///
  /// * `icon`: The icon to display for the setting.
  /// * `title`: The text title of the setting.
  /// * `onTap`: The callback function to execute when the setting is tapped.
  Widget _buildSettingOption(
      IconData icon, String title, VoidCallback onTap) {
    print('_buildSettingOption called for: $title'); // Print statement
    return ListTile(
      leading: Icon(icon, color: Colors.blue), // Blue icon
      title: Text(title), // Setting title
      onTap: () {
        print('Setting option tapped: $title'); // Print statement
        Get.back(); // Close the dialog
        onTap(); // Execute the provided onTap callback
      },
    );
  }

  /// Builds the list view of home cards.
  Widget _buildListView() {
    print('_buildListView called'); // Print statement for debugging
    return ListView(
      padding: const EdgeInsets.all(12), // Padding for the entire list
      children: HomeType.values
          .map((e) => HomeCard(homeType: e))
          .toList(), // Map each HomeType to a HomeCard widget
    );
  }

  /// Builds the grid view of home cards.
  Widget _buildGridView() {
    print('_buildGridView called'); // Print statement for debugging
    return GridView.builder(
      padding: const EdgeInsets.all(12), // Padding for the entire grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns in the grid
        childAspectRatio:
            1, // Aspect ratio of each grid item (1:1 for square)
        crossAxisSpacing: 12, // Spacing between columns
        mainAxisSpacing: 12, // Spacing between rows
      ),
      itemCount: HomeType.values
          .length, // Number of items in the grid (number of HomeType values)
      itemBuilder: (context, index) {
        final homeType =
            HomeType.values[index]; // Get the HomeType for the current index
        return HomeCard(
            homeType:
                homeType); // Build a HomeCard widget with the HomeType data
      },
    );
  }

  /// Toggles the app's theme between light and dark mode.
  void _toggleTheme() {
    print('_toggleTheme called'); // Print statement for debugging
    // Determine the new theme mode.
    final newMode =
        _isDarkMode.value ? ThemeMode.light : ThemeMode.dark; // Ternary operator
    Get.changeThemeMode(
        newMode); // Use Get to change the app's theme mode.  This will trigger a UI rebuild.
    _isDarkMode.value =
        !_isDarkMode
            .value; // Update the _isDarkMode observable.  This will trigger a UI rebuild.
    Pref.isDarkMode =
        _isDarkMode
            .value; // Update the shared preferences to persist the theme setting.
    Get.snackbar(
        'Theme Changed',
        'Theme set to ${_isDarkMode.value
            ? 'Dark'
            : 'Light'}'); // Show a snackbar to confirm the change.
  }

  /// Toggles the app's view mode between list and grid.
  void _toggleListGrid() {
    print('_toggleListGrid called'); // Print statement for debugging.
    _isGridMode.value =
        !_isGridMode
            .value; // Update the view mode.  This will trigger a UI rebuild because _isGridMode is an observable.
    Pref.isGridMode =
        _isGridMode
            .value; // Persist the view mode setting to shared preferences.
    Get.snackbar(
        'View Changed',
        'View set to ${_isGridMode.value
            ? 'Grid'
            : 'List'}'); // Show a snackbar to confirm the change.
  }
}

