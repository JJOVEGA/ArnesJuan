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
