#!/usr/bin/env bash
# arnes-lectura.sh — qué LEE la máquina en los REQ de este proyecto.
#
# POR QUÉ EXISTE
# Un banco de pruebas sólo caza lo que falla. Los peores defectos que ha tenido este
# arnés no fallaban: la puerta que debía existir simplemente no existía, y todo se
# veía verde. Medido en un proyecto real: siete REQ declaraban
# `Sensible a seguridad: **sí**`, la negrita impedía que casara con `si`, y esos siete
# se saltaban la revisión de seguridad en silencio. Uno gobernaba datos personales y
# estaba a un campo de cerrarse sin auditoría.
#
# Esto no es una prueba: es un INFORME. No pregunta «¿falla algo?» sino «¿qué lee la
# máquina en tus datos?». Pasa cada campo por EL MISMO normalizador que usan los
# hooks —no una copia, que se desfasaría— y enseña todo valor que no reconozca.
#
# Habría cazado los siete el primer día, sin que nada fallara.
#
# LO QUE NO HACE, dicho por delante: detecta valores que la máquina lee distinto de
# como se escribieron. NO detecta una puerta que falta en la lógica. Para eso sigue
# haciendo falta que alguien la busque.
#
# Uso:  tools/arnes-lectura.sh [ruta-del-proyecto]      (por defecto, el directorio actual)
# Sale 0 si no hay anomalías, 1 si las hay, 2 si no puede leer el proyecto.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/../hooks/lib.sh"

PROY="${1:-$PWD}"
MAN="$PROY/.arnes/config.json"
if [ ! -f "$MAN" ]; then
  printf 'No hay .arnes/config.json en %s — esto no es un proyecto del arnés.\n' "$PROY" >&2
  exit 2
fi
command -v jq >/dev/null 2>&1 || { printf 'Hace falta jq.\n' >&2; exit 2; }

