import '../models/task_item.dart';

abstract interface class TaskRepository {
  Stream<List<TaskItem>> watchTasks(String userId);
  Future<void> addTask(String userId, String title);
  Future<void> setTaskDone(String userId, TaskItem task, bool isDone);
  Future<void> deleteTask(String userId, String taskId);
}
