#!/usr/bin/env bash
# (e) El alcance de la regla del comando llano: el `cp` legítimo F3 (`cp S docs/notas.md`, destino existente
# no protegido, coordinadora) acompañado de cada clase de carácter en OTRA parte del comando. Esperado por
# P-032-4 (B): con comillas, `$`, `#`, `<` o un salto (y el resto de la lista de `_arnes_cmd_llano`), la
# decisión de v1.36.0 (deny); con caracteres que el detector sigue, allow. Uso: bash 38-alcance-llano.sh <cand> <v136>
set -u
HC="$1"; HV="$2"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
P="$T/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"; printf 'n\n' > "$P/docs/notas.md"; printf 'S\n' > "$P/S"
dec() { local out; out="$(cd "$T" && jq -cn --arg c "$P" --arg k "$2" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}}' | CLAUDE_PROJECT_DIR="$P" bash "$1/guard.sh" 2>/dev/null)"; case "$out" in *'"deny"'*) echo deny ;; *) echo allow ;; esac; }
c() { printf '%-5s v1.36.0=%-5s candidata=%-5s esperado=%-5s %s | %s\n' "$1" "$(dec "$HV" "$3")" "$(dec "$HC" "$3")" "$2" "$( [ "$(dec "$HC" "$3")" = "$2" ] && echo OK || echo DIFIERE)" "${3//$'\n'/⏎}"; }
echo "fecha: $(date -Iseconds)"
c E0 allow 'cp S docs/notas.md'
c E1 deny  'cp S docs/notas.md && echo "hecho"'
c E2 deny  "cp S docs/notas.md && echo 'hecho'"
c E3 deny  'cp S docs/notas.md && echo $HOME'
c E4 deny  'cp S docs/notas.md # copia'
c E5 deny  'cp S docs/notas.md && wc -l < docs/notas.md'
c E6 deny  $'cp S docs/notas.md\necho hecho'
c E7 deny  'cp S docs/notas.md && ls *.md'
c E8 allow 'cp S docs/notas.md && echo hecho > docs/log.txt'
c E9 allow 'cp S docs/notas.md | cat'
c E10 allow 'cp S docs/notas.md; ls -la'
c E11 allow 'X=1 cp S docs/notas.md'
c E12 allow 'cp -v S docs/notas.md && echo 50% hecho, user@host: a+b'
c E13 allow 'cp S docs/notas.md && echo ñandú'
