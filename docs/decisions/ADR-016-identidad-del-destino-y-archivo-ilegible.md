# ADR-016 — Las puertas juzgan el archivo que la escritura alcanzaría, no la forma de su ruta, y un REQ que la puerta no puede leer entero no se edita; supersede «el arnés juzga la ruta escrita, no su destino» y la regla del archivo ilegible
Fecha: 2026-09-30
Estado: aceptada

## Contexto
**Las decisiones que se superseden.**
- **REQ-007 CA-49 (SEC-004, 2026-09-05)** fijó que el arnés «juzga la ruta escrita y no su destino»: se
  deniega el `Edit`/`Write`/`MultiEdit` cuyo **último** componente es un enlace simbólico dentro del
  proyecto, **sin resolver** nada. Los directorios enlazados y las rutas con `..` quedaron fuera
  (`arnes_deny_enlace` excluye las rutas que suben).
- **`arnes_ruta_relativa`** (`hooks/lib.sh`) decide la pertenencia recortando la raíz **como texto**, y deja
  una ruta relativa «tal cual, asumiendo que el comando corre en la raíz». REQ-007 CA-47 (SEC-003) sólo
  añadió el colapso de barras repetidas.
- **El archivo ilegible** (REQ-007 CA-46 (b); REQ-023 CA-13 (iv); ADR-015, consecuencia «(=)»): con el REQ en
  disco imposible de leer entero, sólo se deniega la edición que **menciona** el estado terminal.

**Lo que las desmiente:**
1. **QA-023-07** (`docs/qa/REQ-023.md`, adenda de la vuelta excepcional, §10) y **SEC-119**
   (`docs/seguridad/registro-seguridad.md` § R-045-A, §3), medidos a nivel de hook en el candidato, en
   `31d2a21` y en `713ac68`: un `Edit` literal que cierra un REQ `critico` con QA pendiente sale **allow**
   por `<raíz>/docs/../requirements/…`, por `<raíz>/././requirements/…` y por un directorio enlazado,
   dentro o fuera del proyecto; y un `Write` de la coordinadora a `src/a.ts` por las mismas formas sale
   **allow** en `guard-codigo`.
2. **O-11** (misma adenda de QA; R-045-A §6) y **QA-023-08**: con un NUL en el REQ, una edición que no
   escribe la palabra del estado terminal pasa sin juzgarse, y REQ-007 CA-46 (b) afirmaba que decidía «la
   transición», que era falso.
3. **El host real**, medido por la coordinadora el 2026-09-30 (CLI 2.1.285, `claude -p`, WSL2, hook de
   `9596e39`, una ejecución por caso; rama local `evidencia/prueba-despacho-2026-09-14`,
   `sec119-base/RESULTADO.md`, commit `bf47f37`, registros previos `794d50b` y `b4c7e18`):
   - el host **normaliza léxicamente** el `file_path` de `Edit` y `Write` (`..`, `./`) antes del hook, así
     que por esas herramientas esas formas sólo se alcanzan inyectando la entrada;
   - el host **no resuelve enlaces**: un `Edit` por un directorio enlazado a `requirements/` dejó
     `completado` un REQ `critico` con todo en rojo;
   - el host **no normaliza el texto de `Bash`**: `printf … > docs/../src/a.ts` creó código protegido desde
     la coordinadora y `sed -i … docs/../requirements/…` cerró un REQ;
   - con un REQ en **UTF-16LE**, un `Edit` sin estado **se aplicó** mientras el hook no podía leer el
     archivo: la herramienta escribe lo que el hook no lee.

**Lo que decidió el propietario:** la **quinta autorización** (2026-09-30), literal en `PENDING_APPROVAL.md`
§ Resueltas, commit `1ebe1c1`. Propiedad: «las rutas equivalentes que apuntan al mismo archivo protegido no
pueden recibir permisos distintos por su escritura»; una resolución coherente para las dos puertas que
considere el directorio de trabajo y los enlaces; los archivos nuevos por su directorio padre existente, sin
confundir «todavía no existe» con «no se pudo determinar»; sin prometer nada frente a las carreras; y, para
O-11, distinguir inexistente, ilegible y error al resolver, sin que no poder leer o reconstruir se convierta
en permiso silencioso. SEC-120 queda fuera y pendiente: la coordinadora lo determinó independiente (entrada
de `CHANGELOG.md` de `1ebe1c1`).

## Decisión
**Las dos puertas deciden sobre la identidad del destino,** y la norma vive en un solo sitio:
`requirements/REQ-007.md` **CA-47** (versionado el 2026-09-30). Allí están cómo se ancla una ruta relativa
(en el `cwd` de la entrada del hook), sus dos lecturas —la física, la del sistema de archivos, y la léxica,
la que aplica el host a `Edit`/`Write`—, cuándo un destino pertenece al ámbito protegido, qué es un destino
**no determinable** y por qué no pasa, y las fronteras que se declaran sin promesa.

