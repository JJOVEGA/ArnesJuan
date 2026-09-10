#!/usr/bin/env bash
# Sonda QA (solo lectura sobre hooks/lib.sh @1154417): verdad de terreno de _arnes_clave_oculta
. "$1/hooks/lib.sh" 2>/dev/null || { echo "no se pudo cargar lib.sh"; exit 2; }
probe() {
  ARNES_CLAVE_OCULTA=0; ARNES_CLAVE_OCULTA_CLAVE=''; ARNES_CLAVE_OCULTA_REPR=''
  _arnes_clave_oculta "$2"
  printf '%-34s | entrada=%-28q | oculta=%s clave=%-22s repr=%s\n' "$1" "$2" "${ARNES_CLAVE_OCULTA:-0}" "${ARNES_CLAVE_OCULTA_CLAVE:-()}" "${ARNES_CLAVE_OCULTA_REPR:-()}"
}
echo "ALFABETO=[$ARNES_CLAVES_ALFA]"
echo "MAPA=$ARNES_CLAVES_MAPA"
echo "---"
probe "clave limpia"                 'Estado'
probe "blanco DUPLICADO"             'Sensible a  seguridad'
probe "blanco BORRADO (sin blancos)" 'Sensibleaseguridad'
probe "NBSP DENTRO de la palabra"    "$(printf 'Est\xc2\xa0ado')"
probe "NBSP en sitio del blanco"     "$(printf 'Sensible a\xc2\xa0seguridad')"
probe "TAB en sitio del blanco"      "$(printf 'Hallazgos\tabiertos')"
probe "ZWSP delante"                 "$(printf '\xe2\x80\x8bEstado')"
probe "BOM delante"                  "$(printf '\xef\xbb\xbfEstado')"
probe "HOMOGLIFO E cirilica"         "$(printf '\xd0\x95stado')"
probe "HOMOGLIFO a cirilica"         "$(printf 'Sensible \xd0\xb0 seguridad')"
probe "clave ajena (Modulo)"         'Módulo'
probe "clave ajena (Archivos)"       'Archivos'
