# Requerimientos — {{NOMBRE_PROYECTO}}

Esta carpeta es el **contrato compartido**: la única fuente de verdad sobre qué hay que hacer y qué falta. Todos los agentes leen y actualizan estos archivos.

## Tipos
- **REQ-xxx** — Requerimiento funcional (una capacidad del sistema).
- **NFR-xxx** — Requerimiento no funcional (seguridad, rendimiento, límites).

## Estados
| Estado | Significado |
|--------|-------------|
| `borrador` | Redactado, pendiente de confirmación del usuario |
| `pendiente` | Confirmado, aún no iniciado |
| `en-progreso` | El desarrollador lo está codificando |
| `en-revisión` | Terminado, en validación de QA / seguridad |
| `completado` | Pasó todas las quality gates + QA + seguridad |
| `bloqueado` | Detenido por una dependencia o veto (indicar motivo) |

Un REQ solo pasa a `completado` cuando: criterios de aceptación cumplidos + quality gates en verde + visto bueno de seguridad.

## Veredictos de validación (campos del REQ)
Cierran el lazo de hallazgos para que no haya deriva silenciosa:
- `QA:` — veredicto del `qa-tester`: `pendiente` | `aprobado` | `con-hallazgos`.
- `Seguridad:` — veredicto del `auditor-seguridad`: `n/a` | `pendiente` | `aprobado` | `vetado`
  (al marcar el REQ `Sensible a seguridad: sí`, pásalo de `n/a` a `pendiente`).

El hook `guard-completado` **impide** marcar `completado` sin `QA: aprobado`, y un REQ
`Sensible a seguridad: sí` sin `Seguridad: aprobado`. Llegar a "aprobado" exige que los
hallazgos estén resueltos **y reflejados en el REQ/NFR** (write-back, ver `AGENTS.md` §9).

## Clases de hallazgo
Todo hallazgo abierto se declara en el campo `Hallazgos abiertos:` de la cabecera, con
su **clase entre paréntesis**: `SEC-121 (instrumento), SEC-144 (usuario/dinero)`.

| Clase | Qué es | Efecto en el cierre |
|---|---|---|
| `usuario/dinero` | Afecta lo que alguien ve, decide o cobra | **Bloquea.** Reabre el REQ |
| `contrato` | El requerimiento dice algo falso sobre lo construido | **Bloquea** hasta el write-back |
| `instrumento` | El control o la prueba tienen un defecto, sin efecto en el producto | **No bloquea.** Deuda técnica con dueño |

**Un hallazgo sin clase declarada no cuenta como hallazgo** — y la puerta deniega el
cierre hasta que se clasifique, porque no puede saber si bloquea.

Por qué existe la clase `instrumento`: un defecto del propio arnés —un lector de
umbral, un guardián— **no puede impedir cerrar una función de negocio**. Atacar
guardianes es valioso y tiene su propio ciclo; los hallazgos que produzca entran como
deuda con dueño, no reabren REQ de negocio.

## Cambios de requerimientos
Un REQ **no se reescribe encima**: se versiona. Todo cambio se anota en el **Historial de
cambios** del REQ (fecha · antes→después · causa · ADR si aplica). Los cambios de fondo
generan un **ADR**. Si un REQ `completado` cambia, vuelve a `en-progreso`/`en-revisión` y
**re-recorre el ciclo**. Política completa en `AGENTS.md`, sección "Cambios de requerimientos".

## Metodología
**1. Historia de usuario:** Como **[rol]**, quiero **[acción]**, para **[beneficio]**.
**2. Criterios de aceptación en Gherkin:** **Dado** [contexto] **Cuando** [acción] **Entonces** [resultado].
**3. Requisitos no funcionales** se documentan como NFR separados y se referencian desde los REQ.

## Plantilla
```markdown
# REQ-XXX — Título
Estado: borrador
Módulo: (...)
Prioridad: (alta / media / baja)
Sensible a seguridad: (sí / no)
QA: pendiente
Seguridad: n/a
Hallazgos abiertos: (ninguno)
NFR relacionados: (NFR-xxx, ...)

## Historia
Como [rol], quiero [acción], para [beneficio].

## Criterios de aceptación
- Dado ... Cuando ... Entonces ...

## Notas / alcance
(detalles, fuera de alcance, dependencias)

## Preguntas abiertas / conflictos
(preguntas sin resolver; conflictos con otros REQs identificando ambos y la contradicción. Mientras haya algo aquí, el REQ se queda en `borrador`.)

## Trazabilidad
Origen: (...)
Tocado por: (agente / fecha)

## Historial de cambios
| Fecha | Antes → Después | Causa | ADR |
|------------|-----------------|-------------------------|--------|
| AAAA-MM-DD | (creación) | — | — |
```

## Índice
(lista de REQ y NFR con su estado)
