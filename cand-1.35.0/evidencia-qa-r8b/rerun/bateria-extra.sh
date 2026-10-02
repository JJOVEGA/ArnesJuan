#!/usr/bin/env bash
# bateria-extra.sh — formas adicionales de lo que depende del proceso (a nivel de hook).
set -u
. "$(dirname "$0")/lib8.sh"
BASEV=/var/tmp/arnes-ev8x-$$; mkdir -p "$BASEV"; trap 'rm -rf "$BASEV"' EXIT
proyecto8 "$BASEV/p"
echo "== bateria-extra ($(date -Iseconds)) =="
fila8 "X1 echo > /proc/thread-self/fd/1 (descriptor por el hilo)" guard.sh "$(j8 Bash "$P" - 'command=echo hola > /proc/thread-self/fd/1')" allow
fila8 "X2 echo > /proc/thread-self/cwd/src/a.ts, cwd raiz" guard.sh "$(j8 Bash "$P" - 'command=echo x > /proc/thread-self/cwd/src/a.ts')" deny
fila8 "X3 echo > /dev/stdin" guard.sh "$(j8 Bash "$P" - 'command=echo x > /dev/stdin')" allow
fila8 "X4 echo > /proc/1/cwd/src/a.ts (otro proceso, sin permiso)" guard.sh "$(j8 Bash "$P" - 'command=echo x > /proc/1/cwd/src/a.ts')" deny
fila8 "X5 echo > /proc/self/fd/../cwd/src/a.ts, cwd raiz" guard.sh "$(j8 Bash "$P" - 'command=echo x > /proc/self/fd/../cwd/src/a.ts')" deny
fila8 "X6 echo > /proc/self/cwd/../../x, cwd raiz (fuera, sube por encima)" guard.sh "$(j8 Bash "$P" - "command=echo x > /proc/self/cwd/../../x")" ''
fila8 "X7 Write /proc/self/root<raiz>/docs/n.md (legitimo por la raiz)" guard.sh "$(j8 Write "$P" - "file_path=/proc/self/root$P/docs/n.md" content=x)" allow
fila8 "X8 echo x > /dev/null; echo y > src/a.ts (el segundo destino manda)" guard.sh "$(j8 Bash "$P" - 'command=echo x > /dev/null; echo y > src/a.ts')" deny
fila8 "X9 desarrollador Write /proc/self/cwd/src/a.ts (host)" guard.sh "$(j8 Write "$P" desarrollador "file_path=/proc/self/cwd/src/a.ts" content=x)" ''
fila8 "X10 cierre por Write /dev/stderr de un REQ (no es REQ)" guard-completado.sh "$(j8 Write "$P" - "file_path=/dev/stderr" content=x)" deny
