# CI del candidato v1.34.0 — PR #51 (borrador, hacia `main`), `hooks-en-linux`, cabeza `b520e3b`

Run 35151689849 · https://github.com/JJOVEGA/ArnesJuan/actions/runs/35151689849 · 2026-09-16T21:19:00Z · **failure** · check `hooks-en-linux=FAILURE`.

**Corrida autorizada por el propietario** («Ejecuta el CI completo sobre el candidato final»); única corrida sobre esta cabeza. **No se relanza para buscar verde.**

**Método.** `gh run view --log` completo → `hooks-en-linux-log.txt` (1236 líneas); pasos → `run.json`. Recuentos por `grep` sobre la columna de veredicto, contrastados con la línea `Resultado:` del corredor. Comparación del mismo caso en corridas anteriores por `grep` sobre sus logs (`gh run view <id> --log`).

## PR #51 — exclusividad
base `main` = `10eac80` = `v1.33.2` · head `porte/via-proporcional-1.33.2` = `b520e3b` · borrador · `gh pr diff --name-only` **idéntico** a `git diff --name-only v1.33.2 b520e3b` (15 archivos; 0 de mecanismo). `hooks/` y `tools/` **idénticos por hash de árbol** a `v1.33.2` (`a6810ac…`, `87edb9b…`).

## Pasos
1–5 success · **6 banco: failure** · 7 autoprueba del corredor: **skipped** (no corrió por el rojo del paso 6) · 14–15 success.

## El banco: **904 PASS · 1 FAIL · 7 SKIP — suma 912 = `CASOS_ESPERADOS` de `v1.33.2`. Cuadre exacto.**

### FALLIDA (1) — sonda de coste, sobre un mecanismo idéntico a la estable
```
  FAIL  REQ-017 CA-08 (ii) un REQ real de 6 líneas: el reloj no sube más de 1,25× el de v1.32.1  1.258× > 1.250× (0.0789 s/llamada frente a 0.0627 s), y la sonda SÍ convergió (1.030×/1.192×): esto es una regresión, no ruido
```
- La sonda empareja, **en la misma corrida**, el reloj de los hooks de este árbol contra los de `v1.32.1`. **Los hooks de este árbol son byte a byte los de `v1.33.2`** (0 archivos de mecanismo en el diff; hash de árbol igual). Lo que la sonda mide como «regresión» es, por construcción, la de `v1.33.2` frente a `v1.32.1` en este runner, no la del candidato.
- **El mismo caso en corridas anteriores, con los mismos hooks:**

| Corrida | Árbol (hooks = v1.33.2) | Resultado |
|---|---|---|
| 34503259541 (`a630dc6`, 1.33.1-estabilización) | sí | PASS 0,932× |
| 34570782988 (`195ae31`, hotfix 1.33.2) | sí | PASS 1,101× |
| 34572551548 (`db53011`, hotfix 1.33.2) | sí | PASS 0,936× |
| **34572715085 (`10eac80` = `main` = `v1.33.2`)** | sí | **PASS 1,214×** |
| 34891548490 (`2b56cb4`, PR #50) | hooks de la rama larga | SKIP (techo dentro del recorrido [1,111×, 1,397×]) |
| 34923365661 (`a82db68`) | ídem | SKIP (no convergió) |
| 34926912323 (`f6912ea`) | ídem | PASS 1,241× |
| 35127982693 (`e392fbf`) | ídem | SKIP (no convergió) |
| **35151689849 (`b520e3b`, este candidato)** | **sí** | **FAIL 1,258×** |

- Sobre hooks idénticos a `v1.33.2`, la misma sonda ha dado **0,932×, 0,936×, 1,101×, 1,214× y 1,258×**. El techo 1,25× cae **dentro del recorrido observado del propio mecanismo estable**; la sonda declara «regresión, no ruido» porque su criterio de convergencia (1,030×/1,192×) se cumplió, pero la convergencia acredita estabilidad **dentro de la corrida**, no que el runner de hoy sea comparable al de las corridas anteriores.
- **Atribución:** no atribuible al candidato (mecanismo idéntico a la estable publicada). Es la misma clase de resultado que `REQ-017 CA-09` en el PR #50 (`variabilidad-no-desmiente-un-fail`): **se conserva como FAIL, no se relanza, y la decisión sobre la puerta es del propietario.**

### OMITIDAS (7), todas con motivo impreso
Windows sin `cygpath` · `REQ-017 CA-10` (i)(ii)(iii) (36 entradas no clasificables) · `REQ-017 CA-05` (i)(ii) (no se pide: acreditado en el Historial) · `REQ-021 CA-08 (iii)` (reloj 2,118×). Mismas causas que en `v1.33.2`.

### ERRORES DE EJECUCIÓN (1) — preexistente
`889: mv: cannot stat '/tmp/tmp.i31BFj1TbR/.arnes/c2'` — sección 33, sin efecto en veredictos; presente en todas las corridas anteriores.

## La autoprueba del corredor NO corrió en CI sobre `b520e3b`
El paso 7 quedó `skipped`. Sobre `404e044` la corrió QA en local (106 · 0); `b520e3b` no toca ningún archivo de `tests/` (0 en el diff), así que `CA-18` y el resto no pueden haber cambiado de resultado, **pero eso es inferencia sobre el diff, no una corrida en CI**.

## Estado
- **Puerta requerida de `main`: ROJA** por `REQ-017 CA-08 (ii)`, sonda de coste sobre hooks idénticos a `v1.33.2`.
- Banco cuadrado (912), 0 FAIL funcionales, 7 SKIP con motivo, autoprueba no ejecutada en CI.
- **Impedimento concreto para fusionar por la vía delegada:** el check requerido está en rojo, y la única forma de ponerlo en verde sin tocar la sonda es otra corrida — que el propietario no ha autorizado y que este documento no recomienda «para buscar verde». **La decisión es del propietario.**
