import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../model/note/note.dart';

class NoteController extends GetxController {
  late Box<Note> noteBox;
  final RxList<Note> notes = <Note>[].obs;
  final RxList<Note> filteredNotes = <Note>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isGridView = true.obs;
  final List<String> categories = ['General', 'Work', 'Personal', 'Ideas'];

  @override
  void onInit() {
    super.onInit();
    _initializeHive();
    debounce<List<Note>>(notes, (_) => _sortAndFilterNotes(),
        time: const Duration(milliseconds: 300));
    debounce<String>(searchQuery, (_) => _sortAndFilterNotes(),
        time: const Duration(milliseconds: 300));
  }

  Future<void> _initializeHive() async {
    try {
      noteBox = await Hive.openBox<Note>('notes');
      notes.assignAll(noteBox.values.toList().reversed);
      _sortAndFilterNotes();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notes: ${e.toString()}');
    }
  }

  void addNote(String title, String content, String category, bool isPinned, List<bool> checklist) {
    if (title.isEmpty) return;
    
    final newNote = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      category: category.isNotEmpty ? category : 'General',
      isPinned: isPinned,
      checklist: checklist,
      timestamp: DateTime.now(),
    );

    noteBox.put(newNote.id, newNote);
    notes.insert(0, newNote);
  }

  void editNote(String id, String title, String content, String category, bool isPinned, List<bool> checklist) {
    final index = notes.indexWhere((note) => note.id == id);
    if (index == -1 || title.isEmpty) return;

    final updatedNote = notes[index].copyWith(
      title: title,
      content: content,
      category: category,
      isPinned: isPinned,
      checklist: checklist,
      timestamp: DateTime.now(),
    );

    noteBox.put(id, updatedNote);
    notes[index] = updatedNote;
  }

  void deleteNote(String id) {
    noteBox.delete(id);
    notes.removeWhere((note) => note.id == id);
    update();
  }

  void togglePin(String id) {
    final index = notes.indexWhere((note) => note.id == id);
    if (index == -1) return;

    final updatedNote = notes[index].copyWith(isPinned: !notes[index].isPinned);
    noteBox.put(id, updatedNote);
    notes[index] = updatedNote;
    update();
  }

  void _sortAndFilterNotes() {
    final query = searchQuery.value.toLowerCase().trim();
    
    List<Note> result = notes.where((note) {
      return query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.category.toLowerCase().contains(query);
    }).toList();

    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.timestamp.compareTo(a.timestamp);
    });

    filteredNotes.assignAll(result);
  }

  void searchNotes(String query) {
    searchQuery.value = query;
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
    update();
  }

  int get totalNotes => notes.length;
  int get pinnedNotesCount => notes.where((n) => n.isPinned).length;
}
