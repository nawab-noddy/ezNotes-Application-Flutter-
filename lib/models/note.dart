class Note {
  final int? id;
  final String title;
  final String content;
  final String createdTime;
  final int color; // New field!

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdTime,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdTime': createdTime,
      'color': color,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdTime: map['createdTime'],
      color: map['color'] ?? 0, // Default to 0 if null
    );
  }
}