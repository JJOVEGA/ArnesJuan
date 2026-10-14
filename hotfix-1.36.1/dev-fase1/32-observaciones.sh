#!/usr/bin/env bash
# observaciones.sh <hooks candidata> <hooks v1.36.0> — formas vecinas de M-032, medidas en los dos árboles (por guard.sh).
HC="$1"; HV="$2"; P="$(mktemp -d)"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
cat > "$P/.arnes/config.json" <<'J'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] }, "quality_gates": ["true"], "estados": { "completado": "completado" },
  "requirements_dir": "requirements", "pending_approval": "PENDING_APPROVAL.md" }
J
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; echo n > "$P/docs/notas.md"; echo a > "$P/src/a.ts"; echo r > "$P/a.ts"
printf 'x\n' > "$P/\$X"
j() { jq -cn --arg c "$1" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$cwd,tool_input:{command:$c}}'; }
d() { local out; out="$(j "$2" | CLAUDE_PROJECT_DIR="$P" bash "$1/guard.sh" 2>/dev/null)"; case "$out" in *'"deny"'*) printf deny;; *) printf allow;; esac; }
printf '%-8s %-8s %s\n' candidata v1.36.0 'comando (coordinadora, cwd <raíz>; <raíz>/a.ts y <raíz>/$X existen como archivos regulares)'
for c in 'mv src/a.ts docs/nuevo.md' 'mv src/a.ts docs/notas.md' \
         'cd src && cp S a.ts' 'cd src && cat S > a.ts' \
         'cp S $X' 'cat S > $X' \
         'cp --backup S docs/notas.md' 'cp -t src docs/notas.md' 'cp S1 S2 docs/notas.md'; do
  printf '%-8s %-8s %s\n' "$(d "$HC" "$c")" "$(d "$HV" "$c")" "$c"
done
rm -rf "$P"
