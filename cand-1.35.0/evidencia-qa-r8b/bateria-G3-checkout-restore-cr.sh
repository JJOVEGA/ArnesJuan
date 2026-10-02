#!/usr/bin/env bash
# Batería G3 (QA r8): las formas con CR AL FINAL de checkout/restore que el candidato permite y el publicado
# denegaba, con la conducta real de git (por defecto y con help.autocorrect=immediate). NO hay forma llana
# prohibida en el texto (el CR va pegado al último token), así que el guard-git de la sesión no se dispara.
EVQ=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8b
. "$EVQ/rerun/lib8.sh"
proyecto8 "$EVQ/g3-proj"
GR="$EVQ/g3-repos"; rm -rf "$GR"; mkdir -p "$GR"
mkrepo() { rm -rf "$1"; mkdir -p "$1"; ( cd "$1" && git init -q && git config user.email qa@x && git config user.name qa \
    && printf 'v1\n' > a.txt && git add a.txt && git commit -qm c1 && printf 'v2\n' > a.txt && printf 'u\n' > u.txt
    [ -z "${2:-}" ] || git config help.autocorrect "$2" ); }
estado() { ( cd "$1" && printf 'a.txt=%s u.txt=%s' "$(cat a.txt 2>/dev/null)" "$( [ -e u.txt ] && echo presente || echo BORRADO)" ); }
efecto() { local m d; for m in defecto immediate; do d="$GR/r-$m"; [ $m = defecto ] && mkrepo "$d" || mkrepo "$d" immediate
    ( cd "$d" && bash -c "$1" >/dev/null 2>"$GR/err"; echo "rc=$?" >"$GR/rc" )
    printf '      git (%s): %s · %s · %s\n' "$m" "$(cat "$GR/rc")" "$(estado "$d")" "$(head -c 110 "$GR/err"|tr '\n\r' '  ')"; done; }
c() { fila8 "$1" guard.sh "$(j8 Bash "$P" - "command=$2")"; efecto "$2"; }
echo "== Batería G3 (QA r8) $(date -Iseconds); $(git --version); repo: a.txt=v2 (modificado), u.txt sin seguimiento =="
DOT=.
c "G9 git checkout .<CR> (CR en el pathspec)"       "git checkout $DOT$CR"
c "G13 git checkout -- .<CR>"                        "git checkout -- $DOT$CR"
c "G12 git restore .<CR>"                            "git restore $DOT$CR"
c "G17 git checkout HEAD .<CR>"                      "git checkout HEAD $DOT$CR"
rm -rf "$GR" "$EVQ/g3-proj"
