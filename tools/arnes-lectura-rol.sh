#!/usr/bin/env bash
# arnes-lectura-rol.sh — archivo de lectura por rol (REQ-036 CA-18, P-137-Z (A)).
#
# Uso: tools/arnes-lectura-rol.sh [--verificar] [ruta-del-proyecto]     (por defecto, el directorio actual)
#
# QUÉ HACE. Escribe `.arnes/lectura/{analista,desarrollador,qa,seguridad}.md`: cada uno es la cabecera de tres
# líneas, una línea en blanco y la CONCATENACIÓN EXACTA, sin cambiar un byte, de los bloques de `AGENTS.md` y
# luego de `requirements/README.md` (siempre los de la raíz del proyecto) cuya marca nombra al rol o dice
# `todos`, más todo bloque cuya obligación no se puede leer (ante la duda, se lee). Sólo queda fuera un bloque
# `explicativo`. Un bloque va de su marca (línea que empieza por `[[`) a la línea anterior a la siguiente; lo
# que precede a la primera marca no es bloque. La regla de las marcas vive en A-00 de `AGENTS.md`.
# Es un DERIVADO: nunca una segunda redacción, y se pisa en la siguiente generación.
#
# FRESCURA. Si un archivo ya es idéntico no se reescribe, pero se le pone la fecha de ahora: el agente lo usa
# sólo si ninguna fuente es más reciente que él, y un archivo al día no debe parecer viejo tras un checkout.
# Con `--verificar` no escribe nada y sale 1 si algún archivo falta o no es lo que se generaría.
#
# FALLOS. Toda generación fallida (fuente ausente o ilegible, `.arnes` ausente, enlace simbólico, destino no
# escribible, falta `sha256sum`) BORRA los cuatro archivos y sale 1: un archivo ausente se lee por marcas, así
# que todo fallo termina en leer más, nunca en leer una norma vieja. Nunca sigue un enlace simbólico: con
# `.arnes` o `.arnes/lectura` como enlace no escribe ni borra nada; un destino que es enlace se quita, no se sigue.
#
# COSTE. Sin jq ni red; sólo órdenes internas de bash más `sha256sum` (una vez), `touch` (sólo si hay archivos al
# día), `mkdir` (sólo si falta el directorio) y un `mv` por archivo que cambia (temporal del mismo directorio y
# renombrado: nunca un archivo a medias).
set -u
LC_ALL=C   # ${#v} cuenta bytes y los patrones comparan bytes
set -C     # noclobber: el temporal nunca pisa (ni sigue) algo que ya exista
set -f     # sin expansión de comodines: ninguna palabra de las fuentes se interpreta como ruta

ROLES=(analista desarrollador qa seguridad)
VERIFICAR=no
PROY=.
case "${1:-}" in
  --verificar) VERIFICAR=si; shift ;;
  -*) printf 'uso: arnes-lectura-rol.sh [--verificar] [ruta-del-proyecto]\n' >&2; exit 2 ;;
esac
[ "$#" -le 1 ] || { printf 'uso: arnes-lectura-rol.sh [--verificar] [ruta-del-proyecto]\n' >&2; exit 2; }
[ -n "${1:-}" ] && PROY="$1"

ARNES="$PROY/.arnes"; DIR="$ARNES/lectura"
FUENTES=("$PROY/AGENTS.md" "$PROY/requirements/README.md")
NOMBRES=(AGENTS.md requirements/README.md)

# borra_derivados: el destino de todo fallo. No toca nada si el camino pasa por un enlace simbólico.
borra_derivados() {
  local r f=()
  [ -L "$ARNES" ] || [ -L "$DIR" ] || [ ! -d "$DIR" ] && return 0
  for r in "${ROLES[@]}"; do
    [ -e "$DIR/$r.md" ] || [ -L "$DIR/$r.md" ] && f+=("$DIR/$r.md")
  done
  [ "${#f[@]}" -eq 0 ] || rm -f -- "${f[@]}" 2>/dev/null
  return 0
}
falla() {
  printf 'arnes-lectura-rol: %s\n' "$1" >&2
  [ "$VERIFICAR" = si ] || borra_derivados
  exit 1
}

# roles_de <marca sin salto>: deja en INCLUYE los roles (de ROLES) que leen el bloque. Fail-safe: una marca
# que no se puede leer, o sin ningún rol reconocido, la leen los cuatro; sólo `explicativo` no la lee nadie.
roles_de() {
  local m="$1" t lista rec=no
  INCLUYE=()
  m="${m%"${m##*[![:space:]]}"}"            # sin blancos finales (incluido un \r de fin de línea CRLF)
  case "$m" in
    '[['*']]') m="${m#\[\[}"; m="${m%\]\]}" ;;
    *) printf 'arnes-lectura-rol: aviso: marca sin cierre, la leen todos: %.60s\n' "$m" >&2
       INCLUYE=("${ROLES[@]}"); return 0 ;;
  esac
  case "$m" in
    *obliga:*) lista="${m#*obliga:}" ;;
    *explicativo*) return 0 ;;
    *) printf 'arnes-lectura-rol: aviso: marca sin `obliga:`, la leen todos: %.60s\n' "$m" >&2
       INCLUYE=("${ROLES[@]}"); return 0 ;;
  esac
  lista="${lista,,}"; lista="${lista//[[:space:]]/}"
  local IFS=,
  for t in $lista; do
    case "$t" in
      todos) INCLUYE=("${ROLES[@]}"); return 0 ;;
      analista|desarrollador|qa|seguridad) INCLUYE+=("$t"); rec=si ;;
      coordinadora) rec=si ;;
    esac
  done
  if [ "$rec" = no ]; then
    printf 'arnes-lectura-rol: aviso: marca sin ningún rol reconocido, la leen todos: %.60s\n' "$m" >&2
    INCLUYE=("${ROLES[@]}")
  fi
  return 0
}

