# REQ-019 · piloto de lectura por encargo — RESULTADO ESPERADO, escrito antes de ejecutar (2026-09-22)

**Diseño que se ejecuta:** `docs/arnes/req-019-piloto-comparacion.md` de la rama `feat/req-019-piloto-lectura`. **Encargo:** el de `prompt.txt` (defecto real y preexistente de la sección 33 del banco, visible en el CI de `main` `cfb1106`: `mv: cannot stat …/.arnes/c2`). **Mismo prompt, mismo plugin (`origin/main` = `cfb1106`), mismos flags, mismo modelo, misma fecha, entornos bwrap separados.**

| | Brazo A (línea base) | Brazo B (piloto) |
|---|---|---|
| Árbol del proyecto | commit **padre** del que aplica §0 (rama reconciliada, sin el bloque) | commit que aplica §0 (bloque «Y para un SUBAGENTE…» + write-back CA-06) |
| Diferencia declarada entre árboles | `AGENTS.md` §0 · `requirements/REQ-007.md` · `requirements/REQ-018.md` · `requirements/REQ-019.md` · `CHANGELOG.md` (una entrada). Se verifica con `diff -rq` antes de lanzar y se guarda | |

## Qué se espera observar (por `parent_tool_use_id`)
1. **Lecturas de `requirements/README.md`** — A: al menos un subagente lo lee **entero** (línea base medida: 6 de 7 comisiones en CON-4). B: el `desarrollador` y el `qa-tester` lo leen **por secciones** (Read con `offset`/`limit`, o `grep`/`sed -n` sobre encabezados) y **no** entero; el `analista-requerimientos`, si se despacha, lo lee entero (su mínimo es el documento entero, por contrato).
2. **Lecturas de `docs/ESTADO.md`** — A: una por comisión (línea base). B: los subagentes **sólo si** el encargo de la coordinadora no trae el estado con su fuente; la coordinadora lo lee igual en los dos brazos.
3. **`AGENTS.md`** — se lee igual en los dos brazos (el piloto no lo acota); 0 lecturas explícitas es coherente con la línea base (entra en contexto al arrancar).
4. **Obligaciones del encargo, iguales en los dos brazos:** orden desarrollador → QA; QA corre `bash -n` sobre el archivo y la sección 33 del banco por ruta; si QA halla algo, lo registra con clase; `CHANGELOG.md` actualizado; ningún `Estado: completado` sin veredicto; `Archivos:` sin decoración si se toca o crea un REQ; ninguna escritura fuera del proyecto.
5. **Tokens reportados por el CLI**: primer turno por comisión, Σ input por comisión, `total_cost_usd`. **Se reportan; no se promete dirección ni porcentaje.** Con n=1 por brazo, cualquier diferencia es **lo observado en estas corridas**, no una tasa.
6. **Cumplimiento de §0 nuevo en B**: la coordinadora conserva las tres lecturas del ritual; los subagentes leen las secciones de su mínimo y, si necesitan más, el documento (permitido por el texto: «mínimo orientativo, no permiso acotado»).

## Cómo se anota
Cada punto: **observado / no observado / ambiguo**, con cita del `stream-json` (id del `tool_use`, rol, archivo, `offset`/`limit`, tamaño del resultado en caracteres). Los tokens, del campo `usage` de cada mensaje `assistant` y del evento `result`. **Quién acredita:** el `qa-tester` (no quien lanza); este documento y el análisis de la coordinadora son testimonio.

## Qué no acredita
Ningún porcentaje de ahorro; ningún determinismo (n=1); nada sobre proyectos consumidores (la plantilla no cambia); nada sobre el reparto documental ni el techo 0,72×; ni que el defecto de la sección 33 quede corregido en `main` (las salidas de los brazos no se fusionan).

---
**Nota fechada (2026-09-22, tras la acreditación de QA; el texto de arriba no se reescribe):** QA-019-03 — la fila «Diferencia declarada entre árboles» enumera cinco archivos y el `diff -rq` previo al lanzamiento (`diff-arboles-A-B.txt`) registró **seis**: falta `requirements/README.md`, cuyo cambio es una celda del índice (fila de REQ-019, `pendiente` → `en-progreso`). El diseño ejecutado es el de `diff-arboles-A-B.txt`.
