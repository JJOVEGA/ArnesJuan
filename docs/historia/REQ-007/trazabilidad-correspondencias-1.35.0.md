# REQ-007 — historia: Correspondencia con el encargo, los seis versionados de 1.35.0

> **Movido desde `requirements/REQ-007.md` el 2026-10-12** por la undécima autorización del propietario
> (ficha **F-136-17**), cabeza de origen **`cecf9b6`**, líneas **4219–4418** (200 líneas, 36 467 bytes medidos).
> **Copia verbatim: no se resumió, no se reordenó y no se corrigió nada.**
> Índice: `docs/historia/REQ-007/README.md`. Contrato: `docs/arnes/v1.37.0-f136-17-fase1.md`.
> Comprobación de que no se perdió ninguna línea: ese contrato, §5, y el índice.

### Correspondencia con el encargo (versionado del 2026-09-30)

Pedido: la quinta autorización, literal. Autorización de todas las filas: `PENDING_APPROVAL.md` § Resueltas,
«RESUELTA (propietario, 2026-09-30, quinta autorización)», commit `1ebe1c1`, en el punto que indica cada fila.
Las obligaciones que son de la coordinadora (base y contexto, commits, CI, entrega) no dan fila: no son
contrato de este REQ.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «las rutas equivalentes que apuntan al mismo archivo protegido no pueden recibir permisos distintos por su escritura» | CA-47 (la promesa, para la equivalencia por resolución de nombres que el punto 2 enumera; lo que queda fuera está en la fila de las fronteras), CA-48, CA-49, CA-66 | cubierta | quinta autorización, punto 2 |
| «Reutiliza las reproducciones existentes de `..`, `././` y directorios enlazados» | CA-66 (I3, I4, I9, I10) | cubierta | ídem |
| «Distingue: lo que recibe realmente el hook desde el host. Lo que sólo se ha inyectado directamente al hook. La ruta utilizada finalmente por la herramienta.» | CA-47 («Medido en el host real»); CA-66, columna «Host» y punto 6 | cubierta | ídem |
| «Implementa una resolución de rutas coherente para `guard-completado` y `guard-codigo`, conforme a sus contratos.» | CA-47 (una sola regla, en un solo sitio, para las dos) | cubierta | ídem |
| «No basta con borrar segmentos del texto: considera el directorio de trabajo y los enlaces simbólicos.» | CA-47, puntos 1, 2 y 6; CA-49 | cubierta | ídem |
| «Preserva las operaciones legítimas fuera del ámbito protegido.» | CA-48 (d) y (f); CA-66, L1–L8 | cubierta | ídem |
| «Contempla archivos nuevos mediante su directorio padre existente» | CA-47, punto 2; CA-45 (i); CA-48 (e); CA-66, K1–K3 | cubierta | ídem |
| «sin confundir «todavía no existe» con «no se pudo determinar el destino».» | CA-47, puntos 7 y 8; CA-66, D1–D4 | cubierta | ídem |
| «No prometas resolver carreras de enlaces o cambios concurrentes si no existe un mecanismo que lo garantice; declara esa frontera.» | CA-47, F1; CA-45; CA-49 | cubierta | ídem |
| Fronteras que la autorización no nombra: F2 (`cd` dentro del comando, expansiones), F3 (enlaces duros, montajes, alias de plataforma), F5 (enlace dentro del ámbito que sale de la raíz, por la ruta directa) y F7 (el `cwd` de la entrada) | CA-47, «Fronteras» | excluida | → Preguntas abiertas, **P-119-A** (no impide implementar ni probar). *(2026-10-03: resuelta por el propietario como límites declarados, abiertos y no aceptados como riesgo; `PENDING_APPROVAL.md` § Resueltas, «Decisiones de publicación de v1.35.0», decisión 5, y «Cierre de v1.35.0, tramo 3», decisión 1)* |
| «Distingue archivo inexistente, archivo existente pero ilegible y error al resolver la ruta.» | CA-45 (i), (ii) y (iii) | cubierta | quinta autorización, punto 3 |
| «Para una operación dentro del ámbito protegido, no poder leer o reconstruir lo necesario para juzgarla no puede convertirse en permiso silencioso.» | CA-45 (ii) y (iii); CA-46 (b), (d) y (e); CA-47, punto 7 (el `Write` que cierra con todo en verde se permite porque se juzga entero: movimiento declarado en CA-66, punto 5) | cubierta | ídem |
| «No supongas que, porque el hook no puede leer, la herramienta tampoco podrá escribir. Comprueba esa relación donde sea reproducible; si no lo es, declara el límite.» | CA-45 (párrafo «No se supone…»); CA-66, punto 6 | cubierta | ídem |
| «El mensaje debe indicar la causa y cómo corregirla, sin recomendar otra herramienta para eludir la puerta.» | CA-45 («El motivo»); CA-47, punto 7; CA-49 (i) | cubierta | ídem |
| «Inclúyelo [SEC-120] en esta reparación sólo si comparte directamente la causa… Si es independiente, consérvalo pendiente y no abras su reparación.» | — | excluida | quinta autorización, punto 4; determinación de la coordinadora en la entrada de `CHANGELOG.md` de `1ebe1c1` |
| «Autorizo al analista a versionar los criterios existentes directamente afectados, con ADR si corresponde, y a reabrir los requisitos que lo exijan.» | CA-45 a CA-50, nota de CA-58, CA-60; REQ-023 CA-13 (iv); ADR-016. Ningún REQ `completado` queda afectado (Historial) | cubierta | quinta autorización, punto 4 |
| «No conserves una expectativa de allow basada en una premisa desmentida.» | CA-46 (b); CA-50 (c); CA-66, punto 4 | cubierta | ídem |
| «Registra el cambio de compatibilidad» | CA-66, punto 7; ADR-016; notas `[1.35.0]`; guía «Hacia 1.35.0» | cubierta | ídem |
| «y no cierres requisitos automáticamente.» | Historial del 2026-09-30 (sin tocar `Estado:` ni veredictos) | cubierta | ídem |
| «No crees otro REQ para eludir contadores.» | Bloque K (se versiona este REQ; ningún contador se reinicia) | cubierta | ídem |
| «Antes de despachar, deja identificados los criterios, archivos y pruebas afectados» | «Notas / alcance», «Sedes y pruebas del versionado del 2026-09-30»; `Archivos:` | cubierta | ídem |
| «Prueba al menos: …» (los seis casos) | CA-66, punto 3 | cubierta | quinta autorización, punto 5 |
| «Comprueba en el host real los casos alcanzables mediante sus herramientas, con control de denegación y verificación del archivo final. Separa esas pruebas de las realizadas sólo a nivel de hook. No atribuyas cobertura a Windows, MultiEdit u otros hosts no ejercidos.» | CA-66, punto 6; CA-47, F4 y F6 | cubierta | ídem |
| «Adapta los fixtures afectados para que cada prueba siga llegando al control que pretende medir. No cambies expectativas indiscriminadamente a deny ni retires casos para obtener verde.» | CA-66, punto 4 | cubierta | ídem |
| «Actualiza notas, guía y comentarios únicamente para describir fielmente esta reparación, su compatibilidad y sus límites.» | «Sedes y pruebas del versionado del 2026-09-30» (comentarios); notas `[1.35.0]`; guía «Hacia 1.35.0» | cubierta | quinta autorización, punto 6 |

