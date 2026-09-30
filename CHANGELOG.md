# CHANGELOG — rama de evidencia

## 2026-09-30 · SEC-119 y O-11 v3: REGISTRO PREVIO de la validación de la reparación en el host real (antes de ejecutar)
`sec119-v3/`: doce casos con lo esperado. Hook reparado de `104ffd1`, con sus sha. Incluye el control de denegación, los casos que en la línea base escaparon, los legítimos y la regresión de SEC-117. Nada ejecutado todavía.

## 2026-09-30 · SEC-119 y O-11: RESULTADO de la línea base en el host real con el hook sin reparar
`sec119-base/RESULTADO.md`, sobre el CLI 2.1.285.
- El host **normaliza** `..` y `./` en el `file_path` de `Edit`/`Write`, así que esas formas no se alcanzan desde el host por esas herramientas.
- El host **no resuelve los enlaces**: por un directorio enlazado se cerró un REQ `critico` con todo en rojo.
- El host **no normaliza `Bash`**: por `..` se creó código protegido y se cerró un REQ por shell.
- **O-11:** la herramienta editó un REQ en UTF-16LE que el hook no puede leer.

Una ejecución por caso; controles conformes.

## 2026-09-30 · SEC-119 y O-11: REGISTRO PREVIO de la línea base en el host real con el hook sin reparar (antes de ejecutar)
`sec119-base/`: `PREREGISTRO.md` con siete casos: controles canónicos; `..`; `././`; un directorio enlazado; `Write` de código por `..`; y un REQ en UTF-16LE (O-11). Incluye lo que se espera según el host normalice o no la ruta, y el método. Nada ejecutado todavía.

## 2026-09-30 · Candidato 1.35.0, vuelta excepcional agrupada: evidencia del desarrollador, de QA y de seguridad, y CI de la cabeza final `9596e39`
- `cand-1.35.0/evidencia-dev-sec117/`: corridas 00–27, sin borrar ninguna; incluye el banco final con 2 FAIL de reloj conservados.
- `cand-1.35.0/evidencia-qa-sec117/`: banco 1164/1/13, casos de ruptura, sonda de motivos y QA-023-07.
- `cand-1.35.0/evidencia-seg-v2/`: sondas de R-045-A, SEC-119 y SEC-120.
- `cand-1.35.0/ci-cand-9596e39/`: run 36745052075, success, 1146 PASS · 0 FAIL · 32 SKIP (0 INCONCLUSO; 18 SKIP del fail-before de REQ-023 por falta de 1.33.2 en el runner). Sin relanzar.
- También: el inventario de llamadas del banco y las copias de trabajo de la tercera y la cuarta autorización. Las copias de registro están en `PENDING_APPROVAL.md` del candidato.

Sin binarios ni volcados de terceros. Sin push.

## 2026-09-30 · SEC-117 v2: RESULTADO de la validación de la reparación en el host real (tras el registro previo `0680a2a`)
`sec117-real-v2/RESULTADO.md` y las salidas por caso. Una ejecución por caso:
- **sospechoso:** deny por CA-13, el host bloquea y el disco no cambia. En la v1 se cerraba.
- **positivo:** deny.
- **control:** se permite y se aplica.
- **reapertura**, con la cola ocupada: se permite y se aplica.
- **multiedit:** no comprobable en el host, porque el CLI 2.1.285 no expone `MultiEdit`; lo cubre el banco a nivel de hook.

## 2026-09-30 · SEC-117 v2: REGISTRO PREVIO de la validación de la reparación en el host real (antes de ejecutar)
`sec117-real-v2/`: `PREREGISTRO.md` (CLI 2.1.285, la misma sonda que la v1, hook del candidato `5dfabb3` con sus sha, cinco casos con su entrada, sus precondiciones y lo esperado, y el método), los prompts, `run.sh` y los proyectos en su estado inicial. Nada ejecutado todavía.

## 2026-09-29 · Candidato 1.35.0: CI de `df550fa` y evidencia de la QA del delta documental
- `cand-1.35.0/ci-cand-df550fa/`: run 36637448792, `hooks-en-linux` success, 1115 PASS · 0 FAIL · 34 SKIP (2 INCONCLUSO de rendimiento; 18 SKIP del fail-before de REQ-023 por falta de 1.33.2 en el runner). Sin relanzar.
- `cand-1.35.0/evidencia-qa-doc/`: la revisión de QA del delta documental, incluida la sonda multibyte de QA-023-06.

