> **Aviso (2026-09-14, propietario):** `comprobar-autorizacion.sh` es **evidencia histórica, no válida para
> acreditar autorización** (hallazgo `I-1` de QA). Se conserva sin reparar y **no es mecanismo del producto**.
> El estado de `I-1` lo determina QA.

# Prueba de despacho de la vía proporcional — instrucciones, método y resultados

**Versión base:** rama `rel/via-proporcional`, árbol de trabajo en el commit **`b2323f1`** más el
cambio que acompaña a este documento (la comprobación de autorización). Todas las cifras y rutas de
aquí se re-derivan corriendo lo que dice el § «Método».

**Qué se prueba.** El diseño que el propietario aprobó el 2026-09-13: *un agente del plugin no
ejerce la vía proporcional por tenerla escrita; la ejerce si el proyecto la autoriza; sin
declaración —o con contradicción— se conserva el procedimiento anterior; y las obligaciones de
seguridad no dependen de esa comprobación.*

**Orden de la entrega, porque importa:** esta prueba se corrió **antes** de ampliar ninguna
documentación sobre la vía. Lo único que existía al correrla era el cambio mínimo de las sedes
(§6 y §14 de `AGENTS.md` y de `templates/AGENTS.md.tpl`, y los cuatro agentes).

---

## La frontera de honestidad — qué se EJECUTÓ y qué se LEYÓ

Esto no es negociable y va antes que los resultados, porque sin ello el informe afirma de más.

**EJECUTADO** (comandos reales sobre archivos reales; se pueden volver a correr):

1. La construcción de los dos proyectos temporales con archivos reales.
2. `comprobar-autorizacion.sh` sobre cada proyecto — la **mitad mecánica** de la comprobación de §6:
   leer el `AGENTS.md` del proyecto y resolver AUTORIZADA / NO-AUTORIZADA, fail-closed.
3. Los `grep` que recogen la evidencia que cada caso necesita: los criterios de `critico`
   declarados en §6, la presencia o ausencia de la tabla de vías, el `Rigor:` y el
   `Sensible a seguridad:` de cada REQ, y si existe un REQ que contrate la exportación.

**LEÍDO / APLICADO A MANO** (no ejecutado):

4. La clasificación de cada caso en una fila de la tabla y la ruta que resulta. Eso es el
   procedimiento de §6 aplicado por mí sobre los archivos reales de cada proyecto, citando la línea
   que lo decide. Es una **lectura**, no una corrida.

**LO QUE NO OCURRIÓ, y no se disfraza:** **no se despachó ningún agente dentro de estos proyectos
temporales.** No tengo esa capacidad, así que aquí **no hay ningún «despacho ejecutado»**. Los seis
resultados de abajo son **rutas resueltas** —dos por comprobación ejecutada, seis por lectura del
procedimiento—, y llamarlos de otro modo sería falsear la evidencia. Lo que un agente real haga al
leer estas instrucciones **sigue sin acreditar**.

---

## Método — cómo se reconstruye todo esto

Con `R` = raíz del worktree `rel/via-proporcional` y `SP` = cualquier directorio temporal:

