# `QA-024-20` — qué debe decir el criterio para corresponder con lo construido

> **Esto NO es el write-back: es el insumo para él.** El write-back lo hace el
> `analista-requerimientos` sobre `requirements/`, que el `desarrollador` no escribe
> (`AGENTS.md` §9). Aquí va **lo que hay construido, medido y citado a línea**, para que el
> analista no tenga que re-derivarlo leyendo el código.
>
> Vuelta **4** de `REQ-024`. Hallazgo: `QA-024-20`, `contrato`, bloquea, dueño
> `analista-requerimientos`.

---

## 1. El defecto, en una frase

El criterio enumera **cerrado** dos causas de abstención —**suelo** y **línea base
ausente**— y lo construido se abstiene por **cuatro más**, todas ellas **con la sonda por
encima de su suelo y con la línea base presente**. Y le falta la **cota** de la abstención que
el criterio hermano `REQ-017 CA-08 (ii)` sí contrata.

---

## 2. Las causas de abstención REALMENTE construidas, una por una y con su línea

Sobre `tests/escenarios/hooks/secciones/40-ausencia-que-abre-7-el-reloj-de-la-ruta-critica.sh`
tal como quedó en la vuelta 3.

| # | causa | dónde decide | ¿la enumera hoy el criterio? | ¿la sonda está sobre su suelo? |
|---|---|---|---|---|
| 1 | **Línea base ausente**: `mat07 v1.33.0` no materializó el árbol heredado | `:144` (`FALTA07`) → `:239` | **sí** | n/a |
| 2 | **Suelo**: alguna serie por debajo de 50 ms, por **dos vías** — la sonda devuelve `estado=suelo` y la repetición entra vacía (`:150`/`:154`), o `razon07` lo re-comprueba sobre `min_a`/`min_b` | `:173-174` | **sí** | no (ésa es la causa) |
| 3 | **La sonda no midió por otro motivo**: `sonda_lee` falla, o `estado ≠ ok` por plazo agotado, descendencia viva o registro ambiguo | `:150-156` (`FALTA07` en `:154`) | **NO** | **sí** |
| 4 | **No convergencia por brazo**: `segundo mínimo / mínimo` de cualquiera de los dos brazos por encima de **1,250×** | `:178-186` | **NO** | **sí** |
| 5 | **El techo cae DENTRO del recorrido** de las `k` razones: `mín(r) ≤ 1,250× < máx(r)` | `:230-231` | **NO** | **sí** |
| 6 | **No llegó ninguna repetición** del par intercalado (`n = 0`) | `:220` | **NO** | n/a |

**Las cuatro que faltan (3, 4, 5 y 6) se abstienen con la línea base presente y la sonda por
encima de su suelo**, que es exactamente lo que la redacción actual excluye al decir «**o es
SKIP si la sonda no llega a su suelo**» (`REQ-024:465`).

---

## 3. La forma de la corrección: **propiedad**, no lista cerrada más larga

Cambiar «dos causas» por «seis causas» repite el defecto con el número cambiado: la lista se
volvería a quedar corta el día que la guarda crezca —y la fase 2 puede hacerla crecer—. La
enmienda tiene que enunciar la **propiedad que decide** y dar las causas conocidas **como
ejemplos declaradamente no exhaustivos**, que es la forma que este arnés ya usa para la clase
del carácter invisible (`AGENTS.md` §13).

**La propiedad es decidible y está implementada, así que no es un rodeo retórico:**

> La puerta **se abstiene** exactamente cuando **no puede afirmar la unanimidad de las `k`
> razones respecto del techo** — ni `máx(r) ≤ techo` en todas, ni `mín(r) > techo` en todas —,
> **incluido el caso en que alguna de las `k` razones no llegue a existir**. Una medición
> inconclusa **no es una aprobación** y **nunca** sale `PASS`.

Las seis causas del §2 **se reducen todas** a esa propiedad, y por eso la propiedad es la sede
y la lista es el ejemplo. **Y el matiz «no exhaustiva» no cuelga de una promesa absoluta**: la
promesa principal aquí **es** la propiedad, no una enumeración.

---

## 4. La cota que falta, y la advertencia de no escribirla como no se puede comprobar

`REQ-017 CA-08 (ii)`:136 contrata, para el criterio hermano y con la misma patología:

> **no más de 1** corrida **consecutiva** de la puerta requerida `hooks-en-linux` abstenida en
> **este acto** (**operativo**: se **baja** con la medición; suelo de esa dirección: **1**);
> tras ella la abstención **deja de ser un veredicto**, **pasa a hallazgo** con dueño y se
> **escala al propietario**.

Su motivo está medido en `SEC-064`: **una abstención sin cota es un verde que nadie anunció**,
y con el ruido a horcajadas del techo el estado estable de una regresión real situada entre
~1,25× y ~1,40× es `SKIP` corrida tras corrida.

### Y la mitad que el criterio hermano declara abierta, que aquí se hereda IGUAL

`REQ-017 CA-08 (ii)`:136 dice, y está comprobado el 2026-09-10, que dos abstenciones **no se
pueden sumar** mientras no se sepa **de qué máquina** salió cada una — «ningún mensaje de
`37/5`, incluidos sus seis de abstención, emite plataforma ni carga».

