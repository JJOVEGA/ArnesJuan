#!/usr/bin/env bash
# guard-codigo.sh — Invariante A1: "la coordinadora no edita código de la app".
#
# Solo el agente de código (por defecto `desarrollador`) puede editar las rutas de
# código de la app. Cualquier edición desde la sesión coordinadora (sin `agent_id`)
# o desde otro subagente se DENIEGA. El editor se distingue por el campo `agent_id`
# del input del hook: presente sólo cuando la llamada viene de un subagente.
#
# Cubre `Edit`/`Write`/`MultiEdit` (por `file_path`) y, de forma DELIBERADAMENTE
# PARCIAL, `Bash` (redirecciones, `tee`, `cp`/`mv`/`install`, `sed -i`, `dd of=`).
# Ver `arnes_bash_escrituras` en lib.sh: es una barandilla contra el descuido, no
# una jaula contra un agente decidido a rodearla.
#
# La lógica vive en una FUNCIÓN para que `guard.sh` pueda ejecutar los dos
# guardianes en un solo arranque de intérprete, reutilizando el mismo análisis del
# input y del manifiesto. Este archivo sigue siendo ejecutable por su cuenta —el
# banco de pruebas lo invoca así— y en ambos casos corre exactamente el mismo
# código, que es lo que hace que las pruebas sigan valiendo.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