```bash
# Proyecto A — POLÍTICA ANTIGUA. Su AGENTS.md es la plantilla REAL anterior a la vía.
git show f387b1c:templates/AGENTS.md.tpl > "$SP/proy-antiguo/AGENTS.md"

# Proyecto B — AUTORIZACIÓN PROPORCIONAL. Su AGENTS.md es la plantilla de este cambio.
cp "$R/templates/AGENTS.md.tpl" "$SP/proy-proporcional/AGENTS.md"

# Los MISMOS agentes del plugin en los dos. Es la variable controlada: mismos agentes,
# distinto documento.
cp "$R"/agents/*.md "$SP/proy-<X>/.claude/agents/"

# El marcador {{CRITERIO_RIGOR_CRITICO}} se rellena IGUAL en los dos (dominio de facturación):
#   Crítico: cálculo de importes y cobro (dinero); datos personales del cliente; inicio de
#   sesión y permisos; factura electrónica; migración irreversible.
# Y los mismos dos REQ reales en los dos:
#   REQ-001 «Cálculo de importes y cobro»  → Rigor: critico   · Sensible a seguridad: sí
#   REQ-002 «Informe mensual de ventas»    → Rigor: estandar  · Sensible a seguridad: no
#   (no hay ningún REQ que contrate la exportación de clientes — comprobado con grep)

bash "$R/docs/arnes/via-proporcional-prueba-despacho/comprobar-autorizacion.sh" "$SP/proy-antiguo"
bash "$R/docs/arnes/via-proporcional-prueba-despacho/comprobar-autorizacion.sh" "$SP/proy-proporcional"
```

**Por qué `f387b1c`:** es el commit base del intento de la vía proporcional.
`git show f387b1c:templates/AGENTS.md.tpl | grep -c "Sin comisión de analista"` da **0**: ese
documento es un proyecto de política antigua de verdad, no una maqueta escrita para la prueba.

**Los dos proyectos difieren en UNA cosa y sólo una:** su `AGENTS.md`. Agentes, REQ, criterios de
`critico` y manifiesto son idénticos byte a byte.

---

## Resultado ejecutado — la comprobación de autorización

| Proyecto | Archivo leído | Resuelve | Evidencia | rc |
|---|---|---|---|---|
| A · política antigua | `<SP>/proy-antiguo/AGENTS.md` | **NO-AUTORIZADA** | forma (a) ausente · forma (b) ausente | 1 |
| B · autorización proporcional | `<SP>/proy-proporcional/AGENTS.md` | **AUTORIZADA** | forma (a) en la línea 95 · forma (b) en la línea 102 | 0 |

Confirmación adicional ejecutada: `grep -c "^| Naturaleza del cambio | Vía |"` da **0** en A y **1**
en B; `grep -c "reparación"` da **0** en todo el `AGENTS.md` de A.

---

## Los seis casos

Los tres mismos cambios, uno por fila, corridos contra los dos proyectos. La columna «archivo
contra el que se resolvió» es la que pedía el encargo.

### Proyecto A — política antigua (la comprobación resolvió NO-AUTORIZADA)

| # | Caso | Archivo contra el que se resolvió | Ruta resuelta | Línea que la decide |
|---|---|---|---|---|
| A-1 | **Ordinaria** — el informe mensual imprime `DD-MM-AAAA` y `REQ-002 CA-01` contrata `AAAA-MM-DD` | `proy-antiguo/AGENTS.md` | **analista → desarrollador → QA** | `:87` «**Flujo:** analista define REQ → …», único régimen del documento; no hay tabla de vías |
| A-2 | **Exige seguridad** — el cálculo suma el IVA dos veces; `REQ-001 CA-01` contrata una sola vez | `proy-antiguo/AGENTS.md` + `requirements/REQ-001.md` | **analista → desarrollador → QA → seguridad** | `:87` para el analista; `REQ-001:11 Rigor: critico` y `:7 Sensible a seguridad: sí` para seguridad |
| A-3 | **Necesita REQ nuevo** — la exportación de clientes entrega datos personales sin tope y **ningún REQ la contrata** | `proy-antiguo/requirements/` (grep sin resultados) + `proy-antiguo/AGENTS.md:255-256` | **analista** (abre el REQ, fija `Rigor:` y `Sensible a seguridad:`) → desarrollador → QA → seguridad | `:255-256` «El `analista-requerimientos` hace el write-back»; datos personales está en `:162` |

**Analista en los tres. Es lo que se esperaba.**

### Proyecto B — autorización proporcional (la comprobación resolvió AUTORIZADA)

