# Plan técnico: Administración de usuarios y prestadores de TÖÖ

**Rama**: `001-admin-dashboard` | **Fecha**: 2026-11-04 | **Especificación**: [spec.md](spec.md)

## Resumen

Planificar una consola administrativa Flutter Web con drawer vertical responsive,
autenticación para `ADMIN`, módulos por funcionalidad y modelos tipados, además de la API
administrativa necesaria en el proyecto Node.js/Express/Prisma. La especificación vigente
define el producto; Prisma define persistencia; las rutas, schemas y guards definen las
capacidades API actuales.

El checkout actualmente contiene `lib/src/app`, `lib/src/core`, features de acceso,
lecturas Admin, categorías y reportes, con router, tema, sesión y cliente HTTP. Las
mutaciones Admin aprobadas de perfiles y categorías están implementadas en el checkout API.
Los breakpoints
aprobados son móvil web `<768 px`, tablet `768–1199 px`, escritorio `≥1200 px`. Flutter
3.47.7/Dart 3.13.5; dependencias aprobadas y presentes, incluyendo `font_awesome_flutter`.

El API respalda listado, unificación y mantenimiento permitido de categorías; listado y
resolución de reportes; lecturas Admin; y edición aprobada de perfiles/cuentas. Las clarificaciones
del 2026-11-04 aprueban nuevas escrituras Admin para editar perfiles con las allowlists y
validaciones existentes, activar/desactivar `User.isAccountActive` y crear/editar/activar/
desactivar categorías. Estas rutas se implementaron en el checkout API con guard `ADMIN`;
se prohíben cambios a schema Prisma, migraciones y modificaciones manuales de datos.
Reseñas, portafolios y membresías permanecen solo lectura. No se agregan eliminaciones,
moderación ni pagos.

## Contexto técnico

**Cliente**: Flutter Web; Flutter `3.47.7 stable`, Dart SDK `^3.13.5`; Flutter SDK,
`flutter_test`, `flutter_lints: ^6.0.0`, `go_router ^18.1.2`, `dio ^5.11.1`,
`provider ^6.1.5+1` y `font_awesome_flutter ^11.0.0` constan en `pubspec.yaml`/lockfile.
`ChangeNotifier` proviene de Flutter.

**API de referencia**: Node.js `>=22 <25`, Express 5, TypeScript, Prisma, PostgreSQL con
PostGIS, JWT, bcrypt, cors, dotenv y Zod según `/Users/matybazan/Documents/api-tooapp`.

**Almacenamiento**: esquema Prisma vigente. No se justifican migraciones para entidades
existentes. `Service`, estado de moderación, auditoría, suspensión/historial o suscripción
solo podrán incorporarse tras decisiones de dominio explícitas.

**Sesión web**: access y refresh tokens solo en memoria. Ante 401, coordinar una renovación
con `/auth/refresh` usando el refresh token en el body, reemplazar ambos tokens y reintentar
una vez la petición original. Si falla, limpiar sesión y volver a login. Logout envía Bearer
access y refresh token actual a `/auth/logout`, limpia siempre memoria y no afirma revocación
remota cuando la solicitud falla. Recargar la página requiere login; no usar
`localStorage`, `sessionStorage` ni IndexedDB.

**Pruebas previstas**: `flutter analyze`, formatter, pruebas Flutter unitarias/widgets;
pruebas HTTP/contrato/integración con Vitest/Supertest del API. Solo se planifican ahora;
no se ejecutan.

**Rendimiento**: sin SLA inventados. Los listados usarán paginación solo cuando el contrato
vigente la soporte; los endpoints actuales de categorías y reportes no la ofrecen. Los
agregados calculados no serán editables.

**Restricciones**: solo `ADMIN` entra en v1; `SUPPORT`, `CLIENT` y `PROVIDER` no reciben
acceso. `ADMIN` se aprovisiona fuera del registro público y usa login existente. No pagos,
registro público de administradores, CRUD de localidades, DNI, `isDniVerified`, coordenadas
ni ubicación precisa. Teléfono solo en detalle si el DTO lo autoriza; nunca en listados.

**Alcance**: se trazan por separado las 27 pantallas numeradas en la especificación.
Reportes es un destino independiente del drawer; auditoría es una dependencia, no pantalla
v1. La decisión de privacidad está resuelta: la consola solo puede consumir
`author.firstName` y `author.lastName`, opcionales. Las integraciones GET/PATCH dependen de
que el propietario del API entregue y apruebe respuestas reducidas que omitan
`authorId`, `author.id`, email y phone.

## Inspección de código y contrato

### Dashboard

- Solo existe `lib/main.dart`; no hay carpetas `lib/src`, `test`, arquitectura Flutter,
  dependencias de red/estado/rutas o breakpoints numéricos.
- `analysis_options.yaml` incluye `flutter_lints`; la configuración de Web no define
  breakpoints de producto. La decisión aprobada en la especificación establece `<768 px`
  móvil web, `768–1199 px` tablet y `≥1200 px` escritorio.

