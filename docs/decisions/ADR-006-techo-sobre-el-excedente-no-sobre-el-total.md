# ADR-006 — El techo de una sección del banco se pone sobre su EXCEDENTE, no sobre su total: `líneas(f) ≤ max(N, piso(f) × k)`
Fecha: 2026-09-08
Estado: aceptada
REQ: REQ-014 (CA-18) · Versión: 1.33.0

## Contexto

REQ-014 partió el banco en archivos por sección para que dos comisiones de QA pudieran trabajar a la
vez y para que una comisión no tuviera que leer 4 096 líneas para tocar cuarenta. **CA-18 es el
criterio que mide esa promesa**, y hasta el 2026-09-08 la medía con un literal absoluto: «ningún
archivo de `secciones/` supera las **400** líneas; si alguna sección no cabe, se parte en dos».

**El defecto no fue el número: fue que nadie comprobó que existiera alguna partición que lo
cumpliera.** El 400 se escribió sin medir el mínimo por debajo del cual ningún archivo de sección
puede bajar. Cuando se midió —el 2026-09-08, sobre `cand/1.33.0`, **antes de meter un solo caso**—
las dos secciones 37 tenían un mínimo autónomo de **461** y **468** líneas contra un techo de **400**.
No existía ninguna partición conforme: el criterio era **insatisfacible**, y la consecuencia no fue
teórica — la puerta requerida de `main` (`hooks-en-linux`) quedó **roja sin ninguna acción conforme
disponible**, con la fusión de 1.33.0 bloqueada. Es la clase de `DEV-021-05`: **un criterio derivado
sin comprobar su factibilidad**, registrado aquí como **DEV-014-01** (`contrato`).

### Por qué ese mínimo existe y no lo elige quien escribe la sección

`piso(f)` —el **mínimo autónomo** de un archivo— es la parte que **ninguna partición baja**, porque
partir `f` en dos produce **dos** pisos y no medio piso. Lo imponen tres invariantes del propio
REQ-014, que se multiplican:

- **CA-04** — cada sección corre en **su propio subshell** y en paralelo (`ARNES_JOBS`), y el **sitio
  único** de los ayudantes compartidos es el corredor ⇒ todo archivo partido tiene que ser
  **autocontenido**;
- **CA-19** — **ninguna** sección hace `source` de otra (comprobado en `autoprueba-corredor.sh`);
- **H-04** — el corredor **aborta**, antes de ejecutar nada, ante cualquier entrada de `secciones/`
  que no case `NN-<slug>.sh` ⇒ **tampoco cabe un archivo auxiliar** allí.

No hay tercera vía: la maquinaria que dos mitades comparten **se duplica o se sube al corredor**.
Subirla es **cambio de mecanismo** —cambia el conjunto que `autoprueba-corredor.sh` deriva y vigila—,
exige analista y auditor, y el propietario **no la eligió** (era la opción B de la entrada del
2026-09-08 en `PENDING_APPROVAL.md`; eligió la A).

### Y el total de líneas era, además, la magnitud equivocada

Un archivo cuyo piso es 461 **no se lee más barato partiéndolo**: quien toque cualquiera de las dos
mitades lee las 461 líneas de piso igual. El total mide algo que la partición no puede mejorar.
«Líneas por caso» tampoco sirve, y está medido el mismo día: **65,3** líneas por caso en
`37-coste-del-escaner-1-…` frente a **4,1** en `07-bash-falsos-positivos.sh` —un factor **16×** que es
exactamente la maquinaria no factorizable, no la prolijidad de nadie—. Medir por líneas-caso
castigaría a la sección que mide caro por medir caro.

## Decisión

**El techo deja de ser un total absoluto y pasa a ser una regla sobre el excedente.** Para cada
archivo `f` de `secciones/`:

```
líneas(f)  ≤  max( N , piso(f) × k )        N = 400 · k = 1,25
```

1. **`N` = 400 no cambia**, y ésa es la mitad importante de esta decisión. Mismo número, mismo tipo
   **operativo**, misma dirección admitida **hacia abajo** (se baja con la medición, entrada en el
   Historial, **sin** ADR). Lo que cambia es **a qué se aplica**: gobierna los archivos cuyo piso
   cabe holgadamente por debajo de él, que tras la partición son **48 de 50**. Para que `piso × k`
   supere a `N` hace falta `piso ≥ 321`.
