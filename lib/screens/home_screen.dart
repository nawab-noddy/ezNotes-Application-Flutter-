import 'package:flutter/material.dart';
import '../models/note.dart';
import '../db/database_helper.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];      // The list currently shown on UI
  List<Note> allNotes = [];   // A copy of all data (for searching)
  bool isLoading = false;

  // Define colors again here
  final List<Color> noteColors = [
    Colors.white,
    Colors.orange.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.pink.shade100,
    Colors.yellow.shade100,
  ];

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    // Fetch data and store it in BOTH lists
    allNotes = await DatabaseHelper.instance.readAllNotes();
    notes = List.from(allNotes); // Create a copy

    setState(() => isLoading = false);
  }

  // New Search Logic
  void _runFilter(String keyword) {
    List<Note> results = [];
    if (keyword.isEmpty) {
      // If search is empty, show all notes
      results = allNotes;
    } else {
      // Filter by Title OR Content
      results = allNotes
          .where((note) =>
      note.title.toLowerCase().contains(keyword.toLowerCase()) ||
          note.content.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }

    // Refresh the UI
    setState(() {
      notes = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            onChanged: (value) => _runFilter(value), // Call filter on every keystroke
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              border: InputBorder.none,
              hintText: 'Search notes...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? const Center(child: Text('No Notes yet!', style: TextStyle(fontSize: 20)))
          : buildNotesList(),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Navigate to the NoteDetailScreen
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NoteDetailScreen()),
          );
          // When we come back, refresh the list!
          refreshNotes();
        },
      ),
    );
  }

  // Helper method to build the ListView
  Widget buildNotesList() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8, // Make items slightly taller than wide
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final color = noteColors[note.color]; // Get color from index

        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
            );
            refreshNotes();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () async {
                      await DatabaseHelper.instance.delete(note.id!);
                      refreshNotes();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}