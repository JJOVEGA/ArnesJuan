#!/usr/bin/env bash
# 42-segv-y-s130.sh <scratch> <hooks>
#  G8: un desbordamiento de pila REAL (recursión sin fondo) dentro de arnes_guard_completado, en una copia:
#      ¿la trampa emite, y con qué código de salida sale el hook?
#  S130-lib: arnes_estado_ausente a nivel de librería con `ulimit -n 3` (la redirección del grupo falla): ¿qué
#      devuelve con un texto que SÍ menciona el estado terminal? Y el control sin límite.
set -u
S="${1:?}"; H="${2:?}"; W="$(mktemp -d "$S/segv-XXXX")"; trap 'rm -rf "$W"' EXIT
QD="$(cd "$(dirname "$0")" && pwd)"; . "$QD/h.sh"; P="$W/p"; mkp "$P"
mkdir -p "$W/G8"; cp -r "$H" "$W/G8/hooks"; sed -i '/^arnes_guard_completado() {/a\  _qa_r() { _qa_r; }; _qa_r' "$W/G8/hooks/guard-completado.sh"
in_bash 'ls -la' > "$W/b4"; in_bash "sed -i 's/en-revisión/completado/' requirements/REQ-900.md" > "$W/b3"
echo "# $(date -Is); bash $BASH_VERSION; ulimit -s $(ulimit -s)"
for b in b3 b4; do echo "G8 $b guard.sh $(corre "$W/G8/hooks" guard.sh "$W/$b")"; done
T='sed -i s/en-revisión/completado/ requirements/REQ-900.md'
echo "S130-lib control (sin límite): rc=$(bash -c '. "$1/lib.sh" >/dev/null 2>&1; arnes_estado_ausente "$2" completado; echo $?' _ "$H" "$T")  (1 = puede mencionarlo: decide grep)"
echo "S130-lib con ulimit -n 3:      rc=$(bash -c '. "$1/lib.sh" >/dev/null 2>&1; ulimit -n 3; arnes_estado_ausente "$2" completado; echo $?' _ "$H" "$T")  (0 = afirma la ausencia sin comprobarla)"