### Correspondencia con el encargo (versionado del 2026-10-01)

Pedido: la sexta autorización, literal. Autorización de todas las filas: `PENDING_APPROVAL.md` § Resueltas,
«RESUELTA (propietario, 2026-10-01, sexta autorización)», commit `fb6eaab`, en el punto que indica cada fila. Las
obligaciones de la coordinadora y del desarrollador que no son contrato de este REQ —verificar la base, commits,
push, CI, medir, detener la optimización y presentar sus cifras, la entrega— no dan fila.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «Corrige la extracción de los datos para que un salto de línea dentro de `cwd` no desplace campos ni cambie la ruta que juzgan las puertas.» | CA-47, punto 11; CA-66 (versionado del 2026-10-01), E1–E4 | cubierta | sexta autorización, punto 2 |
| «La solución debe preservar los límites entre campos del formato de entrada» | CA-47, punto 11 (límites fijados por el formato, para todos los campos que lee `arnes_parse_input`); CA-66, E5 y P1 | cubierta | ídem |
| «no basta con prohibir el nombre ensayado o sustituir caracteres silenciosamente.» | CA-47, punto 11 (un `cwd` con saltos se admite; nada se retira ni se sustituye); puntos 12 y 13 deniegan con motivo, no sustituyen | cubierta | ídem |
| «Añade pruebas que fallen con la reparación defectuosa y pasen después.» | CA-66 (versionado del 2026-10-01), punto 1 (fail-before contra `43b948a`) y punto 3 | cubierta | ídem |
| «Comprueba ambas puertas, la ruta realmente juzgada y el efecto en disco.» | CA-66, punto 3 (E1 y E2 en las dos puertas y por `guard.sh`; el motivo cita la ruta canónica) y punto 6 (el efecto en disco, en el host) | cubierta | ídem |
| «Incluye un control legítimo.» | CA-66, G1 y G2; punto 6, control legítimo con el mismo `cwd` | cubierta | ídem |
| «Reutiliza el caso del host real.» | CA-66, punto 6 (`cwd-nl` y `cwd-nl-ctl` de la v3b, con el hook reparado) | cubierta | ídem |
| «No presentes su denegación anterior por ruta irresoluble como protección acreditada» | CA-47, punto 11 («Medido en el host antes de la reparación»); CA-66, punto 6 | cubierta | ídem |
| «ni extiendas las conclusiones a hosts no ensayados.» | CA-47, punto 11; CA-66, punto 6 | cubierta | ídem |
| «conservando: Techo de menos de 5 segundos. Valor por defecto y máximo admitido. Cobertura de seguridad y decisiones del control.» | CA-54, nota del 2026-10-01 (umbral, defecto y máximo sin cambio; decisiones idénticas) | cubierta | sexta autorización, punto 3 |
| «No subas el techo, reduzcas límites admitidos, omitas comprobaciones ni cambies el procedimiento de medición para obtener un PASS.» | CA-54, nota del 2026-10-01 (la regla «el máximo baja hasta que cumpla» no se aplica en esta vuelta) | cubierta | ídem |
| «El analista incorpora en CA-45 la evidencia ya obtenida: El cwd recibido por el hook sigue al cd observado.» | CA-45, versionado del 2026-10-01, (i); CA-66, punto 6 | cubierta | sexta autorización, punto 4 |
| «El caso de archivo ilegible falló antes de llegar al hook.» | CA-45, versionado del 2026-10-01, (ii) | cubierta | ídem |
| «Declara ese segundo caso como límite de la comprobación en el host.» | CA-45, (ii); CA-66, punto 6 | cubierta | ídem |
| «No lo conviertas en prueba de denegación del hook ni repitas el experimento sin una pregunta nueva imprescindible.» | CA-45, (ii) | cubierta | ídem |
| «Los ajustes internos necesarios para resolver estos tres hallazgos están autorizados. Sólo exige otra decisión un cambio de alcance, contrato o cobertura que exceda expresamente estos límites.» | CA-47, puntos 12 y 13: sólo mueven casos de `allow` a `deny` y no reducen ninguna cobertura (CA-66, punto 5). La alternativa que la reducía —declarar como movimientos de `deny` a `allow` los casos del `file_path` y del `tool_name` con salto— se descarta (Historial) | cubierta | sexta autorización, punto 5 |
| «Ficha 1 (SEC-115/SEC-118), ficha 2 (hueco C) y P-119-A siguen pendientes y sin aceptación. No uses una aceptación de F7 para cubrir QA-023-09.» | CA-47, punto 12 (no se apoya en F7); P-119-A sin cambio («Preguntas abiertas», nota del 2026-10-01) | cubierta | sexta autorización, cierre |
| «No retirar la reparación ni abrir mejoras independientes.» | CA-45 a CA-50 se conservan; el punto 13 cierra `Edit␊` (T1) sólo como efecto de su regla, declarado en CA-66, punto 5 | cubierta | sexta autorización, objetivo |
| «Conserva los contadores y registra esta excepción sin reiniciarlos.» | CA-66, versionado del 2026-10-01; Historial | cubierta | sexta autorización, preámbulo |
| «Sin fusión, cierre automático de requisitos» | Historial (sin tocar `Estado:`, veredictos ni `Hallazgos abiertos:`) | cubierta | sexta autorización, cierre |

