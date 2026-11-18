import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'data/firebase_task_repository.dart';
import 'data/local_task_repository.dart';
import 'data/task_repository.dart';
import 'data/auth_gateway.dart';
import 'firebase/firebase_setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configured = FirebaseSetup.isConfigured;
  TaskRepository repository;
  AuthGateway auth;
  if (configured) {
    await Firebase.initializeApp(options: FirebaseSetup.options);
    repository = FirebaseTaskRepository();
    auth = FirebaseAuthGateway();
  } else {
    repository = LocalTaskRepository();
    auth = LocalAuthGateway();
  }

  runApp(
    TaskFlowApp(
      repository: repository,
      auth: auth,
      firebaseEnabled: configured,
    ),
  );
}
