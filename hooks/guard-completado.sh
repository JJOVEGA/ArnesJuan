#!/usr/bin/env bash
# guard-completado.sh — Invariantes A2, A3 y anti-deriva sobre la transición de un REQ a `completado`.
#
#   A2: no completar con aprobaciones pendientes en PENDING_APPROVAL.md.
#   A3: no completar si alguna quality gate falla.
#   Veredictos (anti-deriva): no completar sin `QA: aprobado`, ni un REQ marcado
#       `Sensible a seguridad: sí` sin `Seguridad: aprobado`. Así ningún REQ se cierra con la
#       validación o la auditoría pendientes/abiertas; el write-back del hallazgo al
#       requerimiento es lo que lleva esos veredictos a "aprobado" (ver AGENTS.md §9).
#
# Se dispara cuando una edición dentro de `requirements/` deja el `Estado:` del REQ en el
# valor terminal (`completado`). Si la transición no ocurre, el hook no hace nada.
set -uo pipefail
# Directorio del propio script por expansión de parámetro. La forma habitual
# —`$(cd "$(dirname ...)" && pwd)"`— son DOS forks anidados, y en esta
# plataforma un fork cuesta más que ejecutar el binario que va dentro.
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

# Lee stdin con el builtin `read`: `cat` costaba un fork y su sustitución, otro.
IFS= read -r -d '' input || true
arnes_require_jq || exit 0

arnes_project_dir "$input"; proj="$ARNES_PROJ"
[ -n "$proj" ] || exit 0
manifest="$proj/.arnes/config.json"
[ -f "$manifest" ] || exit 0   # no es un proyecto del arnés -> inerte

# UNA lectura del input para todo lo que se necesita de él. Este hook corre en
# CADA Edit/Write/MultiEdit y ahora también en cada Bash; en Windows un arranque
# de proceso cuesta ~0,5 s, así que leer los campos por separado eran cinco jq
# más cinco tr por invocación. `cmd` va al final porque puede ser multilínea: se
# lee como el resto del flujo.
arnes_jq_str "$input" -r '[.tool_name // "",
                           .tool_input.file_path // "",
                           .tool_input.command // ""] | .[]'
{ IFS= read -r tool; IFS= read -r fp; IFS= read -r -d '' bash_cmd; } <<< "$ARNES_JQ"
bash_cmd="${bash_cmd%$'\n'}"

case "$tool" in
  Bash)
    # Salida temprana barata: la inmensa mayoría de los comandos son lecturas y
    # no escriben nada. Se descartan aquí sin haber tocado el manifiesto.
    [ -n "$bash_cmd" ] || exit 0
    escrituras="$(arnes_bash_escrituras "$bash_cmd")"
    [ -n "$escrituras" ] || exit 0 ;;
  Edit|Write|MultiEdit)
    [ -n "$fp" ] || exit 0 ;;
  *) exit 0 ;;
esac

