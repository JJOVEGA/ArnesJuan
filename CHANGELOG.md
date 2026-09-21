# CHANGELOG — rama de evidencia

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
