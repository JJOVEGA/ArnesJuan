# CI de la cabeza final publicada — PR #51, `hooks-en-linux`, cabeza `ca5ac4a` (fusionada en `main` como `cc8972c`, tag `v1.34.0`)

Run 35160183239 · https://github.com/JJOVEGA/ArnesJuan/actions/runs/35160183239 · 2026-09-16T22:58:25Z · **success** · check `hooks-en-linux=SUCCESS`.

Única corrida sobre esta cabeza, autorizada por el propietario tras la corrección documental de las notas (`c5db41b`) y sus verificaciones (QA `1fe3382`, seguridad `ca5ac4a`). **Método:** `gh run view --log` → `hooks-en-linux-log.txt`; pasos → `run.json`; recuentos por `grep` contrastados con `Resultado:`/`Autoprueba:`.

## Pasos: los nueve `success` (banco y autoprueba incluidos).
## Banco: **903 PASS · 0 FAIL · 9 SKIP — suma 912 = `CASOS_ESPERADOS` de `v1.33.2`. Cuadre exacto.** Autoprueba: **106 · 0**.

### La sonda `REQ-017 CA-08 (ii) un REQ real de 6 líneas`: **SKIP** («la sonda NO convergió: segundo mínimo / mínimo = 1,304×»)
Séptima lectura de la misma sonda sobre hooks byte a byte idénticos a `v1.33.2`: PASS 0,932× · 0,936× · 0,958× · 1,101× · 1,214× · **FAIL 1,258×** (`b520e3b`) · **SKIP** (no convergió). **Su configuración y todos sus resultados se conservan; su estabilidad no está acreditada** (decisión del propietario).

### OMITIDAS (9): Windows sin `cygpath` · `REQ-017 CA-10` (i)(ii)(iii) · `REQ-017 CA-05` (i)(ii) · `REQ-017 CA-08 (ii)` ×2 (no convergieron) · `REQ-021 CA-08 (iii)`. Todas con motivo impreso.
### ERRORES DE EJECUCIÓN (1): `mv: cannot stat …/.arnes/c2` — sección 33, preexistente, sin efecto.

## Publicación (2026-09-16T23:00Z)
- PR #51 **MERGED** por `gh pr merge --merge --match-head-commit ca5ac4a…`: `main` → **`cc8972c`**, padres `10eac80` (= `v1.33.2`) y `ca5ac4a`.
- **Árbol de `cc8972c` == árbol de `ca5ac4a`** (hash de árbol igual): lo publicado es el candidato validado.
- **Tag anotado `v1.34.0`** → `cc8972c` (tagger Juan Vega, mensaje en `../tag-v1.34.0.borrador.txt` actualizado con R-033 y las cifras finales), empujado; `git ls-remote --tags` lo confirma. Sin release de GitHub, como en 1.33.1/1.33.2.
- El tag declara `plugin.json 1.34.0`, `marketplace.json 1.34.0/1.34.0`; `AGENTS.md` del repo con la **negativa**; `arnes_version` del repo `1.33.0` (no tocado).
- **Instalación estable local: sigue en 1.33.2**; no existe caché `1.34.0`; ningún proyecto consumidor actualizado.
