# ADR-018 — Las quality gates tienen su propio presupuesto, y el plazo propio del hook mide sólo el análisis (issue #63; versiona ADR-017)
Fecha: 2026-10-27
Estado: aceptada (2026-10-27). El propietario resolvió P-137-AB (A) (`PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-27) — P-137-AC (A) y P-137-AB (A)», commit `d9b3348` de `cand/1.37.0`), literal en lo que toca a esta decisión: «El plazo propio de 30 s mide el ANÁLISIS de la puerta, no el tiempo de las quality gates […] Las gates tienen su propio presupuesto, por debajo de lo que el cliente tarda en matar el hook […] Si las gates lo exceden, deny con un motivo propio de gates […], nunca un cierre sin veredicto.»

## Contexto
**Medido** (`issue-63-plazo-gates/`, commit `bca0598` del árbol de evidencia; CLI 2.1.289, Linux/WSL2, una corrida por punto):
- con una gate `sleep 35`, `guard-completado` deniega **todo** cierre por su plazo propio en 1.36.0, 1.36.1, 1.36.2 y el candidato `d722aed`: la comprobación que va **detrás** de las gates cuenta el tiempo de las propias gates;
- el cliente mata un `PreToolUse` sin `timeout` explícito a **≈ 600 s**, no a los 60 s sobre los que ADR-017, `AGENTS.md` §13 y los comentarios de `hooks/` fijaron el plazo de 30 s. Un hook muerto no deniega (SEC-030).

ADR-017 (P-136-C) decidió «techos de tamaño más plazo propio de 40 s, sin procesos», y REQ-007 CA-68 dejó SEC-132 (a) como límite declarado (P-136-U (A)) tras revertir una pasada que acotaba la gate en curso (QA-007-15, 16 y 17).

## Decisión
1. **El plazo propio (30 s, respuesta en no más de 40 s) mide el análisis y no cuenta lo que tardan las gates.** El valor no cambia; cambia qué mide.
2. **Las gates tienen su propio presupuesto de 420 s en total**, de modo que *análisis (≤ 40 s) + presupuesto + corte (≤ 10 s) ≤ 0,8 × el límite medido del cliente*. Si se agota, el hook interrumpe la gate en curso, no lanza la siguiente y emite `deny` con un motivo propio de gates. Nunca un cierre sin veredicto.
3. **La promesa «60 s» se corrige con la cifra medida** en todo texto vivo (REQ-037 CA-07).
4. **Interrumpir una gate puede costar procesos:** «sin procesos» de ADR-017 se conserva para el análisis; la rama de las gates lo declara y lo techa (REQ-037 CA-06). Es lo que ya aceptó P-136-T (B) en 1.36.0.

## Consecuencias
- Un cierre con gates **verdes** de entre 30 s y 420 s vuelve a pasar (`deny` → `allow`, M-037-1).
- Unas gates que suman más de 420 s y menos de ≈ 600 s **ya no pasan** como en 1.35.0 (M-037-2) y las que no terminan dan `deny` en vez de «sin decisión» (M-037-3).
- **N es de contrato** (un proyecto elige la duración de sus gates por él): no cambia sin otro ADR. **Residual declarado:** depende del valor por defecto del cliente; un `timeout` explícito en `hooks.json` lo cerraría y **no está pedido** (REQ-037, R-1). Sacar las gates del hook es la ficha F-137-24 (1.38).
- No se tocan SEC-133, SEC-131 (a) ni SEC-132 (b).
- REQ-007 CA-68 y `AGENTS.md` §13 se versionan en la fase de write-back de REQ-037.
