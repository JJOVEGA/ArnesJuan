#!/usr/bin/env bash
# 40-finales.sh <scratch> <hooks> — CA-68 (i) y R2: finales sin juicio que el desarrollador NO inyectó (F1-F4 son
# suyos). Fallos INYECTADOS en COPIAS de los hooks, nunca en el árbol. Por cada copia, la decisión por guard.sh
# (y por el guardián suelto cuando se indica) en cinco vectores: tres que esperan deny y dos sin decisión.
#   G1  `exit 3` a mitad de arnes_guard_codigo (salida inesperada)
#   G2a/b/c/d  el analizador de escrituras devuelve 1 / 6 / 127 / 255
#   G3  el proceso recibe SIGTERM dentro de arnes_guard_completado (kill -TERM $$)
#   G4  el proceso recibe SIGSEGV dentro de arnes_guard_completado (kill -SEGV $$): un final que bash no atrapa
#   G5  `return 1` a mitad de arnes_guard_git (una puerta que vuelve con error)
#   G6  `exit 0` a mitad de arnes_guard_codigo (una salida «limpia» sin juicio)
#   G7  lib.sh termina con `exec 1>&-` justo antes de emitir (stdout cerrado) — informativo
#   S130  SEC-130: `ulimit -n 3` justo antes de `arnes_estado_ausente` en guard-completado: la redirección del
#         grupo falla y la función afirma la ausencia sin comprobarla. ¿R2 lo ve?
set -u
S="${1:?}"; H="${2:?}"; W="$(mktemp -d "$S/fin-XXXX")"; trap 'rm -rf "$W"' EXIT
QD="$(cd "$(dirname "$0")" && pwd)"; . "$QD/h.sh"
P="$W/p"; mkp "$P"
copia() { mkdir -p "$W/$1"; cp -r "$H" "$W/$1/hooks"; cp -r "$H/../tools" "$W/$1/tools" 2>/dev/null
  [ -z "$2" ] || sed -i "$3" "$W/$1/hooks/$2"
  [ -z "$2" ] || ! cmp -s "$H/$2" "$W/$1/hooks/$2" || echo "AVISO: la inyección $1 no cambió $2"; }
copia G0 '' ''
copia G1 guard-codigo.sh '/^arnes_guard_codigo() {/a\  exit 3'
copia G2a lib.sh '/^arnes_bash_escrituras() {/a\  return 1'
copia G2b lib.sh '/^arnes_bash_escrituras() {/a\  return 6'
copia G2c lib.sh '/^arnes_bash_escrituras() {/a\  return 127'
copia G2d lib.sh '/^arnes_bash_escrituras() {/a\  return 255'
copia G3 guard-completado.sh '/^arnes_guard_completado() {/a\  kill -TERM $$'
copia G4 guard-completado.sh '/^arnes_guard_completado() {/a\  kill -SEGV $$'
copia G5 guard-git.sh '/^arnes_guard_git() {/a\  return 1'
copia G6 guard-codigo.sh '/^arnes_guard_codigo() {/a\  exit 0'
copia S130 guard-completado.sh 's/^\(    \)arnes_estado_ausente "\$bash_cmd" "\$estado_done" \&\& return 0/\1ulimit -n 3; arnes_estado_ausente "$bash_cmd" "$estado_done" \&\& return 0/'
in_bash 'echo x > src/a.ts' > "$W/b1"; in_bash 'git reset --hard' > "$W/b2"
in_bash "sed -i 's/en-revisión/completado/' requirements/REQ-900.md" > "$W/b3"
in_bash 'ls -la' > "$W/b4"; in_write docs/n.md x > "$W/b5"; in_write src/a.ts x > "$W/b6"
echo "# $(date -Is); bash $BASH_VERSION; hooks $H"
for c in G0 G1 G2a G2b G2c G2d G3 G4 G5 G6 S130; do
  for b in b1 b2 b3 b4 b5 b6; do printf '%-5s %s guard.sh %s\n' "$c" "$b" "$(corre "$W/$c/hooks" guard.sh "$W/$b")"; done
done
for c in G0 G2a G3 S130; do for b in b1 b3 b4; do printf '%-5s %s guard-completado.sh %s\n' "$c" "$b" "$(corre "$W/$c/hooks" guard-completado.sh "$W/$b")"; done; done
for c in G0 G1 G2a G6; do for b in b1 b4 b6; do printf '%-5s %s guard-codigo.sh %s\n' "$c" "$b" "$(corre "$W/$c/hooks" guard-codigo.sh "$W/$b")"; done; done
echo "# REQ-900 en disco tras todo (no se aplica ninguna herramienta): $(grep -c '^Estado: en-revisión' "$P/requirements/REQ-900.md") línea(s) en-revisión"