| # | Caso | Archivo contra el que se resolvió | Ruta resuelta | Línea que la decide |
|---|---|---|---|---|
| B-1 | **Ordinaria** (la misma que A-1) | `proy-proporcional/AGENTS.md` + `requirements/REQ-002.md` | **desarrollador → QA. Sin analista** | `:102` fila 2; no casa la fila 3: el formato de una fecha de informe no alcanza ninguno de los cinco críticos de `:272`, y `REQ-002` es `estandar` / `no` |
| B-2 | **Exige seguridad** (la misma que A-2) | `proy-proporcional/AGENTS.md` + `requirements/REQ-001.md` | **desarrollador → QA → seguridad. Sin analista** | casa fila 2 **y** fila 3 (`:103`, «dinero» está en `:272`); `:106` «manda la MÁS RESTRICTIVA» → fila 3. `REQ-001` es `critico` / `sí` |
| B-3 | **Necesita REQ nuevo** (la misma que A-3) | `proy-proporcional/AGENTS.md` + `requirements/` (grep sin resultados) | **analista** (contrato inicial + `Rigor:` + `Sensible a seguridad:`) → desarrollador → QA → **seguridad** | §6 punto 2: «es el `analista-requerimientos` … quien define el contrato inicial, el `Rigor:` y el `Sensible a seguridad:`»; «“Hace falta un REQ nuevo” es, por sí solo, motivo de parada del `desarrollador`». Seguridad además por «datos personales» de `:272` |

**Ordinaria sin analista · la de seguridad con seguridad · la del REQ nuevo con analista. Es lo que
se esperaba.**

---

## Dos observaciones que la prueba produjo, y no son lecturas de instrucciones

**(1) El caso que la fila 3 antigua dejaba escapar, ahora no escapa — y se comprobó en el
documento, no en el razonamiento.** B-2 es una reparación con causa y contrato claros: con la
enumeración anterior («hooks, protecciones, firmas, permisos, instalación, migración o
publicación») casaba **sólo** la fila 2 y la ruta escrita terminaba en QA. Con la fila 3 enunciada
por propiedad, «dinero» está en los criterios de `critico` **que el proyecto declara en su propio
§6** (`:272`), así que casa también la fila 3 y manda la más restrictiva.

**(2) El desfase documento↔agentes se ejerció en la dirección peligrosa, y el write-back no quedó
sin dueño.** El proyecto A es exactamente el caso de `SEC-095`/`SEC-096`: documento viejo, agentes
nuevos. Se leyó, dentro de ese proyecto, la definición de agente que el plugin entrega:
`analista-requerimientos.md:57` dice «si el `AGENTS.md` de este proyecto **NO** declara esa vía, ese
write-back **SÍ** es tuyo», y el §9 del propio proyecto A (`:255-256`) dice «el `analista-requerimientos`
hace el write-back». **Las dos sedes coinciden**, que es justamente lo que antes no ocurría.

**Esto NO cierra `SEC-095` ni `SEC-096`, y no se declaran cerrados.** La observación es sobre **una**
composición (documento de `f387b1c` + agentes de esta cabeza) leída a mano; no acredita ninguna
corrida de `arnes-upgrade`, ni ninguna otra pareja de versiones, ni un proyecto con **copia propia**
de los agentes —que es la mitad del riesgo y que esta prueba **no ejerció**—.

---

## Lo que esta prueba NO acredita

1. **No acredita ningún despacho real.** Ningún agente corrió dentro de los proyectos temporales.
2. **No acredita compatibilidad con definiciones de agente anteriores.** Los dos proyectos llevan
   los agentes de **esta** cabeza; no se probó ninguno viejo.
3. **No acredita coste.** No se midió lo que cuesta que un agente lea §6 con esta profundidad.
4. **No acredita nada sobre un proyecto con agentes personalizados**, que por construcción no
   reciben la comprobación.
5. **No cierra ningún hallazgo** de `R-034` ni de ningún otro sitio.
6. **No acredita `arnes-upgrade`.** No se migró ningún proyecto, ni real ni copiado.

