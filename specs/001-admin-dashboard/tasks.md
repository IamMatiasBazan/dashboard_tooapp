# Tasks: TooApp Dashboard — Administración de usuarios, prestadores y contenido

**Input**: `specs/001-admin-dashboard/spec.md`, `plan.md` y `.specify/memory/constitution.md`.

**Feature activa**: `.specify/feature.json` confirma `specs/001-admin-dashboard`.

**Estado de implementación**: el shell, lecturas Admin, Reportes y las escrituras aprobadas de perfiles/categorías están implementados en los checkouts de dashboard/API. Las pruebas de escritura usan repositorios simulados. Este backlog registra la evidencia en las tareas completadas y conserva los bloqueos de G4/G9.

**Restricción absoluta de datos**: no modificar ni planificar cambios en Prisma, migraciones, tablas, columnas, índices, relaciones, seeds o datos. No ejecutar `migrate`, `db push` ni pruebas que escriban o conecten a DB. Las pruebas API deben usar Prisma/repositories simulados. Si una capacidad no cabe en el esquema/API actual, queda bloqueada y su brecha se documenta; no se propone solución de base de datos.

**Formato**: cada tarea usa checkbox, ID secuencial, `[P]` solo si es independiente, etiqueta `[US#]` en fases de historia, resultado, archivos, aceptación y `Depends on: ...`. Las tareas con etiqueta `BLOQUEADA` no están listas para comenzar.

## Decisiones de alcance y brechas verificadas

- **Reportes**: destino independiente; T086/T087 redujeron y verificaron el contrato. El API devuelve únicamente datos del reporte y `author?` con nombre/apellido opcionales; GET/PATCH omiten `authorId`, `author.id`, email y phone. T077–T079 integran GET/PATCH sin detalle ni paginación.
- **Servicios**: Prisma no contiene `Service`. Tampoco existe relación de servicio con prestador/categoría ni campos de publicación, fecha o tarifa/unidad por servicio. `ProviderProfile` sí contiene categorías primaria/secundarias y precios a nivel del perfil; estos no representan servicios publicados ni tarifas por servicio. La pantalla #10 puede mostrar categorías asociadas de forma explícita si hay lectura Admin; su parte de Services y las pantallas #21–22 no se simulan y quedan bloqueadas. No se propone cambiar esquema.
- **Operaciones confirmadas**: `GET /admin/categories` acepta filtros `status`/`active`; `POST /admin/categories/unify` acepta dos UUID distintos; alta, edición y activación/desactivación Admin se implementan en API con guard ADMIN y pruebas simuladas. No existe DELETE ni cambios Admin de `status`.
- **Escrituras de perfiles aprobadas**: API implementa `PATCH /admin/users/:userId` y `PATCH /admin/providers/:providerProfileId`, ambos reutilizan las allowlists y validaciones del autoservicio para `User` y `ProviderProfile` bajo guard ADMIN. En Provider el body separa `{user, providerProfile}`. `PATCH /admin/users/:userId/account-status` cambia por separado `isAccountActive`. Teléfono/avatar se limitan a detalles y respuestas autorizadas; no aparecen en listados. No hay cambios Prisma.
- **Membresías**: existen `MembershipTier` y FK opcional `ProviderProfile.membershipTierId`; no hay suscripción, compra, período, transacción o escritura Admin confirmada. No se agregan pagos.
- **Privacidad**: DNI e `isDniVerified` excluidos; no exponer geometrías/coordenadas. Locality solo lectura. Teléfono solo en detalle cuando DTO y permiso ADMIN lo autoricen. `ContactIntent.problemDescription` requiere decisión de necesidad y acceso. La app no acredita almacenamiento de conversaciones ni canal WhatsApp.

## Gates verificables

| Gate | Evidencia necesaria; responsable | Tareas bloqueadas | Condición de desbloqueo |
|---|---|---|---|
| G4 Dashboard | No está definido el conteo de prestadores, contactos recibidos ni período “reciente”; no hay agregador Admin. Responsables: producto/API. | T020–T023 | Cada cifra tiene regla, datos y contrato actuales verificables; métricas imposibles se declaran no disponibles. Gate registrado en T004. |
| G5 Privacidad | Teléfono e imagen solo en detalles ADMIN autorizados; listados los omiten. `ContactIntent.problemDescription` permanece excluido. | Ninguna; pruebas de pantallas comprueban los DTOs mínimos. | API limita teléfono/avatar a detalle User o Provider y respuestas de mutación protegidas; DNI, `isDniVerified`, coordenadas y texto libre siguen excluidos. |
| G6 Lecturas Admin | **Resuelto para lecturas v1**: contratos y rutas están implementados en `src/modules/admin-read/`, con guard `ADMIN`, selección explícita y validación Zod. Responsable: API; el propietario lo solicitó expresamente. | Ninguna para los endpoints GET definidos en `contracts/rest-api.md`; no habilita mutaciones. | `admin-read-routes.test.ts` verifica guard por recurso, validación, paginación y 404 con repositorios simulados; `typecheck` y lint pasan. T006 completada. |
| G7-U Edición Admin de User | **Resuelto**: allowlist/validaciones de `ownUserPatchSchema` y cambio separado `isAccountActive`; sin DNI/rol/verificaciones ni historial inventado. Responsable: API. | Ninguna; T034–T036 y T091 completadas. | T091 verifica rutas, allowlist, roles y errores con repositorios simulados; Flutter confirma, envía solo campos aprobados y refresca con respuesta del servidor. |
| G7-P Edición Admin de ProviderProfile y User asociado | **Resuelto**: `user` reutiliza `ownUserPatchSchema`; `providerProfile` reutiliza `providerFields`. Excluye DNI, rol, `isAccountActive`, verificaciones, ubicación precisa, disponibilidad y agregados. Responsable: API. | Ninguna; T045/T047/T092 completadas. | T092 verifica guard, ambos schemas y exclusiones con mocks; detalle incluye teléfono/avatar solo para ADMIN; formulario envía cambios por sección y el servidor confirma antes de refrescar. |
| G8 Escritura Admin de categorías | **Resuelto**: crear/editar `name`/`iconUrl`, activar/desactivar `isActive`, conservar unificación, sin eliminar ni cambiar `status`. Responsable: API. | Ninguna; T063/T065/T088–T090 completadas. | T090 verifica rutas, roles, validación, duplicados y 404 con mocks; Flutter confirma acciones y refleja el resultado del servidor. |
| G9 Servicios | `schema.prisma` y módulos API revisados no contienen Service, relación servicio-prestador/categoría, estado/fecha de publicación ni tarifa por servicio. Responsables: API/producto. | Parte “Service” de T046; T070–T071 | Solo se desbloquea si una fuente vigente demuestra datos y operación ya existentes que representen el servicio, sin cambio de esquema. Con las fuentes actuales, #21–22 siguen bloqueadas. Gate registrado en T001. |
| G10 Membresías solo lectura | Resuelto para v1: tiers consultables; no se implementa alta/edición/activación/baja ni pagos. | Ninguna tarea de escritura; T074 conserva consulta. | Decisión aprobada en spec; no crear formularios ni endpoints de escritura. |
| G11 Contrato reducido de Reportes | **Resuelto**: decisión aprobada limita `author` a `firstName`/`lastName` opcionales; T086 redujo selects y contrato; T087 verificó GET/PATCH, filtros y guard ADMIN con repositorios simulados, sin DB. | Ninguna; T077–T079 completadas | G11 se satisface con los cambios contractuales y la prueba unitaria T087. GET/PATCH omiten `authorId`, `author.id`, email y phone; `author` ausente no bloquea mostrar ni resolver. |

