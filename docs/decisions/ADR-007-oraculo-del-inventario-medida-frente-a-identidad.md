# ADR-007 — El inventario del banco compara bajo un oráculo que separa MEDIDA de IDENTIDAD, enunciado por propiedad y con un solo sitio
Fecha: 2026-09-08
Estado: aceptada
REQ: REQ-014 (CA-12, CA-14) · Versión: 1.33.0

## Contexto

CA-12 es el **criterio central** de REQ-014, y lo es por una razón medida: cuando el banco se
reorganiza, «el banco pasa» **no dice nada**. Dos casos que intercambian PASS y FAIL dan el mismo
total, y ésa es exactamente la forma en que un refactor del banco pierde cobertura sin que nadie lo
vea. Por eso el criterio no compara totales: compara el **inventario caso por caso**, byte a byte,
entre el banco anterior y el posterior.

Hasta el 2026-09-08 CA-12 exigía esa comparación **sin decir bajo qué normalización**, y el
instrumento que la producía normalizaba **una sola unidad**: `tests/escenarios/hooks/inventario.sh`
hacía `sed -E 's/[0-9]+ms/Nms/g'` **y nada más**.

**La medición desmintió el criterio, y lo hizo sin tocar nada.** Dos corridas **intactas** del banco
—el mismo árbol, dos veces— daban **884** casos las dos pero **74.046** y **74.047** bytes, y `cmp`
difería en el **byte 42.659, línea 548**: **20 de 884 líneas eran volátiles**, en `REQ-017
CA-03/04/08/09` y `REQ-021 CA-02/03/04/08`. Con tres corridas la dispersión era mayor todavía
(74.047 · 74.055 · 74.047 bytes; 25 líneas volátiles). El criterio **afirmaba una acreditación que su
instrumento no podía dar** —la forma de `SEC-050`—, y el hallazgo se registró como **DEV-014-02**
(`contrato`).

**La causa cabe en una línea, y es más interesante que el defecto.** El comentario de la línea 15 de
`inventario.sh` **ya declaraba la propiedad correcta**: «los milisegundos se normalizan a `Nms`: son
la **MEDIDA** de un caso, no su identidad». La propiedad estaba bien escrita; lo que envejeció fue su
**extensión**, que nombraba **una unidad** cuando la propiedad es «**todo** campo que es medida y no
identidad». Es la «extensión mal trazada» de REQ-023: el día que una sección publicó microsegundos,
cocientes, PID, sellos epoch o ternas sorteadas, la lista quedó corta y el criterio central del REQ
dejó de poder ejecutarse.

**Y CA-14 arrastraba lo mismo, con un remedio literal peor que el defecto.** CA-14 exige tres corridas
antes y tres después idénticas, y decía que un caso «inestable» **se estabiliza antes de particionar**.
Aplicado a la letra sobre esta medición, habría ordenado **borrar del banco las 20 líneas de medición
que REQ-017 y REQ-021 existen precisamente para publicar**: hacer el instrumento determinista
quitándole lo que mide.

## Decisión

**El inventario se compara bajo un oráculo enunciado por PROPIEDAD, no por lista de unidades, y esa
propiedad tiene un solo sitio: `tests/escenarios/hooks/inventario.sh`.**

1. **La propiedad.** Se normaliza **todo campo que sea MEDIDA o SORTEO de un caso y no su
   IDENTIDAD**; se conserva **intacto** todo lo demás. El criterio del REQ enuncia la propiedad y
   **no transcribe** la extensión: los ejemplos que cita van marcados **no exhaustivos**.
2. **El sitio único es el instrumento.** La regla completa —qué es designación y qué es magnitud—
   vive en `inventario.sh` y en ningún otro sitio. Enumerar las unidades en el REQ sería reincidir en
   el defecto que se está corrigiendo: una lista envejece con el primer campo volátil nuevo.
3. **La otra mitad, sin la cual el oráculo no mide nada (CA-12 (c)).** Se conservan **carácter por
   carácter** el **veredicto** (PASS/FAIL/SKIP), el **REQ y el CA** que el caso nombra y el **texto
   normativo** del identificador; y todo numeral que **designa** en vez de medir —pegado a un nombre,
   con tres o más partes (una versión o una fecha), entre comillas (la entrada que el caso ejercita)
   o entero suelto dentro del nombre del caso—. Un oráculo que normalizara «todo» saldría idéntico
   siempre: sería el mismo defecto en el otro extremo.
4. **El par discriminante es obligatorio (CA-12 (d)), y el negativo son TRES inyecciones.** Positivo:
   dos corridas intactas dan inventarios idénticos. Negativo: un caso **suprimido**, un caso
   **renombrado** y un caso cuyo **veredicto se invierte** de PASS a FAIL hacen fallar la
   comparación, y la salida **nombra el cambio** en cada uno. Un `rc ≠ 0` a secas no acredita nada
   —lo daría igual una comparación que falla siempre—, y las tres inyecciones son las tres formas en
   que un refactor pierde cobertura: cubrir una no acredita las otras dos.
5. **La dirección del error queda declarada.** Si algún día un caso publica una magnitud volátil como
   **entero suelto dentro de su nombre**, la regla **no** la normaliza y el positivo de CA-12 (d) se
   pone **rojo**. Es la dirección elegida a propósito: **un inventario que enrojece se investiga; uno
   que normaliza de más pierde casos en silencio**, que es exactamente el defecto que este oráculo
   viene a cerrar.
