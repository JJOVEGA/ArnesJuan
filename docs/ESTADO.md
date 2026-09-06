# ESTADO — ArnesJuan

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparecerá un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.
> Se actualiza al cerrar cada sesión de trabajo.

## Fase actual
Fase 0 — autoalojamiento: el arnés (v1.30.2 instalado, en WSL) gobierna el desarrollo de su siguiente versión.
Ciclo 1 = 1.30.3 (REQ-001). El banco corre siempre en WSL (~10 s); nunca en Windows.

## En progreso
- REQ-001 — los dos bypass de 1.30.2 (rama `cand/1.30.3-autoalojamiento`, PR #31). Tres vueltas dev↔QA
  gastadas (tope alcanzado); `QA: aprobado` en la tercera. Auditoría de seguridad en curso.
- Redactados y a la espera de su versión: REQ-002..006 (1.31.0), REQ-007 (huecos preexistentes del lector
  y del detector; 1.31.0), REQ-008 (informe de proyecto como evolución de `arnes-panel`; 1.33.0).

## Próximo paso concreto
1. Auditor firma `Seguridad:` en REQ-001 y deja `docs/seguridad/` escrito.
2. Coordinadora: commit + push de la rama, CI `hooks-en-linux` en verde, fusión squash, tag `v1.30.3`
   sobre el merge, verificación tag ↔ plugin.json, fila del ciclo 1 en `docs/gobernanza/autoalojamiento.md`.
3. Reiniciar la sesión (1.30.3 pasa a gobernar) y correr `/arnes-upgrade` sobre este repo.
4. Ciclo 2 = 1.31.0: `cand/1.31.0-…` desde `main`; REQ-002..007 con referencia en la rama `feat/1.31.0`.

## Bloqueos
- Ninguno. La fusión, el tag y la publicación están delegados por el propietario cuando todo está en verde
  (`docs/gobernanza/autoalojamiento.md`); cualquier rojo o veto vuelve al humano.

## Pendientes (cola)
- [ ] Decisión editorial del propietario: nombres de proyectos consumidores en el árbol público (CHANGELOG
      antiguo, `lib.sh:252`, README del banco, `.gitattributes`).
- [ ] **1.35.0 — working set explícito** (estrategia de contexto): decidido por el propietario el
      2026-09-05; el análisis completo y las reglas de diseño están en `docs/PENDIENTES.md`, sección
      «1.35.0 — el working set explícito». Su MVP es REQ-004, que va en 1.31.0.
- [ ] **Decisión abierta del propietario:** ¿adelantar sólo el adelgazamiento de `AGENTS.md` a 1.32.0
      o 1.33.0? No depende de ninguna medición y es el mayor coste fijo de contexto (26 KB en cada
      agente, en cada arranque). Preguntarlo al abrir 1.32.0.
- [ ] Mejoras observadas en el autoalojamiento → `docs/PENDIENTES.md` (ya listadas; convertir en REQ al abrir
      1.31.0 / 1.32.0).

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-06 14:46

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `cand/1.31.0-mecanismos` @ `79ff767` — CON CAMBIOS SIN COMITEAR
**Arnés:** plugin instalado `1.30.3`
**Aprobaciones pendientes:** 0
**REQ:** 11 — completado 1 · en-revisión 7 · en-progreso 1 · bloqueado 0 · otros 2
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 1 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-002 | en-revisión | aprobado | aprobado | critico | qa-106(instrumento) |
| REQ-003 | en-revisión | aprobado | aprobado | critico | (ninguno) |
| REQ-004 | en-revisión | aprobado | aprobado | critico | qa-109(instrumento,conductaimplementadaymedidael2026-09-06;faltasucriterioenelreq—dueñoanalista-requerimientos) |
| REQ-005 | en-revisión | aprobado | con-hallazgos | critico | qa-113(instrumento,dueñoanalista-requerimientos;elcontroldeca-21generalizademássobreeldescuentodecomillas),sec-009(contrato,dueñodesarrollador+analista-requerimientos;construccionesordinariasdelshell—`then`,`{`,`&`,`nohup`,continuacióndelinea—atraviesanguard-gityca-06afirmalocontrario),sec-010(contrato,dueñodesarrollador+analista-requerimientos;conelmanifiestoilegibleguard-gitpermitemientraselavisoafirmaquesedeniega) |
| REQ-006 | en-revisión | aprobado | aprobado | critico | (ninguno) |
| REQ-007 | en-progreso | pendiente | pendiente | critico | qa-114(contrato,dueñoanalista-requerimientos;ca-59exigea`gitstatus`unconteoquereq-005ca-26/ca-27declaraimposible,ysumargenderelojnodiscrimina) |
| REQ-008 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-009 | en-revisión | aprobado | aprobado | critico | (ninguno) |
| REQ-010 | en-revisión | aprobado | aprobado | critico | qa-108(instrumento) |
| REQ-011 | pendiente | pendiente | pendiente | critico | (ninguno) |

<!-- ARNES:DERIVADO fin -->
