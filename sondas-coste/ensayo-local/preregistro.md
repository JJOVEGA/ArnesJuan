# Ensayo local del procedimiento propuesto para las sondas de REQ-017 — PREREGISTRO (escrito ANTES de medir, 2026-09-25)

**Autorización:** experimento local y aislado para evaluar `sondas-coste/propuesta.md` (`020b643`); sin incorporarlo al banco ni cambiar el contrato; sin CI ni push. **Entorno:** árbol de ensayo `/home/juan/dev/ArnesJuan-ensayo-sondas` = `main` `cfb1106` (worktree separado, detached) con el parche `propuesta-sondas-REQ-017.patch` aplicado **sólo ahí**, más una sección de controles `37-coste-del-escaner-9-ensayo-controles.sh` (sólo ahí) y dos líneas de instrumentación que publican los datos de cada repetición. WSL2, 12 CPU, carga inicial 0,5. **Nada de esto toca `main`, el PR #53, hooks, umbrales, workflows ni rulesets.**

## Presupuesto y orden (fijos)
- **N = 10 corridas**, secuenciales, numeradas 01…10. Cada corrida = `ARNES_JOBS=6 bash tests/escenarios/hooks/run.sh tests/escenarios/hooks/secciones/37-*.sh` (corrida parcial: 37/1, 37/2, 37/3, 37/4, 37/5 y 37/9 en paralelo, seis secciones → hay contención entre sondas, como en la puerta requerida, aunque menos vecinos que en CI).
- Orden **dentro** de cada corrida: 37/2 mide CA-03 con R=5 repeticiones (cada repetición: este árbol S y 2S, luego v1.32.1 S y 2S, k=20); 37/5 mide CA-08 (ii) con R=5 pares intercalados por entrada (REQ-100 de 6 líneas, luego REQ-200 de 200 líneas; 6 series × k=4 por brazo); 37/9 mide, por entrada REQ-100 y luego REQ-200, los controles **I** (idénticos), **W0** (envoltorio con demora 0) y **WD** (envoltorio con demora fija), cada uno con R=5.
- **Límite de tiempo total: 150 minutos de pared.** Antes de arrancar cada corrida se comprueba el tiempo consumido; si excede el límite, no se arranca y se conserva lo obtenido, declarando cuántas corridas faltaron. **No se amplía la muestra ni se ajusta el procedimiento después de ver resultados.**
- **Demoras del control WD, fijadas ahora:** REQ-100: **40 ms por llamada**; REQ-200: **100 ms por llamada** (`sleep` en un envoltorio que después ejecuta el hook real). Derivadas de los tiempos por llamada de los logs de CI (≈0,08 s y ≈0,19 s): razón esperada ≈ 1,5× en ambas. **No se recalibran** aunque en esta máquina el sujeto sea más rápido o más lento: si la razón resultante cae cerca del techo, se declara.

