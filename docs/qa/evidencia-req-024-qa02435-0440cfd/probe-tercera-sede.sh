#!/usr/bin/env bash
# La TERCERA sede: AGENTS.md:363 y templates/AGENTS.md.tpl:321 prometen, SIN condicion,
# que un veredicto fuera del vocabulario impide cerrar el REQ. Se mide con el hook real.
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
printf '%-12s %-10s %-9s %-9s %s\n' llave rigor "QA fuera" "SEG fuera" "AGENTS.md:363 dice «ese REQ no podra cerrarse»"
for llave in false true; do
  sed -i "s/\"ausencia_exige\": [a-z]*/\"ausencia_exige\": $llave/" "$P/.arnes/config.json"
  for r in ligero estandar critico; do
    f="$P/requirements/V.md"
    { printf '# R\nEstado: en-revisión\nSensible a seguridad: no\nRigor: %s\nHallazgos abiertos: (ninguno)\nQA: aprobadisimo\nSeguridad: aprobado\n' "$r"; } > "$f"
    a="$(go "$P" "$(j "$f" 'Estado: en-revisión' 'Estado: completado')")"
    g="$P/requirements/W.md"
    { printf '# R\nEstado: en-revisión\nSensible a seguridad: no\nRigor: %s\nHallazgos abiertos: (ninguno)\nQA: aprobado\nSeguridad: aprobadisimo\n' "$r"; } > "$g"
    b="$(go "$P" "$(j "$g" 'Estado: en-revisión' 'Estado: completado')")"
    v=""; [ "$a" = ALLOW ] && v="FALSA para QA:"; [ "$b" = ALLOW ] && v="$v${v:+ y }FALSA para Seguridad:"
    [ -z "$v" ] && v="cierta en esta celda"
    printf '%-12s %-10s %-9s %-9s %s\n' "$llave" "$r" "$a" "$b" "$v"
  done
done
