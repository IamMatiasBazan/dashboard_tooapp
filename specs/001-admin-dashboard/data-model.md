# Inventario lógico de datos — 001-admin-dashboard

Este documento describe el esquema observado en
`/Users/matybazan/Documents/api-tooapp/prisma/schema.prisma` en modo de referencia. No
propone ni autoriza cambios de base de datos. DTOs Admin y permisos deben validarse por
separado; la existencia de un modelo no concede acceso administrativo.

## Entidades y relaciones confirmadas

| Entidad | Datos del modelo relevantes | Relaciones relevantes |
|---|---|---|
| `User` | `id`, `role`, `phone`, nullable `email`, `firstName`, `lastName`, `avatarUrl`, `dni`, `isDniVerified`, `ratingAvg`, `reviewsCount`, `isAccountActive`, `createdAt`, `updatedAt`, `localityId` | opcional `ProviderProfile`; opcional `Locality`; `RefreshToken[]`; contactos hechos; reseñas dadas/recibidas; reportes hechos |
| `ProviderProfile` | `id`, `userId`, `primaryCategoryId`, nullable `membershipTierId`, `isAvailable`, `shiftEndsAt`, `lastPulseAt`, `availabilityLocationSource`, `coverageRadiusKm`, `minPrice`, `chargesConsultation`, `consultationPrice`, `issuesInvoice`, `invoiceType`, `profileViewsCount`, `contactsCount`, `bio`, `experienceYears`, `isMatriculado`, `matriculaNumber`, `createdAt`, `updatedAt` | `User` uno-a-uno; `Category` primaria; `MembershipTier?`; categorías secundarias; imágenes de portafolio; contactos |
| `Category` | `id`, `name`, `iconUrl`, `status` (`APPROVED`, `PENDING`, `REJECTED`), `isActive`, `createdAt` | prestadores primarios/secundarios; contactos |
| `ProviderSecondaryCategory` | `providerId`, `categoryId`, `createdAt` | llave compuesta con `ProviderProfile` y `Category` |
| `ContactIntent` | `id`, `clientId`, `providerId`, `categoryId`, `problemDescription`, `status` (`PENDING`, `SCHEDULED`, `COMPLETED`, `CANCELLED`), `scheduledFor`, `createdAt`, `updatedAt` | `User` cliente; `ProviderProfile`; `Category`; reseñas |
| `Review` | `id`, `contactIntentId`, `authorId`, `targetId`, `direction`, nullable `rating`, nullable `comment`, `cancellationReason`, `metadata`, `createdAt` | `ContactIntent`, autor `User`, usuario evaluado `User` |
| `ProviderPortfolioImage` | `id`, `providerProfileId`, `imageUrl`, `createdAt` | `ProviderProfile`; no hay título, descripción ni estado de moderación |
| `Locality` | `id`, `name`, `slug`, `isEnabled`, `createdAt`, `updatedAt` | `User[]`; solo lectura para este alcance |
| `MembershipTier` | `id`, `name`, `description`, `price`, `createdAt` | prestadores relacionados opcionalmente; no modela compra, período ni transacción |
| `Report` | `id`, `authorId`, `type` (`SUGGESTION`, `CLAIM`, `USER_REPORT`), `content`, `isResolved`, `createdAt`, `updatedAt` | autor `User`; existe índice por autor y estado |
| `RefreshToken` | `id`, `userId`, `tokenHash`, `deviceId`, `deviceName`, `expiresAt`, `createdAt` | `User`; token persistido como hash, no exponer desde dashboard |

`ProviderProfile.baseLocation` y `currentLocation` son `Unsupported(geometry(Point,4326))`.
La consola no muestra coordenadas ni ubicación actual precisa. No hay entidad independiente
`Service`, modalidad de cobro por servicio, moderación de reseñas/portafolios, `AuditEvent`,
historial de suspensión ni suscripción.

## Agregados derivados de la especificación

| Dato solicitado | Fuente/cálculo permitido | Límite actual |
|---|---|---|
| Total usuarios | conteo de `User` según definición acordada para total | no hay endpoint Admin agregado/listado disponible |
| Total prestadores | conteo de `ProviderProfile` o `User.role=PROVIDER`, tras elegir definición consistente | endpoint Admin ausente; reconciliar posibles perfiles faltantes antes de etiquetar cifra |
| Prestadores disponibles ahora | `isAvailable == true` y `shiftEndsAt > ahora`; un fin nulo no demuestra disponibilidad vigente | endpoint/consulta Admin ausente; no calcular desde endpoint de autoservicio |
| Oficios publicados | el esquema solo relaciona categorías primarias/secundarias; no define “publicado” como entidad/estado separado | no presentar como servicios publicados ni emitir conteo de servicios |
| Contactos recibidos | `ContactIntent` vinculados a proveedor, con definición de si total histórico o ventana | no hay evento separado de WhatsApp ni endpoint Admin |
| Promedio/total de reseñas | agregación de `Review` según dirección/usuario objetivo y solo ratings no nulos conforme a regla aprobada | `User.ratingAvg`/`reviewsCount` existen como columnas cacheadas; no editables manualmente ni asumir sincronía |
| Reseñas recientes/pendientes | `Review.createdAt`; no existe estado de moderación | recientes requiere ventana/regla pendiente; pendientes de moderación no existen |

## Reglas de presentación y privacidad

- Excluir siempre `User.dni`, `User.isDniVerified`, hashes de contraseña/tokens y geometrías.
- El teléfono no va en listados; solo podría exponerse en detalle a `ADMIN` si un DTO Admin
  aprobado lo autoriza. Correo y ubicación también dependen de finalidad/DTO/permiso.
- En Reportes, el contrato cliente aprobado limita `author` opcional a nombre y apellido.
  La entidad persiste `authorId`, pero las respuestas consumidas por dashboard deben omitir
  `authorId`, `author.id`, email y phone (G11).
- Ausencia/null en un campo opcional se presenta como no disponible, no como cero ni como
  estado inferido.
- Ningún cambio del esquema Prisma se incluye en el plan.