Sin push.

## 2026-09-29 · SEC-117: RESULTADO del experimento real (tras el registro previo `6c947ef`) — REPRODUCIDO en el CLI 2.1.285 (comillas rectas donde el archivo las tiene tipográficas)
`sec117-real/RESULTADO.md` y, por caso, `logs/` (entrada y salida del hook), `stream.jsonl` (eventos de hook y `tool_result`), el archivo final y su sha. Una ejecución por caso y sin repetición:
- **positivo:** deny; el host bloquea; el archivo no cambia;
- **sospechoso:** el hook sale sin decisión; el host aplica el `Edit`, y su `tool_response.oldString` muestra que normalizó las comillas; el REQ queda `completado` con todas las precondiciones en rojo;
- **control:** se permite y se aplica.

No se ensayó el escape `\uXXXX`. Sin reparación.

## 2026-09-29 · SEC-117: REGISTRO PREVIO del experimento real y aislado (antes de ejecutarlo)
`sec117-real/`: `PREREGISTRO.md` (entorno, CLI 2.1.285, plugin sonda, hook del candidato con sus sha, entradas exactas, precondiciones, resultado esperado, método de observación), los prompts, `run.sh`, los proyectos en su estado inicial y la comprobación del montaje a nivel de hook. Nada ejecutado todavía en el host.

## 2026-09-29 · Candidato 1.35.0 (`cand/1.35.0`, PR #59 en borrador): evidencia íntegra de las comisiones y CI de `45c2e5c`
`cand-1.35.0/` (índice en su `README.md`):
- las comisiones: desarrollador (implementación, versión, comentarios v2 y v3), QA (vueltas 1 a 3), auditor (R-045) y la comprobación previa de la coordinadora;
- el CI del candidato: run 36625681278, `hooks-en-linux` success, 1114 PASS · 0 FAIL · 35 SKIP (2 INCONCLUSO de rendimiento; 18 SKIP del fail-before de REQ-023 porque el runner no tiene la instalación estable 1.33.2).

Excluido: `qa/cc-strings.txt`, cadenas del binario del CLI, contenido de terceros. Nada de esto acredita rendimiento. Sin push.

## 2026-09-21 · REQ-025: observación acotada de S4 (ENS-S4-P, candidato `9f908d9`) — **NO OBSERVADO**: el desarrollador corrigió también CA-03, QA aprobó, seguridad aprobó, REQ-004 en `en-revisión`; no se repite por instrucción del propietario
`req-025/ensayos/ENS-S4-P/` (salida completa, diff del proyecto, REQ-004, QA del proyecto, análisis). Acreditación formal pendiente de QA.

## 2026-09-21 · REQ-025 entrega 1 consolidada: 18 commits, PR #52 en borrador, CI verde sobre `9f908d9` (903 · 0 · 9; autoprueba 106 · 0); QA vuelta 3 `con-hallazgos` por QA-025-08 (condición de aceptación pendiente); REQ-025 bloqueado con alcance y decisión encolada
`req-025/README.md` (consolidado), `req-025/ci-pr52-9f908d9/` (diagnóstico y log). Sin fusión ni publicación.

## 2026-09-21 · REQ-025 entrega 1: ensayo de coordinación ENS-COORD-P ejecutado (plantillas y agentes de `ff4ff67`, n=1): S1, S2, S3 observados; S4 bloqueo conservado por veto de seguridad; cola 1 → 7 entradas (observación)
`req-025/ensayos/ENS-COORD-P/` (salida completa, diff del proyecto, cola, REQ-004, QA y seguridad del proyecto, análisis de la coordinadora). Acreditación pendiente de QA (CA-11 punto 3).

## 2026-09-21 · REQ-025 entrega 1: lanzador del ensayo de coordinación (S1 cola sólo de publicación · S2 decisión de negocio · S3 hallazgo ajeno · S4 defecto que compromete) y resultados esperados escritos antes de ejecutar
`req-025/ensayos/lanzar-coordinacion.sh` (sin ejecutar) y `req-025/ensayos/esperado-coordinacion.md`. Se ejecutará con el candidato ya parcheado, una vez aplicado y revisado.

