# REQ-019 vía A · evaluación del reparto documental de `AGENTS.md` desde `main` (2026-09-22) — propuesta SIN aplicar

**Base identificada:** `AGENTS.md` de `main` = `cfb1106` (1.34.0 + REQ-025 entrega 1): **63 211 B**; contexto obligatorio de arranque = `CLAUDE.md` (408 B, importa `@AGENTS.md`) + `AGENTS.md` = **63 619 B**, cargados enteros al arrancar **cada** comisión (mecanismo establecido con la documentación oficial en `docs/arnes/req-019-piloto-comparacion.md` §1). `requirements/README.md` (42 458 B) **no** se carga al arrancar; queda fuera de esta evaluación por eso y porque su mayor bloque movible (`## Índice`, ≈7,9 kB) está fuera de alcance de REQ-019.
**Separación del piloto:** esta evaluación no incorpora el §0 del piloto (rama local, no seleccionado). Trabaja sobre `main` tal cual.
**Método:** clasificación bloque a bloque con el filtro de REQ-019 §«El criterio: qué se queda y qué se va» (¿manda? ¿acota? ¿hace falta antes de actuar? ¿es su sede única?) y su predicción registrada; bytes con `len(utf-8)` sobre `git show cfb1106:AGENTS.md`; punteros y enunciados **escritos reales**, no estimados (`contabilidad.md`). Evidencia F1 (`requirements/REQ-019.md` §«El suelo forzado MEDIDO EN BYTES», `docs/arnes/req-019-techo-propuesto.md`) usada para el **método y la clasificación**; sus cifras (base 33 827 B) están **desfasadas**: `AGENTS.md` casi se ha duplicado desde F1 (+29 384 B, casi todo §6 por la vía proporcional y las seis reglas), y lo añadido es **normativo**, no historia.

## 1. Bloques propuestos (conjunto pequeño: sólo justificación, historia o mecánica de consulta)

| Bloque | Qué sale | Qué queda en `AGENTS.md` | Destino (un salto) |
|---|---|---|---|
| B1 §1 | explicación del mecanismo del autoalojamiento (ya en su sede) | título, la regla en una frase y el puntero | `docs/gobernanza/autoalojamiento.md` §«Las dos copias» |
| B2 §5 | «por qué así» del candado QA-Opus | **cómo se aplica** (`model` al despachar, no editar el agente) + puntero | `…/autoalojamiento.md` §«Política de rigor» |
| B4 §6 | «Medido: el ciclo 2 corrió casi entero en serie…» | la obligación entera + puntero con la cifra | `…/autoalojamiento.md` §«Lo que enseñó el ciclo 2» |
| B5 §6 | «Esto es deliberado: un tope por hallazgo no acota nada…» | el tope de 3 vueltas **por REQ** sin reinicio + puntero | `docs/arnes/agents-md-historia-y-mecanica.md` (nuevo) §«Loop de error» |
| B9 §13 | celdas de veredicto recortadas a 40 caracteres | un puntero de una línea | mismo archivo nuevo §«Bloque derivado» |
| B7 §13 | mecánica de la rotación | enunciado («mueve, no resume», apagada, cabecera y criterios intactos) + puntero | §«Rotación» |
| B8 §13 | mecánica e historia de la continuidad (1.32.0, «1 de 25») | enunciado **y la acotación entera** (fuera de marcadores no se toca; sin serialización; temporal huérfano) + puntero | §«Continuidad» |
| B10 §13 | detalle del prefijo estricto del agente | nombre corto basta, prefijo opcional y estricto + puntero | §«Manifiesto» |

El **diff sin aplicar** está en `propuesta-AGENTS.patch` (104 líneas); el texto que aterrizaría verbatim en cada destino, en `destino-agents-md-historia-y-mecanica.md` y `destino-autoalojamiento-adiciones.md`.

**Excluidos a propósito, y por qué:** el «caso medido» de la regla 4 (REQ-025 CA-09 lo exige **en la sede**); la casuística de SEC-020 y la de cobertura de `Bash`/heredoc de §13 (son **acotaciones** de promesas de cobertura hoy **cuestionadas** por SEC-103/QA-019-04: mover su casuística mientras la promesa se discute es tocar lo que QA y seguridad tienen que volver a leer, y CA-14 exige que el enunciado se quede pegado); los «tres límites de la comprobación de autorización» (acotaciones: se quedan); el paréntesis «(criterios genéricos que suelen aplicar…)» (230 B de plantilla sin efecto aquí: **borrarlo no es un movimiento**, CA-01 lo prohíbe; exige decisión contractual aparte); todo §6 normativo nuevo (vía proporcional, seis reglas, gates: obligaciones, condiciones y contadores mezclados en párrafos que **no** se pueden trasladar enteros).

## 2. Reducción neta, medida

| | bytes |
|---|---:|
| Sale de `AGENTS.md` (8 bloques, verbatim a destino) | 4 291 |
| Queda o entra (enunciados conservados + 8 punteros conformes a CA-03) | 2 678 |
| **Reducción neta de `AGENTS.md`** | **1 615 B = 2,6 %** (63 211 → 61 596) |
| Reducción del contexto de arranque (`CLAUDE.md` + `AGENTS.md`) | 1 615 B = **2,5 %** (63 619 → 62 004) |
| Bytes que aterrizan en destinos (no se cargan al arrancar) | 4 949 |