### Correspondencia con el encargo (versionado del 2026-10-02)

Pedido: la séptima autorización, literal. Autorización de todas las filas: `PENDING_APPROVAL.md` § Resueltas,
«RESUELTA (propietario, 2026-10-02, séptima autorización)», commit `3128d09`, en el punto que indica cada fila.
Las obligaciones de la coordinadora y del desarrollador que no son contrato de este REQ —comprobar la base,
conservar los cambios preexistentes, no recuperar la optimización, no repetir hasta obtener verde, preparar la
decisión de QA-023-10, commits, push, CI y la entrega— no dan fila.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «Corrige el tratamiento del `cwd` con retorno de carro antes de que cualquier lectura o normalización pueda recortarlo.» | CA-47, punto 11 (la cuenta sobre el valor crudo, antes del transporte); CA-66 (versionado del 2026-10-02), R1–R5 y P2 | cubierta | séptima autorización, punto 2 |
| «las puertas deben juzgar la ruta real de la operación o denegar explícitamente cuando no puedan determinarla; nunca juzgar otra ruta por haber modificado silenciosamente el directorio recibido», para el `cwd`, el `file_path` y el `tool_name` | CA-47, puntos 1, 7, 11, 12 y 13; CA-66, R, RF y RT | cubierta | ídem |
| La misma propiedad, para el texto del comando de `Bash` (su retorno de carro de transporte: CA-47, punto 11, «Lo que este punto NO cubre») | — (declarado como límite, sin promesa) | excluida | → Preguntas abiertas, **P-023-13-A** |
| «Autorizo denegar un `cwd` que contenga CR con un motivo preciso.» | CA-47, puntos 7 y 11 (la ruta relativa que depende de él es no determinable, con su motivo; lo que no depende de él se juzga) | cubierta | ídem |
| «Conserva el tratamiento ya validado de LF» | CA-47, punto 11 (un `cwd` con saltos de línea y sin retorno de carro ancla); CA-66, punto 4 (las 167 filas anteriores sin cambio) | cubierta | ídem |
| «y las denegaciones de `file_path` y nombre de herramienta que quedaron registradas en la vuelta anterior.» | CA-47, puntos 12 y 13, conservados | cubierta | ídem |
| «Revisa los puntos de lectura y transporte de estos campos directamente relacionados con el defecto.» | CA-47, puntos 11, 12 y 13 (el mismo transporte en el `file_path` y el `tool_name`); CA-66, RF y RT | cubierta | ídem |
| «No conviertas esto en una reescritura general del analizador de Bash.» | CA-47, punto 11 (el texto de `Bash` conserva su transporte) | cubierta | ídem |
| «El caso de QA-023-13 antes y después, tanto para `guard-completado` como para `guard-codigo`.» | CA-66 (versionado del 2026-10-02), puntos 1 y 3: R1 (`guard-codigo`), R2 y R3 (`guard-completado`), con fail-before contra `cd6afa6` | cubierta | séptima autorización, punto 3 |
| «Que siguen conformes los casos de LF de QA-023-09 y las reparaciones de SEC-117 y SEC-119 afectadas por este cambio.» | CA-66, punto 4 (sin cambio de expectativa) y punto 8 de arriba (el banco completo en verde) | cubierta | ídem |
| «Una operación legítima, verificando la decisión y el archivo resultante.» | CA-66, RC y RS (la decisión, a nivel de hook); punto 6 (el efecto en disco, en el host: no ejecutado en esta vuelta) | cubierta | ídem |
| «El caso CR en el host real, si el host permite construirlo. Si no, registra el impedimento y distingue expresamente la prueba directa del hook de la prueba del host.» | CA-66 (versionado del 2026-10-02), punto 6 (no ejecutado; sólo a nivel de hook). Registrar el impedimento es de la coordinadora | cubierta | ídem |
| «Conserva el hallazgo y el criterio de menos de 5 segundos.» | CA-54 sin cambio; `Hallazgos abiertos:` sin tocar | cubierta | séptima autorización, punto 4 |
| «El analista actualiza únicamente las sedes afectadas.» | Historial (2026-10-02) | cubierta | séptima autorización, punto 5 |
| «sin reiniciar contadores» | CA-66, versionado del 2026-10-02; Historial | cubierta | séptima autorización, preámbulo |
| «Esta autorización no acepta SEC-115, SEC-118, el hueco C ni P-119-A; tampoco autoriza fusionar, cerrar requisitos…» | P-119-A sin cambio; Historial (sin tocar `Estado:`, veredictos ni `Hallazgos abiertos:`) | cubierta | séptima autorización, cierre |

