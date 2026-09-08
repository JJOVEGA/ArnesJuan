# ESTADO — ArnesJuan

> Tablero de continuidad. Responde: ¿dónde quedamos y cuál es el próximo paso concreto?
> Lo de aquí lo escribes tú. Al final aparece un **bloque derivado** entre marcadores
> `<!-- ARNES:DERIVADO ... -->` que **reescribe el arnés** en cada parada de agente: no lo
> edites, se sobrescribe. Lo de fuera de esos marcadores no se toca nunca.

## Fase actual
Fase 0 — autoalojamiento. **v1.32.1 publicada.** Ventana **1.33.0 abierta**, gobernada por 1.32.1.

**Partida el 2026-09-07 por decisión del propietario: 1.33.0 son SÓLO las cuatro palancas de coste**
—REQ-017 (en curso), la puerta de «¿esta prueba mide algo?», `tests/util/` y adelgazar `AGENTS.md`—,
≈3 h de reloj de agente, que caben en un ciclo semanal. **El núcleo por estado** (REQ-011, SEC-025,
SEC-029, REQ-007 B/C, la pasada de conformidad y el canal de informes) **pasa a 1.34.0**, ≈6 h.

El motivo no es sólo el calendario: **las palancas abaratan el núcleo, y medirlas antes de empezarlo es
la única forma de saber cuánto abaratan.** Juntas, el ahorro y el gasto se mezclan y no se pueden
atribuir — el mismo error que la línea base envenenada por la sonda desbocada. Los nueve trabajos
juntos salían a ~8–10 h, y una ventana que no cabe en el ciclo se corta a mitad de una comisión.

**El paralelismo entra en 1.34.0, no antes, y por una razón medida:** hoy casi nada se puede despachar
en paralelo porque `skills/arnes-upgrade/SKILL.md` colisionaba en **15 de 15** pares. La palanca de la
nota de migración retira esa colisión; después, `tools/arnes-paralelo.sh` puede declarar `disjunto` de
verdad. Sigue siendo condición **necesaria y no suficiente** mientras SEC-020 esté abierto, y el orden
de fases no se paraleliza nunca.

## En progreso
**REQ-017 — `en-progreso`, con delta de implementación pendiente.** Se detuvo por **presupuesto de
tokens**, no por un bloqueo técnico: el semanal iba al 81 % con 2 h para el reset, y las tres comisiones
que faltan suman ~410 k. Parar antes es más barato que quedarse sin cupo a mitad de una comisión.

**Lo conseguido y medido:**

| | Antes | Después |
|---|---|---|
| Cociente de duplicación de `arnes_sin_cita` | 3,95 — **cuadrático** | **1,90 — lineal** |
| Sección `32-huecos-auditoria-r001` | 76,19 s | **9,60 s** |
| Banco (las 42 secciones de antes) | 95,66 s | **45,14 s** |
| Pared de los 60 s del hook | 0,94 MB | **sube — magnitud RETIRADA, ver abajo** |

La última fila es un **beneficio no buscado**: subir la pared de agotamiento es `SEC-030`, con dueño
propio, y sale gratis al quitar la cuadraticidad.

> **Corrección (2026-09-07, QA-017-05). La cifra «1,60 MB» se retira: la sonda no repite.** Seis
> corridas del mismo árbol dan **1,08 · 1,32 · 1,78 · 2,64 · 2,65 · 3,98 MB**. Las dos series que
> creíamos discordantes —2,01 y 1,46— **no discrepan: son dos extracciones de la misma distribución**, y
> la serie de QA las contiene a las dos. Causa medida: los tres tiempos base son **una sola muestra cada
> uno** —contra la regla del mínimo de k que la propia sección enuncia—, dos de ellos entran como
> diferencia de muestras únicas, y el exponente resultante va **en el exponente** de la extrapolación;
> además el arranque que se resta osciló 0,10–0,21 s según hubiera vecinos. **La dirección del beneficio
> se sostiene 6 de 6; la magnitud, no.** Dueño: `SEC-030`. Lo que hay que retener no es el número: es
> que **lo publicamos como medido en el CHANGELOG y en este tablero**, y lo cazó el endurecimiento que
> el analista había metido esa misma tarde —obligar a que cada cifra nombre su corrida—, que **se pagó
> a sí mismo en su primera validación**.

**El arreglo es una sentencia**, con equivalencia por construcción:
`case "${l%$CR}" in *$CR*)` → `case "$l" in *$CR?*)`. La guarda **no se movió**: sigue siendo la
primera sentencia del único escáner, como REQ-016 contrató. Se abarató *cuándo* se paga, no *dónde*
vive.

**Lo que falta, en este orden exacto:**
1. **Delta del desarrollador** (~80 k): invertir el defecto de `ARNES_COSTE_RUTA_CRITICA` y añadir el
   `timeout`, derivado de `mín(este árbol)` medido **en la misma corrida y después del numerador** —
   una constante en segundos reintroduciría el reloj absoluto que todo el REQ combate—, y con el
   **vencimiento como resultado positivo, nunca como SKIP**.
   Y ahora también **H-08**: `fetch-depth: 0` en el checkout del CI, porque sin tags **once de los
   criterios de REQ-017 salieron SKIP y el PR #43 dio verde sin medir ninguno** (detalle y las tres
   consecuencias en `docs/PENDIENTES.md`). Va en el mismo delta, no antes: encarece la puerta
   requerida y esa decisión ya estaba escalada con CA-05.
