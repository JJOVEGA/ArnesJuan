# Candidato de estabilización sobre v1.33.0

Estado: candidato validado localmente; no es una versión publicada ni un cierre de hallazgos.
Seguridad: aprobado (R-030, 2026-09-11, sobre d82d6cd — no la mide ninguna puerta; SUSTITUYE al con-hallazgos de R-029 del 2026-09-10, que NO se retira porque cubre el árbol de entonces y es la causa de la corrección)
QA: aprobado (vuelta 1 de 2, 2026-09-10) sobre a8e332a — PENDIENTE de extender a la cabeza final: ver el aviso de orden de abajo

> **Ese campo no lo mide nada, y va dicho dentro del propio campo a propósito.** Este
> parche **no tiene REQ**, así que `guard-completado` no lee esta cabecera ni la puede
> hacer cumplir: un campo que *parece* medido y no lo está es la familia de `SEC-079`,
> y el auditor pidió expresamente que se declarara aquí.
>
> **`SEC-087`** (`contrato`) —el hallazgo que detuvo la primera firma— está **remediado en cinco
> sedes** y su condición de cierre **se cumple**, verificado en `R-030`. **No se cierra**: el
> propietario prohibió cerrar hallazgos en su nombre, y ni la coordinadora ni el auditor lo hacen.
> `SEC-088` sigue **abierto** y diferido, sin bloquear.
>
> **AVISO DE ORDEN, y es el único pendiente real del parche.** El veredicto de QA cubre `a8e332a`;
> desde entonces `a529c49` y `d82d6cd` editaron
> `tests/escenarios/hooks/secciones/40-estabilizacion-firmas-y-rigor.sh`, que §6 clasifica como
> **crítico**, y uno de ellos cambia el **nombre de un caso**, que es parte de la salida inventariada.
> **Y no existe en disco ninguna corrida del banco sobre esta cabeza**: el único artefacto conserva el
> nombre viejo del caso, lo que prueba que es anterior. Las cifras que circularon llegaron **por
> conversación**, y §14.B.7 dice que eso **no es evidencia**. El orden del §6 se completa cuando el
> banco se haya ejercido **sobre esta cabeza**, con su salida en disco.

Base de código: `810128abd5d5b1ca9a240bde98192a9a0c51447c` (tag v1.33.0).
Traspaso consultado: `1dfe31bcb71dcf914f2124f40536bcde2d4019a3`.
Autorización: el propietario pidió tomar el relevo el 2026-09-10, tras detener
Claude, para preparar cambios y pruebas en una copia aislada. No incluye publicar.

## Alcance verificable

1. **D16 / QA-016-04 — ENUNCIADO CORREGIDO EN v1.33.2; ver §«El parche v1.33.2».**
   ~~Un nivel de rigor válido con evidencia parentética final conserva el mismo
   nivel que sin esa evidencia.~~ Esa promesa, tal cual, es la que abrió el
   fail-open de `QA-P48-01`: enunciada sin dirección, autoriza tanto subir
   `critico (por suelo)` —que era el arreglo— como **bajar** `ligero (local)`
   hasta la exención de QA, que no era. El enunciado vigente lleva dirección **y
   alcance**: **un matiz parentético BIEN FORMADO —el que cierra el paréntesis al
   final del valor— puede SUBIR o MANTENER el rigor efectivo; nunca bajarlo.** Un
   paréntesis sin cerrar no es un matiz: es un valor desconocido, cae en la
   derivación heredada y por ahí un `critico` de un REQ no sensible se juzga
   `estandar` (`SEC-087`, vía **preexistente**, ver §«El parche v1.33.2»). Se
   sigue usando la normalización común, y `critico (por suelo)` —cerrado— en un
   REQ no sensible sigue sin caer a `estandar`.
   Ausencia y valores realmente desconocidos conservan la derivación de v1.33.0;
   endurecer esa política queda fuera de este candidato.
2. **SEC-084:** al cambiar el valor efectivo de Seguridad a aprobado, la guarda
   aplica el control de orden existente también si la clave tiene decoración
   aceptada por el lector o si Edit sustituye sólo el valor. QA pendiente o
   con-hallazgos deniega; QA aprobado permite. No se añade una lista alternativa
   de claves al disparador.
3. **Ediciones legítimas:** mencionar campos en el cuerpo o editar texto ajeno
   a la firma no se trata como una nueva firma sólo porque exista una aprobación
   antigua en la cabecera. Seguridad preventiva conserva su conducta.
