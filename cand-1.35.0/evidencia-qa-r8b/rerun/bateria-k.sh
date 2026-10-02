#!/usr/bin/env bash
# bateria-k.sh — P-023-13-A / QA-023-15: el retorno de carro en el texto del comando de `Bash`.
# A nivel de hook. Proyecto fuera de /tmp. Con `docs/k␍` -> ../src/a.ts y `docs/r␍` -> ../requirements/REQ-900.md.
set -u
. "$(dirname "$0")/lib8.sh"
BASEV=/var/tmp/arnes-ev8k-$$; mkdir -p "$BASEV"; trap 'rm -rf "$BASEV"' EXIT
echo "== bateria-k ($(date -Iseconds)); $(uname -r); bash $BASH_VERSION; $(jq --version); $(git --version) =="
proyecto8 "$BASEV/p"
ln -s ../src/a.ts "$P/docs/k$CR"; ln -s ../requirements/REQ-900.md "$P/docs/r$CR"
echo "-- K: los casos medidos por el desarrollador y por QA (r7), mas variantes --"
fila8 "K1 printf x > k␍ (CR final del command), cwd docs" guard.sh "$(j8 Bash "$P/docs" - "command=printf x > k$CR")" deny
fila8 "K2 printf x > k␍␊true (CR antes de un salto), cwd docs" guard.sh "$(j8 Bash "$P/docs" - "command=printf x > k$CR${NL}true")" deny
fila8 "K3 printf x > src/a.ts␍ (el recortado era codigo)" guard.sh "$(j8 Bash "$P" - "command=printf x > src/a.ts$CR")" deny
fila8 "K4 printf x > k␍z (CR en medio), cwd docs" guard.sh "$(j8 Bash "$P/docs" - "command=printf x > k${CR}z")" allow
fila8 "K6 printf x > <raiz>/docs/k␍ (absoluto)" guard.sh "$(j8 Bash "$P" - "command=printf x > $P/docs/k$CR")" deny
fila8 "K7 sed -i que cierra por docs/r␍ (enlace al REQ en rojo)" guard.sh "$(j8 Bash "$P" - "command=sed -i 's/en-revisión/completado/' docs/r$CR")" deny
fila8 "K8 echo x | tee docs/k␍" guard.sh "$(j8 Bash "$P" - "command=echo x | tee docs/k$CR")" deny
fila8 "K9 cp /etc/hostname docs/k␍" guard.sh "$(j8 Bash "$P" - "command=cp /etc/hostname docs/k$CR")" deny
fila8 "K10 printf x > k␍␍ (dos CR finales)" guard.sh "$(j8 Bash "$P/docs" - "command=printf x > k$CR$CR")" allow
fila8 "K11 printf x > k␍ por guard-codigo solo" guard-codigo.sh "$(j8 Bash "$P/docs" - "command=printf x > k$CR")" deny
fila8 "K12 sed -i por docs/r␍ por guard-completado solo" guard-completado.sh "$(j8 Bash "$P" - "command=sed -i 's/en-revisión/completado/' docs/r$CR")" deny
fila8 "K13 desarrollador: printf x > k␍ (puede escribir codigo)" guard.sh "$(j8 Bash "$P/docs" desarrollador "command=printf x > k$CR")" allow
echo "-- Lo legitimo con CR en el texto: se juzga lo que el shell escribe --"
fila8 "KC1 printf x > docs/n.md␍ (escribe docs/n.md␍, fuera)" guard.sh "$(j8 Bash "$P" - "command=printf x > docs/n.md$CR")" allow
fila8 "KC2 ls -la␍" guard.sh "$(j8 Bash "$P" - "command=ls -la$CR")" allow
fila8 "KC3 echo hola␍␊ls␍␊ (comando CRLF sin escrituras)" guard.sh "$(j8 Bash "$P" - "command=echo hola$CR${NL}ls$CR$NL")" allow
fila8 "KC4 printf x > app/a.ts␍ (app/*.ts: el shell escribe app/a.ts␍, que no casa)" guard.sh "$(j8 Bash "$P" - "command=printf x > app/a.ts$CR")" allow
fila8 "KC5 printf x > app/a.ts (control: casa app/*.ts)" guard.sh "$(j8 Bash "$P" - "command=printf x > app/a.ts")" deny
echo "-- H: el delimitador de un heredoc con CR (el analizador no lo sigue: se deniega) --"
H1="cat > docs/x.md <<'EOF'$CR${NL}cuerpo$CR${NL}EOF$CR${NL}echo x > src/a.ts$NL"
fila8 "H1 heredoc CRLF citado y luego echo > src/a.ts" guard.sh "$(j8 Bash "$P" - "command=$H1")" deny
H2="cat > docs/x.md <<'EOF'$CR${NL}cuerpo$CR${NL}EOF$CR$NL"
fila8 "H2 heredoc CRLF citado a docs/x.md (legitimo: de allow a deny)" guard.sh "$(j8 Bash "$P" - "command=$H2")" deny
H3="cat > docs/x.md <<EOF$CR${NL}\$(echo x > src/a.ts)$CR${NL}EOF$CR$NL"
fila8 "H3 heredoc CRLF sin citar con \$(echo > src/a.ts)" guard.sh "$(j8 Bash "$P" - "command=$H3")" deny
H4="cat <<${CR}EOF${NL}don't${NL}${CR}EOF${NL}echo x > 'src/a.ts'$NL"
fila8 "H4 delimitador que EMPIEZA por CR (preexistente: las comillas del cuerpo)" guard.sh "$(j8 Bash "$P" - "command=$H4")" deny
H5="cat > docs/x.md <<'EOF'${NL}cuerpo$CR${NL}EOF${NL}"
fila8 "H5 heredoc con CR solo en el cuerpo (delimitador limpio)" guard.sh "$(j8 Bash "$P" - "command=$H5")" allow
fila8 "H6 desarrollador: H2 por guard-codigo (le estaba permitido escribir)" guard-codigo.sh "$(j8 Bash "$P" desarrollador "command=$H2")" allow
fila8 "H7 desarrollador: H2 por guard.sh (guard-completado lo deniega a todos)" guard.sh "$(j8 Bash "$P" desarrollador "command=$H2")" deny
echo "-- G: guard-git con el CR (el comando que se juzga es el que git recibe) --"
fila8 "G1 git reset --hard␍ (git lo rechaza: opcion desconocida)" guard.sh "$(j8 Bash "$P" - "command=git reset --hard$CR")" allow
fila8 "G2 git reset --hard (control)" guard.sh "$(j8 Bash "$P" - 'command=git reset --hard')" deny
fila8 "G3 git reset --hard ␍ (el CR es otro argumento: --hard se ve)" guard.sh "$(j8 Bash "$P" - "command=git reset --hard $CR")" deny
fila8 "G4 git stash␍ (git: no es un comando)" guard.sh "$(j8 Bash "$P" - "command=git stash$CR")" allow
fila8 "G5 echo␍␊git clean -fd (la segunda orden se ve)" guard.sh "$(j8 Bash "$P" - "command=echo$CR${NL}git clean -fd")" deny
echo "-- El shell y git, de verdad (arbol aparte) --"
T="$BASEV/efecto"; proyecto8 "$T"; ln -s ../src/a.ts "$T/docs/k$CR"
( cd "$T/docs" && bash -c "printf INTRUSO > k$CR" ); printf '   K1: src/a.ts contiene: %s\n' "$(cat "$T/src/a.ts")"
( cd "$T" && bash -c "printf x > docs/n.md$CR" ); printf '   KC1: docs contiene: %s\n' "$(cd "$T/docs" && for f in *; do printf '%q ' "$f"; done)"
( cd "$T" && printf '%s' "$H1" | bash 2>/dev/null ); printf '   H1: src/a.ts contiene: %s\n' "$(cat "$T/src/a.ts")"
G="$BASEV/git"; mkdir -p "$G"; ( cd "$G" && git init -q . && git config user.email t@t && git config user.name t && echo a > f && git add f && git commit -qm a && echo CAMBIO > f && echo u > u.txt
  for c in "git reset --hard$CR" "git stash$CR" "git clean -fd$CR"; do bash -c "$c" >/dev/null 2>&1; echo "   $(printf %q "$c") rc=$? -> f=$(cat f) u.txt=$([ -e u.txt ] && echo sigue || echo borrado) stash=$(git stash list | wc -l)"; done )
