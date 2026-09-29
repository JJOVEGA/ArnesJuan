# ADR-014 — Cabecera ambigua: una variante de una clave de control, o una clave de control repetida, deniega el cierre; la frontera es el esqueleto ASCII de la clave y la estructura de la declaración
Fecha: 2026-09-29
Estado: aceptada

## Contexto
**SEC-047** (`docs/seguridad/registro-seguridad.md:3633`, R-012) midió que un carácter que no se ve
delante de una clave de la cabecera —un BOM, un `0xc3` suelto, un U+200B— hace que el lector no
reconozca la línea, y que para las claves cuya **ausencia abre** la puerta eso cierra como `completado`
un REQ que nadie validó ni auditó. **QA-031-01** (campo `Hallazgos abiertos:` de `requirements/REQ-031.md`)
midió lo mismo con **mayúsculas visibles** (`HALLAZGOS ABIERTOS: SEC-1 (contrato)` junto a la canónica
→ allow), y la propuesta del 2026-09-29 midió una tercera forma: dos declaraciones **contradictorias**
de la misma clave (`Sensible a seguridad: sí` y más abajo `…: no`), donde hoy gana la última en silencio.

`requirements/REQ-023.md`, en su redacción del 2026-09-08, contrataba la mitad (1) de SEC-047 como una
propiedad **por estado**: *una línea de cabecera que lleva un carácter de la clase de CA-01 no se puede
medir*, con denegación **en cualquier línea de la cabecera** (CA-02, primer párrafo), el universo del
sorteo de CA-03 en «cualquier punto de código», un alfabeto de claves **derivado** (CA-06) y techos de
reloj (CA-09 (ii) y (iii)). Esa redacción nunca se implementó, y `v1.34.0` se publicó sin ella.

La coordinadora presentó el 2026-09-29 una propuesta acotada (`docs/arnes/v1.35.0-propuesta-sec-047.md`
y `.diff`, commit `856d97d`; es texto de la coordinadora, no del propietario, y sus cifras de coste son
de un ensayo preliminar que **no** acredita rendimiento). El propietario la autorizó con dos
condiciones propias —la **estructura** de la declaración y el **cambio de compatibilidad** de las claves
repetidas— en `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-09-29) — SEC-047
(mitad 1 de REQ-023) y candidato v1.35.0», texto literal, punto 2.

Se registra como ADR porque, por la regla de `AGENTS.md` §9, cambia el **significado** de REQ-023 —qué
se protege y qué no— y la conducta de cierre sobre cabeceras que hoy cierran (clave repetida con el mismo
valor), no por su tamaño.

## Decisión
1. **Claves de control:** `Estado`, `QA`, `Seguridad`, `Sensible a seguridad`, `Hallazgos abiertos` y
   `Rigor`, lista cerrada por contrato y declarada **una sola vez** en el código (constante de
   `hooks/lib.sh`). `Archivos:` queda fuera: `tools/arnes-paralelo.sh` ya falla cerrado cuando falta.
2. **Variante:** una línea de la cabecera (antes del primer `## `, fuera de `<!-- … -->`, con `:` ASCII)
   cuya clave, tras la normalización que el lector ya hace y tras retirar **como mucho un** marcador de
   lista inicial —buscado tras saltar los bytes descartados, de modo que un BOM o un U+200B delante de
   `- ` no impiden reconocerlo; el blanco que sigue al signo tiene que ser ASCII—, tiene el mismo **esqueleto** que una clave de control —sus letras ASCII en
   minúsculas; para comparar se descartan los blancos y bytes de control ASCII y todo byte ≥ 0x80— y no
   es exactamente esa clave. Se calcula bajo `LC_ALL=C`, sin rangos sujetos a colación, y sólo sobre
   claves de hasta 256 bytes.
3. **Estructura:** si tras el marcador la clave contiene un carácter ASCII imprimible que no es letra
   ni blanco, o uno de nueve delimitadores de cita tipográficos (« » “ ” ‘ ’ „ ‹ ›), la línea **no es
   una declaración** y no es variante. Un byte descartado no decide si una línea es estructura o
   declaración: la condición mira sólo caracteres **visibles**.
4. **Respuesta:** una cabecera **ambigua** —una variante, o una clave de control declarada más de una
   vez, canónica o variante, **aunque los valores coincidan**— **deniega el cierre** citando las líneas
   con los bytes invisibles escapados —las primeras N y cuántas quedan, porque un motivo sin tope puede
   dejar la puerta sin salida y una puerta sin salida permite; el informe las nombra todas—. La variante **nunca** se lee como la clave y ningún lector cambia
   sus valores; reabrir, editar sin intentar cerrar o conservar la forma de un REQ ya cerrado no se
   bloquea, **con una excepción** (la de la variante en disco, en «Consecuencias»): una cabecera que en disco declara el
   estado terminal sólo en una variante deniega toda edición que la conserve. `Hallazgos abiertos`
   canónica repetida conserva la puerta y el motivo de REQ-031 CA-A12.
