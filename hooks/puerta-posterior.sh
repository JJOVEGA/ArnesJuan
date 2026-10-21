#!/usr/bin/env bash
# puerta-posterior.sh — SPIKE 1.37 · 3a (P-137-V). Prototipo; no se instala ni se publica.
#
# QUÉ HACE. Alrededor de cada orden de `Bash` toma una FOTO de una LISTA FIJA —`.arnes/config.json` y
# `hooks/**` del proyecto— antes (PreToolUse, modo `pre`) y después (PostToolUse/PostToolUseFailure, modo
# `post`). Si la foto de después difiere de la de antes y quien ejecutó no es el agente de código, la puerta
# RESTAURA lo vigilado desde una copia tomada antes de la orden y BLOQUEA con motivo (`decision: block`).
#
# POR QUÉ ASÍ:
#   * La lista va ESCRITA AQUÍ y no se lee del manifiesto (P-032-6 (2)): la puerta vigila justamente el
#     manifiesto, y una puerta que se apaga cuando le borran lo que vigila no vigila nada. Por eso este
#     archivo no carga `lib.sh` ni pasa por `arnes_preludio`, que sale inerte sin `.arnes/config.json`.
#   * La foto es METADATO, no contenido: tipo, inodo, tamaño, ctime, mtime, modo y destino de enlace de cada
#     entrada, con UN solo `find`. El ctime no lo fija `touch` ni `cp -p`: cambia con cualquier escritura,
#     renombrado o `chmod`, así que copiar un archivo y devolverle su mtime no deja la foto igual. Sin hash:
#     hashear 400 KB en cada orden sería pagar contenido donde basta el metadato.
#   * La COPIA de restauración no se toma en cada orden: se refresca en `pre` sólo cuando la foto difiere de
#     la de la copia. En la orden común (`ls`) el coste es la foto y un archivo de estado.
#   * La LLAVE que une el antes con el después es `session_id` + `tool_use_id`, que el host entrega en las
#     dos entradas. Sin `tool_use_id` no hay llave segura: `post` compara contra la foto de la copia.
#   * El agente de código sale de la COPIA del manifiesto —el estado de ANTES de la orden—, nunca del vivo:
#     una orden que reescribe `agentes.agente_codigo` no se concede a sí misma el permiso. Sin copia legible,
#     `desarrollador`, el valor por defecto del arnés.
#
# LÍMITES DEL SPIKE (los mide y los declara el informe, docs/arnes/v1.37.0-spike-puerta-posterior.md):
#   el estado vive en un directorio que la propia orden puede escribir; dos agentes concurrentes comparten la
#   ventana; un cambio hecho fuera de una ventana observada (orden en segundo plano, Post que no llega) se
#   absorbe en la copia siguiente con sólo un aviso; Windows/MSYS sin medir.
set -uo pipefail
LC_ALL=C

modo="${1:-}"
entrada=''
IFS= read -r -d '' entrada || true

pp_salir() { exit 0; }

command -v jq >/dev/null 2>&1 || { printf 'ARNES (puerta posterior): jq no encontrado; inactiva.\n' >&2; pp_salir; }

# Una sola llamada a jq: los cuatro campos, uno por línea. Ningún campo que la puerta usa lleva saltos válidos;
# uno que los lleve rompe la lectura y la puerta lo trata como «sin llave» (lado estricto).
campos="$(jq -r '[.session_id // "", .tool_use_id // "", .agent_type // "", .cwd // ""] | map(tostring) | .[]' \
          <<< "$entrada" 2>/dev/null)" || campos=''
{ IFS= read -r sid; IFS= read -r tid; IFS= read -r agente; IFS= read -r cwd; } <<< "$campos"

proj="${CLAUDE_PROJECT_DIR:-$cwd}"
[ -n "$proj" ] && [ -d "$proj" ] || { printf 'ARNES (puerta posterior): sin proyecto; inactiva.\n' >&2; pp_salir; }
cd "$proj" || pp_salir

# Lo que entra en el nombre de un archivo de estado sólo puede llevar caracteres de identificador.
pp_limpio() { case "$1" in ''|*[!A-Za-z0-9_-]*) return 1 ;; esac; return 0; }
pp_limpio "$sid" || sid=sin-sesion
pp_limpio "$tid" || tid=''

estado="${TMPDIR:-/tmp}/arnes-pp-${UID:-0}/$sid"
[ -d "$estado/pre" ] || mkdir -p "$estado/pre" 2>/dev/null || { printf 'ARNES (puerta posterior): sin estado; inactiva.\n' >&2; pp_salir; }

# LA LISTA FIJA. No se lee de ningún sitio.
PP_LISTA=(.arnes/config.json hooks)

pp_foto() {   # -> FOTO
  FOTO="$(find "${PP_LISTA[@]}" -printf '%y %i %s %C@ %T@ %m %p -> %l\n' 2>/dev/null)"
}
pp_lee() {    # <archivo> -> LEIDO ; 1 si no existe
  LEIDO=''
  [ -f "$1" ] || return 1
  IFS= read -r -d '' LEIDO < "$1"
  return 0
}
pp_escribe() { printf '%s' "$2" > "$1"; }

