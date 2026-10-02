#!/usr/bin/env bash
# EMULACIÓN (no es Windows, no es el host): un `jq` envoltorio que, como el jq nativo de Windows en modo
# texto, convierte cada salto de línea de su salida en CRLF. Sirve para comprobar sobre Linux la lógica de
# transporte de la que depende la reparación: (1) sin CR en los datos, ningún falso positivo (la línea de
# contadores llega «0\r» y el transporte la limpia); (2) con CR en los datos, la marca sigue saliendo.
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8/r7rerun/qa-lib-r8.sh
JQREAL="$(command -v jq)"; W=$Q/jq-crlf; mkdir -p "$W"
cat > "$W/jq" <<EOF
#!/usr/bin/env bash
set -o pipefail
"$JQREAL" "\$@" | sed 's/\$/\r/'
EOF
chmod +x "$W/jq"
PRJ=$Q/proj-emul; F=$Q/fuera-emul; rm -rf "$PRJ" "$F"; mkproj "$PRJ"; mkdir -p "$F/d"; ln -s "$PRJ" "$F/d$CR"
req "$PRJ/requirements/REQ-900.md"; req "$PRJ/requirements/REQ-901.md" en-revisión aprobado
callw() { local out; out="$(printf '%s' "$3" | PATH="$W:$PATH" CLAUDE_PROJECT_DIR="$PRJ" timeout 55 bash "$1/$2" 2>/dev/null)"
  case "$out" in *'"permissionDecision":"deny"'*) D=deny ;; *) D=allow ;; esac
  M="$(printf '%s' "$out" | tr -d '\r' | "$JQREAL" -r '.hookSpecificOutput.permissionDecisionReason // empty' 2>/dev/null)"; }
fila() { local id="$1" esp="$2" json="$3" dc dd mc
  callw "$CAND" guard.sh "$json"; dc="$D"; mc="$M"; callw "$CD6" guard.sh "$json"; dd="$D"
  printf '%-64s esperado=%-5s cand=%-5s %s cd6afa6=%-5s | %s\n' "$id" "$esp" "$dc" "$([ "$dc" = "$esp" ] && echo OK || echo '<<DIFIERE>>')" "$dd" "${mc:0:110}"; }
echo "== Emulación del jq de Windows (CRLF en su salida) sobre Linux, $(date -Iseconds) =="
printf '   prueba del envoltorio: %q\n' "$(printf '{"a":"x"}' | PATH="$W:$PATH" jq -r '.a, .a')"
fila "E1 coordinadora Write ABS docs/n.md (legítimo, sin CR)"      allow "$(j Write "$PRJ" - "file_path=$PRJ/docs/n.md" content=x)"
fila "E2 coordinadora Write src/a.ts (sin CR)"                     deny  "$(j Write "$PRJ" - "file_path=$PRJ/src/a.ts" content=x)"
fila "E3 desarrollador Write src/a.ts (sin CR)"                    allow "$(j Write "$PRJ" desarrollador "file_path=$PRJ/src/a.ts" content=x)"
fila "E4 ls -la (sin CR)"                                          allow "$(j Bash "$PRJ" - 'command=ls -la')"
fila "E5 coordinadora echo x > docs/n.md, cwd raíz (sin CR)"        allow "$(j Bash "$PRJ" - 'command=echo x > docs/n.md')"
fila "E6 cierre REQ-901 en verde (sin CR)"                         allow "$(cierre "$PRJ" "$PRJ/requirements/REQ-901.md")"
fila "E7 cierre REQ-900 en rojo (sin CR)"                          deny  "$(cierre "$PRJ" "$PRJ/requirements/REQ-900.md")"
fila "E8 QA-023-13: echo x > src/a.ts desde F/d<CR>"               deny  "$(j Bash "$F/d$CR" - 'command=echo x > src/a.ts')"
fila "E9 Write ABS docs/n.md desde F/d<CR> (legítimo)"             allow "$(j Write "$F/d$CR" - "file_path=$PRJ/docs/n.md" content=x)"
fila "E10 Write docs/n.md<CR> (file_path con CR)"                  deny  "$(j Write "$PRJ" - "file_path=$PRJ/docs/n.md$CR" content=x)"
fila "E11 Write<CR> del desarrollador a docs/n.md"                 deny  "$(j "Write$CR" "$PRJ" desarrollador "file_path=$PRJ/docs/n.md" content=x)"
echo "-- lo que deja arnes_parse_input del candidato con el envoltorio, entrada P2 (CR final en tool, cwd y file_path):"
P2="$("$JQREAL" -cn '{tool_name:"Bash\r",cwd:"/tmp/d\r",tool_input:{file_path:"/tmp/f\r",command:"ls"}}')"
( PATH="$W:$PATH"; . "$CAND/lib.sh"; ARNES_INPUT="$P2"; ARNES_INPUT_LISTO=''; arnes_parse_input
  printf '   tool=%q cwd=%q fp=%q cmd=%q marcas tool/cwd/fp=%s/%s/%s\n' "$ARNES_TOOL" "$ARNES_CWD" "$ARNES_FP" "$ARNES_CMD" "$ARNES_TOOL_CR" "$ARNES_CWD_CR" "$ARNES_FP_CR" )
P0="$("$JQREAL" -cn '{tool_name:"Write",cwd:"/tmp/d",tool_input:{file_path:"/tmp/f",command:""}}')"
( PATH="$W:$PATH"; . "$CAND/lib.sh"; ARNES_INPUT="$P0"; ARNES_INPUT_LISTO=''; arnes_parse_input
  printf '   (sin CR) tool=%q cwd=%q fp=%q marcas=%s/%s/%s\n' "$ARNES_TOOL" "$ARNES_CWD" "$ARNES_FP" "$ARNES_TOOL_CR" "$ARNES_CWD_CR" "$ARNES_FP_CR" )
