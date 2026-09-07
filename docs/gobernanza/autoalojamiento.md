# Autoalojamiento controlado — el arnés se desarrolla a sí mismo

> **Estado: ACTIVO desde 2026-09-05.** Este repositorio usa el arnés para modificar el arnés.
> El principio que lo hace posible, y que no se negocia:
>
> **La versión estable N gobierna el desarrollo de N+1. La versión que está siendo modificada
> nunca puede convertirse en su propio guardián durante esa misma ejecución.**

## Por qué hace falta un principio y no sólo cuidado

Un hook que se edita mientras gobierna la sesión que lo edita tiene dos formas de fallar en
abierto: la edición lo rompe y desde ese instante nada deniega; o la edición lo relaja "un
momento" para que pase un cambio, y ese momento se publica. Las dos son silenciosas, y este
arnés existe para impedir exactamente esa familia. Por eso el guardián y el candidato son
**dos copias distintas en dos rutas distintas**, y sólo una de ellas se edita.

## Las dos copias

| | Qué es | Dónde vive | Quién la cambia |
|---|---|---|---|
| **Estable (N)** | La versión publicada e instalada del plugin; corre los hooks de la sesión | `~/.claude/plugins/cache/arnes-juan/arnes-juan/<N>/` (la ruta que registra `installed_plugins.json`) | Sólo el instalador del plugin, y sólo **después** de publicar y verificar N+1 |
| **Candidata (N+1)** | El worktree de este repositorio, en una rama aparte | `<worktree>/` en la rama `cand/<N+1>-<tema>` | El `desarrollador`, gobernado por N |

**Antes de editar nada, se verifica y se muestra** — no se asume:
1. versión y commit exactos de la instalación que ejecuta los hooks (`installed_plugins.json`:
   `version`, `gitCommitSha`, `installPath`);
2. que sus archivos son **byte a byte** los del tag `v<N>` del repositorio;
3. que esa ruta **no es** el worktree que se va a modificar;
4. la rama de trabajo de la candidata.

Si los hooks activos apuntan al mismo árbol que se va a modificar, **se para**. No se continúa
hasta separar guardián y candidato.

## El manifiesto del arnés sobre sí mismo

`.arnes/config.json` de este repositorio declara `hooks/`, `tools/` y `.github/` como
`codigo_app.globs`: **sólo el agente `desarrollador` los edita**, y la sesión coordinadora que
lo intente recibe la denegación de N, con el motivo.

Desde 1.31.0 esa frontera **se incluye a sí misma**: `.arnes/config.json` y `.claude-plugin/*` están
dentro de los globs, porque quien no puede escribir `hooks/` no debe poder cambiar la regla que dice
qué es `hooks/` (hallazgo de la auditoría del ciclo 1). Queda fuera el resto de `.arnes/` —
`migracion.md` y `plantillas-origen/`—, que los escribe la migración desde la sesión coordinadora y
no declaran ninguna invariante. **Consecuencia práctica y aceptada:** `arnes_version` vive en el
manifiesto, así que la Fase 5 de `/arnes-upgrade` en este repositorio la ejecuta el `desarrollador`.
Ocurre una vez por versión y coincide con el commit en el que ya sube `plugin.json` y
`marketplace.json`. **Esto es mapeo de este repositorio y no se traslada a las plantillas:** un
proyecto que instale el arnés decide su propia frontera. Las quality gates del manifiesto son
rápidas (sintaxis y JSON) porque un hook `PreToolUse` muere a los 60 s y un hook muerto no
deniega; el banco completo es la puerta de `main` en CI (`hooks-en-linux`, requerido y estricto).

