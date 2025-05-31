import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neo_ai_assistant/controller/summarize_controller.dart';
import 'package:neo_ai_assistant/controller/note_controller.dart';

class SummarizeFeature extends StatelessWidget {
  final SummarizeController controller = Get.put(SummarizeController());
  final NoteController noteController = Get.find<NoteController>();

  SummarizeFeature({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Summarizer"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (controller.summaryText.isEmpty)
                _buildUploadCard(context, isDarkMode, colorScheme)
              else
                _buildSummaryCard(context, isDarkMode, colorScheme),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUploadCard(
      BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return Expanded(
      child: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _showUploadOptions,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Icon(
                      Icons.add,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Upload Content to Summarize',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PDF files, text, or article links',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, bool isDarkMode, ColorScheme colorScheme) {
    return Expanded(
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'AI Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.content_copy),
                        color: colorScheme.primary,
                        onPressed: () => _copyToClipboard(
                          context,
                          controller.summaryText.value,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: colorScheme.primary,
                        onPressed: () => controller.resetPDFState(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        controller.summaryText.value,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('New Summary'),
                  onPressed: () => controller.resetPDFState(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save to Notes'),
                  onPressed: _saveToNotes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, size: 28),
              title: const Text(
                'Upload PDF',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Get.back();
                controller.pickPDF();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.article, size: 28),
              title: const Text(
                'Enter Text',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Get.back();
                _showTextInputDialog(context);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.link, size: 28),
              title: const Text(
                'Paste Article Link',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Get.back();
                _showUrlInputDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlInputDialog(BuildContext context) {
    final inputController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Summarize from URL'),
        content: TextField(
          controller: inputController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/article',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (inputController.text.trim().isNotEmpty) {
                Get.back();
                Get.snackbar(
                  'Coming Soon',
                  'URL summarization will be available in the next update',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Summarize'),
          ),
        ],
      ),
    );
  }

  void _saveToNotes() {
    noteController.addNote(
      'AI Summary - ${DateTime.now().toString().substring(0, 10)}',
      controller.summaryText.value,
      'Summaries',
      false,
      [],
    );
    Get.snackbar(
      'Saved',
      'Summary added to your notes',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showTextInputDialog(BuildContext context) {
    final inputController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter Text to Summarize'),
        content: TextField(
          controller: inputController,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: 'Paste your article text here...',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          ),
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (inputController.text.trim().isNotEmpty) {
                controller.summarizeText(inputController.text.trim());
                Get.back();
              }
            },
            child: const Text('Summarize'),
          ),
        ],
      ),
    );
  }
}
