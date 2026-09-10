# ADR-009 — La ausencia de un campo de cabecera no se resuelve del lado que abre
Fecha: 2026-09-09
Estado: propuesta (gate humano pendiente: toca `.arnes/config.json` y la superficie heredada)

> **El papel, que es lo estable.** Éste es el **«ADR de la dirección de la ausencia»** que
> `REQ-024` encarga. El **número** se estampó al crearlo: `ADR-006`, `ADR-007` y `ADR-008` ya
> estaban ocupados (los dos primeros por REQ-014, el tercero por REQ-026), verificado leyendo
> `docs/decisions/` el 2026-09-09. El número no tiene asignador, así que reservarlo por
> anticipado sería un absoluto sobre un conjunto que otro trabajo puede ampliar.

## Contexto

La puerta de cierre (`hooks/guard-completado.sh`) y el lector de campos (`hooks/lib.sh`)
resolvían la **ausencia** de un campo de cabecera **del lado que abre**. No es una vía: es un
**estado**. La puerta no mide *cómo* desapareció la línea —comentada, borrada o nunca escrita—,
mide que **no está**; y para cuatro de los seis campos que el lector reconoce, «no está»
equivalía a «no exige nada».

**Medido, y por dos caminos independientes.** El auditor lo midió ejecutando el entrypoint real
en la instalada `1.32.1` y en `cand/1.33.0` (`SEC-047` mitad 2, `R-013` §1 y §2, 11 filas): un
REQ `critico` con `QA: pendiente` y `Seguridad: pendiente` **cerraba** comentando una línea. Esta
comisión lo re-derivó leyendo el código y luego **ejecutando** el par de fixtures campo a campo:
la clase es de **4 de 6** —`QA`, `Sensible a seguridad`, `Hallazgos abiertos`, `Rigor`—;
`Seguridad` **cierra** y `Estado` es el sujeto de la transición.

Y el forzador que el auditor subió, que conviene conservar textual porque es la mitad del valor
de la medición: **«Un BOM en un diff es una anomalía; un campo comentado en un diff parece
higiene.»** La vía del comentario no necesita ni un carácter invisible: es una edición de una
línea que cualquier agente escribe con `Edit`, que **aparece** en el diff, y que un revisor
humano lee como *«el REQ declara que es sensible»* mientras la máquina lee *«no declara nada»*.

Dos cosas más del contexto, porque acotan la decisión:

- **La decisión vivía en DOS sitios.** `hooks/guard-completado.sh` decidía la dirección de los
  veredictos y de la clase del hallazgo (`[ -n "$qa" ]`, `[ -n "$hall" ]`);
  `hooks/lib.sh` la decidía para el suelo de sensibilidad (`arnes_sens_efectiva`) y para el
  nivel de rigor (`arnes_rigor_efectivo`). Dos transcripciones de la misma noción se desfasan, y
  **ya lo habían hecho**: el puntero de `REQ-016 CA-11` cita **un** archivo como lista
  exhaustiva y **2 de los 4** campos de la clase no están ahí (`SEC-050`).
- **El radio de migración es el precio real.** Si la ausencia dejara de perdonarse por defecto,
  **todo** REQ heredado de **todo** proyecto instalado que no declare uno de esos cuatro campos
  dejaría de cerrar el día de la actualización. La fricción termina con alguien apagando el
  guard (`AGENTS.md` §13), y un guard apagado protege menos que uno parcial.

## Decisión

**Tres decisiones, y las tres son de este ADR.**

1. **La dirección de la ausencia se declara en UN solo sitio, y ese sitio es `hooks/lib.sh`:**
   la tabla `ARNES_AUSENCIA`, **derivada** de las constantes `ARNES_CLAVE_*` que `REQ-023 CA-06`
   creó. Los dos despachos (`arnes_campos_req`, `arnes_estado_cabecera`) siguen enrutando cada
   clave a su variable, pero ya **no deciden**: preguntan a `arnes_resuelve_ausencia`, que es el
   único que decide.

