# Migración del andamiaje — 1.30.3 → 1.31.0 (`arnes-upgrade`)

- **Fecha:** 2026-09-06 · **Origen:** 1.30.3 · **Destino:** 1.31.0 (plugin instalado 2fecae1, el actual).
- **Acreditación del origen: CONFIRMADO.** Las 11 plantillas de `.arnes/plantillas-origen/` son idénticas
  a `v1.30.3:templates/`. Los dos marcadores que implicarían origen ≥ 1.31.0 están **ausentes**, como
  corresponde: el manifiesto no tiene `git.prohibidos` y `requirements/README.md` no lista
  `con-hallazgos` en el vocabulario de `Seguridad:`.
- **Árbol de git limpio** al empezar, en `main` @ 8263284.

## Plan

| Archivo | Sección | Estado | Acción |
|---|---|---|---|
| `PENDING_APPROVAL.md` | «Cómo se cuenta esta cola» | **ya aplicada** | ninguna — el `desarrollador` la escribió con REQ-009 (CA-04 exigía la regla en el archivo y en la plantilla a la vez) |
| `AGENTS.md` §13 | dos filas nuevas de la tabla de enforcement (veredicto fechado; `guard-git`) | **NUEVO** | SAFE: añadir |
| `AGENTS.md` §13 | «Un hook que avisa sin decidir» | **NUEVO** | SAFE: añadir |
| `AGENTS.md` §13 | celdas del bloque derivado recortadas a 40 | **NUEVO** | SAFE: añadir |
| `AGENTS.md` §13 | rotación de **una sección** de un documento | **NUEVO** | SAFE: añadir al párrafo de rotación existente |
| `AGENTS.md` §13 | «Y ancha no es infalible» | **ya presente** | ninguna — este repositorio la escribió primero y la plantilla la espeja |
| `requirements/README.md` | `con-hallazgos` en el vocabulario de `Seguridad:` | **NUEVO** | SAFE: añadir |
| `requirements/README.md` | aviso al escribir fuera del vocabulario | **NUEVO** | SAFE: añadir |
| `requirements/README.md` | la fecha del veredicto en el paréntesis | **NUEVO** | SAFE: añadir |
| `requirements/README.md` | la historia se archiva, los criterios no | **NUEVO** | SAFE: añadir |
| `requirements/README.md` | veredictos recortados a 40 en el bloque derivado | **NUEVO** | SAFE: añadir |
| `.arnes/config.json` | bloques `veredictos`, `git`, `limites` y `_doc_artefactos` | **NUEVO** | **DELEGADO al `desarrollador`**: el manifiesto entró en `codigo_app.globs` de este repositorio en 1.31.0, así que la coordinadora ya no puede escribirlo. Es la consecuencia aceptada de esa decisión, y la Fase 5 va con ella |

**Sin `UNKNOWN` ni `CONFLICTO`.** Ninguna sección gestionada del proyecto difiere de su base: lo que
está personalizado en este repositorio —la política de autoalojamiento— vive en secciones que las
plantillas de 1.31.0 no tocan.

## Decisiones que la skill obliga a preguntar, y sus respuestas

- **`veredictos.exigir_fecha` y `caducan_con_codigo`: se quedan APAGADAS.** Los veredictos de este
  repositorio sí llevan fecha, pero encenderlas ahora mezclaría una decisión de política con una
  migración de andamiaje. Se decide en su propia ventana, con la medición delante.
- **`git.activo: true` con la lista por defecto.** Es la única puerta que nace encendida y este
  repositorio la quiere: aquí trabajan varios agentes en paralelo sobre el mismo árbol, que es
  exactamente el escenario que la motiva.
- **`limites.bash_max_analisis`: no se declara.** El valor por defecto vive en el código y ningún
  comando legítimo ha topado con el techo.
- **`rotacion` sigue apagada.** La rotación de la historia de un REQ **no reconoce filas de tabla**
  —medido: 0 entradas y 94 filas en los REQ de este repositorio—, así que encenderla hoy no rotaría
  nada. Está en `docs/PENDIENTES.md` para 1.32.0 con su alcance.

## Aplicado

- [x] `AGENTS.md` — cinco añadidos
- [x] `requirements/README.md` — cinco añadidos
- [x] `.arnes/config.json` — aplicado por el `desarrollador`: bloques `veredictos` (ambos `false`) y `git` (`activo: true`, lista por defecto), `_doc_artefactos` de `rotacion` al texto de 1.31.0; `limites` NO se declara y `rotacion.activo` sigue en `false`
- [x] Fase 5: `arnes_version` → 1.31.0 (al final, tras releer y verificar el manifiesto)
