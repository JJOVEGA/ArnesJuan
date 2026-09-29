#!/usr/bin/env bash
# lectores.sh <dir de hooks> <archivos...> -> una línea por archivo con los valores que lee la PUERTA
# (arnes_estado_cabecera + arnes_campos_req, del lib.sh de ese árbol) y, aparte, los del awk del bloque derivado.
H="$1"; shift
. "$H/lib.sh"
for f in "$@"; do
  arnes_lee_archivo "$f" || { echo "$f|ILEGIBLE"; continue; }
  t="$ARNES_TEXTO"
  arnes_estado_cabecera "$t"; e="$ARNES_ESTADO"
  arnes_campos_req "$t" ''
  printf '%s|est=%s|qa=%s|seg=%s|sens=%s|hall=%s|rig=%s|cita=%s|cr=%s|halln=%s\n' "${f##*/}" "$e" "$ARNES_QA" "$ARNES_SEG" "$ARNES_SENS" "$ARNES_HALL" "$ARNES_RIGOR" "$ARNES_CITA_ABIERTA" "$ARNES_CR_INTERIOR" "${ARNES_HALL_N:-}"
done
