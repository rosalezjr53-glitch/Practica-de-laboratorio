import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/domain/task_validator.dart';

void main() {
  group('TaskValidator', () {
    test('rejects an empty or whitespace-only title', () {
      expect(TaskValidator.validate(null), 'Escribe el nombre de la tarea.');
      expect(TaskValidator.validate(''), 'Escribe el nombre de la tarea.');
      expect(TaskValidator.validate('   '), 'Escribe el nombre de la tarea.');
    });

    test('accepts a trimmed title up to 80 characters', () {
      expect(TaskValidator.validate('  Estudiar Flutter  '), isNull);
      expect(TaskValidator.validate('a' * 80), isNull);
    });

    test('rejects titles longer than 80 characters', () {
      expect(TaskValidator.validate('a' * 81), 'Usa 80 caracteres o menos.');
    });
  });
}
