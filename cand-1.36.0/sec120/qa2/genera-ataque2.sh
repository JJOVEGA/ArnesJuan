#!/usr/bin/env bash
# QA, re-verificación de la pasada correctiva de SEC-120 (413c6bd): entradas propias NUEVAS (prefijos Z y T),
# sobre el proyecto de la fase 3 (qa/proyecto). Z*: NUL en otras posiciones y entradas grandes;
# T*: tipos en los campos que lee cada puerta; G*: legibles normales (falsos positivos). -c coordinadora, -d desarrollador.
set -euo pipefail
Q=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120/qa; P="$Q/proyecto"; R="$P/requirements"
D=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120/qa2/entradas; rm -rf "$D"; mkdir -p "$D"
[ -f "$P/.arnes/config.json" ] || { echo "falta $P"; exit 1; }
AD='{agent_id:"a1",agent_type:"desarrollador"}'
j()  { jq -cn --arg c "$P" --arg R "$R" "{hook_event_name:\"PreToolUse\",cwd:\$c} + $1"; }
e()  { j "$1" > "$D/$2-c.json"; j "$1 + $AD" > "$D/$2-d.json"; }
LS_C="$(j '{tool_name:"Bash",tool_input:{command:"ls -la"}}')"; LS_D="$(j "{tool_name:\"Bash\",tool_input:{command:\"ls -la\"}} + $AD")"
ESC_C="$(j '{tool_name:"Bash",tool_input:{command:"echo x > src/a.ts"}}')"; ESC_D="$(j "{tool_name:\"Bash\",tool_input:{command:\"echo x > src/a.ts\"}} + $AD")"
CIE_C="$(j '{tool_name:"Edit",tool_input:{file_path:($R+"/REQ-900.md"),old_string:"Estado: en-revisión",new_string:"Estado: completado"}}')"
# --- Z: NUL en otras posiciones
printf '%s\0'      "$LS_C" > "$D/Z01-ls-c-NUL-final.json"
printf '%s\0'      "$LS_D" > "$D/Z01-ls-d-NUL-final.json"
printf '%s\n\0'    "$LS_C" > "$D/Z02-ls-c-salto-NUL.json"
printf '%s\0%s'    "$LS_C" "$ESC_C" > "$D/Z04-ls-c-NUL-escritura-c.json"
printf '%s\0%s'    "$LS_D" "$ESC_D" > "$D/Z04-ls-d-NUL-escritura-d.json"
printf ' \n\0%s'   "$LS_C" > "$D/Z05-blancos-NUL-ls-c.json"
printf '\0'        > "$D/Z06-un-NUL.json"
printf '%s\0'      "$CIE_C" > "$D/Z07-cierre-rojo-c-NUL.json"
printf '%s\0%s'    "$ESC_D" "$LS_D" > "$D/Z08-escritura-d-NUL-ls-d.json"
printf '%s\0'      "$ESC_D" > "$D/Z09-escritura-d-NUL-final.json"
# NUL DENTRO de una cadena del JSON (byte crudo): ls<NUL> > src/a.ts
c="${LS_C%\"*}"; printf '%s\0 > src/a.ts"}}' "$c" > "$D/Z03-NUL-dentro-del-command-c.json"
c="${LS_C%%\"tool_name*}"; printf '%s\0"tool_name":"Bash","tool_input":{"command":"ls"}}' "$c" > "$D/Z10-NUL-entre-claves-c.json"
printf '\r'   > "$D/Z11-solo-CR.json"; printf '\r\n' > "$D/Z12-CRLF.json"; printf '\xef\xbb\xbf' > "$D/Z13-solo-BOM.json"
# Grandes: 65536 bytes en el command (legible), y lo mismo con un NUL al final o en medio; 1 MiB de NUL.
A="$(head -c 65536 /dev/zero | tr '\0' a)"
j "{tool_name:\"Bash\",tool_input:{command:(\"ls \" + \"$A\")}}" > "$D/G01-ls-c-64KiB.json"
printf '%s\0' "$(cat "$D/G01-ls-c-64KiB.json")" > "$D/Z14-ls-c-64KiB-NUL-final.json"
g="$(cat "$D/G01-ls-c-64KiB.json")"; printf '%s\0%s' "${g:0:40000}" "${g:40000}" > "$D/Z15-ls-c-64KiB-NUL-en-medio.json"
head -c 1048576 /dev/zero > "$D/Z16-1MiB-de-NUL.json"
{ printf '%s' "$ESC_C"; head -c 1048576 /dev/zero; } > "$D/Z17-escritura-c-1MiB-NUL.json"
printf '%s' "$(head -c 1048576 /dev/zero | tr '\0' ' ')" > "$D/Z18-1MiB-de-blancos.json"
# --- T: tipos en los campos que lee cada puerta
for H in Edit Write MultiEdit Bash; do
  for V in false true 0 '"x"' '["x"]' '[]'; do
    n="$(printf '%s' "$V" | tr -d '"[]' )"; [ -n "$n" ] || n=listavacia; [ "$V" = '["x"]' ] && n=listax; [ "$V" = '"x"' ] && n=cadena
    e "{tool_name:\"$H\",tool_input:$V}" "T01-$H-tool_input-$n"
  done
