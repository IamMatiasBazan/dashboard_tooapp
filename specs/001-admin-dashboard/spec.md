# Especificación funcional: Administración de usuarios y prestadores de TÖÖ

**Rama de funcionalidad**: `001-admin-dashboard`

**Creada**: 2026-11-03

**Estado**: Borrador sujeto a resolver dependencias de API

**Entrada**: Actualizar TooApp Dashboard para administrar perfiles Usuario y Prestador,
datos relacionados y funciones existentes en la app móvil, con drawer responsive y
operaciones fieles al modelo y al API vigente.

## Propósito y alcance

La consola web permite al personal autenticado con rol administrativo consultar y, cuando
el backend lo autorice, gestionar perfiles de usuarios y prestadores y consultar los datos
relacionados que TooApp registra. El drawer presenta las áreas del producto de forma
coherente. Esta especificación describe el resultado funcional deseado y separa las
capacidades ya respaldadas de las que necesitan cambios de API o decisiones previas.

El alcance v1 excluye pagos, transacciones y su administración. No incluye registro
público de administradores, gestión de administradores, mantenimiento de localidades,
conversaciones externas que la app no almacena ni operaciones administrativas inventadas.
Las localidades pueden mostrarse como dato relacionado de solo lectura cuando la respuesta
autorizada las incluya.

## Clarifications

### Session 2026-11-03

- Q: ¿Qué mecanismo autorizado aprovisiona y autentica usuarios `ADMIN` sin registro público? → A: Un operador autorizado provisiona cuentas fuera del registro público; `ADMIN` inicia sesión con el acceso existente.
- Q: ¿Debe `SUPPORT` recibir algún permiso de lectura diferenciado? → A: No; `SUPPORT` no accede a la consola v1.
- Q: ¿Debe mostrarse el DNI en la consola v1? → A: No; el DNI no se muestra en la consola v1.
- Q: ¿Cómo se muestra el teléfono a personal administrativo autorizado? → A: Oculto en listados; visible completo en la ficha a `ADMIN` cuando esté autorizado.
- Q: ¿Qué ubicación del prestador puede mostrar la consola v1? → A: Solo la localidad relacionada; no mostrar coordenadas ni ubicación actual precisa.
- Q: ¿Qué destino debe tener Reportes en v1, dado que FR-008 lo incluye pero no aparece en el mapa del drawer? → A: Agregar Reportes como módulo separado; solo se describen las operaciones y filtros respaldados por el API vigente.
- Q: ¿Qué datos del autor puede devolver y mostrar la consola v1 en Reportes? → A: Identificación básica: solo `firstName` y `lastName`. Omitir `authorId`, `author.id`, `email` y `phone` de la respuesta Admin consumida por la consola. Hasta que el contrato de `GET /admin/reports` y la respuesta de resolución se actualice para no enviar esos campos, no integrar esas operaciones desde la consola; no se requieren cambios de base de datos.
- Q: ¿Qué dependencias de navegación, HTTP y estado se aprueban para el dashboard y con qué SDK se verifican? → A: Con Flutter 3.47.7 stable y Dart 3.13.5, aprobar `go_router ^18.1.2`, `dio ^5.11.1` y `provider ^6.1.5+1`; `ChangeNotifier` se usa desde Flutter. T008 debe declararlas y actualizar el lockfile; esta decisión no modifica aún `pubspec.yaml`.
- Q: ¿Qué breakpoints definen escritorio, tablet y móvil web? → A: Móvil web <768 px; tablet 768–1199 px; escritorio ≥1200 px. En escritorio el drawer permanece vertical y persistente; en tablet se colapsa o expande; en móvil web se presenta como drawer lateral accesible.
- Q: ¿Cómo se almacena, renueva y revoca la sesión web de `ADMIN`, especialmente el refresh token? → A: Mantener access y refresh tokens solo en memoria; no persistirlos en `localStorage`, `sessionStorage` ni IndexedDB. Ante 401 del access token, realizar una única renovación coordinada usando el refresh token del body y reemplazar ambos tokens en memoria; reintentar la operación original una sola vez. Si la renovación falla, limpiar la sesión y volver al login. En logout, enviar access token y refresh token actual al endpoint existente, limpiar siempre la memoria local y no afirmar revocación del servidor si la solicitud falla; el access token emitido puede seguir válido hasta expirar. Tras recarga, requerir login nuevamente.

### Session 2026-11-04

- Q: ¿Qué escrituras administrativas de perfiles/cuentas se aprueban como objetivo de v1, sujetas a campos existentes y autorización Admin? → A: Aprobar edición de campos de perfil existentes y permitir activar/desactivar cuentas mediante `isAccountActive`. Esto no aprueba modificar campos sensibles o de sistema ni inventar validaciones. La API debe exponer rutas administrativas protegidas por `ADMIN`, sin cambios Prisma/base de datos. Auditoría, historial y control de concurrencia quedan pendientes si no existe soporte actual; no deben simularse.
- Q: ¿Qué mantenimiento Admin de categorías se aprueba sin cambiar el esquema? → A: Aprobar crear, editar y activar/desactivar categorías; conservar la unificación existente y no permitir eliminación. Las rutas nuevas deben usar campos y relaciones actuales, requerir `ADMIN` y validar las relaciones sin dejar registros huérfanos.
- Q: ¿Se aprueba moderar reseñas o imágenes de portafolio sin un estado de moderación en el modelo? → A: Mantener reseñas y portafolios solo lectura. No crear acciones de moderación ni borrado Admin en v1, y no agregar campos o cambios de esquema.
- Q: ¿Se aprueba mantenimiento Admin de tiers de membresía con los campos actuales? → A: Mantener tiers de membresía solo lectura en v1; no crear operaciones Admin de alta, edición o baja ni alterar el esquema.
- Q: ¿Qué allowlist y validaciones usarán las operaciones Admin de edición de perfiles? → A: Reutilizar los campos y validaciones de los schemas de autoservicio vigentes para `User` y `ProviderProfile`, pero protegerlos con autorización Admin independiente. Excluir DNI, rol, verificaciones y ubicaciones precisas; no incluir `isAccountActive` en el parche de perfil, pues se cambia mediante acción separada.

## Evidencia y decisiones vigentes inspeccionadas

- En este checkout no había especificaciones de producto, decisiones adicionales ni
  breakpoints establecidos; la aplicación dashboard aún conserva el `main.dart` inicial.
- La constitución de dashboard exige inventariar cada entidad y permiso, respetar API y
  separar capacidades faltantes, aplicar mínimo privilegio, estados explícitos y diseño
  responsive/accesible. Esos principios rigen este documento.
