import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import for text-to-speech functionality

import '../controller/chat_controller.dart'; // Import the chat controller.
import '../helper/global.dart'; // Import global helper functions or variables.  Make sure this import is correct.
import '../model/chat/chat.dart'; // Import the chat message model.

/// This widget displays an individual chat message.  It handles rendering
/// both user and bot messages, including text animation for loading states,
/// and interactive elements like saving bot responses to notes and text-to-speech.
class MessageCard extends StatelessWidget {
  /// The chat message to display.
  final Chat message;

  //  Reference to the chat controller for accessing chat-related functionality.
  final ChatController _chatController = Get.find();

  //  Flutter TTS instance for text-to-speech.
  final FlutterTts _flutterTts = FlutterTts();

  /// Constructor for the MessageCard widget.
  ///
  /// Parameters:
  ///   message (Chat): The chat message to display.
  MessageCard({super.key, required this.message}) {
    _initializeTTS(); // Initialize TTS when the card is created.
  }

  /// Initializes the text-to-speech engine.
  /// This method sets the language and pitch for the TTS engine.  It's called once
  /// when the MessageCard is created to ensure the TTS engine is ready for use.
  void _initializeTTS() async {
    await _flutterTts.setLanguage("en-US"); // Set the language to US English.
    await _flutterTts.setPitch(1.0); // Set the pitch to normal.
  }

  /// Speaks the given text using the text-to-speech engine.
  /// This method takes a string of text and uses the Flutter TTS plugin to speak it aloud.
  /// It also includes error handling to catch any exceptions that may occur during the speech synthesis process.
  ///
  /// Parameters:
  ///   text (String): The text to be spoken.
  void _speak(String text) async {
    if (text.isNotEmpty) {
      // Ensure there is text to speak.
      try {
        await _flutterTts.speak(text); // Speak the provided text.
      } catch (e) {
        debugPrint('TTS Error: $e'); // Log any errors that occur during speech.
      }
    }
  }

  /// Builds the UI for the message card.
  /// This method constructs the layout and appearance of the message card,
  /// including the message text, sender's avatar, and interactive elements.
  ///
  /// Returns:
  ///   Widget: The built message card widget.
  @override
  Widget build(BuildContext context) {
    const radius =
        Radius.circular(15); // Define the border radius for the message bubbles.
    final isBot =
        message.msgType ==
        ChatType
            .bot; // Determine if the message is from the bot or the user.

    return Row(
      // Align the message based on the sender.
      mainAxisAlignment:
          isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align items to the start vertically.
      children: [
        // Display bot's avatar if it's a bot message.
        if (isBot) ...[
          const SizedBox(width: 6), // Add some spacing.
          const CircleAvatar(
            // Bot's avatar.
            radius: 18,
            backgroundColor: Colors.white,
            child: Image(
                image: AssetImage('assets/images/logo.png'),
                width:
                    24), // Use an AssetImage.  Make sure the path is correct.
          ),
        ],
        // Container for the message text.
        Flexible(
          child: Container(
            constraints: BoxConstraints(
                maxWidth:
                    mq.width *
                        .6), // Limit the width of the message container.  Use mq.width
            margin: EdgeInsets.only(
              // Set the margin of the message.
              bottom: mq.height * 0.02, // Use mq.height.
              left: isBot
                  ? mq.width *
                      0.02 // Use mq.width
                  : 0, // No left margin for user messages.
              right: isBot
                  ? 0
                  : mq.width *
                      0.02, // Use mq.width // No right margin for bot messages.
            ),
            padding: EdgeInsets.symmetric(
                // Set the padding for the message.
                vertical: mq.height * 0.01, // Use mq.height
                horizontal: mq.width * 0.02), // Use mq.width
            decoration: BoxDecoration(
              // Style the message container.
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface), // Use theme color.
              borderRadius: BorderRadius.only(
                // Apply different border radius for user and bot.
                topLeft: radius,
                topRight: radius,
                bottomLeft: isBot ? Radius.zero : radius, // Bot message.
                bottomRight: isBot ? radius : Radius.zero, // User message.
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display message text or loading animation.
                message.msg.isEmpty
                    ? AnimatedTextKit(
                        // Show animation when message is empty.
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Please wait...!',
                            speed: const Duration(
                                milliseconds:
                                    100), // Typing speed.  Consider making this a constant.
                          ),
                        ],
                        repeatForever:
                            true, // Repeat the animation indefinitely.
                      )
                    : Text(message.msg,
                        textAlign: TextAlign
                            .left), // Display the message.
                // Show interactive buttons for bot messages.
                if (isBot && message.msg.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Space evenly.
                    children: [
                      // Button to save the message as a note.
                      GestureDetector(
                        onTap: () =>
                            _chatController.saveChatResponseAsNote(
                                'Chatbot Response',
                                message.msg), // Pass title and message.
                        child: const Row(
                          // Use a Row for the icon and text.
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save,
                                size: 16,
                                color: Colors
                                    .blue), // Use a constant for the color.
                            SizedBox(width: 4),
                            Text('Save to Notes',
                                style: TextStyle(
                                    color: Colors
                                        .blue)), // Use a constant for the color.
                          ],
                        ),
                      ),
                      // Button to speak the message.
                      GestureDetector(
                        onTap: () => _speak(message.msg),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.volume_up,
                                size: 16,
                                color: Colors
                                    .green), // Use a constant for the color.
                            SizedBox(width: 4),
                            Text('Listen',
                                style: TextStyle(
                                    color: Colors
                                        .green)), // Use a constant for the color.
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        // Display user's avatar if it's a user message.
        if (!isBot) ...[
          const CircleAvatar(
            // User's avatar.
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(Icons.person,
                color: Colors
                    .blue), // Use a constant for the color.
          ),
          const SizedBox(width: 6),
        ],
      ],
    );
  }
}

