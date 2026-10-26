# REQ-036 CA-02, pasada de P-137-Z: archivo de lectura por rol

**Árbol medido:** `cand/1.37.0` en `cfdc60e` (CA-18 y CA-19, sin validar). **Base:** las 2 corridas de `081cb10`
de `../README.md`, sin repetir. **Fecha:** 2026-10-26. **Coordinadora:** Opus.

**Método:** igual que la serie anterior (`corre2.sh`, `monta.sh`): `claude -p --agent arnes-juan:analista-requerimientos
--model sonnet --plugin-dir <candidato> --setting-sources project,local`. El archivo `.arnes/lectura/analista.md` **no**
se genera a mano: lo genera el hook de inicio de sesión del plugin al arrancar cada corrida.

**Métrica (P-137-Z):**
- principal: USD por corrida (`total_cost_usd`);
- secundarios: tokens no cacheados (entrada + creación de caché + salida, de `modelUsage`) y total de tokens.

| Corrida | USD | No cacheados | Total | Turnos | Cabecera |
|---|---|---|---|---|---|
| cand2-normal-1 | 0,2505 | 52 346 | 150 687 | 8 | ligero · no · n/a · borrador |
| cand2-normal-2 | 0,2198 | 42 257 | 193 666 | 8 | ligero · no · n/a · borrador |
| cand2-dinero-1 | 0,2063 | 41 568 | 149 322 | 8 | critico · no · **pendiente** · borrador |
| cand2-dinero-2 | 0,2045 | 40 960 | 160 964 | 7 | critico · no · **pendiente** · borrador |
| **Media, esta pasada** | **0,2203** | **44 283** | **163 660** | 7,75 | 4/4 |
| Media, base (`081cb10`) | 0,3077 | 64 770 | 212 564 | 6,0 | 2/2 |
| Media, pasada anterior (`d4e68d6`) | 0,2669 | 48 992 | 248 432 | 15,0 | 3/4 (`Seguridad: n/a` en dinero) |

**Frente a la base:** USD −28 %, no cacheados −32 %, total −23 %.

**Qué se comprobó**
- **Escrituras:** las 4 escriben sólo `requirements/REQ-001.md` y `requirements/README.md`. Se comprobó por fecha de modificación posterior al manifiesto.
- **Lectura:** las 4 leen su archivo por rol en un solo `Read`, y ninguna vuelve a leer por marcas.
  - Las 4 hacen el `Glob` de frescura.
  - En 3 de 4 va en el mismo mensaje que el `Read`. En `cand2-dinero-2` va en el mensaje anterior: un turno más, sin efecto en la decisión.
- **Bytes leídos (sumando (ii) de CA-01):**
  - 66 363 B en dinero y 66 480 B en normal: archivo por rol 57 089 + manifiesto **entero** 9 274 (+ 117 de `filtro.ts`).
  - La definición del agente (16 481 B) no se lee con `Read`: se inyecta como instrucciones del agente.
  - **Lo que recibe el analista**, contado como la línea base de P-137-W (definición + manifiesto entero + lo leído): ≈ 82 844 B, frente a 138 574.

Cada corrida deja su `*.json` (uso), su `*.REQ-001.md` (lo escrito) y su `*.herramientas.jsonl` (las llamadas a
herramientas, sacadas de la transcripción de la sesión).
