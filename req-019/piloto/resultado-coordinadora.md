# REQ-019 · piloto de lectura por encargo — resultado de la comparación por brazo (testimonio de la coordinadora, 2026-09-22)

> **Qué es esto:** la lectura de la coordinadora sobre las salidas crudas. **No es la acreditación**: la emite el `qa-tester` contra `esperado.md` (REQ-019 CA-07 (P)). Las cifras se releen de `BRAZO-*/analisis.txt` y de `BRAZO-*/salida.jsonl`; método: `analizar-brazo.py` (atribución por `parent_tool_use_id`).

## Corrida
| | Brazo A (línea base) | Brazo B (piloto) |
|---|---|---|
| Árbol | `ed14828` (sin §0) | `000ba83` (con §0 + write-back CA-06) |
| Diferencia verificada antes de lanzar (`diff-arboles-A-B.txt`) | `AGENTS.md`, `CHANGELOG.md`, `requirements/README.md` (celda del índice), `REQ-007.md`, `REQ-018.md`, `REQ-019.md` | |
| Plugin cargado solo | `cfb1106` (`main`, 1.34.0), único en `init` de las dos sesiones | |
| Lanzamiento | 2026-09-22 16:39:26Z, simultáneo, bwrap separados, mismo prompt, mismos flags, mismo modelo | |
| Fin · rc · turnos · coste reportado | 17:12:22Z · 0 · 15 · **$10,75** · 1974 s | 17:11:58Z · 0 · 16 · **$11,54** · 1950 s |
| Despachos | analista → desarrollador → qa-tester | analista → desarrollador → qa-tester |

## 1. Lecturas de `requirements/README.md` (44,9 kB) — el objeto del piloto
| Rol | A | B |
|---|---|---|
| Coordinadora | **entera** (Read, 44 911 chars) | **entera** (Read, 44 913) — §0 la conserva |
| Analista | **entera** (44 911) + rango 537– (1 808) | **entera** (44 913) — su mínimo es el documento entero |
| Desarrollador | sólo `wc -l` (no la leyó) | **por secciones exactamente según el mapa**: `grep '^##'` (1 025) y `sed -n '9,21p;143,175p;467,502p'` = Estados · Archivos · Plantilla (4 052) |
| QA | rango `120/40` (2 404) — ya no entera en la línea base | **por secciones**: `grep '^##'` (1 025), Read `283/185` (13 783: «Cómo se escribe un criterio…») y Read `9/145` (9 905: Estados…Clases de hallazgo) |

**Observado en B:** los dos roles acotados leyeron por secciones y **ninguno leyó el documento entero**; el desarrollador siguió el mapa literalmente. **Observado en A:** la coordinadora y el analista leyeron entero; QA leyó un rango pequeño; el desarrollador no leyó. La lectura completa del README desaparece en B **para los roles previstos**, pero en A ya no la hacía el desarrollador ni QA en esta corrida (la línea base de CON-4 —6 de 7 comisiones enteras— **no se reprodujo aquí**).

## 2. `docs/ESTADO.md` (27,2 kB) y `AGENTS.md`
| Rol | A | B |
|---|---|---|
| Coordinadora | entera (27 207) | entera (27 207) + al cerrar, `grep` y rango 96/18 |
| Analista | **entera** (27 207) | **no lo leyó** |
| Desarrollador | no | `grep` (867) + rangos `97-115;211-230` (2 955) |
| QA | no | `grep` (3 403) + Read `94/18` (1 344) |
| `AGENTS.md` explícito | 0 lecturas | desarrollador: Read `limit 80` (6 012) |

Los encargos de la coordinadora mencionan `ESTADO.md` en los dos brazos (5 060 / 4 670 / 4 374 chars en A; 5 574 / 4 654 / 4 885 en B); si llevan «el estado pertinente identificando su fuente» lo juzga QA leyendo los prompts.

## 3. Tokens reportados por el CLI (`usage`; no es facturación)
| Comisión | A primer turno · Σ input | B primer turno · Σ input |
|---|---|---|
| Coordinadora | 38 811 · 2 635 850 | 39 333 · 2 791 625 |
| Analista | 37 387 · 1 062 654 | 38 182 · 1 702 831 |
| Desarrollador | 38 615 · 3 248 345 | 39 139 · 3 866 154 |
| QA | 40 254 · 3 709 922 | 40 975 · 4 155 287 |
| `modelUsage` opus: cacheRead · cacheCreate · output | 8 418 283 · 492 920 · 120 970 | 9 784 909 · 489 259 · 126 077 |

