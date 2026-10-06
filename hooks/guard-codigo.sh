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
  arnes_deny_entrada_ilegible   # SEC-120: a todo agente
  # SEC-120 (REQ-007 CA-47, punto 20): el `file_path` o el `command` que esta puerta juzga no es texto.
  # Un `file_path` que no es texto NO DEJA PASAR A NADIE, tampoco al agente de codigo (SEC-128, CA-47
  # punto 20, P-136-J): la regla del enlace de abajo (SEC-004, CA-49 (i)) le alcanza a el tambien, y
  # sin el texto del destino no se puede aplicar. Un `command` que no es texto si deja pasar al agente de
  # codigo, como un `tool_name` que no identifica ninguna herramienta (abajo): por `Bash` esta puerta no
  # le juzga nada. El manifiesto se lee solo en este camino.
  if arnes_campo_no_texto; then
    arnes_parse_manifest
    if [ "$ARNES_TOOL" = Bash ] && [ -n "$ARNES_AGENT_ID" ] && arnes_agente_coincide "$ARNES_AGENT_TYPE" "${ARNES_AGENTE_CODIGO:-}"; then
      return 0
    fi
    if [ -n "$ARNES_AGENT_ID" ]; then quien="el subagente $(arnes_agente_legible "${ARNES_AGENT_TYPE:-desconocido}")"
    else quien="la sesión coordinadora"; fi
    arnes_deny_no_texto "esta puerta no puede saber si escribe codigo de la app ni en que archivo" "intento de $quien; "
  fi
  # REQ-007 CA-47, punto 13: un `tool_name` con un salto de linea no identifica ninguna herramienta
  # —leido entero, `Bash` seguido de un salto ya no es `Bash`—, y tratarlo como una herramienta que
  # esta puerta no juzga lo dejaria pasar. Es una escritura no determinable (punto 7): solo el agente
  # de codigo pasa. El agente de codigo lo dice el manifiesto; si no se puede leer, no pasa nadie.
  # Con un retorno de carro, igual (QA-023-13): el transporte retiraba el del final y `Bash␍` con
  # `ls` y un `file_path` en `src/` se juzgaba como `Bash`, sin mirar el `file_path`. El CR lo cuenta
  # jq en el valor crudo (`ARNES_TOOL_CR`); el salto, si hay los dos, da el motivo de siempre.
  if [[ "$ARNES_TOOL" == *$'\n'* ]] || [ "${ARNES_TOOL_CR:-0}" = 1 ]; then
    arnes_parse_manifest
    if [ -n "$ARNES_AGENT_ID" ] && arnes_agente_coincide "$ARNES_AGENT_TYPE" "${ARNES_AGENTE_CODIGO:-}"; then
      return 0
    fi
    if [ -n "$ARNES_AGENT_ID" ]; then quien="el subagente $(arnes_agente_legible "${ARNES_AGENT_TYPE:-desconocido}")"
    else quien="la sesión coordinadora"; fi
    arnes_cita_ruta "$ARNES_TOOL"; arnes_causa_herramienta
    arnes_deny "ARNES: el nombre de la herramienta de esta llamada, $ARNES_CITA_RUTA, $ARNES_CAUSA_HERR y no identifica ninguna herramienta, asi que esta puerta no puede saber si escribe ni en que archivo: se trata como una escritura que no se puede determinar, y una puerta que no puede medir no deja pasar (intento de $quien; REQ-007 CA-47, punto 13)."
  fi
  # SEC-004 (REQ-007 CA-49 (i)): por Edit/Write/MultiEdit, un enlace en el ULTIMO componente
  # situado dentro de la raiz se deniega sea cual sea su destino. Cualquier otro enlace —un
  # directorio enlazado, uno de fuera de la raiz— lo juzga la identidad del destino, abajo.
  arnes_deny_enlace

  if [ "$ARNES_TOOL" = "Bash" ]; then
    [ -n "$ARNES_CMD" ] || return 0
    via_bash=1
    # El codigo de salida NO se ignora: `$ARNES_RC_EXCESO` significa "no analice",
    # y una lista vacia por no haber analizado no puede leerse como "no escribe nada".
    # Analizado una vez por invocacion: `guard-completado` reutiliza este resultado (`arnes_escrituras_de`).
    arnes_escrituras_de "$ARNES_CMD"; rc=$?; escrituras="$ARNES_ESCRITURAS"
    if [ "$rc" -eq "$ARNES_RC_EXCESO" ]; then
      # Fail-closed CON destinatario: el guardian solo prohibe a quien no es el agente
      # de codigo, asi que el rechazo por tamano se decide abajo, en el mismo sitio y
      # con las mismas reglas que cualquier otra escritura. Al agente de codigo no le
      # estorba, porque a el ya se le permitia escribir.
      exceso=1; objetivo="(comando no analizable)"
    elif [ "$rc" -eq "$ARNES_RC_CR" ]; then
      # P-023-13-A: el delimitador de un heredoc lleva un retorno de carro y el analizador no puede
      # seguirlo como el shell (`arnes_bash_sin_texto`). Mismo destinatario que el presupuesto: solo
      # se prohibe a quien no es el agente de codigo.
      exceso=2; objetivo="(comando no analizable)"
    elif [ "$rc" -eq "$ARNES_RC_CUERPO_CR" ]; then
      # SEC-124 (REQ-007 CA-47, punto 18): una linea del cuerpo de un heredoc es el delimitador seguido
      # de un retorno de carro y no es la ultima del comando. Se deniega la forma, sin retirar el CR ni
      # juzgar otro comando. Mismo destinatario que los dos de arriba: quien no es el agente de codigo.
      exceso=3; objetivo="(comando no analizable)"
    elif [ "$rc" -eq "$ARNES_RC_LC10" ]; then
      # SEC-125, LC10 (REQ-007 CA-47, punto 19, «Excepcion nombrada»): la linea que abre un heredoc acaba en
      # una continuacion de linea. A TODO agente, el de codigo incluido: no pasa por la regla de destinatarios
      # de abajo. Motivo unico de las cuatro puertas.
      arnes_deny_lc10 guard-codigo
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
  if [ "$exceso" -eq 2 ]; then
    arnes_deny "ARNES: el comando lleva un heredoc cuyo delimitador contiene un retorno de carro. Para el shell ese retorno de carro es parte del delimitador, y el analisis de esta puerta no puede seguirlo asi: no sabria donde acaba el cuerpo ni que escribe lo que va detras, asi que no lo analiza y no lo permite (intento de $quien). Una puerta que no puede medir no deja pasar, y el retorno de carro no se retira en silencio para juzgar otro comando (REQ-007 CA-47, punto 11). Para corregirlo, escribe el comando sin retornos de carro: lineas terminadas solo en salto de linea."
  fi
  if [ "$exceso" -eq 3 ]; then
    arnes_deny "ARNES (SEC-124): dentro del cuerpo de un heredoc hay una linea que es su delimitador seguido de un retorno de carro, y no es la ultima del comando. Para bash esa linea no cierra el cuerpo, pero el retorno de carro es un dato del transporte y un shell que lo retire cerraria el cuerpo ahi y ejecutaria como orden lo que va detras; esta puerta no retira el retorno de carro ni juzga otro comando, asi que deniega la forma (intento de $quien; REQ-007 CA-47, punto 18). Para corregirlo, escribe el comando sin retornos de carro —lineas terminadas solo en salto de linea— o usa en el cuerpo otra palabra que no sea el delimitador."
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
  arnes_preludio guardian || exit 0
  arnes_guard_codigo
  exit 0
fi