> **Comprobado ahora sobre `40/7`: sus mensajes de abstención TAMPOCO emiten plataforma ni
> carga.** Publican las `k` razones, el recorrido, el techo, la peor convergencia y `k`/`r`
> (`:224-225`), y ahí se acaba. Luego una cota escrita hoy en `CA-07 (ii)` **nacería con la
> misma mitad abierta**.
>
> *Comprobado sobre el texto:* los tres mensajes de abstención de `40/7` son `:220`, `:231` y
> `:239`; la lista de evidencia que publican se arma en `:224-225` (`n` razones, recorrido,
> techo, peor convergencia, `k`, `r`). **Ninguno nombra la máquina ni su carga.**

**Consecuencia para la redacción, y es la parte que no se puede omitir:** la cota se escribe
**con su limitación declarada en la misma sede**, igual que en `REQ-017`, o no se escribe
como comprobable. Escribirla en seco sería **documentación haciéndose pasar por remediación**.

**Lo que lo cierra de verdad es barato y es trabajo del `desarrollador`, no del analista:**
añadir `plataforma` y `carga` al mensaje de abstención de `40/7` —los dos campos **ya vienen**
en el registro de la sonda (`SONDA[plataforma]`, `SONDA[carga]`), no hay que medir nada nuevo—.
Queda **anotado como deuda con dueño (`desarrollador`) y entra en la fase 2** si la fase 2 se
autoriza; si no se autoriza, sigue siendo deuda con dueño y **no** se cierra por decreto.

### Y lo que la cota NO sustituye — literal del propietario

> «**Limitar SKIP no sustituye la acreditación de rendimiento.**»

La cota acota **cuántas veces** la puerta puede no decidir; **no** acredita el rendimiento. La
vía de acreditación tiene que seguir escrita y ser **ejecutable**: hoy es
`ARNES_COSTE_RUTA_CRITICA=1` (`r` 6→30, `k` 4→8), que **no apaga la señal** y deja de decidir
cada PR con ella. La cota es **necesaria y no suficiente**, y así debe decirlo el criterio.

---

## 5. Las cuatro sedes, y qué le pasa a cada una

Se corrigen **juntas**: arreglar sólo la última frase señalada es el ciclo de retrabajo que ya
costó una vuelta.

| sede | qué dice hoy | qué le falta |
|---|---|---|
| **`REQ-024:386-391`** — el criterio `CA-07`, punto (ii) | «el **mínimo de k repeticiones** del reloj … **no más de 1,25×** … (**operativo**: se **baja** con la medición)» | el **estadístico cambió**: ya no se decide sobre **una** razón sino sobre la **unanimidad de `k` razones**, con guarda de convergencia por brazo. Hay que decir **qué se mide** (k razones del par intercalado), **con qué regla se decide** (unanimidad) y que existe un **tercer estado** |
| **`REQ-024:465`** — la salida contratada de (ii) | «si al medir sale **> 1,25×**, el techo **no se sube** —es hallazgo contra el **código**— o es **SKIP** si la sonda no llega a su suelo» | la enumeración **cerrada**. Sustituir por la **propiedad** del §3 + las causas como ejemplos **no exhaustivos** + la **cota** del §4 con su limitación |
| **`REQ-024:1150-1152`** — Notas, «su salida está contratada en el propio criterio» | repite la forma corta («si sale `> 1,25×`, el techo **no se sube**») | es una **transcripción** de `:465` y **se desfasa con ella**: o se actualiza igual, o se sustituye por un puntero a `:465` sin re-enunciar la regla |
| **`requirements/README.md:388-390`** — el **sitio único** | «una sonda que no llega a ese suelo, o que no encuentra su línea base, emite SKIP con el motivo y con el número que sí obtuvo — nunca PASS» | enumera **dos** causas y es el **sitio único**, así que su lista cerrada es la que propaga el defecto a cualquier criterio futuro. Debe enunciar la **propiedad** (una sonda que **no resuelve el factor que vigila** se abstiene, y la abstención **nunca es PASS**) y dejar las dos causas como **ejemplos** |

---

## 6. Dependencia con la fase 2 — dicha antes, para que el analista no trabaje dos veces

Lo de arriba describe **lo construido hoy** (vuelta 3). Si la fase 1 sale **viable** y el
propietario autoriza la fase 2, **las causas 4 y 5 pueden cambiar de forma** (otros `k`/`r`,
y un camino de acreditación que no permita que un `SKIP` habilite la fusión). **La propiedad
del §3 y la cota del §4 NO cambian** con eso — están escritas sobre la propiedad justamente
para no tener que reescribirlas—, pero **la tabla de ejemplos del §2 sí**.

**Recomendación operativa, y es sólo eso:** que el write-back de la **propiedad**, de la
**cota** y de las **cuatro sedes** se haga **ya** —no depende de la fase 2— y que la tabla de
ejemplos se confirme contra el árbol final antes de que `QA-024-20` se dé por cerrado. La
decisión de cómo secuenciarlo es de la coordinadora.