2. **`piso(f)` lo declara cada sección** en `PISO_AUTONOMO_SECCION`, junto a su
   `CASOS_ESPERADOS_SECCION`, **con su derivación término a término en la misma línea**:
   `preámbulo + maquinaria compartida duplicada + bloque indivisible mayor`.
3. **La máquina comprueba la aritmética, y sólo la aritmética** (`ca18_deriva()` en
   `tests/escenarios/hooks/autoprueba-corredor.sh`, una sola pasada de `awk` sobre el corredor y las
   secciones): **(a)** que **todos** los archivos declaran, y quien no lo haga sale **nombrado**;
   **(b)** que los términos escritos **suman** el valor declarado, y que una derivación de menos de
   tres términos o que la máquina no puede leer es **ILEGIBLE** y no se da por buena —fail-closed—;
   **(c)** que `piso(f) ≤ líneas(f)`. Y **publica** una fila por archivo (líneas · piso · techo ·
   quién gobierna · líneas duplicadas) **sin compararla**: la duplicación es exactamente lo que las
   tres invariantes imponen, y un ABORT ahí sería un **rojo sobre código correcto** —la clase de rojo
   que ya produjo H-11 y la que enseña a desactivar el control—.
4. **`k` = 1,25 es un literal con derivación escrita**: el mayor de los cocientes `líneas / piso` de
   las particiones conformes medidas el 2026-09-08, redondeado hacia arriba al siguiente múltiplo de
   0,05 —`565/461 = 1,2256`; `468/468 = 1,000`; `516/460 = 1,122`; `511/467 = 1,094` ⇒ **1,2256 →
   1,25**—. Es **operativo**, su dirección admitida es **hacia abajo**, y **subirlo relaja el
   criterio**: exige ADR nuevo más la comprobación de CA-35. Esa puerta es la que impide la
   circularidad de derivar `k` de lo que alguien acabe construyendo.
5. **`k` se re-deriva en la misma edición que cambie cualquiera de sus términos** —CA-04, CA-19,
   H-04, la maquinaria compartida o la mejor partición medida—. La obligación **ya se ejerció** el
   mismo día: al corregirse el piso en una línea, el cociente que gobierna pasó de `564/460 = 1,226`
   a `565/461 = 1,2256`, sigue ≤ 1,25, y **`k` se re-derivó sin cambiar**.
6. **`max(…)` y no sólo la razón, comprobado ANTES de escribir el techo** —que es justo el paso que
   faltó la vez anterior—: con sólo `piso(f) × k`, un archivo de 12 líneas con piso ~5 tendría techo
   6,25 y **~42 archivos hoy conformes saldrían rojos**. La razón describe la conducta de los
   archivos cuyo piso ya excede `N / k` = 320, y de ninguno más.
7. **El remedio y su salida.** Si un archivo excede su techo, se parte **en tantas partes como haga
   falta para que cada una quepa bajo SU propio techo derivado**: el número de partes lo decide la
   aritmética parte por parte, no la costumbre. Y si **ninguna** partición cabe, el defecto es **del
   piso, no del archivo**: vuelve al analista con la medición, y sólo hay dos salidas, las dos con
   gate —subir la maquinaria al corredor (analista + auditor + ADR) o re-derivar `k` (ADR + CA-35)—.
   **Prohibidas por nombre**, porque son las que aparecen como atajo: `continue-on-error` en el paso
   de la autoprueba y sacar CA-18 del CI. Las dos ponen la puerta requerida en verde **apagando la
   señal**, que es el modo de fallo que `AGENTS.md` §13 describe.

### Por qué NO se compró el techo con una cifra nueva

Subir el 400 a 500 o a 700 habría sido **el mismo defecto con otro número**: un literal absoluto
elegido para que quepa lo que hoy hay, sin ninguna razón que sobreviva al archivo siguiente. El
mínimo es **estructural** —lo imponen CA-04, CA-19 y H-04, no la prolijidad de quien escribe—, y el
sujeto que se mide no se puede deformar. Lo que estaba mal no era la magnitud del número: era que el
techo se aplicaba al **total** cuando la partición sólo puede actuar sobre el **excedente**.

