#!/usr/bin/env bash
# Batería B — casos de ruptura propios de QA, a nivel de hook, contra la reparación de QA-023-13.
# Cuatro árboles; las marcas <<MOV deny->allow vs X>> señalan un movimiento a revisar.
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/qa/qa-lib-r7.sh
PRJ=$Q/proj-b; F=$Q/fuera-b
rm -rf "$PRJ" "$F"; mkproj "$PRJ"; mkdir -p "$F"
req "$PRJ/requirements/REQ-900.md"                  # rojo
req "$PRJ/requirements/REQ-901.md" en-revisión aprobado   # verde
R="$PRJ/requirements"
ln -s "$PRJ" "$F/d$CR"; mkdir -p "$F/d"
ln -s "$PRJ" "$F/dd$CR$CR"; mkdir -p "$F/dd"
ln -s "$PRJ" "$F/$CR"                                # un directorio que se llama sólo CR
ln -s "$PRJ" "$F/x$NL$CR"; mkdir -p "$F/x$NL"         # LF y luego CR al final
ln -s "$PRJ" "$F/y$CR$NL"; mkdir -p "$F/y$NL"         # CR antes de LF al final
ln -s "$PRJ" "${PRJ}$CR"                              # <raíz>␍ enlace a la raíz
mkdir -p "$PRJ/docs/c$CR"                             # un subdirectorio real con CR dentro del proyecto
ln -s ../src "$PRJ/docs/s$CR"                         # enlace con CR dentro hacia src
echo "== Batería B — ruptura propia de QA-023-13 ($(date -Iseconds)) =="
echo
echo "## B1. Formas del cwd con CR (coordinadora, echo x > src/a.ts, relativa) — todas deben denegar por el cwd"
quad "B1a cwd=F/dd<CR><CR> (dos CR finales)"             guard.sh "$(j Bash "$F/dd$CR$CR" - 'command=echo x > src/a.ts')"
quad "B1b cwd=F/<CR> (componente que es sólo CR)"        guard.sh "$(j Bash "$F/$CR" - 'command=echo x > src/a.ts')"
quad "B1c cwd=<CR> (el cwd entero es un CR)"             guard.sh "$(j Bash "$CR" - 'command=echo x > src/a.ts')"
quad "B1d cwd=F/x<LF><CR> (LF y CR finales)"             guard.sh "$(j Bash "$F/x$NL$CR" - 'command=echo x > src/a.ts')"
quad "B1e cwd=F/y<CR><LF> (CRLF final)"                  guard.sh "$(j Bash "$F/y$CR$NL" - 'command=echo x > src/a.ts')"
quad "B1f cwd=<raíz><CR> (enlace a la raíz)"             guard.sh "$(j Bash "${PRJ}$CR" - 'command=echo x > src/a.ts')"
quad "B1g cwd=<raíz>/docs/c<CR> (dir REAL con CR), ../../src/a.ts" guard.sh "$(j Bash "$PRJ/docs/c$CR" - 'command=echo x > ../../src/a.ts')"
quad "B1h cwd=<CR><raíz> (CR inicial, no absoluto)"      guard.sh "$(j Bash "$CR$PRJ" - 'command=echo x > src/a.ts')"
echo
echo "## B2. El CR escrito como escape \\u000d en el JSON crudo, y claves cwd duplicadas"
JX="$(printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","cwd":"%s/d\\u000d","tool_input":{"command":"echo x > src/a.ts"}}' "$F")"
quad "B2a cwd con \\u000d (JSON a mano)"                  guard.sh "$JX"
JD1="$(printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","cwd":"%s","cwd":"%s/d\\r","tool_input":{"command":"echo x > src/a.ts"}}' "$PRJ/docs" "$F")"
quad "B2b cwd duplicado: limpio y luego con CR (jq toma el último)" guard.sh "$JD1"
JD2="$(printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","cwd":"%s/d\\r","cwd":"%s","tool_input":{"command":"echo x > src/a.ts"}}' "$F" "$PRJ")"
quad "B2c cwd duplicado: con CR y luego la raíz limpia"  guard.sh "$JD2"
echo
echo "## B3. Lo que NO depende del cwd con CR se juzga como siempre (cwd=F/d<CR>)"
quad "B3a coordinadora Write ABS <raíz>/docs/n.md (legítimo)"   guard.sh "$(j Write "$F/d$CR" - "file_path=$PRJ/docs/n.md" content=x)"
quad "B3b coordinadora Write ABS <raíz>/src/a.ts"               guard.sh "$(j Write "$F/d$CR" - "file_path=$PRJ/src/a.ts" content=x)"
quad "B3c desarrollador Write ABS <raíz>/src/a.ts"              guard.sh "$(j Write "$F/d$CR" desarrollador "file_path=$PRJ/src/a.ts" content=x)"
quad "B3d cierre ABS REQ-901 en verde"                          guard.sh "$(cierre "$F/d$CR" "$R/REQ-901.md")"
quad "B3e cierre ABS REQ-900 en rojo"                           guard.sh "$(cierre "$F/d$CR" "$R/REQ-900.md")"
quad "B3f Bash printf x > ABS <raíz>/docs/n.md (legítimo)"       guard.sh "$(j Bash "$F/d$CR" - "command=printf x > $PRJ/docs/n.md")"
quad "B3g Bash printf x > ABS <raíz>/src/a.ts"                  guard.sh "$(j Bash "$F/d$CR" - "command=printf x > $PRJ/src/a.ts")"
quad "B3h Bash sed -i cierra ABS REQ-900"                       guard.sh "$(j Bash "$F/d$CR" - "command=sed -i 's/en-revisión/completado/' $R/REQ-900.md")"
quad "B3i ls -la ; git status ; cat x 2>/dev/null"              guard.sh "$(j Bash "$F/d$CR" - 'command=ls -la; git status; cat x 2>/dev/null')"
quad "B3j echo x > /dev/null"                                   guard.sh "$(j Bash "$F/d$CR" - 'command=echo x > /dev/null')"
quad "B3k Bash ABS por el enlace con CR: printf x > F/d<CR>/src/a.ts" guard.sh "$(j Bash "$F/d$CR" - "command=printf x > $F/d$CR/src/a.ts")"
quad "B3l Write ABS por el enlace con CR: F/d<CR>/src/a.ts (file_path con CR)" guard.sh "$(j Write "$F/d$CR" - "file_path=$F/d$CR/src/a.ts" content=x)"
quad "B3m MultiEdit ABS REQ-900 cierra (rojo)"                  guard.sh "$(jq -cn --arg c "$F/d$CR" --arg f "$R/REQ-900.md" '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:$c,tool_input:{file_path:$f,edits:[{old_string:"Estado: en-revisión",new_string:"Estado: completado"}]}}')"
quad "B3n MultiEdit RELATIVO REQ-901 cierra (verde)"            guard.sh "$(jq -cn --arg c "$F/d$CR" '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:$c,tool_input:{file_path:"requirements/REQ-901.md",edits:[{old_string:"Estado: en-revisión",new_string:"Estado: completado"}]}}')"
quad "B3o desarrollador Bash relativo sin terminal: echo x > src/a.ts" guard.sh "$(j Bash "$F/d$CR" desarrollador 'command=echo x > src/a.ts')"
quad "B3p desarrollador Bash relativo con terminal: echo completado > docs/x.md" guard.sh "$(j Bash "$F/d$CR" desarrollador 'command=echo completado > docs/x.md')"
quad "B3q qa-tester Bash relativo fuera: echo x > notas.md"     guard.sh "$(j Bash "$F/d$CR" qa-tester 'command=echo x > notas.md')"
echo
echo "## B4. tool_name con CR en otras posiciones (punto 13), coordinadora y desarrollador"
for t in "${CR}Bash" "Bash$CR$CR" "Ba${CR}sh" "$CR" "Write$CR$NL" "MultiEdit$CR"; do
  quad "B4 coord   tool=$(printf %q "$t") Write-like a src/a.ts"   guard.sh "$(j "$t" "$PRJ" - "file_path=$PRJ/src/a.ts" content=x 'command=ls')"
  quad "B4 desarr. tool=$(printf %q "$t") a docs/n.md"             guard.sh "$(j "$t" "$PRJ" desarrollador "file_path=$PRJ/docs/n.md" content=x 'command=ls')"
