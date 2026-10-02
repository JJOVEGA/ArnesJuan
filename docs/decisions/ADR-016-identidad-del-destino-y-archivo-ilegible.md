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
