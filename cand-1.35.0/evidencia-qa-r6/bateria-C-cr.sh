#!/usr/bin/env bash
# Batería C (QA r6): el retorno de carro (CR) que la transformación de transporte retira
# (`arnes_sin_cr_transporte`, declarada en REQ-007 CA-47 punto 11) cuando cierra un campo o precede a un LF.
# Pregunta: ¿puede ese recorte hacer que las puertas juzguen OTRO directorio de trabajo (o otra ruta)
# que el que usa de verdad el shell o la herramienta? A NIVEL DE HOOK, con directorios REALES.
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r6/qa-lib-r6.sh
PRJ=$Q/proj-cr; FUERA=$Q/fuera-cr
rm -rf "$PRJ" "$FUERA"; mkproj "$PRJ"; mkdir -p "$FUERA"
req "$PRJ/requirements/REQ-900.md"
R="$PRJ/requirements"
# Fuera de la raíz: `t␍` es un enlace a la RAÍZ; `t` (sin CR) es un directorio normal de fuera.
ln -s "$PRJ" "$FUERA/t$CR"; mkdir -p "$FUERA/t"
# Control sin CR: `u` es un enlace a la raíz.
ln -s "$PRJ" "$FUERA/u"
# Con CRLF DENTRO del nombre: `a␍␊b` enlace a la raíz; `a␊b` (lo que queda tras el recorte) dir normal.
ln -s "$PRJ" "$FUERA/a$CR${NL}b"; mkdir -p "$FUERA/a${NL}b"
# `v␍` enlace a la raíz y `v` NO existe (el recorte deja un cwd inexistente).
ln -s "$PRJ" "$FUERA/v$CR"
# Dentro de la raíz: `docs/k␍` -> ../requirements y `docs/k` dir normal; control `docs/k2` -> ../requirements.
ln -s ../requirements "$PRJ/docs/k$CR"; mkdir -p "$PRJ/docs/k"; ln -s ../requirements "$PRJ/docs/k2"
ln -s ../src "$PRJ/docs/s$CR"; mkdir -p "$PRJ/docs/s"; ln -s ../src "$PRJ/docs/s2"
# Último componente con CR final: `docs/w␍` -> ../src/a.ts (enlace dentro de la raíz, CA-49 (i)); `docs/w` no existe.
ln -s ../src/a.ts "$PRJ/docs/w$CR"; ln -s ../requirements/REQ-900.md "$PRJ/docs/r$CR"
echo "== Batería C: CR en el cwd y en el file_path ($(date -Iseconds)); FUERA=$FUERA =="
echo "-- comprobación de los directorios (el shell los distingue):"
for d in "$FUERA/t$CR" "$FUERA/t" "$FUERA/a$CR${NL}b" "$FUERA/a${NL}b" "$PRJ/docs/k$CR" "$PRJ/docs/k"; do
  printf '   %-60s -> %s\n' "$(printf %q "${d#$Q/}")" "$(cd "$d" 2>/dev/null && pwd -P | sed "s#$Q/##" || echo NO-EXISTE)"
done
echo "-- lo que el shell escribiría de verdad (en un árbol de prueba aparte, sin tocar PRJ):"
T=$Q/shell-cr; rm -rf "$T"; mkdir -p "$T/root/src" "$T/x"; ln -s "$T/root" "$T/x/t$CR"; mkdir -p "$T/x/t"
( cd "$T/x/t$CR" && printf 'escrito\n' > src/a.ts ); printf '   cd "x/t\\r" && printf > src/a.ts  =>  root/src/a.ts: %s\n' "$(cat "$T/root/src/a.ts" 2>/dev/null || echo 'no existe')"
echo
echo "-- C: Bash relativo con el cwd con CR final (guard-codigo: coordinadora escribe código; guard-completado: sed con el terminal)"
quad "C1 cwd=FUERA/t␍ (enlace a la raíz): echo x > src/a.ts"          guard.sh "$(j Bash "$FUERA/t$CR" - 'command=echo x > src/a.ts')"
quad "C1g guard-codigo a solas"                                         guard-codigo.sh "$(j Bash "$FUERA/t$CR" - 'command=echo x > src/a.ts')"
quad "C2 cwd=FUERA/t␍: sed -i terminal requirements/REQ-900.md"       guard.sh "$(j Bash "$FUERA/t$CR" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
quad "C2g guard-completado a solas"                                     guard-completado.sh "$(j Bash "$FUERA/t$CR" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
quad "C3 control sin CR, cwd=FUERA/u (enlace a la raíz): echo > src/a.ts" guard.sh "$(j Bash "$FUERA/u" - 'command=echo x > src/a.ts')"
quad "C3b control sin CR, cwd=FUERA/u: sed -i terminal REQ"             guard.sh "$(j Bash "$FUERA/u" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
quad "C4 CRLF dentro: cwd=FUERA/a␍␊b (enlace a la raíz): echo > src/a.ts" guard.sh "$(j Bash "$FUERA/a$CR${NL}b" - 'command=echo x > src/a.ts')"
quad "C4b CRLF dentro: sed -i terminal REQ"                             guard.sh "$(j Bash "$FUERA/a$CR${NL}b" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
quad "C5 cwd=FUERA/v␍ (v no existe): echo > src/a.ts"                  guard.sh "$(j Bash "$FUERA/v$CR" - 'command=echo x > src/a.ts')"
quad "C6 dentro: cwd=docs/k␍ (-> requirements): sed -i terminal REQ-900.md" guard.sh "$(j Bash "$PRJ/docs/k$CR" - "command=sed -i 's/en-revisión/completado/' REQ-900.md")"
quad "C6c control sin CR: cwd=docs/k2 (-> requirements): idem"           guard.sh "$(j Bash "$PRJ/docs/k2" - "command=sed -i 's/en-revisión/completado/' REQ-900.md")"
quad "C7 dentro: cwd=docs/s␍ (-> src): printf x > a.ts"                 guard.sh "$(j Bash "$PRJ/docs/s$CR" - 'command=printf x > a.ts')"
quad "C7c control sin CR: cwd=docs/s2 (-> src): idem"                    guard.sh "$(j Bash "$PRJ/docs/s2" - 'command=printf x > a.ts')"
quad "C8 legítimo: el desarrollador desde FUERA/t␍: echo > src/a.ts"   guard.sh "$(j Bash "$FUERA/t$CR" desarrollador 'command=echo x > src/a.ts')"
echo
echo "-- F: file_path con CR final (Edit/Write absolutos): la puerta juzga la ruta sin el CR"
quad "F1 Write coordinadora a docs/w␍ (enlace -> src/a.ts)"            guard.sh "$(j Write "$PRJ" - "file_path=$PRJ/docs/w$CR" content=x)"
quad "F1c control: Write a docs/w2 (enlace sin CR -> src/a.ts)"          guard.sh "$(ln -sf ../src/a.ts "$PRJ/docs/w2"; j Write "$PRJ" - "file_path=$PRJ/docs/w2" content=x)"
quad "F2 Edit que cierra por docs/r␍ (enlace -> REQ-900)"               guard.sh "$(cierre "$PRJ" "$PRJ/docs/r$CR")"
quad "F3 Write coordinadora a src/a.ts␍ (archivo distinto, nuevo)"      guard.sh "$(j Write "$PRJ" - "file_path=$PRJ/src/a.ts$CR" content=x)"
quad "F4 Write cierre con QA pendiente a REQ-900.md␍"                    guard.sh "$(j Write "$PRJ" - "file_path=$R/REQ-900.md$CR" $'content=# REQ-900\nEstado: completado\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n')"
quad "F5 Write coordinadora a docs/n.md␍ (fuera, legítimo)"            guard.sh "$(j Write "$PRJ" - "file_path=$PRJ/docs/n.md$CR" content=x)"
echo
echo "-- T: tool_name con CR final"
quad "T1 tool_name Write␍ coordinadora a src/a.ts"                      guard.sh "$(j "Write$CR" "$PRJ" - "file_path=$PRJ/src/a.ts" content=x)"
quad "T2 tool_name Bash␍ con echo > src/a.ts"                           guard.sh "$(j "Bash$CR" "$PRJ" - 'command=echo x > src/a.ts')"
quad "T3 tool_name Bash␍␊ con echo > src/a.ts"                          guard.sh "$(j "Bash$CR$NL" "$PRJ" - 'command=echo x > src/a.ts')"