done
echo
echo "## B5. file_path con CR en otras posiciones (punto 12)"
quad "B5a coord Write <raíz>/src/a.ts<CR><CR>"            guard.sh "$(j Write "$PRJ" - "file_path=$PRJ/src/a.ts$CR$CR" content=x)"
quad "B5b coord Write <CR><raíz>/docs/n.md (CR inicial)"  guard.sh "$(j Write "$PRJ" - "file_path=$CR$PRJ/docs/n.md" content=x)"
quad "B5c coord Write <raíz>/docs/c<CR>/n.md (dir real con CR)" guard.sh "$(j Write "$PRJ" - "file_path=$PRJ/docs/c$CR/n.md" content=x)"
quad "B5d coord Write <raíz>/docs/s<CR>/a.ts (enlace con CR -> src)" guard.sh "$(j Write "$PRJ" - "file_path=$PRJ/docs/s$CR/a.ts" content=x)"
quad "B5e coord Write <raíz>/docs/n.md<CR><LF> (CR+LF: motivo del salto)" guard.sh "$(j Write "$PRJ" - "file_path=$PRJ/docs/n.md$CR$NL" content=x)"
quad "B5f Bash con file_path con CR (no se juzga) y ls"    guard.sh "$(j Bash "$PRJ" - "file_path=$PRJ/src/a.ts$CR" 'command=ls')"
quad "B5g herramienta desconocida Foo con file_path <raíz>/src/a.ts<CR>" guard.sh "$(j Foo "$PRJ" - "file_path=$PRJ/src/a.ts$CR")"
quad "B5h desarrollador Edit legítimo <raíz>/src/a.ts (sin CR, control)" guard.sh "$(j Edit "$PRJ" desarrollador "file_path=$PRJ/src/a.ts" old_string=x new_string=y)"
echo
echo "## B6. Campos del agente con CR en medio (no contados; ¿hay movimiento?)"
quad "B6a agent_type desarr<CR>ollador escribe src/a.ts"   guard.sh "$(j Write "$PRJ" "desarr${CR}ollador" "file_path=$PRJ/src/a.ts" content=x)"
quad "B6b agent_type <CR>desarrollador escribe src/a.ts"   guard.sh "$(j Write "$PRJ" "${CR}desarrollador" "file_path=$PRJ/src/a.ts" content=x)"
quad "B6c agent_type qa-tester<CR> escribe src/a.ts"       guard.sh "$(j Write "$PRJ" "qa-tester$CR" "file_path=$PRJ/src/a.ts" content=x)"
echo
echo "## B7. cwd que no es cadena (como antes: no ancla)"
for v in 5 true '{"a":"\r"}' '["/x\r"]' null; do
  J="$(jq -cn --argjson c "$v" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:"echo x > docs/n.md"}}')"
  quad "B7 cwd=$v, coordinadora echo x > docs/n.md (relativa)" guard.sh "$J"