- `pubspec.yaml` declara Dart SDK `^3.13.5`, Flutter SDK, `flutter_test` y
  `flutter_lints: ^6.0.0`. Se aprobaron `go_router ^18.1.2`, `dio ^5.11.1` y
  `provider ^6.1.5+1` con Flutter 3.47.7 stable/Dart 3.13.5; T008 los añadió a
  `pubspec.yaml` y verificó la resolución del lockfile.
- La app móvil contiene flujos de acceso/registro, búsqueda y perfil de prestadores,
  categorías, eventos de contacto, reseñas, perfil y disponibilidad del prestador,
  ubicaciones, portfolio, membresía y métricas. Estos flujos identifican datos del
  producto; sus controles de usuario/proveedor no definen permisos administrativos.
- El API revisado define guards `ADMIN` en consulta/unificación de categorías y consulta/
  resolución de reportes. Registro público acepta solo `CLIENT` o `PROVIDER`. Las rutas
  restantes observadas son públicas, `CLIENT`, `PROVIDER` o de autoservicio; no se
  consideran autorización administrativa.

## Actores y permisos

| Actor | Capacidades en esta especificación |
|---|---|
| Personal `ADMIN` | Único rol administrativo de consola. Puede usar las rutas Admin de lecturas, Reportes, categorías y las escrituras aprobadas de perfil/cuenta protegidas por `authenticate` y `requireRole('ADMIN')`. |
| `SUPPORT` | Existe en `UserRole`, pero no accede a la consola v1. Ninguna ruta administrativa inspeccionada le concede acceso. |
| `CLIENT`, `PROVIDER` | Roles de la app. Sus acciones propias no confieren capacidad de administración en la consola. |

La autorización debe verificarse en servidor para cada operación. El acceso denegado no
debe revelar datos protegidos. Las cuentas `ADMIN` se provisionan fuera del registro
público por un operador autorizado y usan el inicio de sesión existente; no hay alta o
edición administrativa de esas cuentas en v1. El rol `SUPPORT` no tiene acceso a la
consola en v1.

La sesión web mantiene access y refresh tokens solo en memoria. Ante un 401 del access
token, la consola coordina una única llamada de renovación con el refresh token en el body,
reemplaza ambos tokens en memoria y reintenta una vez la operación original. Si renovar
falla, limpia la sesión y vuelve al login. Logout envía el access token Bearer y el
refresh token vigente al endpoint existente, luego limpia la sesión local; si la llamada
falla, no se afirma que el servidor haya revocado el refresh token. El access token ya
emitido puede seguir válido hasta expirar. Recargar la página requiere volver a iniciar
sesión. No se persisten tokens en `localStorage`, `sessionStorage` ni IndexedDB.

## Mapa del drawer

El drawer vertical agrupa estas áreas y conserva el mismo inventario de módulos en todos
los tamaños. Marca de forma visible y accesible el destino activo, permite navegar a los
módulos autorizados y no muestra una opción como operativa si su capacidad está pendiente.
Los módulos pendientes pueden figurar como no disponibles con explicación solo cuando
una decisión de producto así lo apruebe; no deben simular datos ni acciones.

1. **Dashboard** — resumen administrativo; métricas solo cuando su fuente y permisos existan.
2. **Usuarios** — listado y detalle de cuentas `CLIENT`; edición de campos permitidos y activación/desactivación por `isAccountActive` mediante operaciones Admin protegidas.
3. **Prestadores** — listado y ficha Admin, subsecciones existentes y edición de campos permitidos de `User`/`ProviderProfile`; servicios publicados no existen en el modelo.
4. **Categorías y oficios** — listado, unificación, alta, edición y activación/desactivación Admin confirmados; eliminar y cambiar `status` no forman parte de v1.
5. **Servicios y tarifas** — consultas solicitadas; no existe modelo `Service` independiente.
   La tarifa observada vive en `ProviderProfile`; módulo global y mantenimiento dependen del API.
6. **Portafolios** — listado Admin de imágenes existente; moderación no disponible.
7. **Contactos** — `ContactIntent`; listado/detalle Admin de metadatos existentes, sin `problemDescription` ni conversaciones.
8. **Reseñas** — `Review`; listado Admin y subsección por prestador existentes; moderación no disponible.
9. **Disponibilidad y ubicaciones** — consulta administrativa global y ubicación precisa
   dependen de operación autorizada; no editar desde consola.
10. **Membresías** — `MembershipTier` confirmado y enlazado a `ProviderProfile`; listado/detalle Admin de solo lectura disponible; escritura continúa pendiente.
11. **Auditoría** — no hay modelo ni ruta. No aparece como pantalla v1; queda como dependencia
    explícita antes de atribuir cambios sensibles a un administrador.
12. **Reportes** — destino independiente con listado y filtros `isResolved`/`type`, y acción
    para marcar como resuelto según el contrato Admin vigente. No se anida en Dashboard ni
    Auditoría y no incluye pagos.

### Comportamiento por tamaño

El repositorio no tenía breakpoints implementados; para v1 se adoptan los rangos aprobados
en esta especificación:

- **Escritorio (≥1200 px)**: drawer vertical persistente junto al contenido; la etiqueta/icono del
  destino activo permanece identificable.
- **Tablet (768–1199 px)**: drawer lateral colapsable o expandible, operable por teclado y táctil, que
  conserva áreas, orden y permisos.
- **Móvil web (<768 px)**: drawer lateral invocado desde un control accesible; al elegir una opción,
  el drawer se cierra y el foco y título se sitúan de forma predecible en la nueva vista.
- En todos los tamaños, reflow sin pérdida de acciones o datos, foco visible, etiquetas
  accesibles y estados de carga/error/vacío anunciables.

## Inventario de datos y respaldo

