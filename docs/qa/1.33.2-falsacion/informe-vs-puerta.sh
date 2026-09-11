set -u
HOOKS="$1"; TOOLS="$2"; ETIQ="$3"
RAIZ="$(mktemp -d)"; trap 'rm -rf "$RAIZ"' EXIT
PROJ="$RAIZ/p"; mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
cat > "$PROJ/.arnes/config.json" <<'CFG'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
CFG
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$PROJ"
i=0
for f in "critico (por suelo)" "estandar (x)" "ligero (local)"; do
  i=$((i+1))
  printf '# REQ-%s\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: pendiente\nRigor: %s\n' \
    "$i" "$f" > "$PROJ/requirements/REQ-$i.md"
done
echo "######## $ETIQ ########"
echo "-- lo que dice el INFORME (tools/arnes-lectura.sh) --"
( cd "$PROJ" && ARNES_HOOKS_DIR="$HOOKS" "$TOOLS/arnes-lectura.sh" 2>&1 | grep -A2 -E 'Rigor:' | sed 's/^/   /' )
echo "-- lo que hace la PUERTA (cierra con QA aprobado y Seguridad PENDIENTE?) --"
for i in 1 2 3; do
  j="$(jq -n --arg fp "$PROJ/requirements/REQ-$i.md" '{hook_event_name:"PreToolUse",tool_name:"Edit",
      cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}')"
  o="$(printf '%s' "$j" | "$HOOKS/guard-completado.sh" 2>/dev/null)"
  d=allow; printf '%s' "$o" | grep -Eq '"permissionDecision": *"deny"' && d=deny
  printf '   REQ-%s  %-22s -> %s   %s\n' "$i" "$(sed -n 's/^Rigor: //p' "$PROJ/requirements/REQ-$i.md")" "$d" \
    "$([ "$d" = deny ] && echo '(rigor efectivo = critico: exige seguridad)' || echo '(rigor efectivo = estandar o menor)')"
done