2. **QA (Opus)** sobre los 9 criterios (~180 k). Vuelta 0 de 3.
3. **Auditor** (~150 k). `critico` y `Sensible a seguridad: sí`: sin su firma no cierra.

**La lección de esta media ventana, que vale más que el arreglo:** `CA-05` exigía comparar contra un
**tag congelado en cada corrida**, y eso parecía rigor. Es una puerta que **mide una vez y luego
envejece hacia el lado que abre** — el banco crece a propósito, así que la igualdad de inventario
contra v1.32.1 será falsa en la primera sección de 1.34.0, y entonces alguien la re-fija corriendo el
propio banco que dice validar. **Una comprobación contra línea base congelada es acreditación de
fail-before, no puerta permanente.** Lo permanente tiene que ser **auto-anclado**: `CA-03`, el orden de
crecimiento, que no depende de ningún tag, cuesta milisegundos y habría visto H-07.

**Y un error de aritmética que cometimos tres.** La corrida heredada de 76 s servía a la igualdad de
inventario **y** a la razón de reloj; contarla como ahorro en las dos mitades daba «~45 s» cuando el
número real era **~107 s**, por encima de los 92 s que el REQ venía a arreglar. Lo vio el analista al
rehacer la resta. Nadie la había comprobado.

## Próximo paso concreto
1. **Retomar tras el reset del semanal** por el delta del desarrollador, luego QA, luego auditor.
2. **REQ-018 — el canal de informes, NO lanzado a propósito.** Es el único trabajo del backlog
   genuinamente **disjunto** de 1.33.0 (vive en `.github/` y `templates/`, no en `hooks/`), y sería el
   primer `disjunto` real de la herramienta de paralelismo. Se aplaza por **presupuesto**, no por
   colisión. Y va **partido en dos**: las plantillas y las etiquetas son disjuntas; la línea dentro de
   los mensajes de los hooks **no lo es** y espera a que 1.33.0 suelte `hooks/lib.sh`.
3. Después de REQ-017, **y con eso cierra 1.33.0**: las otras tres palancas —la puerta de «¿esta prueba
   mide algo?», `tests/util/` y el adelgazamiento de `AGENTS.md`—. El núcleo ya **no** va aquí.

## Bloqueos
- Ninguno técnico. La parada es de **presupuesto de tokens** y es una decisión del propietario.

## Pendientes (cola)
- [ ] Decisión editorial del propietario: nombres de proyectos consumidores en el árbol público, y las
      dos cuentas de GitHub nombradas en `AGENTS.md` (hallazgo informativo SEC-008; la salida propuesta
      es sustituir nombres por roles).
- [ ] **1.35.0 — working set explícito**: análisis y reglas de diseño en `docs/PENDIENTES.md`. La
      pregunta de si adelantar el adelgazamiento de `AGENTS.md` **queda resuelta** (2026-09-07): se
      adelanta a 1.33.0 como cuarta palanca, porque es el mayor coste fijo de contexto —~9 k tokens en
      cada subagente— y 1.34.0 es la ventana con más comisiones. El resto del working set sigue en 1.35.0.
- [ ] Windows/MSYS: el coste allí no está medido, y es donde un `fork` cuesta entre 1,2 y 6 s.

<!-- ARNES:DERIVADO inicio — lo escribe el hook; NO editar a mano -->
## Estado derivado — 2026-09-07 19:15

> Lo **deriva** el arnés leyendo el disco en cada parada de agente; no lo redacta nadie.
> Se reescribe entero cada vez, así que editarlo a mano no sirve: lo tuyo va **fuera**
> de los marcadores y ahí no se toca. Si algo aquí te sorprende, el disco dice eso.
>
> Los veredictos se muestran **como los lee la máquina** —normalizados: sin mayúsculas, sin
> tildes, sin marcado— y no como están escritos en el REQ. Es a propósito: si un valor se ve
> raro aquí, es que la puerta lo está leyendo raro, y eso es justo lo que conviene ver.

**Repositorio:** `cand/1.33.0` @ `e85a300` — CON CAMBIOS SIN COMITEAR
**Arnés:** plugin instalado `1.32.1`
**Aprobaciones pendientes:** 0
**REQ:** 21 — completado 12 · en-revisión 1 · en-progreso 2 · bloqueado 0 · otros 6
**Otros archivos en `requirements/` sin `Estado:` (notas, no REQ):** 0

_Sólo los REQ abiertos; los 12 completados no se listan._

| REQ | Estado | QA | Seguridad | Rigor | Hallazgos abiertos |
|---|---|---|---|---|---|
| REQ-007 | en-progreso | pendiente | pendiente | critico | qa-114(contrato,dueñoanalista-requerimie… |
| REQ-008 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-011 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-013 | en-revision | con-hallazgos | con-hallazgos | critico | sec-014(contrato),sec-020(contrato),qa-2… |
| REQ-017 | en-progreso | con-hallazgos | pendiente | critico | qa-017-01(contrato),qa-017-02(instrument… |
| REQ-019 | pendiente | pendiente | preventiva | critico | sec-031(contrato),sec-032(contrato),sec-… |
| REQ-020 | pendiente | pendiente | pendiente | critico | (ninguno) |
| REQ-021 | pendiente | pendiente | preventiva | critico | sec-035(contrato),sec-036(contrato),sec-… |
| REQ-022 | borrador | pendiente | pendiente | critico | (ninguno) |

<!-- ARNES:DERIVADO fin -->
