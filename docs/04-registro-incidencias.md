# 04. Registro de incidencias

Incidencias encontradas durante el análisis, pruebas automatizadas y revisión del flujo de escritura. Las cinco están corregidas; INC-001 tiene prueba de regresión unitaria, e INC-005 tiene prueba de widget que simula un error de Firestore.

| ID | Severidad / prioridad | Origen | Pasos de reproducción | Causa | Corrección / commit | Regresión y estado |
|---|---|---|---|---|---|---|
| INC-001 | Alta / P1 | Tipo estático en validación de formulario | Ejecutar `flutter analyze` con `TaskValidator.validate` conectado a `TextFormField.validator` | El validador aceptaba `String`, pero Flutter entrega un valor nullable | Cambiar firma a `String?`; validar null como título vacío. Commit `5cbe912` | Reprobada y corregida: unit test de null y `flutter analyze` sin problemas |
| INC-002 | Baja / P2 | Lint de Dart | Ejecutar `flutter analyze` | Varias ramas `if` sin llaves generaban 7 avisos de estilo | Añadir llaves a las ramas señaladas. Commit `5cbe912` | Reprobada y corregida: `flutter analyze` sin problemas |
| INC-003 | Baja / P2 | Configuración de análisis local | Ejecutar `flutter analyze` con Pub cache en `work/pub-cache` | El analizador recorría paquetes y pruebas de dependencias dentro de la carpeta de trabajo y reportaba más de 28 mil problemas ajenos a la app | Excluir `work/**` en `analysis_options.yaml`. Commit `5cbe912` | Reprobada y corregida: el analizador solo inspecciona el proyecto y termina sin problemas |
| INC-004 | Media / P1 | Código de pruebas | Ejecutar `flutter test` | `DateTime.utc` no es una expresión constante, pero la tarea del caso estaba declarada `const` | Cambiar el fixture a `final`; commit `5cbe912` | Reprobada y corregida: las 16 pruebas pasan, incluidas serialización y `copyWith` |
| INC-005 | Alta / P1 | Escritura de datos / manejo de errores | Marcar como completada o eliminar una tarea con fallo del repositorio (fake que lanza `StateError`) | Las acciones de actualización y borrado no atrapaban el error asíncrono; la UI no mostraba resultado y podía llegar una excepción no controlada | Centralizar el manejo en `_runTaskAction`; mostrar un mensaje claro y conservar el estado anterior. Commit `8dfd955` (`fix: INC-005 handle task write failures`) | Reprobada y corregida: dos widget tests verifican mensajes y estado conservado sin excepción; `flutter test` pasa con 16 pruebas |

El APK no se compiló en esta sesión. El SDK Android requirió instalar Android CLI y después falló al guardar su índice; el emulador x86_64 no inició porque esta sesión no dispone de la aceleración Hyper-V/Windows Hypervisor Platform. Las salidas se adjuntan en `docs/evidencias/pruebas-y-analisis/`. Estos bloqueos no se cuentan como defectos corregidos de la aplicación.

## Método de 5 pasos

Para la incidencia de mayor prioridad, registrar: 1) reproducir el fallo; 2) leer la traza y el flujo; 3) proponer una causa comprobable; 4) comprobarla con un caso mínimo; 5) corregir, añadir/regresar la prueba y registrar el commit `fix: INC-001 ...`.