| Dato o entidad | Fuente/relación real | Estado para administración |
|---|---|---|
| Usuario | `User`: `id`, `role`, nullable `email`, `firstName`, `lastName`, `isAccountActive`, `createdAt`, `updatedAt`, relación nullable `locality`; relación opcional `providerProfile`. | `GET /admin/users` lista solo `CLIENT`; detalle autorizado puede incluir teléfono/avatar. `PATCH /admin/users/:userId` reusa `ownUserPatchSchema`; ruta de estado cambia únicamente `isAccountActive`. DNI, hashes y tokens excluidos. |
| Perfil de prestador | `ProviderProfile` 1:1 con `User`; categoría primaria/secundarias, membresía opcional, disponibilidad, fuente de ubicación, localidad de `User`, tarifas del perfil, facturación, portfolio, bio, experiencia y matrícula. | `GET /admin/providers` omite teléfono/avatar; el detalle Admin puede incluir `phone` y `avatarUrl`. `PATCH /admin/providers/:providerProfileId` admite por separado allowlists de `User` y `ProviderProfile`; omite coordenadas, DNI y `isDniVerified`. |
| Categoría | `Category`: `name`, `iconUrl`, `status` (`APPROVED`, `PENDING`, `REJECTED`), `isActive`, `createdAt`; relaciones con perfiles, categorías secundarias y contactos. | `ADMIN` puede listar, unificar, crear, editar `name`/`iconUrl` y cambiar `isActive`. Aprobar/rechazar mediante `status` y eliminar siguen excluidos. |
| Oficio/especialidad | El esquema usa `Category` y `ProviderSecondaryCategory` (relación M:N); el perfil tiene `primaryCategoryId`. No define entidades `Trade` o `Specialty`. | Mostrar categoría primaria/secundarias solo con respuesta autorizada. Conceptos separados de oficio/especialidad son brecha de modelo si producto los requiere. |
| Servicio | No existe modelo `Service`. | Nombre, descripción, publicación, mantenimiento o conteo de “servicios publicados” no se pueden respaldar. `minPrice`, `chargesConsultation`, `consultationPrice` son campos del perfil, no tarifas por servicio. |
| Contacto | `ContactIntent`: `clientId`, `providerId`, `categoryId`, nullable `problemDescription`, `status`, nullable `scheduledFor`, `createdAt`, `updatedAt`; relaciones a usuario, perfil, categoría y reseñas. | `GET /admin/contact-intents` y `GET /admin/contact-intents/:contactIntentId` devuelven relaciones y metadatos, omiten `problemDescription`; no prueban conversaciones/canales externos. La autorización de acceso a ese texto queda pendiente. |
| Reseña | `Review`: `contactIntentId`, `authorId`, `targetId`, `direction`, nullable `rating`, nullable `comment`, nullable `cancellationReason`, nullable JSON `metadata`, `createdAt`. No hay `moderationStatus`. | `GET /admin/reviews` y `GET /admin/providers/:providerProfileId/reviews` consultan `CLIENT_TO_PROVIDER`; promedio/total se derivan en lectura. No hay moderación. |
| Portfolio | `ProviderPortfolioImage`: `providerProfileId`, `imageUrl`, `createdAt`; no hay título, descripción ni estado de moderación. | `GET /admin/portfolio` permite filtrar por perfil y fecha. No hay moderación `ADMIN`. |
| Disponibilidad | `ProviderProfile.isAvailable`, nullable `shiftEndsAt`, `lastPulseAt`, nullable `availabilityLocationSource` (`BASE`, `CURRENT`). | `GET /admin/providers` y `/admin/providers/:providerProfileId` devuelven disponibilidad efectiva: activa solo cuando `isAvailable` es true y `shiftEndsAt` futuro. No editar pulsos ni exponer coordenadas. |
| Ubicaciones | `baseLocation` y `currentLocation` son `Unsupported("geometry(Point, 4326)")`; nullable `coverageRadiusKm`; el API expone ubicación base para perfil propio y localización actual como coordenadas al iniciar un pulso. `User.localityId` referencia `Locality`. | Consola v1 solo muestra `Locality` relacionada si viene en una respuesta autorizada. No mostrar coordenadas ni ubicación actual precisa. No hay mantenimiento de localidades ni historial de puntos. |
| Membresía | `MembershipTier`: `name`, nullable `description`, `price`, `createdAt`; `ProviderProfile.membershipTierId` nullable. | `GET /admin/membership-tiers` y `GET /admin/membership-tiers/:tierId` son de solo lectura. No existen suscripciones/períodos/pagos; excluir cobros y transacciones. |
| Reporte | `Report`: `id`, `authorId`, `type`, `content`, `isResolved`, `createdAt`, `updatedAt`; relación `author`. | Contrato Admin reducido implementado: GET omite `authorId` y devuelve `author?` con solo nombre/apellido; GET/PATCH omiten email/teléfono e identificadores del autor. |
| Localidad | `Locality`: `name`, `slug`, `isEnabled`, fechas; relación desde usuarios. | El endpoint observado devuelve localidades habilitadas; solo lectura. No incluir pantalla CRUD ni herramientas de búsqueda/mantenimiento. |
| Auditoría | No existe entidad de auditoría ni ruta identificada. | Registro de administrador, acción, motivo y valores previos/nuevos son dependencia; no afirmar que se almacenen. |

## Historias y definición por pantalla

Las pantallas siguientes describen alcance de producto; “confirmado” significa que el
modelo/contrato observado respalda los datos u operación, no que ya esté implementada en
el dashboard. Las operaciones marcadas **pendientes** no pueden exponerse como funcionales
hasta resolver la brecha. Todas las pantallas requieren sesión administrativa válida y
respuesta de permiso; denegación, fallo de red y error del servidor conservan el contexto
sin mostrar datos no autorizados.

### US1 — Resumen y navegación administrativa

#### 1. Dashboard — resumen administrativo

- **Propósito**: ofrecer acceso inicial a datos agregados con origen verificable.
- **Datos y regla**: total de usuarios: contar `User`; total de prestadores: contar `User.role=PROVIDER` o perfiles, con regla única pendiente; disponibles: contar perfiles que satisfagan la lógica vigente (`isAvailable` y `shiftEndsAt > ahora`); oficios publicados: **no disponible**, no existe servicio/oficio publicado modelado; contactos recibidos: contar `ContactIntent` según definición de “recibido” pendiente; reseñas recientes: seleccionar `Review.createdAt` dentro de una ventana por definir; reseñas pendientes: **no disponible**, no existe estado de moderación.
- **Acciones/permisos**: navegar a listados solo cuando existan ruta y permiso de lectura. Sin edición de agregados.
- **Validaciones/estados**: no combinar conteos parciales como totales confirmados; carga por indicador; error por fuente; vacío cuando la fuente responde cero; acceso denegado por indicador/módulo.
- **Aceptación**: cada cifra muestra fuente y regla; no se guardan como editables; fuentes no soportadas se identifican como pendientes y no muestran cifra ficticia; los enlaces conducen únicamente a listados autorizados.
- **Dependencias**: consultas de resumen; definición de periodo de “recientes” y de base para contar prestadores/contactos.

#### 2. Usuarios — listado