**Cuál es «la plataforma del desarrollador» de `AGENTS.md` §7, porque dejó de ser obvia.** Desde el
traslado del desarrollo a WSL/Linux (2026-09-05), el banco se corre **aquí**: tarda segundos en vez de
media hora, y esa diferencia no es comodidad — un banco de treinta minutos se corre una vez y se cree,
uno de diez segundos se corre veinte veces y se comprueba. La exigencia de §7 se cumple con las corridas
de esta plataforma, y **está cumplida de sobra**. Lo que **no** queda cubierto, y hay que decirlo cada
vez en lugar de darlo por hecho, es el **coste en Windows/MSYS**, donde un `fork` cuesta entre 1,2 y 6 s:
las cifras de proceso que declaran los REQ se miden aquí y se razonan allí. Un proyecto que corra el
arnés en Windows paga por cada proceso que añadamos, y por eso los criterios cuentan **procesos**, que
son comparables entre plataformas, y no milisegundos, que no lo son.

## El ciclo, con los roles reales del arnés

1. **Requerimiento.** Todo cambio del mecanismo nace como REQ en `requirements/` con
   `Rigor: critico`, `Sensible a seguridad: sí`, `QA: pendiente`, `Seguridad: pendiente`. Lo
   redacta el `analista-requerimientos`, con criterios de aceptación que nombran la evidencia:
   **el caso falla contra N y pasa contra N+1**, más sus controles positivos.
2. **Código y pruebas.** El `desarrollador` modifica `hooks/`, `tools/` y el banco, en la rama
   candidata. La coordinadora dirige y **no suplanta** al desarrollador para escribir código
   protegido; si lo intenta, N la deniega — y eso es lo que se quiere.
3. **Romperlo.** El `qa-tester` intenta romper la solución con casos **independientes** de los
   del desarrollador, y los deja en el banco.
4. **Bypasses.** El `auditor-seguridad` busca las formas de rodear la puerta que el cambio abre o
   deja abiertas, y las escribe en `docs/seguridad/`.
5. **Evidencia.** Cada bypass corregido tiene su par *fail-before / pass-after*: el mismo caso del
   banco, ejecutado con `ARNES_HOOKS_DIR` apuntando a la instalación estable (N) tiene que
   **fallar**, y contra el worktree candidato tiene que **pasar**. Sin ese par, el caso no prueba
   que el arreglo arregle.
6. **Banco completo en Linux** (CI del PR): `PASS`, `FAIL` y `SKIP` por separado; **ningún**
   `FAIL`; cada `SKIP` explica la plataforma o condición que lo salta; bits de ejecución de todo
   punto de entrada; y se comprueba que `hooks-en-linux` sigue siendo puerta estricta de `main`.
7. **Un humano aprueba la fusión.** El CI en verde es necesario, no suficiente. Se presenta la
   evidencia y se **espera**. No se fusiona, no se etiqueta, no se publica sin esa aprobación.
8. **Publicación y verificación de N+1.** Tras la fusión: tag `v<N+1>` sobre el commit de merge,
   verificación de que el tag declara esa versión, y **sólo entonces** se actualiza la
   instalación estable.
9. **N+1 gobierna N+2.** La versión recién instalada sólo empieza a gobernar el desarrollo de la
   siguiente, en una sesión nueva: los hooks se cargan al arrancar.

## Lo que está prohibido durante el ciclo

- Debilitar temporalmente los hooks, el manifiesto, las quality gates, el workflow o el
  ruleset para que el cambio pase. Si una puerta estorba, se corrige **en la candidata, con su
  REQ**, y pasa por el mismo ciclo.
- Editar la instalación estable. Si N tiene un defecto que bloquea el trabajo, el defecto se
  documenta y se corrige en N+1; mientras, se convive con él o se para.
- Cerrar el REQ del cambio antes de que N+1 esté publicada y verificada: el cierre es el último
  paso, no el primero.

## Dos advertencias medidas

- **`autoUpdate` del marketplace.** Si está en `true`, la instalación estable se actualiza sola
  al publicar; en esa máquina la nueva versión pasa a gobernar **la siguiente sesión** sin
  decisión explícita. Es aceptable si el paso 8 se cumplió; si se quiere control manual, se
  desactiva y la actualización se hace a mano tras verificar.