**Los punteros y enunciados se comen el 62 % de lo que sale.** Es la misma estructura que F1 ya midió (49–57 %): lo delegable de `AGENTS.md` está repartido en muchas secciones y cada una paga su puntero. **Bytes, no tokens ni coste:** la conversión no está medida en este proyecto; con el orden de magnitud del piloto (≈39 k tokens de primer turno con 63 kB de `AGENTS.md`) la reducción sería de **cientos** de tokens por comisión, y **no se promete**.

## 3. Obligaciones y dependencias comprobadas
- **CA-01 (no-pérdida):** 44 líneas retiradas, **0** sin aterrizaje literal en un destino (búsqueda literal, normalización `> `).
- **CA-04 (esqueleto):** la lista de `## ` es idéntica antes y después. `templates/AGENTS.md.tpl` **no se toca** → divergencia temporal que CA-05 obliga a registrar en el anexo de ADR-003.
- **CA-02 / anclas:** ninguna frase movida la cita literalmente el mecanismo (`hooks/`, `tools/`); «Principio rector», la tabla de §13, los 7 bloques `🔒` y los marcadores de `arnes-upgrade` (`preventiva`, «Cumplido por máquina», fila del rigor) quedan intactos. Los ficheros de `hooks/lib.sh` que hablan del «nombre corto» son la sede ejecutable, no una cita.
- **CA-14 (acotaciones):** B7 y B8 conservan enunciado y acotación en `AGENTS.md`; sólo sale mecánica e historia.
- **CA-12 (un salto):** cada bloque de gobierno (B7, B8, B10) tiene puntero propio con la pregunta; los narrativos, uno por sección.
- **REQ-025:** la sede de las seis reglas no se toca; el «caso medido» de la regla 4 se queda (CA-09 (B) pregunta 3).
- **Cuándo se consultaría lo trasladado:** la mecánica de rotación y continuidad, al configurar `rotacion.*`/`estado_derivado.*` o al diagnosticar un `docs/ESTADO.md` anómalo; el prefijo del agente, al configurar el manifiesto con dos plugins; la historia, nunca en el curso ordinario. **Ninguno se leería en cada comisión**: el ahorro sería efectivo, pero es el de arriba.

## 4. Ajuste contractual que exigiría implementarlo (sin cambiar nada por cuenta propia)
- **CA-07 (ii) y su techo 0,72×:** esta propuesta deja `AGENTS.md` en **0,974×**. El techo firmado (2026-09-09) es insatisfacible con cualquier reparto conforme a CA-02/CA-14 (F1 midió 0,82× sobre una base ya superada; hoy la base es normativa en su mayor parte). CA-07 y CA-14 fijan la única salida: **firma del propietario sobre un techo nuevo por documento y entrada de Historial**, o sustituir la razón por una **reducción neta medida en bytes** como magnitud de CA-07 (ii) — cambio de fondo, ADR. Su historia se conserva (`docs/arnes/req-019-techo-propuesto.md`, §«El suelo forzado…»).
- **CA-15 (inventario cerrado antes del reparto, doble enumeración independiente):** escrito para el documento entero; para 8 bloques habría que **acotarlo al conjunto movido** o ejecutarlo íntegro (7–11 h estimadas en el REQ).
- **CA-05:** registro de divergencia `AGENTS.md` ↔ plantilla en ADR-003, con su forzador y su vencimiento por evento.
- **CA-13:** tabla de decisión con la pregunta de cada bloque redactada por quien no reparte.
- Ciclo: REQ-019 es `critico` y `Sensible a seguridad: sí` → analista (ajuste), desarrollador (movimiento), QA (CA-01/04/12 por búsqueda literal), auditor (CA-14, anclas). **≈4 comisiones** para 1 615 B.

## 5. Recomendación: **DETENER**
Hay un recorte **seguro** (ocho bloques, no-pérdida y esqueleto verificados, sin tocar promesas cuestionadas) pero **no útil**: 2,6 % del documento y 2,5 % del arranque, sin ahorro medible de tokens ni de coste, a cambio de un ciclo crítico completo, tres ajustes contractuales (CA-07, CA-15, CA-05) y una divergencia con la plantilla que hay que mantener. El peso de `AGENTS.md` hoy no es historia: es **contrato añadido en 1.33–1.34** (vía proporcional, seis reglas, gates con alcance), que este REQ no puede mover. El diff queda a disposición del propietario; la implementación depende de su decisión sobre este diff, y esta evaluación **no abre otro encargo** para REQ-019.

## Lo que no se hizo
No se aplicó el parche, no se creó ningún destino en el repositorio, no se tocaron plantillas, agentes, hooks, herramientas, pruebas ni consumidores; no se movió el techo 0,72×; no se recuperó `referencia/enforcement.md`; no se reabrieron REQ-025 ni las sondas; sin comisiones, ensayos, push, fusión ni publicación.
