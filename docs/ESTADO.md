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
## Estado derivado — 2026-09-06 18:40

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `docs/coste-ciclo-2` @ `23bc018` — CON CAMBIOS SIN COMITEAR
**Arnés:** plugin instalado `1.31.0`
**Aprobaciones pendientes:** 0
**REQ:** 14 — completado 8 · en-revisión 0 · en-progreso 1 · bloqueado 0 · otros 5
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 8 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-007 | en-progreso | pendiente | pendiente | critico | qa-114(contrato,dueñoanalista-requerimie… |
| REQ-008 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-011 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-012 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-013 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-014 | pendiente | pendiente | pendiente | critico | (ninguno) |

<!-- ARNES:DERIVADO fin -->
