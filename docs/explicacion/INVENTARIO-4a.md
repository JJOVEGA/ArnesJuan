# Inventario de 1.37 · 4a — qué salió, qué se quedó y por qué (REQ-036 CA-03)

**Convenciones.** Línea base: cabeza `081cb10`. Bytes: `wc -c`, 1 KB = 1 000 B. Clase: `normativo`,
`explicativo` o `historico`, con la definición del preámbulo de REQ-036 (en la duda, normativo y no se mueve).
**Ninguna frase normativa salió de su archivo ni se condensó.** Lo que «sale» es sólo lo que deja su sitio; la
lectura por destinatario (CA-14) no mueve nada: añade marcas.

## Dónde va lo explicativo de un proyecto consumidor

**Se queda en el proyecto** (REQ-036 CA-04, parada decidida en P-137-X (D)). La fase 1 **no pudo mostrar** cómo
un agente de un consumidor localiza la raíz del plugin: el entorno de un subagente no trae ninguna variable con
esa ruta (comprobado en esta sesión: ninguna variable `CLAUDE_PLUGIN_ROOT` ni equivalente), el caché del cliente
guarda **varias versiones** del plugin a la vez (en esta máquina, cinco), y el analista no tiene consola. Una
skill sí conoce su directorio base al cargarse —por eso `arnes-upgrade` lo usa como `PLUGIN`—, pero eso no
alcanza a un agente que lee un puntero en una comisión. Por eso, en las **plantillas**, lo explicativo sale de
los bloques que se leen y pasa a un bloque `explicativo` **del mismo archivo** del proyecto, con su puntero
(ruta relativa a la raíz del proyecto, ancla e identificadores). En **este repositorio**, que sí es el proyecto,
va a `docs/explicacion/`.

## Bytes por archivo (antes → después)

| Archivo | Antes | Después | Diferencia | Sale | Entra (marcas, leyenda, punteros, reglas nuevas) |
|---|---:|---:|---:|---:|---:|
| `templates/AGENTS.md.tpl` | 69 888 | 75 116 | +5 228 | 0 | 5 228 (36 marcas y leyenda; CA-10; CA-11; § 14 con los tres `_doc`; A-00 y § 12 sin el import, CA-14 y CA-16) |
| `templates/requirements-README.md.tpl` | 43 245 | 45 038 | +1 793 | 2 347 (a su anexo, mismo archivo) | 4 140 (15 marcas y nota de lectura; 5 punteros; el anexo con lo movido; la línea del ámbito alcanzado, CA-19) |
| `templates/arnes-config.json.tpl` | 9 970 | 9 331 | −639 | 896 (texto de tres `_doc`, a `AGENTS.md` § 14) | 257 (los tres punteros) |
| `agents/analista-requerimientos.md` | 15 471 | 16 721 | +1 250 | 0 | 1 250 (su lista de lectura; el `Read` del archivo por rol con el `Glob`, CA-18; leerlo entero y la fuente sin marcas, QA-036-08 y QA-036-03) |
| `agents/desarrollador.md` | 11 070 | 12 388 | +1 318 | 0 | 1 318 (ídem) |
| `agents/qa-tester.md` | 16 771 | 18 013 | +1 242 | 0 | 1 242 (ídem) |
| `agents/auditor-seguridad.md` | 20 511 | 21 754 | +1 243 | 0 | 1 243 (ídem) |
| `AGENTS.md` (este repositorio) | 75 448 | 78 476 | +3 028 | 0 | 3 028 (34 marcas y leyenda; CA-10; A-00 y § 12 sin el import, CA-14 y CA-16; **sin** CA-11, por F-137-19) |
| `requirements/README.md` (este repositorio) | 78 607 | 79 087 | +480 | 2 347 (a `docs/explicacion/casos-medidos.md`) | 2 827 (15 marcas y nota; 5 punteros; la línea del ámbito alcanzado, CA-19; filas del índice) |
| `skills/arnes-upgrade/SKILL.md` | 135 493 | 154 198 | +18 705 | 0 | 18 705 (la migración hacia 1.37.0 y su orden; `CLAUDE.md`, CA-16; los archivos por rol, CA-18; «Fuente sin marcas», pieza 3, y el paso 4b, QA-036-03 a 05) |

**Cuadre (CA-03):** en cada fila, *Después − Antes = Entra − Sale*. En el README de la plantilla lo que sale
vuelve a entrar en el mismo archivo (su anexo), así que su «Entra» lo incluye. Los «Después» son `wc -c` del
árbol que se entrega en la vuelta 1 de QA de REQ-036 (QA-036-09); los de la fase 1 (`e1f23d2`) quedan en la
historia de git de este archivo. Lo que sale —la columna «Sale» y la lista de abajo— no cambió desde la fase 1.

## Bloques que salen

