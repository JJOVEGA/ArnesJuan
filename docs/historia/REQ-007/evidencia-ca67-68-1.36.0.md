# REQ-007 — historia: CA-67 y CA-68, estado y medición de la construcción (1.36.0)

> **Movido desde `requirements/REQ-007.md` el 2026-10-12** por la undécima autorización del propietario
> (ficha **F-136-17**), cabeza de origen **`cecf9b6`**, líneas **2286–2291, 2295–2297, 2299–2305, 2308–2320, 2325–2333, 3068–3096, 3116–3122 y 3132–3138** (81 líneas, 8367 bytes medidos).
> **Copia verbatim: no se resumió, no se reordenó y no se corrigió nada.**
> Índice: `docs/historia/REQ-007/README.md`. Contrato: `docs/arnes/v1.37.0-f136-17-fase1.md`.
> Comprobación de que no se perdió ninguna línea: ese contrato, §5, y el índice.

    - **Técnica elegida (P-136-B: es del desarrollador): las dos.** `arnes_deny` y `arnes_emitir_avisos`
      (`hooks/lib.sh`) pasan el motivo a `jq` por la **entrada estándar**, con un here-string y sin procesos nuevos:
      ningún dato variable cruza la línea de órdenes. Y lo **acotan** con `arnes_acota` (`hooks/lib.sh:394`), que
      cuenta y corta en bytes, conserva el comienzo, añade dentro del mismo tope la nota «[...] (ARNES: motivo
      acortado: medía N bytes y el tope es 16384; se conserva su comienzo)» y retira la secuencia UTF-8 que el corte
      deja partida: ningún carácter de 2, 3 o 4 bytes sale a medias.
    - *(Punteros de línea de `hooks/lib.sh` de esta viñeta, leídos en el código de `8e11f87`. Antes: `:385` y `:380`,
      los de `0efd3c2`; la reparación de QA-007-07 —su comentario y una línea de código, `hooks/lib.sh:125-132`—
      los desplazó 9 líneas. Historial, 2026-10-06, write-back de estado del QA del paso 6.)*
    - **Medido por el desarrollador.** Tope (`20-tope.sh`, árbol final, `81-`): **273 casos, 0 MAL**. En la
      librería, motivos de tope−1, tope, tope+1 a tope+4, 2×tope y 300 000 bytes, con contenido ASCII y de 2, 3 y
      4 bytes y un desfase de 0 a 3 bytes para que el corte caiga en cada byte de un carácter; en el hook, los 17
      vectores D y A, con motivos emitidos de 16 381 a 16 384 bytes. En todos: no más del tope, `jq` lo relee,
      `iconv` lo acepta como UTF-8, conserva el comienzo y lleva la nota si y sólo si el original pasaba del tope.
      Sección 47 (`47-decision-emitida.sh`): D, 9 casos y 2 controles, todos `deny` con motivo de 16 383 o 16 384
      bytes; A, 6 casos, con el aviso emitido de 16 381 a 16 384 bytes, sin decisión y el REQ sin cerrar.
  - **QA-007-12: construido en `03cbf5e`; validado y cerrado por QA en la re-verificación (`docs/qa/REQ-007.md`,
    «Paso 6: re-verificación de la pasada correctiva»; evidencia `6cf1ba0`) (P-136-P (2) (A), resuelta por el
    propietario el 2026-10-06; versionado ese día; estado actualizado el 2026-10-07).** *(Antes: «QA-007-12: en la
    pasada correctiva del paso 6, SIN VALIDAR». Historial, 2026-10-07.)* Decisión, literal: «(2) (A): la pasada correctiva repara QA-007-10, QA-007-12 y
    QA-007-11 (a); … Nada más entra.» (`PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario,
    2026-10-06) — P-136-P: (1) (A) y (2) (A)»).
    - **Lo medido por QA** (`docs/qa/REQ-007.md`, «Paso 6…», §2 y §10; evidencia `cand-1.36.0/sec115-118/qa/70-` a
      `73-`, commit `e19b708`): con contenido UTF-8 válido, el tope se cumple —motivos de 16 382 a 16 384 bytes—.
      Con bytes que **no** son UTF-8, no: un `QA:` o un `Seguridad:` de unos 140 KB de `0xFF`, `0x80` o un `0xC3`
      suelto, leído del disco, da un `deny` válido cuyo motivo mide **48 692 a 48 781 bytes**; y en la librería, un
      motivo de 16 383 o 16 384 bytes que termina en un carácter partido sale con 16 385 o 16 386. La decisión se
      emite siempre. Causa, por lectura de QA: `arnes_acota` mide y corta en bytes **antes** de que `jq -R`
      sustituya cada byte inválido por U+FFFD, de 3 bytes. Lo introduce esta ventana.
    - **Estado:** **construido en `03cbf5e`; validado y cerrado por QA** en la re-verificación (`docs/qa/REQ-007.md`,
      «Paso 6: re-verificación de la pasada correctiva», §1, §2 y §6; evidencia `cand-1.36.0/sec115-118/qa2/20-` a
      `23-`, commit `6cf1ba0`): a nivel de hook, 0 casos mal de 393 con el valor leído del disco y motivo máximo de
      16 384 bytes, frente a 119 de 393 y 48 872 bytes en `8e11f87`; en la librería, 0 mal de 112. La revisión de
      seguridad del paso 6 sigue pendiente (`Seguridad: pendiente`); esta viñeta no toca `Hallazgos abiertos:`. La
      medida fue la de «Medida», arriba —el tope con contenido ASCII, de 2 y de 4 bytes—, más los rellenos que no
      son UTF-8 de QA-007-12, en el tope y por encima. *(Antes: «reparación **en curso** en la pasada del
      `desarrollador`, **SIN VALIDAR** por QA ni por seguridad. Este criterio no lo declara reparado; …». Historial,
      2026-10-07.)*
  - **Estado: construido en `c5bf6d4` (commits `0efd3c2`, `8e11f87`, `03cbf5e`, `39e6128`, `c5bf6d4`); validado
    por QA (`c4afbde`, favorable para el código del paso 6); R-056 conforme sin veto: SEC-115, SEC-118 y SEC-129
    `mitigado` en el candidato, con sus residuales (QA-007-09, SEC-132, Windows y el host sin medir; F-136-9/19/20 y
    SEC-131)** (write-back de estado del 2026-10-07, sin cambio de contrato).
    - **Validación de QA:** `docs/qa/REQ-007.md`, las cinco secciones del paso 6, la última «Paso 6:
      re-verificación de la línea de P-136-R», veredicto **FAVORABLE** (evidencia `cand-1.36.0/sec115-118/qa4/`,
      commit `c4afbde`). Las viñetas de QA-007-07, QA-007-10, QA-007-11 (a), QA-007-13 y QA-007-14 de la parte (ii)
      llevan cada una su validación.
    - **Determinación de seguridad:** `docs/seguridad/registro-seguridad.md` § R-056, §2, §3, §9 y §10 (evidencia
      `cand-1.36.0/sec115-118/seg-R056/`, commit `4bd3464`): **conforme con hallazgos, sin veto**, sobre el delta
      del paso 6; en lo medido, ningún `deny` pasa a `allow` ni a «sin decisión» a nivel de hook, y los movimientos
      van sólo hacia `deny`, declarados en CA-69, punto 3 (R-056 §9). Lo de este criterio, en el candidato
      `c5bf6d4`, sin publicar (R-056 §10):
      - **SEC-115 `mitigado` en sus tres vías registradas** —el valor grande, el `Write` grande y la búsqueda de
        `old_string`—. Residuales con identificador propio, abiertos: QA-007-09 (F-136-18, límite declarado,
        arriba) y SEC-132. Límite declarado: la operación única que no termina («Lo que esta propiedad no puede
        prometer», arriba). Abierto aparte: SEC-030. Sin medir: Windows/MSYS.
      - **SEC-129 `mitigado`.** Residuales: F-136-20 (i) a (v), F-136-19 y F-136-9, declarados; SEC-131, abierto;
        bash distinto de 5.3.9, sin medir.
      - La palabra es la de R-056: `mitigado`, no «reparado».
    - **Lo que no cambia:** R-056 es una determinación sobre el delta, **no la firma del REQ**: `Seguridad:` sigue
      `pendiente`, y este write-back no toca la cabecera ni `Hallazgos abiertos:`. Las sedes de la promesa de
      CA-69, punto 5, no se tocan aquí.
    - Lo que sigue en esta viñeta es lo que declaró y midió el `desarrollador` en la fase 2 (sede
      `docs/arnes/v1.36.0-sec115-118-fase2.md` §1, §2, §7 y §8; evidencia `cand-1.36.0/sec115-118/`, commit
      `65092c8`), que QA validó después.
    - *(Antes: «Estado: construido en `0efd3c2`; SIN VALIDAR por QA (paso 6, fase 2; write-back de estado del
      2026-10-06, sin cambio de contrato; sede …). Es lo que declara y mide el `desarrollador`; no acredita este
      criterio hasta que QA lo valide.» Historial, 2026-10-07, R-056.)*
    - **Medido por el desarrollador.** Sección 47: T1, T2a, T2b y T3 en `deny` en 4,3, 0,6, 0,4 y 2,7 s (T2a y T2b
      los deniega el techo de piezas; T3, el presupuesto de búsqueda); las 40 filas de `Bash` en modo POSIX en
      `deny` y los 32 controles sin cambio. Fallos inyectados en copias, nunca en el árbol (`60-`, `61-`): F1 (puerta
      abandonada), F2 (el analizador devuelve 7), F3 (`set -u` dentro de una puerta) y F4 (`jq` inexistente dentro de
      `arnes_deny`) dan `deny`, y un proyecto sin `.arnes/` sigue inerte. Procesos (`80-`): **+0** en el camino
      común; las rutas que deniegan por techo, plazo o fin anómalo emiten con el mismo `jq` de siempre, y el `deny`
      fijo de la trampa no lanza ninguno.
    - **No comprobado en esta fase** (fase 2, §8): Windows/MSYS y el host; bash distinto de 5.3.9; los finales de
      (i) que no sean F1 a F4; y las expansiones `$'…'` en modo POSIX (O-54-3), que con R1 no se alcanzan, por
      lectura del código.
    - *(Punteros de línea de `hooks/lib.sh` de este estado, leídos en el código de `8e11f87`. Antes: `:441`, `:444`,
      `:426`, `:453` y `:1670-1671`, los de `0efd3c2`; la reparación de QA-007-07 (`hooks/lib.sh:125-132`) los
      desplazó 9 líneas. Los de `hooks/guard.sh`, `hooks/guard-codigo.sh` y `hooks/guard-completado.sh` no se
      movieron. Historial, 2026-10-06, write-back de estado del QA del paso 6.)*