2. **Qué dirección corresponde a cada campo**, campo a campo y con su motivo:

   | Campo | Dirección | Por qué ésa |
   |---|---|---|
   | `Sensible a seguridad` | **`gobierna: si`** | Existe un valor que más restringe y aplicarlo no inventa nada que nadie haya firmado: conserva el **suelo** de rigor en vez de retirarlo |
   | `Rigor` | **`gobierna: critico`** | Igual: el nivel más alto de ceremonia es un valor legítimo, no una firma |
   | `QA` | **`deniega`**, nombrando el campo | «Gobernar» un veredicto sería **fabricar una firma que nadie emitió**, que es peor que no tenerla |
   | `Seguridad` | **`deniega`** | Ya lo hacía (`hooks/guard-completado.sh` compara sin `-n`); la tabla lo **declara** para que el sitio único sea exhaustivo |
   | `Hallazgos abiertos` | **`deniega`**, nombrando el campo | `(ninguno)` es una declaración —alguien miró—; que la línea no exista es que nadie la escribió. Inventar «ninguno» abre; inventar un hallazgo bloqueante fabricaría lo contrario |
   | `Estado` | **`n/a`** | Es el **sujeto** de la transición, no una exigencia que su ausencia pueda activar: sin él no hay cierre que juzgar |

   La tercera salida —**abrir**— es la de hasta 1.33.0 y es la que esta tabla existe para no
   tener.

3. **La exigencia se activa por una llave de manifiesto, `campos.ausencia_exige` (booleana, y
   nace APAGADA), y esa llave viaja DENTRO de la lectura del manifiesto que cada punto de entrada
   ya hacía.** No cuesta **ni un proceso** en el camino de evaluación.

   Esto último no es un detalle de implementación: `REQ-024 CA-07 (i)` contrata **0 procesos
   añadidos**, y el propio REQ escribió que una llave de manifiesto «cuesta un proceso `jq`»
   y que ahí podía haber una colisión insalvable con su propio diseño. **La colisión no se
   materializa, y está verificado:** `arnes_parse_manifest` lee el manifiesto entero en **una
   sola** invocación de `jq` (`hooks/lib.sh:71`) y esa invocación corre **antes** de leer los
   campos (`hooks/guard-completado.sh:64` frente a `:230`). Añadir la llave a ese programa de
   `jq` —y al de `hooks/estado-derivado.sh` y al de `tools/arnes-lectura.sh`— es 0 forks. Medido
   ejecutando: la evaluación de la puerta gasta **2** procesos y la línea base `v1.33.0` gasta
   **2**; la parada gasta **5** y la línea base **5**.

## Alternativas consideradas

- **El sitio único en `hooks/guard-completado.sh`, que es lo que haría cierto el puntero de
  `REQ-016 CA-11` sin tocar REQ-016.** *Por qué no, y es la única razón que hacía falta:*
  `hooks/lib.sh` lo cargan **siete** puntos de entrada y sólo uno es la puerta. Los otros seis
  —entre ellos `hooks/estado-derivado.sh` y `tools/arnes-lectura.sh`, que **sí** resuelven la
  ausencia al derivar el rigor efectivo— **no** cargan `guard-completado.sh`. Una tabla ahí sería
  invisible para ellos: el informe diría `estandar` donde la puerta dice `critico`, que es
  exactamente el desfase entre lectores que este repositorio persigue y que `CA-11 (ii)` vigila.
  **Consecuencia asumida:** `REQ-024 CA-03` resuelve por su salida **(ii)** —el sitio único es
  otro, `REQ-016` vuelve a `en-progreso` y su `CA-11` se reescribe con el puntero real—. Es la
  remediación 1 de `SEC-050`, y es trabajo del `analista-requerimientos`, no de código.