### API existente

| Dominio | Contrato y guard observados | Consecuencia para el plan |
|---|---|---|
| Autenticación | `POST /auth/login`, `/auth/refresh`, `/auth/logout`. `POST /auth/register` limita `role` a `CLIENT`/`PROVIDER`. Bearer JWT y refresh token en body. Refresh rota el token; logout revoca el refresh asociado al usuario/token cuando recibe el valor actual. | Reusar endpoints existentes; aprovisionar admins fuera del registro. Aplicar la sesión web en memoria aprobada; logout fallido no implica revocación remota. |
| Categorías | `GET /admin/categories?status&active`, `POST /admin/categories/unify`, `POST /admin/categories`, `PATCH /admin/categories/:categoryId`, `PATCH /admin/categories/:categoryId/active`, con `authenticate` + `requireRole('ADMIN')`. `POST /categories` no es permiso Admin. | Rutas nuevas limitadas a `name`, `iconUrl`, `isActive` existentes; no DELETE ni cambios en `status`. Contratos y pruebas simuladas añadidos; sin Prisma/DB schema changes. |
| Reportes | `GET /admin/reports?isResolved&type` y `PATCH /admin/reports/:id/resolve`; ambos usan `authenticate` y `requireRole('ADMIN')`. Query valida `isResolved=true|false` y `type=SUGGESTION|CLAIM|USER_REPORT`; `id` debe ser UUID; PATCH no recibe body. | T086 redujo el contrato y los selects; T087 verificó las respuestas con pruebas sin DB. GET/PATCH omiten `authorId`, `author.id`, email y phone; GET puede incluir `author?` solo con `firstName` y `lastName`. G11 está satisfecho. No hay detalle separado ni paginación; 404 si no existe. |
| Usuarios | `GET /admin/users`, `GET /admin/users/:userId`, `PATCH /admin/users/:userId` y `PATCH /admin/users/:userId/account-status`; perfil solo CLIENT, estado CLIENT/PROVIDER. | Escritura implementada con guard ADMIN, allowlist `ownUserPatchSchema`, estado booleano separado y pruebas simuladas; sin cambios Prisma ni reutilización de permisos autoservicio. |
| Prestadores | `GET /admin/providers`, `/admin/providers/:providerProfileId` y subsección de reviews con guard ADMIN. El listado omite teléfono/avatar y el detalle los limita a `ADMIN`. | `PATCH /admin/providers/:providerProfileId` está implementado con guard ADMIN. El body divide `user` (`ownUserPatchSchema`) y `providerProfile` (`providerFields`); excluye rol, `isAccountActive`, DNI/verificaciones, `baseLocation`, coordenadas y agregados. No habilita Service. |
| Categorías públicas | `GET /categories`; `POST /categories` crea categoría personalizada autenticada, sin guard Admin específico. | No reutilizar la creación de usuario/proveedor como permiso administrativo. |
| Contactos/reseñas/portfolio | GET Admin existentes, DTOs minimizados. | Contactos, reseñas y portafolios quedan solo lectura; `problemDescription` excluido y sin moderación ni borrado Admin. |
| Membresías | `GET /admin/membership-tiers` y `GET /admin/membership-tiers/:tierId` exponen solo campos de `MembershipTier`. | Lectura disponible; por decisión v1 no habrá escrituras. No existen compra, periodo, suscripción ni pagos. |
| Ubicaciones/localidades | Availability es Provider. `Locality` tiene GET de localidades habilitadas. Geometry `baseLocation/currentLocation` es `Unsupported` en Prisma. | DTO Admin puede incluir solo localidad relacionada, si está autorizada. No devolver coordenadas ni crear mantenimiento/búsqueda CRUD. |
| Auditoría | No hay modelo ni ruta. | No mostrar historial. Definir capacidad antes de habilitar cambios sensibles que deban atribuirse. |

Los schemas de `/admin/categories` y `/admin/reports` no contienen paginación. La UI no
ofrecerá paginación para esos endpoints ni afirmará que el listado es completo en escenarios
de volumen que el API no limite; cualquier cambio de contrato quedaría fuera de este plan.

## Constitution Check

