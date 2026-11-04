# TÖÖ Admin Dashboard

Consola administrativa web de TÖÖ construida con Flutter.

## Configurar la conexión con la API

El dashboard recibe la URL base de la API mediante el `dart-define` `TOO_API_BASE_URL`. La URL debe ser el origen donde Express sirve las rutas (sin agregar `/api`):

```sh
flutter run -d chrome --dart-define=TOO_API_BASE_URL=http://localhost:3000
```

Para compilar para web, define la misma variable en el comando de build:

```sh
flutter build web --dart-define=TOO_API_BASE_URL=https://<api-host>
```

Usa la URL del entorno de API correspondiente. No guardes credenciales, tokens ni secretos en `--dart-define`; esta variable solo identifica el host público de la API. La API debe estar levantada y aceptar el origen web del dashboard mediante su configuración CORS.

Si no se proporciona `TOO_API_BASE_URL`, las llamadas HTTP quedan deshabilitadas y el login informa que la conexión no está configurada.
