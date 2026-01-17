import 'package:flutter/material.dart';
import '../models/note.dart';
import '../db/database_helper.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note; // If null, we are adding. If not null, we are editing.

  const NoteDetailScreen({super.key, this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  // Controllers capture what the user types
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If we are editing, pre-fill the text fields
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      selectedColor = widget.note!.color; // Load saved color
    }
  }

  // Save logic
  Future addOrUpdateNote() async {
    // Basic validation
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      return;
    }

    final isUpdating = widget.note != null;

    if (isUpdating) {
      await updateNote();
    } else {
      await addNote();
    }

    // Go back to the previous screen (Home)
    Navigator.of(context).pop();
  }

  Future updateNote() async {
    final note = Note(
      id: widget.note!.id, // Keep the old ID
      title: _titleController.text,
      content: _contentController.text,
      createdTime: DateTime.now().toString(),
      color: selectedColor,
    );

    await DatabaseHelper.instance.update(note);
  }

  Future addNote() async {
    final note = Note(
      title: _titleController.text,
      content: _contentController.text,
      createdTime: DateTime.now().toString(),
      color: selectedColor,
    );

    await DatabaseHelper.instance.create(note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        actions: [
          IconButton(
            onPressed: addOrUpdateNote,
            icon: const Icon(Icons.check), // The Save Button
          ),
        ],
      ),
      // Inside build(), replace the body with this:
      body: Column(
        children: [
          // --- Title & Content (Same as before) ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _contentController,
                style: const TextStyle(fontSize: 18),
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Type something...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // --- Color Picker Bar (New!) ---
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: noteColors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: noteColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColor == index
                            ? Colors.black
                            : Colors.grey,
                        width: selectedColor == index ? 3 : 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int selectedColor = 0; // Default white
  final List<Color> noteColors = [
    Colors.white,
    Colors.orange.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.pink.shade100,
    Colors.yellow.shade100,
  ];
}
