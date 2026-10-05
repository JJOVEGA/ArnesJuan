#!/usr/bin/env bash
# QA fase 3 de SEC-120: proyecto y entradas de ataque (casos propios de QA). Cada entrada es un archivo en entradas/.
# Prefijos: I* formas de entrada ilegible o al borde; N* campos que no son texto; M* edits malformados;
#           R* restos y raíces; F* entradas legibles normales (falsos positivos). Sufijo -c coordinadora, -d desarrollador.
set -euo pipefail
Q=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120/qa; P="$Q/proyecto"; D="$Q/entradas"; R="$P/requirements"
rm -rf "$P" "$D"; mkdir -p "$P/.arnes" "$R" "$P/src" "$P/docs" "$D"
cat > "$P/.arnes/config.json" <<'J'
{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}
J
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
req() { printf '# %s\nEstado: en-revisión\nSensible a seguridad: sí\nQA: %s\nSeguridad: %s\nRigor: critico\n\n## Historia\nnota\n' "${1##*/}" "$2" "$2" > "$1"; }
req "$R/REQ-900.md" pendiente; req "$R/REQ-901.md" aprobado; printf 'x\n' > "$P/src/a.ts"; printf 'n\n' > "$P/docs/n.md"
AC='{}'; AD='{agent_id:"a1",agent_type:"desarrollador"}'
# e <json jq sin agente> <nombre>: escribe -c (coordinadora) y -d (desarrollador)
e() { jq -cn --arg c "$P" --arg R "$R" "{hook_event_name:\"PreToolUse\",cwd:\$c} + $1" > "$D/$2-c.json"
      jq -cn --arg c "$P" --arg R "$R" "{hook_event_name:\"PreToolUse\",cwd:\$c} + $1 + $AD" > "$D/$2-d.json"; }