done
for V in false true 0 '{}' '[]' '""'; do
  n="$(printf '%s' "$V" | tr -d '"')"; [ -n "$n" ] || n=vacia; [ "$V" = '{}' ] && n=objeto; [ "$V" = '[]' ] && n=lista
  e "{tool_name:\"Edit\",tool_input:{file_path:$V,old_string:\"a\",new_string:\"b\"}}"      "T02-Edit-file_path-$n"
  e "{tool_name:\"Write\",tool_input:{file_path:$V,content:\"x\"}}"                         "T03-Write-file_path-$n"
  e "{tool_name:\"MultiEdit\",tool_input:{file_path:$V,edits:[{old_string:\"a\",new_string:\"b\"}]}}" "T04-MultiEdit-file_path-$n"
  e "{tool_name:\"Bash\",tool_input:{command:$V}}"                                         "T05-Bash-command-$n"
  # el campo que la puerta NO necesita: decide como siempre
  e "{tool_name:\"Edit\",tool_input:{file_path:(\$c+\"/docs/n.md\"),old_string:\"n\",new_string:\"m\",command:$V}}" "T06-Edit-docs-command-$n"
  e "{tool_name:\"Bash\",tool_input:{command:\"ls -la\",file_path:$V}}"                   "T07-Bash-ls-file_path-$n"
  e "{tool_name:\"Bash\",tool_input:{command:\"echo x > src/a.ts\",file_path:$V}}"        "T08-Bash-escribe-src-file_path-$n"
done
e '{tool_name:"Edit",tool_input:{file_path:($R+"/REQ-900.md"),old_string:"Estado: en-revisión",new_string:"Estado: completado",command:false}}' T09-Edit-cierre-rojo-command-false
e '{tool_name:"Edit",tool_input:{file_path:($R+"/REQ-901.md"),old_string:"nota",new_string:"otra",command:false}}' T10-Edit-req-literal-command-false
for H in Read Glob Grep NotebookEdit; do e "{tool_name:\"$H\",tool_input:false}" "T11-$H-tool_input-false"; e "{tool_name:\"$H\",tool_input:{file_path:false,command:false}}" "T12-$H-campos-false"; done
e '{tool_name:"Edit",tool_input:{file_path:"src/a.ts",old_string:"x",new_string:"y"},agent_type:false}' T13-Edit-src-agent_type-false
e '{tool_name:"Edit",tool_input:{file_path:"src/a.ts",old_string:"x",new_string:"y"},cwd:false}'        T14-Edit-src-cwd-false
# --- G: legibles normales
e '{tool_name:"Bash",tool_input:{command:"git status"}}'                               G02-git-status
e '{tool_name:"Bash",tool_input:{command:"ls -la",timeout:120000,description:"x"}}'   G03-ls-timeout
e '{tool_name:"Edit",tool_input:{file_path:"docs/n.md",old_string:"n",new_string:"m"}}' G04-edit-docs-relativa
e '{tool_name:"Edit",tool_input:{file_path:($R+"/REQ-901.md"),old_string:"nota",new_string:"otra nota"}}' G05-edit-literal-req
e '{tool_name:"MultiEdit",tool_input:{file_path:($R+"/REQ-901.md"),edits:[{old_string:"nota",new_string:"otra nota"}]}}' G06-multiedit-req
e '{tool_name:"Write",tool_input:{file_path:($c+"/docs/nuevo.md"),content:""}}'         G07-write-vacio-docs
e '{tool_name:"Edit",tool_input:{file_path:"src/a.ts",old_string:"x",new_string:"y"}}'  G08-edit-src
e '{tool_name:"Bash",tool_input:{command:"echo x > src/a.ts"}}'                        G09-bash-escribe-src
printf '%s\n' "$LS_C" > "$D/G10-ls-c-salto-final.json"; printf ' \t%s \n\n' "$LS_C" > "$D/G11-ls-c-blancos-alrededor.json"
j '{tool_name:"Bash",tool_input:{command:"ls"}}' | jq . > "$D/G12-ls-c-multilinea.json"
printf '\xef\xbb\xbf%s' "$LS_C" > "$D/G13-ls-c-BOM.json"
ls "$D" | wc -l