### Correspondencia con el encargo (versionado del 2026-10-02, octava autorización)

Pedido: la octava autorización, literal. Autorización de todas las filas: `PENDING_APPROVAL.md` § Resueltas,
«RESUELTA (propietario, 2026-10-02, octava autorización)», commit `01b4a59`, en el punto que indica cada fila. Las
obligaciones de la coordinadora, del desarrollador y de QA que no son contrato de este REQ —comprobar la base,
conservar los cambios preexistentes y las corridas, no recuperar la optimización de CA-54, el procedimiento de las
mediciones, repetir sólo lo necesario, commits, push, CI y la entrega— no dan fila.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «SEC-122: elimina la exclusión indiscriminada de `/dev/` y `/proc/`.» | CA-47, F3 (corregida); CA-66 (octava autorización), S1–S5 y B1–B5 | cubierta | octava autorización, punto 2 |
| «Los destinos resolubles por nombres deben pasar por la identificación y las reglas de protección correspondientes, conservando las comprobaciones de existencia y enlaces.» | CA-47, F3 y puntos 2, 6 y 8; CA-49 (i) y (ii); CA-66, S y B | cubierta | ídem |
| La misma obligación, para un enlace situado dentro de un ámbito protegido que lleva a un descriptor (QA-023-17, que era P-122-A (2)) | CA-47, punto 15; CA-66 (octava autorización), C10–C13. *(Era `omitida`, → P-122-A, hasta la pasada correctiva, `befc17a`.)* | cubierta | ídem |
| «Una identidad dependiente del proceso que no pueda determinarse de forma fiable no recibe permiso por esa incertidumbre.» | CA-47, puntos 7, 14 y 16; CA-66, P3, P6, P7 y P9 | cubierta | ídem |
| «Conserva los usos legítimos previstos de `/dev/null` y `/dev/stderr` sin convertir sus nombres en una excepción general.» | CA-47, punto 15 (por `Bash`, el descriptor se detecta, no se nombra); CA-66, N1–N6. `Write /dev/stderr` por el host, que no es una redirección del shell, pasa a `deny` y está declarado entre lo legítimo que se deniega (CA-66, punto 5) | cubierta | ídem |
| «QA-023-14: elimina la sustitución superlineal introducida en `_arnes_repone_cr`.» | CA-47, punto 11 (coste de la lectura); CA-66, Q1 | cubierta | ídem |
| «Puedes usar la detección en la lectura con `jq` propuesta, conservando íntegros los valores y las decisiones de protección.» | CA-47, punto 11 (la primera línea delata el transporte; cada campo llega con sus retornos de carro; la cuenta decide); CA-66, Q1–Q3 | cubierta | ídem |
| «No sustituyas este coste por otra pasada superlineal.» | CA-47, punto 11 (ninguna pasada sobre el valor de un campo; propiedad estructural) | cubierta | ídem |
| «P-023-13-A: corrige el transporte del CR en el texto de comandos Bash.» | CA-47, punto 11; CA-66, K1–K8 | cubierta | ídem |
| «Si el análisis no puede preservar su significado, deniega explícitamente; nunca lo elimines silenciosamente para juzgar un comando distinto.» | CA-47, puntos 11 y 17; CA-66, H1–H6 y G1–G3 | cubierta | ídem |
| La misma obligación, para una orden de git con un retorno de carro pegado (`git stash␍`, P-122-A (1); y las órdenes de QA-023-16) | CA-47, punto 11 (las dos lecturas de `guard-git`); CA-66 (octava autorización), C1–C9. *(Era `omitida`, → P-122-A, hasta la pasada correctiva, `befc17a`.)* | cubierta | ídem |
| «No reescribas el analizador general de Bash.» | CA-47, punto 17 (se deniega donde el analizador no sigue el retorno de carro, sin reescribirlo) | cubierta | ídem |
| «Contrato: el analista actualiza F3, CA-49, CA-66 punto 5 y las sedes directamente afectadas.» | CA-47 (F3, la frase de las fronteras, puntos 7, 11, 12 y 14 a 17); CA-49; nota de CA-24; CA-66 (octava autorización); Preguntas abiertas; ADR-016, adenda; notas `[1.35.0]`; guía «Hacia 1.35.0» | cubierta | ídem |
| «F3 no debe desactivar las reglas de existencia, enlaces ni protección de destinos resolubles.» | CA-47, F3 | cubierta | ídem |
| «Conserva el historial y declara los cambios de compatibilidad.» | Historial (2026-10-02, octava autorización); CA-66 (octava autorización), punto 7; ADR-016, adenda; notas `[1.35.0]`; guía «Hacia 1.35.0» | cubierta | ídem |
| «Autorizo una intervención excepcional agrupada, registrada sin reiniciar contadores» | CA-66 (octava autorización); Historial | cubierta | octava autorización, punto 3 |
| «si aparecen defectos dentro de este mismo alcance, una pasada correctiva con su re-verificación de QA» | CA-47, puntos 11 y 15; CA-66 (octava autorización), bloque C, con fail-before contra `9220c71`; Historial (pasada correctiva) | cubierta | ídem |
| «Las dos caras de SEC-122, con las dos puertas y controles legítimos.» | CA-66 (octava autorización), punto 3: S1–S6, B1–B5, N1–N6, P8 | cubierta | octava autorización, punto 4 |
| «Distingue decisión del hook, efecto en disco y comportamiento del host. No atribuyas al host lo que sólo se inyectó al hook.» | CA-66 (octava autorización), punto 6 | cubierta | ídem |
| «Autorizo registrar el texto de plataformas propuesto, limitado a los casos realmente ejecutados» (las cuatro líneas) | CA-66 (octava autorización), punto 6; notas `[1.35.0]` | cubierta | octava autorización, punto 5 |
| «Esto describe dónde se ejecutaron los casos; no acredita toda la plataforma ni todos sus comportamientos.» | CA-66 (octava autorización), punto 6; notas `[1.35.0]` | cubierta | ídem |
| «La reparación agrupada tampoco garantiza por sí sola que el candidato quede publicable. CA-54, SEC-115/118, el hueco C y las fronteras restantes conservan sus decisiones pendientes.» | CA-66 (octava autorización), punto 6; CA-54 y P-119-A sin cambio | cubierta | ídem |
| «Esta autorización no acepta:» CA-54, SEC-115, SEC-118, el hueco C, F2, F5 y F7 de P-119-A, SEC-120 | CA-54, P-119-A (F2, F5 y F7) y `Hallazgos abiertos:` sin tocar | cubierta | octava autorización, punto 6 |
| «No cierres requisitos» | Historial (sin tocar `Estado:`, veredictos ni `Hallazgos abiertos:`) | cubierta | octava autorización, punto 7 |