## El límite honesto, que es la consecuencia más importante de esta decisión

El término **bloque indivisible mayor** es una **afirmación sobre la estructura**, no una medición:
**ninguna máquina de este banco decide** si dos casos pueden vivir en archivos distintos. Lo que
CA-18 comprueba es que los términos **sumen**, no que sean **ciertos**. Dicho en la forma en que lo
dice el propio código (`autoprueba-corredor.sh`, §CA-18): **«un piso INFLADO afloja el techo sin que
ninguna puerta grite»**.

Contra eso hay dos cosas, y **ninguna es una puerta**: la derivación **escrita** en cada archivo, que
un lector puede falsificar término a término, y la regla de procedimiento —**el techo no se compra
deformando el sujeto**—. Inflar el piso para caber es **regresión**: devuelve el hallazgo a
`contrato`, y `contrato` bloquea el cierre. La única defensa real es la revisión humana y la
auditoría; se escribe aquí, y no en una nota, porque es la parte de esta decisión que un año después
nadie recordaría haber aceptado.

### Y esa consecuencia se validó el mismo día en que se escribió

Al despachar la partición (commit `b9afa01`), el desarrollador midió el piso de la mitad-B de
`37/1` **honestamente** y le salió **295** cuando, para que 431 líneas fuesen conformes, harían falta
**345** —es decir, un bloque indivisible de **≥ 196**—. **El mayor bloque indivisible real de esa
mitad mide 146.** No existía. Declarar 345 habría hecho pasar el archivo, y las comprobaciones
**(a)(b)(c) lo habrían dado por bueno, porque los términos suman**. En vez de eso, `37/1` se partió
en **tres**.

Es exactamente el límite honesto funcionando en su primer uso: la máquina no lo habría impedido, y lo
impidió la regla escrita. Resultado sobre el árbol: **50** secciones, autoprueba de **105 PASS · 1
FAIL** a **106 PASS · 0 FAIL** (rc 0), `CASOS_ESPERADOS = 884` sin tocar, **48 de 50** archivos
gobernados por `N` y **2** por `piso × k` (577 líneas con techo 588; 468 con techo 579), sin regresión
de reloj (mediana 39,8 s antes, 39,7 s después).

## Alternativas consideradas

| Alternativa | Por qué no |
|---|---|
| **A — Subir el literal a una cifra nueva** (500, 700) | El mismo defecto con otro número. El mínimo es estructural, no de estilo, y el techo seguiría midiendo el **total** cuando la partición sólo puede actuar sobre el **excedente** |
| **B — Subir la maquinaria compartida al corredor** para que el piso baje | Es **cambio de mecanismo**: cambia el conjunto que `autoprueba-corredor.sh` deriva y vigila. Exige analista, auditor y ADR propio, y **el propietario eligió A** (`PENDING_APPROVAL.md`, 2026-09-08) |
| **C — `continue-on-error` en la autoprueba, o sacar CA-18 del CI** | Pone la puerta requerida en verde **apagando la señal**. `AGENTS.md` §13: un guard apagado protege menos que uno parcial. Es precisamente lo que este criterio existe para evitar |
| **D — Sólo la razón `piso(f) × k`, sin `max(…)`** | Comprobado antes de escribir el techo: ~42 archivos hoy conformes saldrían rojos (un archivo de 12 líneas con piso 5 tendría techo 6,25). La razón sólo describe a los archivos cuyo piso ya excede `N / k` |
| **E — Medir «líneas por caso»** | 65,3 frente a 4,1 en el mismo árbol: un factor **16×** que es maquinaria no factorizable. Castigaría a la sección que mide caro por medir caro |
| **F — Dejar CA-18 en 400 y bloquear REQ-014** | Era la opción C que el propietario no eligió: la partición no se hace y 1.33.0 no se fusiona. Castiga el trabajo correcto por un defecto de derivación del criterio |
| **G — Que la máquina decida el «bloque indivisible mayor»** | Ninguna máquina de este banco puede decidir si dos casos pueden vivir en archivos distintos. Intentarlo produciría un veredicto inventado con apariencia de medida, que es peor que un límite declarado |