- **Propósito/datos**: paginar `User` con nombre, apellido, email nullable, `createdAt`, `isAccountActive`; búsqueda/filtros solo por campos soportados. Teléfono y DNI quedan ocultos en este listado.
- **Acciones**: buscar por nombre, apellido o email; filtrar por `isAccountActive`; paginar y abrir detalle. La API permite leer solo cuentas con rol `CLIENT`.
- **Validaciones/estados**: query `q`, `isAccountActive`, `page` y `limit` validados por contrato; carga, sin coincidencias, error de red/servidor y sin permiso `ADMIN` tienen mensajes diferenciados.
- **Aceptación**: se muestran datos devueltos por servidor; email ausente se marca como no disponible; no se ofrece exportación ni mutación. Teléfono no forma parte del DTO de listado.

#### 3. Usuarios — detalle

- **Datos**: nombre, apellido, correo, alta, estado; opcionales `locality` de solo lectura, avatar y datos de búsqueda únicamente si se persisten y una respuesta autorizada los incluye. Prisma no contiene categoría elegida ni `radiusKm` del cliente.
- **Acciones/permisos**: regresar al listado y abrir el formulario de edición protegido por `ADMIN`; enlaces relacionados solo aparecen cuando hay ruta y permiso.
- **Estados/aceptación**: carga; no encontrado; error/autorización; cada opcional ausente se muestra “Dato no disponible”. Categoría/radio no se presentan como atributos confirmados del perfil.

#### 4. Usuarios — edición

- **Datos/acciones**: `PATCH /admin/users/:userId` reutiliza la allowlist validada por `ownUserPatchSchema`: `phone`, `email`, `firstName`, `lastName`, `avatarUrl`, respetando sus reglas actuales. La ruta requiere autorización Admin independiente. `role`, `dni`, verificación, fechas, hashes y tokens no se editan.
- **Validaciones**: reutilizar las reglas de `ownUserPatchSchema` (phone trim 1–30; email válido o null; first/last name trim 1–100; avatar URL o null) y validar también en servidor.
- **Estados/aceptación**: formulario conserva cancelación; error de unicidad/conflicto no borra los cambios; éxito solo después de confirmación servidor; versión/conflictos desactualizados requieren soporte API pendiente.

#### 5. Usuarios — estado de cuenta

- **Modelo/decisión**: se aprueba permitir activar/desactivar la cuenta mediante el campo existente `User.isAccountActive`. Esto no define suspensión, motivo, historial ni otra transición distinta del booleano.
- **Flujo**: implementar una operación Admin explícita y protegida; mostrar estado actual y solicitado, pedir confirmación y reflejar solo el valor confirmado por el servidor. No requiere cambio de esquema/base de datos.
- **Aceptación**: solo `ADMIN`; 401/403, error y red no cambian el estado mostrado ni aparentan éxito. Auditoría y motivo no se presentan como disponibles si no hay soporte actual.

### US2 — Consulta y gestión de prestadores

#### 6. Prestadores — listado

- **Datos**: nombre/apellido/email de `User`; categoría primaria y secundarias; disponibilidad calculada con `isAvailable` y `shiftEndsAt`; perfil vinculado por `ProviderProfile.userId`. Teléfono y DNI no se muestran en listado. Verificación/aprobación no tiene un estado general: `isDniVerified` solo refiere al DNI y `Category.status` al estado de categoría.
- **Acciones**: buscar por nombre/apellido/email, filtrar por categoría primaria/secundaria y disponibilidad efectiva, y abrir ficha mediante rutas Admin de lectura.
- **Estados/aceptación**: carga/vacío/error/sin permiso; teléfono/avatar se omiten del listado y se muestran solo si aparecen en ficha Admin; un dato no expuesto por contrato se omite, no se obtiene de endpoint de autoservicio con otro rol.

#### 7. Prestadores — detalle administrativo

- **Datos**: identidad de usuario (incluidos teléfono/avatar solo en detalle ADMIN) y campos de `ProviderProfile`; categoría principal, estado operativo, promedio/cantidad de reseñas y portfolio count desde relación. Conteo de servicios publicados no aplica: no existe `Service`.
- **Acciones**: navegar a subsecciones disponibles; `GET /admin/providers/:providerProfileId` devuelve perfil, categorías, precios del perfil, facturación modelada, localidad de cuenta y cantidad de imágenes.
- **Aceptación**: no se editan agregados; valores se atribuyen a la fuente recibida; no disponible/no autorizado no se interpreta como cero.

#### 8. Prestadores — perfil personal y profesional

- **Datos**: `User.firstName`, `lastName`, `email`, `phone`; `ProviderProfile.primaryCategory`, `secondaryCategories`, `matriculaNumber`, `isMatriculado`, `experienceYears`, `bio`, fechas. `dni` e `isDniVerified` existen en el modelo, pero no se muestran en consola v1. No existe campo `specialty`, `accountStatus` distinto a usuario ni estado de verificación/aprobación del perfil.
- **Permisos**: lectura del DTO limitada a `ADMIN`; teléfono y avatar solo se muestran en la ficha, no en el listado. El DNI se excluye de todas las pantallas v1.
- **Aceptación**: no exponer DNI ni `isDniVerified`; los campos opcionales ausentes se identifican como no disponibles; no exponer hash de contraseña ni tokens.

#### 9. Prestadores — edición del perfil

- **Datos/candidatos**: el body separa `user` y `providerProfile`. `user` reutiliza `ownUserPatchSchema`: `firstName`, `lastName`, `email`, `phone`, `avatarUrl`; `providerProfile` reutiliza `providerFields`: `primaryCategoryId`, `bio`, `experienceYears`, `isMatriculado`, `matriculaNumber`, `coverageRadiusKm`, `minPrice`, `chargesConsultation`, `consultationPrice`, `issuesInvoice` e `invoiceType`. La ruta requiere autorización Admin independiente. No editar DNI, rol, `isAccountActive`, verificaciones, claves, `baseLocation`, coordenadas ni campos derivados/de sistema.
- **Validaciones**: aplicar las reglas actuales de ambos schemas: nombre/apellido trim 1–100; phone trim 1–30; email válido o null; `avatarUrl` URL o null; experiencia entero ≥0; matrícula hasta 50 caracteres; bio trim con máximo 5000; radio/precios enteros no negativos o null; categoría primaria con UUID y validación de categoría activa según servicio actual. Requerir al menos un campo permitido y no aceptar secciones vacías.
- **Aceptación**: teléfono/avatar solo en detalle ADMIN, nunca en listados; distinguir editable/solo lectura según allowlist Admin explícita; guardar/cancelar; error conserva formulario; éxito requiere respuesta servidor. Auditoría y control de concurrencia no se simulan si no existen; no se modifica Prisma/base de datos.