| Requisito constitucional | Evaluación |
|---|---|
| Inventario por área, entidad, dato y permiso | ✅ Matriz posterior conserva #1–27 y separa capacidades actuales, dependencias y pantallas globales/subsecciones. |
| Fidelidad al API y manejo de vacíos | ✅ Las escrituras aprobadas tienen rutas protegidas implementadas y pruebas simuladas. Sin cambios de schema, migraciones o campos; las rutas mutan únicamente registros/campos existentes en runtime. |
| Autorización y mínimo privilegio | ✅ UI guarda navegación; servidor aplica `authenticate`/`requireRole('ADMIN')` en cada operación. No hay acceso SUPPORT. DTO minimiza datos. |
| Drawer responsive | ✅ Mismo árbol de áreas; persistente en escritorio (`≥1200 px`), colapsable en tablet (`768–1199 px`) y lateral accesible en móvil web (`<768 px`). Estados pendientes no son acciones. |
| Capas y tipos | ✅ Estructura `app/core/features`; presentation/estado/data/modelos; modelos cliente tipados, parseo en límite HTTP, no `dynamic`. |
| Identidad y accesibilidad | ⚠ Diseño debe verificar identidad visual en fuente existente; breakpoints aprobados, tokens de diseño todavía por inspeccionar/proponer. |
| Estados, resiliencia y métricas | ✅ carga/vacío/error/éxito/403, éxito confirmado por API, cálculo no editable, errores parciales visibles. Sin SLA arbitrario. |
| Pruebas y seguridad | ✅ Flutter analyze y 44 pruebas UI, API typecheck/lint y 27 pruebas unitarias Admin ejecutadas con doubles; no se conectó a DB. |

**Gates de implementación por capacidad**: los breakpoints están aprobados; G7-U/G7-P/G8
y G11 están resueltos con rutas y pruebas. G4 métricas y G9 Services siguen bloqueados por
falta de fuente/entidad. G10 se cierra como solo lectura en v1.
Auditoría permanece sin soporte: no inventar historial ni guardar acciones en tabla nueva.

**Revisión posterior al diseño**: revalidar modelos/DTOs, guards, campos sensibles,
estados, responsive y que cada control activo tenga contrato de servidor.

## Arquitectura y estructura propuesta

La estructura base `lib/src/app`, `core` y features existe en el checkout. Las extensiones
por feature y formularios enumerados abajo son rutas propuestas donde el archivo aún no
existe; deben confirmarse en `tasks.md` contra el árbol real antes de implementarse:

```text
lib/
├── main.dart
└── src/
    ├── app/
    │   ├── app.dart
    │   ├── router/admin_router.dart
    │   └── layout/{admin_scaffold.dart,admin_drawer.dart,responsive_admin_layout.dart}
    ├── core/
    │   ├── config/app_config.dart
    │   ├── network/{api_client.dart,api_failure.dart}
    │   ├── session/{admin_session.dart,session_provider.dart}
    │   ├── theme/{admin_theme.dart,admin_tokens.dart}
    │   ├── widgets/{async_state_view.dart,confirmation_dialog.dart}
    │   └── utils/
    └── features/
        ├── access/{data,models,presentation}
        ├── dashboard/{data,models,presentation}
        ├── users/{data,models,presentation}
        ├── providers/{data,models,presentation}
        ├── categories/{data,models,presentation}
        ├── services/{data,models,presentation}       # bloqueado por falta de entidad/API
        ├── portfolios/{data,models,presentation}
        ├── contacts/{data,models,presentation}
        ├── reviews/{data,models,presentation}
        ├── availability/{data,models,presentation}
        ├── memberships/{data,models,presentation}
        └── reports/{data,models,presentation}         # módulo v1; contrato reducido verificado por T086–T087
```

No crear feature payments, locality CRUD, admin-management o audit en v1. `services` no
puede tener datos o acciones reales hasta aprobar modelo/contrato. `reports` es módulo v1;
sus consultas y resolución consumen el contrato API reducido y verificado en G11. La ausencia opcional de `author` nunca bloquea mostrar o
resolver el reporte.

- `go_router`: declara rutas, UUID, rutas de retorno y guard de navegación por sesión/rol;
  estos guards no reemplazan autorización API. Registrar `/reports` como ruta protegida a
  `features/reports/presentation/report_list_page.dart`.
- `AdminDrawer`: catálogo tipado de módulos/ruta/permiso/disponibilidad, estado activo,
  navegación por teclado y menú lateral compacto; incluir **Reportes** como destino
  independiente con ruta `/reports`. Un módulo bloqueado no llama repositorio.
- `Dio`: cliente HTTP centralizado, base URL por configuración, Bearer, refresh/logout,
  errores tipados y no exposición de cuerpo sensible. Tokens solo en memoria; renovación
  coordinada una vez y reintento único; cierre remoto best-effort con resultado comunicado
  con precisión.
- `Provider`/`ChangeNotifier`: estado por feature; widgets no llaman HTTP ni parsean JSON.
  DTOs/mappers tipados no reproducen todos los campos Prisma por defecto.
- Tema/tokens centralizados. Revisar identidad TÖÖ en fuente móvil solo para obtener
  referencias visuales; documentar propuestas de dashboard como tales.
- Layout usa los breakpoints aprobados: móvil web `<768 px`, tablet `768–1199 px` y
  escritorio `≥1200 px`; mantener el mismo inventario y permisos en los tres modos.

### API — rutas y contratos Admin implementados

El API es un checkout separado `/Users/matybazan/Documents/api-tooapp`; esta implementación
fue autorizada por el propietario. Las lecturas Admin nuevas se agrupan en
`src/modules/admin-read/{routes,controller,service,repository,schema}.ts`, se montan desde
`src/routes.ts` y tienen contrato en
`specs/001-too-api-functional-spec/contracts/rest-api.md`.