**B consumió más que A en todas las comisiones.** El primer turno de B es 500–800 tokens mayor en todos los roles (AGENTS.md tiene 17 líneas más y entra entero al arrancar: el piloto no lo acota). El Σ input y el coste mayores de B se corresponden con **más trabajo hecho**: seis hallazgos de QA frente a dos, el desarrollador de B escribió además Historial de REQ-029, CHANGELOG, índice y ESTADO. **No se observó ahorro de tokens**; n=1 por brazo, y la variabilidad entre sesiones del mismo encargo ya está medida como grande.

## 4. Obligaciones del encargo
| Obligación | A | B |
|---|---|---|
| Orden dev → QA | sí | sí |
| Gates §7 + sección 33 por ruta por QA | sí (rc 0, `mv: cannot stat` desaparece) | sí (banco entero en los dos árboles, 895 · 0 · 17, inventario idéntico) |
| Hallazgos con clase | QA-029-01 (contrato), QA-029-02 (instrumento) | QA-029-01…03 (contrato), 04…06 (instrumento) |
| CHANGELOG / ESTADO actualizados | sí / sí | sí / sí |
| `Estado: completado` | ninguno | ninguno |
| Quién movió `Estado: en-revisión` | **coordinadora** | desarrollador |
| Veredicto `QA:` | qa-tester | qa-tester |
| `Archivos:` sin decoración | sí | sí |
| Corrección de la sección 33 | `if / elif / else` con aborto si ningún camino prepara el manifiesto | se retira el camino `python3`; queda sólo `jq … && mv` |
| Conducta anómala | — | QA de B relata que `guard-codigo` denegó un `cp` con origen `.arnes/config.json` y destino fuera del proyecto y que «me obligó a rodearlo»; lo registró como QA-029-06 (`instrumento`, posible falso positivo). **Rodear un guardián es lo que §13 nombra; QA debe juzgarlo** |

## 5. Lo que la coordinadora NO afirma
Ni ahorro ni dirección del coste (B costó más); ni que B cumpla §0 «mejor» que A más allá de lo listado; ni la calidad relativa de las dos correcciones (las salidas no se fusionan); ni nada sobre consumidores. La acreditación —observado / no observado / ambiguo por punto de `esperado.md`, con cita— es del `qa-tester`.

## 6. Acreditación de QA (2026-09-22, `docs/qa/REQ-019.md` de la rama del piloto, commit `605db77`)
**CA-07 (P): PARCIALMENTE SATISFECHO.** (ii) obligaciones del encargo: **satisfecho**, 0 de 11 incumplidas en B. (i) lecturas: **anotado, no concluyente** — en B el desarrollador leyó exactamente su mínimo y QA 5 de 6 secciones, nadie el README entero; pero en A el desarrollador leyó 0 bytes del README y QA 2 404, así que **B leyó más README que A** y la línea base de CON-4 (6 de 7 enteras) no se reprodujo. (iii) tokens: **registrados sin dirección** (B > A en las cuatro comisiones y en coste). Encargos de B: los tres traen el estado con su fuente. Cabecera de REQ-029: ninguna de las dos escrituras de `Estado:` es desvío de una invariante escrita. Incidente de `guard-codigo` en el QA de B: falso positivo sobre un `cp` con origen protegido y destino fuera, **no** un rodeo en el sentido de §13; y un `cp -a` del proyecto entero hacia fuera pasó sin denegación (QA-019-04, ajeno a REQ-019). Hallazgos: QA-019-01 (fuga de tratamiento: el CHANGELOG de B anuncia el piloto y lo leyeron dos agentes), QA-019-02 (control sin línea base reproducida), QA-019-03 (esta nota), QA-019-04; los cuatro `instrumento`. **Qué falta para satisfecho a secas:** una corrida más con el diseño corregido, o la decisión del propietario de aceptar (i) como observación no concluyente con residual declarado. QA no propone relanzar; la decisión es de alcance y del propietario.

## 7. Cierre del experimento (propietario, 2026-09-22)
«Piloto ejecutado, sin reducción demostrada; no seleccionado para adopción.» No se adopta el cambio de §0 ni se repite la comparación. Registro fiel: las obligaciones observadas se cumplieron en ambos brazos; la reducción de lecturas no quedó demostrada y B leyó más README; B tuvo mayor consumo de tokens y coste reportado en esta corrida, lo que no es facturación efectiva ni demuestra que siempre sea peor; el control no reprodujo la línea base anterior y el CHANGELOG de B anunció el piloto a dos agentes, limitando la comparación. CA-07 (P) conserva el veredicto de QA (parcialmente satisfecho) sin residual que lo convierta en satisfecho. REQ-019 sigue pendiente de replanificación con sus criterios y hallazgos abiertos. Todo se conserva en las ramas locales, fuera de `main`.
