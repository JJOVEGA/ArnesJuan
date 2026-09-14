# Diagnóstico completo de la corrida del banco en CI — PR #50, `hooks-en-linux`, cabeza `2b56cb4`

Run 34891548490 · 2026-09-14 20:12:57Z → 20:15:32Z · **failure** · log fallido: `hooks-en-linux-log-failed.txt` (1404 líneas, 24 encabezados de sección).
Recuento del log: **PASS 1273 · FAIL 1 · SKIP 16 · suma 1290** — coincide con lo que declara el corredor. **Es la primera corrida del banco entero sobre esta rama** (todas las anteriores fueron subconjuntos 44/45/46; 40 nunca).

## 1. Pruebas FALLIDAS (1)
```
  FAIL  REQ-024 CA-06 promesas de equivalencia: 3 vistas y 1 enunciadas SIN acto (sujeto abierto): se queda como está|
```
- Sección `40-ausencia-que-abre-3-los-textos-heredados.sh`. Frase señalada: «Tu texto **se queda como está**», `skills/arnes-upgrade/SKILL.md:1280`.
- Introducida por `c65ce65` (reparación de `H-7`). **Preexistente al delta validado** (`b3efa23` da el mismo FAIL; `f387b1c` y `a80a1cb` PASS — reproducido por QA revisión por revisión).
- Clase fijada por QA: **`instrumento`** (alcance del reconocedor por cadena sobre un apartado que ahora contiene una tabla de migración; la frase no promete equivalencia con la versión heredada y su acto está nombrado). **Bloquea como PUERTA (§7), no como hallazgo.**

## 2. Pruebas OMITIDAS (16), todas con motivo declarado por el propio caso
| # | Caso | Causa |
|---|---|---|
| 1 | ruta estilo Windows con backslashes -> deny | entorno: caso sólo de Windows |
| 2 | REQ-017 CA-10 (i) fuera del dominio este árbol decide siempre lo mismo, y lo mismo en los dos locales | locale/clasificabilidad (REQ-017 CA-10): la heredada tampoco decide de forma única bajo LC_ALL=C |
| 3 | REQ-017 CA-10 (ii) ...y esa decisión es la del ORÁCULO: la heredada bajo LC_ALL=C | locale/clasificabilidad (REQ-017 CA-10): la heredada tampoco decide de forma única bajo LC_ALL=C |
| 4 | REQ-017 CA-10 (iii) fail-before: la heredada bajo el locale del entorno NO cumple (i) o (ii), y se registra si | locale/clasificabilidad (REQ-017 CA-10): la heredada tampoco decide de forma única bajo LC_ALL=C |
| 5 | REQ-017 CA-03 el escáner no crece más que linealmente: doblar la línea no cuadruplica | abstención de medición de coste: el techo cae dentro del ruido de la corrida |
| 6 | REQ-017 CA-09 la pared de los 60 s de este árbol NO es menor que la de v1.32.1, pareado en la misma corrida | abstención de medición de coste: el techo cae dentro del ruido de la corrida |
| 7 | REQ-017 CA-05 (i) la ruta crítica cuesta no más de 0,250× lo de v1.32.1 | acreditación previa en el Historial, no puerta de cada PR (REQ-017 CA-05) |
| 8 | REQ-017 CA-05 (ii) la comparación no se compra dejando de probar | acreditación previa en el Historial, no puerta de cada PR (REQ-017 CA-05) |
| 9 | REQ-017 CA-08 (ii) un REQ real de 6 líneas: el reloj no sube más de 1,25× el de v1.32.1 | abstención de medición de coste: el techo cae dentro del ruido de la corrida |
| 10 | REQ-017 CA-08 (ii) una cabecera de 200 líneas: el reloj no sube más de 1,25× el de v1.32.1 | abstención de medición de coste: el techo cae dentro del ruido de la corrida |
| 11 | REQ-021 CA-08 (iii) calibrar sonda-reloj.sh no cuesta más de 6× una medición suya con los MISMOS mandos | abstención de medición de coste: el techo cae dentro del ruido de la corrida |
| 12 | REQ-023 CA-12 la cola cuenta exactamente lo mismo que la versión heredada | precondición de atribuibilidad (REQ-023 CA-12): otro REQ cambió el lector a propósito |
| 13 | REQ-023 CA-09 (iii) la guarda no empeora el orden de crecimiento de arnes_norm_clave: relación emparejada cont | abstención de medición de coste: el techo cae dentro del ruido de la corrida |
| 14 | REQ-023 CA-09 (iii) la guarda no empeora el orden de crecimiento de arnes_campo_linea: relación emparejada con | abstención de medición de coste: el techo cae dentro del ruido de la corrida |
| 15 | 46/11 CA-14 (anti-vacuidad) [AGENTS.md] toda sede DETECTADA queda interpretada, o IDENTIFICADA con su motivo y | sedes mudas de CA-14 (46/11): 2 de 4, identificadas y sin acreditar |
| 16 | 46/11 CA-14 (anti-vacuidad) [templates/AGENTS.md.tpl] toda sede DETECTADA queda interpretada, o IDENTIFICADA c | sedes mudas de CA-14 (46/11): 2 de 4, identificadas y sin acreditar |

**Por causa:** 7 abstenciones de medición de coste · 3 de locale/clasificabilidad · 2 sedes mudas de CA-14 · 2 acreditaciones previas · 1 atribuibilidad · 1 sólo-Windows. **Ninguna es un fallo enmascarado**: cada SKIP publica su motivo, y las de coste son la abstención contratada («abstenerse por entorno, fallar por defecto»). Las 4 que no aparecían en corridas locales anteriores (CA-10 ×3, CA-09) son dependientes del runner (locale y ruido).

## 3. ERRORES DE EJECUCIÓN (1) — no son veredictos
```
723:mv: cannot stat '/tmp/tmp.WldUhGoxHH/.arnes/c2': No such file or directory
```
- Ocurre dentro de la sección que contiene los casos `REQ-010 CA-13` y `REQ-010 CA-02` (`33-acento-y-clave-1-normalizacion.sh`), entre dos PASS. **No cambia ningún veredicto** —los casos vecinos pasan— pero es un comando del propio banco que falla y **el corredor no lo cuenta**: no aparece como FAIL, SKIP ni aviso.
- Mecanismo: en `33-acento-y-clave-1-normalizacion.sh:77` el fixture reescribe `.arnes/config.json` con `python3 … || jq … > .arnes/c2 && mv …`; cuando `python3` tiene éxito la rama `jq` no corre, `c2` no llega a existir y el `mv` posterior falla con `cannot stat`. El fixture queda igualmente bien escrito por la rama `python3`, por eso los casos vecinos pasan.
- Origen en el banco: `tests/escenarios/hooks/secciones/33-acento-y-clave-1-normalizacion.sh:77:python3 - "$L33/.arnes/config.json" <<'PY' 2>/dev/null || jq '.esta`. Presente en `f387b1c`: **1** ocurrencia(s) en la misma sección — **preexistente**, no del candidato (el candidato no toca `tests/`).
- Clase: no fijada aquí; corresponde a QA (`instrumento` probable: un fixture del banco, no una protección). Se registra sin reparar.

## 4. Otros
- Avisos del corredor fuera de veredictos: **ninguno**. El único `##[error]` es el exit code 1 del paso, consecuencia del FAIL.
- Cuadre 1290 exacto. No se relanzó ninguna corrida.
