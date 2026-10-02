#!/usr/bin/env bash
# Batería G (QA r8): guard-git y un retorno de carro pegado a un token de git.prohibidos. Decisión a nivel de
# hook (guard.sh, coordinadora) en cuatro árboles, y conducta REAL de git, en un repositorio desechable, con su
# configuración por defecto y con help.autocorrect=immediate (configuración LOCAL del repositorio de prueba).
EVQ=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8
. "$EVQ/rerun/lib8.sh"
proyecto8 "$EVQ/g-proj"
GR="$EVQ/g-repos"; rm -rf "$GR"; mkdir -p "$GR"
mkrepo() {   # <dir> [autocorrect]
  rm -rf "$1"; mkdir -p "$1"; ( cd "$1" && git init -q && git config user.email qa@x && git config user.name qa \
    && printf 'v1\n' > a.txt && git add a.txt && git commit -qm c1 && printf 'v2\n' > a.txt && printf 'u\n' > u.txt
    [ -z "${2:-}" ] || git config help.autocorrect "$2" )
}
estado() { ( cd "$1" && printf 'a.txt=%s u.txt=%s stash=%s' "$(cat a.txt 2>/dev/null || echo AUSENTE)" "$( [ -e u.txt ] && echo presente || echo BORRADO)" "$(git stash list | wc -l)" ); }
efecto() {   # <comando literal>
  local m d
  for m in defecto immediate; do
    d="$GR/r-$m"; if [ $m = defecto ]; then mkrepo "$d"; else mkrepo "$d" immediate; fi
    ( cd "$d" && bash -c "$1" >/dev/null 2>"$GR/err"; echo "rc=$?" > "$GR/rc" )
    printf '      git (%s): %s · %s · %s\n' "$m" "$(cat "$GR/rc")" "$(estado "$d")" "$(head -c 150 "$GR/err" | tr '\n\r' '  ')"
  done
}
echo "== Batería G (QA r8) $(date -Iseconds); $(git --version); estado inicial de cada repo: a.txt=v2 (modificado), u.txt sin seguimiento, stash vacío =="
c() { fila8 "$1" guard.sh "$(j8 Bash "$P" - "command=$2")"; efecto "$2"; }
c "G2c git stash (control)"                      "git stash"
c "G4 git stash<CR>"                             "git stash$CR"
c "G4b git stash<CR> push"                       "git stash$CR push"
c "G6 git clean<CR> -f"                          "git clean$CR -f"
c "G7 git clean -f<CR>"                          "git clean -f$CR"
c "G8 git checkout<CR> ."                        "git checkout$CR ."
c "G9 git checkout .<CR>"                        "git checkout .$CR"
c "G10 git restore<CR> ."                        "git restore$CR ."
c "G1 git reset --hard<CR>"                      "git reset --hard$CR"
c "G11 git reset<CR> --hard"                     "git reset$CR --hard"
c "G2 git reset --hard (control)"                "git reset --hard"
rm -rf "$GR" "$EVQ/g-proj"
