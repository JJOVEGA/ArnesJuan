# Banco completo en CI — PR #50, `hooks-en-linux`, cabeza `e392fbf` (contenido `81f89bf`)

Run 35127982693 · https://github.com/JJOVEGA/ArnesJuan/actions/runs/35127982693 · 2026-09-16T17:24:26Z → job completo · **success**.

**Corrida autorizada por el propietario** tras las dos reparaciones acotadas (SEC-102 y la partición por REQ-014 CA-18): «push sin force y una corrida completa de CI sobre el candidato final». Única corrida sobre esta cabeza.

**Método.** `gh run view 35127982693 --log` completo → `hooks-en-linux-log.txt` (1838 líneas); pasos y metadatos → `run.json`. Recuentos por `grep` sobre la columna de veredicto, contrastados con las líneas `Resultado:` y `Autoprueba:` del corredor. Identificadores comprobados uno a uno (disciplina `I-6`). El log de CI sale **intercalado** (secciones en paralelo), así que un conteo «entre titulares» no es fiable; los casos de `40/8` se verifican por identificador, no por posición.

## PR #50 — exclusividad verificada
- base `base/via-proporcional` = `f387b1c` (sin cambios) · head `rel/via-proporcional` = `e392fbf` · borrador.
- `gh pr diff 50 --name-only` **idéntico** a `git diff --name-only f387b1c..e392fbf`.
- Push `f6912ea..e392fbf` en fast-forward, sin force: `38858d2` (tablero), `108b087` (SEC-102), `81f89bf` (partición CA-18), `1f6f06d` (QA), `e392fbf` (R-040).

## Los nueve pasos del job: todos `success`
Por primera vez en el PR **la autoprueba del corredor (paso 7) corre y pasa**: en `2b56cb4` y `a82db68` quedó `skipped` tras el rojo del banco; en `f6912ea` corrió y falló (`CA-18`).

## El banco (paso 6): **1278 PASS · 0 FAIL · 16 SKIP — suma 1294 = `CASOS_ESPERADOS` 1294. Cuadre exacto.**
`Resultado: 1278 PASS, 0 FAIL, 16 SKIP — ninguna causa común: cada uno con su motivo`.
Cuadre en el PR: 1290 → 1291 → 1293 → **1294** (+1 por el caso «el coste del borde» de SEC-102; la partición no añade casos: 25 + 5 = 30).

### Las dos secciones ejecutadas, con sus titulares
```
--- 40/3 · la ausencia que abre: los textos que un proyecto hereda (REQ-024 CA-06) ---
--- 40/8 · la ausencia que abre: el reconocedor de promesas de equivalencia (REQ-024 CA-06) ---
```
`REQ-024 CA-06`: **28 líneas**, todas PASS. Los **cinco** casos del reconocedor (`40/8`) por identificador:
```
  PASS  REQ-024 CA-06 las 2 promesas de equivalencia del apartado llevan el ACTO dentro de la promesa (2 con acto, 0 de sujeto abierto; …)
  PASS  REQ-024 CA-06 discriminante: el reconocedor sigue mordiendo lo que debe y suelta lo que no  (…)
  PASS  REQ-024 CA-06 las 7 regresiones conocidas de I-5 siguen mordiendo, y los controles positivos siguen pasando  (7 de 7 …)
  PASS  REQ-024 CA-06 los 6 falsos positivos de I-7 ya no muerden, y el reconocedor no se quedó mudo  (6 de 6 dan «0 0» …)
  PASS  REQ-024 CA-06 el coste del borde: las 3 formas con el término como PREFIJO vuelven a morder y los 3 negativos con el término como SUFIJO siguen en «0 0»  (3 de 3 … «anteriormente», «previamente», «con anterioridad»: regresiones CONOCIDAS de SEC-102 …)
```
Los 25 casos de texto de `40/3` (`(i)`…`(v)` y «ninguna frase del apartado afirma completitud») también PASS.

### `REQ-017 CA-09` — PASS, tercera lectura distinta de la misma sonda
```
  PASS  REQ-017 CA-09 la pared de los 60 s de este árbol NO es menor que la de v1.32.1, pareado en la misma corrida  el PEOR de este árbol vale 1.126× el MEJOR de v1.32.1 medido EN ESTA MISMA corrida (>= 1,000×; los rangos no se solapan …)
```
Serie en el PR, con `hooks/` y `tools/` sin cambios en todo `f387b1c..e392fbf`: SKIP (`2b56cb4`) → **FAIL 0,976×** (`a82db68`) → PASS 1,563× (`f6912ea`) → PASS 1,126× (`e392fbf`). Por instrucción del propietario: **el PASS no borra el FAIL anterior ni demuestra estabilidad**; la sonda no se investigó ni se modificó. El FAIL sigue conservado en `../ci-pr50-a82db68/`.

### OMITIDAS: 13 → 16 — las tres que vuelven son sondas de coste que en `f6912ea` habían dado PASS
Vuelven a SKIP: `REQ-017 CA-03 fail-before: la sonda distingue el árbol cuadrático`; `REQ-017 CA-08 (ii) un REQ real de 6 líneas…`; `REQ-017 CA-08 (ii) una cabecera de 200 líneas…`. Las 13 restantes son las mismas de `f6912ea` (Windows, `REQ-017 CA-10` ×3, `CA-03`, `CA-05` ×2, `REQ-021 CA-08 (iii)`, `REQ-023 CA-12`, `REQ-023 CA-09 (iii)` ×2, `46/11` ×2). Ninguna relacionada con el delta; todas con su motivo impreso.

### ERRORES DE EJECUCIÓN (1) — el mismo, preexistente
```
947: mv: cannot stat '/tmp/tmp.fW9UrR67rQ/.arnes/c2': No such file or directory
```
Sección 33, fixture `python3 … || jq … > c2 && mv c2 …`. Sin efecto en veredictos. Fuera de alcance por instrucción.

## Autoprueba del corredor (paso 7): **106 PASS · 0 FAIL**
`REQ-014 CA-18` en verde con las dos partes bajo su techo, sin tocar N, k ni la autoprueba:
```
       40-ausencia-que-abre-3-los-textos-heredados.sh           lineas= 301 piso=  90 techo= 400 (gobierna N       ) duplicadas=  66
       40-ausencia-que-abre-8-el-reconocedor-de-promesas.sh     lineas= 388 piso= 129 techo= 400 (gobierna N       ) duplicadas=  60
```
Holgura: 99 líneas en `40/3`, **12 en `40/8`** — la próxima reparación del reconocedor de ese tamaño reabre CA-18 (señalado por el desarrollador y QA; no se actuó: fuera del encargo).

## Resumen de estado
- **Puerta requerida `hooks-en-linux`: VERDE** sobre `e392fbf`. Banco 1278 · 0 · 16 cuadrado en 1294; autoprueba 106 · 0.
- Sin FAIL. 16 SKIP, todos sondas de coste/locale/Windows con motivo. 1 error de ejecución preexistente sin efecto.
- Nada se relanzó; ninguna excepción; CA-09 sin tocar. **Sin fusión ni publicación**: la decisión es del propietario.
