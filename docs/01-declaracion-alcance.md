# 01. Declaración de alcance

Proyecto: **Mis tareas** (Android, Flutter). La aplicación permite crear una cuenta/acceder, crear tareas, consultar la lista, marcar tareas como completadas y eliminarlas.

| Módulo/servicio | ¿Aplica? | Observación |
|---|---|---|
| Autenticación | Sí | Firebase Authentication, correo y contraseña. Modo local disponible para desarrollo y pruebas. |
| Base de datos | Sí | Cloud Firestore, tareas bajo `users/{uid}/tasks/{taskId}`. |
| Almacenamiento | No | La app no carga archivos. |
| Notificaciones push (FCM) | No | Fuera del alcance de esta versión. |
| API REST externa | No | No consume APIs externas. |
| Otros | No | Analytics, Crashlytics y Remote Config no están incluidos. |

La configuración de Firebase depende de un proyecto creado por el estudiante. Hasta entonces, la app ejecuta el modo local; ese modo no prueba autenticación real ni persistencia remota.
