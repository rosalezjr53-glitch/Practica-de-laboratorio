# practica-integracion-pruebas-flutter

Aplicación Android de lista de tareas creada con Flutter. Incluye acceso y registro por correo, listado de tareas, alta, cambio de estado y eliminación. La persistencia real utiliza Firebase Authentication y Cloud Firestore; la app también tiene un modo local de práctica para ejecutar la interfaz y las pruebas sin credenciales.

## Requisitos

- Flutter 3.47.4 y Dart 3.13.3 (versiones usadas para esta práctica).
- Android Studio o VS Code, Android SDK y emulador/dispositivo.
- Para persistencia real: un proyecto Firebase propio con Authentication por correo y Firestore habilitados.

En este equipo Flutter está en `C:\flutter\bin\flutter.bat`. En PowerShell:

```powershell
$env:CI='true'
$env:FLUTTER_SUPPRESS_ANALYTICS='true'
$env:FLUTTER_SKIP_UPDATE_CHECK='true'
$env:APPDATA="$PWD\work\appdata"
$env:PUB_CACHE="$PWD\work\pub-cache"
$env:TEMP="$PWD\work\tmp"
$env:TMP="$PWD\work\tmp"
$env:GRADLE_USER_HOME="$PWD\work\gradle"
$env:ANDROID_USER_HOME="$PWD\work\android-user"
$env:JAVA_HOME='C:\Program Files\Android\openjdk\jdk-21.0.8'
$env:PATH="$env:JAVA_HOME\bin;$env:PATH"
& 'C:\flutter\bin\flutter.bat' pub get
& 'C:\flutter\bin\flutter.bat' run
```

Sin configuración Firebase se abre el modo local de práctica. En ese modo puedes iniciar sesión con cualquier correo válido y una contraseña de 6 caracteres o más. Los datos desaparecen al cerrar la app.

## Configurar Firebase

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com/).
2. Registra una app Android con el identificador `com.practica.practica_integracion_pruebas_flutter`.
3. En **Authentication → Sign-in method**, activa **Correo electrónico/Contraseña**.
4. Crea una base de datos en **Firestore Database**.
5. Define estas variables en PowerShell con los valores de la configuración Android de tu app Firebase: `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID` y `FIREBASE_PROJECT_ID`. No subas valores privados, tokens ni archivos de cuentas de servicio.
6. Ejecuta la app pasando la configuración como `--dart-define`:

```powershell
& 'C:\flutter\bin\flutter.bat' run `
  --dart-define=FIREBASE_API_KEY=$env:FIREBASE_API_KEY `
  --dart-define=FIREBASE_APP_ID=$env:FIREBASE_APP_ID `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=$env:FIREBASE_MESSAGING_SENDER_ID `
  --dart-define=FIREBASE_PROJECT_ID=$env:FIREBASE_PROJECT_ID
```

7. Publica las reglas de `firestore.rules` en Firebase Console → Firestore → Rules. Cada usuario solo puede leer o escribir su propia colección `users/{uid}/tasks`.

## Ejecutar y validar

```powershell
& 'C:\flutter\bin\flutter.bat' analyze
& 'C:\flutter\bin\flutter.bat' test
```

El proyecto contiene pruebas unitarias del validador de tareas y pruebas de widget del formulario y el alta de una tarea. Los casos manuales, resultados y evidencias se organizan en `docs/`.

## Estructura

- `lib/`: UI, lógica, autenticación y repositorios local/Firebase.
- `test/unit/`: pruebas unitarias.
- `test/widget/`: pruebas de interfaz con repositorio local.
- `docs/`: alcance, flujos críticos, casos de prueba, incidencias y reflexión.
- `firestore.rules`: reglas de acceso a datos por usuario.

Notificaciones push, Storage y API REST quedan fuera del alcance declarado.
