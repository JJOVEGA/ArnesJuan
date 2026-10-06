#!/usr/bin/env bash
# Fase 2: lo legítimo que los techos alcanzan (CA-69 punto 3, «se declara aparte»). REQ reales de este repositorio,
# copiados a un proyecto de prueba, por guard.sh: Write del documento entero, y Edit de REQ-007.md con old_string
# de distintos tamaños (un trozo real del archivo). En el candidato y en v1.35.0, una corrida por punto, timeout 60.
# Uso: 64-req-legitimos.sh <scratch> <candidato/hooks> <v1.35.0/hooks> <worktree>
set -u; S="${1:?}"; C="${2:?}"; V="${3:?}"; WT="${4:?}"; W="$(mktemp -d "$S/leg-XXXX")"; trap 'rm -rf "$W"' EXIT
P="$W/p"; mkdir -p "$P/.arnes" "$P/requirements"
jq -nc '{agentes:{agente_codigo:"desarrollador"},codigo_app:{globs:["src/*"]},quality_gates:["true"],estados:{completado:"completado"},requirements_dir:"requirements",pending_approval:"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
mide() { local H=$1 et=$2 o rc t0 t1 d
  o="$(cd "$P"; export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$P"; unset LC_ALL; t0=$EPOCHREALTIME; timeout 60 bash "$H/guard.sh" < "$W/in.json"; rc=$?; t1=$EPOCHREALTIME; printf '\n@@ %s %s' "$rc" "$(( (${t1/./} - ${t0/./}) / 1000 ))")"
  rc="${o##*@@ }"; o="${o%$'\n'@@ *}"; d=nada; case "$o" in *'"deny"'*) d=deny ;; esac
  printf '%-46s %-34s rc=%s dec=%-4s ms=%-6s motivo<%s>\n' "$et" "${H%/hooks}" "${rc%% *}" "$d" "${rc##* }" "$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' <<< "$o" 2>/dev/null | cut -c1-100)"; }
echo "# $(date -Is); worktree $(git -C "$WT" rev-parse --short HEAD)"
for R in REQ-007 REQ-021 REQ-023; do
  cp "$WT/requirements/$R.md" "$P/requirements/"
  jq -Rs --arg fp "$P/requirements/$R.md" --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$fp,content:.}}' < "$P/requirements/$R.md" > "$W/in.json"
  for H in "$C" "$V"; do mide "$H" "Write de $R.md entero ($(wc -c < "$P/requirements/$R.md") B)"; done
done
for n in 3000 6000 6400 7000 12000; do
  o="$(sed -n 2170,2600p "$P/requirements/REQ-007.md" | head -c "$n")"
  jq -n --arg fp "$P/requirements/REQ-007.md" --arg c "$P" --arg o "$o" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:$o,new_string:($o+" x")}}' > "$W/in.json"
  for H in "$C" "$V"; do mide "$H" "Edit de REQ-007.md, old_string de $(printf %s "$o" | wc -c) B"; done
done
