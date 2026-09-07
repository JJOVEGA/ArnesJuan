# ESTADO — ArnesJuan

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparece un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.

## Fase actual
Fase 0 — autoalojamiento. **Ciclo 3: v1.32.0 lista para publicar.** La ventana del coste: REQ-012 y
REQ-014 con QA y Seguridad aprobados; **REQ-013 cruza a 1.33.0** con SEC-020 abierto (`contrato`).
El guardián de la sesión siguiente será 1.32.0.

## En progreso
**Nada en curso.** Diecisiete comisiones, tres vueltas dev-QA agotadas en los tres REQ, 28 hallazgos de
QA y 9 de seguridad. Banco de 4.096 líneas en un archivo a un corredor de 680 más 37 secciones, de 683
a 742 casos, sin que ninguna línea del inventario anterior cambiara de veredicto.

**Lo que cruza a 1.33.0, con dueño y ventana:**

| Hallazgo | Clase | Qué es |
|---|---|---|
| **SEC-020** | `contrato` | Séptimo fail-open de `arnes-paralelo.sh`: el marcado de Markdown por elemento corrompe el mapa y da `disjunto` con rc 0. **La respuesta es restringir la gramática del campo, no un octavo parche** |
| SEC-017, SEC-021, QA-213, QA-214, QA-215, QA-216, QA-205 | `instrumento` | Deuda con dueño `desarrollador`, ventana 1.33.0 |
| H-03 | `instrumento` | Residual declarado con ADR-002; dueño REQ-011, vencimiento cierre de 1.33.0 |
| H-12 | `instrumento` | La carrera del temporal de nombre fijo en `hooks/estado-derivado.sh`. **REQ-015, parche 1.32.1** |
| SEC-019 | `instrumento` | 54 de 742 casos pasan con su hook a `exit 0`. Ventana 1.35.0 |

**La lección del ciclo, y es la tercera vez que la aprendemos:** cuando un mecanismo interpreta texto
humano libre, ensanchar el patrón no gana la clase. Pasó con el detector de escrituras por Bash, con la
guarda estática del banco (ADR-002) y ahora con el campo `Archivos:`. La salida es **restringir la
gramática** o **preguntar después** en vez de antes, nunca un patrón más largo.

## Próximo paso concreto
1. Publicar: PR, `hooks-en-linux`, fusión squash, tag `v1.32.0`, verificar tag contra `plugin.json`,
   actualizar la instalación estable.
2. Cerrar REQ-012 y REQ-014 (`Estado: completado`) **después** de publicar y verificar, como exige su CA-26.
3. **REQ-015 en el parche 1.32.1**: la carrera de `ESTADO.md`. Es `usuario/dinero` en su REQ propio.
4. **Reiniciar la sesión** antes de abrir 1.33.0, para que 1.32.0 gobierne.
5. Abrir 1.33.0 con las tres reglas nuevas de la coordinadora: tope de ~12 criterios por REQ, un defecto
   de forma no cuesta vuelta, y la re-validación verifica cierre en vez de volver a atacar.

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
## Estado derivado — 2026-09-07 05:45

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `cand/1.32.0` @ `9e04e56` — CON CAMBIOS SIN COMITEAR
**Arnés:** plugin instalado `1.31.0` · el proyecto declara `1.32.0` — **migración pendiente** (`/arnes-upgrade`)
**Aprobaciones pendientes:** 0
**REQ:** 14 — completado 8 · en-revisión 3 · en-progreso 1 · bloqueado 0 · otros 2
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 8 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-007 | en-progreso | pendiente | pendiente | critico | qa-114(contrato,dueñoanalista-requerimie… |
| REQ-008 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-011 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-012 | en-revision | aprobado | aprobado | critico | (ninguno) |
| REQ-013 | en-revision | con-hallazgos | con-hallazgos | critico | sec-014(contrato),sec-020(contrato),qa-2… |
| REQ-014 | en-revision | aprobado | aprobado | critico | h-03(instrumento),h-07(instrumento),h-12… |

<!-- ARNES:DERIVADO fin -->