#### 10. Prestadores — servicios y oficios publicados

- **Modelo real**: no hay servicios publicados. Oficios se representan por `Category` primaria y `ProviderSecondaryCategory`; no existe estado de publicación ni fecha por relación secundaria aparte de `createdAt`.
- **Acciones**: consulta global, búsqueda y conteo “publicado” no disponibles con definición actual. Categorías asociadas pueden consultarse solo cuando contrato admin las incluya.
- **Aceptación**: no crear, editar, activar ni eliminar un servicio inexistente; contar categorías requiere llamarse “categorías asociadas”, no “servicios publicados”; el módulo de servicios queda como dependencia de modelo/API.

#### 11. Prestadores — tarifas y facturación

- **Datos**: `minPrice`, `chargesConsultation`, `consultationPrice`, `issuesInvoice`, `invoiceType` (`NONE`, `FACTURA_C`, `FACTURA_A_B`, `OTHER`). No existe unidad/modalidad de cobro ni datos fiscales completos, alícuotas, CUIT o facturas.
- **Acciones**: consultar y editar los campos del perfil permitidos por `providerFields` mediante `PATCH /admin/providers/:providerProfileId`; ningún pago/transacción.
- **Aceptación**: campos ausentes como “no disponible”; no inferir un precio por servicio ni añadir campos fiscales; llamar precios “indicativos del perfil” hasta definición de negocio.

#### 12. Prestadores — disponibilidad

- **Datos**: `isAvailable`, `shiftEndsAt`, `lastPulseAt`, `availabilityLocationSource`; el API calcula activo solo cuando el booleano es verdadero y hora límite futura.
- **Acciones**: consulta Admin desde `GET /admin/providers`; consola no inicia, edita ni finaliza pulsos. El prestador define estos datos desde la app.
- **Estados/aceptación**: mostrar vencida si `shiftEndsAt <= ahora`; desactualizada si existe regla de frescura aprobada, pendiente actualmente; falta de hora no significa disponible. Mostrar la hora y zona de negocio declaradas por API sin inventar umbral.

#### 13. Prestadores — ubicaciones

- **Datos**: `User.locality` relacionada, solo cuando esté disponible en respuesta autorizada. `BASE`/`CURRENT` y las geometrías base/actual existen en `ProviderProfile`, pero no se muestran en consola v1.
- **Acciones**: consultar únicamente la localidad relacionada que devuelve el DTO Admin; no cambiar ubicación o localidades desde consola.
- **Privacidad/aceptación**: mostrar solo localidad; no mostrar coordenadas, mapa, ubicación actual precisa, `coverageRadiusKm` como sustituto de ubicación, ni historial inferido. Localidad es de solo lectura y no hay mantenimiento. Datos ausentes/error/denegación no se reemplazan por ubicación inferida.

#### 14. Prestadores — portafolio en ficha

- **Datos**: imagen `imageUrl`, `createdAt`, relación con perfil. Título, descripción, fecha de publicación separada y estado de moderación no existen.
- **Acciones**: proveedor puede listar/crear/eliminar sus imágenes en API; `ADMIN` consulta imágenes con `GET /admin/portfolio`. Decisión v1: reseñas e imágenes permanecen de solo lectura para `ADMIN`; no hay moderación ni borrado Admin.
- **Aceptación**: la ficha administrativa no promete ocultar/retirar/moderar; render de imagen fallida tiene alternativa textual; auditoría/motivo/responsable dependen de capacidades futuras.

#### 15. Portafolios — listado global

- **Datos**: imágenes vinculadas a `ProviderProfile`, `imageUrl`, `createdAt`.
- **Acciones/estados**: listado global Admin filtrable por prestador y fecha, con carga/vacío/error/sin permiso; no existe estado de moderación. La decisión v1 mantiene el contenido en solo lectura.
- **Aceptación**: no filtrar por estado inexistente ni ofrecer acciones de moderación/borrado Admin.

#### 16. Prestadores — reseñas en ficha

- **Datos**: reseñas donde `targetId` corresponde al `User`, autor, dirección, rating nullable, comment nullable, fecha; `contactIntent` relacionado. Agregados disponibles en `User.ratingAvg` y `reviewsCount`, sujetos a consistencia con consulta.
- **Acciones**: consultar las reseñas del prestador mediante `GET /admin/providers/:providerProfileId/reviews`; promedio y total se calculan desde `Review`, no desde campos editables. Decisión v1: reseñas de solo lectura Admin, sin moderación ni borrado.
- **Aceptación**: distinguir reseña con comentario/rating null; no mostrar estado pendiente de moderación; datos agregados no se modifican manualmente.

### US3 — Reseñas y categorías

#### 17. Reseñas — listado administrativo

- **Datos/filtros candidatos**: `rating`, `comment`, autor, usuario objetivo/prestador, `direction`, `createdAt`; estado no existe. API ofrece lecturas paginadas solo a `CLIENT` y `PROVIDER`, no a `ADMIN`.
- **Acciones**: listado, búsqueda, filtros, moderar/ocultar/retirar son dependencias pendientes; no publicar controles ficticios.
- **Aceptación**: una puntuación nula no se convierte en cero; autor/objetivo se identifican por relaciones; autorización denegada no filtra resultados.

#### 18. Categorías y oficios — listado

- **Propósito/datos**: `Category.name`, `iconUrl`, `status`, `isActive`, `createdAt`; asociaciones a perfiles/categorías secundarias y conteos opcionales expuestos por resultado admin.
- **Acciones/permisos confirmados**: `ADMIN` consulta `/admin/categories`, filtra `status` (APPROVED/PENDING/REJECTED) y `active` (true/false). La ruta requiere token válido y rol ADMIN.
- **Estados/aceptación**: carga/vacío/error/401-403; filtros solo enumerados; conteos se muestran solo si response los contiene y no se estiman desde resultados parciales.

#### 19. Categorías y oficios — crear y editar

- **Crear/editar**: `POST /admin/categories` y `PATCH /admin/categories/:categoryId` usan únicamente `name` e `iconUrl`, con guard `ADMIN`, schema y validación de unicidad existentes. `/categories` no se reutiliza como permiso administrativo.
- **Campos/validación**: se aprueba alta y edición Admin con los campos actuales de categoría. Nombre trim de 2–100 caracteres e `iconUrl` URL nullable/opcional son reglas observadas en el schema existente; el contrato Admin debe validarlas explícitamente y no añadir campos.
- **Aceptación**: `ADMIN` puede crear/editar con respuesta confirmada; mensajes y reintentos no afirman éxito sin servidor. Sin cambios Prisma/base de datos.