- Admin read: listar/detallar CLIENT, listar/detallar perfiles Provider, listar Reviews y
  Portfolio, consultar ContactIntent sin texto libre y leer MembershipTier; todas usan
  `authenticate`, `requireRole('ADMIN')`, Zod, paginación acotada y selección Prisma explícita.
- Categories y Reports conservan sus rutas Admin preexistentes y contratos específicos.
- Las rutas Admin implementadas cubren las escrituras aprobadas de perfiles/cuentas y categorías.
  No se agregan rutas para moderación, servicios, pagos o escritura de membresías porque faltan
  soporte o decisiones vigentes.
- Agregados: implementar consultas agregadas en servicio/repository; no persistir contadores
  derivados nuevos. Resolver fuente/conteo en caso de usuarios con relación ProviderProfile.
- Toda ruta Admin debe usar Zod, `authenticate`, `requireRole('ADMIN')`, controller delgado,
  servicio de negocio y consultas Prisma limitadas a DTO permitido. Mantener envelopes
  `{data}` y `{error:{code,message}}` actuales.
- No exponer `passwordHash`, refresh tokens/hashes, DNI, `isDniVerified` ni geometrías.
  Teléfono solo en detalle autorizado; localidad únicamente si se permite y existe relación.
- No agregar migración para entidades ausentes hasta aprobar decisiones sobre `Service`,
  moderación, `AuditEvent`, suspensión o suscripción. Evitar borrados en cascada Admin sin
  política explícita, confirmación y análisis de relaciones.

## Mapeo de todas las pantallas y flujos

La numeración remite a la especificación y no combina pantallas globales con subsecciones
de prestador. En todas: sesión ADMIN, autorización server-side, carga/vacío/error/403 y
no-disponible según corresponda. “Pendiente” significa bloqueado para datos/operaciones
reales hasta tener contrato; no significa que se pueda rellenar con datos simulados.