# UNA lectura del manifiesto para los tres campos que se usan aguas abajo.
arnes_jq_file "$manifest" -r '[(.requirements_dir // "requirements"),
                              (.estados.completado // "completado"),
                              (.pending_approval // "PENDING_APPROVAL.md")] | .[]'
{ IFS= read -r req_dir; IFS= read -r estado_done; IFS= read -r pending_rel; } <<< "$ARNES_JQ"

# --- Vía Bash: no se juzga aquí, se DERIVA ---
# `guard-codigo` ya cubre A1 por esta vía. Lo que quedaba abierto —y estaba
# declarado como limitación conocida— es el CIERRE de un REQ: un `sed -i` podía
# cerrarlo sin que ninguna puerta lo evaluara.
#
# Aquí NO se reimplementan los veredictos, la cola ni las quality gates: sería la
# segunda transcripción de la misma regla, y dos transcripciones se desfasan. Se
# deniega diciendo por dónde hay que pasar.
#
# La detección del estado terminal es DELIBERADAMENTE ancha —en cualquier parte
# del comando, no `estado:` seguido del valor—. Razón medida: la forma más natural
# de cerrar un REQ por shell es `sed -i 's/en-revision/completado/' REQ-001.md`,
# que sustituye el VALOR y no escribe nunca la palabra "Estado".
if [ "$tool" = "Bash" ]; then
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    case "$d" in /dev/*|/tmp/*) continue ;; esac
    case "$d" in
      /*|[A-Za-z]:*) arnes_ruta_relativa "$d" "$proj"; rel="$ARNES_REL" ;;
      *)             arnes_norm_path "$d"; rel="${ARNES_NORM#./}" ;;
    esac
    case "$rel" in
      "$req_dir"/*)
        if grep -iqE "(^|[^a-zA-Z])${estado_done}([^a-zA-Z]|$)" <<< "$bash_cmd"; then
          arnes_deny "ARNES: este comando escribe en '$rel' y menciona '$estado_done'. La transicion de estado de un REQ no puede juzgarse desde Bash: las puertas A2/A3 necesitan el contenido resultante (veredictos de QA y Seguridad, cola de $pending_rel y quality gates). Hazlo con Edit/Write para que este mismo hook lo evalue (AGENTS.md 6)."
        fi ;;
    esac
  done <<BASHEOF
$escrituras
BASHEOF
  exit 0
fi

# --- Via Edit/Write/MultiEdit ---
arnes_ruta_relativa "$fp" "$proj"; rel="$ARNES_REL"
case "$rel" in
  "$req_dir"/*) ;;          # dentro de requirements/ -> seguimos
  *) exit 0 ;;
esac

# Texto entrante, resuelto segun la herramienta dentro del propio jq.
arnes_jq_str "$input" -r '
  if   .tool_name == "Edit"      then (.tool_input.new_string // "")
  elif .tool_name == "Write"     then (.tool_input.content // "")
  elif .tool_name == "MultiEdit" then ([.tool_input.edits[]?.new_string] | join("\n"))
  else "" end'
nuevo="$ARNES_JQ"

# ¿El cambio deja el REQ en `completado`? Normalizado: case-insensitive y espacios.
# Here-string en vez de `printf | grep`: la tubería costaba un fork de más.
grep -iqE "estado:[[:space:]]*${estado_done}([[:space:]]|$)" <<< "$nuevo" || exit 0

# --- Veredictos QA/Seguridad (anti-deriva) ---
# Los campos viven en el archivo del REQ; se prefiere el contenido entrante y se respalda en disco
# (pre-edición), porque QA/seguridad fijan su veredicto antes de la transición a completado.
disk=''; [ -f "$fp" ] && IFS= read -r -d '' disk < "$fp"   # `read`, no `cat`: sin fork
arnes_campos_req "$disk" "$nuevo"
qa="$ARNES_QA"; seg="$ARNES_SEG"; sens="$ARNES_SENS"

# Solo se exige el campo cuando está presente (compatibilidad con REQ antiguos sin veredictos).
if [ -n "$qa" ] && [ "$qa" != "aprobado" ]; then
  arnes_deny "ARNES: no se puede completar '$rel': el veredicto de QA es '$qa' (se requiere 'QA: aprobado'). Resuelve los hallazgos de QA y refléjalos en el REQ antes de cerrar (AGENTS.md §9)."
fi
# `si` a secas: el normalizador pliega la tilde, así que `SÍ`, `Sí`, `sí` y `SI`
# llegan aquí como la misma forma. Antes se comparaba contra la lista `sí|si` y
# un REQ escrito `Sensible a seguridad: SÍ` NO casaba —la conversión a minúsculas
# no toca la `Í` sin locale— y se saltaba esta puerta en silencio.
case "$sens" in
  si)
    if [ "$seg" != "aprobado" ]; then
      arnes_deny "ARNES: no se puede completar '$rel': es 'Sensible a seguridad: sí' y el veredicto de seguridad es '${seg:-ausente}' (se requiere 'Seguridad: aprobado'). El control hallado debe quedar como NFR antes de cerrar (AGENTS.md §9)."
    fi ;;
esac

# --- Clase del hallazgo: no todo hallazgo bloquea ---
# Un defecto del propio arnes (un lector de umbral, un guardian, una prueba) no
# puede impedir cerrar una funcion de negocio. Sin esta distincion, un hallazgo
# de instrumento mantiene un REQ abierto mientras QA encuentra variantes suyas.
# Un hallazgo SIN clase deniega: la puerta no puede saber si bloquea o no, y un
# "no se" que deja pasar es un "si" disfrazado.
hall="$ARNES_HALL"
case "$hall" in
  ''|ninguno|'(ninguno)'|n/a|na|-|'(-)') hall='' ;;
esac
if [ -n "$hall" ]; then
  # La lista se parte con IFS, no con `printf | tr`: eran tres forks para trocear
  # una cadena que ya está en memoria.
  IFS=',' read -r -a ARNES_HALLAZGOS <<< "$hall"
  for h in ${ARNES_HALLAZGOS[@]+"${ARNES_HALLAZGOS[@]}"}; do
    [ -n "$h" ] || continue
    id="${h%%(*}"
    clase=''
    case "$h" in
      *\(*\)*) clase="${h#*\(}"; clase="${clase%%\)*}" ;;
    esac
    if [ -z "$clase" ]; then
      arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$id' no declara su clase, y un hallazgo sin clase no cuenta como hallazgo. Clasificalo como 'usuario/dinero', 'contrato' o 'instrumento' (requirements/README.md, seccion 'Clases de hallazgo')."
    fi
    case "$clase" in
      instrumento) ;;   # no bloquea: va a deuda tecnica con dueno
      usuario/dinero|contrato)
        arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$id' es de clase '$clase' y bloquea el cierre. Resuelvelo — o reclasificalo si en realidad no afecta a lo que alguien ve, decide o cobra ni a lo que el REQ afirma (requirements/README.md, seccion 'Clases de hallazgo')." ;;
      *)
        arnes_deny "ARNES: no se puede completar '$rel': el hallazgo '$id' declara la clase '$clase', que no existe. Validas: 'usuario/dinero', 'contrato', 'instrumento'." ;;
    esac
  done
fi

# --- Gate A2: no completar con aprobaciones pendientes ---
pending="$proj/$pending_rel"
if [ -f "$pending" ]; then
  abiertas="$(awk '
    # Un ejemplo de formato COMENTADO no es una entrada de la cola. La plantilla
    # traia uno bajo `## Pendientes` y este conteo lo leia como 1 pendiente, asi
    # que un proyecto recien inicializado no podia cerrar NINGUN REQ.
    /<!--/ {enc=1}
    /-->/  {enc=0; next}
    enc    {next}
    /^##[[:space:]]+Pendientes/ {sec=1; next}
    /^##[[:space:]]+Resueltas/  {sec=0}
    sec && /^###[[:space:]]/    {c++}
    END {print c+0}
  ' "$pending")"
  if [ "${abiertas:-0}" -gt 0 ]; then
    arnes_deny "ARNES: no se puede marcar '$rel' como '$estado_done': hay $abiertas aprobación(es) pendiente(s) en $pending_rel. El humano debe resolverlas primero (ver AGENTS.md §6)."
  fi
fi

# --- Gate A3: quality gates en verde antes de completar ---
arnes_jq_file "$manifest" -r '.quality_gates[]? | if type=="object" then (.comando // empty) else . end'
ARNES_GATES="$ARNES_JQ"
tmp="$(mktemp 2>/dev/null || echo /tmp/arnes_gate.$$)"
while IFS= read -r cmd; do
  [ -n "$cmd" ] || continue
  if ! ( cd "$proj" && eval "$cmd" ) >"$tmp" 2>&1; then
    out="$(tail -c 600 "$tmp" 2>/dev/null)"
    rm -f "$tmp"
    arnes_deny "ARNES: no se puede marcar '$rel' como '$estado_done': falló la quality gate \`$cmd\`. Corrígela y reintenta (ver AGENTS.md §7). Últimas líneas: $out"
  fi
done <<< "$ARNES_GATES"
rm -f "$tmp"

exit 0
