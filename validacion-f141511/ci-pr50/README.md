# CI sobre el candidato final — PR #50 (borrador), `hooks-en-linux`, cabeza `2b56cb4`

- Run: https://github.com/JJOVEGA/ArnesJuan/actions/runs/34891548490 · 2026-09-14T20:12:57Z → 20:15:32Z · **failure**
- PR #50: base `base/via-proporcional` (= `f387b1c`, el commit donde nació el candidato) · head `rel/via-proporcional` · **15 commits** ·
  diff de archivos **idéntico** al local `f387b1c..2b56cb4` (md5 `c7752124` en ambos). El puntero `base/…` no añade contenido al remoto.
- **Resultado del banco completo: 1273 PASS · 1 FAIL · 16 SKIP — cuadre 1290 exacto.** Los 16 SKIP son los preexistentes de coste/locale/Windows.

## El FAIL, y su atribución
`REQ-024 CA-06 promesas de equivalencia: 3 vistas y 1 enunciadas SIN acto (sujeto abierto): se queda como está|`
(sección `40-ausencia-que-abre-3-los-textos-heredados.sh`).

- Frase señalada: «Tu texto **se queda como está**», `skills/arnes-upgrade/SKILL.md:1280`, fila `MODIFICADO` de la entrada «Hacia 1.34.0».
- Introducida por **`c65ce65`** (`git log -S`), la reparación de `H-7` («presenta el conflicto, no lo resuelvas»). **No está en `f387b1c`.**
- **Preexistente respecto del delta validado:** la sección `40` corrida sobre `b3efa23` (extraído aparte) da **el mismo FAIL**. Sobre `2b56cb4`: `79 PASS · 1 FAIL`.
- Por qué no se vio antes: sobre esta rama nunca se corrió el banco completo ni la sección `40`; las corridas locales y de QA fueron `44`/`45`/`46`.
- **Se conserva y se explica; no se relanza** (instrucción del propietario). Su **clase** la fija QA; **no se repara** aquí.
