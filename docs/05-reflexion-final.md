# 05. Reflexión final

La prueba de análisis estático habría detectado antes el tipo incompatible entre el validador y el formulario.
La prueba unitaria con valor nulo protege esa corrección y la suite de widget verifica que el usuario vea el mensaje esperado.
Los fakes permitieron probar los flujos de crear, completar y borrar sin depender de Firebase.
Las reglas de Firestore limitan cada colección de tareas al UID autenticado.
Un fake que lanza un error permitió comprobar que una escritura fallida informa al usuario sin cerrar la app.
Las 16 pruebas locales pasan, pero todavía debo repetir los casos manuales con Firebase real.
No pude validar persistencia remota ni el arranque en emulador porque esta sesión no logró conectar un dispositivo Android.
