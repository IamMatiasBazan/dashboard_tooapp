# Guía de validación de implementación — 001-admin-dashboard

Esta guía define comprobaciones para cuando se implementen las tareas desbloqueadas. No se
ejecutaron comandos de validación durante la planificación. No requiere acceso ni escritura
a una base de datos; utilizar mocks/stubs y respuestas contractuales locales.

## Prerrequisitos

- Flutter 3.47.7 stable y Dart 3.13.5.
- Dependencias aprobadas en T008: `go_router ^18.1.2`, `dio ^5.11.1`,
  `provider ^6.1.5+1`.
- Servidor API de referencia solo si se realiza una verificación HTTP autorizada. No usar
  endpoints de escritura contra datos reales. No ejecutar migraciones, seeds, `db push` ni
  comandos que escriban la base de datos.
- Para Reportes, T086/T087 completos y G11 aprobado antes de habilitar cliente conectado.

## Comprobaciones locales Flutter

Desde la raíz del dashboard, después de implementar tareas listas:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Resultado esperado: paquetes resueltos conforme a `pubspec.lock`, formato y análisis sin
errores, pruebas aisladas sin red/DB real. Añadir `test` solo cuando exista en el checkout.

## Escenarios funcionales y de seguridad

1. Iniciar sesión con respuesta ADMIN; confirmar que CLIENT, PROVIDER y SUPPORT no acceden
   al shell protegido. La autorización de API debe probarse además de la protección UI.
2. Verificar expiración: varias peticiones reciben 401 simultáneamente, pero generan una
   sola renovación coordinada; cada petición original se reintenta una vez como máximo.
   Fallo de refresh limpia tokens de memoria y redirige a login.
3. Verificar logout exitoso y fallido: siempre limpiar memoria; solo afirmar revocación
   remota al confirmar respuesta del servidor. Recarga exige login.
4. Probar drawer y rutas a `<768 px`, `768–1199 px` y `≥1200 px`; comprobar foco, teclado,
   destino activo, navegación al seleccionar en móvil y mismo inventario/permisos.
5. Categorías: validar filtros declarados, estados carga/vacío/error/403 y unificación con
   confirmación; no presentar CRUD no soportado.
6. Reportes, solo tras G11: GET con filtros `isResolved` y `type`; autor ausente y presente
   solo con nombre/apellido; PATCH resuelto confirmado, 404/401/403/red con error visible.
   Verificar que no se consuman ni registren `authorId`, `author.id`, email o phone.
7. Para pantallas bajo otros gates, probar únicamente una vez que el gate correspondiente
   aporta contratos y criterios verificables. Un módulo bloqueado no debe emitir llamadas
   ni reemplazar error/no disponible por lista vacía o valores cero.

## API

Para rutas Admin nuevas que lleguen a aprobarse, ejecutar typecheck y pruebas unitarias/API
aisladas con Prisma mock. Cubrir rol ADMIN vs no autenticado/roles no permitidos, validación,
DTO mínimo, respuestas de error y resultado de mutación. Las pruebas de Reportes reducidos
deben ser evidencia de G11 y preceder la integración Flutter. No conectar a PostgreSQL para
validar esta feature ni realizar cambios de datos/esquema.