**Un REQ que la puerta no puede leer entero no se edita,** y la norma vive en `requirements/REQ-007.md`
**CA-45** (versionado el 2026-09-30): inexistente, existente pero ilegible y no determinable son tres casos
distintos; un `Edit`/`MultiEdit` sobre un REQ ilegible se deniega, toque o no el estado; un `Write` se
juzga entero y como posible transición.

**Se conserva de CA-49 sólo la regla del último componente:** por `Edit`/`Write`/`MultiEdit`, un enlace
situado dentro de la raíz se sigue denegando sea cual sea su destino. Todo lo demás se juzga por la
identidad del destino.

**Lo que supersede:** la premisa «el arnés juzga la ruta escrita y no su destino» (REQ-007 CA-49 y CA-50),
la de que una ruta relativa se lee desde la raíz, la regla del archivo ilegible de REQ-007 CA-46 (b) y de
REQ-023 CA-13 (iv), y la consecuencia «(=) no cambia el archivo que no se puede leer entero» de ADR-015.
Se registra como ADR por `AGENTS.md` §9: cambia la decisión base de CA-49 y la conducta sobre escrituras
que hasta ahora pasaban.

Este ADR registra la decisión y su porqué; no transcribe la norma.

## Alternativas consideradas
- **Sólo la lectura léxica** (retirar `.` y `..` como texto antes de recortar la raíz; primer remedio de
  R-045-A §3). **No basta:** no ve los directorios enlazados, que son justo la forma que el host deja pasar
  (medido), y el propietario lo excluye («no basta con borrar segmentos del texto»).
- **Sólo la lectura física.** **No:** mueve de `deny` a `allow` lo que hoy se juzga bien cuando el propio
  directorio protegido es un enlace que sale de la raíz —`requirements -> /otro/sitio`—, y las rutas de
  `Edit`/`Write` son las que el host normaliza léxicamente. Por eso cuentan las dos lecturas y el tramo fijo
  del patrón.
- **Denegar toda ruta con `..` o con un componente enlazado.** **No:** no resuelve el directorio de
  trabajo, deniega operaciones legítimas fuera del ámbito y el propietario pide preservarlas.
- **Resolver cada ruta con un programa externo** (`realpath`, `readlink -f`). **No** en el camino común:
  cada proceso cuesta de 1,2 a 6 s en Windows/MSYS (`AGENTS.md` §2). `cd -P` y `$PWD` son de bash. El único
  proceso admitido es leer el destino de un enlace en el último componente, que bash no sabe leer sin uno.
- **Para O-11, mantener la regla de «menciona el estado terminal».** **No:** la propiedad de la cuarta y la
  quinta autorización la excluye; es la regla ancha que ADR-015 ya rechazó para SEC-117.
- **Incluir SEC-120.** **No:** su causa es la entrada JSON del hook, no el archivo; la quinta autorización
  manda conservarlo pendiente si es independiente.

## Consecuencias
- (+) Una ruta equivalente —relativa al directorio de trabajo, con `.` o `..`, con barras repetidas o a
  través de un directorio enlazado— recibe el veredicto de la canónica en las dos puertas, venga del host o
  inyectada.
- (+) Un destino que no se puede determinar y un REQ que no se puede leer entero dejan de recibir permiso
  silencioso.
- (−) **Compatibilidad:** pasan a denegarse, entre otras (lista no exhaustiva; la declarada está en
  REQ-007 CA-66): las escrituras a zonas protegidas por rutas con `..`, `./`, `//` o directorios enlazados;
  un enlace situado fuera de la raíz que apunta a un REQ o a código protegido; una escritura por `Bash` a
  través de un enlace hacia una zona protegida; un `Edit`/`MultiEdit` sobre un REQ ilegible aunque no toque
  el estado; y un destino no determinable. *Mitigación:* cada motivo dice la causa y cómo corregirla, sin
  proponer otra herramienta.
- (−) **Seis movimientos de `deny` a `allow`, declarados** en REQ-007 CA-66, punto 5: una ruta relativa que
  casaba con el ámbito sólo porque se leía desde la raíz cuando el directorio de trabajo es otro; un `Write`
  que cierra un REQ ilegible con todo en verde, porque se juzga entero; una ruta equivalente al manifiesto
  durante su avería (CA-60); y tres rutas con `..` que casaban con el ámbito sólo por su texto y designan un
  archivo de fuera —`Write <raíz>/src/../README.md`, `echo x > src/../README.md` y un `sed -i` que menciona
  el estado terminal hacia `requirements/../docs/x.md`—. Ninguno debilita una protección: todos designan un
  archivo que la regla no protege.
