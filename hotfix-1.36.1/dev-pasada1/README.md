# Hotfix 1.36.1 — pasada correctiva de QA-032-01 (desarrollador): REQ-032 CA-15, evidencia

Árbol medido: `hotfix/1.36.1` en `48b8a0a` **con los cambios de la pasada sin commit** (sha256 en `00-entorno.txt`);
código de la entrega anterior: `9e97bd7`. Línea base: los hooks de `v1.36.0` (`f22b905`), la instalación estable.
Linux/WSL2, bash 5.3.9, jq 1.8.2. Windows/MSYS y el host: **sin medir**. Vuelta 1 de 3 del bucle dev↔QA de REQ-032.

## Qué se cambió (`70-diff-pasada.patch`)
- `hooks/lib.sh`, rama `cp|mv|install` del detector: `destino/` sale **sin marca** también si el segmento termina en
  una redirección de salida (`2>/dev/null` se lee como el operando `2`). La variable pasa a llamarse `sin_marca`.
- `hooks/lib.sh`, `arnes_destino_a_juzgar` y `_arnes_cmd_llano` (nueva): no se retira ninguna marca si el comando
  (`ARNES_CMD`) lleva `" ' \ $` acento grave `( ) { } [ ] * ? ~ ! # < ^` o un carácter de control. Sin procesos.
- Sección 48: bloque R (R1–R17, coordinadora y `qa-tester`); `CASOS_ESPERADOS` 2570 → 2686; README del banco.

## Resultados
| Archivo | Qué | Resultado |
|---|---|---|
| `20` | sección 48, candidata | 370 PASS, 0 FAIL |
| `21` | sección 48, hooks de v1.36.0 como candidata | 342/28: los 28 FAIL de M-032 de la fase 1; **todas las R `deny` en v1.36.0** |
| `22` | sección 48, hooks de `9e97bd7` como candidata | 316/**54**: todas las filas R salvo R5 y R6 (el fail-before de la pasada) |
| `10`/`11` | banco completo, candidata | 2673/**1**/12 (2686). El FAIL: REQ-021 CA-03 (c), calibración de `sonda-reloj.sh` en 38/2, que **no ejecuta hooks** |
| `12` | inventario v1.36.0 → candidata | fuera de la 48: REQ-021 CA-03 (c) PASS → FAIL; REQ-017 CA-08 (ii) 200 líneas SKIP → PASS (reloj); dos líneas de sorteo |
| `13` | inventario `9e97bd7` (final de la fase 1) → candidata | +116 de la 48; REQ-021 CA-03 (c) PASS → FAIL; REQ-017 CA-08 (ii) 6 líneas FAIL → SKIP INCONCLUSO; sorteo |
| `46` | 38/2 sola, candidata, dos veces | REQ-021 CA-03 (c) PASS y PASS (caracteriza; no desmiente el FAIL de `10`) |
| `10`, caso P1 | procesos candidata/v1.36.0 | 1/1, 1/1, 2/3: **0 añadidos** |
| `41` | reloj CA-12 (c) | 0,978×, 0,991×, 0,912× (techo 1,25×) |
| `31` | formas de CA-15 a mano, candidata frente a v1.36.0, cp/mv/install × coordinadora/`qa-tester` | iguales en todas salvo `o S docs/notas.md` (M-032); `cp S "src/a.ts"` `allow`/`allow` (F-137-14, sin tocar) |
| `32` | lo mismo con `9e97bd7` | 84 `allow` en `9e97bd7` |
| `33` | observaciones de la fase 1, re-medidas | `cp S $X` ahora `deny`/`deny` (CA-15 (c): `$`); `mv` de origen protegido y `cd src && cp S a.ts` siguen `allow` (F-137-13) |
| `50` | autoprueba | 117/0 |
| `60` | gates de `AGENTS.md` §7 | rc 0; versiones 1.36.1 |
