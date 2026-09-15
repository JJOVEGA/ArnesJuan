# Banco completo en CI — PR #50, `hooks-en-linux`, cabeza `f6912ea` (contenido `9dac46f`)

Run 34926912323 · https://github.com/JJOVEGA/ArnesJuan/actions/runs/34926912323 · 2026-09-15T03:56:50Z → 03:59:39Z · **failure**.

**Corrida autorizada por el propietario** después de la reparación de `I-7` («estamos validando código nuevo, no repitiendo el mismo candidato para buscar verde»). Es la **única** corrida sobre esta cabeza; no se relanza.

**Método.** `gh run view 34926912323 --log` completo → `hooks-en-linux-log.txt` (1833 líneas; el de `a82db68` sólo tenía `--log-failed`, 1404 líneas). Metadatos y pasos → `run.json`. Recuentos por `grep` sobre la columna de veredicto (`PASS|FAIL|SKIP` tras la marca de tiempo), contrastados con la línea `Resultado:` que imprime el corredor. Identificadores comprobados uno a uno (disciplina `I-6`).

## PR #50 — exclusividad verificada
- base `base/via-proporcional` = `f387b1c` (sin cambios) · head `rel/via-proporcional` = `f6912ea` · borrador.
- `gh pr diff 50 --name-only` **idéntico** a `git diff --name-only f387b1c..f6912ea`.
- Push `a82db68..f6912ea` en fast-forward, sin force: `eea46ad` (I-5), `0b8daf9` (QA), `6732e94` (R-038), `9dac46f` (I-7), `69b01dd` (QA), `f6912ea` (R-039).

## El banco (paso 6): **1280 PASS · 0 FAIL · 13 SKIP — suma 1293 = `CASOS_ESPERADOS` 1293. Cuadre exacto.**
Línea del corredor: `Resultado: 1280 PASS, 0 FAIL, 13 SKIP — ninguna causa común: cada uno con su motivo`.
Evolución del cuadre en el PR: 1290 (`2b56cb4`) → 1291 (`a82db68`) → 1293 (`f6912ea`; +1 I-5, +1 I-7).

### Identificadores esperados de `REQ-024 CA-06` — presentes, 25 líneas, todas PASS
```
  PASS  REQ-024 CA-06 las 2 promesas de equivalencia del apartado llevan el ACTO dentro de la promesa (2 con acto, 0 de sujeto abierto; …)
  PASS  REQ-024 CA-06 discriminante: el reconocedor sigue mordiendo lo que debe y suelta lo que no  (inyectada SIN acto -> 1 sin acto, muerde; …)
  PASS  REQ-024 CA-06 las 7 regresiones conocidas de I-5 siguen mordiendo, y los controles positivos siguen pasando  (7 de 7 inyectadas dan «sin acto» >= 1 …)
  PASS  REQ-024 CA-06 los 6 falsos positivos de I-7 ya no muerden, y el reconocedor no se quedó mudo  (6 de 6 dan «0 0» —fechas ISO, números de 3 cifras y la anterioridad dentro de «bastantes»…)
```
Los dos casos nuevos (I-5, I-7) **se ejecutaron en CI** y pasaron. El FAIL histórico «se queda como está»: 0 ocurrencias.

### `REQ-017 CA-09` (la sonda de coste que dio FAIL en `a82db68`) — **PASS en esta corrida**
```
  PASS  REQ-017 CA-09 la pared de los 60 s de este árbol NO es menor que la de v1.32.1, pareado en la misma corrida  el PEOR de este árbol vale 1.563× el MEJOR de v1.32.1 medido EN ESTA MISMA corrida (>= 1,000×; los rangos no se solapan, así que la dirección no es ruido). …
```
- En `a82db68` el mismo caso dio **FAIL** con **0,976×** (mejor de este árbol / peor de `v1.32.1`); en `2b56cb4`, **SKIP** por solapamiento. Entre las tres corridas **`hooks/` y `tools/` no cambiaron** (0 rutas de mecanismo en `f387b1c..f6912ea`).
- **Este PASS no desmiente el FAIL anterior**: es la misma sonda sobre el mismo mecanismo dando 0,976× y 1,563× en dos corridas; eso es evidencia de la **variabilidad de la sonda en el runner**, no de que el árbol mejorara. El FAIL de `a82db68` se conserva en `../ci-pr50-a82db68/`. La decisión sobre ese gate sigue siendo del propietario y aparte; aquí sólo se registra el resultado de esta corrida.

