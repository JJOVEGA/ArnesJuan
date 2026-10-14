#!/usr/bin/env bash
# 42-reloj-req017-ca08.sh <hooks candidata> <hooks v1.36.0> — el sujeto EXACTO de REQ-017 CA-08 (ii) («un REQ real de 6
# líneas»: guard-completado.sh con un Edit que cierra REQ-100), cabeza a cabeza candidata frente a v1.36.0, con
# sonda-reloj.sh y el mismo procedimiento de 37/5 (k=4, r=6, intercalado, mínimo), 5 repeticiones.
HC="$1"; HV="$2"; SONDA="${ARNES_UTIL:-/home/juan/dev/ArnesJuan-v1.36/tests/util}/sonda-reloj.sh"
P="$(mktemp -d)"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
cat > "$P/.arnes/config.json" <<'J'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] }, "quality_gates": ["true"], "estados": { "completado": "completado" },
  "requirements_dir": "requirements", "pending_approval": "PENDING_APPROVAL.md" }
J
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf '# REQ-100\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nRigor: estandar\n' > "$P/requirements/REQ-100.md"
f="$P/e.json"; jq -n --arg fp "$P/requirements/REQ-100.md" '{hook_event_name:"PreToolUse",tool_name:"Edit",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$f"
for n in 1 2 3 4 5; do
  reg="$("$SONDA" --k 4 --r 6 --etiqueta "req017-ca08-$n" \
    --sujeto-a "CLAUDE_PROJECT_DIR='$P' bash '$HC/guard-completado.sh' < '$f' >/dev/null 2>&1" \
    --sujeto-b "CLAUDE_PROJECT_DIR='$P' bash '$HV/guard-completado.sh' < '$f' >/dev/null 2>&1" 2>/dev/null)"
  ma="$(sed -n 's/.* min_a=\([^ ]*\).*/\1/p' <<< "$reg")"; mb="$(sed -n 's/.* min_b=\([^ ]*\).*/\1/p' <<< "$reg")"
  printf '#%s candidata min=%sµs v1.36.0 min=%sµs razón=%s‰\n' "$n" "$ma" "$mb" "$(( ma * 1000 / mb ))"
done
rm -rf "$P"
