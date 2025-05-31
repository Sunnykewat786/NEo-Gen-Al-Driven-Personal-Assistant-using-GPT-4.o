import 'dart:developer'; // Import for the log function.
import 'package:flutter/material.dart'; // Import for Flutter UI elements.
import 'package:get/get.dart'; // Import for GetX for state management.

import '../controller/translate_controller.dart'; // Import the translation controller.
import '../helper/global.dart'; // Import global helper functions or variables.  Check this import.

/// This widget is a bottom sheet that displays a list of languages for selection.
/// It allows the user to search for a language and select it.
class LanguageSheet extends StatefulWidget {
  //  Instance of the translation controller.
  final TranslateController c;

  //  RxString to hold the selected language.
  final RxString s;

  const LanguageSheet({super.key, required this.c, required this.s});

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  //  RxString to hold the search query.
  final _search = ''.obs;

  /// Builds the UI for the language selection bottom sheet.
  /// It includes a search bar and a list of languages.
  ///
  /// Returns:
  ///   Widget: The built widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      height: mq.height *
          0.5, // Occupy half of the screen height.  Use mq for responsive height.
      padding: EdgeInsets.only(
          left: mq.width * 0.04,
          right: mq.width * 0.04,
          top: mq.height *
              0.02), // Responsive padding.  Use mq for responsive width and height.
      decoration: BoxDecoration(
        color: Theme.of(context)
            .scaffoldBackgroundColor, // Use the theme's background color.
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(
                15)), // Rounded corners for the top.
      ),
      child: Column(
        children: [
          TextFormField(
            // Search input field.
            onChanged: (s) =>
                _search.value = s, // Update the search query.
            onTapOutside: (e) =>
                FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside.
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.translate_rounded,
                  color: Colors
                      .blue), // Icon for the search field.
              hintText: 'Search Language...', // Placeholder text.
              hintStyle:
                  TextStyle(fontSize: 14), // Hint text style.
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(10)), // Rounded corners for the input field.
              ),
            ),
          ),
          Expanded(
            // Expanded to take up remaining space.
            child: Obx(
              () {
                // Observe the search query for changes.
                final List<String> list = _search.isEmpty
                    ? widget.c.lang // Show all languages if search is empty.  c is controller
                    : widget.c.lang
                        .where((e) => e.toLowerCase().contains(
                            _search.value.toLowerCase())) // Filter languages based on search query.
                        .toList(); // Convert to list.

                return ListView.builder(
                  // Build the list of languages.
                  physics: const BouncingScrollPhysics(), // Add bouncing effect.
                  itemCount:
                      list.length, // Number of languages in the list.
                  padding: EdgeInsets.only(
                      top: mq.height * 0.02,
                      left:
                          6), // Add padding.  Use mq for responsive height.
                  itemBuilder: (ctx, i) {
                    // Build each language item.
                    return InkWell(
                      // Make each item clickable.
                      onTap: () {
                        // Handle language selection.
                        widget.s.value =
                            list[i]; // Update the selected language.  s is RxString
                        log(list[i]); // Log the selected language.
                        Get.back(); // Close the bottom sheet.
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: mq.height *
                                0.02), // Add padding.  Use mq for responsive height.
                        child: Text(list[i]), // Display the language name.
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

