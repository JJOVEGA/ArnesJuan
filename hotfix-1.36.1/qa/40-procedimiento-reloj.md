# Procedimiento de atribución del FAIL de reloj REQ-017 CA-08 (ii) («un REQ real de 6 líneas»)

**Fijado por escrito ANTES de correr nada** (QA fase 2 de REQ-032, 2026-10-14, cabeza `9e97bd7`). Mismo
patrón que INS-136-3 e INS-136-4: el número de corridas, los árboles y la regla de decisión se fijan aquí y
no se cambian a la vista del resultado. Un FAIL no se desmiente repitiendo: aquí no se repite el FAIL para
que salga verde, se mide **a quién se le atribuye**.

## Pregunta
¿El FAIL de CA-08 (ii) que vio el desarrollador (1,263×–1,300× contra v1.32.1, techo 1,25×) es atribuible
al cambio de REQ-032 (`9e97bd7` frente a `v1.36.0`)?

## Sujeto
Exactamente el de la sonda 37/5: un `Edit` que cierra un REQ de 6 líneas de cabecera (`mkreq_r REQ-100 no
aprobado n/a estandar` del banco; aquí reconstruido con el mismo texto), juzgado por `guard-completado.sh`
solo, con `CLAUDE_PROJECT_DIR` en el proyecto de fixture con el manifiesto base del banco.

## Instrumento
`tests/util/sonda-reloj.sh` del candidato, con los mismos mandos que 37/5: `--k 4 --r 6`, sujetos A y B
**intercalados en una sola invocación**, estadístico el **mínimo** (lo impone la sonda).

## Árboles
- **C** — candidata: `hooks/` de `9e97bd7`.
- **B** — v1.36.0: la instalada, idéntica a `git archive f22b905 hooks` (comprobado en `00-entorno.txt`).
- **H** — v1.32.1: `git archive v1.32.1 hooks` (la línea base de CA-08 (ii)).

## Corridas
**N = 10 rondas**, en serie. Cada ronda mide tres pares, con el orden rotado ronda a ronda:
- **P1 = C frente a B** (la atribución: lo único que difiere es el cambio de REQ-032);
- **P2 = C frente a H** (el criterio tal como lo juzga el banco);
- **P3 = B frente a H** (dónde cae la línea base v1.36.0 respecto del mismo techo).

Carga: `uptime` antes de cada ronda, anotado en la salida. Durante las 10 rondas QA no corre nada más (ni el
banco ni otras sondas). Ninguna ronda se descarta ni se repite: la que no mide (`estado` distinto de `ok`)
entra como **no resuelta** y se cuenta así.

Además, como evidencia de camino de código (no de reloj): una traza `bash -x` del sujeto con la candidata,
contando las llamadas a `arnes_destino_a_juzgar` (la única función nueva) y a las líneas cambiadas.

## Regla de decisión (fijada antes)
Razón de un par = `min_a / min_b` de esa invocación.
- **Atribuible al cambio** si **P1** tiene mediana **> 1,05** **y** al menos **7 de 10** rondas resueltas con
  razón > 1,00. Entonces es un veredicto del banco que cambia por el cambio: **condición de parada**.
- **No atribuible** en cualquier otro caso. Entonces se clasifica **`instrumento`**, con su ficha, y se
  apoya en P3: si v1.36.0 también cae cerca o por encima de 1,25× contra v1.32.1, el techo es más fino que
  el ruido de la sonda (F-136-8).
- Se publican, además, las tres distribuciones (mínimo, mediana, máximo) y cuántas rondas de P2 y P3
  superan 1,25×.
- Si menos de 7 rondas de P1 se resuelven, el resultado es **no concluyente** y se dice así; no se
  clasifica.

Los veredictos de CA-08 (ii) que salgan en las corridas completas del banco de esta misma fase (con la
candidata y con v1.36.0 como candidata) se anotan como dato adicional; **no deciden**.
