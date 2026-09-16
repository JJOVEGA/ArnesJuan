# CHANGELOG — rama de evidencia

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