| # y pantalla | Cliente Flutter propuesto | API/datos/permiso y trabajo | Validación verificable prevista |
|---|---|---|---|
| 1 Dashboard/resumen | `features/dashboard` | `User`, `ProviderProfile`, `Category`, `ContactIntent`, `Review`; no hay agregador Admin. Definir fuente, conteo prestadores/contactos y ventana de reseñas. Servicio publicado y moderación no existen. | Cada tarjeta carga/error/vacío independiente; no mostrar conteo parcial como total; cero solo tras respuesta válida; enlace solo a lista autorizada. |
| 2 Usuarios/listado | `user_list_page.dart` | `GET /admin/users` existente en `src/modules/admin-read`; `User` DTO: nombre/apellido/email nullable/`createdAt`/`isAccountActive`; sin teléfono/DNI. Filtros/paginación según schema actual. | Validar solo query contractual, carga, vacío, 401/403/5xx; abrir #3; preservar búsqueda/página al volver. |
| 3 Usuarios/detalle | `lib/src/features/admin_read/presentation/admin_read_pages.dart` | `GET /admin/users/:userId`; `User`, localidad opcional; no hay categoría/radio persistido del cliente. Teléfono/avatar solo en detalle ADMIN; DNI excluido. | Null no disponible; carga/no encontrado/error/403; no consultar endpoint de otro rol. |
| 4 Usuarios/edición | `lib/src/features/admin_read/presentation/user_edit_page.dart`; módulo existente `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/` | `PATCH /admin/users/:userId` implementado; reusa `ownUserPatchSchema` y guard ADMIN. | Validar schema existente; unicidad/error conservan cambios; éxito solo respuesta confirmada. Sin cambios Prisma. |
| 5 Usuarios/estado de cuenta | Acción de ficha/listado; módulo existente `src/modules/admin-read/*` del API | `PATCH /admin/users/:userId/account-status` implementado con `isAccountActive`; sin semántica adicional de suspensión, motivo o historial. | Confirmación antes de mutar; actualizar solo desde respuesta; 401/403/red/error no cambia vista. |
| 6 Prestadores/listado | `provider_list_page.dart` | `GET /admin/providers` existente; `User` role PROVIDER + `ProviderProfile`; listado sin teléfono/DNI; categoría y disponibilidad efectiva del DTO. | Query solo contractual; vacío/error/403; no recuperar datos vía `/provider/me/*`; abrir #7. |
| 7 Prestadores/detalle | `provider_detail_page.dart` | `GET /admin/providers/:providerProfileId` existente; `User` 1:1 `ProviderProfile`; disponibilidad efectiva, localidad y portfolio count según DTO. Sin servicios publicados. | No traducir no expuesto a cero; agregados no editables; links a subsecciones solo para perfil real. |
| 8 Perfil personal/profesional | `lib/src/features/admin_read/presentation/admin_read_pages.dart` | DTO de `GET /admin/providers/:providerProfileId`; User y ProviderProfile; sin specialty/estado de aprobación general. DNI y `isDniVerified` no se muestran; teléfono/avatar solo en detalle ADMIN. | Null/error/403; distinguir disponibilidad de verificación; excluir secretos. |
| 9 Edición perfil | `lib/src/features/admin_read/presentation/provider_edit_page.dart`; módulo existente `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/` | `PATCH /admin/providers/:providerProfileId` implementado. `user` reutiliza `ownUserPatchSchema`; `providerProfile` reutiliza `providerFields`; teléfono/avatar disponibles solo en detalle ADMIN, no en listados. | Enviar secciones con cambios permitidos; aplicar validadores existentes, guard ADMIN independiente, error conserva cambios y éxito confirmado por API. Sin cambios Prisma. |
| 10 Oficios/servicios publicados dentro de ficha | `provider_services_page.dart` | Category primaria + `ProviderSecondaryCategory`; no `Service`, publicación ni fecha. No endpoint Admin. | Mostrar “categorías asociadas” solo con DTO; bloquear cantidad de servicios/CRUD de servicios. |
| 11 Tarifas/facturación perfil | Ficha y `provider_edit_page.dart` | `ProviderProfile` ofrece `minPrice`, `chargesConsultation`, `consultationPrice`, `issuesInvoice`, `invoiceType`; son editables mediante `PATCH` según `providerFields`; no hay modalidad por servicio ni fiscalidad completa. | Valores indicativos del perfil; null/no disponible; sin pago/factura/transacción; no son tarifas de Services. |
| 12 Disponibilidad | `provider_availability_page.dart` | `GET /admin/providers` y detalle devuelven `isAvailable`, `shiftEndsAt`, `lastPulseAt`, `availabilityLocationSource`. | Disponibilidad efectiva si flag true y fin futuro; no editar pulse; error/403. |
| 13 Ubicaciones | `provider_location_page.dart` | DTO Admin actual permite localidad relacionada si está incluida; geometry `Unsupported`. | Sin coordenadas, mapa, ubicación precisa, radio como proxy o CRUD Locality; null/error/403 diferenciado. |
| 14 Portfolio dentro de ficha | `provider_portfolio_page.dart` | `GET /admin/portfolio?providerProfileId=...`; `imageUrl`, `createdAt`, relación; sin título/descr/moderation. | Solo consulta; imagen fallida con alternativa; carga/vacío/error. |
| 15 Portafolios/listado global | `features/portfolios/presentation/portfolio_list_page.dart` | `GET /admin/portfolio` existente, filtro por perfil según schema actual. | No filtrar estado inexistente; vínculo a prestador; sin moderación/borrado; estados vacío/error. |
| 16 Reseñas en ficha | `provider_reviews_page.dart` | `GET /admin/providers/:providerProfileId/reviews`; `Review` y agregados según DTO. | Sin estado moderación; null no equivale a cero; promedio/total no editables; solo lectura. |
| 17 Reseñas/global | `features/reviews/presentation/review_list_page.dart` | `GET /admin/reviews` existente; filtros disponibles según schema Admin; no hay `moderationStatus`. | Lista solo lectura; no ocultar/retirar/borrar; carga/vacío/error/403. |
| 18 Categorías/listado | `category_list_page.dart` | Integrar `GET /admin/categories`; filtros `status`/`active`; ADMIN; `Category`. | Valores enum exactos; carga/vacío/401/403/5xx; conteos solo si response los incluye, nunca sobre página parcial. |
| 19 Categorías/alta y edición | `category_form_page.dart`; extender `/Users/matybazan/Documents/api-tooapp/src/modules/categories/{categories.routes.ts,categories.controller.ts,categories.service.ts,categories.repository.ts,categories.schema.ts}` | Aprobado, rutas propuestas `POST /admin/categories` y `PATCH /admin/categories/:categoryId`; solo `name`, `iconUrl`; reusar schema actual (trim 2–100, URL nullable/opcional). | Guard ADMIN, unicidad/errores existentes, respuesta confirmada; no crear campos ni cambiar esquema. No presentar rutas como existentes. |
| 20 Categorías/estado/unificación | `category_actions.dart`, `category_unify_dialog.dart`; extender archivos de `src/modules/categories/*` indicados en #19 | `PATCH /admin/categories/:categoryId/active` propuesto para `isActive`; `POST /admin/categories/unify` confirmado. Cambios de `status` y DELETE excluidos por decisión. | Confirmar activar/desactivar y origen/destino unificación; respetar relaciones actuales y transacción de unificación; error no produce éxito; sin eliminación ni schema changes. |
| 21 Servicios/tarifas listado global | `features/services/presentation/service_list_page.dart` | No modelo Service ni endpoint; precios de perfil no son tarifas de servicio. | Sin resultados ficticios; no declarar 0; bloqueado por decisión de dominio/schema/API. |
| 22 Servicio detalle/mantenimiento | `service_detail_page.dart`, `service_edit_page.dart` | No entidad/DTO/operaciones; pagos excluidos. | No CRUD hasta definir campos, relaciones, permisos, estados, validaciones y migración aprobada. |
| 23 Contactos/listado | `features/contacts/presentation/contact_list_page.dart` | `ContactIntent`; API actual CLIENT crea/lee propio/cambia estado. No listado Admin; canal WhatsApp no demostrado. | Definir “recibido”; no usar endpoints Client; minimizar `problemDescription`; estados y filtro solo contrato. |
| 24 Contacto/detalle | `contact_detail_page.dart` | Relaciones a Client, ProviderProfile, Category, status/scheduledFor/dates; no detalle Admin. | No conversaciones; texto personal solo con permiso/need; no mutar status vía endpoint CLIENT; null/error/403. |
| 25 Membresías/listado y detalle | `features/memberships/presentation/{membership_list_page.dart,membership_detail_page.dart}` | `MembershipTier` y relación opcional; lectura Admin confirmada. Decisión v1 solo lectura; sin compra, período, suscripción ni transacción. | No crear formularios ni mutaciones; sin pagos/cobros. |
| 26 Auditoría/listado y detalle | No crear en v1; feature futura solo aprobada. | No AuditEvent, actor/motivo/historial ni endpoint. | Ningún historial simulado. Definir modelo/política antes de acciones sensibles que requieran atribución. |
| 27 Reportes/listado y resolución | `features/reports/presentation/report_list_page.dart`; modelos/repositorio en `features/reports/{models,data}` | GET filtrable por `isResolved`/`type`; PATCH `/:id/resolve`; guard ADMIN. T086–T087 entregaron y verificaron G11: GET puede devolver `author?` solo con `firstName`/`lastName`; GET y PATCH omiten `authorId`, `author.id`, email y phone. | Sin detalle, paginación ni ordenamiento adicional. `author` opcional: si falta, mostrar y permitir resolver sin datos del autor. Resolver con respuesta confirmada; manejar 404/401/403/red. |