5. **Fuera, declarado y sin promesa de reconocimiento universal:** el homóglifo; una letra ASCII de más,
   de menos o cambiada; unos dos puntos no ASCII; las líneas con carácter de estructura visible —incluido
   un NBSP en lugar del blanco ASCII que sigue al marcador (`-`+NBSP+`Estado:`), que no forma marcador y
   deja el `-` como estructura—; los caracteres
   del **valor**; las claves de más de 256 bytes, que son una **limitación**: se siguen leyendo como
   ausencia y **no** están protegidas por ese límite; y el `Edit`/`MultiEdit` cuyo `old_string` no está
   **literal** en el archivo: el hook no reconstruye el documento y juzga el fragmento como antes, pero
   la herramienta **puede escribir igualmente** —el `Edit` del CLI 2.1.284 normaliza las comillas
   tipográficas y desescapa `\uXXXX`; leído y emulado, no ejecutado en una sesión real—, y por esa vía un
   cierre puede no pasar por ninguna puerta (**QA-023-02**, preexistente, escalado al propietario y no
   aceptado; esta decisión no lo cierra).

El contrato exacto —casos, costes, lectores y superficie heredada— es `requirements/REQ-023.md` (CA-01…
CA-12, versión del 2026-09-29).

**Lo que supersede, dentro de REQ-023:** la propiedad «cualquier carácter de la clase en cualquier línea
de la cabecera» (CA-01, CA-02), el universo del sorteo de CA-03, el alfabeto derivado y el recuento de
transcripciones de CA-06, los techos de reloj de CA-09 (ii) y (iii), la redacción de la fila de §13 que
pedía CA-10 y el último párrafo de CA-11. **Lo que NO supersede:** ADR-013 (la gramática del valor de
`Hallazgos abiertos:` no cambia; esta decisión la **complementa**: una variante de esa clave sigue sin
leerse, y ahora además deniega el cierre); la regla de lectura de REQ-016 («gana la última» para los
campos, «la primera» para el estado), que sigue siendo con la que **se leen** los valores; y la
semántica de la **ausencia** de un campo, que es REQ-024.

## Alternativas consideradas
- **La propiedad por estado de la redacción del 2026-09-08 (cualquier carácter de la clase en cualquier
  línea deniega).** No: no se implementó; su única palanca medida como viable ya era por **claves** (la
  cata del 2026-09-08 descartó el alfabeto positivo por coste y por locale); no cubría mayúsculas ni
  declaraciones repetidas; y extendida a los valores deniega por caracteres que hoy ya caen del lado
  seguro (un valor de `Sensible a seguridad:` que no se entiende se lee «sí»; un `QA:` fuera de
  vocabulario no cierra; un identificador no ASCII hace ininterpretable `Hallazgos abiertos:`).
- **Leer la variante como la clave (normalizar).** No: ensancha la tolerancia y obliga a **elegir**
  entre variante y canónica cuando discrepan, que es lo que el propietario pidió evitar.
- **Comparar los valores de una clave repetida y denegar sólo si difieren.** No: obliga a normalizar
  valores que pueden ser largos, que es el coste de SEC-115; el propietario aceptó expresamente que la
  repetición deniegue aunque coincidan.
- **El esqueleto sin condición de estructura (la propuesta tal como se presentó).** No: convertía citas,
  ejemplos y explicaciones (`> Estado: completado`, `«Estado»: …`, `(QA): …`) en campos de control.
  Condición exigida por el propietario.
- **Normalizar Unicode o una tabla de homóglifos.** Fuera por instrucción del propietario («No amplíes
  este encargo para resolver todo Unicode ni SEC-115»), y una tabla es la enumeración que envejece hacia
  el lado que abre.

## Consecuencias
- (+) Una variante cubierta o una declaración repetida de una clave de control **no** se convierte en
  silencio en ausencia: no baja el rigor, no oculta un bloqueante y no esconde la propia transición. La
  puerta no elige entre declaraciones contradictorias.
- (+) Es **observacional**: ningún lector (puerta, `tools/arnes-lectura.sh`, `hooks/campos-req.awk`,
  `tools/arnes-paralelo.sh`) cambia los valores que lee; el informe nombra la variante y la repetición.
- (−) **Cambio de compatibilidad, aceptado expresamente por el propietario:** una cabecera con una clave
  de control repetida con el **mismo** valor, que hasta `v1.34.0` cerraba, deniega el cierre. Mitigación:
  el motivo nombra las líneas y la salida (una sola línea por clave, como la plantilla);
  `tools/arnes-lectura.sh` las informa con salida ≠ 0 antes de intentar cerrar; la guía de actualización
  lo explica (REQ-023 CA-10). El ensayo preliminar midió 0 cabeceras ambiguas de 29 en este árbol; se
  vuelve a medir (REQ-023 CA-04).
- (−) La frontera **no es universal**, y se dice: lo que queda fuera se sigue leyendo como ausencia.
  Las claves de más de 256 bytes son una limitación, no una zona protegida.
- (−) Una cabecera que **en disco** declara el estado terminal sólo en una variante, con un `Estado:`
  canónico no terminal, deniega toda edición que la conserve hasta que alguien la corrija; la edición
  que la corrige no se deniega.
- (=) La guarda del retorno de carro, la noción de cita de la cabecera, el techo de `Hallazgos abiertos:`
  y la semántica de la ausencia (REQ-024) no cambian.