#### 20. Categorías y oficios — activar, desactivar o eliminar

- **Confirmado**: estados `APPROVED`, `PENDING`, `REJECTED`, flag `isActive`; endpoint admin para unificar dos IDs distintos, con validación UUID. El servicio transfiere relaciones conforme a implementación actual y devuelve cantidad de perfiles actualizados.
- **Decisión**: se aprueba activar/desactivar una categoría utilizando el `isActive` existente; las transiciones de `status` (`APPROVED`, `PENDING`, `REJECTED`) no quedan aprobadas como operación de aprobar/rechazar. La eliminación queda excluida; se conserva la unificación existente.
- **Flujo de unificación**: seleccionar origen/destino diferentes; verificar etiquetas y efecto antes de confirmar; éxito se basa en resultado del servidor; error/conflicto deja datos intactos visualmente y ofrece reintento seguro. Auditoría no existe.
- **Aceptación**: rutas Admin protegidas para activar/desactivar; confirmar el cambio y mostrar únicamente el resultado del servidor. La eliminación no se expone; conflictos/relaciones no se resuelven con escrituras directas ni cambio de esquema.

### US4 — Módulos relacionados

#### 21. Servicios y tarifas — listado global

- **Modelo**: no hay `Service`; perfil conserva precios orientativos y categorías. No hay fecha/estado de publicación de servicio.
- **Pantalla**: el módulo solicitado queda documentado como pendiente; no lista resultados inventados. Cuando exista contrato, incluir prestador, categoría, nombre/descr., tarifa, estado y fechas solo si están modelados.
- **Aceptación**: v1 no cuenta servicios publicados ni confunde perfiles/categorías con servicios.

#### 22. Servicios y tarifas — detalle y mantenimiento

- **Acciones**: consulta/mantenimiento no disponible. Datos actuales de precio pertenecen al perfil; edición vía API es autoservicio Provider.
- **Aceptación**: cualquier consulta/edición admin requiere entidad/operación, roles, validaciones y reglas acordadas; sin ello no hay formulario operativo. No incluye pagos.

#### 23. Contactos — listado

- **Datos**: `ContactIntent` y relaciones con cliente, perfil prestador y categoría; estado enum, descripción opcional y fechas.
- **Acciones**: `ADMIN` puede listar y filtrar eventos persistidos por perfil, categoría, estado y fechas; no administra el estado.
- **Aceptación**: DTO muestra relaciones y metadatos registrados, omite `problemDescription`; no afirmar almacenamiento de canal o mensajes.

#### 24. Contactos — detalle

- **Datos**: relaciones e información guardada del evento únicamente; `problemDescription` puede contener texto personal.
- **Permisos**: `ADMIN` consulta metadatos; `problemDescription` permanece excluido hasta una decisión de privacidad.
- **Aceptación**: no exponer conversaciones externas; carga/no encontrado/error/denegación; valores null como no disponibles. No habilitar cambios de estado al administrador con la ruta CLIENT.

#### 25. Membresías — listado, detalle y mantenimiento

- **Inclusión**: confirmada por modelos `MembershipTier` y `ProviderProfile.membershipTierId`, y vistas móviles.
- **Datos**: tiers `name`, `description`, `price`, `createdAt`; relación opcional al perfil. No hay entidad de compra, suscripción, vigencia o transacción.
- **Acciones**: `ADMIN` puede listar y consultar detalle de tiers; la decisión v1 mantiene los tiers solo lectura y no habilita alta, edición, activación ni baja. Sin pagos/cobros.
- **Aceptación**: no inventar estado de membresía ni facturación; datos relacionados se consultan solo con permiso futuro; precio del tier no equivale a pago ejecutado.

#### 26. Auditoría — no incluida como pantalla v1

- Prisma no contiene tabla/evento de auditoría y no hay endpoint. Responsable, motivo, fecha por administrador, valores anteriores/nuevos no están respaldados.
- Antes de habilitar edición sensible, estado de cuenta o moderación, definir mecanismo, retención, acceso y campos seguros como dependencia. Nunca registrar contraseña, `passwordHash`, access/refresh token, `tokenHash` ni secretos.
- **Aceptación**: ninguna pantalla enlaza a un historial ficticio; acciones pendientes no se habilitan suponiendo auditoría.

#### 27. Reportes — listado y resolución

- **Actor y propósito**: `ADMIN` consulta y resuelve reportes en el destino independiente **Reportes** del drawer.
- **Campos y contrato de autor**: los campos del reporte son `id`, `type` (`SUGGESTION`, `CLAIM`, `USER_REPORT`), `content`, `isResolved`, `createdAt` y `updatedAt`. La decisión v1 permite recibir y mostrar únicamente `author.firstName` y `author.lastName`, dentro del objeto opcional `author`. El contrato e implementación Admin vigentes limitan `author` a esos dos campos y omiten `authorId`, `author.id`, `email` y `phone` en GET y PATCH. No leer, mapear, guardar ni registrar esos campos excluidos. Si `author` no viene, mostrar el reporte sin datos del autor; no tratarlo como error ni impedir su resolución. No abrir un detalle separado.
- **Filtros y consulta**: `GET /admin/reports` acepta únicamente `isResolved=true|false` y `type` con los tres valores del enum. No hay query de paginación ni filtros adicionales. La pantalla no añade ordenamiento o controles de paginación.
- **Acciones y permisos**: listar y filtrar con `GET /admin/reports`; marcar como resuelto con `PATCH /admin/reports/:id/resolve`, que valida `id` como UUID y no requiere body. Ambas operaciones requieren autenticación y `requireRole('ADMIN')`. El API retorna 404 si el reporte no existe. No hay desresolución, asignación, motivo ni auditoría.
- **Validaciones y confirmación**: no enviar parámetros fuera de los schemas. Confirmar antes de marcar resuelto; impedir envíos duplicados durante la acción y actualizar `isResolved`/`updatedAt` desde la respuesta del servidor. No presentar éxito local ni habilitar una reversión inexistente.
- **Estados**: carga inicial y de filtros, error de red/servidor, vacío sin filtros, vacío filtrado, permiso insuficiente (401/403), no encontrado en resolución, acción en curso y éxito confirmado. Mensajes no deben exponer respuestas crudas ni datos personales innecesarios.
- **I1/G11 — resolución**: la decisión aprobada limita los datos del autor a nombre y apellido opcionales. T086 actualizó contrato y selects de GET/PATCH; T087 verificó las respuestas reducidas, filtros y guard ADMIN mediante pruebas con repositorios simulados. No se modificó Prisma ni datos. La consola puede consumir el contrato reducido y mantiene el caso `author` ausente.
- **Criterios de aceptación**: Reportes aparece como módulo independiente y activo en el drawer; solo `ADMIN` accede; los campos y filtros coinciden con el contrato actualizado; solo se consume `author.firstName`/`author.lastName`; si `author` falta, el reporte se muestra sin autor y se puede resolver; email/phone no se leen ni se presentan; no existe vista de detalle separada; resolución informa únicamente el resultado confirmado por servidor y maneja 404/401/403/red sin aparentar éxito.

