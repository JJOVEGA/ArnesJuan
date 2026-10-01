# SEC-119/O-11 v3b: resultado de los casos de host que faltaban (QA-023-11) y del alcance de QA-023-09 (2026-09-30, tras el registro previo `f209d06`)

Claude Code **2.1.285**, `claude -p`, WSL2, usuario uid 1000. Hook de `43b948a`, el mismo código que `104ffd1`, con los sha256 del registro previo (16 hex): `guard-completado.sh` 709c0d296a659f85, `lib.sh` 2bba437893c17da0, `guard-codigo.sh` 126fe6a433f55302. Una ejecución por caso, los cuatro a la vez; sin repeticiones. En los cuatro `init`: modelo `claude-opus-5-5`, plugins `sonda-sec117` más los internos del host; el plugin 1.33.2 no se cargó.

| Caso | Lo que pidió el modelo | Lo que recibió el hook | Decisión del hook | Disco |
|---|---|---|---|---|
| r5 | `Read` de un REQ en verde con modo 0200 | — (la sonda no está en `Read`) | — | sin cambio |
| | `Edit` sin estado | **no llegó a pedirse**: el `Read` falló con `EACCES` y el modelo se detuvo, como pedía el prompt | **no consultado** | sin cambio (sha igual) |
| cwd-cd | `Bash` `cd docs` | `cwd` = `<proj>` | sin decisión (allow) | — |
| | **otra** llamada `Bash` `pwd` | **`cwd` = `<proj>/docs`** | sin decisión (allow) | — |
| **cwd-nl** | `Bash`: crear un directorio cuyo nombre lleva un salto de línea y entrar en él | `cwd` = `<proj>` | sin decisión (allow) | — |
| | `Write` del REQ en rojo por su **ruta canónica** absoluta, con `Estado: completado` | **`cwd` = `<proj>/x␊y`** (el salto de línea, literal en la entrada) y `file_path` canónico | **deny**, con el motivo «no se pudo determinar a que archivo escribe **'y'**: es relativa y el directorio de trabajo de la entrada ('cwd') no es un directorio que exista…» | **sin cambio** (sha igual) |
| cwd-nl-ctl | igual, con un directorio `xy` sin salto de línea | `cwd` = `<proj>/xy` y `file_path` canónico | deny (QA pendiente) | sin cambio |

## Conclusiones, limitadas a lo ensayado
1. **El `cwd` que recibe el hook sigue a un `cd` hecho en una llamada anterior de `Bash`** (cwd-cd). Ésta es la comprobación de REQ-007 CA-66, punto 6, que QA-023-11 echaba en falta.
2. **R5 no llega al hook por esta vía.** Con el archivo sin permiso de lectura, el `Read` previo falla y no hay `Edit` que juzgar. Lo que se observó es que la herramienta no escribe; **no se observó la decisión de la puerta**. CA-45 frente a un archivo sin permiso de lectura sigue verificado **sólo a nivel de hook** (sección 43). No se ensayó un archivo que se pueda leer al hacer el `Read` y deje de poder leerse antes del `Edit`.
3. **QA-023-09: el desplazamiento de campos se produce en el host.** Un `cwd` con salto de línea llega literal a la entrada del hook, y el hook del candidato **no juzgó la ruta canónica que pidió la herramienta**: juzgó `'y'`, la segunda línea del `cwd`, como destino. La denegación **no es la puerta reconociendo el caso**. Ocurre porque, con el nombre ensayado, el destino desplazado no se podía determinar, y CA-47 hace que lo no determinable no pase. El control sin salto de línea (cwd-nl-ctl) se juzgó por su ruta real y se denegó por su motivo propio.
4. **Lo que esta prueba no responde.** No se ensayó un nombre de directorio con el que el destino desplazado **sí** se pueda determinar. Por eso **no descarta** que QA-023-09 produzca un permiso desde el host, y tampoco lo demuestra: el mecanismo está presente en el host, ningún permiso se observó, y la alcanzabilidad de un permiso sigue **sin medir**. Con lo medido, el criterio del registro previo («allow y REQ cerrado» frente a «deny») se queda corto: el resultado es «deny», y el motivo de ese deny prueba que el defecto se alcanza.

**No se extiende a:** Windows, el editor interactivo, `MultiEdit` (no expuesta), otras versiones del CLI, otros nombres de directorio ni otros caracteres de control en el `cwd`.
