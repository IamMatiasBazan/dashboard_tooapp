<!--
Informe de impacto de sincronización
- Cambio de versión: inexistente → 1.0.0 (primera constitución del proyecto).
- Principios incorporados: cobertura administrativa; fidelidad a API y capacidades;
  autorización y seguridad; navegación administrativa; capas y organización; adaptación,
  accesibilidad e identidad; operaciones responsables y resiliencia; verificación y entrega.
- Secciones añadidas: Restricciones técnicas; Flujo de desarrollo; Gobierno.
- Secciones retiradas: ninguna.
- Plantillas Spec Kit: ⚠ pendientes de revisión de sincronización en una etapa posterior;
  este cambio se limita a la constitución.
- Integración y configuración Spec Kit: ✅ inspeccionadas; repositorio ya inicializado
  con integración Codex y Spec Kit 0.13.2.
- Pendientes: confirmar fecha original de ratificación; acordar dependencias y decisiones
  técnicas de red, estado, rutas, sesión y estructura final.
-->
# Constitución de TÖÖ Admin Dashboard

## Principios fundamentales

### I. Cobertura administrativa basada en inventario
Cada especificación DEBE inventariar las áreas, entidades y datos observables de la app
de referencia y definir, para cada entidad y rol autorizado, las acciones permitidas:
consultar, crear, editar, activar, desactivar, aprobar, rechazar o eliminar, según
corresponda. DEBE distinguir permisos administrativos de las capacidades de CLIENT,
PROVIDER y otros roles de la app. Ninguna acción se presume por la existencia de una
pantalla móvil. Las áreas sin capacidad administrativa implementada DEBEN seguir
registradas como pendientes o limitaciones, sin simular controles u operaciones.

### II. El API vigente gobierna las capacidades
El código y los contratos vigentes del API son la autoridad para rutas, campos,
operaciones, estados y autorización disponibles. La consola NO DEBE inventar ni dar por
disponibles operaciones sin respaldo verificable. Una necesidad no cubierta DEBE quedar
documentada como dependencia, decisión pendiente o limitación antes de implementar la
tarea afectada. La revisión de capacidades DEBE distinguir operaciones confirmadas de
las incompletas o ausentes y volver a contrastarlas al implementar.

### III. Mínimo privilegio y protección de datos
Cada operación protegida DEBE requerir autenticación y validación de rol o permiso en el
servidor. La interfaz PUEDE ocultar controles para orientar el uso, pero ocultarlos NO
constituye autorización. La consola DEBE aplicar mínimo privilegio y proteger tokens,
secretos, datos personales y respuestas de error; no DEBE exponerlos en registros,
mensajes, URLs o artefactos cliente.

### IV. Navegación administrativa coherente
En layouts amplios, la consola DEBE ofrecer un drawer vertical persistente con acceso
claro a las áreas administrativas respaldadas. En pantallas compactas, DEBE adaptar la
navegación a un drawer lateral accesible u otro patrón equivalente que conserve las
mismas áreas y permisos. La navegación DEBE corresponder a módulos reales y NO DEBE
presentar como funcional una capacidad pendiente.

### V. Responsabilidades separadas y tipadas
El código DEBE organizarse por funcionalidad y separar presentación, estado, acceso a
datos/servicios y modelos tipados. Las dependencias y convenciones DEBEN corresponder a
`pubspec.yaml` y al código vigente. La estructura propuesta bajo `lib/src/app`, `core` y
`features` es una guía para el diseño futuro, no una estructura ya adoptada: cada plan
DEBE contrastarla con la organización existente y dependencias aprobadas, adaptar lo
necesario y documentar la razón técnica. Las decisiones aún no verificadas DEBEN quedar
pendientes; no se fijarán paquetes ni versiones por inferencia.

## Adaptabilidad, accesibilidad e identidad

Desktop y móvil son targets del producto. Las composiciones DEBEN responder al ancho
disponible y permitir operación por teclado, foco visible, lector de pantalla, contraste
suficiente y texto ampliado. La consola DEBE conservar la identidad TÖÖ observada en las
fuentes existentes y centralizar sus tokens visuales. Los elementos comprobados en las
fuentes y las propuestas nuevas DEBEN identificarse por separado; detalles no verificados
DEBEN registrarse como decisiones pendientes, no presentarse como diseño aprobado.