## Matriz de cobertura de pantallas

| Pantalla | Tareas | Condición |
|---|---|---|
| 1 Dashboard | T020–T023 | G4 |
| 2 Usuarios — listado | T030–T031, T033 | Integración en `features/admin_read`; no muestra teléfono |
| 3 Usuarios — detalle | T032–T033 | Ficha ADMIN; campos opcionales explícitos y teléfono en detalle autorizado |
| 4 Usuarios — edición | T034, T036, T091 | PATCH protegido; allowlist de autoservicio |
| 5 Usuarios — cambio de estado | T035–T036, T091 | Confirmación y cambio aislado de `isAccountActive` |
| 6 Prestadores — listado | T040–T042 | Búsqueda, disponibilidad y filtro por categoría |
| 7 Prestadores — ficha administrativa | T043–T044 | Datos modelados y calificación/recuento derivados de reseñas |
| 8 Perfil profesional | T044 | DTO Admin sin DNI/verificación; teléfono/avatar solo en ficha, nunca en lista |
| 9 Edición de perfil | T045, T047, T092 | PATCH protegido; `user` usa `ownUserPatchSchema`, `providerProfile` usa `providerFields` |
| 10 Categorías/oficios y servicios publicados en ficha | T046 | Categorías en DTO de Provider; Service bloqueado por G9 |
| 11 Tarifas/facturación | T048 | Campos del perfil solamente; sin pagos |
| 12 Disponibilidad | T049 | Se calcula vencimiento; no edita pulsos |
| 13 Ubicaciones | T050 | Solo localidad; sin coordenadas |
| 14 Portafolio en ficha | T051 | API global filtrable por perfil; solo lectura |
| 15 Portafolios — global | T052 | API lista; solo lectura |
| 16 Reseñas en ficha | T053 | Reseñas y agregados derivados; no editables |
| 17 Reseñas — global | T060 | Filtros disponibles en API; sin moderación |
| 18 Categorías — listado | T061–T062 | API Admin disponible |
| 19 Categorías — crear/editar | T063, T088, T090 | POST/PATCH Admin protegidos; sin eliminación |
| 20 Categorías — estado/eliminar/unificar | T064–T065, T089–T090 | Unificar y activar/desactivar; eliminar y cambiar `status` fuera de v1 |
| 21 Servicios — listado global | T070 | G9; no hay Service/datos/endpoints |
| 22 Servicios — detalle/mantenimiento | T071 | G9; no hay Service/datos/endpoints |
| 23 Contactos — listado | T072 | API lista; omite texto libre |
| 24 Contactos — detalle | T073 | API detalle; omite texto libre |
| 25 Membresías — listado/detalle | T074 | API lectura; v1 solo lectura |
| 26 Auditoría | T076 | Fuera de v1; no existe AuditEvent/ruta |
| 27 Reportes — listado y resolución | T077–T079 | Completadas tras T086–T087 y cierre de G11 |
| Drawer, rutas y responsive | T009–T017, T080 | Breakpoints y sesión web aprobados; solo dependen de su base técnica |

## Trazabilidad de requisitos y criterios de éxito