### Correspondencia con el encargo (versionado del 2026-10-03, novena autorización, fase 1)

Pedido: la novena autorización, literal, sección «Fase 1 — SEC-123 (documental, independiente)», y la decisión sobre
SEC-123 del mismo día. Autorización de todas las filas: `PENDING_APPROVAL.md` § Resueltas, «RESUELTA (propietario,
2026-10-03, novena autorización)», y, para la decisión, «RESUELTA (propietario, 2026-10-03) — Decisión 11 (SEC-124)…».
La fase 2 (SEC-124 y SEC-125) no da fila aquí: tiene su propia comisión. Las obligaciones de verificación de QA y
seguridad, el commit y el orden de fases son de la coordinadora y no dan fila.

**Precisión de la coordinadora, rotulada como suya y no como cambio del pedido.** El pedido resume lo medido como
«cuatro componentes de subida desde una raíz de proyecto a cinco o más niveles de profundidad». R-047 §2 midió con la
raíz a **siete** niveles —permiso con cuatro, cinco y seis subidas; deny con una a tres y con siete o más—, y que haga
falta una raíz a **cinco o más** niveles es lo que R-047 **deduce** («Cómo se alcanza»). Como el propio pedido exige
separar lo medido de lo inferido, CA-47 F3 escribe la profundidad medida (siete) como medida y la de cinco o más como
inferida. La fila sigue `cubierta`: es fidelidad al pedido, no una diferencia que requiera al propietario.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «Corregir la descripción de F3 en REQ-007, ADR-016 y las notas [1.35.0]» | CA-47, F3 y punto 16; P-119-A (anotación del 2026-10-03); ADR-016, precisión de SEC-123; notas `[1.35.0]` (fronteras del cambio 4 y limitación SEC-123); también la guía «Hacia 1.35.0», por la misma propiedad | cubierta | novena autorización, fase 1 |
| «separar lo medido de lo inferido» | CA-47, F3 (viñetas «Medido», «Inferido, no medido» y «No comprobado»); punto 16 | cubierta | ídem |
| «lo medido son cuatro componentes de subida desde una raíz de proyecto a cinco o más niveles de profundidad» | CA-47, F3, «Medido» (cuatro subidas con la raíz a siete) e «Inferido» (cinco o más), por la precisión de arriba | cubierta | ídem |
| «permiso indebido y efecto en disco medidos en hook y shell, no ejercidos en el host» | CA-47, F3, «Medido» y «No comprobado»; punto 16 | cubierta | ídem |
| «declarar la consecuencia operativa» | CA-47, F3, «Consecuencia operativa»; punto 16 | cubierta | ídem |
| «mantener F3 dentro de P-119-A como pendiente» | P-119-A (anotación del 2026-10-03: no cambia la pregunta, las opciones ni la recomendación) | cubierta | ídem |
| «ninguna redacción puede leerse como "reparado", "mitigado" ni "riesgo aceptado"» | CA-47, F3 (nota de corrección) y punto 16; P-119-A; marcador de versionado; las tres sedes externas lo dicen en negativo | cubierta | ídem; y «No acepto el riesgo ni doy por reparado el mecanismo» (decisión sobre SEC-123) |