## Reglas exactas (idénticas para CA-08 (ii), los controles y CA-03)
- **Repetición resuelta:** las dos series tienen mínimo ≥ 50 000 µs **y** en cada brazo `2.º mínimo / mínimo ≤ 1,250` (CA-08) — en CA-03 la resolución de cada lado es «midió y su mínimo ≥ 50 ms». Una repetición sin registro, bajo el suelo o sin converger es **no resuelta**: cuenta en el denominador y **no se descarta ni se sustituye**.
- **Igualdad con el techo:** una razón **igual** al techo **cumple** (`r ≤ techo` es lado conforme; `r > techo` excede). Lo mismo para la convergencia (`≤ 1,250` converge).
- Con **menos de 3 resueltas de 5: NO CONCLUYENTE** (impreso como `SKIP … [INCONCLUSO]`).
- Con ≥ 3 resueltas: **PASS** si `máx(r) ≤ techo`; **FAIL** si `mín(r) > techo`; **NO CONCLUYENTE** si el techo cae dentro de `[mín(r), máx(r)]`.
- **CA-03:** calibración resuelta si `mín(razón heredada) > 2,600` con ≥ 3 medidas; si no, el caso directo es **NO CONCLUYENTE** aunque su razón esté bajo el techo. Con calibración resuelta: PASS si `máx(razón este) ≤ 2,600`, FAIL si `mín(razón este) > 2,600`, si no NO CONCLUYENTE.
- **Por qué 3 de 5 permiten decidir, y qué incertidumbre dejan las otras 2:** tres razones resueltas dan un recorrido observado con tres puntos; el veredicto sólo se emite si **las tres caen del mismo lado del techo**, así que una lectura discordante entre las tres ya lo vuelve no concluyente. Las dos no resueltas **no se han visto**: no se sabe de qué lado habrían caído. Por eso un PASS o FAIL con 3 resueltas es **más débil** que con 5 y se publica el recuento (`en 3 de 5`): quien lea sabe que dos quintos de la muestra no midieron. Si esa debilidad importa para la decisión, la salida es exigir 4 o 5 —cuestión de contrato, que este ensayo **no** decide: mide cuántas veces ocurre.
- **Veredicto «vigente» derivado, para comparar sobre datos compatibles:** el procedimiento de `main` decide con **un** par (la primera repetición) y la convergencia por brazo. Se deriva de la **repetición #1** de cada caso: si #1 no resolvió → SKIP vigente; si resolvió, PASS/FAIL por su razón contra el techo. Para CA-03 la comparación con el vigente es **parcial**: el vigente mide la calibración con k=1 (aquí k=20), así que sólo la directa (repetición #1, k=20) es comparable; la calibración vigente **no se reproduce**.

## Resultados esperados y criterios de decisión (fijados antes)
| Comprobación | Esperado | Umbral de decisión |
|---|---|---|
| Lógica del juez (vectores sintéticos, 9 casos: fronteras, mezclas, no resueltas) | 9 de 9 conformes | cualquier desviación **descarta** hasta corregir |
| Control **I** (idénticos) y **W0** (envoltorio 0), 10 corridas × 2 entradas cada uno | 0 FAIL; PASS o INCONCLUSO | **≥ 1 FAIL** = falso aviso → **descartar** el procedimiento tal cual |
| Control **WD** (demora fija), 10 × 2 | FAIL | **< 7 de 10 FAIL** por entrada, o cualquier PASS → el procedimiento **no detecta** una demora añadida ≈1,5× → descartar |
| CA-08 (ii) real (este árbol frente a v1.32.1; mecanismo idéntico a `main`) | 0 FAIL; PASS o INCONCLUSO | ≥ 1 FAIL → registrar como falso aviso (o regresión no conocida: se declara) |
| CA-03 directa y su calibración | 0 FAIL; calibración resuelta ≥ 8 de 10 | ≥ 1 FAIL de la directa con calibración resuelta → se investiga, no se repite; calibración resuelta < 8/10 → insuficiente |
| Abstenciones | se cuentan por caso | INCONCLUSO en CA-08 (ii) real **> 5 de 10** en una entrada → **insuficiente**: esta máquina tampoco resuelve 1,25; no se sube R |
| Comparación con el vigente (repetición #1) | menos FAIL sobre código idéntico | una reducción de FAIL **acompañada** de más INCONCLUSO **no** demuestra mejora por sí sola: se presenta la tabla completa |
| Coste | duración medida por corrida y por sonda | se reporta; no hay umbral en este ensayo |
**Recomendación posible según resultado:** *descartar* (algún umbral de descarte), *insuficiente* (abstenciones excesivas o calibración no resuelta), o *avanzar a una comprobación acotada en CI* (todos los umbrales cumplidos). **Implementar** directamente no cabe: el ensayo local no acredita el runner de GitHub.

## Qué NO acredita este ensayo
El comportamiento del runner de GitHub (otra máquina, otros vecinos); que una demora añadida por `sleep` equivalga a una regresión interna del escáner (mide **capacidad de detectar una demora**, no la regresión de CA-03, cuyo control real es v1.32.1); ninguna cifra de coste del CI.
