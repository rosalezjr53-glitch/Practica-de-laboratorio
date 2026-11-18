import 'package:flutter/material.dart';

import 'data/auth_gateway.dart';
import 'data/task_repository.dart';
import 'domain/task_validator.dart';
import 'models/task_item.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({
    super.key,
    required this.repository,
    required this.auth,
    required this.firebaseEnabled,
  });
  final TaskRepository repository;
  final AuthGateway auth;
  final bool firebaseEnabled;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mis tareas',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3157C8)),
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: AuthGate(
      repository: repository,
      auth: auth,
      firebaseEnabled: firebaseEnabled,
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.repository,
    required this.auth,
    required this.firebaseEnabled,
  });
  final TaskRepository repository;
  final AuthGateway auth;
  final bool firebaseEnabled;

  @override
  Widget build(BuildContext context) => StreamBuilder<AppUser?>(
    stream: auth.userChanges,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final user = snapshot.data;
      return user == null
          ? SignInScreen(auth: auth, firebaseEnabled: firebaseEnabled)
          : TaskListScreen(
              user: user,
              repository: repository,
              auth: auth,
              firebaseEnabled: firebaseEnabled,
            );
    },
  );
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    required this.auth,
    required this.firebaseEnabled,
  });
  final AuthGateway auth;
  final bool firebaseEnabled;
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_register) {
        await widget.auth.register(_email.text, _password.text);
      } else {
        await widget.auth.signIn(_email.text, _password.text);
      }
    } catch (error) {
      if (mounted) setState(() => _error = _authMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _authMessage(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('email-already-in-use')) {
      return 'Ese correo ya está registrado.';
    }
    if (message.contains('user-not-found') ||
        message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (message.contains('network-request-failed')) {
      return 'No hay conexión. Inténtalo de nuevo.';
    }
    return widget.firebaseEnabled
        ? 'No se pudo completar el acceso. Revisa los datos e inténtalo otra vez.'
        : 'Revisa el correo y usa una contraseña de al menos 6 caracteres.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 52,
                      color: Color(0xFF3157C8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _register ? 'Crea tu cuenta' : 'Organiza tu día',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _register
                          ? 'Regístrate para guardar tus tareas.'
                          : 'Inicia sesión para ver tus tareas.',
                      textAlign: TextAlign.center,
                    ),
                    if (!widget.firebaseEnabled) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Modo de práctica: usa cualquier correo y una contraseña de 6 caracteres o más.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('emailField'),
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        return email.contains('@') && email.contains('.')
                            ? null
                            : 'Escribe un correo válido.';
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('passwordField'),
                      controller: _password,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) => (value?.length ?? 0) < 6
                          ? 'Usa al menos 6 caracteres.'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        key: const Key('authError'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_register ? 'Crear cuenta' : 'Iniciar sesión'),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _register = !_register;
                              _error = null;
                            }),
                      child: Text(
                        _register ? 'Ya tengo una cuenta' : 'Crear una cuenta',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({
    super.key,
    required this.user,
    required this.repository,
    required this.auth,
    required this.firebaseEnabled,
  });
  final AppUser user;
  final TaskRepository repository;
  final AuthGateway auth;
  final bool firebaseEnabled;

  Future<void> _runTaskAction(
    BuildContext context, {
    required Future<void> Function() action,
    required String errorMessage,
  }) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  Future<void> _openAdd(BuildContext context) async =>
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) =>
              AddTaskScreen(userId: user.id, repository: repository),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mis tareas'),
      actions: [
        IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: auth.signOut,
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _openAdd(context),
      icon: const Icon(Icons.add),
      label: const Text('Nueva tarea'),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Text(
            'Hola, ${user.email}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (!firebaseEnabled)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Datos de demostración: no se guardan al cerrar la app.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        Expanded(
          child: StreamBuilder<List<TaskItem>>(
            stream: repository.watchTasks(user.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('No se pudieron cargar las tareas.'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final tasks = snapshot.data!;
              if (tasks.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 56,
                          color: Colors.black38,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Aún no tienes tareas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text('Pulsa «Nueva tarea» para agregar la primera.'),
                      ],
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: tasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isDone,
                        onChanged: (value) {
                          if (value == null) return;
                          _runTaskAction(
                            context,
                            action: () =>
                                repository.setTaskDone(user.id, task, value),
                            errorMessage: 'No se pudo actualizar la tarea.',
                          );
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(task.isDone ? 'Completada' : 'Pendiente'),
                      trailing: IconButton(
                        tooltip: 'Eliminar tarea',
                        onPressed: () => _runTaskAction(
                          context,
                          action: () => repository.deleteTask(user.id, task.id),
                          errorMessage: 'No se pudo eliminar la tarea.',
                        ),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    super.key,
    required this.userId,
    required this.repository,
  });
  final String userId;
  final TaskRepository repository;
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.repository.addTask(widget.userId, _title.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar la tarea.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nueva tarea')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '¿Qué necesitas hacer?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Agrega una tarea breve. Luego podrás marcarla como completada.',
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: TextFormField(
            key: const Key('taskTitleField'),
            controller: _title,
            autofocus: true,
            maxLength: 80,
            decoration: const InputDecoration(
              labelText: 'Nombre de la tarea',
              hintText: 'Ej. Repasar widgets de Flutter',
            ),
            validator: TaskValidator.validate,
            onFieldSubmitted: (_) => _save(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Guardando…' : 'Guardar tarea'),
        ),
      ],
    ),
  );
}