- (−) **Coste:** 0 procesos añadidos salvo leer el destino de un enlace en el último componente cuando hay
  que resolverlo (como mucho 1 por destino enlazado). En Windows/MSYS no está medido.
- (−) **Fronteras sin promesa**, con su sede en REQ-007 CA-47: carreras entre la decisión y la escritura, un
  `cd` dentro del comando, identidades que no son resolución de nombres, sistemas que no distinguen
  mayúsculas, un enlace dentro del ámbito que sale de la raíz por la ruta directa, y los hosts no ejercidos.
  Las que la quinta autorización no nombra están planteadas al propietario (REQ-007, P-119-A).
- (=) No cambian los patrones protegidos, quién puede escribir en ellos, las reglas de cierre, la vía de
  `Bash` de `guard-completado` —que sigue sin leer el archivo— ni `tools/arnes-paralelo.sh`.
- (=) Este ADR no afirma que la reparación esté verificada. Lo acreditan QA, seguridad y la validación en el
  host de REQ-007 CA-66, cada uno en su sede.

## Adenda — 2026-10-01 (sexta autorización): la entrada se lee campo a campo, y un salto de línea en la ruta o en el nombre de la herramienta no da permiso

**Esta adenda manda sobre las consecuencias de arriba en lo que toca; lo de arriba no se reescribe.** La norma
vive en `requirements/REQ-007.md` **CA-47, puntos 11 a 13** (versionado del 2026-10-01); aquí sólo la decisión y
su porqué.

**Causa.** QA-023-09 (`docs/qa/REQ-023.md` § «Vuelta excepcional de la quinta autorización», §9): la
implementación de este ADR (`104ffd1`) añadió el `cwd` a una lectura de la entrada «uno por línea», y un salto de
línea en el `cwd` desplazaba los campos siguientes; las dos puertas juzgaban otra ruta y un cierre en rojo por la
ruta canónica salía **allow** a nivel de hook. En el host real (`sec119-v3b/RESULTADO.md`, CLI 2.1.285, una
ejecución) el desplazamiento se produjo; la denegación que se observó se debió a que el destino desplazado no se
podía determinar, y no acredita protección. **Decisión del propietario:** la sexta autorización (2026-10-01),
literal en `PENDING_APPROVAL.md` § Resueltas, commit `fb6eaab`: preservar los límites entre campos del formato
de entrada, sin prohibir el nombre ensayado ni sustituir caracteres en silencio.

**Decisión.**
1. **Los campos de la entrada se leen enteros, con los límites que fija el formato** (punto 11). Un `cwd` con
   saltos de línea se admite y ancla como cualquier otro.
2. **Un `file_path` con un salto de línea es no determinable** (punto 12). La puerta lo lee entero, pero qué
   archivo escribirá la herramienta con ese argumento —el nombre literal o uno recortado— no está medido; es el
   mismo fundamento que la divergencia de las dos lecturas (CA-47, punto 4).
3. **Un `tool_name` con un salto de línea no identifica ninguna herramienta** y se trata como una escritura no
   determinable (punto 13).

**Alternativas descartadas.**
- **Juzgar la ruta entera y declarar como movimientos de `deny` a `allow` los casos que eso permite** —un
  `app/a.ts` seguido de un salto con el patrón `app/*.ts`, un enlace seguido de un salto—, y lo mismo con el
  `tool_name` `Bash` seguido de un salto. **No:** daba permiso apoyándose en una conducta del host sin medir —lo
  que el host haga con la ruta es la frontera F7, que el propietario no ha aceptado (REQ-007, P-119-A) y que
  prohíbe usar para cubrir QA-023-09—, contradecía «no determinable no pasa» y reducía la cobertura frente a lo
  publicado.
- **Juzgar sólo la primera línea**, como hacían las versiones anteriores. **No:** es juzgar un fragmento del
  campo, la misma clase de defecto que QA-023-09.
- **Prohibir el `cwd` con saltos.** **No:** la sexta autorización dice que no basta con prohibir el nombre
  ensayado.

**Consecuencias.**
- (+) Un salto de línea en el `cwd`, en el agente o en la ruta ya no hace que las puertas juzguen otra cosa.
- (−) **Compatibilidad, además de la de arriba:** se deniega todo `Edit`, `Write` o `MultiEdit` cuyo
  `file_path` lleva un salto de línea, sea cual sea su ruta y su agente, y toda entrada cuyo `tool_name` lo
  lleva. La declarada está en REQ-007 CA-66 (versionado del 2026-10-01).
