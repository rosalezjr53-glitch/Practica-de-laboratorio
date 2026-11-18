import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/models/task_item.dart';

void main() {
  test('task map round trip preserves the fields', () {
    final createdAt = DateTime.utc(2026, 11, 11, 10, 30);
    final task = TaskItem(
      id: 'task-1',
      title: 'Repasar Firebase',
      isDone: true,
      createdAt: createdAt,
    );

    final restored = TaskItem.fromMap(task.id, task.toMap());

    expect(restored.id, task.id);
    expect(restored.title, task.title);
    expect(restored.isDone, isTrue);
    expect(restored.createdAt, createdAt);
  });

  test('copyWith changes completion without changing other fields', () {
    final createdAt = DateTime.utc(2026, 11, 11);
    final task = TaskItem(
      id: 'task-2',
      title: 'Leer',
      isDone: false,
      createdAt: DateTime.utc(2026, 11, 11),
    );

    final completed = task.copyWith(isDone: true);

    expect(completed.isDone, isTrue);
    expect(completed.id, task.id);
    expect(completed.title, task.title);
    expect(completed.createdAt, createdAt);
  });
}