## 2026-09-16 · v1.34.0 PUBLICADA: notas corregidas (`c5db41b`) verificadas por QA y seguridad (R-033); CI verde sobre `ca5ac4a` (903 · 0 · 9); PR #51 fusionado (`cc8972c`, árbol = candidato); tag anotado `v1.34.0` empujado; instalación estable y consumidores sin actualizar
`porte-1.33.2/ci-pr51-ca5ac4a/DIAGNOSTICO.md` y `porte-1.33.2/README.md` § «v1.34.0 PUBLICADA». Limitaciones que viajan, enumeradas; SEC-090 y H-P3 diferidos y abiertos.

## 2026-09-16 · Candidato v1.34.0 corregido `a8cbb29` (PR #51): **CI verde** — banco 904 · 0 · 8 = 912, autoprueba 106 · 0; QA del delta favorable; seguridad R-032 extendida (SEC-090/091/092 instrumento); FAIL previo de la sonda conservado
`porte-1.33.2/ci-pr51-a8cbb29/` (DIAGNOSTICO.md, run.json, log completo) y `porte-1.33.2/README.md` § «Candidato v1.34.0 corregido». Sin fusión, tag ni publicación.

## 2026-09-16 · H-P1 reparado en `8bd5e33` (regla explícita de Fase 5): comprobación UPG4 (2 de 2 sesiones con §6 personalizada conservan la versión y declaran PARCIAL; control COMPLETO avanza a 1.34.0); autoprueba 106 · 0 sobre `8bd5e33`
`porte-1.33.2/ensayos/UPG4-*`, `esperado-upg4.txt`, `lanzar-upg4.sh`, `UPG4-analisis.txt`; `porte-1.33.2/autoprueba-8bd5e33.txt`. QA del delta y seguridad acotada pendientes; sin push todavía.

## 2026-09-16 · CI del candidato v1.34.0 (`b520e3b`, PR #51): puerta ROJA por `REQ-017 CA-08 (ii)` (sonda de coste sobre hooks idénticos a v1.33.2); banco 904 · 1 · 7 cuadrado; consolidado del candidato
`porte-1.33.2/ci-pr51-b520e3b/` (DIAGNOSTICO.md, run.json, log completo) y `porte-1.33.2/README.md` § «Candidato v1.34.0». Sin relanzar, sin fusión, sin publicación.

## 2026-09-16 · Candidato v1.34.0 (`b520e3b`): verificación acotada del destino (UPG3, 4 sesiones: 0 dudas del marcador; renumerado llega a Fase 2 y localiza por título y contenido), aclaración de H-P1, PR #51 en borrador hacia `main`
`porte-1.33.2/ensayos/UPG3-*`, `esperado-upg3.txt`, `lanzar-upg3.sh`, `UPG3-analisis.txt`; `porte-1.33.2/H-P1-aclaracion.md`. Push sin force de `porte/via-proporcional-1.33.2` @ `b520e3b`; diff del PR idéntico a `v1.33.2..b520e3b`; CI run 35151689849 en curso.

## 2026-09-16 · Validación acotada del porte `404e044` consolidada: QA FAVORABLE, seguridad acotada aprobada (R-031 del porte, SEC-089 instrumento), once ensayos reales
`porte-1.33.2/README.md` § «Resultado consolidado». Porte en `346b882` local; pendiente el número de versión (detectado por la skill estable en 2 de 6 sesiones). Sin publicación ni cambios en instalaciones.

## 2026-09-16 · Once ensayos reales sobre el porte `404e044` (agentes: SIN-CONS-P, CON-AFIRM-P; instalación: INIT-P/P2/P3; actualización: UPG-*-P y UPG2-* con fixture limpio)
`porte-1.33.2/ensayos/`: README con resultados frente a lo esperado, lanzadores, salidas completas por caso, análisis y costes reportados. Hallazgo transversal: el marcador de versión del porte (declara 1.33.2 con plantillas distintas del tag) hace que la skill estable rehúse el destino en 2 de 6 sesiones. Sin QA ni seguridad todavía.