raw() { printf '%b' "$1" > "$D/$2.json"; }
CIERRE='tool_name:"Edit",tool_input:{file_path:($R+"/REQ-900.md"),old_string:"Estado: en-revisión",new_string:"Estado: completado"}'
e "{$CIERRE}" F00-cierre-rojo
c="$(cat "$D/F00-cierre-rojo-c.json")"; d="$(cat "$D/F00-cierre-rojo-d.json")"
# --- I: formas de la entrada
raw ''                       I01-vacia
raw ' \n\t\n'                I02-solo-blancos
raw 'null'                   I03-null
raw '5'                      I04-numero
raw '"Edit"'                 I05-cadena
raw 'true'                   I06-true
raw '[]'                     I07-lista-vacia
printf '[%s]' "$c"         > "$D/I08-lista-con-cierre.json"
printf '%s%s' "$c" "$c"    > "$D/I09-dos-objetos.json"
printf '%s x' "$c"         > "$D/I10-objeto-y-basura.json"
printf '%s\0{"x":1}' "$c"  > "$D/I11-objeto-NUL-basura.json"
printf '\0%s' "$c"         > "$D/I12-NUL-objeto.json"
printf '\xef\xbb\xbf%s' "$c" > "$D/I13-BOM-objeto.json"
printf '%s null' "$c"      > "$D/I14-objeto-y-null.json"
printf '%s\n\n' "$c"       > "$D/I15-objeto-saltos-finales.json"
printf '%s' "${c%?}"       > "$D/I16-truncada.json"
printf '%s' "${c%?},\"x\":\"\xff\xfe\"}" > "$D/I17-utf8-invalido.json"
printf '%s' "${c%?},\"x\":\"\\\\ud800\"}" > "$D/I18-surrogado-suelto.json"
printf '%s' "${c%?},\"tool_name\":\"Bash\"}" > "$D/I19-clave-duplicada-ultima-Bash.json"
printf '%s' "${c%?},\"x\":nan}" > "$D/I20-nan.json"
printf '%s' "${c%?},\"x\":NaN}" > "$D/I21-NaN.json"
printf '%s' "${c%?},\"x\":Infinity}" > "$D/I22-Infinity.json"
printf '%s' "${c%?},\"x\":1e1000}" > "$D/I23-numero-enorme.json"
printf '%s' "${c%?},\"x\":01}" > "$D/I24-cero-inicial.json"
printf '%s' "${c%?},}" > "$D/I25-coma-final.json"
printf "%s" "${c//\"/\'}" > "$D/I26-comillas-simples.json"
printf '%s' "${d%?},\"x\":\"\xff\"}" > "$D/I27-utf8-invalido-dev.json"
printf '%s' "${c/\"tool_name\"/\"tool_\\\\u006eame\"}" > "$D/I28-escape-en-clave.json"
printf '%s' "${c%?}  // c\n}" > "$D/I29-comentario.json"
# --- N: campos que no son texto
for v in 5 false true null '[]' '{}' '["x"]'; do s="${v//[^a-z0-9]/_}"
  e "{tool_name:$v,tool_input:{file_path:(\$R+\"/REQ-900.md\"),old_string:\"Estado: en-revisión\",new_string:\"Estado: completado\"}}" "N0-tool_name-$s"
  e "{tool_name:\"Edit\",tool_input:{file_path:$v,old_string:\"Estado: en-revisión\",new_string:\"Estado: completado\"}}" "N1-edit-file_path-$s"
  e "{tool_name:\"Write\",tool_input:{file_path:$v,content:\"x\"}}" "N2-write-file_path-$s"
  e "{tool_name:\"Bash\",tool_input:{command:$v}}" "N3-bash-command-$s"
  e "{tool_name:\"Write\",tool_input:{file_path:(\$R+\"/REQ-900.md\"),content:$v}}" "N4-write-content-req-$s"
  e "{tool_name:\"Edit\",tool_input:{file_path:(\$R+\"/REQ-900.md\"),old_string:\"Estado: en-revisión\",new_string:$v}}" "N5-edit-new_string-req-$s"
  e "{tool_name:\"Edit\",tool_input:{file_path:(\$R+\"/REQ-900.md\"),old_string:$v,new_string:\"Estado: completado\"}}" "N6-edit-old_string-req-$s"
  e "{tool_name:\"Edit\",tool_input:$v}" "N7-edit-tool_input-$s"
  e "{tool_name:\"Bash\",tool_input:$v}" "N8-bash-tool_input-$s"
  e "{tool_name:\"Write\",tool_input:{file_path:\"src/a.ts\",content:\"x\"},cwd:$v}" "N9-write-src-cwd-$s"
done
e "{tool_name:\"Write\",tool_input:{file_path:[\"src/a.ts\"],content:\"x\"}}" NA-write-file_path-lista-src
e "{tool_name:\"Bash\",tool_input:{command:[\"echo x > src/a.ts\"]}}" NB-bash-command-lista-escritura
e "{tool_name:\"Bash\",tool_input:{command:[\"git reset --hard\"]}}" NC-bash-command-lista-git
e "{tool_name:\"Edit\",tool_input:{file_path:(\$R+\"/REQ-900.md\"),old_string:\"Estado: en-revisión\",new_string:\"Estado: completado\",replace_all:\"true\"}}" ND-replace_all-cadena
e "{tool_name:\"Write\",tool_input:{file_path:\"src/a.ts\",content:\"x\"},agent_id:5,agent_type:[\"desarrollador\"]}" NE-agente-no-texto
e "{tool_name:\"Write\",tool_input:{file_path:\"src/a.ts\",content:\"x\"},agent_id:false,agent_type:false}" NF-agente-false
# --- M: edits malformados (MultiEdit sobre el REQ en rojo; y sobre docs/n.md, que la puerta de cierre no trocea)
for v in 'null' '[]' '[null]' '[[]]' '[1]' '[{}]' '[{old_string:"Estado: en-revisión",new_string:"Estado: completado"},5]' '[{old_string:"Estado: en-revisión",new_string:{a:1}}]' '[{old_string:["Estado: en-revisión"],new_string:"Estado: completado"}]' '[{old_string:"Estado: en-revisión",new_string:"Estado: completado",replace_all:1}]' '{"0":{old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' 'true' 'false'; do
  s="$(printf '%s' "$v" | md5sum | cut -c1-6)"
  e "{tool_name:\"MultiEdit\",tool_input:{file_path:(\$R+\"/REQ-900.md\"),edits:$v}}" "M1-req-$s"
  e "{tool_name:\"MultiEdit\",tool_input:{file_path:(\$c+\"/docs/n.md\"),edits:$v}}" "M2-docs-$s"
  printf '%s\t%s\n' "$s" "$v" >> "$D/_M-claves.tsv"
