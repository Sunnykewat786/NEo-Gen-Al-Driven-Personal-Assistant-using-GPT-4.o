import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controller/note_controller.dart';
import '../../../model/note/note.dart';
import 'note_editor_feature.dart';

class NoteFeature extends StatelessWidget {
  final NoteController noteController = Get.find<NoteController>();

  NoteFeature({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          'Notes (${noteController.filteredNotes.length})',
          style: GoogleFonts.poppins(),
        )),
        actions: [
          Obx(() => IconButton(
            icon: Icon(noteController.isGridView.value 
                ? Icons.view_list 
                : Icons.grid_view),
            onPressed: noteController.toggleViewMode,
          )),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: noteController.searchNotes,
              decoration: InputDecoration(
                labelText: 'Search Notes',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (noteController.filteredNotes.isEmpty) {
                return Center(
                  child: Text(
                    noteController.searchQuery.isEmpty
                        ? 'Create your first note!'
                        : 'No notes found',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                );
              }
              
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: noteController.isGridView.value
                    ? GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.2 : 0.9,
                        ),
                        itemCount: noteController.filteredNotes.length,
                        itemBuilder: (ctx, index) => _buildNoteCard(
                          noteController.filteredNotes[index], 
                          context
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: noteController.filteredNotes.length,
                        itemBuilder: (ctx, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildNoteCard(
                            noteController.filteredNotes[index], 
                            context
                          ),
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const NoteEditorScreen()),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildNoteCard(Note note, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: note.isPinned ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: note.isPinned 
              ? colorScheme.primary.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.to(() => NoteEditorScreen(note: note)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    const Icon(Icons.push_pin, size: 16, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.amber[800] : Colors.amber[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      note.category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                    onPressed: () => noteController.togglePin(note.id),
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                    onPressed: () => _confirmDelete(note.id, context),
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Note?', style: GoogleFonts.poppins()),
        content: Text('This action cannot be undone', 
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.primary,
            )),
          ),
          TextButton(
            onPressed: () {
              noteController.deleteNote(id);
              Get.back();
              Get.snackbar(
                'Deleted',
                'Note has been deleted',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            child: Text('Delete', style: GoogleFonts.poppins(
              color: Colors.red,
            )),
          ),
        ],
      ),
    );
  }
}