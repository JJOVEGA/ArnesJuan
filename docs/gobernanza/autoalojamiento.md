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
lo intente recibe la denegación de N, con el motivo. Las quality gates del manifiesto son
rápidas (sintaxis y JSON) porque un hook `PreToolUse` muere a los 60 s y un hook muerto no
deniega; el banco completo es la puerta de `main` en CI (`hooks-en-linux`, requerido y estricto).

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

## Registro

| Ciclo | N (guardián) | N+1 (candidata) | REQ | Resultado |
|---|---|---|---|---|
| 1 | v1.30.2 (38b59fb) | rama `cand/1.30.3-autoalojamiento` | REQ-001 | en curso |