## Datos, rendimiento y resiliencia

Las vistas y operaciones DEBEN representar estados de carga, vacío, éxito y error; validar
los cambios; confirmar acciones de impacto significativo o irreversibles; y comunicar
solo resultados confirmados por el servidor. La consola NO DEBE presentar cifras,
estados ni éxito que el API no haya confirmado. Las consultas DEBEN limitarse y organizarse
según las capacidades reales del API. Los fallos de red y de autorización DEBEN manejarse
sin filtrar datos ni convertir una operación fallida en exitosa. Los requisitos de
rendimiento DEBEN derivarse de necesidades verificables y NO DEBEN imponer SLA arbitrarios.

## Verificación y entrega

La estrategia de pruebas DEBE ser proporcional al riesgo y cubrir permisos, contratos,
flujos de edición y acciones de impacto significativo que estén dentro del alcance.
Antes de entregar, los cambios DEBEN pasar el análisis y formato configurados en el
repositorio y una revisión de seguridad apropiada al cambio. Las pruebas y controles
adicionales DEBEN responder a requisitos o riesgos identificados; no se impondrán
porcentajes de cobertura inventados.

## Restricciones técnicas

- El repositorio es un proyecto independiente Flutter para una consola administrativa
  web. La app móvil y el API son fuentes de referencia; no se modifican desde este
  proyecto salvo que una solicitud futura amplíe explícitamente el alcance.
- `pubspec.yaml` declara Dart SDK `^3.13.5`, Flutter SDK, `flutter_test` y
  `flutter_lints: ^6.0.0`. No declara todavía dependencias de red, estado, navegación,
  sesión ni generación de modelos. Su selección y versión están pendientes de aprobación
  técnica; no deben inferirse de los repositorios de referencia.
- La estructura `lib/src/app/{router,layout}`, `lib/src/core/{config,network,session,theme,widgets,utils}`
  y `lib/src/features/<feature>/{data,models,presentation}` se evaluará en la planificación
  frente al código y las dependencias existentes. No constituye un mandato de crear
  módulos para acciones sin respaldo del API.
- Los contratos actuales del API observado muestran operaciones `ADMIN` para consultar
  categorías y unificarlas, y consultar y resolver reportes. No se confirmó en ese código
  una API administrativa para gestionar usuarios, proveedores, servicios, reseñas,
  membresías o pagos. Esta observación no excluye esas áreas del inventario futuro; sus
  capacidades administrativas quedan pendientes de contrato y autorización verificables.

## Flujo de desarrollo

- Cada especificación DEBE incluir el inventario de áreas/datos y una matriz de permisos
  y acciones por entidad, distinguiendo confirmado, incompleto/no disponible y pendiente.
- Antes de planificar o implementar una operación, se DEBE comprobar su contrato vigente,
  validación del servidor y rol requerido. Los vacíos bloquean únicamente la tarea que
  depende de ellos y se registran con la decisión o dependencia necesaria.
- Cada plan DEBE justificar la estructura y dependencias elegidas con evidencia del
  repositorio. Cada entrega DEBE revisar estados de interfaz, autorización, manejo de
  errores, accesibilidad y controles de calidad aplicables.

## Gobierno

Esta constitución gobierna las especificaciones y el desarrollo de TÖÖ Admin Dashboard.
Las enmiendas DEBEN revisar consistencia con las plantillas Spec Kit y guías de ejecución
afectadas; la sincronización de esos documentos se hará en el mismo cambio cuando estén
dentro de su alcance. Las revisiones de cumplimiento DEBEN registrar excepciones,
evidencia y resolución.

El versionado es semántico: MAJOR para eliminaciones o redefiniciones incompatibles,
MINOR para principios nuevos o ampliaciones sustanciales, y PATCH para aclaraciones sin
cambio de obligaciones. La fecha original de ratificación no está documentada y queda
pendiente de confirmación por el responsable del proyecto. Toda modificación DEBE
actualizar la versión, la fecha de enmienda y el informe de sincronización.

**Versión**: 1.0.0 | **Ratificada**: TODO(RATIFICATION_DATE): confirmar fecha original de adopción | **Última modificación**: 2026-11-03
