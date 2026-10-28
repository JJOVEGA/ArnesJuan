# ADR-019 — Las quality gates corren fuera del hook; la puerta de cierre sólo comprueba un veredicto ligado al hash del árbol (issue #63, F-137-24; sustituye a ADR-018)
Fecha: 2026-10-28
Estado: aceptada (2026-10-28). Sustituye a [ADR-018](ADR-018-las-quality-gates-tienen-su-propio-presupuesto.md), que queda **sustituida** (nunca publicada). El propietario lo decidió en F-137-24, P-137-AF y P-137-AK (`PENDING_APPROVAL.md` de `hotfix/1.36.3` § Resueltas), literal en lo que toca: «las gates no deberían correr dentro del hook. QA o la coordinadora las corren antes y registran el resultado con el hash del árbol; la puerta sólo comprueba que el árbol actual es ese. Así el cierre tarda un segundo sea cual sea el proyecto.»; «las respuestas dobles con carga vienen del arreglo, no del problema original».

## Contexto
**Medido** (`issue-63-plazo-gates/`, commit `bca0598`; CLI 2.1.289): desde 1.36.0, unas gates de más de 30 s impedían todo cierre (el plazo propio contaba el tiempo de las gates), y el cliente mata un `PreToolUse` a ≈ 600 s, no a 60 s. ADR-018 respondió con un presupuesto de 420 s dentro del hook, con reloj, corte y `wait -n -p`; con carga produjo respuestas con dos documentos JSON (el cliente no aplica el `deny`), `deny` espurios y cuelgues (QA-037-01, tres cuelgues en 3 870 cierres). Todo ese riesgo nace de **ejecutar código ajeno dentro de un proceso que tiene que decidir a tiempo**.

## Decisión
1. **Las gates no corren en el hook.** Las corre `tools/arnes-gates.sh`, lanzada por QA, la coordinadora o el propietario, que registra en `.arnes/gates-veredicto.json` el código de salida de cada gate, el hash del árbol, la fecha y quién la corrió.
2. **La puerta no ejecuta ninguna gate:** comprueba que hay registro legible, que su lista de gates es la del manifiesto, que todas salieron 0 y que el hash es el del árbol actual; si no, deniega y dice cómo correr la herramienta.
3. **«El árbol»** es el contenido del árbol de trabajo (comiteado, sin comitear, nuevo no ignorado), menos el registro y los artefactos de gobierno. Sin git no hay veredicto.
4. **Falsificación:** el registro lo protegen las puertas de escritura ya existentes (a todo agente, también al `desarrollador`); lo que queda —consola, formas que el detector no ve, una gate hostil, `quién` no verificado, la edición de la herramienta— **se declara**, no se acepta como definitivo.
5. **Se retira** el código del intento de ADR-018 (presupuesto, relojes, `wait -n -p`, guarda de la trampa); el plazo propio queda como en v1.36.2 y ADR-017 no cambia.

## Consecuencias
- Un cierre con gates verdes de cualquier duración, con veredicto válido, tarda ≈ 1 s (M-037-1). **Cambio de compatibilidad:** un proyecto con `quality_gates` ya no cierra hasta que alguien corre la herramienta (M-037-2); sin git no cierra.
- SEC-133 queda cerrado por construcción; SEC-132 (a) deja de ser un vector del hook; SEC-131 (a) y SEC-132 (b) no cambian.
- Una suite de más de 600 s se corre en segundo plano o desde la terminal del propietario; el hash, no la duración, da la fiabilidad.
- **Residual:** quien escribe el registro por una forma que las puertas no ven puede fabricar un verde (F-136-13). Endurecimiento posible, no incluido: restringir por `Bash` quién lanza la herramienta.
