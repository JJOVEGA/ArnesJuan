#!/usr/bin/env bash
# bateria-s122.sh — SEC-122 (las dos caras), lo legitimo bajo /dev y lo que depende del proceso.
# A nivel de hook, por guard.sh salvo que se diga otro guardian. Proyecto fuera de /tmp (9596e39 se
# saltaba en guard-completado todo destino que empezara por /tmp/, y eso podria ocultar un movimiento).
set -u
. "$(dirname "$0")/lib8.sh"
BASEV=/var/tmp/arnes-ev8-$$; mkdir -p "$BASEV"
trap 'rm -rf "$BASEV" /dev/shm/arnes-ev8-*-$$' EXIT
echo "== bateria-s122 ($(date -Iseconds)); $(uname -r); bash $BASH_VERSION; $(jq --version) =="
proyecto8 "$BASEV/p"
FUERA="$BASEV/fuera"; mkdir -p "$FUERA"
L="/dev/shm/arnes-ev8-req-$$"; LS="/dev/shm/arnes-ev8-src-$$"; LF="/dev/shm/arnes-ev8-fil-$$"
ln -s "$R" "$L"; ln -s "$P/src" "$LS"; ln -s "$P/src/a.ts" "$LF"
ln -s /proc/self/cwd "$FUERA/pc"; ln -s /proc/self/cwd/src/a.ts "$FUERA/pc-a.ts"; ln -s /dev/stderr "$FUERA/err"
CT=$'x\n'
echo "-- Cara (a): enlaces corrientes bajo /dev/shm (resolucion de nombres) --"
fila8 "A1 Edit /dev/shm/<enl req>/REQ-900.md cierra en rojo" guard.sh "$(cierre8 "$L/REQ-900.md")" deny
fila8 "A2 Edit no literal (SEC-117) por /dev/shm" guard.sh "$(j8 Edit "$P" - "file_path=$L/REQ-920.md" 'old_string=en-revisión (tras "R-4")' new_string=completado)" deny
fila8 "A3 Write coordinadora /dev/shm/<enl src>/a.ts" guard.sh "$(j8 Write "$P" - "file_path=$LS/a.ts" "content=$CT")" deny
fila8 "A4 sed -i que cierra por /dev/shm" guard.sh "$(j8 Bash "$P" - "command=sed -i 's/en-revisión/completado/' $L/REQ-900.md")" deny
fila8 "A5 echo > /dev/shm/<enl src>/a.ts coordinadora" guard.sh "$(j8 Bash "$P" - "command=echo x > $LS/a.ts")" deny
fila8 "A6 echo > /dev/shm/<enlace de archivo -> src/a.ts>" guard.sh "$(j8 Bash "$P" - "command=echo x > $LF")" deny
fila8 "A7 Write coordinadora /dev/shm/<enlace de archivo -> src/a.ts>" guard.sh "$(j8 Write "$P" - "file_path=$LF" "content=$CT")" deny
fila8 "A8 desarrollador echo > /dev/shm/<enl src>/a.ts (control)" guard.sh "$(j8 Bash "$P" desarrollador "command=echo x > $LS/a.ts")" allow
echo "-- Cara (a): /proc/self/root y /proc/self/cwd --"
fila8 "R1 Edit /proc/self/root<raiz>/requirements/REQ-900.md" guard.sh "$(cierre8 "/proc/self/root$R/REQ-900.md")" deny
fila8 "R2 Write /proc/self/root<raiz>/src/a.ts" guard.sh "$(j8 Write "$P" - "file_path=/proc/self/root$P/src/a.ts" "content=$CT")" deny
fila8 "R3 echo > /proc/self/root<raiz>/src/a.ts" guard.sh "$(j8 Bash "$P" - "command=echo x > /proc/self/root$P/src/a.ts")" deny
fila8 "R4 echo > /proc/self/cwd/src/a.ts, cwd=<raiz>" guard.sh "$(j8 Bash "$P" - 'command=echo x > /proc/self/cwd/src/a.ts')" deny
fila8 "R5 sed -i /proc/self/cwd/requirements/REQ-900.md, cwd=<raiz>" guard.sh "$(j8 Bash "$P" - "command=sed -i 's/en-revisión/completado/' /proc/self/cwd/requirements/REQ-900.md")" deny
fila8 "R6 echo > /proc/self/cwd/src/a.ts, cwd=<raiz>/docs (designa docs/src/a.ts)" guard.sh "$(j8 Bash "$P/docs" - 'command=echo x > /proc/self/cwd/src/a.ts')" allow
fila8 "R7 echo > /proc/self/cwd/../src/a.ts, cwd=<raiz>/docs" guard.sh "$(j8 Bash "$P/docs" - 'command=echo x > /proc/self/cwd/../src/a.ts')" deny
fila8 "R8 Write /proc/self/cwd/src/a.ts (el host: su cwd no se conoce)" guard.sh "$(j8 Write "$P" - "file_path=/proc/self/cwd/src/a.ts" "content=$CT")" deny
fila8 "R9 Edit /proc/self/cwd/requirements/REQ-901.md (en verde; host)" guard.sh "$(cierre8 /proc/self/cwd/requirements/REQ-901.md)" deny
fila8 "R10 echo > <fuera>/pc/src/a.ts (pc -> /proc/self/cwd), cwd=<raiz>" guard.sh "$(j8 Bash "$P" - "command=echo x > $FUERA/pc/src/a.ts")" deny
fila8 "R11 echo > <fuera>/pc-a.ts (-> /proc/self/cwd/src/a.ts), cwd=<raiz>" guard.sh "$(j8 Bash "$P" - "command=echo x > $FUERA/pc-a.ts")" deny
fila8 "R12 Write <fuera>/pc/src/a.ts (host)" guard.sh "$(j8 Write "$P" - "file_path=$FUERA/pc/src/a.ts" "content=$CT")" deny
fila8 "R13 echo > /proc/self/cwd/src/a.ts sin cwd en la entrada" guard.sh "$(j8 Bash - - 'command=echo x > /proc/self/cwd/src/a.ts')" deny
fila8 "R14 echo > /dev/fd/9/a.ts (detras de un descriptor)" guard.sh "$(j8 Bash "$P" - 'command=echo x > /dev/fd/9/a.ts')" deny
fila8 "R15 echo 1 > /proc/self/oom_score_adj (pseudoarchivo del proceso)" guard.sh "$(j8 Bash "$P" - 'command=echo 1 > /proc/self/oom_score_adj')" deny
fila8 "R16 desarrollador echo > /proc/self/cwd/src/a.ts (control)" guard.sh "$(j8 Bash "$P" desarrollador 'command=echo x > /proc/self/cwd/src/a.ts')" allow
echo "-- Lo legitimo bajo /dev (sigue pasando, sin excepcion por nombre) --"
fila8 "N1 ls -la > /dev/null 2>&1" guard.sh "$(j8 Bash "$P" - 'command=ls -la > /dev/null 2>&1')" allow
fila8 "N2 echo hola > /dev/stderr" guard.sh "$(j8 Bash "$P" - 'command=echo hola > /dev/stderr')" allow
fila8 "N3 echo hola > /dev/stdout" guard.sh "$(j8 Bash "$P" - 'command=echo hola > /dev/stdout')" allow
fila8 "N4 echo hola > /dev/fd/2" guard.sh "$(j8 Bash "$P" - 'command=echo hola > /dev/fd/2')" allow
fila8 "N5 echo hola | tee /dev/stderr" guard.sh "$(j8 Bash "$P" - 'command=echo hola | tee /dev/stderr')" allow
fila8 "N6 echo hola > /proc/self/fd/1" guard.sh "$(j8 Bash "$P" - 'command=echo hola > /proc/self/fd/1')" allow
fila8 "N7 echo hola > <fuera>/err (-> /dev/stderr)" guard.sh "$(j8 Bash "$P" - "command=echo hola > $FUERA/err")" allow
fila8 "N8 echo hola > /dev/tty" guard.sh "$(j8 Bash "$P" - 'command=echo hola > /dev/tty')" allow
fila8 "N9 cat x 2>/dev/null > docs/n.md" guard.sh "$(j8 Bash "$P" - 'command=cat x 2>/dev/null > docs/n.md')" allow
fila8 "N10 echo x > /dev/shm/arnes-nuevo (tmpfs, fuera)" guard.sh "$(j8 Bash "$P" - "command=echo x > /dev/shm/arnes-ev8-nuevo-$$")" allow
fila8 "N11 Write /dev/null" guard.sh "$(j8 Write "$P" - "file_path=/dev/null" "content=$CT")" allow
fila8 "N12 Write /dev/stderr (descriptor del host: de allow a deny)" guard.sh "$(j8 Write "$P" - "file_path=/dev/stderr" "content=$CT")" deny
fila8 "N13 echo > /dev/stderr desde un cwd con CR (sin ancla)" guard.sh "$(j8 Bash "$P/docs$CR" - 'command=echo hola > /dev/stderr')" allow
echo "-- Cara (b): proyecto situado bajo /dev/shm --"
PROY="$P"; proyecto8 "/dev/shm/arnes-ev8-proj-$$"
ln -s ../requirements/REQ-900.md "$P/docs/enlace.md"; ln -s ../src/a.ts "$P/docs/a-enlace.ts"
ln -s ../requirements "$P/docs/dreq"; ln -s ../src "$P/docs/dsrc"
fila8 "B1 Edit por docs/enlace.md (-> REQ-900, ultimo componente) cierra" guard.sh "$(cierre8 "$P/docs/enlace.md")" deny
fila8 "B2 Edit por docs/enlace.md sin cerrar" guard.sh "$(j8 Edit "$P" - "file_path=$P/docs/enlace.md" old_string=nota 'new_string=otra nota')" deny
fila8 "B3 Write por docs/a-enlace.ts (-> src/a.ts)" guard.sh "$(j8 Write "$P" - "file_path=$P/docs/a-enlace.ts" "content=$CT")" deny
fila8 "B4 Edit literal sobre REQ-900 que existe (sin estado)" guard.sh "$(j8 Edit "$P" - "file_path=$R/REQ-900.md" old_string=nota 'new_string=otra nota')" allow
fila8 "B5 Edit por docs/dreq/REQ-900.md cierra" guard.sh "$(cierre8 "$P/docs/dreq/REQ-900.md")" deny
fila8 "B6 echo > docs/dsrc/a.ts" guard.sh "$(j8 Bash "$P" - 'command=echo x > docs/dsrc/a.ts')" deny
fila8 "B7 sed -i docs/dreq/REQ-900.md" guard.sh "$(j8 Bash "$P" - "command=sed -i 's/en-revisión/completado/' docs/dreq/REQ-900.md")" deny
fila8 "B8 Write canonica src/a.ts (control)" guard.sh "$(j8 Write "$P" - "file_path=$P/src/a.ts" "content=$CT")" deny
fila8 "B9 Write docs/n.md (legitimo)" guard.sh "$(j8 Write "$P" - "file_path=$P/docs/n.md" "content=$CT")" allow
fila8 "B10 cierre en verde de REQ-901 (legitimo)" guard.sh "$(cierre8 "$R/REQ-901.md")" allow
fila8 "B11 echo > /dev/stderr desde el proyecto bajo /dev/shm" guard.sh "$(j8 Bash "$P" - 'command=echo hola > /dev/stderr')" allow
rm -rf "$P"; P="$PROY"
echo "-- El shell, de verdad (arbol aparte): que escribe cada forma de la cara (a) --"
T="$BASEV/efecto"; proyecto8 "$T"; LT="/dev/shm/arnes-ev8-t-$$"; ln -s "$T/src" "$LT"
( cd "$T" && echo INTRUSO-shm > "$LT/a.ts"; echo INTRUSO-root >> "/proc/self/root$T/src/a.ts"; echo INTRUSO-cwd >> /proc/self/cwd/src/a.ts )
printf '   src/a.ts tras escribir por /dev/shm, /proc/self/root y /proc/self/cwd (cwd=raiz):\n'; sed 's/^/     /' "$T/src/a.ts"; rm -f "$LT"
( cd "$T/docs" && echo DOCS-cwd > /proc/self/cwd/n.md ); printf '   desde docs, /proc/self/cwd/n.md crea: %s\n' "$(ls "$T/docs")"
