# REQ-007 — historia: sedes y pruebas de los versionados ya construidos (1.35.0)

> **Movido desde `requirements/REQ-007.md` el 2026-10-12** por la undécima autorización del propietario
> (ficha **F-136-17**), cabeza de origen **`cecf9b6`**, líneas **3602–3615 y 3737–3809** (87 líneas, 12 385 bytes medidos).
> **Copia verbatim: no se resumió, no se reordenó y no se corrigió nada.**
> Índice: `docs/historia/REQ-007/README.md`. Contrato: `docs/arnes/v1.37.0-f136-17-fase1.md`.
> Comprobación de que no se perdió ninguna línea: ese contrato, §5, y el índice.

**Construido en `9220c71` (desarrollador), y declarado aquí para que no quede como deriva:** la detección de lo que
depende del proceso vive en `_arnes_propio` y `_arnes_id_propio`, el origen de la segunda lectura física en
`_arnes_cd_resolucion` y el reconocimiento del descriptor estándar, sin proceso, en `_arnes_id_resuelve_enlace`
(`hooks/lib.sh`); la lectura cruda de la entrada, en `arnes_parse_input`, y `_arnes_repone_cr` desaparece; el
delimitador de heredoc con un retorno de carro devuelve `ARNES_RC_CR` desde `arnes_bash_sin_texto`, y
`guard-codigo.sh` y `guard-completado.sh` lo traducen a su denegación. `guard.sh` y `guard-git.sh` no cambian
(sha256 de la entrada del desarrollador en `CHANGELOG.md`).

**Construido en `befc17a` (pasada correctiva, desarrollador), y declarado aquí por lo mismo:** `guard-git.sh`, si el
comando lleva un retorno de carro, añade a lo que juzga una copia de las órdenes sin él (`arnes_guard_git`), y su
motivo lo dice; y en `arnes_id_pertenece` (`hooks/lib.sh`) un descriptor ya no sale «fuera» antes de las tres vías:
su ruta se juzga como la de cualquier enlace y la ranura del descriptor no entra en la lectura física. `guard.sh`,
`guard-codigo.sh` y `guard-completado.sh` no cambian (`evidencia-dev-r8b/07-`).

### Sedes y pruebas del versionado del 2026-09-30 (para el desarrollador)

Barrido del analista **por propiedad** —todo código, comentario, mensaje, prueba o texto que afirme cómo se
identifica el destino de una escritura o cómo se trata un REQ que no se puede leer entero—, hecho en el
árbol de `1ebe1c1` con `grep` sobre `hooks/`, `tools/`, `tests/`, `templates/`, `skills/`, `agents/` y
`playbooks/`. Es **no exhaustivo**: el desarrollador repite el barrido en todo el árbol antes de entregar.
Las líneas son de `1ebe1c1`.

