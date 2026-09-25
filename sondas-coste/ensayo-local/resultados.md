# Ensayo local de las sondas de REQ-017 — RESULTADOS (2026-09-25, 21:37Z → 22:07Z)

**Lo preregistrado se cumplió sin cambios:** N = 10 corridas secuenciales, orden fijo, 1 795 s de pared en total (161–217 s por corrida; límite 150 min, no alcanzado), demoras D100 = 40 ms y D200 = 100 ms fijadas antes, reglas exactas de `preregistro.md`. Ninguna corrida se descartó ni se repitió. Entorno: WSL2, 12 CPU, carga 0,5 → 3,4 durante el ensayo; corridas parciales `37/*` con seis secciones en paralelo. **Este ensayo no acredita el runner de GitHub.** Todas las lecturas: `corridas/corrida-NN.txt`; análisis: `analisis.txt`, `analisis-vigente-derivado.txt`.

## 1. Lógica del evaluador (vectores sintéticos): 9 de 9 conformes
Fronteras (razón igual al techo cumple), mezclas, brazo sin converger, serie bajo el suelo, repeticiones sin medir, 3 resueltas con 2 no resueltas, 2 resueltas → no concluyente. `juez-sintetico.resultado.txt`. (El arnés lleva un décimo vector con la expectativa mal escrita por la coordinadora —esperaba INCONCLUSO con 3 resueltas todas ≤ techo—; el juez respondió PASS, que es lo que la regla prescribe. Se conserva como está.)