## 2026-09-16 · Porte mínimo de la vía proporcional sobre `v1.33.2`: diff preparado (`404e044`) y revisión de la coordinadora
`porte-1.33.2/404e044.diff` y `porte-1.33.2/README.md`: revisión del diff (mecanismo 0, términos prohibidos 0, gemelas, sede única, título provisional), capacidades de `v1.33.2` comprobadas con secciones del banco por ruta. Sin QA, sin seguridad, sin despacho real.

## 2026-09-16 · Tabla de decisión corregida: tres clases (cierre de REQ · condiciones de publicación · limitaciones no bloqueantes)
`decision-publicacion/2026-09-16-tabla.md` § 3: nota de corrección y filas B1…B8 etiquetadas [a]/[b]/[c]; la clasificación vigente vive en el inventario del repo § 4.1. Registro fechado conservado.

## 2026-09-16 · Integración del PR #50 (5f07419 en base/via-proporcional) y tabla para la decisión de publicación
`decision-publicacion/2026-09-16-tabla.md`: actualización del inventario `entrega-acotada-desde-1.33.2.md` con el diff `v1.33.2..5f07419`, procedencia base/vía, ocho bloqueos con evidencia y recomendación (separar). Sin pruebas nuevas ni comisiones.

## 2026-09-16 · Sexta ronda: SEC-102 mitigado (R-040), 40/3 partida por REQ-014 CA-18, SEC-103 nuevo; CI sobre `e392fbf` **verde**: banco 1278 · 0 · 16 cuadrado en 1294, autoprueba 106 · 0
`validacion-f141511/VEREDICTO.md` (Sexta ronda) y `validacion-f141511/ci-pr50-e392fbf/` (`DIAGNOSTICO.md`, `run.json`, log completo). CA-09 PASS 1,126× registrado sin borrar el FAIL anterior. Sin fusión ni publicación.

## 2026-09-15 · Quinta ronda: I-7 resuelto, R-039 extiende la firma a `9dac46f`, SEC-102 nuevo; CI sobre `f6912ea` — banco verde y cuadrado (1293), puerta roja por REQ-014 CA-18 (sección 40/3 con 554 líneas)
`validacion-f141511/VEREDICTO.md` (Quinta ronda) y `validacion-f141511/ci-pr50-f6912ea/` (`DIAGNOSTICO.md`, `run.json`, log completo). El FAIL es determinista e introducido por la cadena I-5/I-7; la autoprueba del corredor no había corrido nunca en el PR. Sin relanzar, sin reparar, sin excepciones.

## 2026-09-14 · Evidencia de la prueba funcional de la vía proporcional sobre `b3efa23`
Consolidación desde `/tmp/arnes-diag-wBF0L4`: diagnóstico de carga, sonda de escrituras, dos proyectos base, seis casos con prompts, salidas, diffs, estado final, análisis y atribución. Sin credenciales. Detalle y limitaciones en `README.md`.

## 2026-09-14 · Verificación posterior del hook omitido en `031e757`
Ver `VERIFICACION-POSTERIOR-HOOK.md`: el commit cumplía la condición (`CHANGELOG.md` incluido); el bypass fue innecesario y no se repite. Es verificación posterior, no ejecución original.

## 2026-09-14 · CON-2 repetido en bwrap endurecido con Node v24.21.0 verificado
Adenda en `README.md`; artefactos en `casos/CON-2b/` y `entorno-aislado/`. QA terminó con un hallazgo real `usuario/dinero`; seguridad no se despachó por orden de firmas; **nadie corrigió rigor, sensibilidad ni exigencia de seguridad** en la cabecera (`estandar`/`no`/`n/a`). Sin intento de cierre prematuro.

## 2026-09-14 · Validación acotada de `f141511` (CON-2c y CON-1c en bwrap): PENDIENTE
Ver `validacion-f141511/VEREDICTO.md`. CON-2c: el analista resolvió la clasificación de forma acotada antes de continuar (lo contratado). CON-1c: el control **no** conservó la vía corta (fila 4 declarada); con n=1 no atribuible al cambio. Banco 45+46: 64·0·2.

## 2026-09-14 · CON-4 (control sustituto) sobre `f141511`: vía corta conservada; escalada posterior por hallazgos de QA y criterio crítico amplio
Ver `validacion-f141511/VEREDICTO.md` y `validacion-f141511/CON-4/`.
