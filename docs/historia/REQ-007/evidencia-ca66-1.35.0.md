# REQ-007 — historia: CA-66, evidencia por versionado (1.35.0)

> **Movido desde `requirements/REQ-007.md` el 2026-10-12** por la undécima autorización del propietario
> (ficha **F-136-17**), cabeza de origen **`cecf9b6`**, líneas **1649–1687, 1710–1780, 1807–1920, 2013–2123 y 2154–2194** (376 líneas, 47127 bytes medidos). Las cuatro viñetas «Punto 5» (1688–1709, 1781–1806, 1921–2012 y 2124–2153) **volvieron al REQ** el 2026-10-13 por P-137-F (QA-007-20).
> **Copia verbatim: no se resumió, no se reordenó y no se corrigió nada.**
> Índice: `docs/historia/REQ-007/README.md`. Contrato: `docs/arnes/v1.37.0-f136-17-fase1.md`.
> Comprobación de que no se perdió ninguna línea: ese contrato, §5, y el índice.

  - **Versionado el 2026-10-01 (sexta autorización, `PENDING_APPROVAL.md` § Resueltas, commit `fb6eaab`,
    puntos 2, 4 y 5; write-back de QA-023-09 y QA-023-11). Casos de CA-47, puntos 11 a 13, en la sección
    `tests/escenarios/hooks/secciones/44-integridad-de-la-entrada.sh`.** Los puntos 1 a 8 de arriba se
    conservan; éste los amplía así. **No reinicia ningún contador:** el de REQ-023 sigue agotado (3 de 3).
    - **Punto 1, fail-before de esta reparación:** contra **`43b948a`**, el árbol con la regresión. Toda fila
      `allow` en esa columna y `deny` en la del candidato tiene que permitir de verdad en `43b948a`, o el caso
      aborta; si `43b948a` no se puede materializar, SKIP con el motivo, nunca PASS. La columna `9596e39` es
      la referencia de antes de la regresión, y es la que cuenta para los movimientos (punto 5).
    - **Punto 3, casos mínimos** —mínimos y **no exhaustivos** de la propiedad de CA-47, puntos 11 a 13—. `␊`
      es un salto de línea dentro del campo. Salvo que la fila diga otra cosa, la escritura es la del punto 3
      de arriba —un `Edit` literal que cierra un REQ `critico` con QA y seguridad pendientes, o un `Write` de
      la coordinadora a `src/a.ts`—, y se ejerce en cada puerta donde aplica **y por `guard.sh`**. **En las
      filas E, el motivo de cada `deny` se comprueba por la ruta que cita:** la canónica que designa la
      entrada, no un trozo del `cwd`. La columna «Host» usa el vocabulario del punto 3 de arriba.

      | # | Caso | Host | Candidato | `43b948a` | `9596e39` |
      |---|---|---|---|---|---|
      | E1 | cierre de un REQ por su ruta canónica con un `cwd` que lleva un salto —ejemplos **no exhaustivos**: `/tmp␊b`, `<raíz>␊`, `<raíz>␊<raíz>/docs`—, por `Edit`, por `MultiEdit` y por `Write` (la forma del host), con al menos uno de esos `cwd` por herramienta | el `cwd` con salto llega del host (medido, v3b, por `Write`) | deny, el motivo cita el REQ | allow | deny |
      | E2 | `Write` de la coordinadora a `<raíz>/src/a.ts` con un `cwd` de los de E1, al menos dos distintos | ídem | deny, el motivo cita `src/a.ts` | allow | deny |
      | E3 | con `cwd` `/tmp␊b`: la edición no reconstruible de SEC-117 (motivo de REQ-023 CA-13) y el `Edit` sobre el enlace de CA-49 (i) (su motivo) | ídem | deny | allow | deny |
      | E4 | por `Bash`, destino relativo anclado en un `cwd` **real** con salto: `printf x > ../../src/a.ts` desde `docs/a␊b`; `printf x > a.ts` desde `src/s␊t`; un `sed -i` con el estado terminal sobre `REQ-9.md` desde `requirements/r␊q` | por `Bash`, sin medir | deny, el motivo cita la ruta canónica con su salto | deny, juzgando otra ruta | allow (clase I7) |
      | E5 | un salto en el agente, escribiendo `src/a.ts`: `agent_type` `qa-tester␊desarrollador` y `desarrollador␊qa`; `agent_id` `a␊1` de un `qa-tester` | sin medir | deny | allow | allow |
      | G1 | lo legítimo con el **mismo** `cwd`: el `desarrollador` escribe `src/a.ts` con `cwd` `/tmp␊b` y, por `Bash`, `printf x > a.ts` desde `src/s␊t`; la coordinadora escribe `<raíz>/docs/n.md` con `cwd` `/tmp␊b`; `ls -la`, una edición literal sin estado y el cierre de un REQ en verde, con `cwd` `/tmp␊b` | — | allow | allow | allow |
      | G2 | la coordinadora, por `Bash`, `echo x > n.md` desde `docs/a␊b`; y el cierre de un REQ en verde con `cwd` `docs/a␊b` | — | allow | deny | allow |
      | G3 | `echo x > src/a.ts` de la coordinadora desde `docs/a␊b` (designa `docs/a␊b/src/a.ts`: instancia de L8) | por `Bash`, sin medir | allow | deny | deny |
      | F1 | `file_path` con salto (punto 12) que ya se denegaba: `<raíz>/src/a.ts␊` y `<raíz>/src/s␊t/a.ts` de la coordinadora; un `Write` con el terminal y QA pendiente a `<raíz>/requirements/REQ-X.md␊`; un `Edit` que cierra por esa misma ruta | sin medir | deny, motivo de no determinable | deny, con otro motivo | deny, con otro motivo |
      | F2 | `file_path` con salto que la lectura entera habría permitido: la coordinadora escribe `<raíz>/app/a.ts␊` con `app/*.ts`, y `<raíz>/cfg/main.json␊` y `<raíz>/cfg/main.json␊x` con el patrón exacto `cfg/main.json`; un `Edit` de creación —una edición, `old_string` vacío— sin terminal sobre `<raíz>/requirements/REQ-X.md␊`; un `Edit` que cierra por `<raíz>/docs/l-req.md␊` (el enlace de CA-49 (i) seguido de un salto) | sin medir qué escribe el host | deny, motivo de no determinable | deny, con otro motivo | deny, con otro motivo (el `Edit` de creación: allow en 1.33.2) |
      | F3 | `file_path` con un salto seguido de `..`: `Write` a `<raíz>/docs/x␊/../../src/a.ts` y `Edit` que cierra por `<raíz>/docs/x␊/../../requirements/REQ-X.md` | sin medir | deny, motivo de no determinable | allow | allow |
      | F4 | `file_path` con salto fuera del ámbito o legítimo: un `Write` sin terminal a `<raíz>/requirements/REQ-X.md␊`; la coordinadora escribe `<raíz>/docs/n.md␊`; `<fuera>␊<raíz>/requirements/REQ-X.md` (O-16); el `desarrollador` escribe `<raíz>/app/a.ts␊` | sin medir | deny, motivo de no determinable | allow | allow |
      | T1 | `tool_name` con salto (punto 13): de la coordinadora, `Write␊` a `src/a.ts`, `Bash␊` con `echo x > src/a.ts` y `Edit␊` que cierra un REQ; y del `desarrollador`, `Write␊` a `src/a.ts`, que `guard-completado` deniega a todo agente | sin medir | deny, motivo del punto 13 | `Write␊` allow · `Bash␊` deny, con otro motivo · `Edit␊` allow | igual que `43b948a` |
      | P1 | el análisis de la entrada conserva cada campo que lee, con un salto en cada uno y al final de uno (sobre la biblioteca) | — | conserva | desplaza | — |

      Además, un caso comprueba que los motivos de F y T dicen su causa —en F, también cómo corregirla— y no
      nombran ninguna herramienta como salida.

    - **Punto 4, adaptación:** en la sección 44, la fila C9 —la coordinadora escribe `<raíz>/docs/n.md␊`—
      pasa de `allow` a `deny` (F4), y la C10 —`<raíz>/src/a.ts␊`— sigue en `deny` con el motivo de no
      determinable (F1); las dos se justifican en el Historial. Si otra sección cambia de expectativa por
      los puntos 11 a 13, se declara con su justificación, como manda el punto 4 de arriba.
    - **Punto 6, validación en el host:**
      - **Hecho (v3b), con su alcance:** el `cwd` tras un `cd` (I7, L8), observado en una ejecución
        —CA-45, versionado del 2026-10-01, (i)—; y R5, que no llegó al hook: **límite de la comprobación en
        el host** —CA-45, mismo versionado, (ii)—. Las dos cierran lo que el punto 6 de arriba pedía «donde
        sea reproducible», y ninguna se presenta como decisión de la puerta.
      - **Pendiente, después de esta comisión (la ejecuta la coordinadora):** reutilizar el caso `cwd-nl`
        de `sec119-v3b` con el hook reparado —un directorio cuyo nombre lleva un salto de línea, el `cd` a él
        y el `Write` del REQ en rojo por su ruta canónica—, con su control sin salto (`cwd-nl-ctl`) y **un
        control legítimo con el mismo `cwd`** —ejemplo **no exhaustivo**: una escritura fuera del ámbito—.
        Es conforme si el hook recibe el `cwd` con el salto literal, deniega con un motivo que cita la ruta
        canónica del REQ y su causa propia —el veredicto que falta—, no un fragmento del `cwd`, y el disco no
        cambia; y si el control legítimo se permite y el disco lo refleja. Para cada caso se registra lo del
        punto 6 de arriba. **A la fecha de este versionado no está hecha,** y nada de este REQ la da por
        hecha.
      - **Lo que acredita la v3b anterior al arreglo, y lo que no:** que el desplazamiento se producía en el
        host; **no** que la puerta protegiera —denegó porque el destino desplazado no se podía determinar— ni
        que un permiso desde el host fuera imposible: quedó sin observar ni descartar (CA-47, punto 11).
      - **No se mide** qué escribe el host con un `file_path` que lleva un salto de línea: CA-47, punto 12,
        no depende de ello. Nada de esto se extiende a Windows/MSYS, a `MultiEdit`, al editor interactivo ni
        a otras versiones del CLI.
    - **Punto 7, compatibilidad, además:** un `Edit`, `Write` o `MultiEdit` cuyo `file_path` lleva un salto
      de línea se deniega, sea cual sea su ruta y su agente; también una entrada cuyo `tool_name` lo lleva; y
      un salto de línea en el `agent_type` o en el `agent_id` ya no desplaza los campos siguientes: el agente
      se juzga con su valor entero (E5).
  - **Versionado el 2026-10-02 (séptima autorización, `PENDING_APPROVAL.md` § Resueltas, commit `3128d09`;
    write-back de QA-023-13). Casos del retorno de carro de CA-47, puntos 11 a 13, en el bloque R de la sección
    `tests/escenarios/hooks/secciones/44-integridad-de-la-entrada.sh`.** Los puntos 1 a 8 y el versionado del
    2026-10-01 se conservan; éste los amplía así. **No reinicia ningún contador:** el de REQ-023 sigue agotado
    (3 de 3).
    - **Punto 1, fail-before de esta reparación:** contra **`cd6afa6`**, el candidato antes de reparar
      QA-023-13 (su código es el de `9c53232`). Toda fila `allow` en esa columna y `deny` en la del candidato
      tiene que permitir de verdad en `cd6afa6`, o el caso aborta; si `cd6afa6` no se puede materializar, SKIP
      con el motivo, nunca PASS. La columna `9596e39` es, como en el versionado del 2026-10-01, la referencia de
      antes de la reparación y la que cuenta para los movimientos (punto 5). Las filas anteriores de la sección
      44 conservan `43b948a` como su fail-before.
    - **Punto 3, casos mínimos** —mínimos y **no exhaustivos** de la propiedad de CA-47, puntos 11 a 13, para el
      retorno de carro—. `␍` es un retorno de carro dentro del campo; `<fuera>/d␍` es un enlace a la raíz del
      proyecto y `<fuera>/d`, un directorio normal fuera de él. Salvo que la fila diga otra cosa, la escritura es
      la del punto 3 de arriba, y cada fila juzgada por un guardián se ejerce además **por `guard.sh`**. **El
      motivo de cada `deny` del candidato se comprueba por su causa:** el `cwd` con un retorno de carro en R y
      RM, el `file_path` con un retorno de carro en RF y el nombre de la herramienta en RT. La columna «Host» usa
      el vocabulario del punto 3 de arriba.

      | # | Caso | Host | Candidato | `cd6afa6` | `9596e39` |
      |---|---|---|---|---|---|
      | R1 | `echo x > src/a.ts` de la coordinadora desde `<fuera>/d␍` (QA-023-13), por `guard-codigo` | por `Bash`, sin medir: no ejercido en el host | deny, motivo del `cwd` con retorno de carro | allow | deny |
      | R2 | `sed -i` que cierra un REQ en rojo desde `<fuera>/d␍`, por `guard-completado` | ídem | deny, ídem | allow | deny |
      | R3 | `Edit` con ruta relativa que cierra un REQ en rojo desde `<fuera>/d␍` | inyectada (como D4), sin medir | deny, ídem | allow | deny |
      | R4 | el retorno de carro en medio: `echo x > src/a.ts` desde `<fuera>/e␍f` | por `Bash`, sin medir | deny, ídem | deny, con otro motivo | deny |
      | R5 | el retorno de carro antes de un salto: `echo x > src/a.ts` desde `<fuera>/g␍␊h` | ídem | deny, ídem | allow | deny |
      | RC | con el mismo `cwd` `<fuera>/d␍`: lo que no depende de él —(a) `Write` absoluto a `<raíz>/docs/n.md`; (b) cierre absoluto de un REQ en verde; (c) `ls -la`; (d) `Write` absoluto de la coordinadora a `<raíz>/src/a.ts`; (e) cierre absoluto de un REQ en rojo—, y (f) el `desarrollador` escribe `src/a.ts` por `Bash`, relativa: no determinable, que el agente de código puede escribir si el comando no menciona el estado terminal (punto 7) | — | (a) (b) (c) (f) allow · (d) (e) deny | igual | igual |
      | RM1 | `echo x > n.md` de la coordinadora desde `<fuera>/d␍`: relativa y fuera del ámbito | por `Bash`, sin medir | deny, motivo del `cwd` con retorno de carro | allow | allow |
      | RS | sin retorno de carro: (a) `echo x > src/a.ts` y (b) el `sed -i` de R2, desde `<raíz>`; (c) `echo x > src/a.ts` desde `<fuera>/d` (designa `<fuera>/d/src/a.ts`: instancia de L8) | — | (a) (b) deny · (c) allow | (a) (b) deny · (c) allow | (a) (b) deny · (c) deny |
      | RF | `file_path` con retorno de carro (punto 12): (1) la coordinadora escribe `<raíz>/docs/l␍`, un enlace dentro de la raíz hacia `src/a.ts`; (2) un `Edit` que cierra `<raíz>/requirements/REQ-901.md␍`, en rojo, con `REQ-901.md` en verde; (3) la coordinadora escribe `<raíz>/docs/n.md␍`, fuera del ámbito; (4) un `file_path` que sólo es un retorno de carro | sin medir | deny, motivo de no determinable (retorno de carro) | allow | allow |
      | RT | `tool_name` con retorno de carro (punto 13): (1) `Bash␍` de la coordinadora con `ls` y un `file_path` en `<raíz>/src/a.ts`; (2) `Edit␍` que cierra un REQ en rojo; (3) `Write␍` del `desarrollador` a `src/a.ts`, que `guard-completado` deniega a todo agente | sin medir | deny, motivo del punto 13 (retorno de carro) | allow | allow |
      | RT4 | `Bash␍` de la coordinadora con `echo x > src/a.ts` | sin medir | deny, motivo del punto 13 | deny, con otro motivo | deny |
      | P2 | el análisis de la entrada con un retorno de carro final en el `tool_name`, el `cwd` y el `file_path` (sobre la biblioteca) | — | lo cuenta: `cwd` vacío y marcado, y el retorno de carro final del `tool_name` y del `file_path` presente | lo recorta | — |

      Además, un caso comprueba que los motivos del retorno de carro dicen su causa y cómo corregirla, y no
      nombran ninguna herramienta como salida.

      **Recuentos.** La sección 44 pasa de **167 a 247 casos**: 23 filas, cada una en el candidato, contra
      `cd6afa6` y contra `9596e39`; por `guard.sh` las 8 que juzga un guardián; el caso de los motivos; y P2 en el
      candidato y en `cd6afa6`. `CASOS_ESPERADOS`, de **1501 a 1581**. **Medido por el desarrollador**
      (Linux/WSL2; rama local `evidencia/prueba-despacho-2026-09-14`, `cand-1.35.0/evidencia-dev-r7/`, commit
      `8959544`): sección 44, 247 PASS (`05-`); la misma sección con los hooks de `cd6afa6` en lugar de los del
      candidato, 24 FAIL, todos del bloque R (`06-`); banco completo, **1570 PASS, 0 FAIL, 11 SKIP**, cuadre
      1581 (`16-`).
    - **Punto 4, adaptación:** ninguna fila existente cambia de nombre ni de veredicto. Las 167 anteriores de la
      sección 44 pasan con los hooks reparados y la sección sin editar (`evidencia-dev-r7/04-`), y ninguna otra
      sección cambia de expectativa.
    - **Punto 6, validación en el host:**
      - **El caso del retorno de carro no se ejecutó en el host en esta vuelta.** A la fecha de este
        versionado, la evidencia de QA-023-13 y de su reparación es **sólo a nivel de hook**: ninguna fila de
        este versionado se presenta como validación en el host, y cada una queda **no comprobada** en el host,
        nunca PASS (punto 6 de arriba). Desde el host, QA-023-13 es alcanzable y no está medido (QA-023-13).
      - **Lo que sí se hizo en el host, para el salto de línea y no para el retorno de carro:** el caso r6
        —un `cwd` con un salto de línea literal, con los hooks de `cd6afa6`—, que el versionado del 2026-10-01
        dejaba pendiente; QA lo verificó contra sus crudos (`docs/qa/REQ-023.md` § «Vuelta excepcional de la
        sexta autorización», §2; rama de evidencia, `3eb279d`). No se extiende al retorno de carro.
      - Nada de esto se extiende a Windows/MSYS, a `MultiEdit`, al editor interactivo ni a otras versiones del
        CLI.
    - **Punto 7, compatibilidad, además:** una ruta relativa cuyo `cwd` lleva un retorno de carro se deniega con
      motivo —también fuera de las zonas protegidas—, y la salida es la ruta absoluta o un directorio cuyo nombre
      no lo lleve; un `Edit`, `Write` o `MultiEdit` cuyo `file_path` lleva un retorno de carro, y una entrada
      cuyo `tool_name` lo lleva, se deniegan como con un salto de línea.
  - **Versionado el 2026-10-02 (octava autorización, `PENDING_APPROVAL.md` § Resueltas, «RESUELTA (propietario,
    2026-10-02, octava autorización)», commit `01b4a59`, puntos 2, 4 y 5; write-back de SEC-122, QA-023-14 y
    QA-023-15 / P-023-13-A). Casos de CA-47 (F3 y puntos 11 y 14 a 17) y de CA-49 en la sección
    `tests/escenarios/hooks/secciones/45-dependencia-del-proceso-y-cr-del-comando.sh`.** Los puntos 1 a 8 y los
    versionados del 2026-10-01 y del 2026-10-02 (séptima autorización) se conservan; éste los amplía así. **No
    reinicia ningún contador:** el de REQ-023 sigue agotado (3 de 3); es la intervención excepcional agrupada que
    autoriza el propietario. *(Puesto al día tras la **pasada correctiva** que la misma autorización prevé
    —código en `befc17a`, evidencia `evidencia-dev-r8b/`, commit `8b497c8`—, que repara QA-023-16, QA-023-17
    (= P-122-A (2)) y P-122-A (1): bloque C de la sección, recuentos, movimientos y compatibilidad; Historial.)*
    - **Punto 1, fail-before de esta reparación:** contra **`3bc7d3c`**, el código del candidato antes de la
      octava autorización (`01b4a59:hooks`); **el bloque C, contra `9220c71`**, el código antes de la pasada
      correctiva. Toda fila `allow` en esa columna y `deny` en la del candidato tiene que permitir de verdad en su
      árbol de fail-before, o el caso aborta; si ese árbol no se puede materializar, SKIP con el motivo, nunca PASS.
      La columna `9596e39` es la referencia de los movimientos (punto 5). **La sección no trae
      columna de 1.33.2:** los movimientos frente a 1.33.2 se apoyan en las baterías del desarrollador, fuera del
      banco (`evidencia-dev-r8/01-`, `02-` y `07-`), donde 1.33.2 decide en todas las filas igual que `9596e39`.
    - **Punto 3, casos mínimos** —mínimos y **no exhaustivos** de la propiedad—. `<shm>` es un directorio bajo
      `/dev/shm`, donde cualquier usuario puede crear un enlace; `<fuera>/pc` es un enlace a `/proc/self/cwd`;
      `docs/k␍` y `docs/r␍` son enlaces cuyo nombre acaba en un retorno de carro, hacia `src/a.ts` y hacia un REQ
      en rojo; los globs son `src/*` y `app/*.ts`. Salvo que la fila diga otra cosa, la escritura es la del punto 3
      de arriba, y cada fila juzgada por un guardián se ejerce además **por `guard.sh`**. El motivo de un `deny`
      del candidato se comprueba por su causa donde la fila la cita. Las filas que dependen de `/dev/shm` o de
      `/proc` se miden **sólo en Linux** y fuera salen SKIP con el motivo; las que necesitan un enlace con un
      retorno de carro en el nombre, también si no se puede crear. La columna «Host» usa el vocabulario del punto 3
      de arriba: **ninguna fila se ejerció desde el host**.

      | # | Caso | Host | Candidato | `3bc7d3c` | `9596e39` |
      |---|---|---|---|---|---|
      | S1–S5 | SEC-122, cara (a), un enlace corriente bajo `/dev/shm`: `Edit` que cierra un REQ en rojo por `<shm>/req/REQ-900.md` (`req` → `requirements`); `Write` de la coordinadora por `<shm>/src/a.ts`; `sed -i` que cierra por el enlace; `echo x >` un enlace de archivo bajo `/dev/shm` hacia `src/a.ts`; la edición no reconstruible de SEC-117 por el enlace | sin medir | deny | allow | allow |
      | S6 | control: el `desarrollador`, `echo x > <shm>/src/a.ts` | — | allow | allow | allow |
      | P1 | `echo x > /proc/self/cwd/src/a.ts` de la coordinadora con el `cwd` en la raíz (el shell escribe `src/a.ts`) | por `Bash`, sin medir | deny | allow | allow |
      | P2 | lo mismo con el `cwd` en `<raíz>/docs` (designa `docs/src/a.ts`) | — | allow | allow | allow |
      | P3 | `Write /proc/self/cwd/src/a.ts` de la coordinadora (escribe el host, cuyo directorio no se conoce) | sin medir | deny, «depende del proceso que la abre» | allow | allow |
      | P4 | `Edit` que cierra en rojo por `/proc/self/root` seguido de `<raíz>/requirements/REQ-900.md` | sin medir | deny | allow | allow |
      | P5 | `echo x > <fuera>/pc/src/a.ts` con el `cwd` en la raíz | por `Bash`, sin medir | deny | allow | allow |
      | P6 | `echo x > /dev/fd/9/a.ts` (una ruta detrás de un descriptor) | por `Bash`, sin medir | deny, ídem | allow | allow |
      | P7 | `echo x > /proc/self/cwd/src/a.ts` sin `cwd` en la entrada | por `Bash`, sin medir | deny, ídem | allow | allow |
      | P8 | control: el `desarrollador`, `echo x > /proc/self/cwd/src/a.ts` | — | allow | allow | allow |
      | P9 | `Write /dev/stderr` de la coordinadora (un descriptor del proceso del host) | sin medir | deny, ídem | allow | allow |
      | N1–N6 | lo legítimo bajo `/dev`, de la coordinadora: `ls -la > /dev/null 2>&1`, `echo hola > /dev/stderr`, `> /dev/stdout`, `> /dev/fd/2`, `echo hola \| tee /dev/stderr`, `Write /dev/null` | — | allow | allow | allow |
      | K1–K4 | el retorno de carro del texto del comando, de la coordinadora: `printf x > k␍` y `printf x > k␍␊true` desde `docs`; un `sed -i` que cierra por `docs/r␍`; `echo x \| tee docs/k␍` | por `Bash`, sin medir | deny | allow | allow |
      | K5 | `printf x > docs/n.md␍` (el shell escribe `docs/n.md␍`, fuera del ámbito) | — | allow | allow | allow |
      | K6 | `printf x > app/a.ts␍` con `app/*.ts` (el shell escribe `app/a.ts␍`, que el patrón no cubre) | por `Bash`, sin medir | allow | deny | deny |
      | K7 | control: `printf x > app/a.ts` | — | deny | deny | deny |
      | K8 | `echo hola␍␊ls␍␊`, un comando CRLF sin escrituras | — | allow | allow | allow |
      | H1 | heredoc CRLF citado y después `echo x > src/a.ts` | por `Bash`, sin medir | deny, «delimitador contiene un retorno de carro» | deny, con otro motivo | deny |
      | H2 | heredoc CRLF citado hacia `docs/x.md` (legítimo), de la coordinadora | por `Bash`, sin medir | deny, ídem | allow | allow |
      | H3 | delimitador que empieza por un retorno de carro, comillas en el cuerpo y detrás `echo x > 'src/a.ts'`, que el shell ejecuta | por `Bash`, sin medir | deny, ídem | allow | allow |
      | H4 | heredoc con un retorno de carro sólo en el cuerpo (delimitador limpio) | — | allow | allow | allow |
      | H5 | el `desarrollador`, H2 sólo por `guard-codigo` | — | allow | allow | allow |
      | H6 | el `desarrollador`, H2 por `guard-completado` | por `Bash`, sin medir | deny, ídem | allow | allow |
      | G2 | control: `git reset --hard` | — | deny | deny | deny |
      | G3 | `git reset --hard ␍` (el retorno de carro es otro argumento) | — | deny | deny | deny |
      | B1–B2 | SEC-122, cara (b), un proyecto situado bajo `/dev/shm`: `Edit` que cierra por `docs/enlace.md` (→ un REQ); `Write` de la coordinadora por `docs/a-enlace.ts` (→ `src/a.ts`) | sin medir | deny, el motivo de CA-49 (i) | allow | deny |
      | B3 | el mismo proyecto: `Edit` literal sin estado sobre un REQ que existe | — | allow | deny | allow |
      | B4 | el mismo proyecto: `echo x > docs/dsrc/a.ts` (directorio enlazado) | por `Bash`, sin medir | deny | allow | allow |
      | B5 | el mismo proyecto: cierre en verde de un REQ | — | allow | deny | allow |
      | Q1 | la lectura de la entrada conserva el retorno de carro final y el que precede a un salto en el `tool_name`, el `file_path` y el `command` (sobre la biblioteca) | — | conserva | los pierde | — |
      | Q2–Q3 | con un `jq` que añade un retorno de carro a cada línea —emulación del de Windows, no Windows—, los valores llegan iguales; y, sin retorno de carro en el dato, no queda ninguno | — | iguales, ninguno | — | — |

      **Bloque C, pasada correctiva** (fail-before contra `9220c71`; la fila G1 de antes es ahora C1). El motivo de
      los `deny` de C1 a C7 se comprueba por su causa: la orden «lleva un retorno de carro pegado a sus palabras».

      | # | Caso | Host | Candidato | `9220c71` | `9596e39` |
      |---|---|---|---|---|---|
      | C1 | `git reset --hard␍` (era G1) | por `Bash`, sin medir | deny | allow | deny |
      | C2 | `git stash␍` (P-122-A (1): con `help.autocorrect`, git lo corrige y lo ejecuta) | por `Bash`, sin medir | deny | allow | deny |
      | C3–C6 | `git checkout .␍`, `git checkout -- .␍`, `git restore .␍`, `git checkout HEAD .␍` (QA-023-16) | por `Bash`, sin medir | deny | allow | deny |
      | C7 | `git clean␍ -f`, un retorno de carro **en medio** de la orden | por `Bash`, sin medir | deny | allow | allow |
      | C8–C9 | controles: `git status␍`, que no está en la lista, y `git stash list␍`, una lectura | — | allow | allow | allow |
      | C10 | `echo x > src/log` de la coordinadora, con `src/log` → `/dev/stderr` (QA-023-17, era P-122-A (2)) | por `Bash`, sin medir | deny | allow | deny |
      | C11 | `sed -i` con el estado terminal por `requirements/log` → `/dev/stderr` (QA-023-17) | por `Bash`, sin medir | deny | allow | deny |
      | C12 | control: el `desarrollador`, `echo x > src/log` | — | allow | allow | allow |
      | C13 | control: `echo x > docs/err` → `/dev/stderr`, fuera del ámbito | — | allow | allow | allow |

      **Recuentos.** La sección 45 trae **206 casos**: 55 filas —las 42 de la primera tabla y las 13 del bloque C—,
      cada una en el candidato, contra su árbol de fail-before y contra `9596e39`; por `guard.sh`, en el candidato,
      las 37 que juzga un guardián distinto de `guard.sh` (H5 se mide sólo por `guard-codigo`); Q1 en el candidato y
      en `3bc7d3c`; y Q2 y Q3 en el candidato. `CASOS_ESPERADOS`, de **1581 a 1741** con la reparación central y de
      **1741 a 1787** con la pasada correctiva (+50 del bloque C, −4 de G1, que pasa a ser C1).
      - **Medido por el desarrollador sobre la reparación central** (Linux/WSL2; rama local
        `evidencia/prueba-despacho-2026-09-14`, `cand-1.35.0/evidencia-dev-r8/`, commit `e0f006d`; código en
        `9220c71`): sección 45, 160 PASS y 0 FAIL (`04-seccion45-v3.txt`; las corridas v1 y v2 se conservan,
        marcadas como de instrumento defectuoso); la misma sección con los hooks de `3bc7d3c`, 52 FAIL (`05-`);
        banco completo, 1730 PASS, 0 FAIL, 11 SKIP, cuadre 1741 (`06-`); autoprueba 117/0 (`09-`).
      - **Medido por el desarrollador sobre la pasada correctiva** (Linux/WSL2; misma rama,
        `cand-1.35.0/evidencia-dev-r8b/`, commit `8b497c8`; código en `befc17a`): sección 45, **206 PASS, 0 FAIL**
        (`03-`); la misma sección con los hooks de `9220c71`, **18 FAIL, todos del bloque C** —C1 a C7, C10 y C11,
        en el candidato y por `guard.sh`— (`04-`); secciones 41 a 45, 806/0 (`05-`); banco completo, **1775 PASS,
        0 FAIL, 12 SKIP**, con 1 INCONCLUSO de rendimiento ajeno al delta (REQ-017 CA-08 (ii)), cuadre 1787 (`06-`);
        autoprueba 117/0 y las tres quality gates, `bash -n` incluida (`07-`).
    - **Punto 4, adaptación:** ninguna fila de otra sección cambia de nombre ni de veredicto. Bajo `tests/` la
      reparación central sólo añade la sección 45 y cambia el total de `run.sh` y el README del banco
      (`evidencia-dev-r8/08-…patch`), y la pasada correctiva sólo toca esos mismos tres archivos
      (`evidencia-dev-r8b/08-…patch`). **Dentro de la sección 45, una fila cambia de veredicto, y se justifica:**
      G1 (`git reset --hard␍`, que la reparación central había declarado de `deny` a `allow`) sale del bloque G y
      pasa al bloque C como C1, en `deny` y con su fail-before contra `9220c71`, porque la pasada correctiva juzga
      también sin el retorno de carro toda orden de git (CA-47, punto 11). Su cobertura se conserva: G2 y G3
      siguen en el bloque G como controles. El banco completo sale en verde.
    - **Punto 6, validación en el host y plataformas:**
      - **Ninguna fila de este versionado se ejerció desde el host.** La evidencia de lo construido en `9220c71`
        y en `befc17a` es **sólo a nivel de hook, en Linux/WSL2**, y cada fila queda **no comprobada** en el host,
        nunca PASS. Lo que hace git con `stash␍` con y sin `help.autocorrect` lo midieron QA y el desarrollador
        ejecutando git aparte (`evidencia-dev-r8b/01-`), no a través del host. Se
        distinguen la decisión del hook, el efecto en disco y la conducta del host: lo que escribe el shell
        —`printf x > k␍`, las formas bajo `/dev/shm` y `/proc`— y lo que hace git con `--hard␍` y `stash␍` lo
        midió el desarrollador ejecutando el shell y git aparte, no a través del host.
      - **Plataformas, con el texto que autoriza el propietario** (octava autorización, punto 5), **limitado a los
        casos realmente ejecutados** en la frontera de 1.35.0:
        - hook en Linux/WSL2;
        - CLI 2.1.285 en WSL2 mediante `claude -p`;
        - hook en Windows/MSYS, en una máquina;
        - sin comprobación de la extensión de VS Code, del CLI en Windows ni de otros clientes.

        Esto describe dónde se ejecutaron los casos; **no acredita toda la plataforma ni todos sus
        comportamientos**. A lo construido en `9220c71` sólo le aplica la primera línea: el CLI en WSL2 se ejerció
        en versionados anteriores (el punto 6 de arriba y el de los versionados del 2026-10-01 y del 2026-10-02,
        séptima autorización), y el hook en Windows/MSYS sólo para la
        medición de latencia de CA-54 (`sec-ca54-win/`, `c51c5c7`). La reparación agrupada tampoco garantiza por
        sí sola que el candidato quede publicable: CA-54, SEC-115 y SEC-118, el hueco C y las fronteras restantes
        conservan sus decisiones pendientes.
    - **Punto 7, compatibilidad, además** (ejemplos **no exhaustivos**): pasan a denegarse una escritura a una zona
      protegida a través de un enlace o de un alias bajo `/dev/` o `/proc/`, y, en un proyecto situado bajo
      `/dev/`, todo lo que en otro directorio ya se denegaba; por `Edit`, `Write` o `MultiEdit`, toda ruta que
      depende del proceso del host —`/dev/stderr`, `/proc/self/cwd/…`— **a todo agente**; por `Bash`, una ruta
      detrás de un descriptor, un pseudoarchivo del proceso o `/proc/self/cwd/…` sin un `cwd` que ancle, a quien no
      es el agente de código; un destino de `Bash` cuyo nombre acaba en un retorno de carro, que se juzga con él; y
      un heredoc cuyo delimitador lleva un retorno de carro —por ejemplo, el de un script con fines de línea
      CRLF—, **a todo agente** por `guard-completado`, con la salida de escribir el comando con líneas acabadas
      sólo en salto de línea; y, desde la pasada correctiva, toda orden de git que sin sus retornos de carro está
      prohibida —también con el retorno de carro en medio, `git clean␍ -f`, que lo publicado permitía—, con la
      misma salida. Pasa a permitirse la clase de K6. *(Antes: «Pasan a permitirse K6 y G1 y, sin declarar,
      `git stash␍` y —por lectura del código, sin medir— el enlace hacia un descriptor de P-122-A».)* *(Anotado el
      2026-10-03, novena autorización, fase 2: sobre `befc17a` pasaba además, sin declarar, la forma de SEC-124
      —R-047 §3—; su vuelta a `deny`, la reparación de SEC-125 y la clase que ésta añade están en el punto 7 del
      versionado de la fase 2, abajo: construido en `10ac6c4` y `36a0d27`; validado por el propietario por vía
      manual (`docs/qa/REQ-023.md`, CI run 37163342218); sin firma del qa-tester ni del auditor-seguridad por
      impedimento del proveedor. Antes: «**pendientes de implementación y de validación**».)*
  - **Versionado el 2026-10-03 (novena autorización, fase 2, `PENDING_APPROVAL.md` § Resueltas, «RESUELTA
    (propietario, 2026-10-03, novena autorización)», «Fase 2 — SEC-124 y SEC-125»; write-back de SEC-124 y
    SEC-125, `docs/seguridad/registro-seguridad.md` § R-047, §3 y §4). Casos de CA-47, puntos 18 y 19.**
    **Estado: construido en `10ac6c4` y `36a0d27`; validado por el propietario por vía manual
    (`docs/qa/REQ-023.md`, CI run 37163342218); sin firma del qa-tester ni del auditor-seguridad por impedimento
    del proveedor.** *(Antes: «PENDIENTE DE IMPLEMENTACIÓN Y DE VALIDACIÓN». Historial, 2026-10-03, write-back de
    estado.)* Los puntos 1 a 8 y los versionados anteriores se conservan; éste los
    amplía así. **No reinicia ningún contador:** el de REQ-023 sigue agotado (3 de 3); es la novena intervención
    excepcional, con como mucho una pasada correctiva en esta fase (aclaración del propietario en esa misma
    entrada de `PENDING_APPROVAL.md`).
    - **Dónde:** en la sección 45, que el propietario nombra como sede, o en otra que el desarrollador declare en
      el Historial. Un archivo nuevo del banco exige además añadirlo a `Archivos:`, que es campo de cabecera y
      queda fuera de este write-back: lo resuelve la coordinadora antes de despachar.
    - **Punto 1, fail-before:** contra **`3f96e6b`** (el código de `befc17a`, el candidato antes de esta fase).
      Toda fila `allow` en esa columna y `deny` en la del candidato tiene que permitir de verdad en `3f96e6b`, o el
      caso aborta; si el árbol no se puede materializar, SKIP con el motivo, nunca PASS. Las columnas `9596e39` y
      `v1.33.2` son la referencia de los movimientos (punto 5); la de `v1.33.2` puede salir de una batería fuera
      del banco, como en la octava autorización, si se declara así.
    - **Punto 2, controles:** las filas con el mismo veredicto en todas las columnas deciden igual en todos los
      árboles.
    - **Punto 3, casos mínimos** —mínimos y **no exhaustivos** de la propiedad de CA-47, puntos 18 y 19—. Se
      construyen **reutilizando** la evidencia de R-047 (`cand-1.35.0/evidencia-seg-r8/`, rama local
      `evidencia/prueba-despacho-2026-09-14`, `t3`, `t4`, `t5`, `t5b` y `t9`) por copia o por referencia, sin
      catálogos nuevos de variantes; este criterio cita los casos por su identificador y **no** copia su comando.
      Salvo que la fila diga otra cosa, emite la coordinadora con `codigo_app.globs: ["src/*"]`, y cada fila se
      ejerce por el guardián que la decide **y por `guard.sh`**; las de LC10, por las cuatro puertas. El motivo de
      un `deny` de las filas HC1 a HC6 se comprueba por su causa y por el identificador `SEC-124`, y el de las
      filas LC10.1 a LC10.9, por su causa y por los identificadores `SEC-125` y `LC10` (CA-47, punto 19,
      «Excepción nombrada»). La columna «Host» usa el vocabulario del punto 3 de arriba.

      | # | Caso | Host | Candidato | `3f96e6b` | `9596e39` | `v1.33.2` |
      |---|---|---|---|---|---|---|
      | HC1–HC4 | SEC-124, los casos de R-047 §3 —`t3` H2 y `t4` E1, E2 (`<<-` con tabulador) y E9 (delimitador citado)—: la línea del cuerpo que es el delimitador seguido de un retorno de carro, y detrás una escritura en código protegido | por `Bash`, sin medir | deny, `SEC-124` | allow | deny | deny |
      | HC5 | SEC-124, la forma de HC1 emitida por el `desarrollador` (restricción aceptada) | — | deny, ídem, por `guard-completado` y por `guard.sh`; `guard-codigo` sólo, allow | allow | allow | allow |
      | HC6 | SEC-124, la forma de HC1 con una orden inocua detrás, de la coordinadora (restricción aceptada) | — | deny, ídem | allow | allow | allow |
      | HC7 | control: esa misma línea como última del comando | — | allow | allow | allow | allow |
      | HC8 | control: H4 de la sección 45 (retorno de carro sólo en el cuerpo) y un heredoc ordinario de delimitador citado | — | allow | allow | allow | allow |
      | HC9 | control: H1 a H6 de la sección 45 (delimitador con retorno de carro, punto 17) | — | sus veredictos de hoy, con el motivo del punto 17 | ídem | ídem | ídem |
      | LC1 | SEC-125, R-047 §4, `t5`: las tres formas de redirección con la continuación entre el operador y un destino en código protegido | por `Bash`, sin medir | deny | allow | allow | allow |
      | LC2 | SEC-125, R-047 §4, `t5b`: la escritura que cierra un REQ con la continuación delante del destino (`guard-completado`) | por `Bash`, sin medir | deny | allow | allow | allow |
      | LC3 | control, R-047 §4: la continuación delante del operador, y en `cp`, `tee` y `sed -i` | — | deny | deny | deny | deny |
      | LC4 | control: el `desarrollador`, la forma de LC1 | — | allow | allow | allow | allow |
      | LC5 | control: la forma de LC1 hacia un destino fuera de todo ámbito (`docs/`) | — | allow | allow | allow | allow |
      | LC6 | control: una orden sin escrituras partida en dos líneas por una continuación | — | allow | allow | allow | allow |
      | LC7 | control, donde el shell no une: la barra seguida de un espacio, la barra escapada y la barra seguida de un retorno de carro, delante del salto; y la continuación dentro de comillas simples —en todos, la línea siguiente nombra código protegido sin que el shell escriba en él— | — | allow | allow | allow | allow |
      | LC8 | la clase de SEC-125 (punto 5): el fragmento anterior a la continuación casa con el ámbito y, unido, el destino está fuera | — | allow | deny | deny | deny |
      | LC9 | control, R-047 §4: la continuación dentro de un destino que queda en el ámbito unido o sin unir | — | deny | deny | deny | deny |
      | LC10 | SEC-125 y la frontera del heredoc (caso (b), añadido el 2026-10-03 por autorización del propietario; **decidido por él con la opción (A) de P-LC10-A**): la continuación de línea al **final de la línea que abre** un heredoc de delimitador limpio (sin retorno de carro; con él rige el punto 17). Para el shell la orden sigue en la línea siguiente y el cuerpo empieza **después** de ella; para el analizador de `3f96e6b` (`arnes_bash_sin_texto`, bucle de heredocs) empieza **en** ella. Las dos lecturas las midió QA (`docs/qa/REQ-023.md`, «medición de LC10», «Las dos lecturas que el analista marcaba sin medir»: shell aparte y el analizador vigente). Regla: CA-47, punto 19, «Excepción nombrada». Por propiedad y sin comandos; las subformas LC10.1 a LC10.9 son las de esa medición, citadas por su nombre; cada una se ejerce por `guard-codigo`, `guard-completado`, `guard-git` y `guard.sh`, y QA puede romper la regla con casos propios | por `Bash`, sin medir | **deny en las cuatro puertas, a todo agente y sea cual sea lo que siga**, con el motivo de la excepción (`SEC-125` y `LC10`, causa y salida); el desglose, en LC10.1 a LC10.9 | por subforma, abajo | por subforma, abajo | por subforma, abajo |
      | LC10.1 | subforma «Ya fijado (a)»: continuación entre la escritura y su destino, destino en código protegido, coordinadora | por `Bash`, sin medir | deny en las cuatro, motivo `SEC-125` · `LC10` | allow en las cuatro | allow en las cuatro | allow en las cuatro |
      | LC10.2 | subforma «Ya fijado (b)»: ídem, destino en un REQ y el estado terminal en el cuerpo, coordinadora | por `Bash`, sin medir | deny en las cuatro, ídem | allow en las cuatro | allow en las cuatro | allow en las cuatro |
      | LC10.3 | subforma «Ya fijado (b)», emitida por el `desarrollador` | por `Bash`, sin medir | deny en las cuatro, ídem | allow en las cuatro | allow en las cuatro | allow en las cuatro |
      | LC10.4 | subforma «el `desarrollador`, la forma de (a)» (restricción aceptada) | — | deny en las cuatro, ídem | allow en las cuatro | allow en las cuatro | allow en las cuatro |
      | LC10.5 | subforma «lo inocuo»: una tubería a una orden que no escribe, coordinadora (restricción aceptada) | — | deny en las cuatro, ídem | allow en las cuatro | allow en las cuatro | allow en las cuatro |
      | LC10.6 | subforma «destino fuera del ámbito» (`docs/`), coordinadora (restricción aceptada) | — | deny en las cuatro, ídem | allow en las cuatro | allow en las cuatro | allow en las cuatro |
      | LC10.7 | subforma «orden de git prohibida en la línea siguiente», coordinadora (QA-023-23, cara de git) | por `Bash`, sin medir | deny en las cuatro, ídem | allow en las cuatro | allow en las cuatro | allow en las cuatro |
      | LC10.8 | subforma «la línea siguiente cierra el heredoc para el analizador, y detrás una escritura en código protegido», coordinadora (el falso positivo de hoy, cubierto por la misma denegación) | — | deny en las cuatro, ídem —también en `guard-codigo` y `guard.sh`, con este motivo y no con el de la regla de escrituras— | deny en `guard-codigo` y `guard.sh` (motivo de `guard-codigo`); allow en `guard-completado` y `guard-git` | ídem que `3f96e6b` | ídem que `3f96e6b` |
      | LC10.9 | subforma «la continuación en otra posición de esa línea —delante del operador, con el operador y el destino en la línea siguiente—», destino en código protegido, coordinadora (QA-023-23, cara de escritura) | por `Bash`, sin medir | deny en las cuatro, ídem | allow en las cuatro | allow en las cuatro | allow en las cuatro |
      | LC10.c1 | control: las subformas «Control» de la misma medición —«(a) en una línea», «(b) en una línea» y «la orden de git de la fila 7 en la línea que abre»—: la misma orden sin la continuación | — | sus veredictos de hoy: (a) deny en `guard-codigo` y `guard.sh`; (b) deny en `guard-completado` y `guard.sh`; git, deny en `guard-git` y `guard.sh`; las demás puertas, allow | ídem | ídem | ídem |
      | LC10.c2 | control de la frontera de la excepción: la línea que abre un heredoc acaba en una barra que el shell **no** trata como continuación (CA-47, punto 19, «la puerta tampoco»): no es la forma de LC10 | — | la decisión de `3f96e6b`, sin el motivo de LC10 | la de ese árbol (sin medir) | la de ese árbol (sin medir) | la de ese árbol (sin medir) |

      **La columna «Candidato» es el contrato** y no se ajusta a lo que se mida. **Las columnas de los árboles
      anteriores que R-047 no midió** —las de HC5 a HC9 y de LC4 a LC9— son la lectura del analista sobre lo
      publicado: el desarrollador las mide, y si un árbol anterior decide distinto lo declara, y la descripción del
      movimiento (punto 5) se corrige con su fila en el Historial, porque es un dato sobre lo publicado y no una
      promesa. Las filas LC7 y LC8 se construyen por propiedad, y QA las rompe con casos propios. **Las columnas
      de LC10.1 a LC10.9 y LC10.c1 no son lectura del analista:** salen de la medición de QA sobre `c4ad408`
      (código de hooks = `befc17a`, el de `3f96e6b`; hook directo por puerta en los tres árboles y efecto en disco
      con un shell aparte, Linux/WSL2; `docs/qa/REQ-023.md`, «medición de LC10»), que sigue vigente como
      fail-before; la de LC10.c2, sí lo es, sin medir.
    - **Punto 4, adaptación (P3 de la autorización):** **ninguna fila existente del banco cambia de decisión ni de
      nombre**; los únicos cambios de expectativa son las filas nuevas y el total de casos esperados. Una fila
      existente que cambie es un hallazgo de esta fase.
    - **Punto 6, validación por capa y plataformas** (P5 y P10 de la autorización). Se registran **por separado**
      la decisión del hook, el efecto en disco y la conducta del host:
      - **a nivel de hook**, Linux/WSL2 —banco y batería—: obligatorio;
      - **shell aparte**, en árboles desechables: que el shell escribe el destino de LC1 y LC2 y el de LC8, y que
        no escribe en código protegido en HC1 a HC6 ni en LC7. Lo ya medido en R-047 §3 y §4 se reutiliza citado,
        no se repite sin necesidad; y también lo de LC10, que QA midió sobre `c4ad408` (`docs/qa/REQ-023.md`,
        «medición de LC10», columna «Efecto en disco»);
      - **CLI real** (`claude -p` en WSL2), **si está disponible**: lo ejecuta la coordinadora, con registro previo
        y una ejecución por caso; si no se ejecuta, cada fila queda **no comprobada en el host**, nunca PASS. Una
        prueba a nivel de hook no se presenta como validación en el host;
      - **extensión de VS Code: no** en esta fase (la comprobación del propietario va aparte);
      - **Windows/MSYS: no medido para este delta**, y no se le atribuye cobertura. Una emulación del transporte
        en Linux, si se hace, se declara emulación (como `t9` de R-047).
    - **Punto 7, compatibilidad, además** (ejemplos **no exhaustivos**): pasa a denegarse, a todo agente, un
      heredoc de delimitador limpio cuyo cuerpo tiene, antes de su última línea, una línea que es su delimitador
      seguido de un retorno de carro, con la salida de escribir el comando con líneas acabadas sólo en salto de
      línea; y una escritura cuyo destino va tras una continuación de línea se juzga por el destino que escribe el
      shell. Pasa a permitirse la clase de SEC-125. La forma de SEC-124 **deja** de permitirse. Y pasa a
      denegarse, **a todo agente y en las cuatro puertas**, un comando de `Bash` en el que la línea que abre un
      heredoc de delimitador limpio acaba en una continuación de línea, sea cual sea lo que siga —también lo
      inocuo, lo de fuera de todo ámbito y lo que emite el `desarrollador`—, con la salida de escribir esa línea
      entera, sin la continuación al final (CA-47, punto 19, «Excepción nombrada»; LC10).
    - **Punto 8, sin regresión de lo acreditado** (P8 de la autorización): las secciones 41 a 45 completas en
      verde; los casos de **SEC-047** (sección 41), de **SEC-119** (secciones 43 y 45) y de **SEC-122** (sección
      45, filas S, B, P, N y C) deciden igual que en `3f96e6b`; los de heredocs de REQ-001 (CA-16 a CA-28 y CA-46 a
      CA-53), los del Bloque C y CA-36 a CA-39 de este REQ, y los de la continuación de `guard-git` (REQ-005 CA-40
      y CA-41, sección 29), sin cambio; el banco completo en verde, con `CASOS_ESPERADOS` cuadrado; la autoprueba;
      y las quality gates de `AGENTS.md` §7. Si las dos reparaciones se hacen en serie, la segunda corre la
      regresión de la primera.
    - **Punto 9, coste**, frente a `3f96e6b` y medido **en la misma corrida**, con el estadístico y el suelo de
      `requirements/README.md` § «Cómo se escribe un criterio que no se desmiente», (d):
      - (i) **no más de 0 procesos añadidos** por llamada, con un comando ordinario, con un heredoc y con
        continuaciones (**operativo**: menos es conforme y **no** es hallazgo). Es la magnitud que esconde un
        `fork` en una máquina rápida;
      - (ii) **cociente de duplicación no más de 2,2** (**operativo**) al doblar el número de continuaciones de
        un comando (CA-47, punto 19) y al doblar el número de líneas del cuerpo de un heredoc (punto 18), con los
        dos tamaños por debajo del presupuesto de análisis. Es la magnitud que se degradó en QA-023-14: una
        sustitución global que crece más que linealmente con las apariciones;
      - (iii) el camino común —un comando sin heredoc ni continuación— lo sigue gobernando **CA-59**, con su
        umbral y su línea base, sin cambio por este versionado; QA lo corre en la misma corrida que (i) y (ii).

