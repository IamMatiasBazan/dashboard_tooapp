# Investigación de planificación — 001-admin-dashboard

**Fecha**: 2026-11-04  
**Fuentes**: constitución del dashboard, `spec.md`, `pubspec.yaml`, estructura Flutter
actual y checkout de referencia `/Users/matybazan/Documents/api-tooapp` (solo lectura).

## Dependencias Flutter

- **Decisión**: usar Flutter 3.47.7 stable / Dart 3.13.5; `go_router ^18.1.2`,
  `dio ^5.11.1` y `provider ^6.1.5+1`. `ChangeNotifier` se obtiene de Flutter.
- **Razón**: la decisión fue confirmada en Clarifications de la especificación y
  corresponde al SDK inspeccionado. `pubspec.yaml` actualmente declara Dart `^3.13.5`,
  Flutter, `flutter_test` y `flutter_lints ^6.0.0`; T008 agregó los paquetes aprobados y
  generó el lockfile.
- **Alternativas consideradas**: conservar el shell sin router/estado/cliente HTTP no
  soporta la navegación ni las capas requeridas. No agregar paquetes diferentes sin una
  decisión nueva. La ejecución futura de `pub get`/T008 comprobará la resolución real y el
  lockfile antes de empezar las features.

## Responsive y drawer

- **Decisión**: móvil web `<768 px`, tablet `768–1199 px`, escritorio `≥1200 px`.
  Drawer persistente vertical en escritorio; colapsable/expandible en tablet; lateral
  accesible e invocado por control explícito en móvil web.
- **Razón**: rangos confirmados en Clarifications; el repo no tenía breakpoints previos.
- **Alternativas consideradas**: heredar valores de Material o configuración de otro repo
  no tiene evidencia local y podría variar de la decisión aprobada. Los tokens de marca y
  refinamientos visuales se inspeccionan/separan de estas decisiones estructurales.

## Sesión web de administración

- **Decisión**: mantener access y refresh token en memoria. En un 401, coordinar una sola
  renovación con `POST /auth/refresh` (refresh token en body), sustituir ambos tokens y
  reintentar la petición original una vez. Si falla, borrar sesión y volver a login.
  Logout envía Bearer access y refresh token actual a `POST /auth/logout`, siempre borra la
  sesión local y no afirma revocación remota ante error. Una recarga requiere nuevo login.
- **Razón**: decisión aprobada por el usuario; los endpoints actuales operan con Bearer y
  cuerpo, no se observó flujo de cookie HTTP-only.
- **Alternativas consideradas**: persistir tokens en `localStorage`, `sessionStorage` o
  IndexedDB se descarta expresamente. No inventar cookie/session backend. La solicitud de
  logout best-effort no puede invalidar por sí misma un access token ya emitido.

## Contratos y alcance API

- **Decisión**: considerar disponible una operación únicamente si ruta, schema, middleware,
  respuesta y rol vigentes la respaldan. Para Reportes se requiere además el contrato
  reducido aprobado: el cliente solo consume campos de reporte y `author?` con
  `firstName`/`lastName`; excluye `authorId`, `author.id`, email y phone.
- **Razón**: T086 actualizó los selects y contratos; T087 verificó GET/PATCH y guard ADMIN
  con repositorios simulados, sin conexión a DB. G11 está satisfecho; no se alteró el
  esquema ni los datos.
- **Alternativas consideradas**: consumir y ocultar luego los campos personales filtrados
  viola minimización; el dashboard no debe hacer la petición hasta aprobar/verificar las
  respuestas reducidas.

## Persistencia y datos derivados

- **Decisión**: usar únicamente el esquema Prisma existente. No se planifican migraciones,
  tablas, campos, relaciones ni cambios de datos. Contadores de Dashboard, promedio y total
  de reseñas y cantidad publicada son agregados calculados en consultas respaldadas, nunca
  campos editables del cliente.
- **Razón**: el esquema no contiene `Service`, estado de moderación, entidad de auditoría,
  registro de suspensión ni ciclo de suscripción. `MembershipTier` sí existe y relaciona
  opcionalmente con `ProviderProfile`, pero la lectura Admin no está implementada.
- **Alternativas consideradas**: reutilizar categorías como servicios, estado de cuenta
  como suspensión o relaciones móviles como permisos administrativos inventaría semántica;
  se descarta. Esas pantallas/acciones permanecen bloqueadas por los gates aplicables.

## Decisiones/gates que permanecen abiertos

- G11: resuelto por el contrato reducido e implementación T086 y las pruebas simuladas
  T087. Reportes usa nombre/apellido opcionales; el resto de gates sigue vigente.
- G4 (Dashboard) y G9 (Services) permanecen bloqueados por datos/entidad sin definir.
  G7/G8 tienen decisiones de producto aprobadas el 2026-11-04; sus rutas Admin y tests son
  trabajo técnico pendiente, no una pregunta funcional. G10 se cierra como solo lectura v1.
- Lecturas Admin de usuarios, prestadores, reseñas, portafolios, contactos y membresías ya
  existen en el API de referencia; integraciones Flutter y las escrituras aprobadas deben
  mantener la distinción entre acceso Admin y autoservicio.
- La fuente de identidad visual requiere contrastarse con el material móvil de referencia;
  esto no habilita copiar componentes o código.
- `FR-002` y `SC-005` están alineados ahora con los breakpoints aprobados en Clarifications;
  las tareas responsive ya no dependen de un gate de decisión G2.

## Decisiones de escritura Admin — 2026-11-04

- **Decisión**: v1 permitirá editar perfiles existentes y activar/desactivar cuentas, además
  de crear/editar/activar/desactivar categorías. Reseñas, portafolios y membresías se
  mantienen de solo lectura. No se habilitan `PUT` ni `DELETE` Admin.
- **Alcance de perfil User**: reusar `ownUserPatchSchema` vigente (`phone`, `email`,
  `firstName`, `lastName`, `avatarUrl`) y sus validaciones; acción separada para el campo
  existente `isAccountActive`.
- **Alcance de perfil ProviderProfile**: reusar `providerFields` de
  `providerProfilePatchBody`/`settingsPatchBody`: `primaryCategoryId`, `bio`,
  `experienceYears`, `isMatriculado`, `matriculaNumber`, `coverageRadiusKm`, `minPrice`,
  `chargesConsultation`, `consultationPrice`, `issuesInvoice`, `invoiceType`. Excluir
  `baseLocation`, coordenadas, DNI, verificaciones y agregados.
- **Alcance Category**: alta/edición solo `name` e `iconUrl` con el schema actual; estado
  mediante `isActive`; conservar la unificación actual; no eliminar ni alterar `status`.
- **Diseño técnico**: extender módulos existentes `src/modules/admin-read/*` y
  `src/modules/categories/*`, validando cada operación con `authenticate` y
  `requireRole('ADMIN')`. No reutilizar rutas de autoservicio como permiso Admin.
- **Restricción**: no modificar schema Prisma, migraciones, tablas/columnas/relaciones,
  índices, seeds o datos mediante scripts. En runtime, los handlers aprobados actualizan
  solo campos ya existentes usando Prisma.
- **Validación**: contract tests para allowlists/validadores, ADMIN contra roles no Admin,
  no autorizado/UUID inválido/not found/unique conflicts; integración Flutter solo después
  de verificar las respuestas. Auditoría, motivo e historial no se fingen al no existir.
- **Fuera de decisión**: Dashboard/G4 y Services/G9 siguen bloqueados; privacidad de
  `ContactIntent.problemDescription` sigue cerrada como campo excluido. Moderación y
  mantenimiento de MembershipTier no forman parte de escrituras v1.
