# Comprobación acotada en CI del procedimiento propuesto para las sondas — PREREGISTRO (antes de la primera ejecución, 2026-09-25)

**Autorización:** «una comprobación experimental en CI, separada del PR #53, con un máximo de cinco ejecuciones». **Rama exclusiva de ensayo:** `ensayo/sondas-r5`, **SHA del experimento: `83f1e9c42f39b7971d4ff5297571d56b2012a517`** (base `main` = `cfb1106`). Contenido exacto: `contenido-del-experimento.diff` (5 archivos): el parche `propuesta-sondas-REQ-017.patch` sobre 37/2 y 37/5, la sección `37/9` de controles (idénticos **I**, envoltorio con demora 0 **W0**, demora fija **WD** = 40 ms/llamada en 6 líneas y 100 ms en 200 líneas), dos líneas de instrumentación, `CASOS_ESPERADOS` 912 → 917 y una entrada de CHANGELOG. **Nada en `hooks/`, `tools/`, umbrales, `.github/` ni ruleset; `main` y el PR #53 no se tocan.**

## Cómo lo ejecuta el workflow existente (verificado en `.github/workflows/banco.yml`)
- Disparadores: `push` **sólo a `main`** y `pull_request`. **Un push a la rama de ensayo por sí solo NO dispara nada**: el experimento se ejecuta abriendo un **PR en borrador** `ensayo/sondas-r5 → main` que **nunca se fusiona**; cada `push` posterior a la rama del PR dispara una corrida nueva. No se modifica el workflow.
- El paso «banco de hooks» corre `bash tests/escenarios/hooks/run.sh` **entero** (`JOBS=6`, ~40 secciones en paralelo: la contención del runner real), con `fetch-depth: 0` (el tag `v1.32.1` existe para la calibración). La sección `37/9` entra por descubrimiento (glob). **El control WD produce 2 FAIL esperados en cada corrida → el check `hooks-en-linux` saldrá ROJO a propósito y la autoprueba no correrá**: no es un fallo del experimento; los demás resultados quedan recogidos en el mismo log.
- **Vigente frente a propuesto, sobre los mismos datos:** el veredicto del procedimiento vigente se **deriva de la repetición #1** de cada caso (regla de `main`: un par, convergencia por brazo, razón contra el techo). **No comparable directamente:** la calibración de CA-03 (el vigente la mide con k=1; aquí k=20) y el sobrecoste (se mide contra las corridas anteriores del mismo workflow: 1–2 min).

## Los cinco ensayos
1. Corrida 1: la abre el PR en borrador (`pull_request` `opened`) sobre `83f1e9c42f39b7971d4ff5297571d56b2012a517`.
2. Corridas 2–5: **un commit vacío cada una** (`git commit --allow-empty`) empujado **sólo cuando la anterior haya terminado**, en secuencia; **mismo contenido, mismos parámetros, mismos umbrales**. Los SHA de esos commits difieren sólo en el commit vacío (árbol idéntico: se verifica con `git rev-parse <sha>^{tree}`).
3. **Toda ejecución iniciada cuenta** dentro del presupuesto de 5, termine como termine (cancelada, agotada por `timeout-minutes: 20`, fallida). **Sin reintentos, sin `re-run`, sin sustituir corridas desfavorables.** Si el runner cancela o falla antes de terminar, se conserva el log parcial y cuenta.
4. **Límite de tiempo total: 60 minutos de pared** desde la apertura del PR. Si se agota, no se lanza la corrida siguiente y se declara cuántas faltaron.
5. **Conservación:** log completo de cada corrida (`gh run view --log`) en `corridas/run-<id>-<sha>.txt` con su `meta` (SHA, inicio, fin, conclusión, duración del job); análisis con `../ensayo-local/analizar-ensayo.py` adaptado a las líneas con marca de tiempo; **los resultados incompletos se guardan tal cual**.

## Reglas de interpretación (fijadas antes; corrigen la propuesta previa)
- **FAIL de un caso real (CA-08 (ii) o CA-03 directa):** **no** demuestra por sí solo que el instrumento sea defectuoso; puede señalar un incumplimiento existente en `main`. Se **conserva** y se **contrasta con los controles de la misma corrida**: si I y W0 pasan y WD falla en esa corrida, el instrumento resolvía y el FAIL real se registra como **posible incumplimiento** a investigar (no se relanza); si I o W0 fallan en esa corrida, la medición está cuestionada.
- **FAIL entre sujetos idénticos (I) o con envoltorio 0 (W0):** cuestiona la **fiabilidad** de la medición → «procedimiento cuestionado por los controles».
- **PASS del sujeto ralentizado (WD):** cuestiona la **capacidad de detección**; un **INCONCLUSO** en WD **no acredita** esa capacidad.
- **Inconclusos:** se cuentan por caso y corrida; **no acreditan rendimiento aunque el workflow quede verde** (aquí quedará rojo por WD de todos modos).
- **Si ambos procedimientos funcionan igual, o no aparece la variación que originó el problema (lecturas > 1,25 en CA-08 (ii) o > 2,6 en CA-03 sobre mecanismo idéntico), NO se declara mejora demostrada.**
- **Cinco ejecuciones favorables** (0 FAIL en I/W0 y en los casos reales, WD FAIL 5 de 5 por entrada, calibración de CA-03 resuelta, inconclusos reportados) **permiten recomendar adopción; no autorizan implementarla.**
- Conclusión posible, una de tres: **evidencia favorable para proponer adopción** · **procedimiento cuestionado por los controles** · **evidencia insuficiente** (por ejemplo ≥ 3 de 5 inconclusos en un caso real, o menos de 5 corridas completas sin que lo obtenido permita decidir).
- **No se ajusta ningún parámetro tras ver resultados ni se amplía la muestra.**

## Qué no acredita
El sobrecoste exacto (se estima por comparación de duraciones del job); que un FAIL histórico del PR #53 fuera ruido (se conservan); la conducta del instrumento con `main` cambiado (mecanismo idéntico en las 5).