| Requisito | Tareas | Nota |
|---|---|---|
| FR-001 | T015–T016, T080 | Drawer, destino activo y navegación accesible |
| FR-002 | T014–T016, T080 | Rangos aprobados: móvil web <768 px, tablet 768–1199 px, escritorio ≥1200 px |
| FR-003 | T010–T012, T030–T036, T040–T047, T060–T065, T072–T075, T084, T090–T092 | Guard del servidor por operación |
| FR-004 | T020–T023, T043, T046–T054, T060, T070–T074 | Fuente/dato actual o bloqueo explícito |
| FR-005 | T030–T033, T040–T054, T060, T072–T074 | Integraciones Flutter implementadas donde el API las respalda; G4/G9 bloquean las áreas indicadas |
| FR-006 | T020–T023, T043, T053 | Agregados calculados, no editables |
| FR-007 | T061–T065, T088–T090 | Listar/unificar; alta/edición/estado solo tras rutas protegidas y pruebas de G8 |
| FR-008 | T077–T079, T086–T087 | T086–T087 completadas; T077–T079 integran el contrato reducido y el flujo |
| FR-009 | T005, T032–T033, T040–T044, T048, T050, T072–T073, T081 | Privacidad teléfono/contacto |
| FR-010 | T017, T022–T023, T031–T033, T036, T041–T042, T047–T065, T072–T078, T088–T090 | Estados/confirmación/resultado servidor |
| FR-011 | T047–T048, T070–T075 | Sin pagos, transacciones, CRUD localidades o admins |
| FR-012 | T074–T075 | Tier confirmado y solo lectura en v1; T075 registra la exclusión de escrituras |
| FR-013 | T034–T036, T045–T047, T051–T060, T063, T065, T070–T078, T088–T092 | Brechas no simuladas |
| FR-014 | T013–T017, T080 | Accesibilidad y responsive |
| FR-015 | T011, T081, T084 | Solo ADMIN; denegación server-side |
| FR-016 | T032–T033, T040–T044, T054, T081 | DNI e `isDniVerified` excluidos |
| FR-017 | T040, T044, T050, T054, T081 | Solo localidad; sin precisión geográfica |
| SC-001 | T001, T085 | Trazabilidad de campos y bloqueos |
| SC-002 | T005–T007, T085 | Actor, permiso y estado de respaldo |
| SC-003 | T014–T016, T080 | Identificación del módulo en viewports |
| SC-004 | T020–T023, T043, T053, T085 | Agregados/no disponible/vacío correctos |
| SC-005 | T001–T007, T085 | Dependencias y gates previos |

## Phase 1: Preparación y decisiones

