#!/usr/bin/env bash
# Batería K — el CR del TEXTO de un comando de Bash (P-023-13-A), y una pasada de movimientos con el proyecto
# FUERA de /tmp (9596e39 se saltaba en guard-completado todo destino de Bash que empezara por /tmp/, y eso
# podía ocultar un deny->allow en las baterías hechas bajo /tmp). Cuatro árboles.
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8b/r7rerun/qa-lib-r8b.sh
BASEV=/var/tmp/arnes-qa-r7-$$; PRJ=$BASEV/proj; F=$BASEV/fuera
rm -rf "$BASEV"; mkproj "$PRJ"; mkdir -p "$F"
req "$PRJ/requirements/REQ-900.md"; req "$PRJ/requirements/REQ-901.md" en-revisión aprobado
R="$PRJ/requirements"
ln -s ../src/a.ts "$PRJ/docs/k$CR"; ln -s ../src/a.ts "$PRJ/docs/k${CR}z"; ln -s ../requirements/REQ-900.md "$PRJ/docs/r$CR"
ln -s "$PRJ" "$F/d$CR"; mkdir -p "$F/d"
echo "== Batería K — CR del texto de Bash y movimientos fuera de /tmp; proyecto en $PRJ ($(date -Iseconds)) =="
echo "-- K. El CR final (o antes de un salto) del texto del comando: el destino se juzga sin él"
quad "K1 coordinadora: printf x > k<CR> desde docs (docs/k<CR> -> src/a.ts)" guard.sh "$(j Bash "$PRJ/docs" - "command=printf x > k$CR")"
quad "K2 coordinadora: printf x > k<CR><LF>true desde docs"                  guard.sh "$(j Bash "$PRJ/docs" - "command=printf x > k$CR${NL}true")"
quad "K3 control: printf x > src/a.ts<CR> desde la raíz (sobredeniega)"      guard.sh "$(j Bash "$PRJ" - "command=printf x > src/a.ts$CR")"
quad "K4 control: printf x > k<CR>z desde docs (CR en medio: se juzga)"      guard.sh "$(j Bash "$PRJ/docs" - "command=printf x > k${CR}z")"
quad "K6 ABS: printf x > <raíz>/docs/k<CR> desde la raíz"                    guard.sh "$(j Bash "$PRJ" - "command=printf x > $PRJ/docs/k$CR")"
quad "K7 sed -i cierra por <raíz>/docs/r<CR> (-> REQ-900, rojo), CR final"   guard.sh "$(j Bash "$PRJ" - "command=sed -i 's/en-revisión/completado/' $PRJ/docs/r$CR")"
quad "K8 tee docs/k<CR> (CR final)"                                          guard.sh "$(j Bash "$PRJ" - "command=echo x | tee docs/k$CR")"
echo "   efecto real del shell para K1 (árbol aparte):"
T=$BASEV/sh; mkdir -p "$T/src" "$T/docs"; printf 'orig\n' > "$T/src/a.ts"; ln -s ../src/a.ts "$T/docs/k$CR"
( cd "$T/docs" && bash -c "printf INTRUSO > k$CR" ); printf '   src/a.ts tras (cd docs; printf INTRUSO > k<CR>) = %s\n' "$(cat "$T/src/a.ts")"
echo "-- Movimientos, fuera de /tmp, de las filas de las baterías A y B que tocan Bash absoluto o el cwd con CR"
quad "A1 coordinadora echo x > src/a.ts desde F/d<CR>"                       guard.sh "$(j Bash "$F/d$CR" - 'command=echo x > src/a.ts')"
quad "A2 sed -i cierra REQ-900 relativo desde F/d<CR>"                       guard.sh "$(j Bash "$F/d$CR" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
quad "B3f Bash printf x > ABS <raíz>/docs/n.md desde F/d<CR> (legítimo)"     guard.sh "$(j Bash "$F/d$CR" - "command=printf x > $PRJ/docs/n.md")"
quad "B3h Bash sed -i cierra ABS REQ-900 desde F/d<CR>"                      guard.sh "$(j Bash "$F/d$CR" - "command=sed -i 's/en-revisión/completado/' $R/REQ-900.md")"
quad "B3h2 Bash sed -i edita ABS REQ-901 SIN terminal desde F/d<CR>"         guard.sh "$(j Bash "$F/d$CR" - "command=sed -i 's/nota/nota2/' $R/REQ-901.md")"
quad "B3k Bash ABS por el enlace con CR: printf x > F/d<CR>/src/a.ts"        guard.sh "$(j Bash "$F/d$CR" - "command=printf x > $F/d$CR/src/a.ts")"
quad "B3k2 sed -i cierra por F/d<CR>/requirements/REQ-900.md (ABS, CR en medio)" guard.sh "$(j Bash "$PRJ" - "command=sed -i 's/en-revisión/completado/' $F/d$CR/requirements/REQ-900.md")"
quad "B3p desarrollador Bash relativo con terminal: echo completado > docs/x.md" guard.sh "$(j Bash "$F/d$CR" desarrollador 'command=echo completado > docs/x.md')"
quad "B3i ls -la desde F/d<CR>"                                              guard.sh "$(j Bash "$F/d$CR" - 'command=ls -la')"
quad "RS3 sin CR: echo x > src/a.ts desde F/d (dir normal, L8)"              guard.sh "$(j Bash "$F/d" - 'command=echo x > src/a.ts')"
rm -rf "$BASEV"