- **Los hooks se cargan al arrancar la sesión.** Un plugin actualizado a mitad de sesión no
  gobierna hasta reiniciarla. Por eso el paso 1 mide con una sonda —no lee la configuración—:
  una edición de la coordinadora sobre `hooks/` que N debe denegar, y un comando que distinga
  el comportamiento de N del de N-1.

## Política de rigor (dictada por el propietario, 2026-09-05)

Todo REQ de este repositorio pasa por **analista → desarrollador → QA → auditor de seguridad →
coordinador reúne la evidencia → Juan aprueba la fusión y la publicación**. Se declara por defecto
`Rigor: critico` y `Sensible a seguridad: sí`, con `QA: pendiente` y `Seguridad: pendiente`. Una
excepción editorial sólo baja ese nivel con autorización expresa del propietario; nunca por
reclasificación automática de un agente. **Esta política pertenece únicamente a ArnesJuan**: no se
traslada a las plantillas ni a los proyectos que instalan el arnés, que conservan su propio mapeo.

### Excepción medida: cuándo un REQ de este repositorio baja a `estandar` (delegado por el propietario, 2026-09-06)

El suelo sigue siendo `critico` **y no se declara al nacer**. Lo que se delega es **saltar el pase del
auditor al cierre**, y sólo cuando la máquina puede demostrar que no había nada que auditar:

| Condición, las tres a la vez | Cómo se comprueba |
|---|---|
| El campo `Archivos:` del REQ no declara ninguna ruta bajo `hooks/`, `tools/`, `tests/`, `.github/`, `.arnes/` ni `.claude-plugin/` | `tools/arnes-paralelo.sh`, que normaliza igual que las puertas |
| El diff del REQ sobre esas rutas es **vacío**, con `git diff` **y** `git status --short` | los dos, porque `git diff` es ciego a lo no rastreado — medido, H-08 |
| El banco corre **idéntico**: ninguna línea del inventario suprimida, modificada ni cambiada de veredicto | `tests/escenarios/hooks/inventario.sh` |

**Por qué al cierre y no al empezar.** Un REQ que *promete* no tocar la máquina no ha demostrado nada;
uno cuyo diff sale vacío, sí. Declarar `estandar` de entrada sería confiar en la intención, que es
exactamente lo que este arnés no hace. Así la excepción es **fail-closed**: si la prueba no se puede
producir, el rigor se queda donde estaba.

**Qué NO cambia.** `QA:` sigue siendo obligatorio —esta excepción sólo salta al auditor—; el suelo por
`Sensible a seguridad: sí` sigue vigente para todo lo demás; y **nada de esto se propaga a las
plantillas**: es política de autoalojamiento de este repositorio, no del arnés que heredan los
proyectos.

**Qué ahorra, medido y sin inflar.** Una comisión de auditoría por REQ que califique: ~15-20 min y unos
4 USD. En el ciclo 3 habría calificado **uno de tres** (REQ-012, cuya CA-11 exige precisamente ese diff
vacío). Es una palanca pequeña; las grandes son el tope de criterios por REQ y que un defecto de forma
deje de costar una vuelta.

## Aprobación humana delegada (propietario, 2026-09-05)

El propietario autorizó de forma **permanente** que, cuando **todo** esté en verde, la coordinadora
fusione, etiquete y publique sin volver a preguntar. «Todo en verde» significa, a la vez:
CI `hooks-en-linux` con **0 FAIL** y cada `SKIP` explicado; el par *fail-before / pass-after*
presente para cada bypass del REQ; `QA: aprobado` y `Seguridad: aprobado` (o hallazgos abiertos
sólo de clase `instrumento`, con dueño); plantillas de los consumidores sin cambios exclusivos del
autoalojamiento; instalación nueva y actualización verificadas. **Cualquier** `FAIL`, un `SKIP` sin
explicar, un hallazgo abierto de clase `usuario/dinero` o `contrato`, o un veto del auditor devuelve
la decisión al propietario: se presenta la evidencia y se para. La delegación cubre la fusión, el
tag y la publicación; la instalación estable se actualiza después (`autoUpdate`) y gobierna la
sesión siguiente.

