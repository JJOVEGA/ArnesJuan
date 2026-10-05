#!/usr/bin/env bash
# Proyecto y entradas de procesos-sec120.sh. Entradas NORMALES (las que nombra el coste de CA-47 punto 20 —un
# Bash sin escrituras, un Edit literal de un REQ, un MultiEdit de un REQ— y otras del camino común) y las de
# SEC-120 (V1–V4 de R-045-A §4, el objeto, la lista de cadenas, la entrada truncada y valores que no son texto).
set -euo pipefail
E=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec120; P="$E/proyecto"; D="$E/entradas"; R="$P/requirements"
rm -rf "$P" "$D"; mkdir -p "$P/.arnes" "$R" "$P/src" "$P/docs" "$D"
cat > "$P/.arnes/config.json" <<'EOF'
{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}
EOF
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
req() { printf '# %s\nEstado: en-revisión\nSensible a seguridad: sí\nQA: %s\nSeguridad: %s\nRigor: critico\n\n## Historia\nnota\n' "${1##*/}" "$2" "$2" > "$1"; }
req "$R/REQ-900.md" pendiente; req "$R/REQ-901.md" aprobado; printf 'x\n' > "$P/src/a.ts"
h() { local a b; printf -v a '%*s' "$1" ''; printf -v b '%*s' "$1" ''; printf '%s%s' "${a// /[}" "${b// /]}"; }
e() { jq -cn --arg c "$P" "{hook_event_name:\"PreToolUse\",cwd:\$c} + $1" > "$D/$2.json"; }
e '{tool_name:"Bash",tool_input:{command:"ls -la"}}'                                                     n1-bash-ls
e "{tool_name:\"Edit\",tool_input:{file_path:\"$R/REQ-901.md\",old_string:\"nota\",new_string:\"otra nota\"}}" n2-edit-literal-req
e "{tool_name:\"MultiEdit\",tool_input:{file_path:\"$R/REQ-901.md\",edits:[{old_string:\"nota\",new_string:\"otra nota\"}]}}" n3-multiedit-req
e "{tool_name:\"Edit\",tool_input:{file_path:\"$R/REQ-900.md\",old_string:\"Estado: en-revisión\",new_string:\"Estado: completado\"}}" n4-edit-cierre-rojo
e "{tool_name:\"Write\",tool_input:{file_path:\"$P/src/a.ts\",content:\"x\"}}"                                 n5-write-src-coord
e '{tool_name:"Bash",tool_input:{command:"echo x > src/a.ts"}}'                                         n6-bash-escribe-src
e '{tool_name:"Bash",tool_input:{command:"git status"}}'                                                n7-bash-git-status
e "{tool_name:\"MultiEdit\",tool_input:{file_path:\"$R/REQ-900.md\",edits:\"[{\\\"old_string\\\":\\\"Estado: en-revisión\\\",\\\"new_string\\\":\\\"Estado: completado\\\"}]\"}}" s1-v1-edits-cadena
e "{tool_name:\"MultiEdit\",tool_input:{file_path:\"$R/REQ-900.md\",edits:1}}"                                 s2-v2-edits-numero
e "{tool_name:\"MultiEdit\",tool_input:{file_path:\"$R/REQ-900.md\",edits:{old_string:\"Estado: en-revisión\",new_string:\"Estado: completado\"}}}" s5-edits-objeto
e "{tool_name:\"MultiEdit\",tool_input:{file_path:\"$R/REQ-900.md\",edits:[\"Estado: completado\"]}}"         s6-edits-lista-cadenas
e "{tool_name:\"Edit\",tool_input:{file_path:\"$R/REQ-900.md\",old_string:\"Estado: en-revisión\",new_string:5}}" s7-new-string-numero
e "{tool_name:\"Write\",tool_input:{file_path:5,content:\"x\"}}"                                              s8-file-path-numero
e '{tool_name:"Bash",tool_input:{command:5}}'                                                           s9-command-numero
c="$(cat "$D/n4-edit-cierre-rojo.json")"
printf '%s' "${c%?},\"x\":$(h 10001)}" > "$D/s3-v3-10001-niveles.json"
printf '%s' "${c%?},\"x\":$(h 9000)}"  > "$D/s4-v4-9000-niveles.json"
printf '%s' "${c%?}"                    > "$D/s10-truncada.json"
printf 'null'                           > "$D/s11-null.json"
printf '%s%s' "$(cat "$D/n1-bash-ls.json")" "$c" > "$D/s12-dos-objetos.json"
ls "$D"
