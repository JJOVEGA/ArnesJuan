# `AGENTS.md`: historia medida y mecánica trasladadas (propuesta REQ-019, vía A)

> Texto **movido verbatim** desde `AGENTS.md` (§6 y §13) el <fecha de aplicación>; el enunciado de cada regla y su acotación siguen en `AGENTS.md`. Aquí vive el *por qué* y la mecánica que se consulta cuando aparece el caso.

## Loop de error

Esto es deliberado: un tope por hallazgo no acota nada, porque cada
arreglo cierra el hallazgo documentado y la vuelta siguiente encuentra una variante. Un REQ
puede pasar semanas en `en-revisión` sin haber gastado nunca tres vueltas del mismo hallazgo.

## Bloque derivado

**Las celdas de veredicto del bloque derivado salen recortadas a 40 caracteres.** Es
presentación: la puerta y `tools/arnes-lectura.sh` leen el valor entero. Un bloque de
continuidad en el que cuatro veredictos largos ocupan un tercio —y rompen la tabla— deja
de servir para lo único que existe.

## Rotación

**Otro que tampoco decide: la rotación.** Un artefacto de bitácora —`CHANGELOG.md`, el registro
de seguridad— crece sin tope, y todo lo que crece sin tope acaba entrando entero en la ventana
de contexto. Con `rotacion.activo: true`, al parar un agente el arnés **mueve** las secciones
sobrantes a `<nombre>-archivo.md` y deja un puntero. **Mueve; no resume** — un resumen
convertiría la bitácora en la versión que el modelo recuerda de ella. Viene apagada.
También puede archivar **una sección** de un documento —típicamente la historia de un REQ— a
`historial/<nombre>.md`, dejando **el resto intacto**: la cabecera con sus veredictos y los
criterios de aceptación no se tocan nunca, porque son el contrato. Qué sección es historia lo
declara este proyecto en `rotacion.artefactos` (`glob` + `seccion`); el arnés no trae ninguna por
defecto, y el nombre se compara **exacto**, nunca por prefijo.

## Continuidad

**Un hook que no decide nada: la continuidad.** Al parar un agente (`Stop` / `SubagentStop`),
el arnés reescribe en `docs/ESTADO.md`, entre marcadores, un bloque **derivado** del disco:
estado y veredictos de cada REQ, cola de aprobaciones, rama y limpieza del árbol. No permite ni
impide nada — existe porque **un resumen redactado por el modelo miente justo cuando más falta
hace**, que es cuando le queda poco contexto. Por eso no se redacta: se deriva, y cada línea
sale de leer un archivo. Nunca bloquea la parada y se apaga con
`estado_derivado.activo: false`. **Y sobre el texto que hay fuera de los marcadores, las dos
mitades — porque una se afirmó sin condición y estaba medida falsa.** *Sí:* fuera de los
marcadores no se modifica nada; si eso no se puede **leer** no se escribe nada y se avisa; y
cada parada publica por un temporal **propio de su proceso** y lo mueve encima, así que dos
paradas simultáneas no comparten archivo (hasta 1.32.0 el temporal tenía **nombre fijo** y por
ahí se perdió texto humano **1 de 25** vueltas del banco; cerrado en 1.32.1, REQ-015). *No:*
no hay **serialización ni orden** — con dos paradas a la vez gana la última que publica, y es
conforme porque el bloque es derivado del mismo disco; y si al proceso lo **matan** sin darle
salida, su temporal puede sobrevivir hasta la parada siguiente, que lo retira.

## Manifiesto

**Nombre del agente en el manifiesto:** basta el nombre corto (`desarrollador`). El hook tolera
el prefijo del plugin que Claude Code añade en runtime (`arnes-juan:desarrollador`), así que no
hay que escribirlo. Escribirlo es opcional y hace la comparación **estricta**: `agentes.agente_codigo`
con prefijo sólo acepta a ese proveedor, útil si conviven dos plugins con un agente homónimo.

