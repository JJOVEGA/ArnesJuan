#!/usr/bin/env bash
# dobles-v.sh <hooks> <n> <clase> <outdir> — como qa/bin/dobles.sh (mismo recuento: documentos JSON por respuesta con
# `jq -s length`, timeout 30 s por cierre), sobre el cierre legítimo CON GIT y con el veredicto de la clase:
#   verde (la herramienta, gate true), roja (la herramienta, gate false), caducado (verde y un cambio después),
#   ausente (gate true, sin correr la herramienta). Cuenta: respuestas con != 1 documento (0 si allow), > 5 s y espurios.
set -u
H="$1"; N="$2"; K="$3"; O="$4"; X="$(cd "$(dirname "$0")" && pwd)"; R=/home/juan/dev/ArnesJuan-1.36.3
mkdir -p "$O"; P="$O/p-$K"
g='["true"]'; [ "$K" = roja ] && g='["false"]'
bash "$X/fixture.sh" "$P" "$g"
case "$K" in verde|roja|caducado) ( cd "$P" && bash "$R/tools/arnes-gates.sh" --quien banco --proyecto "$P" >/dev/null 2>&1 ) ;; esac
[ "$K" = caducado ] && echo cambio >> "$P/src/a.txt"
esperado=1; [ "$K" = verde ] && esperado=0
declare -A C; malos=0; lentos=0; t_ini=$SECONDS
for ((i = 0; i < N; i++)); do
  t0=${EPOCHREALTIME/./}
  out=$(cd "$P" && CLAUDE_PROJECT_DIR="$P" timeout 30 bash "$H/guard.sh" < "$P/in" 2>/dev/null); rc=$?
  ms=$(( (${EPOCHREALTIME/./} - t0) / 1000 ))
  if [ -z "$out" ]; then n=0; else n=$(printf '%s' "$out" | jq -s 'length' 2>/dev/null || echo X); fi
  k="$n docs"; [ "$n" = 1 ] && k="1 docs: $(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason[0:70]' 2>/dev/null)"
  [ "$rc" = 124 ] && k="TIMEOUT30 $k"
  [ "$ms" -gt 5000 ] && lentos=$((lentos + 1))
  [ "$n" = "$esperado" ] && [ "$rc" != 124 ] || { malos=$((malos + 1)); printf '%s\n' "$out" > "$O/out-$K.$i"; echo "  it=$i rc=$rc ms=$ms $k"; }
  C["$k"]=$(( ${C["$k"]:-0} + 1 ))
done
echo "== $K hooks=$H n=$N s=$((SECONDS - t_ini)) respuestas_distintas_de_$esperado=$malos mas_de_5s=$lentos"
for k in "${!C[@]}"; do printf '  %5d  %s\n' "${C[$k]}" "$k"; done
