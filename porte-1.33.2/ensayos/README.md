# Ensayos con agentes y skills reales del porte `404e044` — 2026-09-16

**Plugin bajo prueba:** copia de sólo lectura de `404e044` en `/tmp/arnes-diag-wBF0L4/plugin-404e044` (226 archivos, `git archive`). En **las once sesiones** el evento `init` declara un único plugin: `{"name":"arnes-juan","path":"/tmp/arnes-diag-wBF0L4/plugin-404e044","version":"1.33.2"}`. El plugin estable instalado **no** se cargó.
**Entorno:** el bwrap endurecido y el Node `v24.21.0` verificado de la ronda anterior (`../../entorno-aislado/`), sin cambios; escrituras fuera del proyecto y de `/tmp/claude-1000` denegadas. `--permission-mode acceptEdits`, `--allowedTools Bash`, `--max-budget-usd 10`.
**Resultado esperado escrito antes de ejecutar:** `esperado-porte.txt` (agentes) y `esperado-skills.txt` (skills, con las dos adendas fechadas).
**Costes:** valoración reportada por el CLI (`total_cost_usd`), no facturación efectiva — `costes.md`.

## A. Despacho con agentes reales (autorizados: CON-AFIRM y SIN-CONS; lanzador `lanzar-porte.sh`)

Misma reparación ordinaria de CON-4 (separador de `REQ-004`), mismo prompt sin roles ni pistas. Base regenerada desde `templates/AGENTS.md.tpl` **del porte**, con el marcador sustituido por la línea literal de §6 en cada caso.

| Caso | Declaración en `AGENTS.md` | Primera secuencia de despachos (por `parent_tool_use_id`) | Write-back | Coincide |
|---|---|---|---|---|
| **SIN-CONS-P** | negativa | **`analista-requerimientos`** → desarrollador → qa-tester → analista | analista (reabre y reclasifica el REQ a `critico`/sensible; QA halla `usuario/dinero`; REQ queda `en-progreso`) | **Sí**: el analista intervino primero |
| **CON-AFIRM-P** | afirmativa (Juan, 2026-09-16) | **`desarrollador` → `qa-tester`** (sin analista) → analista → desarrollador → qa-tester | **el `desarrollador`, en la misma entrega** (Historial de `REQ-004`); el analista entró después sólo por una decisión de alcance nueva (`CA-02`) | **Sí** en la secuencia inicial; la intervención posterior es coste del proceso, se conserva sin juzgar |

Observaciones: en CON-AFIRM-P la coordinadora cerró el REQ (`completado`) tras `QA: aprobado` con `Rigor: estandar` — permitido; el analizador cuenta una edición de QA que incluye `Seguridad: n/a`, valor que **ya estaba** en la cabecera base (estandar/no/n/a). Detalle en `*/analisis.txt`.

## B. Instalación (`/arnes-init`; lanzadores `lanzar-skills.sh`, `lanzar-init2.sh`)

| Caso | Entrada | Resultado | Coincide |
|---|---|---|---|
| **INIT-P** | sin respuestas (nadie delante) | la skill se detiene en la **pregunta 1 de 12** y **no crea nada** | límite de la skill estable (interactiva); no ejerce la declaración |
| **INIT-P2** | respuestas por escrito; la pregunta de la vía **sin responder** | andamiaje completo; **línea negativa** literal; 0 placeholders; `plantillas-origen` (11); `arnes_version 1.33.2` leído del plugin | **Sí** |
| **INIT-P3** | respuestas por escrito; **«sí» explícito** de Juan, 2026-09-16 | **línea afirmativa literal** «… — Declarado por Juan, 2026-09-16.», idéntica a la forma de la sede salvo nombre/fecha; 0 placeholders; `plantillas-origen` (10: falta `DELIVERY.md.tpl`) | **Sí** (observación menor: una plantilla de origen menos) |

## C. Actualización (`/arnes-upgrade`; origen 1.33.1 → destino el porte, que declara 1.33.2)

Primera tanda (`UPG-*-P`) con **dos defectos del fixture** (andamiaje mezclado del candidato `6212e87`; registros escritos dentro del proyecto → árbol sucio). Repetida con **fixture limpio** (`UPG2-*`, `lanzar-upg2.sh`): todo el andamiaje desde las plantillas de `v1.33.1`, registros en `$TMP/salidas/`.

| Caso | Personalización | Resultado | Autorización escrita | Coincide |
|---|---|---|---|---|
| UPG-INTACTO-P | nota en §2 | §6 y §9 SAFE aplicados con **negativa**; nota conservada; `README` MODIFICADO por el fixture → no tocado | no | sí (con ruido del fixture) |
| UPG-MODIF-P | párrafo en §6 | §6 **MODIFICADO → CONFLICTO**, no tocado; §9 SAFE; `arnes_version` **se mantiene 1.33.1** | no | sí |
| UPG-UNKNOWN-P | «## 6. Glosario», orquestación en «## 7.» | **UNKNOWN en Fase 1**: destino rehusado («el plugin no es la versión que declara») + tres procedencias (fixture) + árbol sucio (fixture). Nada aplicado | no | efecto sí; motivo **no** el renumerado |
| **UPG2-INTACTO** | nota en §2 | §6, §9 y dos bloques de `requirements/README.md` SAFE aplicados con **negativa**; §2 MODIFICADO → ninguna acción, nota conservada; 0 UNKNOWN, 0 CONFLICTO; `arnes_version → 1.33.2` anotando «versión por decidir» | no | **Sí** |
| **UPG2-MODIF** | párrafo en §6 | §6 **CONFLICTO**, no tocado; resto SAFE; **`arnes_version → 1.33.2` con el conflicto abierto** (UPG-MODIF-P no lo subió) | no | sí en conservación y no autorización; **conducta de registro no determinista** (skill estable) |
| **UPG2-UNKNOWN** | renumerado | **UNKNOWN en Fase 1 por el destino**: único motivo con fixture limpio. Nada aplicado, `AGENTS.md` byte a byte intacto. La skill localizó §6/§9 **por título y contenido** y anotó que «§9 está ocupada por otra sección» y que aplicar por número escribiría en el sitio equivocado — la conducta de la adaptación, **no ejercida hasta la Fase 2** | no | efecto sí; **el marcador de versión paró antes** |

**Hecho que atraviesa la tanda C:** de **6** sesiones de `/arnes-upgrade`, **2** rehusaron el porte como destino (la comprobación de Fase 1 «el plugin instalado es el actual» detecta que `plugin.json` dice `1.33.2` y las plantillas difieren del tag `v1.33.2`) y **4** lo aceptaron anotando la entrada «Hacia <versión por decidir>». **El juicio de la skill estable sobre el marcador de versión no es determinista.** Mientras el porte declare `1.33.2`, la migración hacia él depende de esa lectura. Es la dependencia real del marcador pendiente, medida.

## Qué NO acredita
Una corrida por caso (salvo los UPG, dos con fixtures distintos). Los ensayos con agentes prueban el despacho y el write-back sobre **una** reparación ordinaria; no cubren la fila 3 (efecto `critico`) por vía afirmativa. `arnes-init` sólo se ejerció con respuestas por escrito (no interactivas). Ningún ensayo cubre un proyecto con copia propia de agente. No es QA ni seguridad; nada mecánico distingue afirmativa de negativa (límite declarado en la sede).
