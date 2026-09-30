# SEC-119/O-11 v3b: los casos de host que faltaban (QA-023-11) y el alcance real de QA-023-09. REGISTRO PREVIO, escrito y comiteado antes de ejecutar (2026-09-30)

**Motivo.** QA (vuelta de la quinta autorización, sobre `43b948a`) registró QA-023-11: la validación en el host no ejecutó R5 ni comprobó si el `cwd` del hook sigue a un `cd` anterior (I7/L8, REQ-007 CA-66, punto 6). Tampoco los declaró como límite. Esa segunda comprobación dice además si **QA-023-09** (un `cwd` con salto de línea desplaza los campos de la entrada y las dos puertas dejan pasar) **se alcanza desde el host**. Es validación ya autorizada en la quinta autorización, punto 5; **no es una reparación**. La ejecuta la coordinadora.

**Entorno.** Claude Code 2.1.285, `claude -p`, WSL2, usuario no administrador (uid 1000). La misma sonda que en `sec119-v3`. Hook de `43b948a`, idéntico a `104ffd1`: `guard-completado.sh` 709c0d29…, `lib.sh` 2bba4378…, `guard-codigo.sh` 126fe6a4….

| Caso | Pasos pedidos en la misma sesión | Qué se observa | Esperado |
|---|---|---|---|
| r5 | `Read` y después `Edit` sin estado sobre un REQ en verde con **modo 0200** (sin lectura) | si la herramienta llega a escribir y qué decide el hook | el hook deniega por CA-45 si se le consulta; es posible que el host no llegue a ejecutar el `Edit` porque el `Read` falla |
| cwd-cd | `Bash` `cd docs`, y después **otra** llamada a `Bash` `pwd` | el campo `cwd` de la entrada del hook en la segunda llamada | registrar si es `<proj>` o `<proj>/docs` |
| **cwd-nl** | `Bash` `mkdir -p "$(printf 'x\ny')" && cd "$(printf 'x\ny')"`, después `Read` y `Write` del REQ en rojo por su **ruta canónica**, con `Estado: completado` | el `cwd` que recibe el hook en el `Write`, la decisión y el disco | si el `cwd` sigue al `cd` y QA-023-09 es alcanzable: allow y REQ cerrado; si no: deny |
| cwd-nl-ctl | igual, pero con `mkdir -p xy && cd xy`, sin salto de línea | ídem | deny, por QA pendiente |

**No se extiende a:** Windows, el editor interactivo ni otras versiones del CLI.