- (=) **Los movimientos de `deny` a `allow` siguen siendo los seis de arriba.** Los de este día son todos de
  `allow` a `deny`.
- (−) **Coste de reloj, que la consecuencia «Coste» de arriba no decía:** identificar cada destino encarece el
  análisis de un comando de `Bash` con muchos destinos, y en el máximo de REQ-007 CA-54 no se cumple el < 5 s
  (QA-023-10, abierto; cifras en la nota de CA-54 del 2026-10-01). La optimización intentada en la vuelta de
  este día no lo consiguió y quedó fuera del candidato. Lo decide el propietario.
- (=) Sin procesos nuevos. Esta adenda no afirma que la reparación esté verificada.

## Adenda — 2026-10-02 (séptima autorización): el retorno de carro de la entrada se cuenta antes del transporte, y un `cwd` que lo lleva no ancla

**Esta adenda manda sobre la del 2026-10-01 en lo que toca; lo de arriba no se reescribe.** La norma vive en
`requirements/REQ-007.md` **CA-47, puntos 1, 7 y 11 a 13** (versionado del 2026-10-02); aquí sólo la decisión
y su porqué.

**Causa.** QA-023-13 (`docs/qa/REQ-023.md` § «Vuelta excepcional de la sexta autorización», §7): el transporte
de la entrada retira el retorno de carro que cierra un campo —lo añade el `jq` de Windows—, y en el flujo de
bytes ese retorno de carro no se distingue de uno que forme parte del dato. Con un `cwd` acabado en retorno de
carro y enlazado a la raíz, las puertas anclaban en otro directorio que el del shell, y una escritura de la
coordinadora a código protegido y un cierre en rojo por `Bash` salían **allow** a nivel de hook, donde `9596e39`
y 1.33.2 deniegan. La decisión 1 de la adenda anterior —leer cada campo entero; un `cwd` con saltos de línea
ancla como cualquier otro— era falsa para el retorno de carro. **Decisión del propietario:** la séptima
autorización (2026-10-02), literal en `PENDING_APPROVAL.md` § Resueltas, commit `3128d09`: las puertas juzgan
la ruta real de la operación o deniegan explícitamente cuando no pueden determinarla, y nunca juzgan otra ruta
por haber modificado en silencio el directorio recibido; autoriza denegar un `cwd` que contenga un retorno de
carro, con un motivo preciso.

**Decisión.**
1. **El retorno de carro del `tool_name`, del `cwd` y del `file_path` se cuenta sobre el valor crudo, antes
   del transporte**, en la misma lectura de la entrada, y lo que decide es esa cuenta.
2. **Un `cwd` con un retorno de carro no ancla:** la ruta relativa que depende de él es no determinable, con su
   motivo; lo que no depende de él se juzga como siempre. Un `cwd` con saltos de línea y sin retorno de carro
   sigue anclando (decisión 1 de la adenda anterior, acotada).
3. **Un `file_path` o un `tool_name` con un retorno de carro se tratan como los que llevan un salto de línea**
   (decisiones 2 y 3 de la adenda anterior).

**Alternativas descartadas.**
- **Anclar en el valor reconstruido, reponiendo el retorno de carro que el transporte retiró.** No: la puerta
  no conserva el valor con certeza —el retorno de carro final se confunde con el fin de línea del `jq` de
  Windows—, y anclar sobre una reconstrucción es juzgar lo que la puerta supone que llegó; la séptima
  autorización admite denegar con motivo.
- **Denegar toda llamada cuyo `cwd` lleve un retorno de carro.** No: lo que no depende del `cwd` —una ruta
  absoluta, un comando que no escribe— se puede juzgar, y la propiedad pide denegar lo que no se puede
  determinar. Es la variante mínima, con la estructura de un `cwd` ausente o inexistente.
- **Contar también el retorno de carro del texto de `Bash` en esta vuelta.** No: el propietario pidió no
  convertir la reparación en una reescritura general del analizador de `Bash`. Queda como límite declarado y
  como pregunta al propietario (REQ-007, P-023-13-A).

**Consecuencias.**
- (+) Un retorno de carro en el `cwd`, en el `file_path` o en el `tool_name` ya no hace que las puertas juzguen
  otro directorio, otra ruta u otra herramienta.
- (−) **Compatibilidad, además de la de arriba:** una ruta relativa cuyo `cwd` lleva un retorno de carro se
  deniega con motivo, también fuera del ámbito protegido —la salida es la ruta absoluta o un directorio cuyo
  nombre no lo lleve—, y un `file_path` o un `tool_name` con un retorno de carro se deniegan como con un salto.
  La declarada está en REQ-007 CA-66 (versionado del 2026-10-02).
