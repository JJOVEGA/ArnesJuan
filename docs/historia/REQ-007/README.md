# REQ-007 — historia

Historia de `requirements/REQ-007.md`. **No es contrato:** el contrato vigente —la cabecera, los
criterios `CA-xx` y sus notas vigentes— sigue **íntegro** en el REQ. Aquí vive el **registro** de lo
que se decidió, se construyó, se midió o se preguntó sobre árboles **anteriores o iguales a
`v1.36.0`** (publicada el 2026-10-08, `main` = `f22b905`).

**Qué no es, dicho por su nombre:** no es una norma, no obliga a nada y no se consulta para saber qué
se exige hoy. Si un texto de aquí y un criterio del REQ dijeran cosas distintas, **manda el REQ**.
Nada se resumió, se reordenó ni se corrigió al moverlo: cada archivo es **copia verbatim** de un rango
de líneas de `requirements/REQ-007.md` en la cabeza `cecf9b6`, precedido de un encabezado de
**8 líneas** que es el único texto nuevo.

**De dónde viene esta partición.** Ficha **F-136-17**; undécima autorización del propietario
(2026-10-09) y sus resoluciones **P-137-A** y **P-137-B** (2026-10-12), literales en
`PENDING_APPROVAL.md` § Resueltas. El contrato que fija qué sale, a dónde va y cómo se comprueba que no se pierde ninguna
línea es `docs/arnes/v1.37.0-f136-17-fase1.md`; la prosa aplicada está en
`docs/arnes/v1.37.0-f136-17-fase2-prosa.md`.

**Original.** `git show cecf9b6:requirements/REQ-007.md` — **4 857 líneas, 868 108 bytes**, sin ningún
retorno de carro, `sha256` `bda82984e0fe032d6374166d31194c669e059986670d67f5787e1aaf9d53bed5`.

## Procedencia

Una fila por archivo. «Líneas en REQ-007» son las de la cabeza **`cecf9b6`**; los bytes son los
**medidos** por la coordinadora con `wc -c` sobre el cuerpo de cada destino (§5.1 del contrato), sin el
encabezado de 8 líneas. **Cada archivo es copia íntegra y sin resumir de su rango**: los punteros que
quedan en el REQ no lo repiten, y remiten aquí.

| Archivo | Qué contiene | Líneas en REQ-007 (`cecf9b6`) | N.º de líneas | Bytes medidos |
|---|---|---|---|---|
| `historial-1.31.0-1.33.0.md` | Filas del `## Historial de cambios` del 2026-09-05 y 2026-09-06 | 4793–4818 | 26 | 32 538 |
| `historial-1.35.0.md` | Filas del `## Historial de cambios` del 2026-09-27 al 2026-10-03 | 4819–4837 | 19 | 85 418 |
| `historial-1.36.0.md` | Filas del `## Historial de cambios` del 2026-10-05 al 2026-10-07 | 4838–4857 | 20 | 70 402 |
| `trazabilidad-origenes.md` | «Origen del Bloque G/H/I/J», causas raíz, write-backs y «Origen del registro de …» | 4180–4190 y 4192–4217 | 37 | 34 842 |
| `trazabilidad-tocado-por.md` | El valor histórico del campo `Tocado por:` (la clave y su última entrada se conservan en el REQ) | valor de 4191 | edición en sitio | 12 487 (el valor sin el prefijo `Tocado por: `) |
| `trazabilidad-correspondencias-1.35.0.md` | Las 6 primeras tablas `### Correspondencia con el encargo (…)` | 4219–4418 | 200 | 36 467 |
| `trazabilidad-correspondencias-1.36.0.md` | Las 16 tablas `### Correspondencia con el encargo (…)` restantes | 4419–4789 | 371 | 60 229 |
| `preguntas-resueltas.md` | El cuerpo entero de `## Preguntas abiertas / conflictos`: las cinco preguntas, todas resueltas | 3812–4177 | 366 | 34 900 |
| `notas-sedes-de-versionado.md` | De `## Notas / alcance`: «Construido en `9220c71`/`befc17a`» y las tres «Sedes y pruebas del versionado …» | 3602–3615 y 3737–3809 | 87 | 12 385 |
| `evidencia-ca67-68-1.36.0.md` | CA-67 y CA-68: las viñetas de **estado y de medición** de la construcción de 1.36.0 | 2286–2291, 2295–2297, 2299–2305, 2308–2320, 2325–2333, 3068–3096, 3116–3122 y 3132–3138 | 81 | 8 367 |
| `notas-de-versionado-en-criterios.md` | Notas de versionados ya rendidos dentro de CA-54, CA-58 y CA-60 | 1232–1261, 1429–1434 y 1465–1486 | 58 | 5 873 |

**Lo que NO se movió, y por qué — se lee junto con la tabla, no después.** Por las salvaguardas de
P-137-A: la **nota de CA-24** (69–116) y las **notas de versionado de CA-46** (228–264) se quedan en el
REQ —la primera porque **SEC-124**, hallazgo abierto, la cita por nombre; la segunda porque es el texto
que **manda hoy** («El texto de arriba se deja tal como se escribió; manda este versionado»), de modo
que moverla dejaría el enunciado superado diciendo lo contrario de lo que hace el código—. Dentro de
CA-67, CA-68 y CA-69 se quedan además la **medida obligatoria**, los **límites declarados**, **R2** (lo
cita SEC-130), el tope de **16 384 bytes**, el **plazo propio**, la **trampa de salida**, los **techos
de tamaño** y **E2 del punto 7 de CA-69** (lo cita QA-007-08). Detalle línea a línea en
`docs/arnes/v1.37.0-f136-17-fase2-prosa.md`.

