# CI del candidato v1.34.0 corregido — PR #51 (borrador, hacia `main`), `hooks-en-linux`, cabeza `a8cbb29`

Run 35158767267 · https://github.com/JJOVEGA/ArnesJuan/actions/runs/35158767267 · 2026-09-16T22:39:57Z · **success** · check `hooks-en-linux=SUCCESS`.

**Corrida autorizada por el propietario** sobre el candidato corregido («valida contenido nuevo, no es un reintento del mismo SHA para buscar verde»): `a8cbb29` = `b520e3b` + `8bd5e33` (H-P1) + `cf88b4e` (QA) + `a8cbb29` (seguridad). Única corrida sobre esta cabeza.

**Método.** `gh run view --log` completo → `hooks-en-linux-log.txt` (1401 líneas); pasos → `run.json`. Recuentos por `grep` contrastados con `Resultado:` y `Autoprueba:` del corredor.

## PR #51 — exclusividad
base `main` = `10eac80` = `v1.33.2` · head `a8cbb29` · borrador · `gh pr diff --name-only` **idéntico** a `git diff --name-only v1.33.2 a8cbb29`; 0 rutas de mecanismo; push en fast-forward sin force.

## Los nueve pasos: todos `success`. Por primera vez en el PR #51 corrió la autoprueba del corredor.

## Banco (paso 6): **904 PASS · 0 FAIL · 8 SKIP — suma 912 = `CASOS_ESPERADOS` de `v1.33.2`. Cuadre exacto.**
`Resultado: 904 PASS, 0 FAIL, 8 SKIP — ninguna causa común: cada uno con su motivo`.

### La sonda `REQ-017 CA-08 (ii) un REQ real de 6 líneas` — PASS 0,958× esta vez
```
  PASS  REQ-017 CA-08 (ii) un REQ real de 6 líneas: el reloj no sube más de 1,25× el de v1.32.1  0.958× (0.0612 s/llamada frente a 0.0638 s; convergencia 1.139×/1.088×)
```
**El FAIL de `b520e3b` (1,258×, «regresión, no ruido») se conserva en `../ci-pr51-b520e3b/` y no queda desmentido por este PASS.** Los hooks son byte a byte los mismos en ambas cabezas (idénticos a `v1.33.2`); la misma sonda ha dado ahora, sobre el mismo mecanismo, 0,932×, 0,936×, 0,958×, 1,101×, 1,214× y 1,258×. La sonda no se modificó ni su techo (instrucción). El tratamiento de esa sonda como puerta es una decisión aparte del propietario.

### OMITIDAS (8), con motivo
Windows sin `cygpath` · `REQ-017 CA-10` (i)(ii)(iii) · `REQ-017 CA-05` (i)(ii) · **`REQ-017 CA-08 (ii) una cabecera de 200 líneas`** (no convergió; en `b520e3b` fue PASS) · `REQ-021 CA-08 (iii)` (reloj 1,233×). Todas sondas de coste/locale/Windows.

### ERRORES DE EJECUCIÓN (1) — preexistente
`889: mv: cannot stat '…/.arnes/c2'` — sección 33, sin efecto, presente en todas las corridas anteriores.

## Autoprueba del corredor (paso 7): **106 PASS · 0 FAIL** — coincide con la corrida local de la coordinadora sobre `8bd5e33` (`../autoprueba-8bd5e33.txt`).

## Estado
- **Puerta requerida de `main`: VERDE sobre `a8cbb29`.** Banco cuadrado, 0 FAIL, autoprueba en verde, 8 SKIP con motivo, 1 error de ejecución preexistente sin efecto.
- `SEC-091` (las notas afirman que el banco de `v1.33.2` certifica esto por identidad de mecanismo) queda **superado en los hechos** por esta corrida —hay banco sobre esta cabeza— pero **la frase sigue escrita** en las notas: se conserva como hallazgo de texto para decisión del propietario.
- Sin fusión, sin tag, sin publicación, sin cambios en la instalación estable.
