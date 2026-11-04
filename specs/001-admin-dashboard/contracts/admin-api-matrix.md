# Matriz de contratos Admin — 001-admin-dashboard

Fuente de referencia: implementación actual de `/Users/matybazan/Documents/api-tooapp`.
Las operaciones llamadas **propuestas** abajo no existen aún. Esta matriz no autoriza
cambios de schema Prisma, migraciones, seeds ni escritura manual de datos.

## Operaciones confirmadas

| Operación | Contrato observado | Uso planificado |
|---|---|---|
| `POST /auth/login`, `/auth/refresh`, `/auth/logout` | Sesión actual con Bearer y refresh en body; cuentas ADMIN preaprovisionadas | Shell, renovación única y logout best-effort |
| `GET /admin/categories` | `authenticate` + `requireRole('ADMIN')`; filtros `status`/`active`; sin paginación | Listado y filtros |
| `POST /admin/categories/unify` | `authenticate` + `requireRole('ADMIN')`; UUID de origen/destino distintos | Unificación confirmada y con confirmación de impacto |
| `GET /admin/reports` | filtros `isResolved` y `type`; ADMIN; respuesta reducida T086/T087, `author?` con solo nombre/apellido | Listar sin detalle/paginación/ordenamiento inventado |
| `PATCH /admin/reports/:id/resolve` | UUID; ADMIN; sin body; respuesta reducida | Resolución confirmada por servidor; G11 satisfecho |
| Lecturas `/admin/users`, `/admin/providers`, `/admin/reviews`, `/admin/portfolio`, `/admin/contact-intents`, `/admin/membership-tiers` | Rutas GET protegidas por ADMIN y DTOs minimizados en módulo admin-read | Consultas autorizadas; sin mutaciones implícitas |

## Escrituras Admin aprobadas, aún no implementadas

Las decisiones de 2026-11-04 aprueban estas operaciones con registros/campos existentes.
Cada ruta nueva debe validar `authenticate` + `requireRole('ADMIN')`, body/params, usar
servicios y Prisma existentes y devolver resultado tipado. Actualizaciones en runtime
modifican únicamente campos existentes; no crear columnas, relaciones, tablas, índices,
migraciones o seeds.

| Método y ruta propuesta | Campos / regla | Estado |
|---|---|---|
| `PATCH /admin/users/:userId` | Reusar `ownUserPatchSchema`: `phone`, `email`, `firstName`, `lastName`, `avatarUrl` y validaciones vigentes | Aprobado; ruta ausente |
| `PATCH /admin/users/:userId/account-status` | `isAccountActive` boolean separado de edición de perfil | Aprobado; ruta ausente |
| `PATCH /admin/providers/:providerProfileId` | Reusar `providerFields`: `primaryCategoryId`, `bio`, `experienceYears`, `isMatriculado`, `matriculaNumber`, `coverageRadiusKm`, `minPrice`, `chargesConsultation`, `consultationPrice`, `issuesInvoice`, `invoiceType` | Aprobado; ruta ausente |
| `POST /admin/categories` | `name`, `iconUrl`; reusar reglas actuales: trim, nombre 2–100, URL nullable/opcional | Aprobado; ruta ausente |
| `PATCH /admin/categories/:categoryId` | `name`, `iconUrl` con validaciones existentes | Aprobado; ruta ausente |
| `PATCH /admin/categories/:categoryId/active` | `isActive` boolean | Aprobado; ruta ausente |

No se aprueba `PUT`: cambios parciales usan `PATCH`. No se aprueba `DELETE` Admin.
Los perfiles excluyen DNI, rol, verificaciones, coordenadas/ubicación precisa, claves,
hashes, tokens, fechas y valores derivados. El cambio `isAccountActive` es acción separada.
Categorías no pueden borrar ni cambiar `status` mediante el alcance aprobado.

## Solo lectura o bloqueado en v1

| Módulo | Decisión y evidencia |
|---|---|
| Usuarios y prestadores | Escrituras anteriores aprobadas pero requieren implementación de ruta Admin y luego integración Flutter. No usar endpoints de autoservicio como autorización. |
| Reseñas y portafolios | Solo lectura Admin; sin moderación o borrado. No hay estado de moderación. |
| Contactos | Solo lectura de eventos; omitir `problemDescription` y conversaciones. |
| Membresías | Listado/detalle solo lectura; sin CRUD; sin pagos, compras o suscripciones. |
| Servicios | Bloqueado G9: no existe `Service` ni su relación/estado/fecha. No reinterpretar categorías/tarifas como servicios. |
| Dashboard agregado | Bloqueado G4 hasta fijar fuentes/reglas de conteo. |
| Auditoría | No existe `AuditEvent` ni ruta. No simular historial ni añadir tabla/schema. |

Los contratos nuevos deben especificar método, path, rol, schemas, errores, DTO minimizado,
respuesta y pruebas de autorización. La implementación no debe alterar el schema Prisma ni
ejecutar cambios manuales de datos; las solicitudes Admin sí actualizarán registros existentes
en runtime para realizar las funciones aprobadas.
