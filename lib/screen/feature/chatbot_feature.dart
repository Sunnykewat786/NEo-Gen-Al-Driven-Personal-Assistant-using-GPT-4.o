import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/chat_controller.dart';
import '../../widget/message_card.dart';

/// This class represents the chatbot feature screen.
/// It allows users to interact with an AI assistant.
class ChatbotFeature extends StatelessWidget {
  // Get the ChatController instance using GetX for state management.
  final ChatController _c = Get.find<ChatController>();

  ChatbotFeature({super.key});

  @override
  Widget build(BuildContext context) {
    // Build the UI for the chatbot feature.
    return Scaffold(
      appBar: AppBar(title: const Text('Chat with AI Assistant')),
      drawer: _buildHistoryDrawer(), // Display chat history in a drawer.
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // Position the action button.
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 8), // Add horizontal padding.
        child: Row(children: [
          // Expanded text field for typing messages.
          Expanded(
            child: TextFormField(
              controller: _c.textC, // Connect to the text controller.
              textAlign: TextAlign.center, // Center the input text.
              onTapOutside: (_) => FocusScope.of(context)
                  .unfocus(), // Dismiss keyboard on tap outside.
              decoration: InputDecoration(
                fillColor: Theme.of(context)
                    .scaffoldBackgroundColor, // Match background color.
                filled: true, // Fill the background.
                isDense: true, // Make the input field more compact.
                hintText: 'Ask me anything...', // Placeholder text.
                hintStyle:
                    const TextStyle(fontSize: 14), // Style for hint text.
                border: const OutlineInputBorder(
                  // Rounded border for the input field.
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            ),
          ),
          const SizedBox(
              width: 8), // Add spacing between input and Wikipedia button.
          // Button to trigger a Wikipedia search.
          IconButton(
            icon: const Icon(Icons.public, color: Colors.blue),
            onPressed: () => _c.askQuestion(
                source: "wikipedia"), // Call askQuestion with source.
            tooltip: "Search Wikipedia", // Tooltip for the button.
          ),
          // Button to trigger a YouTube search
          IconButton(
            icon: const Icon(Icons.video_library, color: Colors.red),
            onPressed: () => _c.askQuestion(
                source: "youtube"), // Call askQuestion with source
            tooltip: "Search YouTube",
          ),
          const SizedBox(width: 8), // Add spacing before the microphone button.
          // Button to toggle voice input.
          Obx(
            () => CircleAvatar(
              radius: 24, // Size of the button.
              backgroundColor: _c.isListening.value
                  ? Colors.redAccent // Change color when listening.
                  : Theme.of(context)
                      .colorScheme
                      .primary, // Default button color.
              child: IconButton(
                onPressed: _c.isListening.value
                    ? _c.stopListening // Stop listening if active.
                    : _c.startListening, // Start listening if inactive.
                icon: Icon(
                  _c.isListening.value
                      ? Icons.mic_off
                      : Icons.mic, // Change icon based on listening state.
                  color: Colors.white, // Icon color.
                  size: 28, // Icon size.
                ),
              ),
            ),
          ),
          const SizedBox(width: 8), // Add spacing after the microphone button.
          // Button to send the message.
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              onPressed: () => _c.askQuestion(), // Call the askQuestion method.
              icon: const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
        ]),
      ),
      // Display the list of messages.
      body: Obx(
        () => ListView.builder(
          physics: const BouncingScrollPhysics(), // Add bounce effect.
          controller: _c.scrollC, // Connect to the scroll controller.
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height *
                  0.02, // Top padding relative to screen height.
              bottom: MediaQuery.of(context).size.height *
                  0.1), // Bottom padding for input area.
          itemCount: _c.list.length, // Number of messages.
          itemBuilder: (context, index) =>
              MessageCard(message: _c.list[index]), // Build each message card.
        ),
      ),
    );
  }

  /// Builds the drawer that displays chat history.
  Widget _buildHistoryDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Drawer header with title
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Center(
              child: Text(
                "Chat History",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Button to start a new chat session.
          ListTile(
            leading: const Icon(Icons.add_comment, color: Colors.green),
            title: const Text('New Chat'),
            onTap: () {
              _c.newChat(); // Call newChat to clear the current chat.
              Get.back(); // Close the drawer.
            },
          ),
          const Divider(), // Visual separator.
          // Expanded section to display the list of chat sessions.
          Expanded(
            child: Obx(() {
              // Show a message if there are no chat sessions.
              if (_c.chatSessions.isEmpty) {
                return const Center(child: Text('No chat history yet'));
              }
              // Build the list of chat sessions.
              return ListView.builder(
                itemCount: _c.chatSessions.length,
                itemBuilder: (context, index) {
                  final session = _c.chatSessions[index];
                  // Get the first message of the session or show "Empty chat".
                  final firstMessage = session['messages'] != null &&
                          session['messages'].isNotEmpty
                      ? session['messages'][0]['msg'] ?? 'Empty chat'
                      : 'Empty chat';
                  return ListTile(
                    leading:
                        const Icon(Icons.history), // Icon for chat history.
                    title: Text(
                      firstMessage, // Display the first message.
                      maxLines: 1, // Limit to one line.
                      overflow: TextOverflow
                          .ellipsis, // Show ellipsis if the text overflows.
                    ),
                    onTap: () {
                      // Load the selected chat session.
                      _c.loadChatSession(session['id']);
                      Get.back(); // Close the drawer.
                    },
                    trailing: IconButton(
                      // Button to delete a chat session.
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          _c.deleteChatSession(session['id']), // Call delete.
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
