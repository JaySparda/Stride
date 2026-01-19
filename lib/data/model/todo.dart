class Todo {
  int? id;
  final String title;
  final String category;
  final int isCompleted;
  final String createdAt;

  static const TABLE_NAME = "todos";

  Todo({
    this.id,
    required this.title,
    required this.category,
    this.isCompleted = 0,
    this.createdAt = "",
  });

  Todo copy({
    int? id,
    String? title,
    String? category,
    int? isCompleted,
    String? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "category": category,
      "isCompleted": isCompleted,
      "createdAt": createdAt,
    };
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map["id"],
      title: map["title"],
      category: map["category"],
      isCompleted: map["isCompleted"],
      createdAt: map["createdAt"],
    );
  }

  @override
  String toString() {
    return "Todo($id, $title, $category, $isCompleted, $createdAt)";
  }
}