| Sede | Qué dice o hace hoy | Qué pide el contrato |
|---|---|---|
| `hooks/lib.sh:37-48` `arnes_parse_input` | no lee `.cwd` | leerlo en la **misma** llamada a `jq` (CA-47, punto 1; CA-48 (i.1)) |
| `hooks/lib.sh:405-442` `arnes_norm_path` | se llama «ruta canónica», y sólo unifica separadores y barras | su conducta **no cambia**: la usa `tools/arnes-paralelo.sh:180-182` (CA-48 (h)); la identidad va en otro sitio |
| `hooks/lib.sh:444-455` `arnes_ruta_relativa` | recorta la raíz como texto; su comentario dice que una relativa «se deja tal cual, asumiendo que el comando corre en la raíz» y que el error es «falso negativo, nunca positivo» | premisa desmentida: la relativa se ancla en el `cwd`, y el error era también falso positivo (CA-48 (f), L8). Pertenencia por CA-47, punto 6 |
| `hooks/lib.sh:312-328` `arnes_dir_interno` | resuelve con dos subshells, pagados sólo en una parada | **no** se reutiliza en un `PreToolUse`: cuesta procesos (CA-48 (i.1)) |
| `hooks/lib.sh:1073-1084` (detector, `cp`/`mv`/`install`) | emite el destino y, si no acaba en `/`, también `destino/`, para cubrir el directorio | la barra final conserva su sentido tras identificar el destino (CA-47, punto 10; CA-66, L5) |
| `hooks/lib.sh:1111-1134` `arnes_lee_archivo` | «no existe: no hay texto, y eso sí se sabe», decidido con `-e` | `-e` también falla si un directorio no se puede recorrer: sólo vale tras resolver el tramo existente (CA-47, punto 8) |
| `hooks/lib.sh:1187-1218` `arnes_deny_enlace` | bloque «el arnes juzga LA RUTA ESCRITA, no su destino», «SIN RESOLVER», «resolver abriria una CARRERA», «`Bash` no paga nada»; excluye las rutas con `..`; motivo con «El arnés juzga la ruta escrita, no su destino» | premisa superada (CA-49): se conserva sólo (i), sin excluir `..`; el motivo deja de afirmarla; (ii) y los destinos de `Bash` |
| `hooks/lib.sh:1243-1275` `arnes_deny_manifiesto_roto` | compara la ruta relativa **como texto** con la del manifiesto | por identidad (CA-60, versionado) |
| `hooks/guard-completado.sh:304-305` y `hooks/guard-codigo.sh:34-35` | «SEC-004: una escritura a través de un enlace simbólico no se juzga, se deniega» | se acota a CA-49 (i) |
| `hooks/guard-completado.sh:351-367` (vía `Bash`) | salta los destinos que empiezan por `/dev/` o `/tmp/` como texto; ancla las relativas en la raíz | pertenencia por CA-47; ningún atajo textual decide que un destino esté fuera (I8) |
| `hooks/guard-completado.sh:369-374` (vía `Edit`/`Write`/`MultiEdit`) | pertenencia por la ruta escrita | por CA-47, punto 6; no determinable → CA-47, punto 7 |
| `hooks/guard-completado.sh:409-430` (`disk_medible`) | comentario «Lo que decide sigue siendo LA TRANSICION… Una edicion que no lo menciona no queda bloqueada por el byte»; deniega sólo si menciona el terminal; motivo «Quita el byte NUL… y reintenta» | CA-45 (ii): `Edit`/`MultiEdit` → deny siempre; `Write` → juzgado entero como transición; el motivo dice la causa sin nombrar herramientas |
| `hooks/guard-completado.sh:415-419, 469, 500` | lee y comprueba `$fp` tal como llegó | la lectura física del destino (CA-47, punto 9) |
| `hooks/guard-codigo.sh:80-91` | pertenencia de los destinos de `Bash` y del `file_path` por la ruta escrita | por CA-47 |
| `tests/escenarios/hooks/secciones/32-huecos-auditoria-r001.sh:65-79` | comentario de SEC-002 y control de CA-46 que espera **allow** (línea 74) | R1 y R6 (a) (CA-66, punto 4) |
| `tests/escenarios/hooks/secciones/33-acento-y-clave-2-manifiesto.sh:8-62` | título «La ruta escrita…», comentarios de «la ruta escrita» y de la «desviación declarada», patrón del motivo de la línea 14, y el enlace fuera de la raíz → allow | motivo nuevo; etiqueta retirada; L3 con su pareja I12; casos de CA-60 por identidad (M1) |
| secciones 01, 04, 06, 07, 09, 14, 16 y 42 | controles con rutas canónicas, formas de Windows (04, sólo con `cygpath`), destinos de `Bash` (06, 07, 09) y regresión de REQ-023 CA-13 (14, 42) | sin cambio de veredicto salvo lo declarado en CA-66, punto 5; se adaptan sólo si hace falta para seguir llegando a su control |
| sección nueva (nombre propuesto `43-identidad-del-destino.sh`), `run.sh`, `README.md` del banco y `autoprueba-corredor.sh` | — | las filas de CA-66, con el fail-before contra `9596e39`; el total de casos esperados y el índice de secciones |

**Lo que no se toca desde aquí:** `tools/arnes-paralelo.sh` sólo entra en `Archivos:` por si el desarrollador
necesitara adaptarlo sin cambiar su conducta; la guía `arnes-upgrade` § «Hacia 1.31.0» describe lo que hizo
esa versión y no se reescribe —la entrada «Hacia 1.35.0» dice que su premisa queda superada—.

### Sedes y pruebas del versionado del 2026-10-01 (para el desarrollador)

Lo que CA-47, puntos 11 a 13, y CA-66 (versionado del 2026-10-01) piden al código y al banco. Es **no
exhaustivo**: el desarrollador repite el barrido por propiedad antes de entregar. «Hoy» es el árbol de trabajo de
esta vuelta, sin comitear, tal como lo describe la evidencia del desarrollador (`evidencia-dev-r6/`).

| Sede | Qué hace hoy | Qué pide el contrato |
|---|---|---|
| `hooks/lib.sh`, `arnes_parse_input` | declara en la primera línea de la salida de `jq` cuántos saltos lleva cada campo y lee cada uno entero (QA-023-09) | conforme con el punto 11; se conserva |
| la identificación del `file_path` de `Edit`/`Write`/`MultiEdit` | juzga entera una ruta con salto de línea | punto 12: no determinable si el **texto del `file_path` tal como llega** lleva un LF; **no** sobre la ruta anclada en el `cwd` ni sobre los destinos de `Bash`. El borrador `opcion-b-file-path-con-salto.patch.txt` lo comprueba en `_arnes_id_calcula` sobre la ruta tal como llega, que no incluye el `cwd` (conforme en eso); pero esa función identifica también los destinos de `Bash`, así que o la comprobación se limita al `file_path`, o se demuestra que el detector no emite destinos con salto de línea |
| el motivo del punto 7 | — | la causa del punto 12 (la ruta lleva un salto de línea) y su arreglo (escribirla sin saltos), sin nombrar herramientas |
| `guard-codigo.sh` y `guard-completado.sh` (o `guard.sh`) | `Bash␊` no es `Bash` y pasa; `Edit␊` no es `Edit` y pasa | punto 13: un `tool_name` con LF se trata como una escritura no determinable por `Edit`/`Write`/`MultiEdit` |
| sección 44 | N1–N15, C1–C10 y P1 | las filas de CA-66 (versionado del 2026-10-01) en sus tres columnas: C9 pasa a `deny` (F4) y C10 conserva `deny` con el motivo de no determinable (F1); filas nuevas para el `Write` de E1, F2, F4 y T1 |
| `run.sh`, `README.md` del banco | — | el total de casos esperados y el índice de secciones |