| # | Archivo y ancla de origen | Clase | Destino (puntero) | Identificadores que cita | Bytes |
|---|---|---|---|---|---:|
| 1 | `templates/requirements-README.md.tpl` § «Cómo se escribe un criterio que no se desmiente», párrafo «Medido, no opinado» | historico | mismo archivo § «Anexo explicativo — casos medidos», «Por qué existe esta sección» | — (ventana 1.32.1) | 725 |
| 2 | ídem, § «(a) Enumerar lo que el código reconoce», «Caso medido» | explicativo | mismo archivo § «Anexo explicativo — casos medidos», «(a)» | — | 321 |
| 3 | ídem, § «(b) Fijar un número…», «Caso medido» | explicativo | ídem, «(b)» | — | 297 |
| 4 | ídem, § «(c) Exigir igualdad…», «Caso medido» | explicativo | ídem, «(c)» | — | 215 |
| 5 | ídem, § «(d) Fijar la magnitud equivocada», «Caso medido» | explicativo | ídem, «(d)» | REQ-016 CA-08 | 789 |
| 6 | `templates/arnes-config.json.tpl`, `_doc` (raíz) | explicativo | `AGENTS.md` § 14, «Raíz (`_doc`)», bloque A-14.1 | — | 252 |
| 7 | ídem, `agentes._doc` | normativo **duplicado** (la regla vive en `AGENTS.md` § 13, «Nombre del agente en el manifiesto», y § 5) | `AGENTS.md` § 14, «`agentes._doc`», bloque A-14.2 (coordinadora, desarrollador) | — | 314 |
| 8 | ídem, `estado_derivado._doc` | normativo **duplicado** (vive en `AGENTS.md` § 13, «Un hook que no decide nada: la continuidad») | `AGENTS.md` § 14, «`estado_derivado._doc`», bloque A-14.2 | — | 330 |
| 9–13 | `requirements/README.md` de este repositorio, los mismos cinco párrafos que 1–5, idénticos | historico / explicativo | `docs/explicacion/casos-medidos.md` § «Por qué existe la sección», «(a)…», «(b)…», «(c)…», «(d)…» | REQ-016 CA-08 (en (d)) | 2 347 |

Los textos 6–8 salen **literales** (el `_doc` sin las comillas de JSON). Los textos 1–5 y 9–13 salen **línea a
línea idénticos** (comprobado con `grep -xF` de cada línea de origen en su destino).

## Bloques que se quedan, y por qué (CA-03, borde; CA-05)

| Archivo y ancla | Clase | Por qué se queda |
|---|---|---|
| `templates/arnes-config.json.tpl`: `codigo_app._doc`, `veredictos._doc`, `git._doc`, `limites._doc`, `rotacion._doc`, `_doc_orden`, `_doc_artefactos` | **sin clasificar** (normativo en la duda) | Describen cómo decide la puerta o el valor por defecto y no viven en otro sitio del proyecto; moverlos podría dejar sin su regla a quien edita el manifiesto. Se anotan, no se deciden (CA-03, borde). |
| `templates/arnes-config.json.tpl`: `rigor_politica._doc` | normativo | Lo aplica el analista al crear el REQ y lo lee en ese bloque. |
| `AGENTS.md` (plantilla y este repositorio) § 13: filas de la tabla con «(Hasta 1.35.0 …)», cláusula 1 y «Lo medido de SEC-115 y SEC-118…» | historico | Citan SEC-115, SEC-118, SEC-132, SEC-131 y fichas F-136-*, abiertos o `mitigado` con residual: CA-05 (i). |
| `AGENTS.md` § 6: el recuadro de SEC-020 del paralelo | normativo | SEC-020 abierto: CA-05 (i). |
| `AGENTS.md` § 6: «La disciplina de la declaración — SEDE NORMATIVA», «seis reglas… sede única», «Loop de error» | normativo | Sede única o normativa: CA-05 (ii). |
| `AGENTS.md` § 6 «Despacho en paralelo», frase «Medido: el ciclo 2 corrió…» (este repositorio) | historico dentro de un párrafo normativo | Sacar una frase de un párrafo normativo lo reescribe: en la duda, se queda. |
| `AGENTS.md` § 13 «La invariante manda…» | normativo | La exige la sección 36 del banco (REQ-016 CA-10): CA-06, borde. |
| `requirements/README.md` (ambos) «Clases de hallazgo», párrafo «*(Medido en 1.35.0…)*» y «Riesgo declarado (SEC-139)» | historico / normativo | Citan SEC-115, SEC-118, SEC-132 y SEC-139: CA-05 (i). |
| `requirements/README.md` de este repositorio, § «El mapa de archivos», «Lo que NO se declara…» | normativo | Cita SEC-053 y SEC-020, abiertos: CA-05 (i). |
| `requirements/README.md` de este repositorio, § «La clase, el forzador y el vencimiento se CITAN…» | normativo | Cita R-015-01 y su registro. |
| `requirements/README.md` (ambos), los «Mal / Bien» de (a)–(d) | explicativo **en la duda** | Son el ejemplo de la forma exigida; sin ellos la regla se lee peor. Se anotan. |

## Barrido de citas antes de mover (CA-05 (iii))

- **Por texto**, en `docs/`, `requirements/` (REQ), `tests/`, `docs/seguridad/registro-seguridad.md` y
  `docs/PENDIENTES.md`: las citas a «Cómo se escribe un criterio que no se desmiente» nombran **la forma** (a)–(d)
  —ADR-004, REQ-007—, que se queda; «el caso medido que la origina» del propio README nombra REQ-016 CA-08, que
  sigue existiendo y queda en el puntero de (d). Ninguna cita al texto de los tres `_doc` movidos.
- **Por número de línea** (`archivo:línea`) a `AGENTS.md` y `requirements/README.md` hay 163 citas en 15
  archivos, `CHANGELOG.md` incluido (recuento del 2026-10-21 sobre `e1f23d2`). Son **fotos de estados anteriores**: la muestra comprobada (`docs/qa/REQ-029.md`, que cita
  `requirements/README.md:502`) ya no apuntaba a su texto **antes** de este cambio. Las marcas desplazan las
  líneas otra vez; no se reescriben (son evidencia fechada). Se declara como límite, no se repara.
- **Tras mover:** todo puntero nuevo resuelve —archivo, ancla e identificadores—; lo comprueba la sección 51 del
  banco (filas B4).