## Disciplina de coste (medida el 2026-09-06, obligatoria desde el ciclo 3)

El ciclo 2 costó **~4 M de tokens y ~253 USD** a precios de API. La medición dice dónde, y no era donde
parecía: **el 87 % del gasto es caché —60 % lecturas, 27 % escrituras— y sólo el 13 % es lo que los
modelos escriben.** No se paga por pensar: se paga por **releer**.

**La fórmula que gobierna todo lo demás: el coste de una comisión es `turnos × contexto`.** Medido sobre
3.384 turnos: 107 k de contexto medio por turno, mediana de pico 149 k, máximo 304 k. La comisión más
cara fue de **138 turnos y 12,48 USD**; la más barata que hizo trabajo real, de **8 turnos y 0,06 USD**.
Doscientas veces de diferencia, y la variable no es el modelo ni cuántos archivos hay en el repositorio.

Tres consecuencias que cambian cómo se despacha:

1. **El encargo declara un presupuesto de turnos y de tokens**, y el agente lo reporta al entregar.
   `AGENTS.md` §6 ya pedía anotar las comisiones por encima de 200 k y nadie lo cumplía, empezando por
   la coordinadora.
2. **Lo grande se lee tarde y en trozos.** Un documento de 38 k leído en el turno 5 de 138 se paga 133
   veces; el mismo leído al final, dos. Por eso importa que la **historia** de un REQ salga del archivo
   que el desarrollador y el QA leen, y que los **criterios** describan la regla en vez de enumerar la
   lista: en un REQ los criterios son el 54 % del peso y la historia sólo el 20 %.
3. **La elección de modelo casi no mueve la aguja.** Medido: la misma coordinadora cuesta 196,63 USD en
   Opus 5 y 208,48 USD en Fable 5.1, un 6 % más, porque el gasto es caché y ahí Fable lee a mitad de
   precio. Ahorrar bajando de modelo es la optimización equivocada; la que rinde es reducir contexto.

**Lo que NO se construye, y la razón:** el arnés no lleva un medidor de coste. Medir esto exige leer las
transcripciones de la herramienta anfitriona, cuyo formato no está documentado y puede cambiar; meterlo
en el plugin haría que todos los proyectos heredaran esa dependencia. El arnés trae el mecanismo, no el
mapeo, y aquí el mapeo es del anfitrión. **La coordinadora mide y reporta el coste de cada ventana**, con
el método escrito arriba, que es estable aunque el script se reescriba.

## Defectos del guardián descubiertos mientras gobierna (regla del propietario, 2026-09-06)

El guardián de la sesión es la versión estable instalada, y es la única copia que se ve **en uso
real**. Sus defectos aparecen aquí y en ningún otro sitio: un `deny` que no debía denegar, una
escritura que debía denegar y pasó, un mensaje que no dice cómo salir. **Se registran en el acto**, con
su clase, en `docs/PENDIENTES.md`. Eso no se discute.

Lo que sí se decide es **en qué ventana entra la reparación**, y el criterio es la clase del hallazgo,
no lo molesto que resulte:

| Qué se encontró | Dónde se repara |
|---|---|
| Deja pasar algo que debía parar, o para algo legítimo y **bloquea el trabajo del ciclo en curso** | **En la ventana abierta**, sin preguntar: un guardián que estorba el ciclo se arregla ya |
| Clase `usuario/dinero` o `contrato` | En la ventana abierta |
| Clase `instrumento` que no bloquea | **Ventana siguiente**, con dueño y criterio escritos |

**Por qué el reparto y no «se arregla todo ya».** Una ventana que admite cualquier hallazgo del
guardián deja de tener alcance, y un ciclo sin alcance no se cierra: el ciclo 2 terminó con siete REQ
porque cada hallazgo abrió el siguiente. La ventana 1.32.0 tiene tres REQ declarados y la reserva es
deliberada.