### Reportes: trazabilidad FR-008

FR-008 corresponde a la pantalla #27 y al destino independiente Reportes. Las operaciones
GET filtrable por `isResolved`/`type` y PATCH de resolución por UUID están protegidas para
`ADMIN`; T086 entregó y T087 verificó el contrato reducido: campos de reporte existentes,
`author?` opcional con solo `firstName`/`lastName` en GET, y sin `authorId`, `author.id`, email
o phone en GET ni PATCH. T077–T079 dependen de T086–T087. Si `author` falta, se muestra y resuelve el reporte sin
datos del autor. No existe detalle, paginación, asignación, motivo ni desresolución; no se
modifica Prisma ni los datos.

## Contratos API requeridos por módulo

- **Auth**: reusar login/refresh/logout; registro sigue restringido a CLIENT/PROVIDER.
  Cuentas ADMIN provisionadas fuera de API pública. Aplicar la sesión browser en memoria
  decidida en Clarifications, incluida renovación coordinada y logout best-effort.
- **Users**: Admin list/search/detail y, una vez aprobado, patch/estado; validar query,
  paginación, DTO, unicidad, conflictos y reglas. Excluir DNI, `isDniVerified`, hashes y
  refresh tokens; teléfono solo detail.
- **Providers**: Admin list/detail y DTO/subrecursos con relaciones necesarias, pero sin
  coordenadas. Crear endpoints propios con guard Admin, nunca reusar `/provider/me/*`.
- **Dashboard**: agregados server-side después de definir fuente y reglas; no persistir
  conteos. “Servicios publicados” y “reseñas moderadas pendientes” no existen.
- **Categories**: conservar list/unify; decidir create/edit/status/delete Admin, validación
  y restricciones de FK. No reutilizar POST autoservicio.
- **Contacts/reviews/portfolio**: lista/detalle paginados Admin solo al acordar permisos,
  campos personales, texto, moderación y respuesta. No implicar almacenamiento WhatsApp.
- **Membership**: definir list/detail/asignación/edit Admin; schema actual solo tier + FK.
- **Reports**: consumir `GET /admin/reports` y `PATCH /admin/reports/:id/resolve` después
  de T086/G11, ya completados. Usar únicamente
  `id`, `type`, `content`, `isResolved`, `createdAt`, `updatedAt` y, cuando venga, los
  campos opcionales `author.firstName`/`author.lastName`. El API debe omitir
  `authorId`, `author.id`, email y phone de ambas respuestas. Si `author` falta, permitir
  consulta y resolución sin datos del autor. Sin detalle, paginación, motivo ni otras
  operaciones; no modificar Prisma ni datos.
- **Errores/paginación**: conservar envelopes `{data}` / `{error:{code,message}}`; Zod en
  query/params/body; implementar paginación únicamente cuando el contrato de ese módulo la
  declare; errores de autorización no filtrantes.

