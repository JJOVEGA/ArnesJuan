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
- (−) **Tres movimientos de `deny` a `allow`, declarados** en REQ-007 CA-66: una ruta relativa que casaba con
  el ámbito sólo porque se leía desde la raíz cuando el directorio de trabajo es otro; un `Write` que cierra
  un REQ ilegible con todo en verde, porque se juzga entero; y una ruta equivalente al manifiesto durante su
  avería (CA-60).
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
