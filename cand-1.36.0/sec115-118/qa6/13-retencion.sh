#!/usr/bin/env bash
# 13-retencion.sh <dir-hooks> <etiqueta> <gate> — ¿qué tubería del hook retiene lo que sobrevive al corte?
# stdout y stderr del hook van a DOS tuberías distintas; se anota cuándo sale el hook y cuándo llega el EOF de cada una.
# Tope: a los 75 s del arranque QA mata con -9 todo lo que lleve la marca (se anota), para no esperar al sleep.
set -u
H="$1"; ET="$2"; G="$3"
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad; export TMPDIR=$S
M="7$$"; G="${G//@M@/$M}"
P="$S/qa5r-$$"; rm -rf "$P"; mkdir -p "$P/.arnes" "$P/requirements"
jq -n --arg g "$G" '{codigo_app:{globs:["src/**"]},quality_gates:[$g]}' > "$P/.arnes/config.json"
printf '# REQ-900\nEstado: en-revision\nQA: aprobado\nSeguridad: aprobado\nSensible a seguridad: si\n' > "$P/requirements/REQ-900.md"
git -C "$P" init -q && git -C "$P" add -A && git -C "$P" -c user.name=qa -c user.email=qa@invalid -c core.hooksPath=/dev/null commit -qm b >/dev/null 2>&1
jq -cn --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:($c+"/requirements/REQ-900.md"),old_string:"Estado: en-revision",new_string:"Estado: completado"}}' > "$P.in"
mkfifo "$P.o" "$P.e"
t0=${EPOCHREALTIME/./}
( cat "$P.o" > "$P.out"; echo "${EPOCHREALTIME/./}" > "$P.to" ) &
( cat "$P.e" > "$P.err"; echo "${EPOCHREALTIME/./}" > "$P.te" ) &
( cd "$P" && unset LC_ALL POSIXLY_CORRECT BASH_ENV; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P"
  timeout 60 bash "$H/guard.sh" < "$P.in" > "$P.o" 2> "$P.e"; echo "$? ${EPOCHREALTIME/./}" > "$P.th" ) &
k=''
while [ ! -s "$P.to" ] || [ ! -s "$P.te" ]; do
  sleep 0.5; [ $(( (${EPOCHREALTIME/./} - t0) / 1000000 )) -lt 75 ] || { [ -n "$k" ] || { k=" (QA mató -9 a los 75 s: $(pgrep -fc "\.$M\b") vivos)"; pkill -9 -f "\.$M\b"; pkill -9 -f "^bash $H/guard.sh$"; }; }
done
sleep 1; read -r rc th < "$P.th"; to=$(cat "$P.to"); te=$(cat "$P.te")
case "$(cat "$P.out")" in *'"permissionDecision":"deny"'*) d=deny ;; '') d=nada ;; *) d=otra ;; esac
printf '%s | gate=%s | rc=%s hook=%sms eof-stdout=%sms eof-stderr=%sms | dec=%s | vivos ahora=%s%s\n' "$ET" "$3" "$rc" \
  $(( (th - t0) / 1000 )) $(( (to - t0) / 1000 )) $(( (te - t0) / 1000 )) "$d" "$(pgrep -fc "\.$M\b")" "$k"
pkill -9 -f "\.$M\b" 2>/dev/null; rm -rf "$P" "$P".*
