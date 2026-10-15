# Hotfix 1.36.1 — pasada correctiva, el enlace duro (P-032-4 (B)): REQ-032, evidencia del desarrollador

Árbol medido: `hotfix/1.36.1` en `759ff50` (la pasada de CA-15 comiteada) **más el enlace duro sin commit**
(sha256 en `00-entorno.txt`). Línea base: hooks de `v1.36.0` (`f22b905`). Misma vuelta 1 de 3. Linux/WSL2,
bash 5.3.9, jq 1.8.2, GNU find. Windows/MSYS y el host: **sin medir**.

## Qué se cambió (`70-diff-desde-759ff50.patch`; `hooks/` con `Edit`)
- `hooks/lib.sh`, `_arnes_un_solo_enlace` (nueva) y una línea en `arnes_destino_a_juzgar`: tras comprobar que el destino
  existe y es archivo regular, la marca sólo se retira con `find <archivo> -maxdepth 0 -type f -links 1 -print` devolviendo
  la ruta; memorizado por archivo; ante cualquier fallo, la marca se queda (decisión de v1.36.0).
- Sección 48: bloque H y la sonda P1 (ahora cuenta `find` y `stat`); `CASOS_ESPERADOS` 2686 → 2722; README del banco.

## Resultados
| Archivo | Qué | Resultado |
|---|---|---|
| `20` | sección 48, candidata | 406 PASS, 0 FAIL |
| `21` | sección 48, hooks de v1.36.0 como candidata | 378/28: los 28 de M-032; H1–H3 `deny` en v1.36.0 |
| `22` | sección 48, hooks de `759ff50` como candidata | 388/**18**: exactamente las 18 filas H (allow en `759ff50`) |
| `20`, caso P1 | procesos candidata/v1.36.0 (y `759ff50` en `22`) | `ls -la` 1/1, `npm run build` 1/1 (**0 añadidos**); F3 3/3 (`759ff50`: 2); H3 4/3 (`759ff50`: 2). **+1 `find` en la rama** |
| `41` | reloj CA-12 (c), candidata/v1.36.0 | 1,010×, 1,008×, 1,051× (techo 1,25×) |
| `31` | formas de CA-15, candidata frente a `759ff50` | ninguna diferencia |
| `10`/`11` | banco completo | 2707/**2**/13 (2722): REQ-017 CA-08 (ii) (reloj contra v1.32.1, 1,285×–1,451×) y REQ-021 CA-04.1 (sonda de descendencia, 38/3, no ejecuta hooks) |
| `12`, `13` | inventario frente a v1.36.0 y frente a `759ff50` | fuera de la 48 sólo cambian casos de reloj e instrumento (REQ-017 CA-03, CA-08 (ii); REQ-021 CA-03 (c), CA-04.1) y sorteo; ninguna decisión de una puerta |
| `46` | 38/3 sola, dos veces | REQ-021 CA-04.1 PASS y PASS (caracteriza; no desmiente el FAIL de `10`) |
| `50` | autoprueba | 117/0 |
| `60` | gates de `AGENTS.md` §7 | rc 0; versión 1.36.1 |
