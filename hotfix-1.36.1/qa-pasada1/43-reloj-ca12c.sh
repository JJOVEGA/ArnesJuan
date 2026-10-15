#!/usr/bin/env bash
# REQ-032 CA-12 (c): el MÍNIMO de la candidata no más de 1,25× el de v1.36.0 en la misma corrida, en
# (i) el camino común (`ls -la`, `npm run build`) y (ii) `cp S <raíz>/docs/notas.md` (F3), por guard.sh,
# coordinadora. Instrumento del banco (`sonda-reloj.sh`, intercalado, mínimo), k=4 r=6, 5 repeticiones por
# sujeto, ninguna descartada; la que no supera el suelo o no resuelve se publica como tal.
# Uso: bash 43-reloj-ca12c.sh <repo del arnés> <hooks v1.36.0>
set -u
REPO="$1"; HB="$2"; HC="$REPO/hooks"; SR="$REPO/tests/util/sonda-reloj.sh"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
P="$T/proj"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; printf 'n\n' > "$P/docs/notas.md"
i=0
for k in 'ls -la' 'npm run build' "cp S $P/docs/notas.md"; do
  i=$((i + 1)); J="$T/j$i.json"
  jq -cn --arg c "$P" --arg k "$k" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}}' > "$J"
  printf '%s · decisión candidata=%s v1.36.0=%s\n' "${k/"$P"/<raíz>}" \
    "$(CLAUDE_PROJECT_DIR="$P" bash "$HC/guard.sh" < "$J" 2>/dev/null | grep -o '"permissionDecision":"[a-z]*"' || echo allow)" \
    "$(CLAUDE_PROJECT_DIR="$P" bash "$HB/guard.sh" < "$J" 2>/dev/null | grep -o '"permissionDecision":"[a-z]*"' || echo allow)"
  for ((n = 1; n <= 5; n++)); do
    r="$("$SR" --k 4 --r 6 --etiqueta "ca12c-$i-$n" \
      --sujeto-a "CLAUDE_PROJECT_DIR='$P' bash '$HC/guard.sh' < '$J' >/dev/null 2>&1" \
      --sujeto-b "CLAUDE_PROJECT_DIR='$P' bash '$HB/guard.sh' < '$J' >/dev/null 2>&1" 2>/dev/null)"
    e="$(grep -oE '(^| )estado=[^ ]*' <<< "$r" | tr -d ' ')"; ma="$(grep -o ' min_a=[0-9]*' <<< "$r" | cut -d= -f2)"; mb="$(grep -o ' min_b=[0-9]*' <<< "$r" | cut -d= -f2)"
    if [ "$e" = estado=ok ] && [ -n "$ma" ] && [ -n "$mb" ]; then printf '  #%s candidata=%sµs v1.36.0=%sµs razón=%s‰ · %s\n' "$n" "$ma" "$mb" "$(( ma * 1000 / mb ))" "$(uptime | sed 's/.*load/load/')"
    else printf '  #%s NO RESUELTA (%s) %s\n' "$n" "$e" "$(grep -oE 'motivo=[^ ]*' <<< "$r" | head -1)"; fi
  done
done