- (=) **Los movimientos de `deny` a `allow` siguen siendo los seis de arriba.** Los de este día son de `allow`
  a `deny`.
- (−) **Límite conocido, no protegido y no aceptado:** el texto del comando de `Bash` conserva el transporte
  —pierde su retorno de carro final y el que precede a un salto—, y un destino de `Bash` cuyo nombre acaba así
  se juzga sin él mientras el shell lo escribe con él. Medido a nivel de hook, una escritura de la coordinadora
  a código protegido por un enlace con ese nombre sale `allow` en el candidato y en 1.33.2. Preexistente. Sede:
  REQ-007 CA-47, punto 11; decisión: P-023-13-A.
- (=) Sin procesos nuevos: la cuenta va en la lectura de la entrada que ya existía. En Windows/MSYS, sin
  medir. Desde el host, el caso del retorno de carro no se ha ejercido. Esta adenda no afirma que la
  reparación esté verificada.

## Adenda — 2026-10-02 (octava autorización): ningún prefijo queda fuera de la identidad, lo que depende del proceso que abre la ruta no recibe permiso por esa incertidumbre, y el texto de `Bash` llega con sus retornos de carro

**Esta adenda manda sobre las de arriba en lo que toca; lo de arriba no se reescribe.** La norma vive en
`requirements/REQ-007.md` **CA-47** (F3, puntos 7, 11, 12 y 14 a 17), **CA-49** (i) y (ii) y **CA-66**
(versionado de la octava autorización); aquí sólo la decisión y su porqué. Corrige además dos afirmaciones de
arriba: la consecuencia «Fronteras sin promesa» de la decisión original incluía como frontera las «identidades que
no son resolución de nombres» con una implementación que excluía todo `/dev/` y `/proc/`, y la frase «los
movimientos de `deny` a `allow` siguen siendo los seis de arriba» de las dos adendas anteriores era falsa en un
proyecto situado bajo `/dev/` (SEC-122, cara b).

**Causa.**
- **SEC-122** (`docs/seguridad/registro-seguridad.md` § R-046, §2): F3 de CA-47 se implementaba como «todo
  destino cuya lectura léxica cae bajo `/dev/` o `/proc/` no recibe identidad física». Un enlace simbólico
  corriente bajo `/dev/shm` —resolución de nombres, la que CA-47 promete— y `/proc/self/root` seguido de la ruta
  absoluta llevaban al REQ o al código protegido y las dos puertas permitían (cara a, preexistente); y en un
  proyecto situado bajo `/dev/` se apagaban CA-49 (i) y la existencia (cara b, regresión de `104ffd1`).
- **QA-023-14:** la reposición del retorno de carro que la séptima adenda dejó en la lectura de la entrada
  (`3bc7d3c`) crecía más que linealmente con el tamaño del campo, antes de cualquier techo.
- **QA-023-15 / P-023-13-A:** el texto del comando de `Bash` perdía en el transporte su retorno de carro final y el
  que precede a un salto, y un destino cuyo nombre acaba así se juzgaba sin él mientras el shell lo escribía con él.

**Decisión del propietario:** la octava autorización (2026-10-02), literal en `PENDING_APPROVAL.md` § Resueltas,
commit `01b4a59`: eliminar la exclusión indiscriminada de `/dev/` y `/proc/`; que los destinos resolubles por
nombres pasen por la identificación y sus reglas de protección, conservando las comprobaciones de existencia y
enlaces; que una identidad dependiente del proceso que no pueda determinarse no reciba permiso por esa
incertidumbre; conservar los usos legítimos previstos de `/dev/null` y `/dev/stderr` sin convertir sus nombres en
una excepción general; eliminar la sustitución superlineal sin sustituirla por otra; corregir el transporte del
retorno de carro en el texto de `Bash` y, si el análisis no puede preservar su significado, denegar
explícitamente, sin reescribir el analizador general.

**Decisión.**
1. **Ningún prefijo queda fuera de la identificación** (F3 corregida): un destino bajo `/dev/` o `/proc/` tiene
   lectura física, enlace del último componente y existencia como cualquier otro. F3 queda en lo que no es
   resolución de nombres —enlaces duros, montajes— y no desactiva ninguna otra regla.
2. **Lo que depende del proceso que abre la ruta se detecta, no se enumera** (punto 14): una resolución que
   aterriza en la entrada de `/proc` del proceso que resuelve depende de él. Por `Bash`, una ranura de descriptor
   es un descriptor del shell y queda fuera de todo ámbito (punto 15); por otra herramienta, y todo lo demás que
   aterriza allí, es no determinable.