- [X] T001 Contrastar pantallas #10/#21/#22 con `/Users/matybazan/Documents/api-tooapp/prisma/schema.prisma` y `/Users/matybazan/Documents/api-tooapp/src/modules/`; aceptación: documentar la brecha Service exacta de G9, mantenerla bloqueada y no proponer cambios de esquema/datos. Depends on: none.
- [X] T003 Registrar en `specs/001-admin-dashboard/spec.md` y `plan.md` las decisiones aprobadas: `go_router ^18.1.2`, `dio ^5.11.1`, `provider ^6.1.5+1` con Flutter 3.47.7/Dart 3.13.5; breakpoints móvil web <768 px, tablet 768–1199 px y escritorio ≥1200 px; access/refresh token solo en memoria, renovación coordinada una vez, retry original una vez, logout best-effort y login tras reload. Aceptación: decisiones visibles en Clarifications y plan; conservar abiertos los gates no relacionados. Depends on: none.
- [ ] T004 Registrar reglas/fuentes pendientes en `specs/001-admin-dashboard/tasks.md`; aceptación: producto/API confirma fuente/conteo/ventana para cada indicador y marca no disponibles los datos sin soporte (G4). Depends on: none.
- [X] T005 Registrar en `specs/001-admin-dashboard/spec.md` y `research.md` decisiones de privacidad y allowlists de edición; aceptación: `phone`/`avatarUrl` solo aparecen en detalles autorizados, nunca listados; `problemDescription`, DNI, verificaciones y coordenadas siguen excluidos; edición User/Provider reutiliza schemas de autoservicio y `isAccountActive` tiene acción separada. G7 queda como gate técnico de entrega/verificación API. Depends on: none.
- [X] T006 Registrar e implementar contratos Admin de lectura en `/Users/matybazan/Documents/api-tooapp/specs/001-too-api-functional-spec/contracts/rest-api.md`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.routes.ts`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.schema.ts`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.controller.ts`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.service.ts`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.repository.ts`; aceptación: DTOs basados en campos existentes, filtros/paginación/error, guard `ADMIN`, prueba HTTP con repositorios simulados y sin exposición de teléfono, DNI, coordenadas o `problemDescription`. No habilita escrituras ni datos excluidos. Depends on: T001.
- [X] T007 Registrar en `specs/001-admin-dashboard/spec.md` y `research.md` decisiones de escritura de categorías; aceptación: alta, edición de `name`/`iconUrl`, activación/desactivación por `isActive` y unificación aprobadas; DELETE y cambios de `status` excluidos. G8 queda como gate técnico de entrega/verificación API. Depends on: none.

## Phase 2: Fundación Flutter y shell

**Purpose**: completar y mantener el shell responsive con las dependencias aprobadas.

- [X] T008 Añadir `go_router ^18.1.2`, `dio ^5.11.1` y `provider ^6.1.5+1` en `pubspec.yaml`; aceptación: versiones aprobadas en `spec.md` y `research.md`, `pubspec.lock` coherente con Flutter 3.47.7 stable/Dart 3.13.5, sin agregar otras dependencias. Depends on: none.
- [X] T009 Crear estructura por feature y capas en `lib/src/app/`, `lib/src/core/`, `lib/src/features/`; aceptación: presentación, estado, datos y modelos separados; `lib/main.dart` solo inicializa app. Depends on: T008.
- [X] T010 [P] Crear `lib/src/core/network/api_client.dart` y `lib/src/core/network/api_failure.dart`; aceptación: JSON tipado, envelope actual, errores 401/403/red/5xx seguros y sin exponer cuerpo sensible. Depends on: T008–T009.
- [X] T011 Crear `lib/src/core/session/admin_session.dart`, `lib/src/core/session/session_provider.dart` y login/logout/refresh en capa access; aceptación: access/refresh token solo en memoria; ante 401 coordinar una renovación, reemplazar tokens y reintentar la petición original una vez; fallo de refresh limpia sesión y vuelve al login; logout envía Bearer y refresh actual, limpia memoria siempre y no afirma revocación remota ante fallo; reload requiere login; solo ADMIN accede y el servidor conserva autorización. Depends on: T003, T010.
- [X] T012 Crear `lib/src/app/app.dart`, `lib/src/app/router/admin_router.dart` y conectar desde `lib/main.dart`; aceptación: rutas protegidas tipadas y retorno correcto; guard cliente no sustituye guard API. Depends on: T009–T011.
- [X] T013 [P] Crear `lib/src/core/theme/admin_tokens.dart` y `lib/src/core/theme/admin_theme.dart`; aceptación: tokens centralizados, identidad observada separada de propuesta y contraste suficiente. Depends on: T009.
- [X] T014 Crear `lib/src/app/layout/responsive_admin_layout.dart`; aceptación: móvil web `<768 px`, tablet `768–1199 px`, escritorio `≥1200 px`; drawer persistente en escritorio, colapsable/expandible en tablet y lateral accesible en móvil; reflow sin perder contenido. Depends on: T003, T013.
- [X] T015 Crear `lib/src/app/layout/admin_drawer.dart`; aceptación: catálogo de módulos reales, destino activo perceptible, navegación accesible; Reportes es destino independiente y módulos con gates abiertos no aparecen habilitados. Depends on: T003, T014.
- [X] T016 Crear `lib/src/app/layout/admin_scaffold.dart`; aceptación: compone router, drawer y layout manteniendo rutas y permisos acordados. Depends on: T003, T012, T014–T015.
- [X] T017 Crear `lib/src/core/widgets/async_state_view.dart`, `lib/src/core/widgets/confirmation_dialog.dart`, `test/src/app/admin_scaffold_test.dart` y `test/src/core/api_client_test.dart`; aceptación: carga/vacío/error/éxito/no disponible/403 y confirmación verificables con doubles, sin DB. Depends on: T010, T013, T016.

## Phase 3: US1 — Resumen y navegación administrativa

**Prioridad**: la especificación no asigna prioridades numéricas; se conserva su orden US1–US4.

**Goal**: ofrecer el shell autenticado ADMIN, navegación responsive y un resumen que solo muestre indicadores con fuentes y reglas confirmadas.

**Independent Test**: probar sesión ADMIN, navegación/drawer y estados compartidos con respuestas simuladas; las tarjetas sin fuente aprobada quedan explícitamente no disponibles, sin datos inventados ni indicadores editables (G4 bloquea las métricas).

- [ ] T020 [US1] Definir regla/fuente y contrato de agregados en el archivo nuevo `specs/001-admin-dashboard/contracts/dashboard-summary.md` solo tras decisión G4; aceptación: total User, total ProviderProfile, disponibilidad vigente, contactos recibidos y reseñas recientes tienen fuente existente; Services publicados/moderación no disponibles si carecen de datos. [BLOQUEADA: G4]. Depends on: T004.
- [ ] T021 [US1] Implementar lectura agregada ADMIN solo tras aprobar contrato T020; aceptación: definir en T020 el archivo API concreto porque no existe módulo Dashboard/Admin agregado en `/Users/matybazan/Documents/api-tooapp/src/modules/`; guard ADMIN, lectura acotada, sin persistencia ni modificación DB. [BLOQUEADA: G4]. Depends on: T004, T006, T020.
- [ ] T022 [US1] Crear `lib/src/features/dashboard/data/dashboard_repository.dart`, `lib/src/features/dashboard/models/dashboard_summary.dart`, `lib/src/features/dashboard/presentation/dashboard_page.dart`; aceptación: fuente/regla por tarjeta, carga/error/vacío y enlace solo a listados autorizados; sin cero falso. [BLOQUEADA: G4]. Depends on: T004, T017, T021.
- [ ] T023 [US1] Crear `test/src/features/dashboard/dashboard_page_test.dart`; aceptación: agregados no editables, respuesta válida cero, error parcial y campo no disponible diferenciados. [BLOQUEADA: G4]. Depends on: T004, T020, T022.

## Phase 4: US2 — Consulta y gestión de usuarios y prestadores

**Goal**: consultar perfiles y sus subsecciones; habilitar edición/estado mediante rutas Admin aprobadas y verificadas bajo G7-U/G7-P.

**Independent Test**: con lecturas Admin y respuestas simuladas, recorrer listado, detalle y subsecciones; verificar allowlists, permisos y privacidad. La integración de edición User depende de T034/T035/T091 y la de Provider de T045/T092.

### Usuarios (#2–5)

- [X] T030 [P] [US2] Implementar listado Admin de User en `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.routes.ts`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.schema.ts`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.controller.ts`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.service.ts`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.repository.ts` y montarlo desde `/Users/matybazan/Documents/api-tooapp/src/routes.ts`; aceptación: solo cuentas `CLIENT`, `firstName`, `lastName`, email nullable, localidad, alta/estado; query validada y paginada, ADMIN guard, sin teléfono/DNI/secrets. Depends on: T006.
- [X] T031 [US2] Integrar listado User en `lib/src/features/admin_read/data/admin_read_repository.dart`, `lib/src/features/admin_read/models/admin_read_models.dart` y `lib/src/features/admin_read/presentation/admin_read_pages.dart`; aceptación: búsqueda, filtro de estado, paginación, carga/vacío/error/403, apertura de ficha y teléfono ausente del listado. Depends on: T006, T030, T016–T017.
- [X] T032 [US2] Integrar detalle User en `lib/src/features/admin_read/presentation/admin_read_pages.dart`; aceptación: campos opcionales como no disponibles, regreso al listado, teléfono solo en ficha autorizada, sin `passwordHash`, token, DNI ni `isDniVerified`. Depends on: T006, T030.
- [X] T033 [US2] Añadir `test/src/features/admin_read/admin_read_pages_test.dart` y `test/src/features/admin_read/user_edit_page_test.dart`; aceptación: listado/detalle, estados vacíos/error/permiso, datos opcionales y privacidad; repositorios simulados, sin snapshots ni API/DB real. Depends on: T031–T032.
- [X] T034 [US2] Implementar `PATCH /admin/users/:userId` en los archivos existentes `admin-read.routes.ts`, `admin-read.schema.ts`, `admin-read.controller.ts`, `admin-read.service.ts` y `admin-read.repository.ts` del módulo Admin-read; aceptación: `authenticate` + `requireRole('ADMIN')`, UUID, targets solo `CLIENT`, campos `phone`, `email`, `firstName`, `lastName`, `avatarUrl`, validaciones `ownUserPatchSchema`, respuesta sin secretos/DNI y errores tipados; no cambia Prisma. Depends on: T005, T006, T030.
- [X] T035 [US2] Implementar `PATCH /admin/users/:userId/account-status` en los archivos existentes `src/modules/admin-read/*`; aceptación: guard ADMIN, UUID, único booleano `isAccountActive`, targets `CLIENT`/`PROVIDER`, rechazo de `ADMIN`/`SUPPORT`, sin motivo/historial/auditoría; no cambia Prisma. Depends on: T034.
- [X] T036 [US2] Crear formulario `lib/src/features/admin_read/presentation/user_edit_page.dart` y acciones confirmables en `admin_read_pages.dart`; aceptación: consume solo la allowlist aprobada; cancelar no muta; errores conservan valores; éxito requiere respuesta server y refresca ficha. Incluye activar/desactivar por acción separada. Depends on: T017, T030–T035, T091.

### Prestadores (#6–16)

- [X] T040 [P] [US2] Implementar listado/detalle Admin ProviderProfile en `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.routes.ts`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.schema.ts`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.controller.ts`, `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.service.ts` y `/Users/matybazan/Documents/api-tooapp/src/modules/admin-read/admin-read.repository.ts`; aceptación: filtros por búsqueda/categoría/disponibilidad y paginación; disponibilidad calculada con hora límite; categorías y DTO explícito bajo ADMIN, sin teléfono/DNI/coordenadas. Depends on: T006.
- [X] T041 [US2] Integrar listado Provider en `lib/src/features/admin_read/data/admin_read_repository.dart`, `lib/src/features/admin_read/models/admin_read_models.dart` y `lib/src/features/admin_read/presentation/admin_read_pages.dart`; aceptación: búsqueda, filtro por categoría y disponibilidad, paginación/estados, sin teléfono en lista y apertura de ficha. Depends on: T006, T040, T016–T017.
- [X] T042 [US2] Añadir cobertura de listado y privacidad en `test/src/features/admin_read/admin_read_pages_test.dart`; aceptación: DTO tipado, filtros declarados, teléfono no aparece en lista, DNI/geometría no se solicitan; sin acceso real a DB. Depends on: T041.
- [X] T043 [US2] Integrar ficha Provider en `lib/src/features/admin_read/presentation/admin_read_pages.dart`; aceptación: categorías relacionadas, navegación a perfil/subsecciones, calificación y total derivados desde reseñas; no muestra ni cuenta servicios inexistentes. Depends on: T040–T041.
- [X] T044 [US2] Integrar perfil personal/profesional en la ficha Provider de `admin_read_pages.dart`; aceptación: campos disponibles y opcionales, teléfono/avatar solo en detalle ADMIN, sin DNI, `isDniVerified` ni secretos; listados mantienen privacidad. Depends on: T040, T043.
- [X] T045 [US2] Implementar `PATCH /admin/providers/:providerProfileId` en los archivos existentes `src/modules/admin-read/*`; aceptación: guard ADMIN, UUID, body estricto con `user` opcional basado en `ownUserPatchSchema` y `providerProfile` opcional basado en `providerFields`; rechazar secciones/cuerpo vacíos; excluir DNI/rol/`isAccountActive`/verificaciones/ubicación precisa/disponibilidad/agregados; respuesta de detalle autorizada y sin cambios Prisma. Depends on: T005, T035, T040.
- [ ] T046 [US2] Mantener bloqueada la pantalla #10 de servicios publicados dentro de ficha; no existe un archivo de pantalla implementable mientras G9 siga abierto. Aceptación: no sustituir “servicios/oficios publicados” por categorías asociadas; no hay Service, publicación, estado, fecha ni tarifa por servicio; no mostrar datos simulados. [BLOQUEADA: G9]. Depends on: T001, T040, T043.
- [X] T047 [US2] Crear `lib/src/features/admin_read/presentation/provider_edit_page.dart` e integrarlo desde la ficha de `admin_read_pages.dart`; aceptación: consume solo campos modificados, envía datos personales permitidos en `user` y profesionales en `providerProfile`, valida reglas vigentes, confirma/cancela, conserva cambios ante error y refresca al confirmar el servidor. Teléfono/avatar solo en detalle ADMIN, no listados. Depends on: T017, T040, T045, T092.
- [X] T048 [US2] Crear subsección “Tarifas y facturación” en `lib/src/features/admin_read/presentation/admin_read_pages.dart`; aceptación: únicamente `minPrice`, `chargesConsultation`, `consultationPrice`, `issuesInvoice` e `invoiceType`; sin pagos/campos fiscales. Depends on: T040, T043.
- [X] T049 [US2] Crear subsección “Disponibilidad” en `admin_read_pages.dart`; aceptación: disponible solo si `isAvailable` y `shiftEndsAt > now`; expirado inactivo, sin editar pulsos ni inventar umbral de frescura. Depends on: T040, T043.
- [X] T050 [US2] Crear subsección “Ubicación” en `admin_read_pages.dart`; aceptación: solo localidad y aviso de que ubicación precisa no está disponible; sin coordenadas/mapa/mantenimiento de localidades. Depends on: T040, T043.
- [X] T051 [US2] Integrar portafolio dentro de la ficha con `AdminPortfolioPage` en `admin_read_pages.dart`; aceptación: imagen/URL, fecha y relación disponibles, solo lectura, sin estado/moderación ficticios. Depends on: T040, T043.
- [X] T052 [US2] Integrar lista global Portafolios por `/portfolios` en router y `AdminPortfolioPage`; aceptación: prestador e imagen/fecha, sin filtros o moderación no respaldados. Depends on: T006, T040.
- [X] T053 [US2] Integrar reseñas dentro de ficha en `AdminReviewsPage` y `admin_read_pages.dart`; aceptación: listados y promedio/total derivados del contrato, no editables, null distinto de cero, sin moderación. Depends on: T040, T043.
- [X] T054 [US2] Añadir `test/src/features/admin_read/admin_read_pages_test.dart` y `provider_edit_page_test.dart`; aceptación: privacidad del perfil, omisión de DNI/coordenadas/secretos y disponibilidad vencida con fixtures simuladas. Depends on: T044, T048–T053.
- [X] T091 [US2] Ampliar `/Users/matybazan/Documents/api-tooapp/tests/unit/admin-read-routes.test.ts`; aceptación: allowlist de User, targets CLIENT, estado booleano aislado, guard ADMIN, rechazo de campos no permitidos/401/403/404; repositorios simulados, sin DB. Evidencia de cierre G7-U. Depends on: T034–T035.
- [X] T092 [US2] Ampliar `/Users/matybazan/Documents/api-tooapp/tests/unit/admin-read-routes.test.ts`; aceptación: valida ambas secciones del body Provider (`ownUserPatchSchema` y `providerFields`), rechazo de DNI/rol/`isAccountActive`/verificaciones/coordenadas/disponibilidad/agregados, guard ADMIN y 404 con repositorios simulados. Evidencia de cierre G7-P. Depends on: T045.

## Phase 5: US3 — Reseñas y categorías

**Goal**: consultar reseñas con filtros vigentes e integrar las escrituras Admin aprobadas de categorías.

**Independent Test**: listar/filtrar/unificar/crear/editar/activar categorías y verificar rechazo sin permiso mediante API mockeada y pantallas Flutter.

- [X] T060 [P] [US3] Integrar `GET /admin/reviews` en `lib/src/features/admin_read/data/admin_read_repository.dart` y `lib/src/features/admin_read/presentation/admin_read_pages.dart`; aceptación: filtros por prestador UUID, rating y fecha según contrato; autor/objetivo sin email/teléfono; sin estado/moderación; prueba en `test/src/features/admin_read/admin_read_pages_test.dart`. Depends on: T006, T016–T017.
- [X] T061 [P] [US3] Integrar `GET /admin/categories` existente en `/Users/matybazan/Documents/api-tooapp/src/modules/categories/categories.routes.ts` y crear `lib/src/features/categories/data/category_repository.dart`, `lib/src/features/categories/models/admin_category.dart`, `lib/src/features/categories/presentation/category_list_page.dart`; aceptación: filtros `status`/`active`, ADMIN, estados reales y lista con carga/vacío/error/403. Depends on: T016–T017.
- [X] T062 [US3] Crear `test/src/features/categories/category_list_page_test.dart`, `category_unify_dialog_test.dart` y `/Users/matybazan/Documents/api-tooapp/tests/unit/admin-categories.test.ts` (nuevo); aceptación: ADMIN/403, filtros inválidos, IDs iguales, conflictos y errores; API prueba simulada sin DB. Depends on: T061, T064.
- [X] T063 [US3] Implementar `POST /admin/categories` y `PATCH /admin/categories/:categoryId` en `src/modules/categories/{categories.routes.ts,categories.controller.ts,categories.service.ts,categories.repository.ts,categories.schema.ts,categories.types.ts}` del API; aceptación: guard ADMIN, UUID, solo `name`/`iconUrl`, validaciones existentes, duplicado/404 tipados, sin cambiar `status`, relaciones ni Prisma. Depends on: T007, T061.
- [X] T064 [US3] Integrar unificación `POST /admin/categories/unify` en `lib/src/features/categories/presentation/category_unify_dialog.dart`; aceptación: UUID distintos, origen/destino/impacto confirmados, respuesta servidor y refresco; conflicto/error no se presenta como éxito. Depends on: T061, T017.
- [X] T065 [US3] Implementar `PATCH /admin/categories/:categoryId/active` en los archivos existentes de `src/modules/categories/`; aceptación: guard ADMIN, UUID, body solo `isActive`, resultado confirmado; sin eliminar, cambiar `status` ni migrar. Depends on: T063.
- [X] T088 [US3] Crear `lib/src/features/categories/presentation/category_form_page.dart` e integrarlo con la lista; aceptación: alta/edición solo `name`/`iconUrl`, validaciones, carga/guardado/error/403, cancelación y resultado confirmado; sin cambiar `status` ni borrar. Depends on: T016–T017, T061, T063, T090.
- [X] T089 [US3] Implementar acciones de activar/desactivar en `lib/src/features/categories/presentation/category_list_page.dart`; aceptación: confirmación, solo `isActive`, acción deshabilitada durante carga/permisos y refresco según servidor; sin aprobar/rechazar/eliminar/cambiar `status`. Depends on: T017, T061, T065, T088, T090.
- [X] T090 [US3] Ampliar `/Users/matybazan/Documents/api-tooapp/tests/unit/admin-categories.test.ts`; aceptación: mocks para POST/PATCH/active, ADMIN/no autenticado/no ADMIN, validaciones, duplicados/not-found y DTOs; unificación existente conservada; cero acceso a DB. Depends on: T063, T065.

## Phase 6: US4 — Módulos relacionados

**Goal**: integrar módulos relacionados respaldados por el modelo/API y mantener explícitas las áreas fuera de v1 o bloqueadas.

**Independent Test**: comprobar que contactos, membresías y Reportes consultan sus contratos; Service y Auditoría se identifican como no disponibles sin consultas/acciones simuladas.

- [ ] T070 [US4] Mantener bloqueada la pantalla global de Servicios; no existe archivo de pantalla implementable mientras G9 siga abierto. Aceptación: `Service`, relación, publicación, fecha y tarifa por servicio no existen en el esquema/API inspeccionados; no presentar categorías/precios de perfil como servicios ni modificar DB. [BLOQUEADA: G9]. Depends on: T001.
- [ ] T071 [US4] Mantener bloqueados el detalle y mantenimiento de Servicios; no crear archivos de pantalla, formularios ni consultas reales sin modelo y operaciones actuales que superen G9; sin pagos ni DB changes. [BLOQUEADA: G9]. Depends on: T001, T070.
- [X] T072 [P] [US4] Integrar `GET /admin/contact-intents` en `lib/src/features/admin_read/data/admin_read_repository.dart`, `admin_read_models.dart` y `admin_read_pages.dart`; aceptación: relaciones y metadatos persistidos, filtros contractuales, sin `problemDescription`, canal ni conversación inferidos. Depends on: T006, T016–T017.
- [X] T073 [US4] Integrar `GET /admin/contact-intents/:contactIntentId` en `admin_read_pages.dart`; aceptación: metadatos mínimos, sin texto libre ni conversaciones externas; ficha con retorno al listado y estados compartidos de error/403. Depends on: T072.
- [X] T074 [P] [US4] Integrar `GET /admin/membership-tiers` y `GET /admin/membership-tiers/:tierId` en `admin_read_repository.dart`, `admin_read_models.dart`, `admin_read_pages.dart` y rutas Admin; aceptación: solo `name`, `description`, `price`, `createdAt`, sin compra/suscripción/pago. Depends on: T006, T016–T017.
- [X] T075 [US4] Excluir formularios y mutaciones de membresías de v1; no crear `membership_form_page.dart` ni endpoints de escritura. Aceptación: tiers solo lectura por decisión vigente, pagos/transacciones fuera de alcance y G10 cerrado. Depends on: none.
- [X] T076 [US4] Verificar que la auditoría permanezca fuera de la navegación v1 en `lib/src/app/router/admin_router.dart` y `lib/src/app/layout/admin_drawer.dart` al no existir `AuditEvent` ni ruta Admin en `/Users/matybazan/Documents/api-tooapp/prisma/schema.prisma` y los módulos API inspeccionados; aceptación: no se enlaza ni atribuyen actor/motivo/valores históricos ficticios. Depends on: T001, T012, T015.

### Reportes (#27)

- [X] T086 [P] [US4] Actualizar e implementar el contrato Admin reducido de Reportes en `/Users/matybazan/Documents/api-tooapp/specs/002-dynamic-categories-reports/contracts/api-contracts.md`, `/Users/matybazan/Documents/api-tooapp/specs/001-too-api-functional-spec/contracts/rest-api.md` y `/Users/matybazan/Documents/api-tooapp/src/modules/reports/reports.repository.ts`; aceptación: `GET /admin/reports` conserva filtros y campos base vigentes, incluye opcionalmente `author` con solo `firstName`/`lastName`, y GET/PATCH omiten `authorId`, `author.id`, email y phone; sin cambios Prisma ni datos. El propietario API aprueba y registra el contrato. Depends on: none.
- [X] T087 [US4] Añadir prueba unitaria API de las respuestas Admin reducidas en `/Users/matybazan/Documents/api-tooapp/tests/unit/admin-reports-response.test.ts`; aceptación: GET/PATCH no exponen campos excluidos; GET admite `author` opcional limitado a nombre/apellido; rutas conservan ADMIN y filtros vigentes; usar mocks/stubs, sin conexión ni escritura de DB. Es evidencia de desbloqueo de G11. Depends on: T086.
- [X] T077 [US4] Crear integración tipada `GET /admin/reports`, registrar `/reports` en `lib/src/app/router/admin_router.dart` y crear `lib/src/features/reports/presentation/report_list_page.dart` con capas nuevas `lib/src/features/reports/data/` y `lib/src/features/reports/models/`; aceptación: filtros `isResolved=true|false` y `type=SUGGESTION|CLAIM|USER_REPORT`; consumir `id`, `type`, `content`, `isResolved`, `createdAt`, `updatedAt` y, solo cuando venga, `author.firstName`/`author.lastName`; no mapear ni consumir `authorId`, `author.id`, email o phone. `author` ausente permite mostrar reporte sin datos de autor. Sin paginación, orden UI adicional ni detalle separado. Carga/vacío/error/401/403. Depends on: T010, T012, T015–T017, T086–T087.
- [X] T078 [US4] Integrar resolución por `PATCH /admin/reports/:id/resolve` en `lib/src/features/reports/presentation/report_list_page.dart`; aceptación: solo UUID, sin body ni motivo; el DTO consumido omite `authorId`, `author.id`, email y phone; confirmar antes de resolver, evitar doble envío, reflejar el resultado confirmado por servidor y manejar 404/401/403/red sin éxito falso ni reversión. Reporte sin `author` se puede resolver. Depends on: T017, T077, T086–T087.
- [X] T079 [US4] Crear `test/src/features/reports/report_list_page_test.dart`; aceptación: filtros permitidos, DTO reducido, nombre/apellido solo en `author` opcional, ausencia de `author` no impide lista/resolución, ningún campo excluido se consume/renderiza/registra, sin detalle separado, resolución confirmada, 404/403/error y vacío distinto de fallo. Depends on: T077–T078, T086–T087.

## Phase 8: Verificación transversal

- [X] T080 Añadir `test/src/app/admin_drawer_accessibility_test.dart` y `test/src/app/responsive_admin_layout_test.dart`; aceptación: tres viewports (<768, 768–1199, ≥1200 px), teclado, foco visible, destino activo, semántica/lector y texto ampliado. Depends on: T003, T014–T016.
- [X] T081 Añadir pruebas de privacidad en `test/src/features/admin_read/admin_read_pages_test.dart` y `tests/unit/admin-read-routes.test.ts`; aceptación: guards ADMIN, listados sin teléfono, detalle limitado, sin DNI/secretos/coordenadas ni `problemDescription`; sin snapshots ni acceso DB. Depends on: T032–T033, T040–T044, T072–T073.
- [X] T082 Revisar formularios/mutaciones en `lib/src/features/admin_read/`, `lib/src/features/categories/` y rutas API correspondientes; aceptación: allowlists, validación cliente/servidor, confirmaciones, errores conservan cambios y éxito solo tras respuesta; sin auditoría simulada ni operaciones no aprobadas. Reportes conserva su verificación T079. Depends on: T034–T036, T045, T047, T064–T065, T078, T088–T090, T091–T092.
- [X] T083 Ejecutar formatter, `flutter analyze` y pruebas Flutter de pantallas implementables de v1; aceptación: análisis/formato limpios, 44 pruebas aisladas sin DB/red real pasan y responsive según breakpoints. Los flujos detrás de G4/G9 se omiten de esta validación y siguen bloqueados. Depends on: T017, T031, T032, T033, T041, T042, T044, T048, T049, T050, T051, T052, T053, T054, T060, T062, T079, T080, T082, T088, T089.
- [X] T084 Ejecutar typecheck, lint y pruebas API Admin con repositorios simulados y revisar guards/DTO; aceptación: lint/typecheck limpios, 27 pruebas pasan, permisos por operación verificados, sin secretos ni acceso/escritura DB. Las operaciones disponibles se verifican independientemente de G4/G9; tareas funcionales dependientes de esos gates no se implementan. Depends on: T030, T032, T034, T035, T040, T045, T060, T061, T063, T064, T065, T072, T074, T087, T090, T091, T092.
- [ ] T085 Verificar trazabilidad final contra `specs/001-admin-dashboard/spec.md`; aceptación: pantallas #1–25 tienen tarea implementable o bloqueo explícito, #26 sigue fuera de v1, #27 Reportes respeta contrato reducido y autor opcional; FR/SC referenciados; Servicios no se presenta como implementado. [BLOQUEADA: G4/G9]. Depends on: T020, T021, T022, T023, T030, T031, T032, T033, T034, T035, T036, T040, T041, T042, T043, T044, T045, T046, T047, T048, T049, T050, T051, T052, T053, T054, T060, T061, T062, T063, T064, T065, T070, T071, T072, T073, T074, T075, T076, T077, T078, T079, T080, T081, T082, T083, T084, T086, T087, T088, T089, T090, T091, T092.

## Dependencias y secuencia

### Ejemplos de ejecución en paralelo por historia

- **US1**: después de T009, T010 (cliente HTTP) y T013 (tema/tokens) pueden avanzar en
  paralelo; están marcadas `[P]` y trabajan en archivos distintos.
- **US2**: T030/T040 entregan lecturas Admin; T031–T054 integran las pantallas y verificaciones implementables. T034 → T035 → T045 son escrituras API secuenciales; T091/T092 las verifican antes de T036/T047. G7-U y G7-P están cerrados.
- **US3**: T060 y T061 integran reseñas/categorías en paralelo; T063 → T065 → T090 verifica las escrituras de categorías y T088 → T089 implementa formularios/acciones. G8 está cerrado.
- **US4**: T072 (ContactIntent), T074 (MembershipTier) y T086 (contrato reducido de Reportes)
  pueden avanzar en paralelo cuando cada contrato/gate propio esté satisfecho. La secuencia
  de Reportes T086 → T087 → T077 → T078 → T079 es serial y no paralelizable.

- T001 precede la verificación de brechas y deja G9 fundamentado. T003–T007 registran decisiones y evidencia ya confirmadas; las dependencias de cada flujo técnico pendiente mencionan sus IDs.
- Foundation: T008 → T009 → (T010 y T013 en paralelo) → T011 → T012; T014 depende de T013; T015 depende de T014; T016 depende de T012 y T014–T015; T017 precede estados y confirmaciones. Las decisiones antes denominadas G2/G3 ya están aprobadas y no bloquean estas tareas ni T080.
- Dashboard: T004 → T020 → T021 → T022 → T023.
- Usuarios: T006 → T030 → T031 → T032 → T033; edición/estado T005/T006/T030 → T034 → T035 → T091 → T036.
- Prestadores: T006 → T040 → T041 → T042/T043 → T044, T046–T054; edición T035/T040 → T045 → T092 → T047.
- Categorías: T061 → T062/T064; escritura T007/T061 → T063 → T065 → T090 → T088 → T089. Solo el alcance aprobado (crear/editar/activar/desactivar) se implementa; unificar no habilita eliminar ni cambiar `status`.
- Servicios: T001 → T070 → T071; #10 queda separado en T046, donde el DTO de Provider trae categorías asociadas y la parte Service sigue bloqueada por G9.
- Contactos: T005/T006 → T072 → T073. Membresías: T006 → T074 → T075.
- Reportes: T086 entrega el contrato API reducido → T087 verifica los DTOs → T077 integra listado/filtros → T078 integra resolución → T079 valida el flujo Flutter. T086, T087 y T077–T079 están completadas; G11 quedó resuelto y T085 conserva solo sus otros gates abiertos. No hay cambios Prisma ni de datos.
- Las tareas `[P]` solo se lanzan después de completar sus dependencias explícitas y cerrar los gates que las afectan; la etiqueta no adelanta el trabajo de ninguna capacidad bloqueada.

## Estrategia de entrega

1. Usar versiones, breakpoints y política de sesión ya aprobados para completar shell y acceso.
2. Mantener la consulta/unificación de categorías y las escrituras aprobadas verificadas por T063/T065/T090.
3. Mantener edición User/estado y Provider bajo sus allowlists y guards; no simular auditoría ni concurrencia.
4. Añadir lecturas por módulo con DTO Admin y privacidad verificados; Reportes sigue como destino independiente y T086–T087/T077–T079 están completadas bajo G11.
5. Mantener bloqueados Dashboard agregado (G4) y Services publicados (G9). Excluir pagos, transacciones, registro/gestión de administradores, CRUD localidades, conversaciones, DNI, ubicación precisa, auditoría y moderación no respaldada; no modificar Prisma, migraciones ni datos.
