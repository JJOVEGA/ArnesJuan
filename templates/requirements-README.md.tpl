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
- `Seguridad:` — veredicto del `auditor-seguridad`: `n/a` | `pendiente` | `aprobado` |
  `aprobado (preventiva)` | `vetado` (al marcar el REQ `Sensible a seguridad: sí`, pásalo de
  `n/a` a `pendiente`).

**El orden importa:** `Seguridad: aprobado` no se escribe mientras `QA:` siga en `pendiente` o
`con-hallazgos` — el auditor no mira las quality gates, así que su firma sobre un árbol sin
validar acreditaría algo que no revisó. El hook lo impide **en cualquier edición del REQ**, no
sólo al cerrarlo, porque el daño se hace al escribir el veredicto. La única salida es la
auditoría **preventiva** —hecha antes de que exista el código—, que se declara al emitirla
como `Seguridad: aprobado (preventiva)` y **no** cubre el código posterior.

El hook `guard-completado` **impide** marcar `completado` sin `QA: aprobado`, y un REQ
`Sensible a seguridad: sí` sin `Seguridad: aprobado`. Llegar a "aprobado" exige que los
hallazgos estén resueltos **y reflejados en el REQ/NFR** (write-back, ver `AGENTS.md` §9).

## Nivel de rigor
Cuánta demostración se exige **por encima** de las quality gates, que son binarias y corren
siempre. Lo fija el analista en la cabecera del REQ.

| Nivel | Qué corre | Cuándo |
|---|---|---|
| `ligero` | analista + desarrollador + quality gates | Sin lógica: textos, etiquetas, ajustes de presentación |
| `estandar` | + QA | Lógica de negocio ordinaria |
| `critico` | + auditoría de seguridad | Dinero · datos personales · identidad o acceso · documento con efecto legal · cambio irreversible (esquema, migración, borrado) |

**Qué REQ de ESTE proyecto cae en cada nivel se decide en `AGENTS.md`, no aquí.** Los
criterios de arriba son independientes del dominio a propósito: el arnés trae el mecanismo,
cada proyecto pone el mapeo con sus ejemplos concretos.

**Reglas de gobierno:**
- **Lo fija el analista.** El auditor **puede subirlo**; nadie lo baja sin su firma.
- **Se puede subir, nunca bajar.** Un REQ marcado `Sensible a seguridad: sí` tiene `critico`
  como **suelo**: escribir `Rigor: ligero` ahí no lo baja. Bajarlo de verdad exige cambiar la
  sensibilidad, que es un campo visible del analista.
- **Si se omite, se deriva:** sensible → `critico`, si no → `estandar`. Es exactamente el
  comportamiento anterior a que existieran los niveles, así que un proyecto que no declare
  nada no nota ningún cambio.
- Un valor no reconocido se ignora y se cae a la derivación. Nunca abre la puerta.

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
Rigor: (ligero / estandar / critico — ver abajo; si se omite, se deriva)
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
