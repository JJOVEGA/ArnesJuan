#!/usr/bin/env bash
# Batería X (QA r8): P-122-A (2) — un enlace del último componente SITUADO DENTRO de un ámbito protegido
# que apunta a un descriptor (src/log -> /dev/stderr). El analista lo identificó leyendo el código, SIN medir.
# Cuatro árboles, a nivel de hook. Controles con enlaces dentro del ámbito que NO van a un descriptor.
EVQ=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8b
. "$EVQ/rerun/lib8.sh"
proyecto8 "$EVQ/x-proj"
# globs: src/* y app/*.ts (como el banco). Enlaces DENTRO de src/ (ámbito protegido):
ln -s /dev/stderr "$P/src/log"           # -> descriptor estándar
ln -s /dev/null   "$P/src/nul"           # -> dispositivo corriente (control)
ln -s ../docs/out.txt "$P/src/outside"   # -> fuera del ámbito, archivo corriente (control)
ln -s ./a.ts "$P/src/alias"              # -> otro archivo DEL ámbito (control)
printf 'x\n' > "$P/docs/out.txt"
echo "== Batería X (QA r8) $(date -Iseconds); globs=[src/*, app/*.ts] =="
echo "-- P-122-A (2): enlace dentro del ámbito -> descriptor estándar --"
fila8 "X-D1 coordinadora echo x > src/log (src/log -> /dev/stderr)" guard.sh "$(j8 Bash "$P" - 'command=echo x > src/log')"
fila8 "X-D2 coordinadora echo x > src/log por guard-codigo" guard-codigo.sh "$(j8 Bash "$P" - 'command=echo x > src/log')"
fila8 "X-D3 coordinadora Write src/log (file_path, no Bash)" guard-codigo.sh "$(j8 Write "$P" - "file_path=$P/src/log" content=x)"
echo "-- Controles: enlaces dentro del ámbito que NO van a un descriptor (deben seguir deny a la coordinadora) --"
fila8 "X-C1 coordinadora echo x > src/nul (src/nul -> /dev/null, dispositivo)" guard.sh "$(j8 Bash "$P" - 'command=echo x > src/nul')"
fila8 "X-C2 coordinadora echo x > src/outside (-> docs/out.txt, fuera)" guard.sh "$(j8 Bash "$P" - 'command=echo x > src/outside')"
fila8 "X-C3 coordinadora echo x > src/alias (-> src/a.ts, dentro)" guard.sh "$(j8 Bash "$P" - 'command=echo x > src/alias')"
fila8 "X-C4 desarrollador echo x > src/log (control: puede escribir código)" guard.sh "$(j8 Bash "$P" desarrollador 'command=echo x > src/log')"
echo "-- Efecto real del shell: a dónde escribe 'echo INTRUSO > src/log' (árbol aparte) --"
T="$EVQ/x-sh"; rm -rf "$T"; mkdir -p "$T/src"; printf 'orig\n' > "$T/src/a.ts"; ln -s /dev/stderr "$T/src/log"
( cd "$T" && bash -c 'echo INTRUSO > src/log' ) 2>"$T/stderr.cap"
printf '   src/a.ts intacto: %s · lo escrito fue a stderr (captura): %s\n' "$(cat "$T/src/a.ts")" "$(cat "$T/stderr.cap")"
rm -rf "$EVQ/x-proj" "$T"