**Corrección del 2026-10-13 (P-137-F; QA-007-19, QA-007-20 y QA-007-21).** La partición del 2026-10-12
había sacado texto vigente que hallazgos abiertos citan por su nombre. **Volvieron al REQ**, verbatim y en
su sitio, **CA-69 entero** —sus puntos 1 a 6 son el enunciado del criterio; SEC-132 y SEC-130 citan «CA-69
punto 3»— y las **cuatro viñetas «Punto 5» de CA-66** (1688–1709, 1781–1806, 1921–2012 y 2124–2153): los
movimientos que cada versionado declara, con «la regla, no un inventario» que SEC-124 cita. El archivo
`evidencia-ca69-1.36.0.md` dejó de existir, porque todo su contenido volvió. Los punteros nombran ahora
también REQ-009, REQ-901, O-16 y los hashes que sólo viven aquí. **El REQ queda por encima del techo de un
`Write`** (393 216 bytes); la salida de fondo es F-137-9.

**Segunda corrección, del 2026-10-13 (P-137-G; QA-007-22).** La pasada correctiva de QA encontró más texto
de CA-66 citado por hallazgos abiertos que seguía fuera: los «Punto 7» de compatibilidad (SEC-124) y las filas
LC10 (QA-023-23). Por decisión del propietario, **CA-66 volvió entero al REQ** y `evidencia-ca66-1.35.0.md`
dejó de existir. **La lección, en palabras del propietario:** «CA-66 no es registro, es contrato (clases de
movimiento, compatibilidad y filas contratadas que los hallazgos abiertos usan como sede). La regla «el rótulo
no inmuniza» vale para Historial, Trazabilidad, Preguntas, notas y CA-67/68, que QA ya probó sin
contraejemplos; para CA-66 no.»

## Comprobación de que no se perdió ninguna línea

Es la de `docs/arnes/v1.37.0-f136-17-fase1.md` §5.0 a §5.6, ejecutada sobre esta partición. Su salida
real va aquí; **ninguna cifra de este bloque se escribe sin su corrida detrás**.

```text
Comprobación §5 sobre el árbol de trabajo de cand/1.37.0, 2026-10-13, tras la segunda corrección (P-137-G) (coordinadora).
5.0 original: 4857 líneas, 868108 bytes, sha256 bda82984e0fe032d6374166d31194c669e059986670d67f5787e1aaf9d53bed5 (= git show cecf9b6:requirements/REQ-007.md)
    REQ-007 resultante: 3612 líneas, 479582 bytes, sha256 55958f2b15c23991514f16d4b952c3c075b7cef0a6506be1bcfb1e04b448cd71
5.2 rangos movidos: 21 tramos, 1265 líneas; disjuntos, dentro de 1-4857
5.3 destinos verbatim (cmp de tail -n +9 contra sus rangos):  11 ok (de 11)
5.4 REQ = original − rangos + texto nuevo declarado (13 líneas: punteros, «(ninguna)» y tres filas del Historial): diferencias fuera de líneas en blanco = 4 (esperadas 4: Archivos: y Tocado por:, antes y después)
5.5 líneas del original ausentes de REQ + destinos (por recuento): 2 - Archivos, Tocado por (las dos ediciones en sitio declaradas)
5.6 identificadores CA-xx desaparecidos del REQ: ninguno (69 distintos)
5.6 cabecera (1-13): líneas distintas = 2 (esperadas 2: Archivos: antes y después)
5.6 identificadores del original (CA/SEC/QA/R/P/F/ADR/INS/PR/REQ/O y hashes de 7, con o sin comillas) sin rastro desde el REQ: ninguno
5.6 hallazgos abiertos con sede en el REQ: 17 de 17
5.6 CA-66 entero (1532-2194 del original) en el REQ: verbatim; CA-69 entero (3139-3397): verbatim
5.6 enlaces ruta#ancla de los punteros: 11, que no resuelven: 0
5.6 lector del arnés: Ningún valor anómalo: la máquina lee los 29 REQ como están escritos.
5.6 mapa de archivos (tools/arnes-paralelo.sh REQ-007 REQ-023): docs/historia/REQ-007 en las rutas de REQ-007 = 1; «SIN DECLARAR» = 0
Puerta: las ediciones del REQ de las dos correcciones (P-137-F y P-137-G) fueron Edit juzgados en vivo por la instalación estable 1.36.0: ninguno denegado.
Presupuesto de Edit sobre este tamaño (4294967296 / bytes del REQ): 8955 bytes de old_string por llamada (era 4947 con el original). Lo mide QA con la puerta.
```

*(Esta salida la produjo la coordinadora tras la segunda corrección (P-137-G); sustituye a las anteriores, que están en el historial de git (`6afb686` y `5717659`). La pasada correctiva de QA vuelve a ejecutar §5 sobre el árbol comiteado **y no da por buena esta salida**.)*

## Punteros

- Contrato de la partición: `docs/arnes/v1.37.0-f136-17-fase1.md` (qué es historia, §1 y §2; destino,
  §3; enlaces y anclas, §4; comprobación, §5; presupuesto de escritura, §6; aritmética, §7).
- Prosa aplicada en la fase 2: `docs/arnes/v1.37.0-f136-17-fase2-prosa.md`.
- Ficha **F-136-17** en `docs/PENDIENTES.md`.
- Decisiones del propietario: `PENDING_APPROVAL.md` § Resueltas, undécima autorización (2026-10-09) y
  **P-137-A** a **P-137-E** (2026-10-12).