# ⚠️ REGLA CRÍTICA DE ESTA FUNCIÓN: "permitir" se dice con `return 0`, NUNCA con
# `exit 0`. Un `exit` aquí mataría el proceso entero y el segundo guardián no
# llegaría a correr — fallo abierto y en silencio, que es justo la familia de
# defecto que este arnés existe para impedir. `arnes_deny` sí termina el proceso,
# y eso es correcto: una denegación es final y no hay nada más que juzgar.
arnes_guard_codigo() {
  local objetivo="" via_bash=0 exceso=0 cand quien escrituras="" rc nodet=0 nd_ruta='' nd_causa='' nd_arreglo=''

  arnes_parse_input
  # SEC-004 (REQ-007 CA-49 (i)): por Edit/Write/MultiEdit, un enlace en el ULTIMO componente
  # situado dentro de la raiz se deniega sea cual sea su destino. Cualquier otro enlace —un
  # directorio enlazado, uno de fuera de la raiz— lo juzga la identidad del destino, abajo.
  arnes_deny_enlace

  if [ "$ARNES_TOOL" = "Bash" ]; then
    [ -n "$ARNES_CMD" ] || return 0
    via_bash=1
    # El codigo de salida NO se ignora: `$ARNES_RC_EXCESO` significa "no analice",
    # y una lista vacia por no haber analizado no puede leerse como "no escribe nada".
    # Detectadas una vez por invocacion y compartidas con `guard-completado` (CA-54).
    arnes_escrituras_bash; escrituras="$ARNES_ESCRITURAS"; rc="$ARNES_ESCRITURAS_RC"
    if [ "$rc" -eq "$ARNES_RC_EXCESO" ]; then
      # Fail-closed CON destinatario: el guardian solo prohibe a quien no es el agente
      # de codigo, asi que el rechazo por tamano se decide abajo, en el mismo sitio y
      # con las mismas reglas que cualquier otra escritura. Al agente de codigo no le
      # estorba, porque a el ya se le permitia escribir.
      exceso=1; objetivo="(comando no analizable)"
    else
      # EL MANIFIESTO SE LEE SOLO SI HAY UNA ESCRITURA QUE JUZGAR (QA-104).
      #
      # Un comando que no escribe nada --`ls -la`, `npm run build`, la inmensa mayoria de
      # las llamadas de todos los agentes-- no necesita saber que rutas protege el
      # proyecto: no toca ninguna. Detectar las escrituras es GRATIS (expansion de
      # parametros, sin procesos); leer el manifiesto cuesta un `jq`, y este es el camino
      # mas frecuente que existe. SEC-005 puso esa lectura por delante del corte temprano
      # y el camino comun paso de 1 proceso a 2 --en Windows, donde un fork cuesta
      # 1,2-6 s, eso es el orden de magnitud que el arnes lleva tres versiones peleando--.
      #
      # NO SE PIERDE NINGUNA GARANTIA: el alcance de SEC-005 ya excluia este caso a
      # proposito ("un `ls -la` con el manifiesto roto sigue pasando, porque no escribe
      # nada y bloquearlo no protegeria ninguna invariante"). El aviso del manifiesto roto
      # se emite siempre que el manifiesto SE CONSULTA, que es siempre que hay algo que
      # juzgar con el.
      [ -n "$escrituras" ] || return 0
    fi
  else
    [ -n "$ARNES_FP" ] || return 0
  fi

  arnes_parse_manifest
  # SEC-005: con el manifiesto roto los globs no se pueden leer, asi que `objetivo` estaria
  # vacio por ignorancia y no por inocencia. Se deniega antes de sacar ninguna conclusion.
  # Recibe los destinos ya detectados (no los vuelve a analizar): con Bash solo alcanza a
  # un comando que escribe, y ese analisis ya esta hecho aqui arriba.
  arnes_deny_manifiesto_roto "$escrituras"

  # ¿ES CODIGO DE LA APP? Se decide por la IDENTIDAD DEL DESTINO (REQ-007 CA-47, ADR-016), no
  # por el texto de la ruta: `<raiz>/docs/../src/a.ts`, un directorio enlazado a `src/` o
  # `a.ts` con `cwd` en `src/` son `src/a.ts`, y `src/a.ts` con `cwd` en `docs/` no lo es. Lo
  # que no se puede determinar se trata como codigo: solo el agente de codigo pasa (punto 7).
  # Los globs ya estan cargados por `arnes_parse_manifest`: no se arranca otro `jq`.
  if [ "$exceso" -eq 0 ]; then
    if [ "$via_bash" -eq 1 ]; then
      while IFS= read -r cand; do
        [ -n "$cand" ] || continue
        arnes_identidad "$cand"; arnes_id_pertenece codigo; rc=$?
        if [ "$rc" -eq 0 ]; then objetivo="$ARNES_ID_REL"; break; fi
        # El primer no determinable se recuerda, pero se sigue buscando: un destino que SI es
        # codigo da un motivo mas claro que uno que no se pudo situar.
        if [ "$rc" -eq 2 ] && [ "$nodet" -eq 0 ]; then
          nodet=1; nd_ruta="$cand"; nd_causa="$ARNES_ID_C"; nd_arreglo="$ARNES_ID_A"
        fi
      done <<< "$escrituras"
    else
      arnes_identidad "$ARNES_FP"; arnes_id_pertenece codigo; rc=$?
      case "$rc" in
        0) objetivo="$ARNES_ID_REL" ;;
        2) nodet=1; nd_ruta="$ARNES_FP"; nd_causa="$ARNES_ID_C"; nd_arreglo="$ARNES_ID_A" ;;
      esac
    fi
    if [ -n "$objetivo" ]; then nodet=0; elif [ "$nodet" -eq 1 ]; then objetivo="$nd_ruta"; fi
  fi

  [ -n "$objetivo" ] || return 0   # no es código de app -> permitir


  # Es código de app. Permitido SÓLO si es un subagente real (agent_id presente) Y
  # además es el agente de código designado. La comparación tolera el prefijo del
  # plugin (`arnes-juan:desarrollador` casa con `desarrollador`); ver lib.sh.
  if [ -n "$ARNES_AGENT_ID" ] && arnes_agente_coincide "$ARNES_AGENT_TYPE" "$ARNES_AGENTE_CODIGO"; then
    return 0
  fi

  # Editor no autorizado -> fail-closed, no silencioso.
  if [ -n "$ARNES_AGENT_ID" ]; then
    quien="el subagente $(arnes_agente_legible "${ARNES_AGENT_TYPE:-desconocido}")"
  else
    quien="la sesión coordinadora"
  fi
  if [ "$exceso" -eq 1 ]; then
    # El techo se vuelve a resolver AQUI: `arnes_bash_escrituras` corre en una sustitucion
    # de comandos, o sea en un subshell, y lo que memorice alli no vuelve. Es un `jq` en
    # el camino de la denegacion, que ya no es el camino comun (REQ-001, QA-016).
    arnes_techo_bash
    arnes_deny "ARNES: el cuerpo sin citar de un heredoc (o el texto del comando fuera de los heredocs) es demasiado grande para analizarlo con garantia, asi que no se analizo y no se permite (intento de $quien). No es un veredicto sobre lo que hace el comando: es que la puerta no puede medirlo, y una puerta que no puede medir no deja pasar. El presupuesto de analisis vigente es de $ARNES_TECHO bytes y este comando lo supera. Salidas: usa un heredoc CITADO (<<'EOF'), que se descuenta entero y no tiene este techo; escribe el contenido en un archivo de script y ejecutalo; o parte el comando en trozos por debajo de $ARNES_TECHO bytes. El techo se puede SUBIR en .arnes/config.json con 'limites.bash_max_analisis' (bytes), hasta un maximo de $ARNES_BASH_MAX_MANIFIESTO bytes: por encima el analisis dejaria de responder antes de que el hook muera, y un hook muerto no deniega."
  fi
  if [ "$nodet" -eq 1 ]; then
    # REQ-007 CA-47, punto 7: la ruta tal como llego (acotada), que no se pudo determinar, por
    # que, y como corregirlo. Sin nombrar ninguna herramienta como salida.
    arnes_cita_ruta "$nd_ruta"
    arnes_deny "ARNES: no se pudo determinar a que archivo escribe $ARNES_CITA_RUTA: $nd_causa. Sin saber que archivo es, esta puerta no puede decidir si es codigo de la app, y una puerta que no puede medir no deja pasar (intento de $quien; REQ-007 CA-47). Para corregirlo, $nd_arreglo."
  fi
  if [ "$via_bash" -eq 1 ]; then
    arnes_deny "ARNES: el comando escribe en '$objetivo', que es código de la app; sólo el agente '$ARNES_AGENTE_CODIGO' puede hacerlo (intento de $quien). Escribirlo por Bash no salta la regla: delega el cambio en '$ARNES_AGENTE_CODIGO' (ver AGENTS.md §5). Nota: la detección en Bash es parcial (redirecciones, tee, cp/mv/install, sed -i, dd) — si esto es un falso positivo, repórtalo."
  fi
  arnes_deny "ARNES: '$objetivo' es código de la app; sólo el agente '$ARNES_AGENTE_CODIGO' puede editarlo (intento de $quien). Delega el cambio en '$ARNES_AGENTE_CODIGO' — ni siquiera al depurar se parchea a mano (ver AGENTS.md §5)."
}

# Ejecutado directamente (no `source`): hace su propio preludio y corre.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  arnes_preludio || exit 0
  arnes_guard_codigo
  exit 0
fi
