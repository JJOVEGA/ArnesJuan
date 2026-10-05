#!/usr/bin/env bash
# corre.sh <hooks> <proy> <cwd|-> <tool> <cwdcr 0|1> <fpcr 0|1> <archivo de destinos>
# Imprime, por destino, la identidad completa y la pertenencia a los tres ambitos, dos pasadas
# (calculo y memoria). El PID propio se reemplaza por PID.
H="$1"; P="$2"; CW="$3"; TOOL="$4"; CWCR="$5"; FPCR="$6"; LISTA="$7"
. "$H/lib.sh"
ARNES_PROJ="$P"; ARNES_TOOL="$TOOL"; ARNES_CWD_CR="$CWCR"; ARNES_FP_CR="$FPCR"
[ "$CW" = - ] && ARNES_CWD='' || ARNES_CWD="$CW"
ARNES_GLOBS=('src/*' 'app/*' 'docs/?.md' '@(app2|zz)/*' 'ñandú/*' 'docs/sub/[ab]*'); ARNES_REQ_DIR=requirements
ARNES_MANIFEST_LISTO=1; ARNES_GLOBS_CARGADOS=1; ARNES_MANIFEST_ROTO=0
mapfile -d '' -t D < "$LISTA"
uno() {
  local d="$1" amb rc
  [ "$TOOL" = Bash ] || ARNES_FP="$d"
  arnes_identidad "$d"
  local s="E=$ARNES_ID_E|C=$ARNES_ID_C|A=$ARNES_ID_A|F=$ARNES_ID_F|F2=$ARNES_ID_F2|L=$ARNES_ID_L|LN=$ARNES_ID_LN|B=$ARNES_ID_B|K=$ARNES_ID_K|X=$ARNES_ID_X|V=$ARNES_ID_V|FD=$ARNES_ID_FD|O=$ARNES_ID_O|R=$ARNES_ID_R"
  for amb in codigo req manifiesto; do
    arnes_identidad "$d"; arnes_id_pertenece "$amb"; rc=$?
    s+="|$amb=$rc:$ARNES_ID_REL:${ARNES_ID_C:0:40}"
  done
  s+="|post:E=$ARNES_ID_E|O=$ARNES_ID_O|X=$ARNES_ID_X|R=$ARNES_ID_R"
  s="${s//$BASHPID/PID}"
  printf '%q\t%s\n' "$d" "$s"
}
for pasada in 1 2; do for d in "${D[@]}"; do printf '%s\t' "$pasada"; uno "$d"; done; done
