import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/app.dart';
import 'package:practica_integracion_pruebas_flutter/data/auth_gateway.dart';
import 'package:practica_integracion_pruebas_flutter/data/local_task_repository.dart';
import 'package:practica_integracion_pruebas_flutter/data/task_repository.dart';
import 'package:practica_integracion_pruebas_flutter/models/task_item.dart';

void main() {
  testWidgets('empty sign-in form shows field validation', (tester) async {
    await tester.pumpWidget(
      TaskFlowApp(
        repository: LocalTaskRepository(),
        auth: LocalAuthGateway(),
        firebaseEnabled: false,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe un correo válido.'), findsOneWidget);
    expect(find.text('Usa al menos 6 caracteres.'), findsOneWidget);
  });

  testWidgets('invalid password remains on the sign-in screen', (tester) async {
    await tester.pumpWidget(
      TaskFlowApp(
        repository: LocalTaskRepository(),
        auth: LocalAuthGateway(),
        firebaseEnabled: false,
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'alumna@example.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'abc');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Usa al menos 6 caracteres.'), findsOneWidget);
    expect(find.text('Organiza tu día'), findsOneWidget);
    expect(find.text('Mis tareas'), findsNothing);
  });

  testWidgets('new account sees the empty task state', (tester) async {
    await _openHome(tester);
    expect(find.text('Aún no tienes tareas'), findsOneWidget);
  });

  testWidgets('empty task form shows validation and does not navigate', (
    tester,
  ) async {
    await _openHome(tester);
    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar tarea'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe el nombre de la tarea.'), findsOneWidget);
    expect(find.text('Nueva tarea'), findsOneWidget);
  });

  testWidgets('back navigation returns from new task to the list', (
    tester,
  ) async {
    await _openHome(tester);
    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.byKey(const Key('taskTitleField')), findsNothing);
  });

  testWidgets('user can create and see a task', (tester) async {
    await _openHome(tester);
    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Repasar widgets',
    );
    await tester.tap(find.text('Guardar tarea'));
    await tester.pumpAndSettle();

    expect(find.text('Repasar widgets'), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
  });

  testWidgets('user can mark a task complete', (tester) async {
    await _createTask(tester, 'Preparar el informe');
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(find.text('Completada'), findsOneWidget);
  });

  testWidgets('write failures show feedback without an uncaught exception', (
    tester,
  ) async {
    final repository = FailingWriteRepository();
    await _createTask(tester, 'Tarea con error', repository: repository);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('No se pudo actualizar la tarea.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text('Pendiente'), findsOneWidget);
  });

  testWidgets('delete failures show feedback and keep the task visible', (
    tester,
  ) async {
    final repository = FailingWriteRepository();
    await _createTask(tester, 'Tarea que se conserva', repository: repository);

    await tester.tap(find.byTooltip('Eliminar tarea'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('No se pudo eliminar la tarea.'), findsOneWidget);
    expect(find.text('Tarea que se conserva'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('user can delete a task', (tester) async {
    await _createTask(tester, 'Tarea para borrar');
    await tester.tap(find.byTooltip('Eliminar tarea'));
    await tester.pumpAndSettle();

    expect(find.text('Tarea para borrar'), findsNothing);
    expect(find.text('Aún no tienes tareas'), findsOneWidget);
  });

  testWidgets('user can sign out and return to login', (tester) async {
    await _openHome(tester);
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Mis tareas'), findsNothing);
  });
}

Future<void> _openHome(
  WidgetTester tester, {
  TaskRepository? repository,
}) async {
  final auth = LocalAuthGateway();
  await tester.pumpWidget(
    TaskFlowApp(
      repository: repository ?? LocalTaskRepository(),
      auth: auth,
      firebaseEnabled: false,
    ),
  );
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('emailField')),
    'alumna@example.com',
  );
  await tester.enterText(find.byKey(const Key('passwordField')), 'clave123');
  await tester.tap(find.text('Iniciar sesión'));
  await tester.pumpAndSettle();
  expect(find.text('Mis tareas'), findsOneWidget);
}

Future<void> _createTask(
  WidgetTester tester,
  String title, {
  TaskRepository? repository,
}) async {
  await _openHome(tester, repository: repository);
  await tester.tap(find.text('Nueva tarea'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('taskTitleField')), title);
  await tester.tap(find.text('Guardar tarea'));
  await tester.pumpAndSettle();
  expect(find.text(title), findsOneWidget);
}

class FailingWriteRepository extends LocalTaskRepository {
  @override
  Future<void> setTaskDone(String userId, TaskItem task, bool isDone) async {
    throw StateError('Simulated Firestore network error');
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    throw StateError('Simulated Firestore network error');
  }
}