## Flujos principales y alternativos

1. Un operador autorizado provisiona la cuenta `ADMIN` fuera del registro público.
   `ADMIN` inicia sesión con el acceso existente y abre Dashboard; el registro público
   continúa limitado a `CLIENT` y `PROVIDER`.
2. El personal selecciona módulo en drawer; el destino activo se anuncia visualmente y
   con semántica accesible. En tamaño compacto, seleccionar destino cierra drawer.
3. Un listado autorizado carga resultados; permite paginación/filtros únicamente conforme
   a contrato. Seleccionar registro abre detalle, volver preserva filtros/página si el
   flujo lo permite.
4. Al guardar una edición de User, ProviderProfile o Category, se validan entradas, se
   informa carga, se presentan errores de validación/conflicto sin perder cambios, y se
   informa éxito después de confirmación del endpoint Admin protegido. No se simulan
   auditoría ni conflictos de concurrencia ausentes.
5. Unificación de categoría confirmada requiere dos categorías distintas y confirmación
   del efecto; respuesta del servidor informa resultado. Error/timeout no se presenta
   como completado y la UI vuelve a consultar antes de reintentar si el resultado quedó
   incierto.
6. Resolución de reporte confirmada cambia `isResolved` a true a través de endpoint Admin;
   no ofrece asignación ni motivo no modelados.
7. En cualquier módulo, sesión vencida/401 conduce a recuperación de sesión autorizada;
   403 muestra acceso insuficiente; fallos de red y 5xx permiten reintentar sin revelar
   cuerpo sensible.

## Casos límite

- Un usuario no tiene `email`, `dni`, `localityId` o un prestador no tiene membresía,
  ubicación o campos opcionales: la vista indica dato no disponible y conserva el resto.
- El mismo usuario tiene un perfil de prestador; los listados no deben contarle dos veces
  como usuario ni confundir cantidad de usuarios con cantidad de perfiles.
- Un prestador tiene `isAvailable=true` pero `shiftEndsAt` nulo o vencido: no se presenta
  como disponible según la regla observada.
- Un reporte ya resuelto, una categoría ya unificada/no encontrada o una respuesta
  conflictiva: presentar estado confirmado por API, no inventar una reversión.
- El usuario selecciona filtros sin resultados: mostrar vacío filtrado, distinto de cero
  resultados globales, fallo o falta de autorización.
- Una respuesta parcial falla mientras se cargan tarjetas del Dashboard: identificar la
  tarjeta con error y no presentar el agregado parcial como total completo.
- Una actualización se envía y vence la conexión antes de recibir respuesta: el resultado
  queda incierto; consultar estado cuando haya contrato antes de permitir repetición que
  pudiera duplicar o reiterar una acción irreversible.
- Un viewport compacto, zoom o texto ampliado reduce espacio: drawer y formularios siguen
  accesibles sin ocultar acciones ni perder foco.

## Requisitos funcionales

- **FR-001**: La consola MUST presentar los módulos del drawer descritos y señalar el
  módulo activo de forma perceptible y accesible.
- **FR-002**: El drawer MUST adaptarse a escritorio, tablet y móvil web sin perder áreas,
  orden ni controles de acceso, usando los breakpoints aprobados: móvil web `<768 px`,
  tablet `768–1199 px` y escritorio `≥1200 px`.
- **FR-003**: Antes de cada lectura/mutación protegida, el sistema MUST exigir sesión y
  permisos validados por servidor; la UI MUST NOT tratar su ocultamiento como control.
- **FR-015**: En v1, solo `ADMIN` puede acceder a la consola; `SUPPORT`, `CLIENT` y
  `PROVIDER` MUST NOT acceder a sus módulos administrativos.
- **FR-004**: Cada campo mostrado MUST vincularse a modelo/contrato o marcarse como dato
  ausente/no disponible; datos inferidos MUST NOT presentarse como persistidos.
- **FR-005**: El personal MUST poder consultar perfiles/usuarios/prestadores solo después
  de que exista endpoint administrativo y permiso explícito; hasta entonces esos flujos
  quedan bloqueados como dependencia, no simulados.
- **FR-006**: Datos derivados MUST indicar fuente y regla, y MUST NOT ser editables como
  valores independientes.
- **FR-007**: Categorías MUST permitir consulta Admin con filtros de `status`/`active` y
  unificación de categorías distintas según contrato vigente.
- **FR-008**: Reportes MUST figurar como módulo independiente y permitir consulta Admin con
  filtros `isResolved`/`type` y resolución según contrato vigente. MUST mostrar los campos
  del reporte y, cuando venga, solo `author.firstName`/`author.lastName`; GET/PATCH MUST
  omitir `authorId`, `author.id`, email y phone. Si `author` falta, se muestra y resuelve el
  reporte sin autor. No hay detalle separado, paginación, motivo ni gestión de pagos.
- **FR-009**: Teléfono y contenido de contacto MUST mostrarse solo tras decisión de
  necesidad y permiso, siguiendo mínimo privilegio. El teléfono MUST NOT
  mostrarse en listados; cuando esté autorizado se muestra completo en ficha a `ADMIN`.
- **FR-016**: La consola v1 MUST NOT mostrar `User.dni` ni `User.isDniVerified` en ninguna pantalla.
- **FR-017**: La consola v1 MUST mostrar solo la localidad relacionada cuando esté disponible y autorizada; MUST NOT mostrar coordenadas ni ubicación actual precisa.
- **FR-010**: La consola MUST mostrar carga, vacío, error y falta de autorización donde
  aplique; MUST informar éxito solo tras confirmación del servidor.