6. **CA-14 se corrige en la misma edición que descubre el defecto.** «Inestable» significa inestable
   **en su identidad o en su veredicto**, no en su medida: un caso que publica microsegundos, un
   cociente o una terna sorteada **es estable** a efectos del criterio, y quien lo estabiliza es el
   **oráculo**, no una corrección del caso.

## Alternativas consideradas

| Alternativa | Por qué no |
|---|---|
| **A — Enumerar las unidades** (`ms`, `µs`, `ns`, PID, epoch…) en el criterio o en el instrumento | Es el defecto que se está corrigiendo, escrito otra vez: la lista queda corta con el primer campo volátil nuevo, y esta vez ya sabemos el día en que pasa. Una regla sobre la **forma** de una magnitud cubre la unidad que nadie ha inventado todavía |
| **B — «Estabilizar» los casos volátiles**, que es lo que CA-14 decía literalmente | Habría ordenado borrar del banco las **20 líneas de medición** que REQ-017 y REQ-021 existen para publicar: hacer el instrumento determinista **quitándole lo que mide**. El remedio era peor que el defecto |
| **C — Comparar sólo el total de casos**, o el recuento por veredicto | Es la comparación que CA-12 existe para no hacer: dos casos que intercambian PASS y FAIL dan el mismo total, y un refactor pasa desapercibido |
| **D — Normalizar todo numeral** | El inventario saldría idéntico siempre y no distinguiría nada. Un oráculo que no puede fallar no acredita: es el defecto en el otro extremo |
| **E — Dejar CA-12 como estaba y abrir un hallazgo `instrumento`** | El criterio **central** de un REQ `critico` seguiría afirmando una acreditación que su instrumento no puede dar, que es la deriva que `AGENTS.md` §9 prohíbe. Y sin comparación ejecutable, la partición del banco no se podía acreditar |
| **F — Fijar las semillas y el reloj** para que las corridas sean deterministas | Cambia el sujeto medido: las ternas sorteadas y los tiempos son lo que esas secciones publican. Un banco que no varía porque se le quitó la variación no mide el sistema que dice medir |

## Consecuencias

- (+) **CA-12 y CA-14 vuelven a ser ejecutables**, y están acreditados sobre el árbol: dos corridas
  intactas dan **884** líneas, **73.508** bytes y `cmp` limpio, y CA-12 se aplicó **al propio cambio**
  que lo introduce.
- (+) **El oráculo sobrevive al campo volátil que todavía no existe**, porque decide por la **forma**
  de lo escrito (notación de magnitud, evidencia publicada tras el nombre) y no por un catálogo.
- (+) **El criterio y el instrumento dejan de tener dos sedes.** La extensión vive donde se ejecuta;
  el REQ enuncia la propiedad. Es la misma doctrina de `ADR-005` aplicada a un instrumento de
  comparación.
- (+) La partición del banco quedó acreditada con él: **8 de 9** corridas byte a byte idénticas, y la
  novena difirió en **una** línea (`REQ-017 CA-09`, PASS→SKIP) que es no determinismo **preexistente**
  con dueño `SEC-030`, acreditado con `worktree` sobre HEAD — ni se introduce ni se empeora.
- (−) **Dos casos que se distinguen SÓLO por una magnitud son indistinguibles** bajo un oráculo que
  borra magnitudes. Hoy: **1 grupo de 2 líneas**. *Mitigación:* no es un defecto del oráculo, es lo
  que significa borrar la magnitud; y **suprimir** cualquiera de las dos **sí se detecta**, porque
  cambia la multiplicidad de la línea.
- (−) **Una letra pegada a un numeral no distingue una unidad de un ordinal** (`el 2o guardián` sale
  `el No guardián`): 1 línea medida, sin colisión. *Mitigación:* está declarado como límite en el
  propio instrumento, con su recuento.
- (−) **Una cota normativa que viva en la evidencia se normaliza con ella** (`techo 2.600×`), porque
  ahí no hay forma de distinguirla de lo medido. *Mitigación:* el sitio único de una cota normativa
  es el texto de la sección, no el inventario.
- (−) **El oráculo es ahora un instrumento con criterio propio**, y un instrumento puede equivocarse
  hacia normalizar de más, que es el error silencioso. *Mitigación:* la **dirección del error está
  declarada** (ante la duda, rojo) y los **tres negativos están automatizados** en
  `autoprueba-corredor.sh`, cada uno nombrando lo que cambió.

## Alcance

Es la segunda de las dos re-derivaciones de la reapertura de REQ-014 del 2026-09-08; la primera —el
techo de CA-18— está en `ADR-006`, que explica además por qué la reapertura se documenta en dos ADR y
no en uno. Este ADR **no supersede** a ningún ADR anterior.

## Enlaces

- `requirements/REQ-014.md` — CA-12 (b)(c)(d), CA-14 y CA-31 (b). Hallazgo **DEV-014-02**
  (`contrato`, forma de `SEC-050`).
- `tests/escenarios/hooks/inventario.sh` — el oráculo, su límite honesto medido y su recuento; es su
  **sitio único**.
- `tests/escenarios/hooks/autoprueba-corredor.sh` — el par discriminante de CA-12 (d), con las tres
  inyecciones. Commit `9809fc2`.
- `ADR-006` — la otra re-derivación de la misma reapertura.
- `ADR-005` — la doctrina de la que esto es un caso: el instrumento de medida vive una sola vez, y su
  regla vive donde se ejecuta.
