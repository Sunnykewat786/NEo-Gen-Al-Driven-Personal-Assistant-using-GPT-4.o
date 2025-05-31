import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class SummarizeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString summaryText = ''.obs;
  final RxString pdfError = ''.obs;

  late GenerativeModel _model;

  final String modelName = 'gemini-1.5-pro';

  @override
  void onInit() {
    super.onInit();
    // IMPORTANT: Use secure method to store and retrieve your API key.
    _model = GenerativeModel(
      model: modelName,
      apiKey: 'AIzaSyBptc2E1WdoyDYTQg1Au4Hf_gxL80w0UD4', // Replace securely
    );
  }

Future<void> pickPDF() async {
  try {
    resetPDFState();
    isLoading.value = true;

    // Clear any previous selections
    FilePicker.platform.clearTemporaryFiles(); 

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select PDF File',
      type: FileType.any,
      //allowedExtensions: ['pdf'],
      allowMultiple: false,
      withData: true,
      lockParentWindow: true,
    );

    if (result == null) {
      summaryText.value = 'No file selected';
      return;
    }

    if (result.files.single.extension?.toLowerCase() != 'pdf') {
      throw Exception('Please select a PDF file');
    }

    final filePath = result.files.single.path;
    if (filePath == null) {
      throw Exception('Could not access file path');
    }

    await processPDFFile(File(filePath));
  } on PlatformException catch (e) {
    handlePDFError('Platform error', e.message ?? 'Unknown platform error');
  } catch (e) {
    handlePDFError('File selection failed', e);
  } finally {
    isLoading.value = false;
  }
}

  /// Process and summarize the given PDF file
  Future<void> processPDFFile(File file) async {
    try {
      if (!await file.exists()) {
        throw Exception('File not found or inaccessible');
      }

      final fileSize = await file.length();
      if (fileSize > 15 * 1024 * 1024) {
        throw Exception('PDF exceeds 15MB limit');
      }

      summaryText.value = 'Extracting text from PDF...';
      final pdfContent = await extractTextFromPDF(file);

      if (pdfContent.isEmpty) {
        throw Exception(
            'Text extraction failed. The PDF may be image-based or encrypted.');
      }

      await generateSummary(pdfContent);
    } catch (e) {
      handlePDFError('Failed to process PDF', e);
    }
  }

  /// Extract plain text from PDF using Syncfusion
  Future<String> extractTextFromPDF(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      String extractedText;
      try {
        extractedText = PdfTextExtractor(document).extractText();
      } finally {
        document.dispose();
      }

      return extractedText.trim();
    } catch (e) {
      throw Exception('PDF text extraction failed: ${e.toString()}');
    }
  }

  /// Summarize text manually entered by the user
  Future<void> summarizeText(String text) async {
    try {
      resetPDFState();
      isLoading.value = true;

      if (text.trim().isEmpty) {
        throw Exception('Please enter some text to summarize');
      }

      await generateSummary(text);
    } catch (e) {
      summaryText.value = 'Error: ${e.toString()}';
      Get.snackbar('Error', 'Failed to summarize text');
    } finally {
      isLoading.value = false;
    }
  }

  /// Core function to generate AI-based summary
  Future<void> generateSummary(String text) async {
    try {
      summaryText.value = 'Generating summary...';

      final prompt = """
You are an intelligent summarizer AI.

Your task is to summarize the following content concisely and clearly, while capturing the most important details, key ideas, and structure. Avoid repetition and keep it human-readable.

Here is the content:
${text.length > 50000 ? '${text.substring(0, 50000)}\n\n[Note: Text was truncated to 50,000 characters]' : text}
""";

      final response = await _model.generateContent([Content.text(prompt)]);

      summaryText.value = response.text?.trim() ?? "No summary generated.";
      pdfError.value = '';
    } catch (e) {
      throw Exception('AI summarization failed: ${e.toString()}');
    }
  }

  /// Save summary to notes or local storage (to implement)
  void saveSummaryToNotes() {
    try {
      if (summaryText.value.isEmpty) {
        throw Exception('No summary available to save');
      }

      // TODO: Implement save functionality (Hive/SQLite/Cloud)
      Get.snackbar(
        'Success',
        'Summary saved to notes',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save summary: ${e.toString()}');
    }
  }

  /// Reset states for fresh summary/PDF
  void resetPDFState() {
    pdfError.value = '';
    summaryText.value = '';
  }

  /// Handle PDF-related exceptions and update UI
  void handlePDFError(String context, dynamic error) {
    pdfError.value = 'PDF Error: ${error.toString()}';
    summaryText.value = 'Failed to process PDF';
    Get.snackbar(
      'PDF Error',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}