done
e "{tool_name:\"MultiEdit\",tool_input:{file_path:(\$R+\"/REQ-900.md\")}}" M3-req-sin-edits
# --- F: legibles normales que deben decidir como en v1.35.0
e "{tool_name:\"Bash\",tool_input:{command:\"ls -la\",description:\"listar\",timeout:120000,run_in_background:false}}" F01-bash-con-timeout
e "{tool_name:\"Bash\",tool_input:{command:\"echo x > src/a.ts\",timeout:5}}" F02-bash-escribe-src-timeout
e "{tool_name:\"Edit\",tool_input:{file_path:(\$R+\"/REQ-901.md\"),old_string:\"nota\",new_string:\"otra nota\",replace_all:true}}" F03-edit-req-replace_all
e "{tool_name:\"MultiEdit\",tool_input:{file_path:(\$R+\"/REQ-901.md\"),edits:[{old_string:\"nota\",new_string:\"otra\",replace_all:false}]}}" F04-multiedit-req
e "{tool_name:\"MultiEdit\",tool_input:{file_path:(\$R+\"/REQ-901.md\"),edits:[]}}" F05-multiedit-req-sin-ediciones
e "{tool_name:\"Write\",tool_input:{file_path:(\$R+\"/REQ-901.md\"),content:\"\"}}" F06-write-req-vacio
e "{tool_name:\"Write\",tool_input:{file_path:(\$c+\"/docs/n.md\"),content:\"ñ € 😀\"}}" F07-write-docs-unicode
e "{tool_name:\"Edit\",tool_input:{file_path:(\$R+\"/REQ-901.md\"),old_string:\"nota\",new_string:\"ñ 😀\",extra:{a:[1,2]}}}" F08-edit-req-extra-anidado
e "{tool_name:\"Edit\",tool_input:{file_path:(\$R+\"/REQ-901.md\"),old_string:\"nota\",new_string:\"x\"},tool_use_id:\"t1\",session_id:\"s\",transcript_path:\"/tmp/x\",permission_mode:\"default\"}" F09-edit-req-campos-del-host
e "{tool_name:\"Write\",tool_input:{file_path:\"src/a.ts\",content:\"x\"}}" F10-write-src
e "{tool_name:\"Bash\",tool_input:{command:\"git status\"}}" F11-git-status
e "{tool_name:\"Bash\",tool_input:{command:\"git reset --hard\"}}" F12-git-reset-hard
e "{tool_name:\"Edit\",tool_input:{file_path:(\$R+\"/REQ-901.md\"),old_string:\"Estado: en-revisión\",new_string:\"Estado: completado\"}}" F13-cierre-verde
printf '%s\n' "$(cat "$D/F13-cierre-verde-c.json")" > "$D/F14-cierre-verde-con-salto-final-c.json"
printf ' \n%s\n ' "$(cat "$D/F13-cierre-verde-c.json")" > "$D/F15-cierre-verde-blancos-alrededor-c.json"
jq . "$D/F13-cierre-verde-c.json" > "$D/F16-cierre-verde-multilinea-c.json"
ls "$D" | wc -l