### OMITIDAS: 15 → 13, todas sondas de coste/locale/Windows
Salen de SKIP (ahora PASS, porque 0 FAIL): `REQ-017 CA-03 fail-before: la sonda distingue el árbol cuadrático`; `REQ-017 CA-08 (ii) un REQ real de 6 líneas…`; `REQ-017 CA-08 (ii) una cabecera de 200 líneas…`.
Entra en SKIP (antes PASS): `REQ-023 CA-09 (iii) … arnes_norm_clave: relación emparejada contra v1.33.0` (dispersión 0,494× ≥ margen 0,097×).
Las 13 con su causa, tal como las imprime el corredor:
```
  SKIP  ruta estilo Windows con backslashes -> deny  (sin cygpath: caso solo de Windows)
  SKIP  REQ-017 CA-10 (i)(ii)(iii)  36 entradas NO son clasificables: la heredada tampoco publica una decisión  [3 casos]
  SKIP  REQ-017 CA-03 el escáner no crece más que linealmente  el techo 2.600× cae DENTRO de la banda
  SKIP  REQ-017 CA-05 (i)(ii)  no se pide: evidencia acreditada en el Historial de REQ-017 (0,125×)  [2 casos]
  SKIP  REQ-021 CA-08 (iii) calibrar sonda-reloj.sh no cuesta más de 6×  reloj 1.152×
  SKIP  REQ-023 CA-12 la cola cuenta exactamente lo mismo que la versión heredada  la PRECONDICIÓN DE ATRIBUIBILIDAD no se cumple (el lector difiere)
  SKIP  REQ-023 CA-09 (iii) arnes_norm_clave  dispersión 0.494× >= margen 0.097×
  SKIP  REQ-023 CA-09 (iii) arnes_campo_linea  dispersión 0.243× >= margen 0.113×
  SKIP  46/11 CA-14 (anti-vacuidad) [AGENTS.md] / [templates/AGENTS.md.tpl]  2 de 4 sedes DETECTADAS sin interpretar  [2 casos]
```

### ERRORES DE EJECUCIÓN (1) — el mismo, preexistente
```
947: mv: cannot stat '/tmp/tmp.GlJ9DLLDyO/.arnes/c2': No such file or directory
```
Sección 33, fixture `python3 … || jq … > c2 && mv c2 …` (precedencia `(A || B) && C`). Sin efecto en veredictos. Fuera de alcance por instrucción.

## El rojo del job está en OTRO paso: la autoprueba del corredor (paso 7) — **105 PASS · 1 FAIL**
```
  FAIL  CA-18 ningún archivo excede max(N, piso × k) — con N=400 y k=1,25  esperado=<> obtenido=< 40-ausencia-que-abre-3-los-textos-heredados.sh(554 líneas, techo 400)>
       40-ausencia-que-abre-3-los-textos-heredados.sh           lineas= 554 piso=  78 techo= 400 (gobierna N       ) duplicadas=  81
```
**Qué exige `REQ-014 CA-18 (i)`:** para cada archivo de `secciones/`, `líneas(f) ≤ max(N, piso(f) × k)` con N = 400 y k = 1,25. El piso declarado de `40/3` es 78 (31 preámbulo + 16 maquinaria duplicada + 31 bloque indivisible), así que `piso × k` = 98 y **gobierna N = 400**. El archivo mide **554**.

**Atribución — introducido por la cadena I-5/I-7, y ya excedía en `eea46ad`:**

| Cabeza | Líneas de `40/3` | ≤ 400 |
|---|---|---|
| `f387b1c` (base del PR) | 325 | sí |
| `a82db68` (última corrida previa) | 382 | sí |
| `eea46ad` (I-5: +126/−31) | **477** | **no** |
| `9dac46f` (I-7: +84/−7) | **554** | **no** |

- **Por qué no se vio antes:** la autoprueba del corredor es el **paso 7** del job y en las dos corridas previas del PR quedó **`skipped`** porque el paso 6 (banco) falló antes (`CA-06` en `2b56cb4`, `CA-09` en `a82db68`). Ésta es la **primera corrida del PR en que la autoprueba llegó a ejecutarse**. Y en local **nadie la corrió**: no forma parte de las tres quality gates del manifiesto (que QA reportó 3/3), y ni el desarrollador ni QA ni seguridad la mencionan en sus entregas sobre `eea46ad` y `9dac46f`. El banco `README.md:31` la lista como comando local; no está escrita como deber previo al push.
- **Es determinista**, no ruido: cuenta líneas de un archivo del árbol.
- **Qué NO es la salida:** `REQ-014 CA-18 (ii)` dice que el techo «**no se resuelve subiendo el techo en silencio**» y que la maquinaria compartida «se duplica o se sube al corredor»; subirla al corredor es **cambio de mecanismo** (analista + auditor). La vía prevista por el propio criterio es **partir la sección**: un archivo nuevo `40-ausencia-que-abre-N-<slug>.sh` con su propio `PISO_AUTONOMO_SECCION` derivado (≈ 78 líneas duplicadas: preámbulo + `mira40c`), sin `source` entre secciones (CA-19), y `CASOS_ESPERADOS_SECCION` repartido; 554 + ~78 ≈ 632 líneas en dos archivos de ≈ 316, ambos bajo 400. Es trabajo del `desarrollador` sobre `tests/` (`critico` en §6 → QA y seguridad), y **no está autorizado**: se presenta como decisión pendiente.

## Resumen de estado
- **Banco: verde y cuadrado (1293)**; `CA-06` con sus cuatro casos nuevos ejecutados; `CA-09` de REQ-017 PASS esta vez (FAIL previo conservado, no desmentido).
- **Puerta requerida `hooks-en-linux`: ROJA** por `REQ-014 CA-18` en la autoprueba del corredor — **introducido por la reparación de I-5 y agravado por la de I-7**, no por el ruido del runner.
- Nada se relanza, nada se repara, ninguna excepción. Sin fusión ni publicación.