### Correspondencia con el encargo (versionado del 2026-10-03, novena autorización, fase 2)

Pedido: la novena autorización, literal, sección «Fase 2 — SEC-124 y SEC-125 (código, contrato y pruebas)» y
«Manejo del contenido técnico sensible», y las decisiones sobre SEC-124 y SEC-125 del mismo día. Autorización de
todas las filas: `PENDING_APPROVAL.md` § Resueltas, «RESUELTA (propietario, 2026-10-03, novena autorización)», y,
para las decisiones, «RESUELTA (propietario, 2026-10-03) — Decisión 11 (SEC-124)…». Las obligaciones de
implementación, de medición, de QA, de seguridad, del commit y del orden de fases no son contrato de este REQ y no
dan fila. **Todas las filas son contrato escrito**, y su estado es el de CA-47 (marcador de la fase 2): construido en
`10ac6c4` y `36a0d27`; validado por el propietario por vía manual (`docs/qa/REQ-023.md`, CI run 37163342218); sin
firma del qa-tester ni del auditor-seguridad por impedimento del proveedor. *(Antes: «Todas las filas son contrato
escrito, pendiente de implementación y de validación: ninguna afirma que lo construido ya lo cumpla». La última
fila, del write-back de estado, no es contrato: registra ese cambio.)*

**Precisión del analista, sobre P1 y la restricción aceptada, rotulada como suya y no como cambio del pedido.** R-047
§3 no fija a qué agentes se deniega. Lo fijan juntas tres partes del pedido: P1 —«el caso … recibe DENY»—, P2 —el
texto no se altera— y «no se juzga ningún otro comando». Lo publicado denegaba esa forma por lo que iba detrás, con la
regla de la puerta que lo juzgaba (`guard-codigo`, `guard-completado` o `guard-git`). Si la puerta no puede juzgar lo
que va detrás como si la línea cerrara el heredoc, la única forma de que la forma reciba `deny` en todas sus
instancias es denegarla por su estructura con los destinatarios del punto 17, que son los de la denegación explícita
más próxima (R-047 §1, QA-023-15 / P-023-13-A): `guard-completado` a todo agente. De ahí HC5 y HC6. Restringirla a la
coordinadora dejaría en `allow` instancias que lo publicado deniega, como una orden de git destructiva que el
`desarrollador` pusiera detrás, y P1 no se cumpliría. **Si el propietario lee «la restricción concreta del uso legítimo
allí descrito» más estrecha que esto, hay un conflicto entre esa lectura y P1, y lo decide él:** esta fila no lo
resuelve en su nombre.

