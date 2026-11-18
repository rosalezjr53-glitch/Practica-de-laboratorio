# 03. Plantilla de pruebas

**Estado de ejecución:** pruebas automatizadas listas para ejecutarse; casos manuales pendientes de dispositivo/emulador y de configurar Firebase. No registrar un caso como aprobado hasta adjuntar evidencia y confirmar el resultado tras reiniciar la app.

| ID | Módulo | Descripción / datos | Resultado esperado | Resultado obtenido / estado | Evidencia |
|---|---|---|---|---|---|
| CP-01 | Arranque | Abrir la app en modo local | Muestra acceso sin excepción | Pendiente | `docs/evidencias/capturas-aplicacion/` |
| CP-02 | Auth | Registrar correo de prueba y clave válida (≥6 caracteres) | Entra al listado | Pendiente; requiere Firebase | `docs/evidencias/firebase/` |
| CP-03 | Auth | Ingresar clave incorrecta | Mensaje de error y permanece en acceso | Pendiente; requiere Firebase | `docs/evidencias/firebase/` |
| CP-04 | Validación | Enviar formulario de acceso vacío | Errores visibles; no se llama al servicio | Aprobado en prueba de widget; salida adjunta | `docs/evidencias/pruebas-y-analisis/flutter-test.txt` |
| CP-05 | Navegación | Abrir «Nueva tarea» y regresar | Abre el formulario; atrás regresa al listado | Aprobado en widget test con repositorio local; salida adjunta | `docs/evidencias/pruebas-y-analisis/flutter-test.txt` |
| CP-06 | Navegación | Guardar tarea y volver | La tarea aparece en el listado | Aprobado en prueba de widget con repositorio local; salida adjunta | `docs/evidencias/pruebas-y-analisis/flutter-test.txt` |
| CP-07 | Datos | Crear tarea válida | Se guarda bajo el UID autenticado | Pendiente; requiere Firebase | `docs/evidencias/firebase/` |
| CP-08 | Datos | Consultar lista con tareas | Muestra todas las tareas del usuario | Pendiente; requiere Firebase | `docs/evidencias/firebase/` |
| CP-09 | Datos | Marcar tarea completada | Estado se conserva en Firestore y UI | Pendiente; requiere Firebase | `docs/evidencias/firebase/` |
| CP-10 | Datos | Eliminar tarea | Desaparece de UI y Firestore | Pendiente; requiere Firebase | `docs/evidencias/firebase/` |
| CP-11 | Seguridad | Intentar consultar tareas de otro UID | Reglas rechazan lectura/escritura | Pendiente; requiere dos usuarios Firebase | `docs/evidencias/firebase/` |
| CP-12 | Estados | Consultar una cuenta sin tareas | Muestra mensaje de lista vacía | Aprobado en prueba de widget con repositorio local; salida adjunta | `docs/evidencias/pruebas-y-analisis/flutter-test.txt` |
| CP-13 | Sesión | Cerrar sesión | Vuelve al acceso y oculta datos privados | Pendiente; requiere Firebase | `docs/evidencias/firebase/` |
| CP-14 | Persistencia | Cerrar y volver a abrir tras crear tarea | La sesión/lista se comportan como esperado | Pendiente; requiere Firebase | `docs/evidencias/capturas-aplicacion/` |
| CP-15 | Flujo completo | Registrar → crear → completar → eliminar → salir | Pasos terminan sin excepción y con datos correctos | Pendiente; requiere Firebase | `docs/evidencias/` |

## Automatizadas

- Unitarias: `test/unit/task_validator_test.dart` cubre valor nulo/vacío, límite válido y exceso de longitud; `test/unit/task_item_test.dart` cubre serialización y `copyWith`.
- Widget: `test/widget/task_flow_test.dart` cubre acceso inválido, lista vacía, navegación de ida/vuelta, validación del alta, creación, completar, errores de escritura, borrar y cerrar sesión con repositorios locales.
- Salida real adjunta: `flutter test` con 16 pruebas aprobadas y `flutter analyze` sin problemas. No sustituye los casos manuales en dispositivo ni las pruebas contra Firebase.

### Casos automatizados ejecutados

| ID | Caso | Resultado obtenido |
|---|---|---|
| AT-01 | Serializar y reconstruir una tarea | Aprobado |
| AT-02 | Copiar tarea cambiando su estado | Aprobado |
| AT-03 | Rechazar título nulo, vacío o con espacios | Aprobado |
| AT-04 | Aceptar título con longitud máxima | Aprobado |
| AT-05 | Rechazar título mayor a 80 caracteres | Aprobado |
| AT-06 | Enviar acceso vacío | Aprobado: muestra errores de correo y contraseña |
| AT-07 | Ingresar contraseña corta | Aprobado: conserva la pantalla de acceso |
| AT-08 | Abrir cuenta nueva sin tareas | Aprobado: muestra estado vacío |
| AT-09 | Enviar alta de tarea vacía | Aprobado: muestra validación y no navega |
| AT-10 | Regresar del formulario de alta | Aprobado: vuelve al listado |
| AT-11 | Crear tarea válida | Aprobado: aparece en la lista |
| AT-12 | Marcar tarea completada | Aprobado: cambia el estado visible |
| AT-13 | Fallar actualización remota | Aprobado con fake: mensaje visible, estado anterior conservado y sin excepción |
| AT-14 | Fallar eliminación remota | Aprobado con fake: mensaje visible, tarea conservada y sin excepción |
| AT-15 | Eliminar tarea | Aprobado: desaparece y vuelve estado vacío |
| AT-16 | Cerrar sesión local | Aprobado: vuelve a la pantalla de acceso |

AT-13 y AT-14 simulan fallos del repositorio; no son pruebas de conectividad real. Los casos de Auth/Firestore real en CP-02/03/07/08/09/11/13/14/15 siguen pendientes hasta configurar Firebase y arrancar un emulador o dispositivo.

## Reglas de resultado

Solo marcar **Aprobado** si el resultado coincide, no hay excepción no controlada, hay evidencia adjunta y el caso se repite tras reiniciar la app.
