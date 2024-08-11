class Task {
  int? id;
  final String title;
  final String description;
  bool? isCompleted;
  Task({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': (isCompleted ?? false) ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description,   isCompleted: $isCompleted)';
  }
}
