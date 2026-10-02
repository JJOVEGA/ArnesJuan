#!/usr/bin/env bash
# Batería R (QA r8b): intentar romper la pasada correctiva. A nivel de hook, cuatro árboles (cand, 9220c71, 9596e39, 1.33.2).
EVQ=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8b
. "$EVQ/rerun/lib8.sh"
proyecto8 "$EVQ/r-proj"
mkdir -p "$P/src/sub"
ln -s /dev/fd "$P/src/fdd"            # directorio de descriptores dentro del ámbito
ln -s /proc/self/fd "$P/src/pfd"      # idem por /proc/self
ln -s /dev/stdout "$P/src/sub/out"    # enlace a descriptor un nivel más abajo
ln -s ../src/log2 "$P/docs/cadena"; ln -s /dev/stderr "$P/src/log2"   # cadena: docs/cadena -> src/log2 -> /dev/stderr
ln -s /dev/stderr "$P/app/w.ts"       # dentro de app/*.ts
echo "== Batería R (QA r8b) $(date -Iseconds) =="
echo "-- QA-023-17: variantes del enlace a un descriptor dentro del ámbito --"
fila8 "R1 coordinadora echo x > src/fdd/2 (src/fdd -> /dev/fd)" guard.sh "$(j8 Bash "$P" - 'command=echo x > src/fdd/2')"
fila8 "R2 coordinadora echo x > src/pfd/1 (src/pfd -> /proc/self/fd)" guard.sh "$(j8 Bash "$P" - 'command=echo x > src/pfd/1')"
fila8 "R3 coordinadora echo x > src/sub/out (-> /dev/stdout, más hondo)" guard.sh "$(j8 Bash "$P" - 'command=echo x > src/sub/out')"
fila8 "R4 coordinadora echo x > docs/cadena (fuera -> src/log2 -> /dev/stderr)" guard.sh "$(j8 Bash "$P" - 'command=echo x > docs/cadena')"
fila8 "R5 coordinadora echo x > app/w.ts (app/*.ts -> /dev/stderr)" guard.sh "$(j8 Bash "$P" - 'command=echo x > app/w.ts')"
fila8 "R6 coordinadora echo x 2> src/log2 (redirección de stderr)" guard.sh "$(j8 Bash "$P" - 'command=echo x 2> src/log2')"
fila8 "R7 coordinadora ls -la > /dev/stderr (control legítimo)" guard.sh "$(j8 Bash "$P" - 'command=ls -la > /dev/stderr')"
fila8 "R8 coordinadora echo x > /proc/self/fd/2 (control legítimo)" guard.sh "$(j8 Bash "$P" - 'command=echo x > /proc/self/fd/2')"
fila8 "R9 desarrollador echo x > src/fdd/2 (control)" guard.sh "$(j8 Bash "$P" desarrollador 'command=echo x > src/fdd/2')"
echo "-- P-122-A (1) / QA-023-16: variantes del CR en una orden de git --"
fila8 "R10 git sta<CR>sh (CR parte el subcomando)" guard.sh "$(j8 Bash "$P" - "command=git sta${CR}sh")"
fila8 "R11 git reset --ha<CR>rd" guard.sh "$(j8 Bash "$P" - "command=git reset --ha${CR}rd")"
fila8 "R12 git<CR> stash (CR pegado a git)" guard.sh "$(j8 Bash "$P" - "command=git$CR stash")"
fila8 "R13 git stash<CR><LF>ls (CR antes de un salto)" guard.sh "$(j8 Bash "$P" - "command=git stash$CR${NL}ls")"
fila8 "R14 ls; git stash<CR>" guard.sh "$(j8 Bash "$P" - "command=ls; git stash$CR")"
fila8 "R15 git -C . stash<CR>" guard.sh "$(j8 Bash "$P" - "command=git -C . stash$CR")"
fila8 "R16 git clean -fd<CR>" guard.sh "$(j8 Bash "$P" - "command=git clean -fd$CR")"
echo "-- Falsos positivos: lecturas y órdenes legítimas con CR --"
fila8 "R17 git status<CR>" guard.sh "$(j8 Bash "$P" - "command=git status$CR")"
fila8 "R18 git log --oneline<CR><LF>git diff<CR>" guard.sh "$(j8 Bash "$P" - "command=git log --oneline$CR${NL}git diff$CR")"
fila8 "R19 git stash list<CR>" guard.sh "$(j8 Bash "$P" - "command=git stash list$CR")"
fila8 "R20 git commit -m \"arreglo<CR>\"" guard.sh "$(j8 Bash "$P" - "command=git commit -m \"arreglo$CR\"")"
fila8 "R21 git restore --staged a.txt<CR>" guard.sh "$(j8 Bash "$P" - "command=git restore --staged a.txt$CR")"
fila8 "R22 echo hola<CR><LF>ls<CR> (sin git)" guard.sh "$(j8 Bash "$P" - "command=echo hola$CR${NL}ls$CR")"
echo "-- B9 por el punto de entrada real (producción) --"
fila8 "R23 tool_name Bash<CR> con git reset --hard, por guard.sh" guard.sh "$(j8 "Bash$CR" "$P" - 'command=git reset --hard')"
rm -rf "$EVQ/r-proj"
