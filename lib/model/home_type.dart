import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neo_ai_assistant/screen/feature/chatbot_feature.dart';
import 'package:neo_ai_assistant/screen/feature/image_feature.dart';
import 'package:neo_ai_assistant/screen/feature/summarize_feature.dart';
import 'package:neo_ai_assistant/screen/feature/translator_feature.dart';
import 'package:neo_ai_assistant/screen/feature/note_feature/note_feature.dart';
import 'package:neo_ai_assistant/screen/feature/todo_feature/todo_feature.dart';

/// Enum representing the different home screen options.
enum HomeType {
  aiChatBot,
  aiImage,
  aiTranslator,
  noteTaking,
  todolist,
  summarize, 
}

/// Extension providing helper methods and properties for the [HomeType] enum.
extension MyHomeType on HomeType {
  // Title Mapping
  /// Returns the title string for each home screen option.
  static final _titles = {
    HomeType.aiChatBot: 'AI ChatBot',
    HomeType.aiImage: 'AI Image Creator',
    HomeType.aiTranslator: 'Language Translator',
    HomeType.noteTaking: 'Note Taking',
    HomeType.todolist: 'Calendar To-Do',
    HomeType.summarize: 'Smart Summarizer',
  };

  // Lottie Mapping
  /// Returns the Lottie animation file name for each home screen option.
  static final _lottieFiles = {
    HomeType.aiChatBot: 'ai_hand_waving.json',
    HomeType.aiImage: 'ai_sit.json',
    HomeType.aiTranslator: 'ai_translate.json',
    HomeType.noteTaking: 'note_taking.json', // Unique Lottie file for notes
    HomeType.todolist:
        'calendar_animation.json', // Unique Lottie file for To-Do List
    HomeType.summarize: 'ai_404_robot.json', // Unique Lottie file for summarize
  };

  // Alignment Mapping
  /// Returns a boolean indicating whether the content should be left-aligned
  /// for each home screen option.
  static final _leftAlignments = {
    HomeType.aiChatBot: true,
    HomeType.aiImage: false,
    HomeType.aiTranslator: true,
    HomeType.noteTaking: false,
    HomeType.todolist: true,
    HomeType.summarize: false, // Unique alignment for summarize
  };

  // Padding Mapping
  /// Returns the padding EdgeInsets for each home screen option.
  static final _paddings = {
    HomeType.aiChatBot: EdgeInsets.zero,
    HomeType.aiImage: const EdgeInsets.all(20),
    HomeType.aiTranslator: const EdgeInsets.all(20),
    HomeType.noteTaking: EdgeInsets.zero,
    HomeType.todolist: const EdgeInsets.all(20),
    HomeType.summarize: const EdgeInsets.all(20), // Unique padding for summarize
  };

  // Navigation Mapping
  /// Returns a callback function that navigates to the corresponding screen
  /// when the home screen option is selected.
  static final _navigationCallbacks = {
    HomeType.aiChatBot: () => Get.to(() => ChatbotFeature()),
    HomeType.aiImage: () => Get.to(() => const ImageFeature()),
    HomeType.aiTranslator: () => Get.to(() => const TranslatorFeature()),
    HomeType.noteTaking: () => Get.to(() => NoteFeature()), // Added `const`
    HomeType.todolist: () => Get.to(() => TodoFeature()), // Added `const`
    HomeType.summarize: () => Get.to(() =>  SummarizeFeature()), //
  };

  /// Gets the title string for the home screen option.
  String get title => _titles[this]!;

  /// Gets the Lottie animation file name for the home screen option.
  String get lottie => _lottieFiles[this]!;

  /// Gets a boolean indicating whether the content should be left-aligned
  /// for the home screen option.
  bool get leftAlign => _leftAlignments[this]!;

  /// Gets the padding EdgeInsets for the home screen option.
  EdgeInsets get padding => _paddings[this]!;

  /// Gets the callback function that navigates to the corresponding screen
  /// when the home screen option is selected.
  VoidCallback get onTap => _navigationCallbacks[this]!;
}
