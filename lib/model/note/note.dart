import 'package:hive/hive.dart'; // Import for Hive for local database persistence.

part 'note.g.dart'; // This part directive is needed for Hive to generate the adapter.  It should be placed directly after the import.

/// Represents a note object.
/// This class defines the structure of a note, including its properties.
@HiveType(
    typeId:
        4) // HiveType annotation with a unique typeId.  This is essential for Hive.
class Note extends HiveObject {
  //  Unique identifier for the note.
  @HiveField(
      0) // HiveField annotation to specify the field's index in the Hive object.
  final String id;

  //  Title of the note.
  @HiveField(1)
  final String title;

  //  Content of the note.
  @HiveField(2)
  final String content;

  //  Category of the note (e.g., 'General', 'Work', 'Personal').
  @HiveField(3)
  final String category;

  //  Indicates whether the note is pinned.
  @HiveField(4)
  final bool isPinned;

  // Checklist of the note
  @HiveField(5)
  final List<bool> checklist;

  //  Timestamp of when the note was created or last modified.
  @HiveField(6)
  final DateTime timestamp;

  /// Constructor for the Note class.
  ///
  /// Parameters:
  ///   id (String): The unique identifier for the note.
  ///   title (String): The title of the note.
  ///   content (String): The content of the note.
  ///   category (String): The category of the note.
  ///   isPinned (bool): Whether the note is pinned.
  ///    checklist (List<bool>): the checklist of the note
  ///   timestamp (DateTime): The timestamp of the note.
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.isPinned,
    required this.checklist,
    required this.timestamp,
  });

  /// Creates a new Note object with the same properties as this object,
  /// but with some properties replaced with the non-null values from the
  /// optional parameters.  This is a helper method to facilitate updating Note objects.
  ///
  /// Parameters:
  ///   id (String, optional): The new id.
  ///   title (String, optional): The new title.
  ///   content (String, optional): The new content.
  ///   category (String, optional): The new category.
  ///   isPinned (bool, optional): The new isPinned value.
  ///    checklist (List<bool>, optional): The new checklist.
  ///   timestamp (DateTime, optional): The new timestamp.
  ///
  /// Returns:
  ///   Note: A new Note object with the updated properties.
  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    bool? isPinned,
    List<bool>? checklist,
    DateTime? timestamp,
  }) {
    return Note(
      id: id ??
          this.id, // Use the provided id if not null, otherwise use the current id.
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      checklist: checklist ?? this.checklist,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
