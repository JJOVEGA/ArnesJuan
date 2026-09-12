#!/usr/bin/env bash
set -u
H="$1"; BASE="$(mktemp -d)"; trap 'rm -rf "$BASE"' EXIT
P="$BASE/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
cat > "$P/.arnes/config.json" <<'JSON'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md", "campos": { "ausencia_exige": false } }
JSON
j() { jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:$os,new_string:$ns}}'; }
go() { local out dec=ALLOW; out="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" bash "$H/guard-completado.sh" 2>/dev/null)"
  printf '%s' "$out" | grep -Eq '"permissionDecision":"deny"' && dec=DENY; printf '%s' "$dec"; }
msg() { printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" bash "$H/guard-completado.sh" 2>/dev/null | jq -r '.hookSpecificOutput.permissionDecisionReason // .systemMessage // ""' 2>/dev/null; }
req() { local f="$1"; { printf '# R\nEstado: en-revisión\nSensible a seguridad: no\nRigor: %s\nHallazgos abiertos: (ninguno)\n' "$2"
  [ -n "$3" ] && printf '%s\n' "$3"; [ -n "$4" ] && printf '%s\n' "$4"; } > "$f"; }
cierre() { go "$P" "$(j "$1" 'Estado: en-revisión' 'Estado: completado')"; }

echo "=== A · TODO el vocabulario de Seguridad: en rigor critico (cierre) ==="
for v in aprobado pendiente con-hallazgos n/a preventiva vetado; do
  req "$P/requirements/S.md" critico 'QA: aprobado' "Seguridad: $v"
  printf '  Seguridad: %-14s -> %s\n' "$v" "$(cierre "$P/requirements/S.md")"
done
echo "=== B · TODO el vocabulario de QA: en rigor estandar (cierre) ==="
for v in aprobado pendiente con-hallazgos; do
  req "$P/requirements/Q.md" estandar "QA: $v" 'Seguridad: aprobado'
  printf '  QA: %-14s -> %s\n' "$v" "$(cierre "$P/requirements/Q.md")"
done
echo "=== C · BORDE: la edicion que BORRA la linea QA: dejando Seguridad: aprobado ==="
for k in false true; do
 sed -i "s/\"ausencia_exige\": [a-z]*/\"ausencia_exige\": $k/" "$P/.arnes/config.json"
 req "$P/requirements/X.md" critico 'QA: aprobado' 'Seguridad: aprobado'
 printf '  llave=%-5s borrar la linea QA: -> %s\n' "$k" "$(go "$P" "$(j "$P/requirements/X.md" 'QA: aprobado
' '')")"
done
echo "=== D · BORDE: cierre con QA ausente + Seguridad ausente, llave apagada ==="
sed -i 's/"ausencia_exige": [a-z]*/"ausencia_exige": false/' "$P/.arnes/config.json"
for r in ligero estandar critico; do
  req "$P/requirements/Z.md" "$r" '' ''; printf '  rigor=%-9s -> %s\n' "$r" "$(cierre "$P/requirements/Z.md")"
done
echo "=== E · el DENY por ausencia de QA (llave ON) NOMBRA el campo? ==="
sed -i 's/"ausencia_exige": [a-z]*/"ausencia_exige": true/' "$P/.arnes/config.json"
req "$P/requirements/N.md" ligero '' 'Seguridad: aprobado'
msg "$P" "$(j "$P/requirements/N.md" 'Estado: en-revisión' 'Estado: completado')" | head -c 300; echo
echo "=== F · el DENY al FIRMAR con QA ausente: que dice? ==="
req "$P/requirements/M.md" estandar '' 'Seguridad: pendiente'
msg "$P" "$(j "$P/requirements/M.md" 'Seguridad: pendiente' 'Seguridad: aprobado')" | head -c 400; echo
echo "=== G · FIRMAR preventiva con QA ausente (la salida declarada) ==="
for k in false true; do
 sed -i "s/\"ausencia_exige\": [a-z]*/\"ausencia_exige\": $k/" "$P/.arnes/config.json"
 req "$P/requirements/PV.md" critico '' 'Seguridad: pendiente'
 printf '  llave=%-5s Seguridad: preventiva -> %s\n' "$k" "$(go "$P" "$(j "$P/requirements/PV.md" 'Seguridad: pendiente' 'Seguridad: preventiva')")"
done