| Obligación del pedido (cita) | Criterio que la cubre | Relación | Autorización citada, o pregunta abierta |
|---|---|---|---|
| «SEC-124: opción B. Denegación explícita del caso delimitado en R-047 §3.» | CA-47, punto 18; CA-66 (fase 2), HC1–HC6 | cubierta | novena autorización, decisiones; Decisión 11 |
| «No se eliminan caracteres en silencio, no se modifica el comando, no se juzga ningún otro comando.» | CA-47, punto 18 («El texto del comando no se altera»; la denegación no depende de lo que va detrás) | cubierta | ídem |
| «Se acepta sólo la restricción concreta del uso legítimo allí descrito.» | CA-47, punto 18 («La restricción aceptada, en su medida exacta»; HC7 y HC8 como controles); CA-66 (fase 2), punto 5 | cubierta, con la precisión de arriba | ídem |
| «P1. El caso delimitado en R-047 §3 recibe DENY con motivo explícito que identifica SEC-124.» | CA-47, punto 18 (destinatarios y motivo); CA-66 (fase 2), HC1–HC4 | cubierta | novena autorización, fase 2 |
| «P2. El texto del comando no se altera, sanea ni reescribe en ningún camino.» | CA-47, punto 18 | cubierta | ídem |
| «P3. Ningún otro caso de la sección 45 ni del banco cambia de decisión.» | CA-66 (fase 2), puntos 4 y 8; HC7–HC9 | cubierta | ídem |
| «P4. El contrato describe la denegación como restricción concreta de ese caso, no como regla general sobre heredocs ni CR.» | CA-47, punto 18 («Qué es y qué no es») y remisión en el punto 17 | cubierta | ídem |
| «P5. Windows: no medido para este delta. Declararlo; no afirmar cobertura.» | CA-47, punto 18 (última viñeta); CA-66 (fase 2), punto 6 | cubierta | ídem |
| «SEC-125: reparar antes de publicar. Una continuación de línea por sí sola no demuestra intención de evadir.» | CA-47, punto 19; CA-66 (fase 2), LC1–LC9 | cubierta | novena autorización, decisiones; Decisión 11 |
| «P6. Un destino de escritura que sería denegado sin la continuación de línea descrita en R-047 §4 se deniega también con ella.» | CA-47, punto 19 (primera viñeta); CA-66 (fase 2), LC1, LC2 y LC9 | cubierta | novena autorización, fase 2 |
| «P7. El significado del comando se preserva: no se elimina la continuación si eso cambia la semántica; no hay DENY por la mera presencia de una continuación.» | CA-47, punto 19 («No hay `deny` por la mera presencia», «la puerta tampoco», «Juzga lo que escribe el shell también en la otra dirección»); CA-66 (fase 2), LC4–LC8 | cubierta, con una consecuencia declarada: la clase de SEC-125 (LC8), un movimiento de `deny` a `allow` que sigue de esta propiedad | ídem |
| «P8. Se preservan las reglas vigentes de comillas, CR y heredocs: regresión obligatoria de los casos SEC-047, SEC-119 y SEC-122 y de la sección 45.» | CA-47, punto 19 («no mueve las fronteras»); CA-66 (fase 2), punto 8 | cubierta | ídem |
| «P9. No se copia la lógica de guard-git sin comprobar P7 y P8; si se reutiliza, registrar qué se comprobó.» | CA-47, punto 19 («El precedente de `guard-git` es referencia, no plantilla») | cubierta | ídem |
| «P10. Cobertura declarada por capa: hook directo, shell aparte, CLI real si está disponible, extensión no. Sin medición del host, decirlo.» | CA-47, punto 19 (última viñeta); CA-66 (fase 2), punto 6 | cubierta | ídem |
| «Los agentes referencian R-047 §3 y §4 por sección. No reproducen ni reescriben las condiciones de explotación en documentos nuevos.» / «Los casos de prueba se construyen reutilizando la evidencia existente … No se redactan catálogos nuevos de variantes.» | CA-66 (fase 2), punto 3 (casos por identificador; las filas nuevas son controles y las dos de movimiento) | cubierta | novena autorización, «Manejo del contenido técnico sensible» |
| «No subir umbrales ni reducir límites de entrada. No cambiar contrato para acomodar un resultado.» | CA-66 (fase 2), punto 9 (techos nuevos, ningún umbral existente movido); CA-54 y su presupuesto, sin tocar | cubierta | novena autorización, «Límites» |
| «Fuera de alcance y sin aceptar: CA-54 / QA-023-10, SEC-115, SEC-118, hueco C, SEC-120, F2/F5/F7 de P-119-A …» | sin tocar; P-119-A y `Hallazgos abiertos:` sin cambio | cubierta | ídem |
| «Autorizo al analista a escribir UN caso en CA-66: la continuación de línea al final de la línea que abre un heredoc. Debe fijar el comportamiento esperado en las cuatro puertas, coherente con los puntos 18 y 19 de CA-47 y con la decisión registrada sobre SEC-124 (denegar por la forma, a todo agente).» | CA-66 (fase 2), LC10: el caso, escrito; el comportamiento por puerta, fijado **sólo** en lo que fija el punto 19 vigente; el resto, sin fijar porque esos puntos y esa decisión no lo resuelven sin cambiar otro criterio, y queda en la pregunta abierta de la última columna | cubierta | `PENDING_APPROVAL.md` § Resueltas, entrada de la novena autorización, «Autorización del propietario, 2026-10-03, posterior a `c4ad408`»; → Preguntas abiertas, **P-LC10-A** |
| «P-LC10-A: opción A. La forma de LC10 (continuación de línea al final de la línea que abre un heredoc) se deniega por la forma, a todo agente, en las cuatro puertas, igual que SEC-124. Acepto que eso restrinja un uso legítimo raro. No se emula la unión de líneas del shell (B rechazada); no se deja QA-023-23 abierto en esta forma (C rechazada).» / «El analista ajusta el punto 19 de CA-47 y LC10 en CA-66 para reflejar A: denegación por la forma, a todo agente, con motivo que identifique SEC-125 y LC10, en guard-codigo, guard-completado, guard.sh y guard-git. El caso que hoy es "falso positivo" (la línea siguiente cierra el heredoc) queda cubierto por la misma denegación; declararlo. Sin tocar HC1–HC9 ni LC1–LC9 salvo referencias cruzadas. Actualiza ADR-016, notas, guía e índice sólo en lo que esta decisión obliga.» | CA-47, punto 19, «Excepción nombrada» (forma, destinatarios, falso positivo cubierto, motivo, restricción aceptada, (B) y (C) rechazadas) y las salvedades en «No hay `deny` por la mera presencia» y «Lo que este punto no promete»; CA-66 (fase 2), LC10 a LC10.c2 y puntos 3, 5, 6 y 7; P-LC10-A, resuelta; ADR-016, notas `[1.35.0]`, guía e índice | cubierta, con dos precisiones del analista: (1) los destinatarios siguen la letra de la decisión —`guard-codigo` deniega también al `desarrollador` y `guard-git` sin orden de git—, más que la redacción de la opción (A), que daba los del punto 18 (sólo añade denegaciones); (2) la forma se define como la decisión la nombra —la línea que abre el heredoc acaba en una continuación—, sin el «con algo en la línea física siguiente» de la fila anterior, que sólo podía estrecharla. HC1–HC9 y LC1–LC9 no cambian: ninguna remite a LC10 ni al punto 19 de forma que cambie | `PENDING_APPROVAL.md` § Resueltas, entrada de la novena autorización, «Decisiones del propietario, 2026-10-03, posteriores a `598792c` (literales)», decisión 1 y «Tarea del mismo mensaje (literal)» |
| «Puntos 18 y 19 de CA-47 y CA-66 fase 2: de «pendiente de implementación y de validación» a «construido en 10ac6c4 y 36a0d27; validado por el propietario por vía manual (docs/qa/REQ-023.md, CI run 37163342218); sin firma del qa-tester ni del auditor-seguridad por impedimento del proveedor». Ni más ni menos que eso: no «aprobado», no «validado por QA».» / «Hallazgos abiertos de REQ-007: SEC-124 y SEC-125 pasan a «reparado en su alcance (validación manual del propietario)»; QA-023-23 «cerrado en la forma de LC10; abierto en cualquier otra»; QA-023-24 y QA-023-25 cerrados por esa validación. QA: y Seguridad: de REQ-007 siguen `pendiente`.» / «Registro de seguridad: entrada de sólo registro (R-050) que remite a la validación manual, sin firma del auditor.» / «Las frases «Hasta que esté construido y validado, el candidato deja pasar esa forma» de las notas pasan a describir el estado construido.» / «Nada de nuevos hallazgos ni cambios de contrato.» | Write-back de estado, sin cambio de contrato: el marcador del versionado de la fase 2 en CA-47 (puntos 18 y 19), sus remisiones en los puntos 11 y 19 («Excepción nombrada», QA-023-23), las notas de CA-24 y de CA-66 (octava autorización, puntos 5 y 7), el marcador y el punto 5 de CA-66 (fase 2), Notas / alcance y el preámbulo de esta tabla; `Hallazgos abiertos:` (SEC-124, SEC-125 y QA-023-23, con su clase; QA-023-24 y QA-023-25 no estaban en el campo y no entran); ADR-016, notas `[1.35.0]`, guía e índice; `docs/seguridad/registro-seguridad.md` § R-050 | cubierta, con dos precisiones del analista: (1) la frase literal «Hasta que esté construido y validado, el candidato deja pasar esa forma» está en la nota de SEC-124; las de SEC-125 y LC10 la dicen con otras palabras («hasta que esté construido y validado, el candidato —como 1.33.2…— deja pasar esa forma») y reciben el mismo tratamiento; la nota de las clases de movimiento («Cuando esa reparación y la de SEC-125 estén construidas y validadas, las clases serán ocho») también, sin tocar su título («siete clases de casos, y sólo ésas»); (2) el estado se escribe en cada sede con el texto literal del pedido, y lo que cada sede añade —qué decía antes, dónde está la decisión— va rotulado aparte | `PENDING_APPROVAL.md` § Resueltas, entrada de la novena autorización, «Encargo del propietario, 2026-10-03, posterior a `ddd1241` (literal, la parte del despacho)», y «Decisión del propietario, 2026-10-03, posterior a `92ec1fa` (literal; registrada por el propietario)», puntos 1 y 2 |