**Construido en `cd6afa6` (desarrollador), y declarado aquí para que no quede como deriva:** la comprobación del
punto 12 vive en `_arnes_id_calcula` y se aplica sólo cuando la ruta que se identifica es el `file_path` de una
llamada que no es de `Bash` —por eso alcanza también a una herramienta desconocida (punto 12, precisión del
2026-10-01)—; que los destinos de `Bash` no lleven nunca un salto lo afirma el desarrollador en el comentario
del código (el detector trocea por palabras), y su batería lo ejerce en X3 a X5 sin movimiento.
`arnes_deny_manifiesto_roto` identifica el `file_path` entero, de modo que un `file_path` con salto no pasa como
la reparación del manifiesto (nota del 2026-10-01 en CA-60). El punto 13 lo aplican `guard-codigo` y
`guard-completado` al empezar. La sección 44 cubre las filas de CA-66 (versionado del 2026-10-01).

### Sedes y pruebas del versionado del 2026-10-03, fase 2 (para el desarrollador)

Lo que CA-47, puntos 18 y 19, y CA-66 (versionado de la novena autorización, fase 2) piden al código y al banco.
Es **no exhaustivo** y describe el árbol de `3f96e6b`, leído por el analista sin ejecutar nada: el desarrollador
repite el barrido por propiedad antes de entregar. **La técnica es suya**; esta tabla dice dónde está hoy la
conducta, no cómo cambiarla.

| Sede (`3f96e6b`) | Qué hace hoy | Qué pide el contrato |
|---|---|---|
| `hooks/lib.sh`, `arnes_bash_sin_texto`, bucle de heredocs | cierra el cuerpo sólo con una línea igual al delimitador, así que la que lleva un retorno de carro final sigue en el cuerpo, como para el shell; devuelve `ARNES_RC_CR` sólo para el delimitador con retorno de carro | punto 18: detectar la línea, sin alterar el texto ni el sitio donde acaba el cuerpo, y llevarla a una denegación con su motivo propio y los destinatarios del punto 17 |
| `hooks/guard-codigo.sh` y `hooks/guard-completado.sh`, traducción de los códigos de `arnes_bash_escrituras` | traducen `ARNES_RC_EXCESO` y `ARNES_RC_CR` a su denegación | punto 18: el motivo con `SEC-124`, la causa y la salida, sin nombrar herramientas; `guard-codigo` a quien no es el agente de código, `guard-completado` a todo agente |
| `hooks/guard-git.sh`, `arnes_guard_git` | ante un código distinto de 0 de `arnes_bash_sin_texto` permite y deja la denegación a las otras dos puertas; pliega la continuación sobre el texto ya descontado (SEC-009) | punto 18: la forma tiene que quedar denegada por `guard.sh` aunque `guard-git` no la juzgue; punto 19: su pliegue es referencia, no plantilla, y su conducta no cambia (REQ-005 CA-40 y CA-41, sección 29), **salvo** la «Excepción nombrada» (LC10), que `guard-git` también deniega, a todo agente y sin orden de git |
| `hooks/lib.sh`, `arnes_bash_sin_texto`, bucle de heredocs (reconocimiento de la línea que abre) | empieza el cuerpo en la línea siguiente a la que abre el heredoc aunque ésta acabe en una continuación de línea, y lo que hay en ella no llega a ninguna puerta (QA-023-23; `docs/qa/REQ-023.md`, «medición de LC10») | punto 19, «Excepción nombrada»: detectar esa forma sin alterar el texto ni mover dónde empieza el cuerpo, y llevarla a una denegación con su motivo propio (`SEC-125`, `LC10`) en las cuatro puertas, a todo agente; filas LC10.1 a LC10.9, LC10.c1 y LC10.c2 de CA-66 (fase 2) |
| `hooks/lib.sh`, `arnes_bash_escrituras` | trocea por blancos y toma como destino el operando siguiente al operador, o los de `tee`, `cp`/`mv`/`install`, `sed -i`/`perl -i` y `of=`: con una continuación detrás del operador, el destino leído es la barra | punto 19: el destino que escribe el shell, plegando sólo donde el shell pliega |
| sección 45 (o la que se declare), `run.sh`, `README.md` del banco | — | las filas HC y LC de CA-66 (fase 2) con sus cuatro columnas; el total de casos esperados |

