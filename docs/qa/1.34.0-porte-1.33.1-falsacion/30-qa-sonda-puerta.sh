#!/usr/bin/env bash
# Sonda QA de la PUERTA (guard-completado.sh), independiente del banco.
# Uso: puerta.sh <HOOKS_DIR>
set -u
HOOKS_DIR="$1"
RAIZ="$(mktemp -d)"; trap 'rm -rf "$RAIZ"' EXIT
PROJ="$RAIZ/proj"; mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
cat > "$PROJ/.arnes/config.json" <<'J'
{ "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
J
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$PROJ"

mk() { # <id> <sens> <qa> <seg> <rigor-literal-o-AUSENTE>
  { printf '# %s\nEstado: en-revisión\n' "$1"
    [ "$2" = OMIT ] || printf 'Sensible a seguridad: %s\n' "$2"
    [ "$3" = OMIT ] || printf 'QA: %s\n' "$3"
    [ "$4" = OMIT ] || printf 'Seguridad: %s\n' "$4"
    [ "$5" = OMIT ] || printf 'Rigor: %s\n' "$5"
  } > "$PROJ/requirements/$1.md"
}
emite() { jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:$os,new_string:$ns}}'; }
veredicto() { # <id>
  local out; out="$(emite "$PROJ/requirements/$1.md" 'Estado: en-revisión' 'Estado: completado' | "$HOOKS_DIR/guard-completado.sh" 2>/dev/null)"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then echo deny; else echo allow; fi
}
n=0
caso() { # <sens> <qa> <seg> <rigor> <etiqueta>
  n=$((n+1)); local id="REQ-Q$n"
  mk "$id" "$1" "$2" "$3" "$4"
  printf '  %-8s | QA=%-9s Seg=%-9s | Rigor=%-22s -> %s\n' "sens=$1" "$2" "$3" "[$4]" "$(veredicto "$id")"
}
echo "== PUERTA guard-completado.sh · HOOKS_DIR=$HOOKS_DIR =="
echo "-- A. el eje: ligero con matiz vs ligero limpio, REQ NO sensible, QA pendiente --"
caso no pendiente pendiente 'ligero'
caso no pendiente pendiente 'ligero (local)'
caso no pendiente pendiente 'ligero (lo que sea)'
caso no pendiente pendiente 'ligero ()'
caso no pendiente pendiente 'ligero (a) (b)'
caso no pendiente pendiente 'ligero (a (b))'
echo "-- B. con QA aprobado (la exencion deja de importar; manda Seguridad) --"
caso no aprobado pendiente 'ligero'
caso no aprobado pendiente 'ligero (local)'
caso no aprobado pendiente 'estandar (x)'
caso no aprobado pendiente 'critico (por suelo)'
caso no aprobado aprobado 'critico (por suelo)'
echo "-- C. suelo de seguridad: sensible=si --"
caso si pendiente pendiente 'ligero (local)'
caso si aprobado pendiente 'ligero (local)'
caso si aprobado aprobado 'ligero (local)'
echo "-- D. variantes de entrada sobre el conjunto conocido --"
caso no pendiente pendiente 'LIGERO (local)'
caso no pendiente pendiente 'Ligero (local)'
caso no pendiente pendiente 'ligero(local)'
caso no pendiente pendiente '  ligero (local)  '
caso no pendiente pendiente 'ligero  (local)'
caso no pendiente pendiente 'ligero (local'
caso no pendiente pendiente 'ligero (local) y mas'
caso no pendiente pendiente '(local)'
caso no pendiente pendiente '()'
caso no pendiente pendiente ''
caso no pendiente pendiente 'inventado'
caso no pendiente pendiente 'inventado (x)'
echo "-- E. AUSENCIA del campo Rigor (el camino que NO debe atravesar la guarda) --"
caso no pendiente pendiente OMIT
caso no aprobado pendiente OMIT
caso si  aprobado pendiente OMIT
caso si  aprobado aprobado OMIT
echo "-- F. repeticion/idempotencia: mismo REQ dos veces y alternancia matiz/limpio --"
mk REQ-R1 no pendiente pendiente 'ligero (local)'; mk REQ-R2 no pendiente pendiente 'ligero'
printf '  alterna: matiz=%s limpio=%s matiz=%s limpio=%s\n' "$(veredicto REQ-R1)" "$(veredicto REQ-R2)" "$(veredicto REQ-R1)" "$(veredicto REQ-R2)"
