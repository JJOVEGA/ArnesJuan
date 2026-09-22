# REQ-019 · piloto de lectura por encargo — REGISTRO DEL RESULTADO (experimento terminado, 2026-09-22)

**Conclusión del propietario (2026-09-22), literal:** «**piloto ejecutado, sin reducción demostrada; no seleccionado para adopción**». No se adopta el cambio de §0 ni se repite la comparación. **El fin del experimento no es el cierre del requerimiento:** REQ-019 permanece `en-progreso` y **pendiente de replanificación**, con sus criterios y sus hallazgos abiertos; CA-07 (P) queda con el veredicto de QA tal como lo emitió (**parcialmente satisfecho**, `QA: con-hallazgos (R-1)`), **sin** declararlo satisfecho por aceptación de residual.

## Resultado, registrado fielmente
| Punto | Resultado |
|---|---|
| Obligaciones del encargo | **Se cumplieron en ambos brazos** (QA: 0 de 11 incumplidas en B; A sin desvíos de invariante escrita). |
| Reducción de lecturas | **No demostrada.** En B los roles acotados leyeron por secciones y nadie el README entero; pero en A el desarrollador leyó 0 bytes y QA 2 404, así que **B leyó más README que A** (6 174 y 24 713 caracteres). |
| Tokens y coste | **B tuvo mayor consumo de tokens y coste reportado en esta corrida** (10,75 frente a 11,54 USD reportados por el CLI; primer turno mayor en las cuatro comisiones). **No es facturación efectiva ni demuestra que siempre sea peor**: n=1 por brazo. |
| Validez de la comparación | **Limitada**: el control no reprodujo la línea base anterior (6 de 7 lecturas completas en CON-4; aquí 1 de 3), y el `CHANGELOG.md` del brazo B anunció el piloto a dos agentes (QA-019-01, QA-019-02). |

## Dónde está todo (se conserva; nada se revierte ni se borra; fuera de `main`)
- **Rama del piloto** `feat/req-019-piloto-lectura` (worktree `/home/juan/dev/ArnesJuan-req019`, **local, sin push**): `ed14828` reconciliación con `main` `cfb1106` · `000ba83` §0 aplicado + write-back CA-06 (REQ-007, REQ-018) · `605db77` acreditación de QA (`docs/qa/REQ-019.md`) · `cb168d7` punto de retomar · cierre del experimento (commit siguiente).
- **Esta rama de evidencia**, `req-019/piloto/`: `esperado.md` (escrito antes de ejecutar, con nota fechada QA-019-03), `prompt.txt`, `lanzar-brazo.sh`, `analizar-brazo.py`, `diff-arboles-A-B.txt`, `BRAZO-A/` (árbol `ed14828`) y `BRAZO-B/` (árbol `000ba83`) con `salida.jsonl`, comando, tiempos, diff del proyecto y archivos creados, `analisis.txt`, y `resultado-coordinadora.md` (testimonio con la acreditación de QA resumida).
- Plugin de los dos brazos: `cfb1106` (`main`, 1.34.0). Encargo: el fixture de la sección 33 del banco (defecto real preexistente).

## Hallazgos abiertos del piloto (todos `instrumento`; registrados, sin reparación autorizada)
QA-019-01 fuga de tratamiento (CHANGELOG de B) · QA-019-02 control sin línea base reproducida · QA-019-03 esperado con cinco diferencias y eran seis · QA-019-04 (ajeno a REQ-019) el detector de escrituras por `Bash` de `guard-codigo` mide el literal de la ruta, no el efecto.

## Lo que NO se hace por esta decisión
No se adopta §0 (queda aplicado sólo en la rama local del piloto, fuera de `main`; la plantilla nunca se tocó); no se repite la comparación; no se declara CA-07 (P) satisfecho; no se modifica el veredicto de QA; no se inicia el reparto documental ni se cambian umbrales; no se abren reparaciones de QA-019-01…04; sin seguridad para promover el piloto; sin push, fusión, publicación ni cambios en consumidores. REQ-025 y las sondas de coste, intactos.
