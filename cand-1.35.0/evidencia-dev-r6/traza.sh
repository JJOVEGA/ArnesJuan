H="$1"; export CLAUDE_PROJECT_DIR="$2"
. "$H/lib.sh"; . "$H/guard-git.sh"; . "$H/guard-codigo.sh"; . "$H/guard-completado.sh"
arnes_preludio < "$3" || exit 0
exec 9>"$4"; BASH_XTRACEFD=9
PS4='+${EPOCHREALTIME}|${FUNCNAME[0]:-main}|${LINENO}| '
set -x
arnes_guard_codigo
arnes_guard_completado
set +x
