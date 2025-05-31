import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controller/note_controller.dart';
import '../../../model/note/note.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final NoteController noteController = Get.find<NoteController>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  late String selectedCategory;
  late bool isPinned;
  late List<bool> checklistItems;

  static const List<String> defaultCategories = [
    'General',
    'Work',
    'Personal',
    'Ideas'
  ];

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    selectedCategory = note?.category ?? 'General';
    isPinned = note?.isPinned ?? false;
    checklistItems = List.from(note?.checklist ?? []);

    titleController.text = note?.title ?? '';
    contentController.text = note?.content ?? '';
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'New Note' : 'Edit Note',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => isPinned = !isPinned),
          ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                noteController.deleteNote(widget.note!.id);
                Get.back();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: "Start typing your note...",
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            /*
            DropdownButton<String>(
              value: selectedCategory,
              items: (defaultCategories.contains(selectedCategory)
                      ? defaultCategories
                      : [...defaultCategories, selectedCategory])
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCategory = value);
                }
              },
              style: GoogleFonts.poppins(),
              dropdownColor: const Color.fromARGB(255, 0, 0, 0),
              isExpanded: true,
              underline: Container(
                height: 1,
                color: Colors.grey[600],
              ),
            ),
            */
            DropdownButton<String>(
  value: selectedCategory,
  items: (defaultCategories.contains(selectedCategory)
          ? defaultCategories
          : [...defaultCategories, selectedCategory])
      .map((category) => DropdownMenuItem(
            value: category,
            child: Text(
              category,
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyLarge?.color, // Adapts to theme
              ),
            ),
          ))
      .toList(),
  onChanged: (value) {
    if (value != null) {
      setState(() => selectedCategory = value);
    }
  },
  style: GoogleFonts.poppins(
    color: Theme.of(context).textTheme.bodyLarge?.color, // Text color adapts
  ),
  dropdownColor: Theme.of(context).cardColor, // Background adapts to theme
  isExpanded: true,
  underline: Container(
    height: 1,
    color: Theme.of(context).dividerColor, // Divider adapts
  ),
),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        child: const Icon(Icons.save),
      ),
    );
  }

  void _saveNote() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      Get.snackbar(
        'Error',
        'Both title and content are required.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (widget.note == null) {
      noteController.addNote(
          title, content, selectedCategory, isPinned, checklistItems);
    } else {
      noteController.editNote(widget.note!.id, title, content, selectedCategory,
          isPinned, checklistItems);
    }
    Get.back();
  }
}