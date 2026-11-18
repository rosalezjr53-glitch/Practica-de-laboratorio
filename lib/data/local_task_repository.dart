import 'dart:async';

import '../models/task_item.dart';
import 'task_repository.dart';

/// In-memory repository for onboarding and automated UI tests.
class LocalTaskRepository implements TaskRepository {
  final Map<String, List<TaskItem>> _tasksByUser = {};
  final Map<String, StreamController<List<TaskItem>>> _controllers = {};

  @override
  Stream<List<TaskItem>> watchTasks(String userId) {
    final controller = _controllers.putIfAbsent(
      userId,
      () => StreamController<List<TaskItem>>.broadcast(),
    );
    scheduleMicrotask(() => controller.add(List.unmodifiable(_for(userId))));
    return controller.stream;
  }

  List<TaskItem> _for(String userId) =>
      _tasksByUser.putIfAbsent(userId, () => []);

  void _publish(String userId) {
    final controller = _controllers[userId];
    if (controller != null && !controller.isClosed) {
      controller.add(List.unmodifiable(_for(userId)));
    }
  }

  @override
  Future<void> addTask(String userId, String title) async {
    _for(userId).insert(
      0,
      TaskItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.trim(),
        isDone: false,
        createdAt: DateTime.now(),
      ),
    );
    _publish(userId);
  }

  @override
  Future<void> setTaskDone(String userId, TaskItem task, bool isDone) async {
    final tasks = _for(userId);
    final index = tasks.indexWhere((item) => item.id == task.id);
    if (index >= 0) tasks[index] = task.copyWith(isDone: isDone);
    _publish(userId);
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    _for(userId).removeWhere((task) => task.id == taskId);
    _publish(userId);
  }
}