ARNES_MANIFEST="$MAN"
arnes_jq_file "$MAN" -r '[(.requirements_dir // "requirements"),
                          (.estados.completado // "completado")] | .[]'
REQ_DIR=''; DONE=''
{ IFS= read -r REQ_DIR; IFS= read -r DONE; } <<< "$ARNES_JQ"
arnes_jq_file "$MAN" -r '(.estados.todos // ["borrador","pendiente","en-progreso","en-revisión","completado","bloqueado"])[]'
ESTADOS_OK=''
while IFS= read -r e; do arnes_norm_campo "$e"; ESTADOS_OK+="|$ARNES_CAMPO"; done <<< "$ARNES_JQ"

# Formas que la máquina reconoce en cada campo. Un valor fuera de aquí no es
# necesariamente un error del proyecto: puede ser un error del arnés al leerlo, y
# distinguirlo es justo lo que este informe existe para permitir.
QA_OK='|pendiente|aprobado|con-hallazgos'
SEG_OK='|n/a|pendiente|aprobado|preventiva|vetado'
RIG_OK='|ligero|estandar|critico'

VERSION="$(jq -r '.version // "?"' "$DIR/../.claude-plugin/plugin.json" 2>/dev/null || echo '?')"
printf 'Lectura del arnés sobre %s/ — plugin %s\n\n' "$REQ_DIR" "$VERSION"

anomalias=0; reqs=0; notas=0; nc=0; ne=0; nl=0
avisa() {   # <req> <campo> <crudo> <leido> <consecuencia>
  anomalias=$((anomalias+1))
  printf '  %-12s %s\n' "$1" "$2"
  printf '  %-12s   escrito:  «%s»\n' '' "$3"
  printf '  %-12s   se lee:   <%s>\n' '' "$4"
  printf '  %-12s   %s\n\n' '' "$5"
}

detalle=''
for f in "$PROY/$REQ_DIR"/*.md; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  case "$base" in README.md|readme.md) continue ;; esac
  texto=''; IFS= read -r -d '' texto < "$f"

  # Los campos CRUDOS, para poder enseñar el contraste con lo que la máquina lee.
  cru_est=''; cru_qa=''; cru_seg=''; cru_sens=''; cru_rig=''
  while IFS= read -r l; do
    case "$l" in
      'Estado:'*)               cru_est="${l#Estado:}" ;;
      'QA:'*)                   cru_qa="${l#QA:}" ;;
      'Seguridad:'*)            cru_seg="${l#Seguridad:}" ;;
      'Sensible a seguridad:'*) cru_sens="${l#Sensible a seguridad:}" ;;
      'Rigor:'*)                cru_rig="${l#Rigor:}" ;;
    esac
  done <<< "$texto"

  arnes_norm_campo "$cru_est"; est="$ARNES_CAMPO"
  if [ -z "$est" ]; then notas=$((notas+1)); continue; fi
  reqs=$((reqs+1))

  # El mismo camino que recorren los hooks, ni uno distinto.
  arnes_campos_req "$texto" ''
  case "$ARNES_RIGOR" in critico) nc=$((nc+1)) ;; estandar) ne=$((ne+1)) ;; ligero) nl=$((nl+1)) ;; esac

  bloque=''
  if [ "${ESTADOS_OK}|" != "${ESTADOS_OK/|$est|/|}|" ] || [ -z "${ESTADOS_OK##*|$est*}" ]; then :; fi
  case "$ESTADOS_OK" in *"|$est"*) ;; *)
    bloque+="$(avisa "${base%.md}" "Estado:" "${cru_est# }" "$est" \
      "no está en \`estados.todos\` del manifiesto; ninguna puerta lo reconoce.")" ;;
  esac
  if [ "${ARNES_SENS_DUDOSA:-0}" = "1" ]; then
    bloque+="$(avisa "${base%.md}" "Sensible a seguridad:" "${cru_sens# }" "$ARNES_SENS_CRUDO" \
      "no se lee ni como sí ni como no → se trata como SENSIBLE (lado seguro). Escribe \`sí\` o \`no\`.")"
  fi
  if [ -n "$ARNES_QA" ]; then case "$QA_OK" in *"|$ARNES_QA"*) ;; *)
    bloque+="$(avisa "${base%.md}" "QA:" "${cru_qa# }" "$ARNES_QA" \
      "no es \`aprobado\` ni ningún veredicto conocido → este REQ NO puede cerrarse.")" ;;
  esac; fi
  if [ -n "$ARNES_SEG" ]; then case "$SEG_OK" in *"|$ARNES_SEG"*) ;; *)
    bloque+="$(avisa "${base%.md}" "Seguridad:" "${cru_seg# }" "$ARNES_SEG" \
      "no es un veredicto conocido → si el rigor es \`critico\`, este REQ NO puede cerrarse.")" ;;
  esac; fi
  if [ -n "$cru_rig" ]; then
    arnes_norm_campo "$cru_rig"; r="$ARNES_CAMPO"
    case "$RIG_OK" in *"|$r"*) ;; *)
      bloque+="$(avisa "${base%.md}" "Rigor:" "${cru_rig# }" "$r" \
        "no es un nivel válido → se IGNORA y el REQ se juzga como si no lo declarara.")" ;;
    esac
  fi
  detalle+="$bloque"
done

if [ "$anomalias" -gt 0 ]; then
  printf 'VALORES QUE LA MÁQUINA NO LEE COMO ESTÁN ESCRITOS (%s)\n\n%s' "$anomalias" "$detalle"
else
  printf 'Ningún valor anómalo: la máquina lee los %s REQ como están escritos.\n\n' "$reqs"
fi

printf 'RESUMEN\n'
printf '  %s REQ leídos' "$reqs"
[ "$notas" -gt 0 ] && printf ' · %s archivo(s) sin `Estado:` (notas, no REQ)' "$notas"
printf '\n  rigor efectivo: critico %s · estandar %s · ligero %s\n' "$nc" "$ne" "$nl"
printf '\n  El rigor efectivo es DERIVADO: `Sensible a seguridad: sí` impone `critico`\n'
printf '  aunque no se declare `Rigor:`. Si un REQ que crees crítico sale `estandar`,\n'
printf '  su campo de sensibilidad no se está leyendo como crees.\n'
[ "$anomalias" -eq 0 ]
