// 🌟 Import necessary dependencies.
import 'package:hive/hive.dart'; // Hive for local database storage.

part 'translate.g.dart'; // Generated file for Hive adapter. IMPORTANT: Must match the file name!

/// 🗂️ **Translation History Item Model**
/// This class represents a single entry in the translation history.
/// It stores the translated text, source and target languages, and provides utility methods for conversion.
@HiveType(typeId: 3) // Unique ID for Hive storage (0-255). IMPORTANT: Ensure uniqueness across models!
class TranslationHistoryItem extends HiveObject { // Extends HiveObject to enable easy saving and deletion.
  
  /// 📌 **Stored Fields in Hive Database**
  @HiveField(0) 
  String fromText; // Original text before translation.

  @HiveField(1) 
  String toText; // Translated text.

  @HiveField(2) 
  String fromLanguage; // Source language code (e.g., 'en' for English).

  @HiveField(3) 
  String toLanguage; // Target language code (e.g., 'fr' for French).

  /// ✅ **Constructor**
  /// Initializes a new translation history item with the given text and language codes.
  TranslationHistoryItem({
    required this.fromText,
    required this.toText,
    required this.fromLanguage,
    required this.toLanguage,
  }) {
    print("✅ TranslationHistoryItem Created: $fromText → $toText ($fromLanguage → $toLanguage)"); // Debugging log
  }

  /// 🔄 **Factory Method: Convert Map to Object**
  /// This method helps in reconstructing a `TranslationHistoryItem` from a map (useful for lists).
  factory TranslationHistoryItem.fromMap(Map<String, String> map) {
    print("🔄 Converting Map to TranslationHistoryItem: $map"); // Debugging log
    return TranslationHistoryItem(
      fromText: map['input'] ?? '', // Retrieves 'input' key (original text).
      toText: map['output'] ?? '', // Retrieves 'output' key (translated text).
      fromLanguage: map['from'] ?? '', // Retrieves 'from' key (source language).
      toLanguage: map['to'] ?? '', // Retrieves 'to' key (target language).
    );
  }

  /// 📤 **Convert Object to Map**
  /// This method is useful for storing or passing data in a structured format.
  Map<String, String> toMap() {
    Map<String, String> map = {
      'from': fromLanguage,
      'to': toLanguage,
      'input': fromText,
      'output': toText
    };
    print("📤 Converting TranslationHistoryItem to Map: $map"); // Debugging log
    return map;
  }
}
