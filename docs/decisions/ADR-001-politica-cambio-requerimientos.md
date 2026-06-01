# ADR-001 — Política de cambio de requerimientos (versionado y deriva)
Fecha: 2026-06-01
Estado: aceptada

## Contexto
El arnés ya trazaba decisiones (ADRs), estados de REQ y CHANGELOG, pero la forma de **cambiar
un requerimiento** estaba implícita. Sin política escrita, el riesgo es reescribir un REQ encima
(perdiendo el porqué), dejar que el código derive del REQ en silencio, o aprobar contra un REQ
desactualizado.

## Decisión
Añadir una política explícita de cambios de requerimientos a `AGENTS.md` y reforzar los
artefactos y agentes que la aplican:
- Un REQ no se reescribe encima: se versiona dejando antes/después y la causa.
- Cambio de fondo → ADR nuevo enlazado desde el REQ.
- Deriva (código ≠ REQ) → se actualiza el REQ; nunca se deja en silencio.
- Un REQ `completado` que cambia reabre el ciclo (dev → QA → seguridad).
Responsables: `analista-requerimientos` (versiona y enlaza), `qa-tester` (detecta y reporta deriva).

## Alternativas consideradas
- Dejarlo implícito (statu quo) — simple, pero permite pérdida de trazabilidad y aprobaciones contra REQ obsoletos.
- Solo CHANGELOG sin Historial por REQ — el porqué queda lejos del REQ; peor lectura.

## Consecuencias
- (+) Trazabilidad completa del "porqué" de cada cambio, junto al REQ.
- (+) La deriva se vuelve visible y se corrige por proceso.
- (−) Más fricción al cambiar un REQ. Mitigación: el cambio menor solo requiere una fila en el Historial.
