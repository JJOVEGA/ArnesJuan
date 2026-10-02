#!/usr/bin/env bash
# Reproducción mínima: un `cwd` que termina en CR (retorno de carro). `arnes_sin_cr_transporte`
# (CA-47 p11) retira el CR que cierra el campo, así que el hook ANCLA en OTRO directorio que el
# que usa el shell. Si ese directorio real es un enlace a la zona protegida y el recortado no,
# el hook juzga la ruta equivocada -> fallo abierto. Mismo mecanismo que QA-023-09, por CR y no LF.
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r6/qa-lib-r6.sh
PRJ=$Q/proj-crrepro; FUERA=$Q/fuera-crrepro
rm -rf "$PRJ" "$FUERA"; mkproj "$PRJ"; mkdir -p "$FUERA"
req "$PRJ/requirements/REQ-900.md"
# `d␍` es un enlace a la RAIZ del proyecto; `d` (lo que queda al quitar el CR) es un dir normal de fuera.
ln -s "$PRJ" "$FUERA/d$CR"; mkdir -p "$FUERA/d"
echo "== Reproducción del fallo abierto por CR final en cwd ($(date -Iseconds)) =="
echo "-- Qué resuelve el shell (prueba real, árbol aparte):"
T=$Q/sh-crrepro; rm -rf "$T"; mkdir -p "$T/root/src" "$T/x"; ln -s "$T/root" "$T/x/d$CR"; mkdir -p "$T/x/d"
( cd "$T/x/d$CR" 2>/dev/null && printf 'ESCRITO-EN-CODIGO\n' > src/a.ts )
printf '   cd "x/d<CR>" (enlace -> root) && printf > src/a.ts   =>  root/src/a.ts: %s\n' "$(cat "$T/root/src/a.ts" 2>/dev/null || echo 'no se escribió')"
printf '   x/d (dir normal, sin CR) tiene src/a.ts?  %s\n' "$([ -e "$T/x/d/src/a.ts" ] && echo SI || echo no)"
echo
echo "-- guard-codigo: la coordinadora escribe código por Bash desde cwd='FUERA/d<CR>' (enlace a la raíz)"
quad "R1 echo x > src/a.ts, cwd=FUERA/d<CR>"   guard-codigo.sh "$(j Bash "$FUERA/d$CR" - 'command=echo x > src/a.ts')"
quad "R1-ctl mismo caso, cwd=FUERA/d (sin CR, dir normal)" guard-codigo.sh "$(j Bash "$FUERA/d" - 'command=echo x > src/a.ts')"
echo
echo "-- guard-completado: la coordinadora cierra un REQ en rojo por Bash desde cwd='FUERA/d<CR>'"
quad "R2 sed -i terminal requirements/REQ-900.md, cwd=FUERA/d<CR>" guard-completado.sh "$(j Bash "$FUERA/d$CR" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
echo
echo "NOTA: 9596e39 ignora el cwd (ancla en la raíz, aún no existía CA-47 p1), por eso deniega 'por azar'."
echo "      43b948a y la CANDIDATA anclan en el cwd y ambas lo recortan igual: el defecto es del cwd anclado, no del delta de la sexta."