3. **La lectura física que atraviesa un enlace se rehace desde el directorio del proceso que escribirá** (punto
   16): el `cwd` de la entrada por `Bash`; la entrada propia de `/proc`, por el host o sin un `cwd` que ancle.
4. **La entrada se lee cruda y el transporte se retira sólo si existe** (punto 11): cada campo llega con sus
   retornos de carro y nada recorre el valor para reponerlos.
5. **Donde el analizador de `Bash` no puede seguir el retorno de carro —el delimitador de un heredoc— se deniega**
   (punto 17), con el destinatario del presupuesto de análisis.

**Alternativas descartadas.**
- **Conservar la exclusión y declarar la cara (b) como séptimo movimiento** (opción B de la decisión 10). No: el
  propietario eligió reparar; y F3 seguiría dejando pasar enlaces corrientes que CA-47 promete cubrir.
- **Exceptuar por nombre `/dev/null`, `/dev/stderr` y los demás.** No: la autorización prohíbe convertir sus
  nombres en una excepción general; una lista de nombres se pudre hacia el lado que abre.
- **Denegar todo destino bajo `/dev/` o `/proc/`.** No: rompe `> /dev/null` y `> /dev/stderr`, que tienen que
  seguir pasando.
- **Resolver cada destino con un programa externo.** No: cuesta un proceso por destino (`AGENTS.md` §2); el
  descriptor estándar se reconoce sin proceso, y el único proceso sigue siendo el del enlace del último componente.
- **Mantener la reposición del retorno de carro, u otra pasada sobre el valor.** No: la autorización prohíbe
  sustituir ese coste por otra pasada superlineal.
- **Seguir retirando el retorno de carro del texto de `Bash`.** No: es juzgar un comando distinto del que ejecuta
  el shell. **Reescribir el analizador para seguir el delimitador con retorno de carro**, tampoco: lo excluye la
  autorización, que manda denegar en su lugar.

**Consecuencias.**
- (+) Un enlace corriente bajo `/dev/`, `/proc/self/root` o `/proc/self/cwd` hacia una zona protegida se juzga
  como en cualquier otro sitio, y un proyecto situado bajo `/dev/` conserva CA-49 (i) y la existencia.
- (+) Un destino de `Bash` cuyo nombre acaba en un retorno de carro se juzga con él, que es lo que el shell
  escribe.
- (+) El coste de QA-023-14 desaparece: medido por el desarrollador a nivel de hook, un `file_path` de 600 000
  bytes con un retorno de carro final tarda 405 ms, como en `cd6afa6`, frente a 83 929 ms en `3bc7d3c`
  (`evidencia-dev-r8/10-`). No acredita CA-54 (QA-023-10, abierto).
- (−) **Compatibilidad, además de la de arriba:** se deniegan, entre otras (lista no exhaustiva; la declarada está en
  REQ-007 CA-66, versionado de la octava autorización), una escritura a una zona protegida a través de un enlace o
  un alias bajo `/dev/` o `/proc/`; por `Edit`, `Write` o `MultiEdit`, toda ruta que depende del proceso del host
  —`Write /dev/stderr` incluido— a todo agente; por `Bash`, lo que depende del proceso y no se puede determinar, a
  quien no es el agente de código; y un heredoc cuyo delimitador lleva un retorno de carro —también el legítimo de
  un script CRLF— a todo agente, por `guard-completado`.
- (−) **Los movimientos de `deny` a `allow` pasan de seis a ocho declarados:** a los de arriba se suman un destino
  de `Bash` acabado en retorno de carro que con él ya no casa con el patrón que casaba sin él (`app/a.ts␍` con
  `app/*.ts`) y `git reset --hard␍`, que git rechaza. **Otros dos no están declarados** —`git stash␍`, cuya
  conducta depende de `help.autocorrect`, y, por lectura del código y sin medir, un enlace situado dentro de un ámbito
  protegido que lleva a un descriptor— y quedan en REQ-007, P-122-A.
- (−) **Límites declarados, sin promesa:** una cadena que sube con `..` por encima de la entrada de `/proc` desde la
  que se resuelve no se ve; sin `/proc`, se resuelve desde donde esté el hook; a qué archivo apunta un descriptor
  que el propio comando abrió antes de escribir en él no se mira; que el delimitador de heredoc sea el único sitio
  donde el analizador no sigue el retorno de carro es una declaración del desarrollador, no una medición
  exhaustiva; en Windows/MSYS la detección del transporte está emulada, no medida.
- (=) Procesos: **no más de 0** añadidos fuera de la resolución del enlace del último componente; `> /dev/stderr`
  sigue en 0 (CA-48 (i.1)).
