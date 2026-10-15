#!/usr/bin/env bash
# Ejecuta el procedimiento de 40-procedimiento-reloj.md (fijado antes). Uso:
#   bash 41-reloj-ca08.sh <repo del arnés> <hooks v1.36.0>
set -u
REPO="$1"; HB="$2"; HC="$REPO/hooks"; SR="$REPO/tests/util/sonda-reloj.sh"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
mkdir -p "$T/h132" && git -C "$REPO" archive v1.32.1 hooks | tar -x -C "$T/h132" || { echo "ABORT: v1.32.1 no se materializó"; exit 1; }
HH="$T/h132/hooks"
P="$T/proj"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs"
printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
# El REQ de 6 líneas de `mkreq_r REQ-100 no aprobado n/a estandar` (run.sh)
grep -n "^mkreq_r()" -A12 "$REPO/tests/escenarios/hooks/run.sh" > "$T/mkreq.txt"
eval "$(sed -n '/^mkreq_r()/,/^}/p' "$REPO/tests/escenarios/hooks/run.sh")"
PROJ="$P" mkreq_r REQ-100 no aprobado n/a estandar
echo "--- el REQ sujeto ($(wc -l < "$P/requirements/REQ-100.md") líneas):"; cat "$P/requirements/REQ-100.md"
J="$T/j.json"
jq -n --arg fp "$P/requirements/REQ-100.md" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.NADA,tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' > "$J"
echo "--- decisión del sujeto en cada árbol (debe ser la misma):"
for h in "$HC" "$HB" "$HH"; do printf '  %s: %s\n' "$h" "$(CLAUDE_PROJECT_DIR="$P" bash "$h/guard-completado.sh" < "$J" 2>/dev/null | head -c 160)"; done
echo "--- camino de código: llamadas a la función nueva en una traza bash -x de la candidata"
CLAUDE_PROJECT_DIR="$P" bash -x "$HC/guard-completado.sh" < "$J" > /dev/null 2> "$T/x.txt"
printf '  arnes_destino_a_juzgar: %s llamadas; ARNES_FORMA_DIR leída en %s líneas de traza; total de líneas de traza: %s\n' \
  "$(grep -c '^+* arnes_destino_a_juzgar' "$T/x.txt")" "$(grep -c 'ARNES_FORMA_DIR' "$T/x.txt")" "$(wc -l < "$T/x.txt")"
CLAUDE_PROJECT_DIR="$P" bash -x "$HB/guard-completado.sh" < "$J" > /dev/null 2> "$T/xb.txt"
printf '  traza de v1.36.0: %s líneas (misma cifra = mismo camino ejecutado, salvo la asignación de la constante)\n' "$(wc -l < "$T/xb.txt")"
diff <(sed -E 's/[0-9]{3,}//g; s#'"$HC"'#H#g' "$T/x.txt") <(sed -E 's/[0-9]{3,}//g; s#'"$HB"'#H#g' "$T/xb.txt") | head -20 | sed 's/^/  diff: /'
sub() { printf "CLAUDE_PROJECT_DIR='%s' bash '%s/guard-completado.sh' < '%s' >/dev/null 2>&1" "$P" "$1" "$J"; }
par() {   # <nombre> <hooks a> <hooks b>
  local r; r="$("$SR" --k 4 --r 6 --etiqueta "$1" --sujeto-a "$(sub "$2")" --sujeto-b "$(sub "$3")" 2>/dev/null)"
  local e ma mb; e="$(grep -oE '(^| )estado=[^ ]*' <<< "$r" | tr -d ' ')"; ma="$(grep -o ' min_a=[0-9]*' <<< "$r" | cut -d= -f2)"; mb="$(grep -o ' min_b=[0-9]*' <<< "$r" | cut -d= -f2)"
  if [ "$e" = estado=ok ] && [ -n "$ma" ] && [ -n "$mb" ]; then
    printf '  %s min_a=%sµs min_b=%sµs razón=%s‰\n' "$1" "$ma" "$mb" "$(( ma * 1000 / mb ))"
  else printf '  %s NO RESUELTA (%s) <%s>\n' "$1" "$e" "${r:0:200}"; fi
}
for ((i = 1; i <= 10; i++)); do
  echo "ronda $i · $(uptime | sed 's/.*load/load/')"
  case $(( i % 3 )) in
    1) par P1 "$HC" "$HB"; par P2 "$HC" "$HH"; par P3 "$HB" "$HH" ;;
    2) par P2 "$HC" "$HH"; par P3 "$HB" "$HH"; par P1 "$HC" "$HB" ;;
    0) par P3 "$HB" "$HH"; par P1 "$HC" "$HB"; par P2 "$HC" "$HH" ;;
  esac
done
echo "fin · $(date -Iseconds) · $(uptime | sed 's/.*load/load/')"
