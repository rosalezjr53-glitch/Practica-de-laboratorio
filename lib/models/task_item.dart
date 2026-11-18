class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
  });

  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  TaskItem copyWith({String? title, bool? isDone}) => TaskItem(
    id: id,
    title: title ?? this.title,
    isDone: isDone ?? this.isDone,
    createdAt: createdAt,
  );

  Map<String, Object?> toMap() => {
    'title': title,
    'isDone': isDone,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  factory TaskItem.fromMap(String id, Map<String, Object?> map) => TaskItem(
    id: id,
    title: map['title'] as String? ?? '',
    isDone: map['isDone'] as bool? ?? false,
    createdAt:
        DateTime.tryParse(map['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}