## 2. Controles, con todas las ejecuciones contabilizadas (10 corridas × 2 entradas)
| Control | Propuesto (R=5, regla de recorrido) | Vigente derivado (repetición #1, regla de `main`) | Razones resueltas, recorrido |
|---|---|---|---|
| **I** idénticos, 6 líneas | **PASS 10** · FAIL 0 · INCONCLUSO 0 | PASS 10 · FAIL 0 | 49: 0,915–1,113 |
| **I** idénticos, 200 líneas | **PASS 10** · 0 · 0 | PASS 10 | 49: 0,901–1,119 |
| **W0** envoltorio con demora 0, 6 l. | **PASS 10** · 0 · 0 | PASS 9 · SKIP 1 (no convergió #1: 1,251 / 1,317) | 49: 0,904–1,161 |
| **W0**, 200 l. | **PASS 10** · 0 · 0 | PASS 10 | 50: 0,900–1,144 |
| **WD** demora fija 40 ms, 6 l. | **FAIL 10** (mín(r) 1,715–2,045; todas las 50 razones > techo) | FAIL 10 | 50: 1,715–2,291 |
| **WD** demora fija 100 ms, 200 l. | **FAIL 10** (mín(r) 1,812–2,100) | FAIL 10 | 50: 1,812–2,324 |
| **CA-08 (ii) real**, este árbol / v1.32.1, 6 l. | **PASS 10** · 0 · 0 | PASS 10 | 49: 0,796–1,164 |
| **CA-08 (ii) real**, 200 l. | **PASS 10** · 0 · 0 | PASS 10 | 50: 0,865–1,131 |
| **CA-03 directa** (con calibración en la misma corrida) | **PASS 10** · 0 · 0 | PASS 10 (repetición #1: 1,802–2,363) | 50: 1,441–2,373 (0 > 2,6) |
| **CA-03 calibración** v1.32.1 | resuelta **10 de 10** | (no comparable: el vigente la mide con k=1) | 50: 3,059–4,801 (0 ≤ 2,6) |
Repeticiones no resueltas por convergencia: **4 de ~400** (todas por un brazo entre 1,26 y 1,35); ninguna bajo el suelo; ninguna sin medir. **Abstenciones del procedimiento propuesto: 0.**

## 3. Comparación con el vigente y coste
- Sobre los mismos datos, el vigente (una repetición) dio **0 FAIL y 1 SKIP** en 80 casos de código idéntico, y el propuesto **0 FAIL y 0 INCONCLUSO** en 80. **En esta máquina no apareció ningún falso aviso con ninguno de los dos**, así que **el ensayo no puede mostrar que el propuesto mejore la distinción entre controles y regresiones**: no hubo nada que distinguir. La dispersión local de CA-08 (ii) real (0,80–1,16 en 99 razones) es **más estrecha** que la del runner sobre mecanismo idéntico (0,94–1,36 en 16 lecturas), y la de CA-03 (1,44–2,37) también (runner: 1,49–2,75).
- **Detección de una demora añadida:** 20 de 20 con los dos procedimientos, con margen (todas las razones ≥ 1,715). Esto acredita que el instrumento **ve** una demora de ≈1,5–2× por llamada; **no** acredita la detección de una regresión interna del escáner (el control real de eso sigue siendo v1.32.1 en CA-03, que aquí resolvió 10 de 10 con recorrido 3,06–4,80).
- **Coste:** cada invocación de `sonda-reloj` con 6 series × k=4 tarda **2,0–9,6 s (mediana 4,5 s)** en esta máquina. El procedimiento propuesto multiplica por 5 las invocaciones de CA-08 (ii) (2 entradas × 5 = 10 → ≈ 45 s frente a ≈ 9 s) y de CA-03 (5 × 2 lados con k=20). Las corridas parciales completas tardaron 161–217 s con los controles incluidos; **el sobrecoste en el banco de CI no se ha medido**.

## 4. Qué queda demostrado y qué no
**Demostrado (aquí):** la lógica del juez decide como se preregistró; con presupuesto fijo R=5 no hubo falsos avisos en 60 casos de control ni en 20 reales; la calibración de CA-03 con el mismo presupuesto que la directa resolvió siempre (el rojo de `d413405`, con k=1, no se reprodujo aquí); una demora añadida de 40/100 ms se detecta 20 de 20. **No demostrado:** que el procedimiento reduzca los FAIL del runner (ninguno de los dos procedimientos produjo FAIL aquí; la dispersión del runner no se reprodujo); que 1,25× sea resoluble en el runner; el sobrecoste en CI; y que el FAIL de `f7a6fdf` (1,339×) o el de `d413405` (2,443×) fueran ruido: **siguen conservados como medidos**.

## 5. Recomendación: avanzar a UNA comprobación acotada en CI (no implementar; no descartar)
Descartar no procede (ningún umbral de descarte se dio); implementar no cabe (lo que decide —la dispersión— vive en el runner y no se reprodujo). **Propuesta única, sin realizarla:** una rama de ensayo `ensayo/sondas-r5` con el árbol de ensayo tal cual (parche + sección de controles + instrumentación), **5 corridas** del check `hooks-en-linux` (una por push de commit vacío, porque el workflow no admite `workflow_dispatch`; cambiarlo sería otra decisión), sin PR hacia `main`, con reglas fijadas antes: **descartar** si algún I/W0/real da FAIL o si WD da < 4 de 5 FAIL; **insuficiente** si CA-08 (ii) real da INCONCLUSO en ≥ 3 de 5 o la calibración de CA-03 no resuelve en ≥ 2 de 5; **avanzar a implementación** (REQ con ADR, contrato versionado) sólo si 0 FAIL, ≤ 2 INCONCLUSO por entrada y calibración resuelta ≥ 4 de 5; y se mide el sobrecoste de pared frente a las corridas anteriores. Presupuesto: 5 corridas de CI ≈ 5–10 min de runner; ninguna comisión.

## 6. Siguiente paso mínimo para desbloquear REQ-029
El rojo del PR #53 lo producen sondas sobre un mecanismo **idéntico por hash a `main`**: cualquier regresión real estaría en `main`, no en el PR. Lo que este ensayo añade es que, sobre ese mismo mecanismo y en una máquina sin la carga del runner, el mismo instrumento da 0 FAIL en 100 razones. **Decisión mínima, tuya:** integrar el PR #53 con la limitación declarada en el propio PR —«CA-03 y CA-08 (ii) no acreditados sobre la cabeza; dos FAIL de sonda conservados sobre mecanismo idéntico a `main`»—, como se hizo con el PR #52 el 2026-09-22, o esperar a la comprobación en CI de §5 y a la implementación que de ella salga. No se recomienda relanzar el CI del PR #53.