Dos ejemplos vivos, ambos defectos de **1.31.0, la versión que gobierna ahora mismo**, ambos
`instrumento`, y ambos aparcados en 1.33.0 por esta regla: la nota heredable de `guard-git` enumera un
envoltorio cuando el código tolera siete (SEC-013), y la skill de migración no dice en ninguna parte
que **hay que reiniciar la sesión** para que las puertas nuevas corran — un proyecto que actualiza cree
estar protegido por puertas que aún no se han cargado.

**Y la reparación no la escribe la coordinadora.** `hooks/` y `tools/` son del `desarrollador`, gobernado
por la versión anterior, con QA y auditoría después. Un arreglo urgente del guardián sigue siendo un
REQ; lo único que cambia es en qué ventana entra.

## Registro

| Ciclo | N (guardián) | N+1 (candidata) | REQ | Resultado |
|---|---|---|---|---|
| 1 | v1.30.2 (38b59fb) | rama `cand/1.30.3-autoalojamiento` → `main` 6c1b58a | REQ-001 | **publicado** 2026-09-05: tag `v1.30.3` sobre 6c1b58a (PR #31, `hooks-en-linux` 309/0/1). Tres vueltas dev↔QA; QA y seguridad aprobados; SEC-001..007 preexistentes → REQ-007. El REQ se cierra al verificar la instalación estable en 1.30.3 |
| 2 | v1.30.3 (6c1b58a) | rama `cand/1.31.0-mecanismos` → `main` 2fecae1 | REQ-002..006, 009, 010 (007 parcial) | **publicado** 2026-09-06: tag `v1.31.0` sobre 2fecae1 (PR #33, `hooks-en-linux` 682/0/1). Tres vueltas dev↔QA **más una extra autorizada por delegación tras un veto del auditor**, con su razón y su límite escritos en REQ-005. Siete REQ con las dos firmas; REQ-007 sigue `en-progreso` y cruza a 1.32.0 |
| 3 | v1.31.0 (2fecae1) | rama `cand/1.32.0-…` | REQ-007 (bloques B y C), REQ-011, y lo que docs/PENDIENTES.md asigna a 1.32.0 | pendiente de abrir (el guardián nuevo gobierna desde la sesión siguiente) |

### Lo que enseñó el ciclo 2, y no estaba previsto

- **El arnés destruía el archivo del usuario.** Con el manifiesto averiado, el hook de parada tenía
  cuatro caminos que mataban o borraban; dos reescribían `docs/ESTADO.md` **a partir de una lectura que
  había fallado**. Lo encontró la auditoría buscando otra cosa, y el QA lo **reprodujo** en la versión
  anterior antes de dar por bueno el arreglo. Regla que se queda: **lo que no se puede leer no se
  reescribe**, y lo que se verifica es el archivo entero por hash, no la parte que a uno le interesa.
- **Un veto se levanta arreglando, no declarando** — y antes de arreglar se mide el **radio**: comprobar
  que el detector de escrituras no estaba afectado convirtió un susto en un cambio acotado a una puerta.
- **La deriva tiene dos direcciones.** Un criterio que promete de más es deriva conocida; uno que promete
  **de menos**, porque el código acabó cubriendo más, lo es igual y nadie lo vigila. Se cierra el límite
  en silencio y el documento deja de describir la máquina.
- **El cierre de un REQ lo juzga el guardián de la sesión, no la versión que se acaba de publicar.** Al
  cerrar los REQ de 1.31.0 con 1.30.3 gobernando, la puerta rechazó el campo `Hallazgos abiertos:`
  escrito en la forma ancha que **1.31.0** aprendió a leer. No es un fallo: es el principio funcionando.
  La consecuencia práctica, que vale para cualquier proyecto: **el campo se escribe en la forma cerrada
  —`ID (clase)`— y la evidencia vive en el informe**, que es donde no la lee ninguna puerta.
