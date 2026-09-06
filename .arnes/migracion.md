# Migración del arnés — plan (arnes-upgrade)

- Fecha: 2026-09-05 · Origen: 1.30.2 (CONFIRMADO: `.arnes/plantillas-origen/` idéntica a `v1.30.2:templates/`) · Destino: 1.30.3 (plugin instalado 6c1b58a, el actual).
- Árbol de git limpio al empezar (rama `cand/1.31.0-mecanismos`).

## Clasificación

| Archivo | Estado | Evidencia | Acción |
|---|---|---|---|
| `AGENTS.md`, `CLAUDE.md`, `ARCHITECTURE.md`, `CHANGELOG.md`, `PENDING_APPROVAL.md`, `docs/ESTADO.md`, `requirements/README.md`, `.arnes/config.json` (las 11 plantillas) | sin cambio en destino | `diff` de cada `templates/*.tpl` entre `v1.30.2` y `v1.30.3`: idénticas | **ninguna** — no hay sección NUEVO ni INTACTO que actualizar; lo MODIFICADO por este proyecto no se toca |
| `.arnes/plantillas-origen/` | base para la siguiente migración | contiene 8 de 11 plantillas | SAFE: añadir las 3 que faltan, copiadas de la versión destino (idénticas a la de origen) |
| `.arnes/config.json` → `arnes_version` | registro | `1.30.2` | Fase 5: `1.30.3`, sólo tras verificar |

## Avisos de «Hacia 1.30.3» aplicados a este proyecto
- Revisión de REQ `completado` con veredictos pendientes: ver salida de `tools/arnes-lectura.sh` en el CHANGELOG de la migración.
- Los cinco cambios de conducta de los hooks están documentados en `CHANGELOG.md` [1.30.3] y `docs/qa/REQ-001.md` §9.13 (guía de usuario).

## Aplicado
- [x] 3 plantillas añadidas a `.arnes/plantillas-origen/`
- [x] `arnes_version` → 1.30.3 (Fase 5)