---

## Un séptimo dato, de control: la comprobación aplicada a ArnesJuan mismo

```
$ bash docs/arnes/via-proporcional-prueba-despacho/comprobar-autorizacion.sh .
archivo leído : ./AGENTS.md
forma (a) ... : 140  forma (b) ... : 148
resuelve      : AUTORIZADA      rc=0
```

**Y aquí la prueba encontró un defecto real, no una confirmación.** En la primera redacción de
`AGENTS.md` la frase de autorización quedó **partida por un salto de línea** («…ArnesJuan autoriza /
la vía proporcional de reparación»), de modo que la **forma (a) no casaba** y la autorización de
este repositorio se sostenía **sólo** sobre la forma (b). Se corrigió juntando la frase. Es
exactamente el motivo por el que la comprobación se enuncia por **propiedad** con **dos** formas de
evidencia y no con una sola cadena: una sola cadena la rompe un salto de línea.

---
## Re-corrida sobre la cabeza final de este cambio

La prueba se corrió dos veces: una con el cambio mínimo de las sedes (§6 y §14 + los cuatro
agentes) y otra tras el barrido por propiedad que añadió `AGENTS.md` §9, `templates/AGENTS.md.tpl`
§9, `skills/arnes-close/SKILL.md` y la tabla de `docs/gobernanza/autoalojamiento.md`. **Los seis
resultados son idénticos en las dos corridas** y las líneas citadas arriba se re-verificaron sobre
la cabeza final (95 · 102 · 103 · 106 · 271-272 en B; 87 · 162 · 255-256 en A).

Comprobación añadida en la segunda corrida: **en el proyecto B no queda ninguna frase que dé el
write-back al analista sin condición** —`grep` de «el `analista-requerimientos` hace el write-back»
devuelve 0—, así que la cláusula de contradicción de §6 no se dispara dentro del propio documento.

## Impedimentos que quedan — se presentan juntos y NO se arreglan aquí

1. **`skills/arnes-upgrade/SKILL.md` (`:1226`, `:1231`) sigue describiendo la vía sin la condición
   de autorización.** No se tocó por prohibición expresa del encargo. Un proyecto migrado por esa
   entrada lee ahí una promesa incondicional que ya no es la de §6.
2. **`SEC-093` y `SEC-094` tienen su remediación de texto escrita, pero no están verificados por
   nadie:** el `qa-tester` no ha validado esta entrega y el `auditor-seguridad` no la ha revisado.
   **No los declaro cerrados.**
3. **`SEC-095` y `SEC-096` NO se cierran**, y esta prueba no los cierra: ejerció **una** composición
   (documento viejo + agentes nuevos) y **no** ejerció la mitad de copia propia de los agentes ni
   ninguna corrida de `arnes-upgrade`.
4. **`SEC-097` sigue siendo una decisión del propietario** (levantar o no el límite 3). No se tocó.
5. **La condición de `docs/ESTADO.md` §«⏸ RETOMAR AQUÍ»** —«primero se resuelve cómo se mantiene
   compatible el conjunto de instrucciones durante una actualización»— la responde este diseño en
   **una** dirección (el documento congelado gobierna al agente que sube), pero **quién decide que
   está respondida es el propietario**, no yo.
6. **Nada de esto está medido sobre un despacho real.** Ver § «Lo que esta prueba NO acredita».
7. **`docs/ESTADO.md` § «⏸ RETOMAR AQUÍ» queda desfasado y NO lo toco.** Dice «no se vuelve a tocar
   `AGENTS.md`, las plantillas, los agentes ni las skills», y esta entrega los tocó por encargo
   posterior del propietario (2026-09-13). Ese bloque es de la coordinadora: reconciliarlo es suyo,
   no mío, y dejarlo desfasado **en silencio** sería peor — por eso queda escrito aquí.