- **FR-011**: La consola MUST NOT ofrecer pagos, transacciones, pantallas de mantenimiento
  de localidades ni registro público/gestión de administradores en v1.
- **FR-012**: Membresías pueden consultarse en la especificación como entidad confirmada,
  pero su operación administrativa MUST permanecer pendiente hasta contrato autorizado.
- **FR-013**: Datos o acciones inexistentes (servicios separados, estado/moderación de
  reseña, suspensiones, auditoría) MUST registrarse como dependencias y no controles activos.
- **FR-014**: Los flujos MUST ser utilizables con teclado y lector de pantalla, foco visible,
  contraste suficiente y texto ampliado en los layouts soportados.

## Estados comunes de interfaz

- **Carga**: indicar que la consulta o acción sigue en curso; evitar duplicar mutaciones.
- **Vacío**: distinguir colección sin registros de consulta fallida o filtro sin resultados.
- **Éxito**: confirmar solo respuesta exitosa del servidor y refrescar datos derivados.
- **Error**: mensaje accionable sin stack trace, credenciales, respuesta cruda ni datos
  personales innecesarios; conservar formulario cuando se pueda reintentar.
- **Sin permiso**: explicar acceso insuficiente sin enumerar recursos no autorizados.
- **No disponible**: usar cuando el campo opcional sea null/no devuelto; no sustituir por
  cero, estado por defecto ni inferencia.

## Requisitos no funcionales

- **Seguridad y privacidad**: mínimo privilegio, control de servidor por operación,
  token/secretos protegidos, evitar exposición de DNI, teléfono y coordenadas; no persistir
  datos de pago en esta versión. Access y refresh tokens existen solo en memoria y nunca se
  guardan en almacenamiento web persistente.
- **Accesibilidad**: teclado, orden de foco coherente, foco visible, nombres accesibles,
  comunicación de estados, contraste suficiente y escalado de texto.
- **Responsive**: móvil web <768 px, tablet 768–1199 px y escritorio ≥1200 px; la
  composición refluye y conserva áreas y permisos.
- **Resiliencia**: fallos de red, autorización y conflictos no producen un éxito falso ni
  pérdida innecesaria de cambios locales.
- **Rendimiento**: usar paginación/carga progresiva solo según contratos existentes o
  futuros; no fijar SLA ni límites arbitrarios en ausencia de decisión.

## Criterios de éxito

- **SC-001**: En revisión funcional, cada dato visible de las pantallas definidas puede
  trazarse a un campo/relación del esquema o queda marcado como brecha/pendiente.
- **SC-002**: Para cada operación propuesta, la especificación identifica actor/permiso,
  validación y estado de respaldo (confirmada, pendiente o no disponible).
- **SC-003**: Una persona administradora puede identificar el módulo y destino activo en
  los tres tipos de viewport sin perder acceso a las áreas autorizadas.
- **SC-004**: Ningún conteo derivado se presenta como editable, ni un vacío/error/denegación
  se representa como cero o éxito.
- **SC-005**: Los flujos pendientes de API, permisos, auditoría o privacidad
  están enumerados como dependencias concretas antes de planificar su implementación.

## Entidades clave

`User`, `ProviderProfile`, `Category`, `ProviderSecondaryCategory`, `ContactIntent`,
`Review`, `ProviderPortfolioImage`, `MembershipTier`, `Locality` y `Report`, con los
campos y relaciones descritos en la matriz de datos. No se asumen entidades `Service`,
`Payment`, `Subscription`, `ReviewModeration` o `AuditEvent`.

## Brechas y dependencias para resolver antes de planificar pantallas bloqueadas

1. Definir y documentar el procedimiento operativo seguro para que un operador autorizado
   provisione cuentas `ADMIN` fuera del registro público; el registro actual solo acepta
   CLIENT/PROVIDER. Confirmar expiración/recuperación de sesión para su uso en consola.
2. Agregar contrato y permisos `ADMIN` para listar/detallar/buscar/paginar usuarios y
   prestadores, definir exposición de localidad relacionada (teléfono solo en ficha,
   DNI y ubicación precisa excluidos de v1), editar perfiles,
   resolver conflictos y definir cambios de cuenta.
3. Confirmar reglas de categoría: altas/ediciones admin, transición entre `status`,
   modificación de `isActive`, eliminación y manejo de categorías asociadas. Solo lista
   y unificación admin están confirmadas.
4. Definir si hace falta entidad `Service` y tarifas vinculadas a servicio; actualmente solo
   hay categorías y precios indicativos de perfil.
5. Definir listado Admin de `ContactIntent`, semántica de contacto recibido, campos
   personales visibles y si el evento de salto a WhatsApp realmente persiste.
6. Definir listado/admin de reseñas y si se requiere moderación, estados, acciones y autoría.
7. Definir lectura Admin de portfolio, reglas de retirada/moderación y tratamiento seguro
   de URLs de imagen.
8. Definir consulta Admin de disponibilidad y localidad relacionada. La consola v1 excluye
   coordenadas y ubicación actual precisa; no hay historial de ubicaciones.
9. Definir operaciones Admin para `MembershipTier`/asignación si se requieren; no hay
    suscripción o pago modelado.
10. Decidir si se requiere `AuditEvent` y su política antes de habilitar cambios sensibles.
11. Definir fuentes y reglas para conteos del Dashboard y ventana de “reseñas recientes”.
12. Actualizar el contrato Admin de Reportes para que GET incluya `author?` solo con `firstName`/`lastName` y GET/PATCH omitan `authorId`, `author.id`, email y phone. El propietario del API debe confirmar el DTO; no requiere cambios de Prisma/datos. Hasta entonces, no integrar las llamadas de listado/resolución desde la consola.

## Supuestos explícitos

- El checkout inspeccionado `/Users/matybazan/Documents/api-tooapp` es la referencia de
  API solicitada; su código y esquema describen el estado revisado, no garantizan que un
  despliegue remoto coincida.
- Solo se considera confirmado un permiso cuando una ruta/middleware o regla vigente lo
  concede; un modelo por sí solo confirma persistencia, no autorización.
- La consola v1 usa el inicio de sesión existente; las cuentas `ADMIN` se provisionan
  fuera del registro público por un operador autorizado. No se añade alta pública de admins.
- “Oficio” se interpreta como categoría primaria/secundaria por ser las relaciones actuales;
  la distinción comercial con servicios/especialidades requiere decisión de producto.
- Los breakpoints acordados son móvil web <768 px, tablet 768–1199 px y escritorio ≥1200 px.