4. **Vías:** ejercer Write, Edit y MultiEdit contra el hook real, con archivos y
   sustituciones válidas. Los controles comprueban decisión y diagnóstico.
5. **Discriminación:** las regresiones del parche fallan en la base y pasan en
   la candidata. El banco existente y su autoprueba se conservan; no se cambian
   techos de rendimiento ni se repite hasta conseguir verde.

## Límite de seguridad y compatibilidad

Este candidato no garantiza frescura de la firma respecto del commit, no resuelve
homóglifos ni la ausencia de QA (SEC-083), y no modifica rotación, manifiesto,
workflow, estados de los REQ existentes ni sus aprobaciones. Una firma ya presente
no se revalida por una edición de prosa. La comprobación de ausencia heredada no
se presenta como protección nueva.

Las referencias D16/SEC-084 proceden del traspaso y del registro de seguridad de
[1dfe31b](https://github.com/JJOVEGA/ArnesJuan/tree/1dfe31bcb71dcf914f2124f40536bcde2d4019a3).
No se copian datos ni informes de proyectos consumidores.

## Entrega

Diff aplicable sobre la base, pruebas reproducibles y revisión independiente.
Las revisiones realizadas aquí no se presentan como firmas de QA Opus del
pipeline de Claude. No se cambia el número de versión ni se marca ningún REQ
completado. La aprobación de publicación y el portado a 1.34.0 quedan pendientes.

## Resultado local — 2026-09-10

La nueva sección de regresión da 17 PASS en la candidata; sobre la base del tag
da 6 PASS y 11 FAIL. Las secciones relacionadas dan 39 PASS. `bash -n`, los JSON
del plugin y `git diff --check` pasan.

El banco completo de la candidata terminó en 889 PASS, 3 FAIL y 9 SKIP. Los tres
FAIL tienen el mismo identificador que los observados contra la base en esta
máquina: CA-04 de recorte y los dos casos de descendencia de REQ-021 CA-04.1.
El banco no está verde, por lo que este resultado no autoriza una publicación.

---

# El parche v1.33.2 — `QA-P48-01`

Base de código: `a630dc6` (tag `v1.33.1`, punta de `main`).
Rama: `hotfix/1.33.2-rigor`. Autorización expresa del propietario, 2026-09-10.

## El defecto

`v1.33.1` cerró un fail-open y **abrió otro más ancho**. El candidato enrutó la
forma con paréntesis por el lector común **para todos los valores**. En `critico`
eso corrigió D16. En `ligero` regaló una exención: `ligero` es el **único** nivel
exento de `QA: aprobado` (`AGENTS.md` §6), así que un REQ **no sensible** con
`Rigor: ligero (<cualquier matiz>)` pasó a **cerrarse sin QA y sin veredicto de
seguridad**, donde `v1.33.0` lo denegaba.

La conducta anterior —«valor no reconocido: se ignora y se cae al defecto de la
sensibilidad»— no era un descuido que el candidato corrigiera: en `ligero` era
**protectora**. Ese es el punto que el enunciado sin dirección no distinguía.

| `Rigor:` con `Sensible a seguridad:` ≠ sí | v1.33.0 | v1.33.1 | **v1.33.2** |
|---|---|---|---|
| `ligero`                   | `ligero`   | `ligero`     | **`ligero`** |
| `ligero (local)`           | `estandar` | `ligero` ⚠️  | **`estandar`** |
| `ligero (D8, 2026-09-08)`  | `estandar` | `ligero` ⚠️  | **`estandar`** |
| `ligero(sin espacio)`      | `estandar` | `ligero` ⚠️  | **`estandar`** |
| `ligero ()`                | `estandar` | `ligero` ⚠️  | **`estandar`** |
| `ligero (critico)`         | `estandar` | `ligero` ⚠️  | **`estandar`** |
| `estandar (x)`             | `estandar` | `estandar`   | **`estandar`** |
| `critico (por suelo)`      | `estandar` | `critico` ✅ | **`critico`** |

## La propiedad

**Enunciado contractual vigente.** Lo redactó el propietario el 2026-09-10 y lleva
desde el 2026-09-11 la **condición de buena formación** que exige `SEC-087` (abajo):
el propietario había pedido escribirlo *«verificando que coincida con el código»*, y el
auditor demostró que sin esa condición **no coincide**. Es el texto que va literal en
`requirements/README.md` y en su plantilla heredada, y manda sobre cualquier paráfrasis
de este documento:

> El rigor efectivo combina el nivel declarado con el suelo de seguridad. Un matiz
> parentético **bien formado** —el que **cierra el paréntesis al final del valor**, como
> `critico (por suelo)`— conserva `estandar` y `critico`, sujeto a ese suelo. Para
> mantener la protección heredada, `ligero` con matiz deriva a `estandar` si el REQ no
> es sensible y a `critico` si lo es. `ligero` sin matiz conserva su comportamiento,
> sujeto al suelo de seguridad.
>
> **Un paréntesis que no cierra al final del valor no es un matiz: es un valor
> desconocido**, y cae en la derivación heredada. `critico (por suelo` (sin cerrar),
> `critico (` y `critico (x) y` (con texto detrás del cierre) se juzgan **`estandar`**
> en un REQ no sensible, así que un `critico` escrito así **deja de exigir la firma de
> seguridad, y no avisa**. Es la única protección que esta forma puede perder: en
> `ligero` y en `estandar` la derivación heredada da lo mismo, y en un REQ sensible el
> suelo de `critico` lo impide. Escribe el matiz cerrado, o no lo escribas.

Enuncia las **dos ramas** de `ligero` con matiz en vez de remitir al «nivel heredado»,
así que se puede comprobar contra la conducta sin traducir nada. La forma corta que
gobierna el código es la misma regla vista desde la implementación — **con su alcance,
que es la mitad que faltaba**:

> **Un matiz BIEN FORMADO puede SUBIR o MANTENER el rigor efectivo; nunca bajarlo.**

Operativamente, en `arnes_rigor_efectivo` (`hooks/lib.sh`): se desenvuelve el
paréntesis, se calcula el nivel candidato y se toma **el más restrictivo** entre
ese candidato y el **nivel heredado** —el que la sensibilidad da por defecto, que
es exactamente lo que ese mismo valor daba antes de que el desenvoltorio
existiera—. El suelo de seguridad se aplica después y sigue mandando.

**Y el alcance sale del código, no de la prudencia:** `arnes_veredicto` desenvuelve
**sólo si el valor termina en `)`**. Si no termina así, el valor entero deja de
reconocerse y `arnes_rigor_efectivo` retorna por su rama de «valor no reconocido»
**antes** de llegar a la guarda del más restrictivo. `max(declarado, heredado)` **no
corre** en ese camino — por eso la promesa sin condición era falsa, y no por un
descuido de redacción.

No es un caso especial: es la doctrina que el proyecto ya tiene escrita en
`AGENTS.md` §6 («el rigor se puede subir, nunca bajar») y la regla de que una
guarda sólo puede **estrechar**. Un paréntesis es evidencia que alguien añadió a
mano: puede pedir más ceremonia, no regalar una exención.

`arnes_campos_normaliza` anota en `ARNES_RIGOR_MATIZ` que el nivel salió de
desenvolver un paréntesis. Sin ese dato, `arnes_rigor_efectivo` no puede
distinguir `ligero` escrito a secas de `ligero` obtenido desenvolviendo, que es
justo la distinción que el candidato perdió. La función sigue siendo idempotente.

**Consecuencia que hay que saber, y es deliberada:** no existe forma de declarar
`ligero` **con** matiz. Quien quiera la exención escribe `Rigor: ligero` a secas
y pone la evidencia en el cuerpo del REQ. La exención de QA es justo lo que no
debe poder concederse de pasada.

## Que ningún caso antes denegado pase a permitido

El argumento tiene **dos mitades de distinto peso probatorio**, y mezclarlas sería
vender un barrido como un teorema:

1. **Medido por barrido, NO demostrado.** El rigor efectivo de v1.33.2 es **mayor o
   igual** que el de v1.33.0 en las **144 combinaciones**
   `(Rigor:, Sensible a seguridad:)` barridas comparando ambos lectores: **0
   regresiones**, y los únicos cuatro cambios son hacia arriba (la corrección D16
   conservada). El dominio real de `Rigor:` es **abierto** —es texto tecleado a
   mano—, así que 144 combinaciones son **evidencia del barrido, no una prueba
   universal**. Cubrir todas las ramas relevantes del lector es encargo de QA.
2. **Por construcción.** Las exigencias de la puerta crecen de forma **monótona**
   con el nivel: `ligero` ⊂ `estandar` (QA) ⊂ `critico` (QA + seguridad), en
   `hooks/guard-completado.sh`. Esto no depende de ninguna muestra.

De (1) y (2): **en el dominio barrido**, un caso sólo puede pasar de permitido a
denegado, nunca al revés. La monotonía de (2) garantiza que **cualquier** entrada
cuyo rigor no baje tampoco puede aflojar la puerta; lo que el barrido sostiene —y no
demuestra— es el antecedente «el rigor no baja».

## Evidencia

- Sonda del propietario reproducida contra los **tres** árboles antes de tocar
  nada: tag `v1.33.0`, `v1.33.1` publicada en la caché del plugin y este
  worktree. Las tres columnas de la tabla salen de ahí.
- **Fail-before / pass-after**, midiendo la **conducta de la puerta** y no el
  lector: contra
  `~/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.1/hooks` los casos nuevos
  dan **6 FAIL** (los seis discriminantes); contra este árbol, **28 PASS · 0
  FAIL** en la sección 40 completa.
- Los cinco casos que pasan en ambos lados **no sobran**: fijan las filas que no
  se pueden mover (`ligero` limpio conserva su exención, `estandar (x)` sigue
  pidiendo QA, `critico (por suelo)` conserva la corrección de v1.33.1, el suelo
  de seguridad sigue mandando sobre el piso del matiz). Sin ellos, «apretar de
  más» y «arreglar» serían indistinguibles.
- Contabilidad cuadrada: sección 40 `17 → 28` casos, `CASOS_ESPERADOS`
  `901 → 912`, `PISO_AUTONOMO_SECCION` `20 → 53`. El caso 12.º no suma porque
  `D16: ligero con matiz sigue ligero` **declaraba `allow` sobre el propio
  fail-open** y se corrigió en su sitio en vez de añadirse: una prueba que fija
  la conducta defectuosa como esperada es lo que impide que el banco la vea.

## Resultado local — 2026-09-10

Banco completo, **tres corridas**, todas con `rc 0` y cuadre **912** exacto:
**908 PASS · 0 FAIL · 4 SKIP** (la 1.ª) y **907 PASS · 0 FAIL · 5 SKIP** (la 2.ª
y la 3.ª).
**La variabilidad se registra, no se promedia ni se elige la cifra mejor:** el
total y el `rc` son idénticos y **FAIL es 0 en las tres**; lo que se mueve es un
SKIP de calibración que depende del reloj de la máquina. 25,2 s de reloj
(`loadavg` 0,92 al arrancar la primera; **esta máquina no es el runner**, la
cifra de reloj no es un umbral y el veredicto lo da el CI en Linux).
Autoprueba del corredor: **106 PASS · 0 FAIL**, CA-18 incluido. `bash -n` sobre
`hooks/*.sh` y `tools/*.sh`, los tres JSON del plugin y `git diff --check`: en
verde.

Los SKIP van explicados por el propio corredor (uno sólo de Windows, dos de
acreditación de coste que no son puerta de PR y uno o dos de calibración cuya
mitad no es medible en este instrumento). Ninguno tapa un caso de este parche:
los 28 de la sección 40 se ejecutan y pasan en las tres corridas.

Nota de reconciliación: el resultado de v1.33.1 registrado arriba (889 PASS, 3
FAIL, 9 SKIP) se midió en **otra máquina**; los recuentos no son comparables
entre plataformas y aquí no se presentan como tales.

## `SEC-087` — la vía que la promesa tapaba, y que este parche NO cierra

Hallazgo del auditor (`R-029`, 2026-09-10), clase **`contrato`**, severidad
media-alta, **abierto**. Con la puerta real, `Sensible a seguridad: no` y
`QA: aprobado`:

| `Rigor:` escrito | Nivel efectivo | Puerta |
|---|---|---|
| `critico (por suelo)` | `critico` | **deny** |
| `critico (por suelo` — falta el `)` | **`estandar`** | **ALLOW, en silencio** |
| `critico (` | **`estandar`** | **ALLOW, en silencio** |
| `critico (x) y` — texto detrás del cierre | **`estandar`** | **ALLOW, en silencio** |

**Causa.** `arnes_veredicto` desenvuelve **sólo si el valor termina en `)`**. Si no,
el valor entero deja de reconocerse y `arnes_rigor_efectivo` retorna por su rama de
«valor no reconocido» **antes** de la guarda del más restrictivo, que por tanto **no
corre**. Lo comprobado en las tres versiones instaladas: **1.33.0, 1.33.1 y 1.33.2 se
comportan igual**.

**Qué es de este parche y qué no.** La vía es **preexistente** y este arreglo **no la
abrió**: no es una regresión y no se revierte nada. Lo que este parche introdujo fue
**la frase absoluta que la tapaba**, y encima en la superficie que los proyectos
**heredan**. Eso es lo que se corrige aquí, en texto.

**Por qué NO se cierra la vía en el código, y es una decisión, no un olvido.** Cerrarla
es **otro defecto y otra reparación** —«un defecto, una reparación», instrucción del
propietario—: cambiaría `hooks/` e **invalidaría la evidencia de QA**, que hoy es válida
precisamente porque este tramo es sólo texto. Queda registrada con dueño y ventana en
`docs/seguridad/registro-seguridad.md` § **R-029** / **SEC-087**.

**Y cómo se nos pasó, que es la parte reutilizable.** La promesa se verificó **en la
dirección en que es verdad**: con tres ejemplos bien formados. Es la misma forma de
fallo que 1.33.1 —que se validó contra el defecto reportado y no contra su contrario— y
van **tres veces en esta ventana**: el barrido del desarrollador, las formas felices de
QA, y esta. Lo que la caza no es más diligencia: es elegir el **alfabeto adversario**
antes de escribir la promesa.

## Límites de este parche

- **No** toca la corrección de la firma (`arnes_seguridad_cabecera` y su uso en
  `guard-completado.sh`): está validada y no es el defecto.
- **No** sube la versión en `.claude-plugin/`: el commit de versión va aparte.
- **No** toca veredictos ni estados de REQ, ni nada de `requirements/` salvo el
  enunciado del rigor en su `README.md` (autorizado; ver abajo).
- Un `Rigor:` **genuinamente basura** (sin paréntesis, o cuyo desenvoltorio no da
  un nivel válido) sigue cayendo al defecto de la sensibilidad. Eso es
  `QA-016-04`, ya abierto, y **no** se toca aquí.
- **No** cierra la vía de `SEC-087` en el código (arriba: es otra reparación, con su
  propio REQ, y tocar `hooks/` invalidaría la evidencia de QA).
- **RESUELTO — el contrato heredado está escrito, y desde el 3.er tramo con su
  condición de alcance.** `requirements/README.md` y su plantilla heredada
  `templates/requirements-README.md.tpl` afirmaban primero que «un matiz parentético
  final **no cambia** un nivel válido» (falso para `ligero (…)`, 2.º tramo) y después
  que «un matiz parentético conserva `estandar` y `critico`» sin condición (falso para
  el paréntesis sin cerrar, `SEC-087`, 3.er tramo). Las dos sedes llevan ya el
  enunciado **condicionado al matiz bien formado**, con el contraejemplo y su
  dirección nombrados, e **idénticas entre sí** (verificado byte a byte en la región).
  El 1.er tramo paró antes de escribirlas porque es superficie que los proyectos
  heredan por `arnes-upgrade`; la redacción base la fijó el propietario, y la condición
  la exige su propia instrucción de escribirla *«verificando que coincida con el
  código»*.

- `docs/estabilizacion/actualizacion-candidata.md` repite el enunciado sin dirección
  en el primer punto de «Cambios que debe conocer un proyecto consumidor». Describe
  el candidato de v1.33.1 **como fue**, así que **no se reescribe**: borrarlo
  escondería que esa promesa se publicó. Lleva arriba una marca de **SUPERADO EN
  PARTE** que nombra qué punto queda superado, desde cuándo, y **cita la sede de la
  regla en vez de transcribirla** — su primera versión sí la transcribía, y `SEC-087`
  la dejó obsoleta en dos días: una copia más es una sede más que se desfasa.
- **No contamina la lectura siguiente**, comprobado por la coordinadora sobre este
  árbol en seis escenarios —matiz→limpio, el orden inverso, campo ausente, valor no
  reconocido, tres seguidos alternando y el indicador **preensuciado a mano** antes
  de una lectura limpia—: `arnes_campos_normaliza` pone `ARNES_RIGOR_MATIZ` a 0 al
  entrar, así que el indicador no sobrevive de una cabecera a la siguiente.
