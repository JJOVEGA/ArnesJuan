#!/usr/bin/env bash
# 40-reloj-ca12c.sh <hooks candidata> <hooks v1.36.0> — REQ-032 CA-12 (c): el reloj de guard.sh en la candidata
# frente a v1.36.0, en la MISMA corrida, con sonda-reloj.sh (dos sujetos intercalados, mínimo de k por serie, r series).
# (i) el camino común: `ls -la` y `npm run build`; (ii) `cp S <raíz>/docs/notas.md` (F3) de la coordinadora.
# Techo operativo 1,25×; suelo 50 ms por serie (si no lo supera o falta la línea base: SKIP, nunca PASS).
HC="$1"; HV="$2"; U="$(cd "$(dirname "$0")" && pwd)"; SONDA="${ARNES_UTIL:-/home/juan/dev/ArnesJuan-v1.36/tests/util}/sonda-reloj.sh"
P="$(mktemp -d)"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
cat > "$P/.arnes/config.json" <<'J'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] }, "quality_gates": ["true"], "estados": { "completado": "completado" },
  "requirements_dir": "requirements", "pending_approval": "PENDING_APPROVAL.md" }
J
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; echo n > "$P/docs/notas.md"
[ -d "$HV" ] || { echo "SKIP: sin línea base v1.36.0 en $HV"; exit 0; }
for k in 'ls -la' 'npm run build' "cp S $P/docs/notas.md"; do
  f="$P/entrada.json"; jq -cn --arg c "$k" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$cwd,tool_input:{command:$c}}' > "$f"
  reg="$("$SONDA" --k 10 --r 6 --etiqueta "req032-ca12c" \
    --sujeto-a "CLAUDE_PROJECT_DIR='$P' bash '$HC/guard.sh' < '$f' >/dev/null 2>&1" \
    --sujeto-b "CLAUDE_PROJECT_DIR='$P' bash '$HV/guard.sh' < '$f' >/dev/null 2>&1" 2>/dev/null)"
  est="$(sed -n 's/.* estado=\([^ ]*\).*/\1/p' <<< "$reg")"; ma="$(sed -n 's/.* min_a=\([^ ]*\).*/\1/p' <<< "$reg")"; mb="$(sed -n 's/.* min_b=\([^ ]*\).*/\1/p' <<< "$reg")"
  if [ "$est" != ok ] || [ -z "$ma" ] || [ -z "$mb" ]; then v=SKIP
  else r=$(( ma * 1000 / mb )); if [ "$r" -le 1250 ]; then v=PASS; else v=FAIL; fi; fi
  printf '%s  «%s»  candidata min=%sµs  v1.36.0 min=%sµs  razón=%s‰ (techo 1250‰)\n  registro: %s\n' "$v" "$k" "$ma" "$mb" "${r:-?}" "$reg"
done
rm -rf "$P"