- (=) **Plataformas, limitado a lo ejecutado:** hook en Linux/WSL2; CLI 2.1.285 en WSL2 mediante `claude -p`; hook
  en Windows/MSYS, en una máquina; sin comprobación de la extensión de VS Code, del CLI en Windows ni de otros
  clientes. Describe dónde se ejecutaron los casos y no acredita toda la plataforma. Lo construido en esta adenda
  sólo se ejerció a nivel de hook en Linux/WSL2; desde el host, no.
- (=) Esta adenda no afirma que la reparación esté verificada.

**Precisión de la pasada correctiva (2026-10-02, `befc17a`) — manda sobre las consecuencias de esta adenda en lo que
toca.** La octava autorización prevé una pasada correctiva para los defectos de su mismo alcance, y QA encontró tres
(`docs/qa/REQ-023.md` § «Vuelta excepcional de la octava autorización»): QA-023-16 —la enumeración «seis más dos» era
falsa sobre lo construido: `git checkout .␍`, `git restore .␍` y dos formas más salían `allow` sin declarar—,
QA-023-17 —el enlace dentro de un ámbito protegido hacia un descriptor salía `allow` por `Bash`— y P-122-A (1)
—QA midió que con `help.autocorrect` git corrige `git stash␍` y lo ejecuta—.
- **Decisión 6, nueva:** `guard-git` juzga cada orden con sus retornos de carro **y** sin ellos, y deniega si
  cualquiera de las dos lecturas casa; la copia sólo añade denegaciones. Lo que git haga con una orden que lleva un
  retorno de carro depende de una configuración que la puerta no lee, y la autorización manda denegar cuando el
  análisis no puede preservar el significado. *Alternativa descartada:* reparar sólo `git stash␍` y declarar
  como movimientos `git reset --hard␍` y las órdenes de QA-023-16, que git rechaza en las dos configuraciones
  medidas por QA; la regla uniforme sólo añade denegaciones y no obliga a saber qué palabras corrige git.
- **Decisión 2, precisada:** la ranura de un descriptor no aporta pertenencia, pero la ruta escrita por la que se
  llega a él se juzga por las tres vías de REQ-007 CA-47, punto 6, como la de cualquier enlace.
- **Consecuencias que cambian:** los movimientos de `deny` a `allow` **no** pasan de seis a ocho: a las seis clases
  de arriba se suma **una**, la del destino de `Bash` acabado en retorno de carro que con él ya no casa con el patrón
  (`app/a.ts␍` con `app/*.ts`). `git reset --hard␍` vuelve a `deny`, y ya no queda ningún movimiento sin declarar.
  REQ-007 CA-66 lo enuncia como regla, no como inventario: un movimiento de `deny` a `allow` fuera de esas clases es
  un hallazgo. **Compatibilidad, además:** se deniega toda orden de git que sin sus retornos de carro está
  prohibida, también con el retorno de carro en medio (`git clean␍ -f`), que lo publicado permitía y que con
  `help.autocorrect` git ejecuta. El límite que queda: dos lecturas no reproducen lo que git haría con cualquier
  palabra mal escrita, que es el límite de siempre de una lista que compara palabras.
- (=) Sin procesos nuevos, desde el host no ejercido, y sin afirmar que la pasada esté verificada: falta la
  re-verificación de QA.

**Precisión de SEC-123 (2026-10-03, novena autorización, fase 1) — manda sobre el primero de los «Límites
declarados, sin promesa» de esta adenda en lo que toca; lo de arriba no se reescribe.** R-047 §2
(`docs/seguridad/registro-seguridad.md`) midió que ese límite estaba mal descrito: REQ-007 CA-47 ponía el umbral en
«cinco niveles» y ni allí ni aquí se decía su consecuencia. La sede de la descripción es REQ-007 CA-47, F3, y el
punto 16 remite a ella; aquí, el resumen. Decisión del propietario: la novena autorización y su decisión sobre
SEC-123, literales en `PENDING_APPROVAL.md` § Resueltas, entradas del 2026-10-03 («corregir la descripción de F3,
separando lo medido de lo inferido y declarando la consecuencia. No acepto el riesgo ni doy por reparado el
mecanismo»).
- **Umbral, por propiedad:** el límite empieza cuando una cadena que pasa por el directorio de trabajo del proceso
  **sale de la entrada de `/proc` del propio hook** —por `Edit`, `Write` o `MultiEdit`, o por `Bash` sin un `cwd`
  que ancle—. No es un número de niveles.
- **Consecuencia:** lo que no se ve se juzga por el archivo al que llega el hook, no por el que abre quien escribe,
  y **puede ser un permiso sobre un archivo protegido**. En este rincón contradice la propiedad de la octava
  autorización recogida arriba («Decisión del propietario»: lo dependiente del proceso que no pueda determinarse
  no recibe permiso por esa incertidumbre).
