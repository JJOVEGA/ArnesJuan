#!/usr/bin/env bash
# IDENTIFICA EL RIGOR EFECTIVO POR CONDUCTA DE PUERTA, no por lo que devuelve el lector.
# Para cada forma de `Rigor:` y cada sensibilidad, se intenta cerrar el REQ con las TRES
# combinaciones de firmas que discriminan el nivel:
#     (QA pendiente, SEG pendiente) · (QA aprobado, SEG pendiente) · (ambas aprobadas)
# La TERNA de decisiones identifica el nivel sin ambiguedad:
#     allow allow allow -> ligero      (exencion de QA EJERCIDA)
#     deny  allow allow -> estandar    (exige QA, no exige seguridad)
#     deny  deny  allow -> critico     (exige ambas)
# Uso: puerta.sh <ruta/hooks>
set -u
HOOKS="$1"
RAIZ="$(mktemp -d)"; trap 'rm -rf "$RAIZ"' EXIT
PROJ="$RAIZ/proj"; mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
cat > "$PROJ/.arnes/config.json" <<'CFG'
{ "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
CFG
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$PROJ"

n=0
intenta() {  # <rigor> <sens> <qa> <seg> -> allow|deny
  n=$((n+1)); local f="$PROJ/requirements/REQ-$n.md"
  { printf '# REQ-%s\nEstado: en-revisión\n' "$n"
    printf 'Sensible a seguridad: %s\n' "$2"
    printf 'QA: %s\n' "$3"
    printf 'Seguridad: %s\n' "$4"
    [ -n "$1" ] && printf 'Rigor: %s\n' "$1"
  } > "$f"
  local json out
  json="$(jq -n --arg fp "$f" '{hook_event_name:"PreToolUse",tool_name:"Edit",
    cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}')"
  out="$(printf '%s' "$json" | "$HOOKS/guard-completado.sh" 2>/dev/null)"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then echo deny; else echo allow; fi
}

nivel() {  # <rigor> <sens> -> terna + nivel identificado
  local a b c t
  a="$(intenta "$1" "$2" pendiente pendiente)"
  b="$(intenta "$1" "$2" aprobado  pendiente)"
  c="$(intenta "$1" "$2" aprobado  aprobado)"
  t="$a $b $c"
  case "$t" in
    "allow allow allow") echo "ligero|$t" ;;
    "deny allow allow")  echo "estandar|$t" ;;
    "deny deny allow")   echo "critico|$t" ;;
    *)                   echo "ANOMALO|$t" ;;
  esac
}

printf '%-44s %-5s %-10s %s\n' FORMA_DE_RIGOR SENS NIVEL_PUERTA TERNA
FORMAS=(
  ""                       # campo ausente
  "ligero"
  "estandar"
  "critico"
  "inventado"
  "ligero (local)"
  "ligero(sin espacio)"
  "ligero ()"
  "ligero ((a) b)"
  "ligero (a) (b)"
  "**ligero (local)**"
  "**ligero** (local)"
  "ligero (critico)"
  "ligero (local"
  "estandar (x)"
  "critico (por suelo)"
  "critico (ligero)"
  "inventado (x)"
  "LIGERO"
  "  ligero  "
)
for f in "${FORMAS[@]}"; do
  for s in no sí; do
    r="$(nivel "$f" "$s")"
    printf '%-44s %-5s %-10s %s\n' "${f:-<AUSENTE>}" "$s" "${r%%|*}" "${r#*|}"
  done
done
echo "casos de puerta ejecutados: $n"
