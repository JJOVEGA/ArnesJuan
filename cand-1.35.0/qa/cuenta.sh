# cuenta.sh <hooks>  (JSON por stdin): corre el mismo camino que guard.sh contando invocaciones
H="$1"; DIR="$H"
. "$H/lib.sh"; . "$H/guard-git.sh"; . "$H/guard-codigo.sh"; . "$H/guard-completado.sh"
NC=0; NV=0; NL=0
eval "$(declare -f arnes_norm_clave | sed '1s/arnes_norm_clave/__o_norm_clave/')"
eval "$(declare -f arnes_norm_campo | sed '1s/arnes_norm_campo/__o_norm_campo/')"
arnes_norm_clave() { NC=$((NC+1)); __o_norm_clave "$@"; }
arnes_norm_campo() { NV=$((NV+1)); __o_norm_campo "$@"; }
trap 'echo "norm_clave=$NC norm_campo=$NV" >&2' EXIT
arnes_preludio || exit 0
arnes_guard_git; arnes_guard_codigo; arnes_guard_completado; arnes_emitir_avisos