- **Medido**, a nivel de hook, con la raíz del proyecto a siete niveles: deny con una a tres subidas, permiso con
  cuatro, cinco y seis, deny con siete o más; y el efecto en disco, con un shell aparte. Linux/WSL2. Preexistente:
  1.33.2 también lo permite. **Inferido:** que haga falta la raíz a cinco o más niveles, y que desde el host sólo
  se alcance inyectando la entrada o con un `cwd` que no ancla. **Sin comprobar:** el host —ni el CLI ni la
  extensión de VS Code— y Windows.
- (=) **No cambia ninguna decisión de este ADR ni lo construido:** corrige la descripción de un límite que ya era
  sin promesa. **No lo repara, no lo mitiga y no lo acepta:** SEC-123 sigue abierto y F3 sigue pendiente en
  REQ-007, P-119-A.

**Precisión de SEC-124 y SEC-125 (2026-10-03, novena autorización, fase 2) — PENDIENTE DE IMPLEMENTACIÓN Y DE
VALIDACIÓN; manda sobre las consecuencias de esta adenda en lo que toca, y lo de arriba no se reescribe.** R-047 §3 y
§4 (`docs/seguridad/registro-seguridad.md`) midieron dos cosas que la adenda no decía. **SEC-124:** desde `9220c71`,
un heredoc de delimitador limpio cuyo cuerpo tiene una línea que es su delimitador seguido de un retorno de carro, con
algo detrás, sale `allow` donde lo publicado deniega; así que la frase «a las seis clases de arriba se suma **una**»
de la precisión de la pasada correctiva era falsa sobre `befc17a`. **SEC-125:** el detector de escrituras no une la
continuación de línea entre el operador y su destino; preexistente, también en `v1.34.0`. La norma vive en
`requirements/REQ-007.md` CA-47, puntos 18 y 19, y CA-66 (versionado de la fase 2); aquí, la decisión y su porqué.
Decisiones del propietario: la novena autorización y sus decisiones sobre SEC-124 y SEC-125, literales en
`PENDING_APPROVAL.md` § Resueltas, entradas del 2026-10-03 («SEC-124: opción B. Restaurar la denegación mediante un
motivo explícito para el caso descrito en R-047 §3, sin eliminar silenciosamente caracteres ni juzgar un comando
distinto. Acepto la restricción concreta de uso legítimo descrita en ese informe»; «SEC-125: reparar antes de
publicar»).
- **Decisión 7, nueva (SEC-124):** esa forma se deniega **por su estructura y con un motivo que nombra SEC-124**, con
  los destinatarios de la decisión 5 —`guard-completado` a todo agente—, sin alterar el texto y sin juzgar lo que va
  detrás. *Alternativas descartadas:* declararla como clase (opción A de R-047 §3, la recomendada por el auditor): el
  propietario eligió B; volver a juzgar lo de detrás como si la línea cerrara el heredoc: es juzgar un comando
  distinto, que el propietario excluye; retirar el retorno de carro: lo excluye la octava autorización.
- **Decisión 8, nueva (SEC-125):** se juzga el destino que escribe el shell: la continuación se une **sólo donde el
  shell la une**, y su sola presencia no deniega nada. *Alternativas descartadas:* declararlo como límite (el
  propietario eligió reparar); denegar todo comando con una continuación (una continuación no demuestra intención de
  evadir); copiar sin comprobar el pliegue de `guard-git`, que es referencia y no plantilla.
- **Consecuencias que cambian, cuando esté construido:** la forma de SEC-124 deja de ser movimiento de `deny` a
  `allow`; **se añade una clase**, la de SEC-125 —un destino que lo publicado juzgaba por su fragmento anterior a la
  continuación y que, unido como lo une el shell, está fuera del ámbito—, por la misma propiedad que K6. Son ocho
  clases, y cualquier otro movimiento de `deny` a `allow` es un hallazgo. **Compatibilidad, además:** se deniega a
  todo agente la forma de SEC-124, también al `desarrollador` y también con algo inocuo detrás, que es la restricción
  que el propietario acepta; y un destino tras una continuación de línea se juzga por el que escribe el shell.
- (=) Sin procesos nuevos y en tiempo lineal (REQ-007 CA-66, fase 2, punto 9). Windows/MSYS no medido para este
  delta; desde el host, no ejercido salvo lo que registre la validación por capa.
- (=) **Esta precisión no afirma que nada esté reparado:** SEC-124 y SEC-125 siguen abiertos hasta que QA y seguridad
  verifiquen lo construido.
