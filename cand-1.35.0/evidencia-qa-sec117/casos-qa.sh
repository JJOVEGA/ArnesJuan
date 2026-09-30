#!/usr/bin/env bash
# casos-qa.sh <hooks_dir> — casos de ruptura propios de QA contra CA-13 (REQ-023), por la puerta
# real (guard.sh), con el JSON PreToolUse. Imprime: caso | decision | disco-cambio | motivo(recorte)
set -uo pipefail
H="$1"
R="$(mktemp -d)"; trap 'chmod -R u+rwx "$R" 2>/dev/null; rm -rf "$R"' EXIT
P="$R/proj"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
cat > "$P/.arnes/config.json" <<'J'
{ "agentes": { "agente_codigo": "desarrollador",
    "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
J
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$P"
BSL="$(printf '\x5c')"
Q=$'“'; QC=$'”'   # comillas tipograficas
base() {  # <archivo> <estado> <qa> <seg> [hallazgos]
  printf '# %s — en-revisión\nEstado: %s (ver %snota%s)\nSensible a seguridad: sí\nQA: %s\nSeguridad: %s\nHallazgos abiertos: %s\nRigor: critico\n\n## Historia\n\nTexto en-revisión y "otra" cosa.\n' \
    "$(basename "$1" .md)" "$2" "$Q" "$QC" "$3" "$4" "${5:-(ninguno)}" > "$1"
}
verde() { base "$1" "$2" aprobado aprobado; }
edit() {  # <fp> <old> <new> [ra-json]
  jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" --argjson ra "${4:-null}" \
   '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
     tool_input:({file_path:$fp,old_string:$os,new_string:$ns} + (if $ra==null then {} else {replace_all:$ra} end))}'
}
multi() { # <fp> <edits-json>
  jq -n --arg fp "$1" --argjson ed "$2" \
   '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,edits:$ed}}'
}
corre() { # <nombre> <fp> <json>
  local h1 h2 out dec mot
  h1="$( [ -f "$2" ] && sha256sum < "$2" | cut -c1-12 || echo nofile)"
  out="$(printf '%s' "$3" | "$H/guard.sh" 2>/dev/null)"
  h2="$( [ -f "$2" ] && sha256sum < "$2" | cut -c1-12 || echo nofile)"
  if grep -Eq '"permissionDecision": *"deny"' <<< "$out"; then dec=deny; else dec=allow; fi
  mot="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" 2>/dev/null)"
  printf '%-4s | %-5s | disco:%s | %s\n' "$1" "$dec" "$([ "$h1" = "$h2" ] && echo igual || echo CAMBIA)" "${mot:0:150}"
}
F="$P/requirements/REQ-1.md"
# K01 control: literal, cierra con QA pendiente -> deny (por QA)
base "$F" en-revisión pendiente pendiente 'SEC-1 (contrato)'
corre K01 "$F" "$(edit "$F" 'Estado: en-revisión' 'Estado: completado')"
# K02 C1-like: comillas rectas, new = valor terminal
corre K02 "$F" "$(edit "$F" 'en-revisión (ver "nota")' 'completado (ver "nota")')"
# K03 replace_all:true literal que aparece 3 veces -> se juzga el resultado (Estado cambia) -> deny por QA
corre K03 "$F" "$(edit "$F" 'en-revisión' 'completado' true)"
# K04 replace_all:true, no literal -> deny CA-13
corre K04 "$F" "$(edit "$F" 'en-revisión (ver "nota")' 'completado' true)"
# K05 replace_all:"true" (cadena) con old que aparece 3 veces: el hook sustituye la primera (titulo)
corre K05 "$F" "$(edit "$F" 'en-revisión' 'completado' '"true"')"
# K05b replace_all:1 (numero)
corre K05b "$F" "$(edit "$F" 'en-revisión' 'completado' 1)"
# K06 sin replace_all, old aparece varias veces (el host fallaria): decision del hook
corre K06 "$F" "$(edit "$F" 'en-revisión' 'completado')"
# K07 MultiEdit: ed1 literal, ed2 busca lo que ed1 destruyo -> deny ed 2
corre K07 "$F" "$(multi "$F" '[{"old_string":"QA: pendiente","new_string":"QA: aprobado"},{"old_string":"QA: pendiente","new_string":"x"}]')"
# K08 MultiEdit: ed2 literal solo gracias a ed1 (crea el texto) -> reconstruible -> juicio (cierra con Seg pendiente -> deny)
corre K08 "$F" "$(multi "$F" '[{"old_string":"QA: pendiente","new_string":"QA: aprobado\nZZZ"},{"old_string":"ZZZ\n","new_string":""}]')"
# K09 MultiEdit: ed1 literal inocua, ed2 no literal que cierra -> deny ed 2 de 2
corre K09 "$F" "$(multi "$F" '[{"old_string":"Texto","new_string":"Texto."},{"old_string":"en-revisión (ver \"nota\")","new_string":"completado"}]')"
# K10 MultiEdit: edits vacio
corre K10 "$F" "$(multi "$F" '[]')"
# K11 MultiEdit: edit con old_string null
corre K11 "$F" "$(multi "$F" '[{"old_string":null,"new_string":"Estado: completado"}]')"
# K12 Edit sin old_string (clave ausente)
corre K12 "$F" "$(jq -n --arg fp "$F" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,new_string:"x"}}')"
# K13 old solo difiere en blanco final
corre K13 "$F" "$(edit "$F" 'QA: pendiente ' 'QA: aprobado ')"
# K14 old en NFD (e + combinante) frente a NFC en disco
corre K14 "$F" "$(edit "$F" $'en-revisión' 'completado')"
# K15 old con ó escapado literal (G1)
corre K15 "$F" "$(edit "$F" "Estado: en-revisi${BSL}u00f3n" 'Estado: completado')"
# K16 new con & y \& (fidelidad de la sustitucion): literal, no toca estado -> allow
corre K16 "$F" "$(edit "$F" 'Texto en-revisión' 'Texto & \& \\ $x')"
# K17 new con escape a del valor terminal, old literal (lo que haga el host no se mide aqui)
corre K17 "$F" "$(edit "$F" 'Estado: en-revisión' "Estado: complet${BSL}u0061do")"
# --- rutas ---
D="$P/requirements/dir.md"; mkdir -p "$D"
corre K18 "$D" "$(edit "$D" '' '# REQ\nEstado: completado\n')"
corre K18b "$D" "$(edit "$D" 'x' 'y')"
ln -s "$F" "$P/requirements/enlace.md"
corre K19 "$P/requirements/enlace.md" "$(edit "$P/requirements/enlace.md" 'Texto' 'Texto.')"
ln -s "$P/requirements/noexiste.md" "$P/requirements/colgante.md"
corre K20 "$P/requirements/colgante.md" "$(edit "$P/requirements/colgante.md" '' $'# REQ-9\nEstado: completado\nQA: pendiente\n')"
mkfifo "$P/requirements/fifo.md"
corre K21 "$P/requirements/fifo.md" "$(edit "$P/requirements/fifo.md" '' 'x')"
# K22 ruta con .. (src/../requirements/REQ-1.md), no literal
corre K22 "$F" "$(edit "$P/src/../requirements/REQ-1.md" 'en-revisión (ver "nota")' 'completado')"
# K23 ruta relativa
corre K23 "$F" "$( cd "$P" && edit "requirements/REQ-1.md" 'en-revisión (ver "nota")' 'completado')"
# K24 ruta con // doble
corre K24 "$F" "$(edit "$P/requirements//REQ-1.md" 'en-revisión (ver "nota")' 'completado')"
# --- creacion ---
N="$P/requirements/REQ-2.md"
corre K25 "$N" "$(edit "$N" '' $'# REQ-2\nEstado: completado\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: aprobado\nRigor: critico\n')"
corre K26 "$N" "$(edit "$N" '' $'# REQ-2\n**Estado:** completado\nQA: pendiente\n')"
corre K27 "$N" "$(multi "$N" '[{"old_string":"","new_string":"# REQ-2\nEstado: en-revisión\n"}]')"
corre K28 "$N" "$(multi "$N" '[{"old_string":"","new_string":"# REQ-2\nEstado: en-revisión\n"},{"old_string":"en-revisión","new_string":"completado"}]')"
# K29 creacion con CRLF y estado terminal, QA pendiente
corre K29 "$N" "$(edit "$N" '' $'# REQ-2\r\nEstado: completado\r\nQA: pendiente\r\n')"
# K30 creacion en carpeta inexistente
corre K30 "$P/requirements/sub/REQ-3.md" "$(edit "$P/requirements/sub/REQ-3.md" '' $'# REQ-3\nEstado: completado\nQA: pendiente\n')"
# --- archivo vacio existente ---
: > "$P/requirements/vacio.md"
corre K31 "$P/requirements/vacio.md" "$(edit "$P/requirements/vacio.md" '' $'# REQ-4\nEstado: completado\n')"
# --- CRLF mixto ---
G="$P/requirements/REQ-5.md"
printf '# REQ-5\r\nEstado: en-revisión\nSensible a seguridad: sí\r\nQA: pendiente\nSeguridad: pendiente\r\nRigor: critico\n' > "$G"
corre K32 "$G" "$(edit "$G" $'Estado: en-revisión\nSensible a seguridad: sí\nQA: pendiente' $'Estado: completado\nSensible a seguridad: sí\nQA: pendiente')"
corre K33 "$G" "$(edit "$G" $'Estado: en-revisión\r\nSensible' $'Estado: completado\r\nSensible')"
corre K34 "$G" "$(edit "$G" $'# REQ-5\nEstado: en-revisión' $'# REQ-5\nEstado: en-revisión')"
# --- reapertura y legitimos ---
C="$P/requirements/REQ-6.md"; verde "$C" completado
corre K35 "$C" "$(edit "$C" 'Estado: completado' 'Estado: en-progreso')"
corre K36 "$C" "$(edit "$C" 'completado (ver "nota")' 'en-progreso (ver "nota")')"
V="$P/requirements/REQ-7.md"; verde "$V" en-revisión
corre K37 "$V" "$(edit "$V" 'Texto en-revisión' 'Texto revisado')"
corre K38 "$V" "$(edit "$V" 'Estado: en-revisión' 'Estado: completado')"
corre K39 "$V" "$(multi "$V" '[{"old_string":"Texto","new_string":"Texto2"},{"old_string":"Estado: en-revisión","new_string":"Estado: completado"}]')"
# --- archivo con NUL (SEC-002, fuera de CA-13 por (iv)) ---
Z="$P/requirements/REQ-8.md"; base "$Z" ado pendiente pendiente 'SEC-1 (contrato)'; printf 'cola\0byte\n' >> "$Z"
corre K40 "$Z" "$(edit "$Z" 'Estado: ' 'Estado: complet')"
corre K41 "$Z" "$(edit "$Z" 'en-revisión (ver "nota")' 'completado')"
# --- README no REQ ---
Rd="$P/requirements/README.md"; printf '# Requerimientos\n\nLista “uno”.\n' > "$Rd"
corre K42 "$Rd" "$(edit "$Rd" 'Lista "uno".' 'Lista "dos".')"
corre K43 "$Rd" "$(edit "$Rd" 'Lista “uno”.' 'Lista dos.')"
# --- otras herramientas dentro de lo que cubre el hook ---
W="$P/requirements/REQ-10.md"; base "$W" en-revisión pendiente pendiente
corre K44 "$W" "$(jq -n --arg fp "$W" --arg c "$(sed 's/^Estado: en-revisión/Estado: completado/' "$W")" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,content:$c}}')"
corre K45 "$W" "$(jq -n --arg c "sed -i 's/en-revisión/completado/' requirements/REQ-10.md" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{command:$c}}')"
# K46 ruta docs/../requirements (coordinadora), no literal
corre K46 "$F" "$(edit "$P/docs/../requirements/REQ-1.md" 'en-revisión (ver "nota")' 'completado')"
# K47 ruta src/../requirements como desarrollador, no literal
corre K47 "$F" "$(edit "$P/src/../requirements/REQ-1.md" 'en-revisión (ver "nota")' 'completado' | jq -c '. + {agent_type:"desarrollador",agent_id:"a1"}')"
# K48 ruta ./requirements/./REQ-1.md, no literal
corre K48 "$F" "$(edit "$P/requirements/./REQ-1.md" 'en-revisión (ver "nota")' 'completado')"
# --- motivo: bytes >=0x80 crudos, longitud, herramientas nombradas ---
L="$(printf '“%.0s' {1..60})"
out="$(edit "$F" "$L" 'x' | "$H/guard.sh" 2>/dev/null)"
mot="$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out")"
printf 'M1   | motivo old=60 comillas tipograficas (180 bytes): %s bytes; bytes>=0x80 crudos: %s; nombra Bash/Write/MultiEdit-en-Edit: %s\n' \
  "$(printf '%s' "$mot" | LC_ALL=C wc -c)" "$(printf '%s' "$mot" | LC_ALL=C grep -c $'[\x80-\xff]')" "$(grep -oE 'Bash|Write|NotebookEdit' <<< "$mot" | sort -u | tr '\n' ' ')"
printf 'M1t  | %s\n' "$mot"
out="$(edit "$F" "it's 'x' en-revisión" 'x' | "$H/guard.sh" 2>/dev/null)"
printf 'M2t  | %s\n' "$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" | grep -o 'El old_string.*es [^.]*\.')"
out="$(multi "$F" '[{"old_string":"Texto","new_string":"T"},{"old_string":"Texto","new_string":"U"}]' | "$H/guard.sh" 2>/dev/null)"
printf 'M3t  | %s\n' "$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$out" | cut -c1-200)"
