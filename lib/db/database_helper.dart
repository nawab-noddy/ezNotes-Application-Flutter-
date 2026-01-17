import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseHelper {
  // Singleton pattern: We only want ONE instance of the DB connection in the app
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Get the database connection
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  // Initialize the database path
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // CREATE TABLE logic (SQL)
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      createdTime TEXT NOT NULL,
      color INTEGER NOT NULL
    )
    ''');
  }

  // --- CRUD OPERATIONS ---

  // 1. Create (Insert)
  Future<int> create(Note note) async {
    final db = await instance.database;
    // db.insert returns the ID of the new row
    return await db.insert('notes', note.toMap());
  }

  // 2. Read All
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'createdTime DESC');

    // Convert List<Map> to List<Note>
    return result.map((json) => Note.fromMap(json)).toList();
  }

  // 3. Update
  Future<int> update(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?', // SQL Where clause
      whereArgs: [note.id], // Prevent SQL Injection
    );
  }

  // 4. Delete
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