done
echo
echo "## B8. Sin CLAUDE_PROJECT_DIR: la raíz sale del cwd (arnes_project_dir, sede propia; «no cambia»)"
PRJ_ENV=''
quad "B8a sin env, cwd=F/d<CR>, echo x > src/a.ts (relativa)"     guard.sh "$(j Bash "$F/d$CR" - 'command=echo x > src/a.ts')"
quad "B8b sin env, cwd=F/d<CR>, Write ABS <raíz>/src/a.ts"        guard.sh "$(j Write "$F/d$CR" - "file_path=$PRJ/src/a.ts" content=x)"
quad "B8c sin env, cwd=F/d<CR>, Write ABS F/d<CR>/src/a.ts"       guard.sh "$(j Write "$F/d$CR" - "file_path=$F/d$CR/src/a.ts" content=x)"
quad "B8d sin env, cwd=<raíz><CR>, Bash printf x > ABS <raíz><CR>/src/a.ts" guard.sh "$(j Bash "${PRJ}$CR" - "command=printf x > ${PRJ}$CR/src/a.ts")"
quad "B8e sin env, cwd=<raíz><CR>, Bash printf x > ABS <raíz>/src/a.ts" guard.sh "$(j Bash "${PRJ}$CR" - "command=printf x > $PRJ/src/a.ts")"
quad "B8f sin env, cwd=<raíz><CR>, Write ABS <raíz>/docs/n.md (legítimo)" guard.sh "$(j Write "${PRJ}$CR" - "file_path=$PRJ/docs/n.md" content=x)"
unset PRJ_ENV
echo
echo "## B9. guard-git: Bash<CR> con git reset --hard (guard-git por su cuenta y por guard.sh)"
for a in - desarrollador; do
  quad "B9 agente=$a guard-git.sh solo: Bash<CR> git reset --hard" guard-git.sh "$(j "Bash$CR" "$PRJ" "$a" 'command=git reset --hard')"
  quad "B9 agente=$a guard.sh: Bash<CR> git reset --hard"          guard.sh "$(j "Bash$CR" "$PRJ" "$a" 'command=git reset --hard')"
done
echo
echo "sha REQ-900/901 y src/a.ts sin cambio: $(sha256sum "$R/REQ-900.md" "$R/REQ-901.md" | cut -c1-12 | tr '\n' ' ') $(cat "$PRJ/src/a.ts")"