No se propone migración Prisma en este plan para lo ya modelado. Migraciones de `Service`,
moderación, `AuditEvent`, lifecycle de cuenta o suscripción dependen de decisiones
aprobadas; no crear campos por deducción de pantallas.

## Sincronización requerida del backlog

La sincronización de `tasks.md` registró T008/T003 y sus breakpoints/sesión aprobados.
T086/T087 completaron y verificaron el contrato reducido de Reportes; G11 está resuelto y
T077–T079 pueden consumir GET/PATCH con `author` opcional. Los gates funcionales/API
restantes siguen bloqueando solo sus propias tareas; antes de implementar más módulos,
comprobar IDs, dependencias y criterios de aceptación contra este plan.

## Orden y dependencias de implementación

1. **Shell y acceso**: T008 instala dependencias aprobadas; construir navegación con los
   breakpoints definidos y la sesión en memoria aprobada. La provisión Admin sigue siendo
   responsabilidad operativa fuera del registro público. T086/T087 ya entregaron y
   verificaron el contrato reducido requerido por Reportes.
2. **Acordar contratos base Admin**: usuarios y prestadores (list/detail, DTO mínimo,
   teléfono detail-only, paginación, búsqueda, errores y guards); endpoint de localidad
   relacionada si se necesita. Sin ello no se habilita consulta real.
3. **Fundación Flutter**: agregar dependencias aprobadas en T008; app,
   router, sesión, cliente Dio, providers, tema, layout responsive y estados. Validar login
   de Admin preaprovisionado y rechazo de otros roles; servidor conserva autoridad.
4. **Lecturas ya disponibles**: integrar lecturas Admin existentes para categorías,
   Reportes (G11 satisfecho), usuarios, prestadores y módulos relacionados; los datos se
   ajustan a sus DTOs y no consumen campos excluidos.
5. **Escrituras Admin aprobadas en API**: extender `admin-read` para PATCH de perfiles User,
   ProviderProfile y `isAccountActive`; extender `categories` para POST/PATCH `name`/`iconUrl`
   y `isActive`. Reusar schemas/validadores actuales, guards ADMIN y acceso Prisma existente.
   No añadir campos/relaciones, migraciones ni escrituras fuera de estas allowlists.
6. **Integración Flutter de mutaciones**: formularios/confirmación solo después de contrato,
   pruebas de API y respuestas verificadas; resultado UI proviene de servidor.
7. **Módulos de dominio faltante**: Dashboard agregado y Services siguen bloqueados; Contactos,
   reseñas, portafolios y membresías quedan lectura solamente. No inventar moderación/auditoría.
8. **Cierre**: escenarios multi-viewport en `<768`, `768–1199` y `≥1200 px`; accesibilidad, privacidad,
   análisis/formato Flutter y suites API pertinentes.

Los pasos 1–3 condicionan consola end-to-end; cada ausencia API bloquea solo el módulo
afectado. La falta de soporte de un área no debe convertirse en cifra/estado vacío ficticio.

## Estrategia de validación prevista

- **Flutter**: `flutter analyze`/formatter; test de sesión/route guard; test drawer (activo,
  menú autorizado, no disponible, navegación teclado); tests de cada async state, formularios,
  conflictos, confirmaciones y reflow. Parseo JSON tipado y nulls/error envelopes.
- **API**: suites Vitest/Supertest existentes; para cada ruta Admin, token ADMIN vs sin
  token, token inválido y roles CLIENT/PROVIDER/SUPPORT; validar schemas y envelope/error.
- **Privacidad**: DTO sin DNI, `isDniVerified`, hashes o coordenadas; teléfono nunca en
  listados de personas; Reportes consume el DTO reducido aprobado después de G11. Localidad
  opcional. Errores no registran/revelan contenido.
- **Mutaciones**: categoría unify con IDs inválidos/iguales, origen/destino y resultado;
  reporte resolve con confirmación, respuesta del API, 404 y protección contra envío
  duplicado; conflicto y timeout con reconsulta; relaciones restrict/cascade antes de
  cualquier delete. Probar nunca mostrar éxito sin respuesta confirmada.
- **Pantallas**: repasar filas 1–27; bloqueada no equivale a vacío/0. Cada tarjeta del
  dashboard conserva error parcial. T087 verificó FR-008 contra el DTO reducido de T086/G11;
  mantener excluidos los campos personales no aprobados.
- **Accesibilidad/responsive**: verificar drawer y reflow en móvil web `<768 px`, tablet
  `768–1199 px` y escritorio `≥1200 px`; teclado, foco visible, semántica, lector y zoom/
  texto ampliado.
- **Entrega**: análisis, formato, pruebas proporcionales a permisos/operaciones y revisión
  de seguridad; sin cuota numérica arbitraria.

## Riesgos, contradicciones y decisiones pendientes

