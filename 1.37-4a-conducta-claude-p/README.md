# Prueba de conducta de REQ-036 (1.37 · 4a) con `claude -p` aislado (P-137-Y, CA-02)

- **Fecha:** 2026-10-26. **Método:** `claude -p --agent arnes-juan:analista-requerimientos --model sonnet --plugin-dir <árbol> --setting-sources project,local --permission-mode acceptEdits --output-format json`, lanzado desde cada proyecto de prueba (`monta.sh`), con su `CLAUDE.md` de la plantilla del árbol. El analista es la **sesión principal**, no un subagente: recibe además el recordatorio de `SessionStart` (≈ 260 B), que un subagente no recibe.
- **Árboles:** candidato = `cand/1.37.0` en `d4e68d6` (sin import); base = `081cb10` (con `@AGENTS.md`), por `git archive`.
- **Contexto al empezar** (encargo «Responde sólo: OK»): candidato **10895** tokens; base **39673** tokens (−73 %).

| Corrida | Tokens procesados (suma de `modelUsage`, con lecturas de caché) | Turnos | USD | Estado | Rigor | Sensible | Seguridad |
|---|---|---|---|---|---|---|---|
| cand-normal-1 | 203 225 | 15 | 0.232 | borrador | ligero | no | n/a |
| cand-normal-2 | 267 004 | 13 | 0.263 | borrador | ligero | no | n/a |
| cand-dinero-1 | 305 742 | 17 | 0.310 | borrador | critico | no | pendiente |
| cand-dinero-2 | 217 756 | 15 | 0.262 | borrador | critico | no | n/a |
| base-normal-1 | 245 485 | 7 | 0.312 | borrador | ligero | no | n/a |
| base-dinero-1 | 179 644 | 5 | 0.303 | borrador | critico | no | pendiente |

**Medias:** candidato 248 432 tokens  15.0 turnos  0.267 USD; base 212 564 tokens  6.0 turnos  0.308 USD.

**Lectura:** el `Rigor:` es correcto en 6/6. `cand-dinero-2` escribió `Seguridad: n/a` con `Rigor: critico`: la plantilla del README dice qué lleva `Seguridad:` en lo normal (`n/a`), pero no en un ámbito alcanzado que no es sensible (`dinero`). El candidato procesa **más tokens** por corrida (más turnos: lee bloque a bloque con `Grep` y `Read` por rangos, y cada turno vuelve a procesar el contexto), aunque **cuesta menos en USD**, porque esas relecturas salen de la caché.
