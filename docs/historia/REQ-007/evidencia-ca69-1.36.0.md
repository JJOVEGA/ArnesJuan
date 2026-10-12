# REQ-007 — historia: CA-69, evidencia común del Bloque L (1.36.0)

> **Movido desde `requirements/REQ-007.md` el 2026-10-12** por la undécima autorización del propietario
> (ficha **F-136-17**), cabeza de origen **`cecf9b6`**, líneas **3141–3239 y 3269–3397** (228 líneas, 23294 bytes medidos).
> **Copia verbatim: no se resumió, no se reordenó y no se corrigió nada.**
> Índice: `docs/historia/REQ-007/README.md`. Contrato: `docs/arnes/v1.37.0-f136-17-fase1.md`.
> Comprobación de que no se perdió ninguna línea: ese contrato, §5, y el índice.

  1. **Línea base: v1.35.0 publicada** (tag `v1.35.0`, fusión `3956a6f`), por la regla de Notas / alcance —la
     versión publicada inmediatamente anterior a la ventana—. **Fail-before:** todo caso nuevo que en el candidato
     espera `deny` y que en v1.35.0 se registra `allow` o sin decisión **permite de verdad, o sale sin decisión, en
     v1.35.0**, o el caso aborta; si v1.35.0 no se puede materializar, el caso sale SKIP con el motivo, nunca PASS.
     Un vector registrado en una versión anterior que no se reproduce en v1.35.0 se declara y no cuenta como
     fail-before.
  2. **Ningún veredicto del banco cambia — caso por caso, no por el total.** Con `tests/escenarios/hooks/inventario.sh`
     (REQ-014 CA-12; sitio único del oráculo que separa la identidad del caso de su medida), en la misma máquina
     Linux/WSL2:
     - **(a) El banco de v1.35.0 tal cual** —su árbol `tests/` sin cambiar una línea, **2050 casos**, corrido desde un
       árbol de trabajo de la etiqueta `v1.35.0`— una vez con `ARNES_HOOKS_DIR` en los hooks de v1.35.0 y otra en
       los del candidato: los dos inventarios son **idénticos** (`diff` vacío). Es la medida que no depende de que
       nadie toque las expectativas de un caso. Para CA-54 no admite ninguna excepción; para CA-47 punto 20, CA-67 y
       CA-68, una línea distinta sólo es conforme si es un movimiento declarado del punto 3. Si el candidato cambia
       `tools/`, se dice, y esos casos se acreditan sólo por (b). Si CA-54 se entrega en su propio commit —el orden
       de prioridad del pedido—, (a) se mide también sobre ese commit. Las dos corridas cuyos inventarios se
       comparan se invocan con `ARNES_SEMILLA_41` fijada al valor que registra el inventario de referencia (`23062`
       en `cand-1.36.0/ca54/22-inventario-v1.35.0.txt` del árbol de evidencia), sin cambiar el banco *(precisión de
       procedimiento añadida el 2026-10-05 por P-136-D; Historial)*.
     - **(b) El banco del candidato, completo:** sin FAIL y con `CASOS_ESPERADOS` cuadrado; su inventario contiene
       **cada línea** del de (a) sin cambios —salvo un movimiento declarado del punto 3, nunca por CA-54—; las
       únicas líneas de más son las de los casos que añade esta ventana, declaradas en el Historial con su número;
       ninguna línea de v1.35.0 falta.
     - **(c) Un SKIP o un INCONCLUSO no acredita** (decisión 7 del propietario de 1.35.0): si una línea difiere sólo
       porque en una de las dos corridas es `SKIP … [INCONCLUSO]`, ese caso queda **no acreditado** —ni conforme ni
       FAIL— y se declara con su motivo. Un FAIL en cualquiera de las dos corridas es FAIL, y no se desmiente
       repitiendo la corrida.
     - Y el banco en verde en el CI (`hooks-en-linux`) sobre la cabeza final.
       - **Lo que el runner no tiene, y qué no acredita (anotado el 2026-10-07 por QA-007-18).** En el run
         `37482487075` del PR #60 (cabeza `f1ffac3`) hubo **34 SKIP**: los 12 de siempre; **18** de REQ-023 CA-08
         (i), R1–R18, porque en el runner **falta la instalación estable 1.33.2**; **3** de REQ-017 CA-10 (i)–(iii),
         que se atribuyen a **bash 5.2.21** del runner (**inferido**: no se ejecutaron con ese bash; con jq 1.7.1 y
         bash 5.3.9 no salen); y 1 INCONCLUSO de rendimiento de REQ-017 CA-08 (ii). **Ninguno de los 34 SKIP del CI
         acredita** (punto (c)). Y con un `jq` que no lee V4 —el del runner, 1.7.1, inferido de la imagen—, K4 sale
         SKIP con motivo, que tampoco acredita el control (CA-47 p. 20, Medida). Fuente: `docs/qa/REQ-007.md`, «CI
         del PR #60: K4 (V4) en Ubuntu», §1 y §4. *(Antes no había anotación. Historial.)*
  3. **Movimientos frente a v1.35.0:** sólo de `allow` —o de «sin decisión»— a `deny`, los que declaran CA-47
     punto 20, CA-67 y CA-68: entradas que no se pueden leer, motivos grandes, juicios que no terminan. Desde el
     2026-10-06 entran también los finales que no son un juicio, por CA-68 (SEC-129). Entre ellos, las filas de
     `Bash` de las tres puertas con el hook en modo POSIX, que pasan de «sin decisión» a `deny`. Lo legítimo
     que caiga en ellos —por ejemplo, un juicio legítimo que agote el plazo de 40 s de CA-68 (P-136-C)— se declara aparte, para que no
     se lea sólo como protección. **Ningún movimiento de `deny` a `allow`** (CA-24): uno es hallazgo. CA-54 no mueve
     nada.
     - **Declarado aparte: lo legítimo que cae en los techos de tamaño de CA-68 — cambio de compatibilidad
       (versionado el 2026-10-06).** Autorización citada: la decisión del propietario «P-136-O: (1) (A) y (2) (A).
       P-136-N: (A).», `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-06) — P-136-O: (1)
       (A) y (2) (A); P-136-N: (A)», texto adoptado de P-136-O (1) (A). Dos llamadas legítimas sobre un REQ grande
       pasan de «sin decisión» a `deny`, a todo agente:
       - el `Write` de un REQ cuyo texto troceado pasa de **393 216 bytes** (`ARNES_PIEZAS_MAX_BYTES`). Medido:
         `REQ-007.md` entero, 660 431 bytes, sin decisión en 11,5 s en v1.35.0 y `deny` en el candidato;
       - el `Edit` cuyo producto de búsqueda pasa de **2³²** (`ARNES_EDIT_MAX_BUSQUEDA`). Medido sobre
         `REQ-007.md`: con un `old_string` de 7 000 o 12 000 bytes, sin decisión en v1.35.0 y `deny` en el
         candidato; con 3 000 a 6 400 bytes, sin decisión en los dos.

       Las cifras son operativas y de lo construido en `0efd3c2`, con una corrida por punto (`65-`). La regla, las
       fronteras, la salida y lo que no cambia viven en CA-68, «Techos de tamaño», «Cambio de compatibilidad
       declarado…», que es su sitio único. *(Antes: este punto no declaraba ninguna llamada legítima que cayera en
       un techo de tamaño, y la fase 2 dejó su alcance pendiente de P-136-O. Historial, 2026-10-06, P-136-O y
       P-136-N.)*
     - **Declarado también, por CA-68 (ii) ampliada (P-136-N (A), misma entrada):** las llamadas juzgadas con
       `ARNES_INPUT_LISTO` o `ARNES_MANIFEST_LISTO` heredadas del entorno pasan de «sin decisión» a la decisión que
       reciben sin ellas, `deny` en los vectores de QA-007-07. Es protección, no compatibilidad: sobre lo legítimo
       no se espera movimiento, porque la parte (ii) exige la misma decisión que sin la variable.
     - **Retirado: el movimiento de las quality gates por el plazo (SEC-132 (a)) — el candidato no lo hace (P-136-U
       (A), resuelta por el propietario el 2026-10-07; versionado ese día; `PENDING_APPROVAL.md` § Resueltas, entrada
       «RESUELTA (propietario, 2026-10-07) — P-136-U: (A)»).** La pasada que lo construía (`cd63066`) se revirtió, y
       el código y el banco vuelven a `c5bf6d4`: **ninguna gate se interrumpe** y **ningún cierre pasa a `deny` por
       plazo a causa de sus quality gates**, tampoco lo legítimo. Un cierre cuyas gates no terminan dentro de los 60 s
       del cliente sigue saliendo **sin decisión**, como en `c5bf6d4`; es el límite declarado de CA-68, «SEC-132 (a) —
       el plazo propio no alcanza a las quality gates», que es su sitio único. Ninguna línea del inventario se acredita
       como movimiento declarado de SEC-132 (a). *(Antes: «**Declarado aparte: lo legítimo que cae en el plazo
       comprobado entre quality gates — cambio de compatibilidad (SEC-132 (a); versionado el 2026-10-07; en la pasada
       acotada de P-136-S, SIN VALIDAR).** Autorización citada: … P-136-S … y … P-136-T …, que lo precisa: «una gate
       que no termine dentro del plazo se interrumpe y el cierre se deniega». Pasan de «sin decisión» —o de un cierre
       que pasaba— a **`deny` por plazo**, a todo agente, también lo legítimo con todas sus gates en verde, dos formas:
       un cierre cuyas quality gates en serie agotan el plazo propio del hook …; y un cierre con **una sola gate que no
       termina dentro de lo que queda del plazo**, que **se interrumpe** … El caso que lo mide cubre las dos formas …
       Mientras la pasada no esté validada, este movimiento se declara y **no se da por construido**.» Historial,
       2026-10-07, P-136-U.)*
  4. **Plataformas y capas, por separado:** hook en Linux/WSL2, obligatorio; host (`claude -p` en WSL2) si está
     disponible, con registro previo y una ejecución por caso, y si no, cada fila **no comprobada en el host**, nunca
     PASS; **Windows/MSYS, declarado no medido**, sin cobertura atribuida; extensión de VS Code, no.
  5. **Las sedes de la promesa cambian sólo cuando esté construido y validado, y sólo hasta lo medido** —ejemplos
     **no exhaustivos**; el analista repite el barrido por propiedad al hacer el write-back—: `AGENTS.md`
     §13 —la cláusula 1 de los límites y la fila de los hallazgos, que hoy declaran SEC-115 y SEC-118 como
     limitaciones—, `templates/AGENTS.md.tpl`, `requirements/README.md` § «Clases de hallazgo», las notas `[1.36.0]`
     y `skills/arnes-upgrade/SKILL.md`. Hasta entonces ninguna sede dice «reparado». Ese write-back es del analista
     (`AGENTS.md` §9).
     **Estado (2026-10-07, P-136-S (3), que lo autoriza):** hecho en `AGENTS.md` §13 —la cláusula 1, la fila de los
     hallazgos, la de la cabecera ambigua y dos filas nuevas, la de la parte (ii) de CA-68 y la de SEC-120—, en
     `templates/AGENTS.md.tpl` con el mismo texto, en `requirements/README.md` § «Veredictos de validación» y
     § «Clases de hallazgo» y en su plantilla, y en la guía, «Hacia 1.36.0». Dicen **`mitigado`** —la palabra de
     R-056—, nunca «reparado», con sus residuales; lo medido en 1.35.0 queda fechado como historia de esa versión, y
     SEC-132 (a) se nombra como **límite declarado**, con la nota de que en 1.35.0 el REQ quedaba `completado`, que
     1.36.0 no cambia ese caso, y la remisión a F-136-22 (P-136-U, 2026-10-07). Las notas `[1.36.0]` no son de esta
     comisión. *(Antes: «… y SEC-132 (a) se nombra como pasada **sin validar**.» Historial, 2026-10-07, P-136-U. Y
     antes de SEC-134: «… con la nota de que en 1.35.0 el REQ quedaba `completado` y la remisión a F-136-22…».
     Historial, 2026-10-07, SEC-134.)*
  6. Las quality gates de `AGENTS.md` §7 y la autoprueba del corredor, en verde.
     - **E3 — los inventarios del punto 2 (a) y (b).** La línea de REQ-017 CA-09 tiene que salir PASS o SKIP por
       solape; para el SKIP rige la regla de 2 (c).
     - **Regla de «afecta»** (**de contrato**: es la definición; basta **1** caso). Hay tres formas:
       - en E1, a 98 304 o a 196 608 bytes, el motivo es el de un techo nuevo o el del plazo de CA-68;
       - en E2, el candidato da un FAIL, o un SKIP estructural que v1.35.0 no da en su serie;
       - en E3, la línea sale SKIP estructural o FAIL.

       Si afecta, el `desarrollador` **para antes de entregar** y la coordinadora presenta al propietario la ficha de
       la evaluación, §7, rellenada con la cifra medida (`AGENTS.md` §9: REQ-017 está `completado`). **No afecta**
       si todas las líneas del candidato son PASS o SKIP por solape y E1 no da ningún motivo de techo ni de plazo en
       esos dos tamaños.
       - **Precisión (P-136-P (1) (A), resuelta por el propietario el 2026-10-06; versionado ese día).** La regla
         **sigue vigente y no cambia**: un FAIL en E2 es «afecta», y entonces se para y se presenta con §9. Lo que
         decidió el propietario es **una instancia**: el FAIL de E2 que QA midió en el paso 6 (QA-007-08), que
         resolvió como **no «afecta»** por la dirección de la cifra —0,962×, el candidato **más rápido** que la
         referencia en esa corrida— y por E1, la medida directa, sin ningún cambio. La resolución, con sus cifras,
         está abajo, en «Medido por QA: E2 dio 1 FAIL en 6…». No crea una excepción para otras corridas ni para otro
         FAIL. *(Antes: la regla sin esta precisión; por ella, el FAIL de QA era «afecta» → parada y §9, con REQ-017
         de vuelta a `en-revisión`. Historial, 2026-10-06, P-136-P.)*
     - **No acredita:** Windows/MSYS, otros hosts, tamaños fuera de los de la sonda, ni un SKIP o un INCONCLUSO como
       prueba de «no afecta» en E1.
     - **Una comprobación de QA que no amplía el alcance: SEC-130.** Clase y estado en R-055 §4,
       `docs/seguridad/registro-seguridad.md:10649`, y su texto final en R-056 §4 (abajo, «Texto final, según
       R-056»); ficha F-136-12, `docs/PENDIENTES.md:2263`. QA comprueba si la
       reparación de SEC-129 por CA-68, parte (i) —la R2 de R-054 §4—, cubre SEC-130 por construcción, y lo
       registra. Si no lo cubre, queda para 1.37 como dice F-136-12: no se repara en este paso ni abre trabajo en él.
     - **Estado: construido en `c5bf6d4` (commits `0efd3c2`, `8e11f87`, `03cbf5e`, `39e6128`, `c5bf6d4`); validado
       por QA (`c4afbde`, favorable para el código del paso 6); R-056 conforme sin veto: SEC-115, SEC-118 y SEC-129
       `mitigado` en el candidato, con sus residuales (QA-007-09, SEC-132, Windows y el host sin medir;
       F-136-9/19/20 y SEC-131)** (write-back de estado del 2026-10-07, sin cambio de contrato; sedes: CA-67 y CA-68,
       «Estado»; `docs/qa/REQ-007.md`, las cinco secciones del paso 6; R-056 §10).
       - **Lo de este punto:** E1 a E3 los midió el `desarrollador` sobre `0efd3c2` (sede
         `docs/arnes/v1.36.0-sec115-118-fase2.md` §4; evidencia `cand-1.36.0/sec115-118/`, commit `65092c8`) y QA sobre
         `8e11f87` («Medido por QA», abajo), con E1 re-medido por QA sin cambio hasta el código de `c5bf6d4`
         (`docs/qa/REQ-007.md`, «Paso 6: re-verificación de la línea de P-136-R», §3; evidencia `qa4/`, commit
         `c4afbde`). Resultado: **«no afecta»**, con el FAIL de E2 de QA resuelto por P-136-P (1) (A) como INS-136-4
         (abajo). R-056 no repitió E1 a E3 (R-056 §11, «No revisado o no medido»).
       - *(Antes: «Estado: E1 a E3 medidos por el desarrollador sobre `0efd3c2`; SIN VALIDAR por QA (write-back de
         estado del 2026-10-06; …). Por la regla de arriba, el resultado medido es «no afecta».» Historial,
         2026-10-07, R-056.)*
       - Lo que sigue son las cifras del `desarrollador`:
       - **E1** (`78-`, árbol final; antes `40-`): las tres entradas, tres veces e intercaladas. En los dos árboles
         salen sin decisión, sin motivo y con rc 0: ningún motivo de techo ni de plazo. Duraciones, candidato frente
         a v1.35.0: N = 0, de 104 a 105 ms frente a 103 a 105 ms; N = 98 304, de 304 a 305 ms frente a 405 a 406 ms;
         N = 196 608, de 1 006 a 1 007 ms frente a 1 005 a 1 006 ms.
       - **E2** (`79-`; antes `42-`): seis corridas contra el candidato intercaladas con seis contra v1.35.0, **12 de
         12 PASS**; ningún SKIP por solape, ningún SKIP estructural y ningún FAIL.
       - **E3:** las dos líneas de REQ-017 CA-09 salen PASS en `22-` y en los inventarios de la fase (`51-`, `57-`,
         `73-` y `76-`).
     - **Medido por QA: E2 dio 1 FAIL en 6; por decisión del propietario no es «afecta» (P-136-P (1) (A), resuelta
       el 2026-10-06; versionado ese día).** Decisión, literal: «P-136-P: (1) (A): QA-007-08 es INS-136-4; F-136-8 se
       amplía a CA-09; REQ-017 no se reabre. (2) (A): …» (`PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA
       (propietario, 2026-10-06) — P-136-P: (1) (A) y (2) (A)», con la ficha debajo).
       - **Lo medido por QA** (`docs/qa/REQ-007.md`, «Paso 6: validación de SEC-115, SEC-118, SEC-129 y QA-007-07»,
         §7 y §10; evidencia `cand-1.36.0/sec115-118/qa/60-` y `61-`, commit `e19b708`, sobre el código de
         `8e11f87`):
         - **E1:** en los dos árboles, sin decisión, sin motivo y con rc 0; ningún motivo de techo ni de plazo;
           **sin cambio frente a v1.35.0**;
         - **E2:** el candidato, 4 PASS, 1 SKIP por solape y **1 FAIL** (corrida 4: «el MEJOR de este árbol vale
           0.962× el PEOR de v1.32.1»); v1.35.0, 5 PASS y 1 SKIP por solape;
         - **E3:** las dos líneas de REQ-017 CA-09, PASS.
       - **Lo que decidió el propietario:** el FAIL **no es «afecta»**. QA-007-08 se registra como `instrumento`,
         **INS-136-4** (`docs/PENDIENTES.md`, «INS-136-4»; dueño `qa-tester`, con el `analista-requerimientos` en
         1.37); **REQ-017 no se reabre** y sigue `completado`; y la ficha **F-136-8** (`docs/PENDIENTES.md`) se amplía
         a CA-09, de modo que la revisión de 1.37 cubre las tres sondas de reloj de REQ-017 (CA-03, CA-08 (ii) y
         CA-09). La razón que da la ficha: la cifra está **por debajo de 1** —el candidato fue más rápido, no más
         lento—, y **E1**, la medida directa a nivel de hook, no cambia ni de decisión ni de duración.
       - **Lo que no cambia:** por 2 (c), el FAIL sigue escrito y no se desmiente repitiendo; la decisión fija su
         clase, no lo borra. La «Regla de «afecta»», arriba, rige igual para cualquier otra corrida (su precisión).
         Reclasificar QA-007-08 en `Hallazgos abiertos:` es de QA.
       - *(Antes: este punto sólo registraba lo medido por el desarrollador —E2, 12 de 12 PASS— y su resultado,
         «no afecta»; el FAIL de QA, QA-007-08 (`contrato`), quedaba pendiente de P-136-P. Historial, 2026-10-06,
         P-136-P.)*
     - **SEC-130, por lectura del desarrollador; la comprobación de QA sigue siendo suya: R2 no lo cubre por
       construcción.** `arnes_estado_ausente` (`hooks/lib.sh:2318-2327` en `8e11f87`; antes, `:2309-2318`, los de
       `0efd3c2`) empieza con `rc=0`. Si la redirección
       `2>/dev/null` del grupo falla, el grupo no corre y la función devuelve 0, que dentro de su vocabulario es una
       respuesta válida: «el comando no menciona el estado terminal». `hooks/guard-completado.sh:412` lo usa con
       `&& return 0`, así que el guardián termina, escribe su marca y R2 no ve el final anómalo. Sigue abierto como
       **F-136-12**, para 1.37, sin reparar en este paso.
       - **Comprobado por QA, midiendo: R2 no lo cubre** (write-back de estado del 2026-10-06; `docs/qa/REQ-007.md`,
         «Paso 6: validación de SEC-115, SEC-118, SEC-129 y QA-007-07», §6; evidencia `cand-1.36.0/sec115-118/qa/40-`
         a `43-`, commit `e19b708`; inyecciones en copias, nunca en el árbol). A nivel de librería, con `ulimit -n 3`,
         `arnes_estado_ausente` devuelve 0 ante un comando que **sí** menciona el estado terminal; sin el límite,
         devuelve 1. A nivel de hook, en una copia con `ulimit -n 3` justo antes de la llamada de
         `hooks/guard-completado.sh:412`, un cierre de REQ por `sed -i` sale **sin decisión** por `guard.sh` y por
         `guard-completado.sh`; sin la inyección, `deny`. La puerta escribe su marca y la trampa no ve nada. Por la
         viñeta «Una comprobación de QA que no amplía el alcance», sigue como **F-136-12**, para 1.37: no se repara
         en este paso ni abre trabajo en él.
       - **Texto final, según R-056** (`docs/seguridad/registro-seguridad.md` § R-056, §4 y §10; evidencia
         `seg-R056/`, bloque 06, commit `4bd3464`). Clase **`instrumento`**, severidad **baja**, `abierto`, no
         aceptado; sede **F-136-12**, 1.37.
         - **R2 no lo cubre:** lo midió QA (arriba) y la lectura de R-056 lo confirma.
         - **Desde fuera del proceso no se alcanza.** Con el límite de descriptores heredado: con **3**, rc 127; con
           **4 y 5**, la vía inerte del preludio, que es SEC-131 (b); con **6 o más**, la decisión normal. El camino de
           SEC-130 sólo se alcanza cambiando el límite **dentro** del proceso, como en la copia de QA; por eso el texto
           «no alcanzado a nivel de hook» queda corregido en esos términos.
         - **No bloquea el cierre de REQ-007**, por su clase. Mientras esté abierto, devuelve **publicar** al
           propietario por la regla vigente (R-056 §4; `AGENTS.md` §4 y §6).
         *(Antes: este punto citaba sólo R-055 §4 para la clase y el estado. Historial, 2026-10-07, R-056.)*
     - **Una observación de QA que no amplía el alcance: el FAIL de la sección 24 en el inventario del punto 2 (a)
       (P-136-O (2) (A), resuelta por el propietario el 2026-10-06).** Decisión, literal: «P-136-O: (1) (A) y (2)
       (A). P-136-N: (A).» (`PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-06) —
       P-136-O: (1) (A) y (2) (A); P-136-N: (A)»), con su texto adoptado: «QA observa el FAIL de la sección 24 en
       su propio inventario y en varias corridas de la sección en reposo; si lo reproduce, es hallazgo; si no,
       INS-136-3.» El FAIL es el de la 1.ª de las tres corridas del banco de v1.35.0 con los hooks del candidato
       (`50-`–`52-`): sección 24, `arnes-lectura: …el contador no dice 1`. Ejecuta `tools/arnes-lectura.sh`, que
       comparte `lib.sh` con los hooks, y no se reprodujo en la sección 24 aislada (3 de 3), en las otras dos
       corridas de 2 (a) ni en los tres bancos del worktree (`docs/arnes/v1.36.0-sec115-118-fase2.md` §5).
       - **Qué hace QA:** corre su propio inventario de 2 (a), con `ARNES_SEMILLA_41=23062`, y la sección 24 varias
         veces con el anfitrión en reposo, anotando la carga en cada corrida. Registra el número de corridas de la
         sección **antes** de correrlas, como procedimiento, para que no se decida a la vista del resultado.
       - **Si lo reproduce** en cualquiera de esas corridas: es **hallazgo** contra el delta, con la clase que fije
         QA, y bloquea lo que su clase bloquee.
       - **Si no lo reproduce:** se registra como **instrumento, INS-136-3**, con las corridas limpias y la única
         roja, citadas.
       - **Lo que no cambia:** por 2 (c), el FAIL sigue escrito y no se desmiente repitiendo. Esta observación no
         lo borra: decide su clase, por decisión del propietario. No abre trabajo de reparación en este paso.
       - **Hecha: no se reprodujo, y es INS-136-3** (write-back de estado del 2026-10-06; `docs/qa/REQ-007.md`,
         «Paso 6: validación de SEC-115, SEC-118, SEC-129 y QA-007-07», §8 y §10; evidencia
         `cand-1.36.0/sec115-118/qa/`, commit `e19b708`, con el procedimiento registrado antes de correr en
         `qa/00-procedimiento.txt`). QA fijó de antemano **15 corridas** de la sección 24: 10 aisladas del banco de
         v1.35.0 con los hooks del candidato y 5 del banco del worktree, en serie, con la carga anotada (0,28;
         `qa/10-`). Más la sección dentro de su propio inventario de 2 (a), con `ARNES_SEMILLA_41=23062`: **16 de 16
         sin FAIL**. Se registra como `instrumento`, **INS-136-3** (`docs/PENDIENTES.md`, «INS-136-3»; dueño
         `qa-tester`), con las corridas limpias citadas. La única roja sigue siendo la del desarrollador (`50-`),
         sobre un árbol intermedio, y sigue escrita por 2 (c). Si reaparece, vuelve a abrirse como hallazgo contra el
         delta. El caso no imprime su salida cuando falla, así que no hay más datos sobre la causa.

