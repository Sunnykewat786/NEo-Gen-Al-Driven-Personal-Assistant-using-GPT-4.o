import 'dart:developer'; // Log debugging info
// JSON decoding (if needed)
import 'package:flutter/material.dart'; // Flutter UI elements
import 'package:get/get.dart'; // GetX for state management
import 'package:flutter_tts/flutter_tts.dart'; // Text-to-Speech
import 'package:speech_to_text/speech_to_text.dart' as stt; // Speech-to-Text

import '../apis/apis.dart'; // Import custom API functions
import '../helper/my_dialog.dart';

import 'image_controller.dart'; // Import custom dialogs

/// Controller class to manage the translation feature's state and logic.
/// Handles text input, translation, text-to-speech (TTS), and speech-to-text (STT).
class TranslateController extends GetxController {
  /// Controllers for user input & translated text.
  final TextEditingController textC = TextEditingController();
  final TextEditingController resultC = TextEditingController();

  /// Observable variables for selected languages.
  final RxString from = ''.obs; // Source language
  final RxString to = ''.obs; // Target language

  /// Status of the translation process.
  final Rx<Status> status = Status.none.obs;

  /// Text-to-Speech (TTS) engine instance.
  final FlutterTts flutterTts = FlutterTts();

  /// Speech-to-Text (STT) engine instance.
  final stt.SpeechToText speech = stt.SpeechToText();

  /// List of supported languages for TTS.
  List<String> supportedTTSLanguages = [];

  /// Observable list to store translation history.
  final history = <Map<String, String>>[].obs;

  /// Called when the controller is initialized.
  @override
  void onInit() {
    super.onInit();
    checkTTSLanguages(); // Load supported TTS languages
    initSpeech(); // Initialize Speech-to-Text
  }

  /// Fetch supported languages for TTS and update `supportedTTSLanguages`.
  Future<void> checkTTSLanguages() async {
    try {
      final langs = await flutterTts.getLanguages;
      if (langs != null) {
        supportedTTSLanguages = List<String>.from(langs);
        log("✅ Supported TTS Languages: $supportedTTSLanguages");
      } else {
        log("⚠️ No languages returned from TTS plugin.");
      }
    } catch (e) {
      log("❌ Error fetching TTS languages: $e");
    }
  }

  /// Initializes the Speech-to-Text engine with error handling.
  Future<void> initSpeech() async {
    final available = await speech.initialize(
      onError: (val) {
        log('❌ Speech recognition error: $val');
        MyDialog.info('Speech recognition error: $val');
      },
      onStatus: (val) => log('🎙 Speech recognition status: $val'),
    );

    if (!available) {
      MyDialog.info('Speech recognition is not available on this device.');
    }
  }

  /// Starts listening for speech input and updates the input text field.
  Future<void> startListening() async {
    if (!speech.isAvailable) await initSpeech();

    if (!speech.isAvailable) {
      MyDialog.info('Speech recognition is still not available.');
      return;
    }

    await speech.listen(
      onResult: (val) {
        textC.text = val.recognizedWords;
      },
      localeId: jsonLangTranslate[from.value] ?? 'en',
    );
  }

  /// Stops listening for speech input.
  Future<void> stopListening() async => await speech.stop();

  /// Translates the text and updates the UI.
  Future<void> translate() async {
    if (textC.text.trim().isEmpty) {
      MyDialog.info('Type or Speak Something to Translate!');
      return;
    }

    if (to.value.isEmpty) {
      MyDialog.info('Select Target Language!');
      return;
    }

    status.value = Status.loading;

    final fromLang = jsonLangTranslate[from.value];
    final toLang = jsonLangTranslate[to.value];

    if (fromLang == null || toLang == null) {
      MyDialog.info('❌ Language not supported for translation.');
      status.value = Status.none;
      return;
    }

    log("🌍 Translating from $fromLang to $toLang");

    try {
      final translatedText = await APIs.googleTranslate(
        from: fromLang,
        to: toLang,
        text: textC.text,
      );

      resultC.text = translatedText;
      status.value = Status.complete;

      // Add to history
      history.add({
        'from': from.value,
        'to': to.value,
        'input': textC.text,
        'output': translatedText,
      });
    } catch (e) {
      log("❌ Translation Error: $e");
      MyDialog.info('Translation Failed! Language may not be supported.');
      status.value = Status.none;
    }
  }

  /// Clears the input and translated text fields.
  void clearFields() {
    textC.clear();
    resultC.clear();
  }

  /// Deletes a translation history entry at the given index.
  void deleteHistory(int index) {
    if (index >= 0 && index < history.length) {
      history.removeAt(index);
    }
  }

  /// Swaps the source and target languages along with their respective texts.
  void swapLanguages() {
    if (from.value.isNotEmpty && to.value.isNotEmpty) {
      final temp = to.value;
      to.value = from.value;
      from.value = temp;

      final tempText = textC.text;
      textC.text = resultC.text;
      resultC.text = tempText;
    }
  }

  /// Speaks the given text using TTS with error handling.
  Future<void> speakText(String text, String lang) async {
    if (text.trim().isEmpty) {
      MyDialog.info('No text to speak!');
      return;
    }

    final languageCode = jsonLangTTS[lang];

    if (languageCode == null) {
      MyDialog.info('❌ Language code not found for $lang!');
      return;
    }

    log("🔍 Requested TTS Language: $lang ($languageCode)");

    if (supportedTTSLanguages.isEmpty) await checkTTSLanguages();

    if (!supportedTTSLanguages.contains(languageCode)) {
      MyDialog.info('❌ Text-to-Speech is not supported for $lang!');
      return;
    }

    try {
      await flutterTts.setLanguage(languageCode);
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.8);
      await flutterTts.setVolume(1.0);
      await flutterTts.speak(text);
    } catch (e) {
      log("❌ TTS Error: $e");
      MyDialog.info(
          "Error using Text-to-Speech! Language may not be supported.");
    }
  }

  /// Mapping of user-friendly language names to Google Translate language codes.
  final Map<String, String> jsonLangTranslate = const {
    'English': 'en',
    'German': 'de',
    'Spanish': 'es',
    'French': 'fr',
    'Hindi': 'hi',
    'Indonesian': 'id',
    'Italian': 'it',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Dutch': 'nl',
    'Polish': 'pl',
    'Portuguese': 'pt',
    'Russian': 'ru',
  };

  /// Mapping of user-friendly language names to TTS language codes.
  final Map<String, String> jsonLangTTS = const {
    'English': 'en-US',
    'German': 'de-DE',
    'Spanish': 'es-ES',
    'French': 'fr-FR',
    'Hindi': 'hi-IN',
    'Indonesian': 'id-ID',
    'Italian': 'it-IT',
    'Japanese': 'ja-JP',
    'Korean': 'ko-KR',
    'Dutch': 'nl-NL',
    'Polish': 'pl-PL',
    'Portuguese': 'pt-BR',
    'Russian': 'ru-RU',
  };

  /// List of supported languages.
  late final List<String> lang = jsonLangTranslate.keys.toList();
}
