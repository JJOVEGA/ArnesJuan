# ADR-013 — Gramática cerrada del campo `Hallazgos abiertos:`: tras el paréntesis de un hallazgo, sólo la coma o el fin del campo
Fecha: 2026-09-27
Estado: aceptada

## Contexto
`guard-completado` decide si un REQ puede quedar `completado` leyendo el campo `Hallazgos abiertos:`.
En la base `a7a60c2` (plugin 1.34.0) parte la lista **sólo** por comas fuera de paréntesis y toma como
clase de cada elemento lo que va del **primer** `(` a su `)` (`hooks/guard-completado.sh:504-522`). Lo que
sigue a ese `)` dentro del mismo elemento **no se lee**. Medido el 2026-09-27
(`evaluacion-2026-09-27/A-hallazgos-separador.txt`): `SEC-A (instrumento) · SEC-B (usuario/dinero)` y
`SEC-A (instrumento); SEC-B (contrato)` **permiten** cerrar y dejan el archivo `completado` con un
hallazgo bloqueante abierto.

A la vez, REQ-007 CA-41 (2026-09-05) había declarado **tolerada** una forma con texto detrás del
paréntesis, `QA-006 (instrumento) — REQ-007`, con el compromiso «este criterio no puede estrechar lo que
ya se leía», certificado por el caso `REQ-717` del banco. Las dos cosas no caben juntas: si el texto
detrás del paréntesis se tolera, `SEC-A (instrumento) · SEC-B` —un segundo hallazgo sin clase— también
cierra.

## Decisión
El campo tiene una **gramática cerrada** (REQ-031 CA-A01): elementos separados por comas fuera de
paréntesis; cada elemento es identificador + `(` clase [`,` evidencia] `)`, y **tras el paréntesis
completo sólo se admite la coma separadora o el fin del campo**. Todo lo demás es **no interpretable** y
**deniega** el cierre con un motivo que nombra el fragmento y dice cómo conservar la evidencia (dentro
del paréntesis, tras la clase y una coma). Nada se descarta en silencio y ningún hallazgo ambiguo se
normaliza automáticamente. En consecuencia, REQ-007 CA-41 se **versiona**: la forma `(clase) — nota`
deja de aceptarse y `REQ-717` pasa de `allow` a `deny`.

Decisión del propietario: `PENDING_APPROVAL.md` § Resueltas, «REQ-031, decisión P-1: opción B»
(2026-09-27).

Se registra como ADR porque, por la regla de `AGENTS.md` §9, es un cambio **de fondo** —cambia la
**decisión base** de REQ-007 CA-41 (el compromiso de no estrechar) y el **significado** de cómo la
puerta lee el campo—, no por su tamaño.

## Alternativas consideradas
- **Opción A — admitir texto detrás del paréntesis si no lleva `(` ni `)`.** Conserva REQ-007 CA-41 y
  el caso del banco. **No:** `SEC-A (instrumento) · SEC-B` y `SEC-A (instrumento) — SEC-B` cierran con
  un hallazgo sin clase ignorado por su separador, que es la propiedad que el propietario exige.
- **Opción B — gramática cerrada (elegida).** La propiedad se cumple sin excepción, y la forma retirada
  tiene equivalente admitido (`QA-006 (instrumento, REQ-007)`), así que no se pierde información.
- **Aceptar «cualquier separador».** Rechazada expresamente por el propietario: no es una
  especificación y amplía la tolerancia sin límites.

## Consecuencias
- (+) Ningún hallazgo bloqueante queda sin leer por su posición o su separador **dentro de la línea
  `Hallazgos abiertos:` de la cabecera, ni por haber repartido el campo en dos líneas con esa clave**
  (REQ-031 CA-A12: la clave repetida deniega); lo que la puerta no entiende lo dice, en vez de
  permitir. **Alcance, enunciado por propiedad** (precisión del 2026-09-27, R-044 / SEC-112; el texto
  anterior de esta viñeta prometía sin condición): la puerta lee **las líneas de la cabecera cuya clave
  reconoce el lector**; lo que no está en una línea así no se lee. Ejemplos **no exhaustivos** de lo que
  queda fuera: una continuación en la línea siguiente sin clave, una clave con un carácter invisible o
  un homóglifo (SEC-047, SEC-078), un comentario HTML de la cabecera, una línea debajo del primer `## `.
- (+) El tamaño del valor tiene techo y el recorrido del bloque «Clase del hallazgo» no es cuadrático
  (REQ-031 CA-A13, CA-A14; R-044 / SEC-113): por encima de 16 384 bytes la puerta deniega sin
  interpretar el valor **siempre que el hook alcance a medirlo dentro del límite del cliente (60 s)**.
  *(Precisión del 2026-09-27, R-044-A / SEC-114; el texto anterior decía que «un valor que la puerta no
  alcanzaría a juzgar antes de que el cliente la mate deniega», sin condición.)* La normalización de
  campos (`arnes_norm_campo`, cuadrática, código anterior a este REQ) corre antes del techo, y con un
  valor del orden de 240 KB o más el hook muere sin denegar (medido, una corrida, Linux/WSL2: 255 371
  bytes → 67,0 s; en Windows/MSYS no medido y menor): un hook muerto no deniega. Residuo `instrumento`
  con dueño y vencimiento en `docs/PENDIENTES.md`; medir el techo antes de normalizar es decisión del
  propietario para la publicación.
- (−) Una forma antes aceptada (`(clase) — nota`) pasa a denegar. Mitigación: el motivo enseña la forma
  equivalente; QA inventaría las cabeceras de `requirements/REQ-*.md` del arnés e informa los usos sin
  reescribirlos (REQ-031 CA-A04); un REQ `completado` no se reabre por esto.
- (−) Los proyectos ya instalados que usen `;`, `·` o texto detrás del paréntesis verán denegado el
  cierre al actualizar el plugin, y su `requirements/README.md` congelado no explicará la sintaxis
  hasta que `arnes-upgrade` lo migre. La nota de migración es trabajo de consumidores, fuera de REQ-031,
  y se presenta en la decisión de publicación.
- (=) La evidencia dentro del paréntesis sigue sin declarar nada; una continuación del campo en la línea
  siguiente sigue sin detectarse (fronteras declaradas en REQ-031, Notas).
