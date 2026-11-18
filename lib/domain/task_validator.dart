abstract final class TaskValidator {
  static String? validate(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'Escribe el nombre de la tarea.';
    if (title.length > 80) return 'Usa 80 caracteres o menos.';
    return null;
  }
}
