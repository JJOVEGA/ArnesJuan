#!/usr/bin/env bash
# bateria-correctiva.sh — pasada correctiva de la octava autorizacion: P-122-A (1), QA-023-16 y
# QA-023-17 (= P-122-A (2)). A nivel de hook, en CINCO arboles: candidata, 9220c71 (fail-before de esta
# pasada), 3bc7d3c, 9596e39 y 1.33.2. Proyecto fuera de /tmp. Esto no es el host.
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/lib8.sh
ARB[9220c71]=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8b/arb/9220c71/hooks
ORDEN=(cand 9220c71 3bc7d3c 9596e39 1.33.2)
# fila9 <id> <guardian> <json> <esperado>: decision por arbol, movimientos frente a 9596e39 y 1.33.2.
fila9() {
  local id="$1" g="$2" js="$3" esp="$4" a linea='' dc='' mc='' d95='' d33='' mv='' ok
  for a in "${ORDEN[@]}"; do
    llama8 "$a" "$g" "$js"; linea+="$a=$D "
    case "$a" in cand) dc="$D"; mc="$M" ;; 9596e39) d95="$D" ;; 1.33.2) d33="$D" ;; esac
  done
  case "$dc:$d95" in allow:deny) mv+=' <<deny->allow vs 9596e39>>' ;; deny:allow) mv+=' [allow->deny vs 9596e39]' ;; esac
  case "$dc:$d33" in allow:deny) mv+=' <<deny->allow vs 1.33.2>>' ;; esac
  [ "$dc" = "$esp" ] && ok=' OK' || ok=" ESPERADO=$esp"
  printf '%-66s %s%s%s\n      motivo(cand): %s\n' "$id [$g]" "$linea" "$mv" "$ok" "$(printf '%q' "${mc:0:300}")"
}
BASEV=/var/tmp/arnes-ev8b-$$; mkdir -p "$BASEV"; trap 'rm -rf "$BASEV"' EXIT
echo "== bateria-correctiva ($(date -Iseconds)); $(uname -r); bash $BASH_VERSION; $(jq --version); $(git --version) =="
echo "   sha256 lib.sh cand $(sha256sum < "${ARB[cand]}/lib.sh" | cut -c1-16) · guard-git.sh cand $(sha256sum < "${ARB[cand]}/guard-git.sh" | cut -c1-16)"
proyecto8 "$BASEV/p"
ln -s /dev/stderr "$P/src/log"; ln -s /dev/stderr "$P/docs/err"; ln -s /dev/stderr "$R/log"
GC="git checkout"; GR="git restore"; GS="git stash"
echo "-- guard-git: un retorno de carro pegado a las palabras de una orden de git --"
fila9 "C1 git reset --hard + CR (G1)"            guard-git.sh "$(j8 Bash "$P" - "command=git reset --hard$CR")" deny
fila9 "C2 git stash + CR (P-122-A 1)"            guard-git.sh "$(j8 Bash "$P" - "command=$GS$CR")" deny
fila9 "C3 git checkout . + CR (QA-023-16)"       guard-git.sh "$(j8 Bash "$P" - "command=$GC .$CR")" deny
fila9 "C4 git checkout -- . + CR (QA-023-16)"    guard-git.sh "$(j8 Bash "$P" - "command=$GC -- .$CR")" deny
fila9 "C5 git restore . + CR (QA-023-16)"        guard-git.sh "$(j8 Bash "$P" - "command=$GR .$CR")" deny
fila9 "C6 git checkout HEAD . + CR (QA-023-16)"  guard-git.sh "$(j8 Bash "$P" - "command=$GC HEAD .$CR")" deny
fila9 "C7 git clean + CR en medio + -f (preexistente)" guard-git.sh "$(j8 Bash "$P" - "command=git clean$CR -f")" deny
fila9 "C8 git re + CR + set --hard (CR dentro de la palabra)" guard-git.sh "$(j8 Bash "$P" - "command=git re${CR}set --hard")" deny
fila9 "C9 git stash + CR + LF + ls (CR antes de un salto)" guard-git.sh "$(j8 Bash "$P" - "command=$GS$CR${NL}ls")" deny
fila9 "C10 git status + CR (control: no esta en la lista)" guard-git.sh "$(j8 Bash "$P" - "command=git status$CR")" allow
fila9 "C11 git stash list + CR (control: lectura)"      guard-git.sh "$(j8 Bash "$P" - "command=$GS list$CR")" allow
fila9 "C12 git restore --staged + CR + . (control: ya denegaba)" guard-git.sh "$(j8 Bash "$P" - "command=$GR --staged$CR .")" deny
fila9 "C13 git log + CR + LF + echo hecho (control)"     guard.sh "$(j8 Bash "$P" - "command=git log$CR${NL}echo hecho")" allow
fila9 "C14 git commit -m con CR entrecomillado (control)" guard.sh "$(j8 Bash "$P" - "command=git commit -m 'a${CR}b'")" allow
fila9 "C15 printf x > docs/n.md + CR (control: no es git)" guard.sh "$(j8 Bash "$P" - "command=printf x > docs/n.md$CR")" allow
echo "-- QA-023-17: un enlace del ultimo componente DENTRO de un ambito que lleva a un descriptor --"
fila9 "D1 coordinadora: echo x > src/log (src/log -> /dev/stderr)" guard-codigo.sh "$(j8 Bash "$P" - 'command=echo x > src/log')" deny
fila9 "D2 lo mismo por guard.sh"                          guard.sh "$(j8 Bash "$P" - 'command=echo x > src/log')" deny
fila9 "D3 sed -i que cierra por requirements/log (-> /dev/stderr)" guard-completado.sh "$(j8 Bash "$P" - "command=sed -i 's/x/completado/' requirements/log")" deny
fila9 "D4 desarrollador: echo x > src/log (control)"      guard.sh "$(j8 Bash "$P" desarrollador 'command=echo x > src/log')" allow
fila9 "D5 coordinadora: echo x > docs/err (-> /dev/stderr, fuera)" guard.sh "$(j8 Bash "$P" - 'command=echo x > docs/err')" allow
fila9 "D6 coordinadora: echo x > /dev/stderr (control)"   guard.sh "$(j8 Bash "$P" - 'command=echo x > /dev/stderr')" allow
fila9 "D7 coordinadora: echo x > /dev/fd/2 (control)"     guard.sh "$(j8 Bash "$P" - 'command=echo x > /dev/fd/2')" allow
fila9 "D8 coordinadora: Write src/log (Edit/Write: CA-49 (i))" guard.sh "$(j8 Write "$P" - "file_path=$P/src/log" content=x)" deny
echo "-- Efecto, de verdad (arbol aparte): git con la configuracion por defecto y con help.autocorrect=immediate --"
G="$BASEV/git"; mkdir -p "$G"
( cd "$G" && git init -q . && git config user.email t@t && git config user.name t && echo a > f && git add f && git commit -qm a
  for modo in defecto immediate; do
    [ "$modo" = immediate ] && git config help.autocorrect immediate
    echo CAMBIO > f
    bash -c "$GS$CR" >/dev/null 2>&1
    echo "   $modo: tras 'git stash'+CR -> f=$(cat f) stash=$(git stash list | wc -l)"
    git stash pop -q >/dev/null 2>&1; git checkout -q -- f 2>/dev/null
  done )
echo "-- Efecto del descriptor: echo x > src/log escribe en stderr, no en un archivo de src/ --"
( cd "$P" && echo INTRUSO > src/log ) 2>"$BASEV/stderr-del-efecto"; printf '   src/: %s ; src/a.ts=%s ; lo escrito fue a stderr: %s\n' "$(ls "$P/src" | tr '\n' ' ')" "$(cat "$P/src/a.ts")" "$(cat "$BASEV/stderr-del-efecto")"
