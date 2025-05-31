import 'package:flutter/cupertino.dart'; // Import for Cupertino-style icons.
import 'package:flutter/material.dart'; // Import for Flutter UI elements.
import 'package:get/get.dart'; // Import for GetX for state management.

import 'package:neo_ai_assistant/controller/image_controller.dart'; // Import the image controller.
import 'package:neo_ai_assistant/controller/translate_controller.dart'; // Import the translation controller.
import '../../widget/custom_btn.dart'; // Import custom button widget.
import '../../widget/custom_loading.dart'; // Import custom loading indicator.
import '../../widget/language_sheet.dart'; // Import the language selection sheet.

/// This widget provides the UI for the multi-language translator feature.
/// It allows users to select languages, input text, translate it, and view the translation history.
class TranslatorFeature extends StatefulWidget {
  const TranslatorFeature({super.key});

  @override
  State<TranslatorFeature> createState() => _TranslatorFeatureState();
}

class _TranslatorFeatureState extends State<TranslatorFeature> {
  //  Instance of the translation controller to manage the translation process.
  final TranslateController _c = Get.put(TranslateController());

  //  List to store the translation history.
  List<Map<String, String>> history = [];

  /// Builds the UI for the translator screen.
  /// It includes language selection dropdowns, a text input field,
  /// the translation result, and buttons to trigger translation and clear the input.
  ///
  /// Returns:
  ///   Widget: The built widget.
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size; // Get the screen size.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi Language Translator'), // Set the title of the app bar.
        leading: Builder(
          // Use a Builder to get the correct context for the drawer.
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu), // Hamburger menu icon.
            onPressed: () =>
                Scaffold.of(context).openDrawer(), // Open the drawer.
          ),
        ),
      ),
      drawer:
          _buildHistoryDrawer(), // Build the translation history drawer.
      body: ListView(
        // Use a ListView for scrollable content.
        physics:
            const BouncingScrollPhysics(), // Add bouncing scroll effect.
        padding: EdgeInsets.only(
            top: mq.height * .02,
            bottom: mq.height *
                .1), // Use mq for responsive padding. bottom padding added.
        children: [
          _buildLanguageSelection(
              mq), // Build the language selection UI.
          _buildInputField(mq), // Build the text input field.
          Obx(() =>
              _translateResult(mq)), // Build the translation result display.
          if (_c.status.value ==
              Status
                  .complete) //show when translation is complete, status is in the controller
            _buildClearButton(
                mq), // Build the clear button.
          SizedBox(height: mq.height *
              0.02), // Add some vertical spacing. Use mq for responsive height.
          CustomBtn(
            // Custom button to trigger the translation.
            onTap: () {
              _c.translate(); // Call the translate method in the controller.
              _addToHistory(_c.textC.text,
                  _c.resultC.text); // Add to history on translate.
            },
            text: 'Translate', // Button text.
          ),
        ],
      ),
    );
  }

  /// Builds the language selection row.
  /// It displays two dropdown-like boxes for selecting the source and target languages.
  ///
  /// Args:
  ///   mq (Size): The screen size.
  ///
  /// Returns:
  ///   Widget: The built widget.
  Widget _buildLanguageSelection(Size mq) => Row(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center the language selectors.
        children: [
          // InkWell for the source language selection.
          InkWell(
            onTap: () => Get.bottomSheet(LanguageSheet(
                c: _c,
                s: _c
                    .from)), // Show the language selection sheet. c is the controller, s is RxString
            borderRadius: const BorderRadius.all(
                Radius.circular(15)), // Rounded corners.
            child: _languageBox(
                mq,
                _c.from.isEmpty
                    ? 'Auto'
                    : _c
                        .from
                        .value), // Display 'Auto' or selected language name.
          ),
          // Button to swap the source and target languages.
          IconButton(
            onPressed:
                _c.swapLanguages, // Call the swapLanguages method in the controller.
            icon: Obx(
              () => Icon(
                // Use Obx to update the icon color dynamically.
                CupertinoIcons.repeat, // Swap icon.
                color: _c.to.isNotEmpty && _c.from.isNotEmpty
                    ? Colors.blue // Blue if both languages are selected.
                    : Colors
                        .grey, // Grey if either is not selected.  To improve UX.
              ),
            ),
          ),
          // InkWell for the target language selection.
          InkWell(
            onTap: () => Get.bottomSheet(LanguageSheet(
                c: _c,
                s: _c
                    .to)), //show language sheet, c is controller, s is RxString
            borderRadius: const BorderRadius.all(
                Radius.circular(15)), // Rounded corners.
            child: _languageBox(
                mq,
                _c.to.isEmpty
                    ? 'To'
                    : _c
                        .to
                        .value), // Display 'To' or the selected language.
          ),
        ],
      );

  /// Builds a language box.
  ///
  /// Args:
  ///   mq (Size): The screen size.
  ///   text (String): The text to display in the box.
  ///
  /// Returns:
  ///   Widget: The built widget.
  Widget _languageBox(Size mq, String text) => Container(
        height: 50, // Fixed height.
        width: mq.width *
            .4, // Responsive width.  Use mq for responsive width.
        alignment: Alignment.center, // Center the text.
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue), // Blue border.
          borderRadius: const BorderRadius.all(
              Radius.circular(15)), // Rounded corners.
        ),
        child: Text(text), // Display the language name.
      );

  /// Builds the input field for entering the text to be translated.
  ///
  /// Args:
  ///   mq (Size): The screen size.
  ///
  /// Returns:
  ///   Widget: The built widget.
  Widget _buildInputField(Size mq) => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: mq.width * 0.04,
            vertical: mq.height *
                0.035), // Use mq for responsive padding. vertical padding added.
        child: Stack(
          // Use a Stack to overlay the microphone and volume icons.
          alignment: Alignment.centerRight, // Align icons to the right.
          children: [
            TextFormField(
              controller:
                  _c.textC, // Bind the text field to the controller.
              minLines: 5, // Allow multiple lines for input.
              maxLines:
                  null, // The text field will expand as the user types.
              onTapOutside: (e) =>
                  FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
              decoration: const InputDecoration(
                hintText: 'Translate anything you want...', // Placeholder text.
                hintStyle:
                    TextStyle(fontSize: 13.5), // Smaller font size for hint.
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(10)), // Rounded corners.
                ),
              ),
            ),
            // Microphone icon button for speech input.
            Positioned(
              right: 50, // Position the icon.
              bottom: 10,
              child: IconButton(
                icon: const Icon(Icons.mic, color: Colors.blue), // Microphone icon.
                onPressed:
                    _c.startListening, // Call the startListening method.
              ),
            ),
            // Volume icon button for text-to-speech.
            Positioned(
              right: 10, // Position the icon.
              bottom: 10,
              child: IconButton(
                icon:
                    const Icon(Icons.volume_up, color: Colors.blue), // Volume icon.
                onPressed: () {
                  //speak the text.
                  if (_c.textC.text.trim().isNotEmpty) {
                    // Check if there is text to speak.
                    _c.speakText(_c.textC.text,
                        _c.from.value); // Call the speakText method.
                  }
                },
              ),
            ),
          ],
        ),
      );

  /// Builds the translation result display.
  /// It shows the translated text or a loading indicator based on the translation status.
  ///
  /// Args:
  ///   mq (Size): The screen size.
  ///
  /// Returns:
  ///   Widget: The built widget.
  Widget _translateResult(Size mq) =>
      switch (_c.status.value) { // Use a switch expression for cleaner UI.
        Status.none =>
          const SizedBox(), // Show nothing if no translation has been made.
        Status.complete =>
          Padding(
            // Show the translated text.
            padding: EdgeInsets.symmetric(
                horizontal: mq.width *
                    .04), // Use mq for responsive horizontal padding.
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to the start.
              children: [
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextFormField(
                      controller:
                          _c.resultC, // Bind to the result text controller.
                      maxLines:
                          null, // Allow multiple lines for the result.
                      onTapOutside: (e) =>
                          FocusScope.of(context).unfocus(), // Dismiss keyboard
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(10)), // Rounded corners.
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: IconButton(
                        icon:
                            const Icon(Icons.volume_up, color: Colors.blue),
                        onPressed: _c.resultC.text.trim().isNotEmpty
                            ? () => _c.speakText(
                                _c.resultC.text,
                                _c.to
                                    .value) //speak translated text, if not empty
                            : null, // Disable if the result is empty.
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Status.loading =>
          const Align(
              child:
                  CustomLoading()), // Show loading indicator during translation.
      };

  /// Builds the clear button.
  /// This button clears the input and output text fields and resets the translation status.
  ///
  /// Args:
  ///   mq (Size): The screen size.
  ///
  /// Returns:
  ///   Widget: The built widget.
  Widget _buildClearButton(Size mq) => Column(
        children: [
          SizedBox(height: mq.height *
              0.02), // Add vertical spacing.  Use mq for responsive height.
          ElevatedButton(
            // Button to clear the input and output.
            onPressed: () {
              _c.textC.clear(); // Clear the input text field.
              _c.resultC.clear(); // Clear the output text field.
              _c.status.value =
                  Status.none; // Reset the translation status.
            },
            child: const Text('Clear'), // Button text.
          ),
        ],
      );

  Widget _buildHistoryDrawer() => Drawer(
  child: Column(
    children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: Colors.blue),
        child: Center(
          child: Text(
            'Translation History',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
      Expanded(
        child: Obx(() => _c.history.isEmpty
          ? const Center(child: Text('No history available'))
          : ListView.builder(
              itemCount: _c.history.length,
              itemBuilder: (context, index) {
                final entry = _c.history[index];
                return ListTile(
                  title: Text(entry['input'] ?? ''),
                  subtitle: Text(entry['output'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _c.deleteHistory(index),
                  ),
                );
              },
            ),
        ),
      ),
    ],
  ),
);

  /// Adds a translation to the history list.
  ///
  /// Args:
  ///   from (String): The source text.
  ///   to (String): The translated text.
  void _addToHistory(String input, String output) {
    setState(() {
      history.add({'input': input, 'output': output});
  });
 }
}

