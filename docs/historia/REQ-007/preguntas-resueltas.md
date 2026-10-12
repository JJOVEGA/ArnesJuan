# REQ-007 — historia: las cinco preguntas abiertas, todas resueltas (1.35.0–1.36.0)

> **Movido desde `requirements/REQ-007.md` el 2026-10-12** por la undécima autorización del propietario
> (ficha **F-136-17**), cabeza de origen **`cecf9b6`**, líneas **3812–4177** (366 líneas, 34 900 bytes medidos).
> **Copia verbatim: no se resumió, no se reordenó y no se corrigió nada.**
> Índice: `docs/historia/REQ-007/README.md`. Contrato: `docs/arnes/v1.37.0-f136-17-fase1.md`.
> Comprobación de que no se perdió ninguna línea: ese contrato, §5, y el índice.

**SEC-132 (a): la gate en curso y el techo de 40 s (2026-10-07, registro de P-136-S) — RESUELTA por el propietario
el 2026-10-07 (P-136-T (B)); ya no es pregunta abierta.** Decisión, literal: «P-136-T: (B). El plazo se comprueba
entre gates y la gate en curso se acota al tiempo que queda del plazo: un cierre cuyas gates agotan el plazo se
deniega por plazo con motivo propio, antes de los 40 s, incluida una gate colgada. Cambio de compatibilidad declarado:
una gate que no termine dentro del plazo se interrumpe y el cierre se deniega. El caso de banco cubre las dos formas:
cuatro gates de 20 s y una gate colgada. Nada más entra.» Sede: `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA
(propietario, 2026-10-07) — P-136-T: (B)» (mensaje del 2026-10-07 a la sesión coordinadora del worktree
`ArnesJuan-v1.36`), con la ficha que resuelve debajo. Escrita en CA-68, viñeta «SEC-132 (a) — el plazo se comprueba
entre una quality gate y la siguiente» («La propiedad», «Cambio de compatibilidad declarado», «Medida», «No acredita»
y «Estado»), y en CA-69, punto 3. Lo que sigue es el texto de la pregunta tal como se abrió, sin cambiarlo.

**Anotación del 2026-10-07: esta resolución queda SUPERADA por P-136-U (A), en lo que toca a 1.36.0.** Decisión del
propietario, literal en `PENDING_APPROVAL.md` § Resueltas, entrada «RESUELTA (propietario, 2026-10-07) — P-136-U:
(A)», con la ficha debajo: se revierte el código de `cd63066` —la pasada que construía lo decidido en P-136-T (B)—
y «SEC-132 (a) queda como límite declarado con (b) en F-136-22, para 1.37». La gate en curso no se acota en el
candidato, ni el techo de 40 s se cumple para las quality gates: está escrito en CA-68, viñeta «SEC-132 (a) — el
plazo propio no alcanza a las quality gates», y CA-69, punto 3, retira su movimiento. La resolución de arriba y el
texto de apertura se conservan sin borrar, como historia; no se reabre la pregunta, y la forma de la reparación en
1.37 se propone antes de implementarse (F-136-22).

*(Texto de apertura:)* No cambia `Estado:` ni abre ningún otro punto: afecta sólo a cómo se acredita la viñeta de CA-68
«SEC-132 (a) — el plazo se comprueba entre una quality gate y la siguiente».
- **Qué choca.** La decisión fija la técnica: «plazo comprobado entre gates». El encargo de la coordinadora fija la
  propiedad con el techo de 40 s de CA-68 y el caso de medida con cuatro gates de 20 s. Con el plazo de 30 s
  comprobado sólo entre gates, la gate en curso no se interrumpe: en ese caso la segunda gate empieza hacia los 20 s
  y el `deny` llega cuando termina, hacia los 40 s (lo prevé R-056 §7: «habría denegado hacia los 40 s»), en la
  frontera del techo. Con una gate más larga que lo que queda del plazo, el techo de 40 s no se puede cumplir sin
  interrumpir esa gate, y el criterio ya declara que el plazo «no alcanza a una quality gate en curso».
- **Lo observado en el árbol de trabajo al escribir esto** (`hooks/guard-completado.sh`, sin commit, mientras el
  `desarrollador` trabaja): el comentario y el código esperan cada gate con `read -t` el tiempo que **queda** del
  plazo y, si no termina, **cortan la gate en curso** (`kill` del subshell, con el límite declarado de que lo que la
  gate lanzó por su cuenta puede seguir corriendo). Eso va **más allá** de «comprobado entre gates»: cambia el límite
  declarado de que el plazo no alcanza a una gate en curso y amplía el cambio de compatibilidad a **una sola gate**
  que dure más de lo que queda del plazo —por ejemplo, una gate legítima de 35 s, que en `c5bf6d4` pasa—. No está
  validado ni es contrato; se anota para que la decisión se tome viéndolo.
- **Opciones** (las presenta la coordinadora con la forma de `AGENTS.md` §6, regla 4): **(A)** la técnica literal
  —sólo entre gates—, y el techo de 40 s se lee para el caso en que la gate en curso no lo impide: el caso de cuatro
  gates de 20 s acredita el `deny` por plazo antes de los 60 s, con la duración anotada contra los 40 s; **(B)** el
  plazo corta también la gate en curso, con el techo de 40 s para todo cierre, el límite nuevo de lo que la gate
  lanza por su cuenta y el cambio de compatibilidad ampliado a una sola gate lenta, todo declarado; **(C)** otra
  cifra de plazo o de caso. **Recomendación del analista:** ninguna; es una elección de alcance que el propietario
  hace con la medida de la pasada delante.
- **Mientras no se resuelva:** la viñeta de CA-68 se escribe con la propiedad del encargo y esta pregunta a la
  vista; ni QA ni seguridad dan por acreditado el techo de 40 s de ese caso por esta viñeta, y nada aquí autoriza ni
  desautoriza el código observado.

**P-136-A, P-136-B y P-136-C (2026-10-03, apertura de 1.36.0) — RESUELTAS por el propietario el 2026-10-03, en la
décima autorización; ya no son preguntas abiertas.** Sus fichas —pregunta, opciones, recomendación y consecuencia de
cada opción— están, sin cambiar su texto, en `PENDING_APPROVAL.md` § Resueltas, debajo de la entrada «RESUELTA
(propietario, 2026-10-03, décima autorización)», que es la sede de las decisiones. Literales, de su apartado
«Decisiones del propietario (registrar literales; cierran las fichas)»:
- **P-136-A** (CA-54, procesos): «P-136-A: 0 procesos añadidos.» → CA-54, nota del 2026-10-03, «Coste en procesos».
- **P-136-B** (CA-67, el tope y los avisos): «P-136-B: criterio por propiedad: toda denegación decidida llega al
  cliente, entera o acotada, nunca perdida; el desarrollador elige la técnica; los avisos entran.» → CA-67, «El
  tope», «Los avisos entran», «Medida» y «No acredita».
- **P-136-C** (CA-68, mecanismo y plazo): «P-136-C: techos de tamaño más plazo propio de 40 s, sin procesos.» →
  CA-68, «Cómo, y con qué plazo», «Medida» (a), y CA-69, punto 3.
- **Y la del aviso de CA-68 sobre REQ-017 CA-09:** «CA-68 / REQ-017 CA-09: se evalúa al construir SEC-115; si
  afecta, §9.» → CA-68, «No regresión».

**Las decisiones se registran con sus palabras, sin traducirlas a las letras de las fichas.** En contenido, P-136-A
coincide con la opción (A) de su ficha; P-136-B, con (C) para el tope y (i) para los avisos; y P-136-C, con (B)
y el plazo en 40 s. Donde una ficha decía algo que la decisión no dice, manda la decisión. ADR-017 pasa a
`aceptada`. *(Antes: «P-136-A, P-136-B y P-136-C (2026-10-03, apertura de 1.36.0) — abiertas, al propietario. …
Este REQ sigue `en-progreso` con ellas abiertas …». Historial, 2026-10-03, décima autorización.)*

**P-119-A (2026-09-30) — Las fronteras de CA-47 que la quinta autorización no nombra.** **RESUELTA por el
propietario el 2026-10-03 como LÍMITES DECLARADOS; ya no es una pregunta abierta.** Fuente, literal:
- `PENDING_APPROVAL.md` § Resueltas, «Decisiones de publicación de v1.35.0», decisión 5: «P-119-A (F2, F5, F7) y
  SEC-123 — LÍMITES DECLARADOS, con F3 corregido (R-048). Permanecen abiertos y no aceptados como riesgo.»;
- la misma sección, «Cierre de v1.35.0, tramo 3», decisión 1: «P-119-A en REQ-007 pasa de «Preguntas abiertas» a
  resuelta como limites declarados (decision 5 de publicacion); F2, F5 y F7 siguen abiertos y no aceptados como
  riesgo.»

**Qué significa, y qué no:**
- **F2, F5 y F7** quedan escritas como no protegidas en CA-47, «Fronteras», que sigue siendo su sede, y en las notas
  `[1.35.0]`. **Siguen abiertas y NO están aceptadas como riesgo.** «Límite declarado» no es «riesgo aceptado».
- **F3** queda con su descripción corregida (R-048; CA-47, F3 y punto 16). Su límite de la detección de lo que
  depende del proceso es **SEC-123**: límite declarado, abierto, sin reparar, sin mitigar y no aceptado como riesgo.
- **La decisión no fija versión de reparación** para ninguna de las cuatro.
- **La decisión se registra con sus palabras, sin traducirla a las opciones de abajo:** declara las cuatro fuera de
  la promesa y dice expresamente que no se aceptan como riesgo, así que la palabra «aceptarlas» de la opción (A) no
  la describe. Ni F5 ni F3 se cubren en esta versión: siguen abiertas.
- **No cambia ningún criterio ni ninguna conducta:** CA-47 (puntos y fronteras), CA-66 y la cabecera de este REQ
  quedan como estaban; CA-47 sólo gana dos anotaciones fechadas que remiten aquí. La anotación de SEC-123 en `Hallazgos abiertos:` («decide el propietario con P-119-A») no se
  toca aquí: la cabecera no la edita este write-back.

*Texto original de la pregunta, conservado como historia (no se reescribe):* una, y no impide
implementar ni probar nada.
- **Pregunta para el propietario:** la quinta autorización pide declarar la frontera de las carreras (F1) y
  prohíbe atribuir cobertura a hosts no ejercidos (F4, F6). Este contrato declara además, sin promesa, **F2**
  (un `cd` dentro del comando y las expansiones del shell, que ya son límite declarado del detector de
  `Bash`), **F3** (enlaces duros, montajes y alias como `/proc/self/…`), **F5** (un enlace dentro del ámbito
  protegido que sale de la raíz, escrito por la ruta directa a su destino) y **F7** (que el `cwd` de la
  entrada sea el directorio del comando). ¿Acepta que queden declaradas fuera de la promesa?
- **Opciones:**
  - **(A) Aceptarlas declaradas.** Consecuencia: la propiedad se promete para la equivalencia por resolución
    de nombres (directorio de trabajo, `.`, `..`, barras repetidas y enlaces), que es lo que la autorización
    enumera, y lo demás queda escrito como no protegido en CA-47, en `AGENTS.md` §13 por remisión y en las
    notas.
  - **(B) Cubrir F5 en esta frontera.** Consecuencia: la puerta tendría que conocer los destinos de los
    enlaces que hay dentro del árbol protegido, lo que cuesta recorrerlo en cada llamada o un proceso por
    enlace; más alcance, más coste y otra vuelta de revisión.
  - **(C) Cubrir F3.** Consecuencia: detectar enlaces duros cuesta un proceso por destino y no alcanza a los
    montajes; los alias de plataforma dependen del proceso que escribe y el hook no los ve.
- **Recomendación del analista:** (A). Ninguna de las cuatro tiene un mecanismo sin procesos que la
  garantice, y F2 ya estaba declarada para `Bash` en `AGENTS.md` §13.
- **Qué impide (regla 2 de `AGENTS.md` §6):** **nada** de implementar ni de probar CA-45 a CA-50, CA-60 y
  CA-66, porque ninguna parte de la implementación depende de esta fila. Se presenta al propietario con las
  decisiones de publicación del candidato. **Evidencia:** CA-47, «Fronteras»; ADR-016, «Consecuencias».
  **Qué la resuelve:** la respuesta del propietario, registrada en `PENDING_APPROVAL.md` § Resueltas.

Por eso, y sólo por eso, este REQ sigue `en-progreso` con una pregunta abierta: la pregunta no toca nada de lo
que se implementa.
*(Anotado el 2026-10-01: la sexta autorización la mantiene pendiente y sin aceptación, y prohíbe usar una
aceptación de F7 para cubrir QA-023-09. CA-47, puntos 11 a 13, no se apoyan en F7 —el punto 12 existe
precisamente para no apoyarse en lo que el host haga con la ruta—, y el `cwd` tras un `cd` observado en la v3b
(CA-45, versionado del 2026-10-01) no la resuelve.)*
*(Anotado el 2026-10-02, octava autorización. R-046 §2 advirtió que esta pregunta no podía presentarse con el texto
anterior de F3, que no decía que dejaba pasar enlaces simbólicos corrientes bajo `/dev/` ni que apagaba CA-49 (i) en
un proyecto situado bajo `/dev/`. F3 está corregida en CA-47: ya **no** incluye los alias del proceso —`/proc/self/…`,
`/dev/fd/…`, que trata el punto 14— ni deja ningún prefijo fuera de la identificación; queda en enlaces duros y
montajes, con los límites declarados de la detección (F3 y punto 16). La opción (C) se lee sobre esa F3: «los alias de
plataforma dependen del proceso que escribe y el hook no los ve» ya no describe lo construido —el hook los detecta, y
lo que no puede determinar no pasa—. F2, F5 y F7, su texto y su falta de aceptación no cambian.)*
*(Anotado el 2026-10-03, novena autorización, fase 1 — SEC-123, `docs/seguridad/registro-seguridad.md` § R-047, §2.
R-047 advirtió que esta pregunta no puede presentarse sin cuatro datos del límite de F3: umbral, consecuencia,
profundidad de la raíz y alcance desde el host. Están en CA-47, F3, que es su sede, y en el punto 16. En resumen: el
límite empieza cuando la cadena sale de la entrada de `/proc` del propio hook, y se midió con cuatro, cinco y seis
subidas y la raíz a siete niveles; lo que no se ve se juzga por el archivo al que llega el hook y **puede ser un
permiso sobre un archivo protegido** —medido a nivel de hook, con el efecto en disco medido con un shell aparte, en
Linux/WSL2—; que haga falta la raíz a cinco o más niveles, y que desde el host sólo se alcance inyectando la entrada
o con un `cwd` que no ancla, es inferido; el host, la extensión de VS Code y Windows están sin comprobar. Para F3, la
opción (A) significaría por tanto aceptar declarado ese permiso, que contradice la propiedad de la octava
autorización; la (C) se lee sobre esta misma F3. Esta anotación no cambia la pregunta, las opciones ni la
recomendación —revisar la recomendación sería decidir sobre esta pregunta, y queda fuera de la fase 1—, y no
acepta, no repara ni mitiga el límite: SEC-123 sigue abierto y F3 sigue pendiente, aquí, sin aceptación.)*
*(Anotado el 2026-10-03, cierre de v1.35.0, tramo 3: la pregunta está resuelta como límites declarados —arriba—. El
párrafo «Por eso, y sólo por eso…» describe el REQ mientras la pregunta estuvo abierta y no se reescribe: desde esta
resolución, este REQ **no tiene ninguna pregunta abierta**, y su `Estado:` no cambia por ello —lo que lo mantiene
abierto está en su cabecera—.)*

**P-023-13-A (2026-10-02) — El retorno de carro del texto de un comando de `Bash`.** **RESUELTA por el
propietario el 2026-10-02 (octava autorización, `PENDING_APPROVAL.md` § Resueltas, commit `01b4a59`, punto 2): se
repara** —«corrige el transporte del CR en el texto de comandos Bash. Si el análisis no puede preservar su
significado, deniega explícitamente; nunca lo elimines silenciosamente para juzgar un comando distinto. No reescribas
el analizador general de Bash»—. La reparación está en CA-47, puntos 11 y 17, y sus casos en CA-66 (versionado de la
octava autorización). *Texto original, conservado:* una, y no impide implementar ni probar la reparación de
QA-023-13.
- **Pregunta para el propietario:** la séptima autorización exige que las puertas juzguen la ruta real de la
  operación o denieguen cuando no puedan determinarla, y pide no convertir la reparación en una reescritura
  general del analizador de `Bash`. La reparación cuenta el retorno de carro del `cwd`, del `file_path` y del
  `tool_name`, pero **no** el del texto del comando: un destino de `Bash` cuyo nombre acaba en un retorno de
  carro —al final del comando o antes de un salto— se juzga sin él, mientras el shell escribe el nombre con él.
  Medido a nivel de hook, una escritura de la coordinadora a código protegido por un enlace con ese nombre sale
  `allow` en el candidato y en los tres árboles anteriores, 1.33.2 incluido, y el shell escribe el archivo
  protegido (CA-47, punto 11, «Lo que este punto NO cubre»). ¿Cómo se trata?
- **Opciones:**
  - **(A) Declararlo fuera de la promesa, como límite del detector de `Bash`.** Consecuencia: queda escrito como
    no protegido en CA-47, punto 11, junto al límite ya declarado de que el detector lee el texto del comando
    (F2 y `AGENTS.md` §13), y la propiedad de la séptima autorización vale para el `cwd`, el `file_path` y el
    `tool_name`. Sin otra vuelta.
  - **(B) Repararlo.** Consecuencia: otra vuelta excepcional —el contador de REQ-023 está agotado— con
    desarrollador, QA y seguridad. La técnica del `cwd` —contar el retorno de carro antes del transporte y
    denegar con motivo lo que no se pueda determinar— parece aplicable en el punto de lectura sin procesos, pero
    no está diseñada ni medida, y sus falsos positivos sobre comandos con fines de línea CRLF tampoco.
  - **(C) Incorporarlo a P-119-A**, para decidirlo con las demás fronteras no nombradas.
- **Recomendación del analista:** (A) para este candidato, con el límite a la vista: el riesgo exige un nombre
  de archivo acabado en retorno de carro y un enlace, que es ofuscación deliberada (`AGENTS.md` §13); es
  preexistente; y la séptima autorización excluyó reescribir el analizador de `Bash`. Si el propietario quiere
  que la propiedad valga también para el texto del comando, (B). **Esta recomendación no acepta nada:** aceptar
  el límite es del propietario.
- **Qué impide (regla 2 de `AGENTS.md` §6):** **nada** de implementar ni de probar la reparación de QA-023-13,
  porque ninguna parte de ella depende de esta fila. Si impide **cerrar** o **publicar** no lo decide esta
  pregunta: lo deciden la clase que le den QA y seguridad y el propietario. **Evidencia:**
  `evidencia-dev-r7/14-sonda-command-cr-arbol-final.txt`, filas K1 y K2. **Qué la resuelve:** la respuesta del
  propietario, registrada en `PENDING_APPROVAL.md` § Resueltas.

*(Como P-119-A, esta pregunta no toca nada de lo que se implementa: el párrafo «Por eso, y sólo por eso…» de
arriba vale también para ella, y el REQ sigue con dos preguntas abiertas.)* *(Anotado el 2026-10-02, octava
autorización: P-023-13-A está resuelta; las abiertas son P-119-A y P-122-A, y el párrafo «Por eso, y sólo por eso…»
vale para las dos.)* *(Anotado tras la pasada correctiva, `befc17a`: P-122-A también está resuelta; la única abierta
es P-119-A.)*

**P-122-A (2026-10-02, octava autorización) — Dos movimientos de `deny` a `allow` de lo construido en `9220c71`
que el analista no sostiene con la propiedad de la autorización.** **RESUELTA por reparación (opción (A)) en la
pasada correctiva que prevé la octava autorización, código en `befc17a`:** QA midió los dos sobre `9220c71`
—(1) `git stash␍` lo corrige y ejecuta git con `help.autocorrect=immediate`; (2) es QA-023-17— (`docs/qa/REQ-023.md`
§ «Vuelta excepcional de la octava autorización», §5), y la pasada los devuelve a `deny`: C2, C10 y C11 de la sección
45 (CA-47, puntos 11 y 15; CA-66, versionado de la octava autorización). No hizo falta ninguna decisión del
propietario. *Texto original, conservado:* no impide implementar ni probar nada. Por CA-24 y por CA-66 (versionado de
la octava autorización, punto 5), los dos son hallazgo mientras no se reparen o se decidan.
- **Qué son:**
  - **(1) `git stash␍`** —un subcomando seguido de un retorno de carro—: `allow` en el candidato, `deny` en
    `9596e39`, 1.33.2 y `3bc7d3c` (`evidencia-dev-r8/02-`, fila G4; no está en el banco). Con su configuración por
    defecto git falla y no guarda nada (medido). Según la documentación de git, y **sin medir aquí**, con
    `help.autocorrect` configurado para ejecutar, git corrige el subcomando y ejecuta `git stash`; la puerta no lee
    esa configuración. La autorización manda denegar cuando el análisis no puede preservar el significado.
  - **(2) Identificado leyendo el código, sin medir:** por `Bash`, una escritura a través de un enlace del último
    componente situado **dentro** de un ámbito protegido que lleva a un descriptor se juzga fuera de todo ámbito
    antes de mirar las tres vías de pertenencia (`arnes_id_pertenece`), aunque por la vía (b) de CA-47, punto 6 —su
    lectura léxica— está en el ámbito, y para el destino de cualquier otro enlace esa vía sí cuenta. `9596e39` y
    1.33.2 lo deniegan por la ruta escrita, y `3bc7d3c` por la ubicación del enlace. La autorización pide conservar
    las comprobaciones de enlaces, y la lista de vías de CA-47, punto 6, es cerrada.
- **Pregunta:** ¿se reparan dentro de la pasada correctiva que la octava autorización ya prevé, o se declaran como
  movimientos con su límite escrito?
- **Opciones:**
  - **(A) Repararlos en la pasada correctiva**, por la propiedad de la autorización: denegar con motivo cuando el
    significado del comando para git no queda determinado, y evaluar las tres vías de CA-47, punto 6, también
    cuando el destino de un enlace es un descriptor. La técnica es del desarrollador. Consecuencia: los dos
    vuelven a `deny` y no hay movimiento frente a lo publicado; cuesta la pasada y su re-verificación de QA.
  - **(B) Declararlos como movimientos, con su límite escrito.** Consecuencia: se acepta un `allow` cuya seguridad
    depende de una configuración de git que la puerta no lee, y una excepción a la lista cerrada de vías de CA-47,
    punto 6. Reduce una protección frente a lo publicado, así que sólo lo decide el propietario.
  - **(C) Medir antes el segundo** y decidir después: si no se reproduce, sale de esta pregunta.
- **Recomendación del analista:** (A) para el primero; (C) para el segundo y, si se reproduce, (A). **Esta
  recomendación no acepta nada.**
- **Qué impide (regla 2 de `AGENTS.md` §6):** nada de implementar ni de probar. Si impiden cerrar o publicar lo
  deciden su clase, cuando QA o seguridad los registren, y quien firme. **Evidencia:** `evidencia-dev-r8/02-`, fila
  G4; `hooks/lib.sh` de `9220c71`, `arnes_id_pertenece` y `_arnes_id_resuelve_enlace`. **Qué la resuelve:** la pasada
  correctiva con su re-verificación de QA, que despacha la coordinadora dentro de la octava autorización, o, para (B),
  una decisión del propietario registrada en `PENDING_APPROVAL.md` § Resueltas.

**P-LC10-A (2026-10-03, novena autorización, caso (b)) — La continuación de línea al final de la línea que abre un
heredoc (CA-66, versionado de la fase 2, fila LC10).** **RESUELTA por el propietario el 2026-10-03, tras `598792c`:
opción (A)** —`PENDING_APPROVAL.md` § Resueltas, entrada de la novena autorización, viñeta «Decisiones del
propietario, 2026-10-03, posteriores a `598792c` (literales)», decisión 1: «P-LC10-A: opción A. La forma de LC10
(continuación de línea al final de la línea que abre un heredoc) se deniega por la forma, a todo agente, en las
cuatro puertas, igual que SEC-124. Acepto que eso restrinja un uso legítimo raro. No se emula la unión de líneas del
shell (B rechazada); no se deja QA-023-23 abierto en esta forma (C rechazada)»—. La regla está en CA-47, punto 19,
«Excepción nombrada», y sus casos en CA-66 (fase 2), LC10 a LC10.c2. **Precisión del analista, rotulada como suya:**
la redacción de la opción (A), abajo, daba a esta forma los destinatarios del punto 18 —`guard-codigo` sólo a quien
no es el agente de código, y `guard-git` sin juzgarla—; la decisión dice «a todo agente, en las cuatro puertas», y
el contrato sigue la decisión: `guard-codigo` la deniega también al `desarrollador`, y `guard-git` aunque no haya
orden de git. Ninguna de las dos cosas abre: sólo añaden denegaciones. *Texto original, conservado como historia:*
una. Es un conflicto **dentro de lo vigente** —entre viñetas
del punto 19 de CA-47 y entre éste y la decisión sobre SEC-124—, no con otro REQ.
- **Por qué no la resuelven los puntos 18 y 19 ni la decisión sobre SEC-124:**
  - el punto 19 sólo promete la continuación **entre una escritura y su destino**; «una continuación en otra
    posición» está en «Lo que este punto no promete», y lo que sostenía no prometerla —que R-047 §4 midió esos
    controles en `deny`— no se ha medido en la línea que abre un heredoc, donde el analizador de `3f96e6b` lee la
    línea siguiente como cuerpo (lectura del analista, sin medir);
  - cuando la línea siguiente cierra el heredoc para el analizador, plegar **retrasaría ese cierre**, que la viñeta
    «no mueve las fronteras» prohíbe, y no plegar decide distinto de la orden escrita en una línea, que la viñeta
    «no hay `deny` por la mera presencia» pide decidir igual;
  - denegar la forma entera por su estructura, como SEC-124, deniega también al `desarrollador`, lo inocuo y lo de
    fuera del ámbito, que esa misma viñeta pide permitir; y la restricción que el propietario aceptó para SEC-124
    es «concreta de ese caso» (P4; CA-47, punto 18, «Qué es y qué no es»), no de éste;
  - una orden de git en la línea siguiente la juzga `guard-git`, cuyo pliegue es de REQ-005 CA-40 y CA-41, fuera
    de los puntos 18 y 19.
- **Pregunta para el propietario:** ¿cómo deciden las puertas esta forma, más allá de lo que LC10 ya fija?
- **Opciones** (todas conservan lo «ya fijado» de LC10):
  - **(A) Por la forma, a todo agente, como SEC-124.** La línea que abre un heredoc de delimitador limpio y acaba
    en una continuación —la del shell— se deniega sin juzgar lo que sigue, con los destinatarios del punto 18
    (`guard-codigo` a quien no es el agente de código, `guard-completado` a todo agente; por `guard.sh`, a todo
    agente; `guard-git` sola no la juzga, como en HC5) y un motivo propio con su causa y la salida —escribir esa
    línea entera, sin la continuación al final—, sin nombrar herramientas y sin interpolar sin tope. Consecuencia:
    cubre todas las posiciones y la orden de git sin plegar en la frontera del heredoc ni mover ninguna; deniega
    uso legítimo, también al `desarrollador`; exige escribir en el punto 19 una excepción a «no hay `deny` por la
    mera presencia», que es cambio de criterio fuera de esta autorización, y la aceptación expresa de esa
    restricción; el identificador del motivo no existe aún.
  - **(B) Como la lee el shell.** El analizador une esa línea con la siguiente y el cuerpo empieza después.
    Consecuencia: coherente con las viñetas «no hay `deny` por la mera presencia» y «en la otra dirección»; pero
    promete posiciones que el punto 19 no promete (ampliarlo es cambio de criterio), necesita una regla propia
    para la línea siguiente que cierra el heredoc para el analizador —donde plegar está prohibido—, y para una
    orden de git, una decisión sobre REQ-005 CA-40 y CA-41; es la frontera donde un pliegue nuevo puede abrir.
  - **(C) Sólo lo que el punto 19 ya fija; el resto, declarado sin promesa,** y la viñeta «no mueve las fronteras»
    prevalece donde choca. Consecuencia: no cambia ningún criterio; si QA mide en `allow` una escritura protegida o
    una orden de git en la línea siguiente, queda abierta y la registra seguridad con su clase.
- **Recomendación del analista:** (A): es la clase de SEC-124 —el analizador y el shell discrepan sobre una frontera
  del heredoc— y el propietario eligió para ella la forma frente a la reinterpretación; es una regla sin procesos que
  no mueve ninguna frontera; y su coste legítimo tiene salida directa. **Esta recomendación no acepta nada.**
- **Qué impide (regla 2 de `AGENTS.md` §6):** **implementar** la parte de LC10 que depende de esta decisión —todo lo
  que la fila marca «Pendiente»— (regla 1 de `AGENTS.md` §6: una diferencia que requiere al propietario no se
  implementa mientras no la resuelva); a la parte de la entrega afectada, sólo LC10. **No impide** probar: QA mide
  LC10 sobre el código vigente, como autoriza el propietario, y contrasta lo «ya fijado». **Evidencia:** CA-47,
  puntos 18 y 19; CA-66 (fase 2), LC10; `docs/qa/REQ-023.md` § «Novena autorización, fase 2: mediciones de las
  lecturas (a) y (b) del analista» (la lectura (b), sin caso y sin medir). **Qué la resuelve:** la respuesta del
  propietario en `PENDING_APPROVAL.md` § Resueltas y, con (A) o (B), la autorización del cambio de criterio que
  conlleva.
- Con ésta, las preguntas abiertas de este REQ son P-119-A y P-LC10-A; la anotación de P-023-13-A («la única abierta
  es P-119-A») describe `befc17a` y no se reescribe.
- *(Anotado el 2026-10-03, tras `598792c`: P-LC10-A está resuelta (A); ya no impide implementar ninguna parte de
  LC10. La única pregunta abierta de este REQ vuelve a ser P-119-A.)*
- *(Anotado el 2026-10-03, cierre de v1.35.0, tramo 3: P-119-A está resuelta como límites declarados. Este REQ ya no
  tiene preguntas abiertas; las anotaciones anteriores describen su fecha y no se reescriben.)*

**REQ-001** — no hay conflicto: aquél declara estos dos huecos explícitamente **fuera de alcance** y
los traslada aquí. Sí hay una **dependencia de orden**: cuando este REQ se implemente, CA-14 y CA-45
de REQ-001 —el `Edit` y el `Write` sobre un REQ que en disco **ya** estaba en el estado terminal—
deben seguir en ALLOW. Ampliar el reconocimiento de la **clave** hace que más documentos se lean como
terminales; no convierte en transición lo que no lo era.
*(Anotado el 2026-09-30, versionado de CA-45: sigue sin haber conflicto. CA-14 y CA-45 de REQ-001, y su CA-12,
presuponen un REQ que la puerta lee entero y una ruta que resuelve; si el REQ no se puede leer, o la ruta no se
puede determinar, rige CA-45 de este REQ, que no conoce el estado anterior. REQ-001 no se versiona por esto.)*

**REQ-001, Bloque G** — no hay conflicto, y hay **dos dependencias de orden**. (1) **CA-34 comparte
raíz con el hallazgo QA-007 de REQ-001**: los dos son el mismo bucle cuadrático, uno dentro de una
línea de heredoc y otro en el camino común de comillas. Si REQ-001 lo corrige en 1.30.3, CA-34 puede
quedar satisfecho **por herencia**, y entonces se verifica **midiendo**, no suponiendo: si al abrir
1.31.0 el eje ya cumple < 5 s, CA-34 se marca cumplido con su medida y su fecha, y su caso del banco
se conserva como **no-regresión**. Lo que no se admite es darlo por cerrado sin la cifra. (2) **CA-36,
CA-38 y CA-39 tocan el mismo detector de heredocs que REQ-001 arregló**: los casos CA-16 a CA-27 y
CA-46 a CA-49 de REQ-001 deben seguir con **el mismo veredicto** después de este REQ, y CA-24 de este
REQ ya lo exige en general (ningún caso pasa de `deny` a `allow`).

**REQ-003** — no hay conflicto, y hay superficie compartida: aquél exige **un solo lector y un solo
vocabulario** entre la puerta y `tools/arnes-lectura.sh`; este REQ añade la normalización de la
**clave** y CA-22 exige que los dos la apliquen igual. Si se implementan en la misma versión, la
normalización de la clave debe vivir en el mismo sitio único que el vocabulario, no en una segunda
transcripción. Dos transcripciones de la misma regla se desfasan: es el defecto que REQ-003 viene a
cerrar.

**REQ-005** — no hay conflicto: `guard-git` comparte con el detector de escrituras el **mismo**
descuento de comillas y heredocs, así que los cambios de los Bloques C y G lo alcanzan sin tocarlo —
y también le llega el hueco de CA-38: un `git commit -m "… <<EOF"` seguido de un `git clean -fd`
cegaría hoy a `guard-git` por la misma vía. Nota para
el desarrollador, no contradicción: un `git clean -fd "src"` con argumentos entrecomillados debe
seguir denegándose, y el reconocimiento del subcomando de REQ-005 no puede depender de que los
argumentos vengan desnudos.

**REQ-005, tras la auditoría R-002 (anotado el 2026-09-06) — superficie compartida en el modo
degradado, sin contradicción.** El estado «manifiesto ilegible» es hoy el mismo para los tres
criterios y hay que leerlos juntos: **CA-60** de este REQ permite la **única** escritura que repara;
**CA-63.2 y CA-63.3** exigen que esa avería se **vea** y que se declare qué queda sin gobernar; y
**REQ-005 CA-42** dice qué hace `guard-git` mientras dura —denegar con la **lista por defecto del
código**—. La lista de CA-63.3 **cita** a REQ-005 CA-42 en vez de repetir su contenido, a propósito:
dos transcripciones de la misma regla se desfasan, que es el defecto que REQ-003 vino a cerrar. Si
REQ-005 cambia lo que hace la puerta de git en modo degradado, la lista de CA-63.3 se actualiza en
**ese mismo** cambio, con su fila de Historial.

**REQ-006** — no hay conflicto: aquél sólo recorta celdas al **componer** el bloque derivado, después
de la normalización; éste cambia la normalización. El recorte sigue sin llegar a ningún lector. Si
REQ-006 aterriza antes, sus CA-01 a CA-08 se re-corren como no-regresión sobre cabeceras decoradas.

**REQ-009** — no hay conflicto y hay una **superficie compartida provechosa**: CA-45/CA-46 de este REQ
cierran la lectura del disco truncada por un NUL en el archivo del **REQ**, y CA-15/CA-16 de REQ-009
hacen lo propio con el archivo de la **cola de aprobaciones**. La forma de lectura que se elija aquí
—una que no se detenga en el NUL, o el rechazo declarado— es la que REQ-009 **reutiliza**: no se
escribe una segunda. Por eso este REQ va **antes** que REQ-009.
*(Anotado el 2026-09-30: el versionado de CA-45 no cambia la conducta de la forma de leer que REQ-009
reutiliza —`arnes_lee_archivo`—, sino lo que la puerta de cierre hace con un REQ que no puede leer. REQ-009 no
queda afectado.)*

**Orden recomendado dentro de 1.31.0 para este REQ (anotado por el analista el 2026-09-05):
REQ-003 → REQ-005 → REQ-007 → REQ-009.**
- **Después de REQ-003**, porque aquél crea el **sitio único** de `hooks/lib.sh` donde tienen que
  vivir la normalización de la clave (Bloque A) y la lectura de la clase del hallazgo (CA-40, CA-41):
  escribirlas antes obligaría a moverlas, y una segunda transcripción es exactamente el defecto que
  REQ-003 cierra. Con REQ-003 ya dentro, se verifican **después** de él: **CA-22** (el informe lee lo
  que lee la puerta), **CA-21** (57 REQ con cabeceras decoradas, < 5 s y sin proceso por REQ),
  **CA-09** (rigor efectivo desde la clave decorada), **CA-40 y CA-41** (clase con evidencia detrás) y
  los controles **CA-05, CA-06, CA-12 y CA-13**.
- **Después de REQ-005**, porque `guard-git` se escribe sobre el descuento de comillas y heredocs
  **actual**; los Bloques C y G lo cambian, y con el banco de REQ-005 ya en verde cualquier rotura se
  atribuye sin ambigüedad a este REQ. Invariante que hay que conservar: `git clean -fd "src"` sigue en
  DENY (la nota de arriba).
- **CA-53 (SEC-006, parte a): el gate humano se abrió y ya está resuelto (2026-09-05).** Exigía la
  aprobación de `AGENTS.md` §6 sobre `.arnes/config.json`; se escribió en `PENDING_APPROVAL.md`, el
  pipeline se detuvo y la coordinadora lo resolvió **por delegación permanente del propietario** como
  **opción B ampliada** (`.arnes/config.json` + `.claude-plugin/*`; **no** `.arnes/` entero). La
  entrada está bajo `## Resueltas` y `## Pendientes` quedó **vacía**, así que la consecuencia de
  calendario que aquí se anotaba —mientras la cola tuviera esa entrada, ningún REQ de 1.31.0 podía
  marcarse `completado`— **ya no aplica**. Sigue vigente quién lo aplica: **el `desarrollador`**, no
  la coordinadora, y con él el coste aceptado del bump de `arnes_version`.

