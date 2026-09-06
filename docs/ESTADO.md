# ESTADO — ArnesJuan

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparece un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.

## Fase actual
Fase 0 — autoalojamiento. **Ciclo 2 cerrado: v1.31.0 publicada** (tag sobre `main` 2fecae1, PR #33) e
instalación estable ya en 1.31.0. El guardián de la sesión **siguiente** será 1.31.0.

## En progreso
- Nada en curso. Los siete REQ de la ventana 1.31.0 quedaron `completado` con QA y Seguridad aprobados.
- **REQ-007** sigue `en-progreso` a propósito: sus bloques B y C cruzan a 1.32.0.
- Redactados y esperando su versión: REQ-008 (informe de proyecto, 1.33.0) y REQ-011 (puerta posterior, 1.32.0).

## Próximo paso concreto
1. **Reiniciar la sesión** para que 1.31.0 pase a gobernar (los hooks se cargan al arrancar).
2. Correr `/arnes-upgrade` sobre este repositorio: 1.31.0 **sí** cambió plantillas, así que hay andamiaje
   que poner al día. Su Fase 5 (`arnes_version`) la ejecuta el `desarrollador`, porque el manifiesto entró
   en su propia frontera.
3. Abrir el ciclo 3 (1.32.0) con el analista: REQ-007 bloques B y C, REQ-011, y el bloque de 1.32.0 de
   `docs/PENDIENTES.md`, que ya tiene la deuda del ciclo 2 con dueño y criterio.

## Bloqueos
- Ninguno. La fusión, el tag y la publicación están delegados cuando todo está en verde; un veto del
  auditor o un hallazgo bloqueante devuelven la decisión al propietario, y así ocurrió en este ciclo.

## Pendientes (cola)
- [ ] Decisión editorial del propietario: nombres de proyectos consumidores en el árbol público, y las
      dos cuentas de GitHub nombradas en `AGENTS.md` (hallazgo informativo SEC-008; la salida propuesta
      es sustituir nombres por roles).
- [ ] **1.35.0 — working set explícito**: análisis y reglas de diseño en `docs/PENDIENTES.md`. Sigue
      abierta la pregunta de si adelantar sólo el adelgazamiento de `AGENTS.md`, que es el mayor coste
      fijo de contexto y no depende de ninguna medición.
- [ ] Windows/MSYS: el coste allí no está medido, y es donde un `fork` cuesta entre 1,2 y 6 s.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-06 15:49

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `cand/1.31.0-mecanismos` @ `62d27c2` — CON CAMBIOS SIN COMITEAR
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
| REQ-005 | en-revisión | aprobado | aprobado | critico | qa-113(instrumento,dueñodesarrollador,ventana1.32.0;untokenentrecomilladooescapadonoseve—lim-10,declaradoenca-21.5yen«fueradealcance»,condictamenconcurrentedelauditorensec-012;nobloqueaelcierre),sec-013(instrumento,dueñodesarrollador,ventana1.32.0;lanotade`skills/arnes-upgrade`quelosproyectosheredanenumera`nohup`peronoloscuatroenvoltoriosnuevos—`xargs`,`setsid`,`ionice`,`doas`—,asiqueunproyectocon`xargsgitclean`enunguionrecibiraunadenegacionquelanotanoleanuncio;direccionseguraydenegacionruidosaconmotivo,poresonobloquea;verr-003) |
| REQ-006 | en-revisión | aprobado | aprobado | critico | (ninguno) |
| REQ-007 | en-progreso | pendiente | pendiente | critico | qa-114(contrato,dueñoanalista-requerimientos;ca-59exigea`gitstatus`unconteoquereq-005ca-26/ca-27declaraimposible,ysumargenderelojnodiscrimina),qa-116(contrato,dueñodesarrollador,ventana1.32.0;heredadodev1.30.3yreproducidoporelauditorenr-003enlasdosversiones:con`docs/estado.md`enmodo444ylacarpetaescribibleelbloqueseescribeigualyelmodopasaa644ensilencio,sinperdercontenidohumano.laverdadyaestaescritaenca-64.2yelarreglo—conservarelmodo—exigidoenca-64.2-bis;nocierrahastaqueelcodigoloimplemente),qa-117(contrato,dueñodesarrollador,ventana1.32.0;heredadodev1.30.3yreproducidoporelauditorenr-003enlasdosversiones:eltextohumanoposterioralosmarcadoressubeporencimadelbloqueencadaparada—sinperderunbyte,4de4lineas,eidempotente—.laverdadyaestaescritaenca-64.1yelarreglodelordenexigidoenca-64.1-bis;nocierrahastaqueelcodigoloimplemente) |
| REQ-008 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-009 | en-revisión | aprobado | aprobado | critico | (ninguno) |
| REQ-010 | en-revisión | aprobado | aprobado | critico | qa-108(instrumento) |
| REQ-011 | pendiente | pendiente | pendiente | critico | (ninguno) |

<!-- ARNES:DERIVADO fin -->