- **Hacer que un campo COMENTADO no equivalga a uno BORRADO, y denegar sólo sobre el comentado.**
  Rompe un contrato firmado y medido por el lado peor: `REQ-016 CA-11` pone la **equivalencia**
  como criterio, y romperla deja el **borrado** abierto, que es la vía más fácil de todas.
  Además persigue la **vía** y no el **estado**: enumerar vías es lo que este repositorio ha
  perdido **cinco** veces (`ADR-002`, `SEC-020`, `SEC-024`, `SEC-025`, `H-01`).
- **Que la exigencia sea el DEFECTO en 1.34.0.** Lo prohíbe `REQ-024 CA-05`, que contrata que en
  esta versión un proyecto que no activa nada decide **idéntico**, REQ a REQ y decisión a
  decisión. Que pase a ser el defecto es un cambio de versión posterior, nombrado en «Fuera de
  alcance» de REQ-024 con dueño, ventana (1.35.0) y forzador.
- **Exigir sólo sobre los REQ que ya declaren algún campo de la clase.** No cierra la clase: un
  REQ que no declara **ninguno** sigue abierto, y ése es exactamente el estado que `SEC-047`
  explota.
- **`gobierna` para los cuatro campos de la clase.** Para un veredicto, «el valor que más
  restringe» sería `pendiente` o `con-hallazgos`, y aplicarlo produciría una denegación con un
  motivo que **miente** —diría que QA encontró algo cuando nadie miró—. Denegar nombrando el
  campo que falta dice la verdad y lleva a la misma puerta cerrada.

## Consecuencias

- (+) **Cierra la clase entera con un solo cambio para quien la active:** el comentario, el
  borrado y el carácter invisible (`REQ-023`) dejan de abrir por la misma vía, y también las que
  nadie ha descubierto todavía — incluida la clave con **otra capitalización** (`QA-023-09`),
  que se resolvía como ausencia y queda cerrada **por construcción**, sin reconocer ninguna
  capitalización y sin ninguna tabla que envejezca.
- (+) **El número de transcripciones BAJA:** la dirección se declaraba en dos sitios y ahora en
  uno. Un campo nuevo que llegue al lector sin declarar su dirección **hace fallar el banco
  nombrando esa clave** (`REQ-024 CA-02`).
- (+) **Un fail-closed que no es silencioso:** cuando el rigor llega a `critico` porque un campo
  ausente se resolvió con el valor que más restringe, el motivo **lo dice y nombra el campo**.
  «Entra pero no ve nada, sin explicación» es un bug de diagnóstico, no una puerta.
- (−) **Un proyecto que NO active la llave sigue expuesto a la clase entera.** No se maquilla:
  es la consecuencia directa de `CA-05` y `CA-11 (iii)`, y queda **nombrada** en «Fuera de
  alcance» de REQ-024 con dueño (`analista-requerimientos` para el texto; cada proyecto
  consumidor para la decisión de activar), ventana **1.35.0** y forzador (el primer proyecto que
  reporte un cierre sin auditoría por esa vía).
- (−) **Activar tiene un coste de migración que se paga de golpe.** Todo REQ heredado que omita
  uno de los cuatro campos deja de cerrar hasta declararlo. Mitigación: la llave nace apagada, el
  `_doc` del manifiesto manda **medir antes** con `tools/arnes-lectura.sh` y preguntar por
  **estado** —«cuáles de mis REQ en estado terminal no cerrarían hoy»—, y el informe que
  **anticipa** ese coste queda fuera de alcance con dueño y ventana.
- (−) **`REQ-016` queda con un puntero falso hasta que el analista lo reescriba.** Está medido y
  publicado en cada corrida del banco (`REQ-024 CA-03`, 2 de 4 campos), y el caso dice
  expresamente que **no acredita** que el write-back se haya hecho.
- (−) **Desviación declarada:** `hooks/estado-derivado.sh` no estaba en el `Archivos:` de
  REQ-024 y esta comisión le añadió **un renglón** (leer la llave en la llamada a `jq` que ya
  hacía), porque publica el **rigor efectivo** en su tabla y sin la llave el tablero diría
  `estandar` donde la puerta dice `critico`. Va al Historial de REQ-024 como desviación.