## Consecuencias

- (+) **El criterio vuelve a ser satisfacible**, y con configuración verde demostrada: el
  interbloqueo que dejó `hooks-en-linux` roja sin acción conforme se cerró el mismo día.
- (+) **El techo mide lo que la partición puede cambiar.** Un archivo con piso alto ya no se parte
  para no ganar nada; uno con piso pequeño sigue gobernado por `N` = 400, que es la conducta que el
  criterio tenía y que se conserva para 48 de 50 archivos.
- (+) **El interbloqueo tiene salida nombrada** (punto 7) y las dos formas de apagarlo están
  prohibidas por nombre, no por costumbre.
- (+) `k` nace con **derivación escrita y obligación de re-derivarse**, así que no puede envejecer en
  silencio como envejeció el 400.
- (−) **El término «bloque indivisible mayor» no lo decide ninguna máquina, y un piso inflado afloja
  el techo sin que nada grite.** *Mitigación:* la derivación va **escrita y es falsificable término a
  término**; inflarla es regresión declarada que devuelve el hallazgo a `contrato`; y la tabla de
  `ca18_deriva()` publica por archivo líneas, piso, techo, quién gobierna y cuántas líneas están
  duplicadas, que es la evidencia con la que un revisor humano la falsifica. La primera vez que hizo
  falta, funcionó (`37/1` a tres partes).
- (−) **Dos literales que hay que mantener vivos** (`N` y `k`) donde antes había uno.
  *Mitigación:* los dos declaran tipo **operativo** y dirección **hacia abajo**; bajarlos no exige
  ADR, subir `k` sí, y la obligación de re-derivación está escrita en el criterio y ya se ejerció una
  vez el mismo día.
- (−) **El techo de un archivo puede subir sin que nadie lo pida**, si su piso crece por una razón
  legítima (maquinaria compartida nueva). *Mitigación:* el piso crece sólo editando la declaración, y
  esa edición es visible en el diff y falsificable contra sus tres términos.
- (−) La comprobación **no distingue** un piso honesto de uno cómodo, así que **la revisión humana es
  parte del control**, no un extra. Está escrito en el criterio, en el código y aquí.

## Alcance y numeración

REQ-014 pedía «un ADR que cubra la reapertura y las dos re-derivaciones (CA-18 y CA-12)». Se entrega
como **dos** ADR, porque son **dos decisiones con sujeto, alternativas y consecuencias distintas** —un
techo derivado del piso y un oráculo de igualdad— y un ADR titulado por el suceso que las juntó
(«la reapertura») sería ilocalizable dentro de un año. **Entre ADR-006 y ADR-007 queda cubierta la
reapertura del 2026-09-08 y sus dos re-derivaciones**; ninguno supersede a ningún ADR anterior.

El tercer cambio de fondo de este REQ —estrechar lo que promete la guarda estática de CA-06 (H-03)—
**ya tiene su ADR: `ADR-002`**, escrito el 2026-09-06. No estaba pendiente: lo que faltaba era su
enlace en el Historial.

## Enlaces

- `requirements/REQ-014.md` — CA-18 (i)(ii)(iii), y CA-04, CA-19 y H-04, que son los tres términos
  que imponen el piso. Hallazgo **DEV-014-01** (`contrato`).
- `ADR-007` — la otra re-derivación de la misma reapertura (el oráculo del inventario, CA-12).
- `ADR-002` — la misma forma aplicada a otro control del mismo REQ: el criterio describe lo que la
  máquina cumple, y lo que la máquina no puede decidir se declara en vez de prometerse.
- `PENDING_APPROVAL.md` — entrada del 2026-09-08 «La partición autorizada es IMPOSIBLE»: el
  propietario eligió la opción **A** (re-derivar el techo) sobre la **B** (subir la maquinaria al
  corredor) y la **C** (bloquear).
- `tests/escenarios/hooks/autoprueba-corredor.sh` — `ca18_deriva()` y el par discriminante de
  CA-18 (iii). Commits `9809fc2` (la máquina) y `b9afa01` (la partición que la puso en verde).
