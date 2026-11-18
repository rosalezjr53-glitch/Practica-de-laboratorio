import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_item.dart';
import 'task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  FirebaseTaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('tasks');

  @override
  Stream<List<TaskItem>> watchTasks(String userId) =>
      _collection(userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => TaskItem.fromMap(doc.id, doc.data()))
                .toList(),
          );

  @override
  Future<void> addTask(String userId, String title) => _collection(userId).add(
    TaskItem(
      id: '',
      title: title.trim(),
      isDone: false,
      createdAt: DateTime.now(),
    ).toMap(),
  );

  @override
  Future<void> setTaskDone(String userId, TaskItem task, bool isDone) =>
      _collection(userId).doc(task.id).update({'isDone': isDone});

  @override
  Future<void> deleteTask(String userId, String taskId) =>
      _collection(userId).doc(taskId).delete();
}