# --- Fuentes: legibles, y leídas línea a línea CON su salto (mapfile sin -t): la concatenación es exacta. ----
for f in "${FUENTES[@]}"; do
  [ -f "$f" ] && [ -r "$f" ] || falla "fuente ausente o ilegible: $f"
done
command -v sha256sum >/dev/null 2>&1 || falla 'falta sha256sum'
SAL="$(sha256sum -- "${FUENTES[@]}" 2>/dev/null)" || falla 'sha256sum no pudo leer las fuentes'
SUMAS=()   # una línea por fuente, en orden: «<64 hex>  <ruta>»; una ruta rara la escapa con «\» y no pasa
while read -r h _; do SUMAS+=("$h"); done <<< "$SAL"
[ "${#SUMAS[@]}" -eq 2 ] && [[ ${SUMAS[0]} =~ ^[0-9a-f]{64}$ && ${SUMAS[1]} =~ ^[0-9a-f]{64}$ ]] \
  || falla 'sha256sum dio una salida inesperada'

declare -A CUERPO=()
FUENTES_CAB=''
for i in 0 1; do
  mapfile LINEAS < "${FUENTES[$i]}" || falla "no se pudo leer ${FUENTES[$i]}"
  n=0; leen=()   # antes de la primera marca, nadie: el título no es bloque
  for l in "${LINEAS[@]}"; do
    n=$((n + ${#l}))
    if [ "${l:0:2}" = '[[' ]; then roles_de "${l%$'\n'}"; leen=("${INCLUYE[@]}"); fi
    for r in "${leen[@]}"; do CUERPO[$r]+="$l"; done
  done
  FUENTES_CAB+="${FUENTES_CAB:+; }${NOMBRES[$i]} $n B sha256 ${SUMAS[$i]}"
done

# --- Destino: ni `.arnes` ni `.arnes/lectura` pueden ser enlaces; `.arnes` tiene que existir ya. -------------
[ -L "$ARNES" ] && falla '.arnes es un enlace simbólico: no se escribe'
[ -L "$DIR" ] && falla '.arnes/lectura es un enlace simbólico: no se escribe'
[ -d "$ARNES" ] || falla "no existe $ARNES"

AL_DIA=(); NUEVOS=(); DISTINTO=no
for r in "${ROLES[@]}"; do
  esperado="<!-- DERIVADO — no editar a mano: lo genera tools/arnes-lectura-rol.sh y se pisa en la siguiente generación. -->
<!-- Rol: $r -->
<!-- Fuentes: $FUENTES_CAB -->

${CUERPO[$r]:-}"
  d="$DIR/$r.md"; actual=''
  if [ -L "$d" ]; then
    [ "$VERIFICAR" = si ] && { DISTINTO=si; continue; }
    falla "el destino es un enlace simbólico: $d"
  fi
  if [ -f "$d" ] && [ -r "$d" ]; then
    mapfile LINEAS < "$d"; printf -v actual '%s' "${LINEAS[@]}"
  fi
  if [ -f "$d" ] && [ ! -L "$d" ] && [ "$actual" = "$esperado" ]; then AL_DIA+=("$d"); continue; fi
  DISTINTO=si
  [ "$VERIFICAR" = si ] && continue
  [ -d "$DIR" ] || mkdir -p -- "$DIR" 2>/dev/null || falla "no se pudo crear $DIR"
  [ -d "$d" ] && falla "el destino es un directorio: $d"
  tmp="$DIR/.$r.md.tmp.$$"
  { printf '%s' "$esperado" > "$tmp"; } 2>/dev/null || { rm -f -- "$tmp" 2>/dev/null; falla "no se pudo escribir $tmp"; }
  mv -f -- "$tmp" "$d" 2>/dev/null || { rm -f -- "$tmp" 2>/dev/null; falla "no se pudo renombrar a $d"; }
  NUEVOS+=("$d")
done

if [ "$VERIFICAR" = si ]; then
  [ "$DISTINTO" = no ] || { printf 'arnes-lectura-rol: algún archivo por rol falta o no es el que se generaría\n' >&2; exit 1; }
  exit 0
fi
# Un archivo idéntico no se reescribe, pero se fecha ahora (frescura del agente: ver arriba).
if [ "${#AL_DIA[@]}" -gt 0 ]; then touch -c -- "${AL_DIA[@]}" 2>/dev/null || falla 'no se pudo actualizar la fecha'; fi
exit 0