pp_refresca_copia() {   # la copia pasa a ser el estado actual de la lista
  rm -rf "$estado/copia.nueva" && mkdir -p "$estado/copia.nueva/.arnes" || return 1
  [ -e .arnes/config.json ] && { cp -a .arnes/config.json "$estado/copia.nueva/.arnes/" || return 1; }
  [ -e hooks ] && { cp -a hooks "$estado/copia.nueva/" || return 1; }
  rm -rf "$estado/copia" && mv "$estado/copia.nueva" "$estado/copia" || return 1
  pp_escribe "$estado/copia.foto" "$FOTO"
}

pp_restaura() {   # devuelve la lista al estado de la copia; 0 si lo consiguió
  [ -d "$estado/copia" ] || return 1
  rm -rf hooks .arnes/config.json || return 1
  if [ -e "$estado/copia/hooks" ]; then cp -a "$estado/copia/hooks" hooks || return 1; fi
  if [ -e "$estado/copia/.arnes/config.json" ]; then
    mkdir -p .arnes && cp -a "$estado/copia/.arnes/config.json" .arnes/config.json || return 1
  fi
  pp_foto; pp_escribe "$estado/copia.foto" "$FOTO"
}

pp_agente_codigo() {   # -> CODIGO, del manifiesto de ANTES (la copia)
  CODIGO=''
  [ -f "$estado/copia/.arnes/config.json" ] &&
    CODIGO="$(jq -r '.agentes.agente_codigo | if type == "string" then . else empty end' \
              "$estado/copia/.arnes/config.json" 2>/dev/null)"
  [ -n "$CODIGO" ] || CODIGO=desarrollador
}
pp_es_codigo() {   # <agent_type> <declarado>; tolera el prefijo del plugin, como arnes_agente_coincide
  local r="${1//[[:space:]]/}" d="${2//[[:space:]]/}"
  [ -n "$r" ] || return 1
  [ "${r##*:}" = "${d##*:}" ] || return 1
  case "$d" in *:*) [ "$r" = "$d" ] || return 1 ;; esac
  return 0
}

pp_bloquea() {   # <motivo>
  jq -cRs '{decision:"block", reason: rtrimstr("\n")}' <<< "$1"
  exit 0
}

case "$modo" in
  pre)
    pp_foto
    if pp_lee "$estado/copia.foto"; then
      if [ "$LEIDO" != "$FOTO" ]; then
        # Cambió fuera de una ventana observada (una edición permitida, o algo que esta puerta no vio).
        # El spike la absorbe y avisa; decidir otra cosa es del REQ 3b (informe, «lo que no resuelve»).
        printf 'ARNES (puerta posterior): lo vigilado cambió desde la última foto; se toma como nueva base.\n' >&2
        pp_refresca_copia || printf 'ARNES (puerta posterior): no se pudo refrescar la copia.\n' >&2
      fi
    else
      pp_refresca_copia || printf 'ARNES (puerta posterior): no se pudo tomar la copia.\n' >&2
    fi
    [ -n "$tid" ] && pp_escribe "$estado/pre/$tid" "$FOTO"
    ;;
  post)
    pp_foto
    antes=''
    if [ -n "$tid" ] && pp_lee "$estado/pre/$tid"; then antes="$LEIDO"; rm -f "$estado/pre/$tid"
    elif pp_lee "$estado/copia.foto"; then antes="$LEIDO"
    else
      pp_bloquea "ARNES (puerta posterior): no hay foto de antes de esta orden, así que no se puede saber si cambió .arnes/config.json o hooks/. Una puerta que no puede medir no deja pasar."
    fi
    [ "$antes" = "$FOTO" ] && exit 0
    pp_agente_codigo
    if pp_es_codigo "$agente" "$CODIGO"; then
      pp_refresca_copia || printf 'ARNES (puerta posterior): no se pudo refrescar la copia.\n' >&2
      exit 0
    fi
    quien="${agente:-la sesión coordinadora}"
    case "${ARNES_PP_RESPUESTA:-ambas}" in   # SÓLO PARA EL SPIKE: compara las tres respuestas
      bloquear) pp_bloquea "ARNES (puerta posterior): esta orden cambió .arnes/config.json o hooks/ y la ejecutó $quien, que no es el agente de código ($CODIGO). El cambio SIGUE en disco." ;;
      restaurar) pp_restaura; exit 0 ;;
    esac
    if pp_restaura; then
      pp_bloquea "ARNES (puerta posterior): esta orden cambió .arnes/config.json o hooks/ y la ejecutó $quien, que no es el agente de código ($CODIGO). Se restauró el estado de antes de la orden. Ese cambio es del agente de código."
    else
      pp_bloquea "ARNES (puerta posterior): esta orden cambió .arnes/config.json o hooks/ y la ejecutó $quien, que no es el agente de código ($CODIGO). NO se pudo restaurar: revisa esas rutas antes de seguir."
    fi
    ;;
  *) printf 'ARNES (puerta posterior): modo desconocido (%s).\n' "$modo" >&2 ;;
esac
exit 0