| Tema | Impacto | Tratamiento |
|---|---|---|
| G11: contrato reducido de Reportes | Resuelto: T086 redujo los selects y registró el contrato aprobado; T087 comprobó GET/PATCH, filtros y guard ADMIN con mocks, sin DB. | T077–T079 y T085 pueden avanzar usando solo campos de reporte y `author.firstName`/`author.lastName` opcionales; la ausencia de `author` se admite. |
| Escrituras perfil/cuenta (decisión 2026-11-04) | Implementadas con allowlists de autoservicio, guard ADMIN y pruebas simuladas; solo campos existentes. | Flutter consume `PATCH` y refleja respuesta; no altera Prisma ni datos por scripts/seeds. |
| Escrituras categoría (decisión 2026-11-04) | Implementadas create/edit/isActive; no delete ni transiciones de `status`. | Flutter consume rutas protegidas; alta/edición/estado solo usa columnas actuales. |
| Integración Flutter de lecturas Admin | Rutas y pantallas v1 implementables integradas; validación aislada ejecutada. | G4 bloquea Dashboard agregado y G9 bloquea Services; teléfono/avatar se limitan a detalles autorizados y `problemDescription` sigue excluido. |
| Sesión web con tokens en memoria | Una recarga termina la sesión; logout de red fallido puede dejar válido el access token hasta su vencimiento. | Comportamiento aprobado: renovar una vez por 401, limpiar y volver a login si falla; logout remoto best-effort y no afirmar revocación cuando no se confirma. |
| Provisionar ADMIN fuera del registro | Login existente pero procedimiento operativo no está descrito. | Documentar quién/cómo de forma segura fuera del endpoint público. |
| `Service`, moderation, audit, suspension y subscription ausentes/incompletos | CRUD, métricas y moderación no representables con fidelidad. | Aprobación producto/schema/API antes de proponer migración. |
| Geometría Prisma `Unsupported` y ubicación confidencial | Serialización y exposición precisas no autorizadas. | Solo localidad relacionada; excluir coordenadas en DTO y UI. |
| Admin category/report lists sin paginación | El API puede retornar listas sin paginación. | No mostrar controles de paginación ni afirmar soporte; manejar la respuesta conforme al contrato actual. Cualquier cambio de contrato queda fuera de este plan. |
| Relaciones con `onDelete: Cascade` | Borrado podría eliminar dependencias. | No CRUD delete sin política, confirmación y revisión de impacto referencial. |

## Revisión constitucional posterior al diseño

- ✅ Todas las pantallas 1–27 trazadas con datos, permiso/estado API y validación; global y
  subsecciones permanecen diferenciados.
- ✅ Solo capacidades respaldadas se marcan disponibles; áreas sin API quedan bloqueadas,
  documentadas y no simuladas.
- ✅ Guards server-side, role ADMIN, datos mínimos, éxito confirmado, fallos y privacidad.
- ✅ Estructura propuesta partió del repo real; dependencias aprobadas están instaladas y
  el contrato reducido de Reportes está verificado por tests unitarios sin DB.
- ⚠ Los gates de datos y permisos de los demás módulos siguen abiertos. La identidad visual necesita inspección de las
  fuentes de referencia antes de cerrar los tokens de diseño.
- ✅ Verificación y seguridad se planifican sin SLA/cobertura
  inventados.

## Decisión de estructura y complejidad

El dashboard permanece un proyecto Flutter en este repo, con `lib/src/app`, `core` y
`features` ya presentes; las extensiones listadas son nuevas donde no exista archivo. Los
cambios API se realizarían después en el proyecto separado
`/Users/matybazan/Documents/api-tooapp`, cuyos paths fueron inspeccionados; esta fase no
lo modifica. La interfaz Flutter y los controllers Node/Prisma se coordinan mediante DTOs
HTTP tipados, evitando mezclar lógica de ambos proyectos.

| Decisión | Justificación | Alternativa descartada |
|---|---|---|
| Capas por feature | 27 pantallas, modelos relacionados, permisos y estados requieren límites rastreables. | Un `main.dart` monolítico impediría revisar permisos/DTO por módulo. |
| Feature `reports` incluida | La especificación confirma destino independiente; el API ya tiene listado/resolución ADMIN y G11 está satisfecho. | Anidarla en Dashboard/Auditoría contradiría FR-008 y el drawer aprobado. |
| Sin modelos especulativos | Service/moderation/audit/suspension no existen completos en Prisma. | Reutilizar modelos no relacionados crearía datos y acciones ficticias. |

## Artefactos de diseño relacionados

- [research.md](research.md): decisiones, razones y alternativas consideradas para las
  dependencias, sesión, breakpoints y límites de capacidad.
- [data-model.md](data-model.md): inventario de entidades Prisma existentes y datos
  derivados requeridos, sin proponer cambios de persistencia.
- [contracts/](contracts/): matriz del contrato Admin observado, DTO de Reportes reducido
  aprobado y contratos/gates pendientes para las áreas bloqueadas.
- [quickstart.md](quickstart.md): guía de validación para la etapa de implementación; no
  se ejecutó en esta etapa.
