#!/usr/bin/env bash
# ATAQUE A NIVEL DE CABECERA: ¿se puede NEUTRALIZAR el matiz y recuperar la exencion
# de QA que `ligero` a secas concede? Cada caso construye una cabecera COMPLETA a mano,
# con QA y Seguridad PENDIENTES y sin sensibilidad declarada. Si la puerta responde
# `allow`, el rigor efectivo es `ligero` y la exencion se CONCEDIO.
#   esperado deny  = el matiz gobierna (estandar: exige QA)
#   esperado allow = la declaracion vigente es `ligero` a secas (legitimo)
set -u
HOOKS="${1:-/home/juan/dev/ArnesJuan-1.33.2/hooks}"
RAIZ="$(mktemp -d)"; trap 'rm -rf "$RAIZ"' EXIT
PROJ="$RAIZ/p"; mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
cat > "$PROJ/.arnes/config.json" <<'CFG'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
CFG
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$PROJ"
n=0; P=0; F=0
caso() { # <nombre> <esperado> <cuerpo-de-cabecera>
  n=$((n+1)); local f="$PROJ/requirements/REQ-$n.md" j o d
  { printf '# REQ-%s\nEstado: en-revisión\nQA: pendiente\nSeguridad: pendiente\n' "$n"
    printf '%s' "$3"; } > "$f"
  j="$(jq -n --arg fp "$f" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
       tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}')"
  o="$(printf '%s' "$j" | "$HOOKS/guard-completado.sh" 2>/dev/null)"
  d=allow; printf '%s' "$o" | grep -Eq '"permissionDecision": *"deny"' && d=deny
  if [ "$d" = "$2" ]; then P=$((P+1)); printf '  PASS  %-58s (%s)\n' "$1" "$d"
  else F=$((F+1)); printf '  FAIL  %-58s esperado=%s got=%s\n' "$1" "$2" "$d"; fi
}

caso "control: ligero a secas concede la exencion"      allow 'Rigor: ligero
'
caso "control: ligero con matiz la niega"               deny  'Rigor: ligero (local)
'
caso "clave DECORADA con matiz"                         deny  '**Rigor**: ligero (local)
'
caso "clave con backtick y matiz"                       deny  '`Rigor`: ligero (local)
'
caso "clave sangrada con matiz"                         deny  '   Rigor: ligero (local)
'
caso "clave con espacio antes de los dos puntos"        deny  'Rigor : ligero (local)
'
caso "DUPLICADO: matiz primero, limpio despues (gana el ultimo=limpio)" allow 'Rigor: ligero (local)
Rigor: ligero
'
caso "DUPLICADO: limpio primero, matiz despues (gana el ultimo=matiz)"  deny  'Rigor: ligero
Rigor: ligero (local)
'
caso "el matiz COMENTADO no declara; queda ligero a secas"  allow 'Rigor: ligero <!-- (local) -->
'
caso "ligero limpio COMENTADO + matiz vigente"          deny  '<!-- Rigor: ligero -->
Rigor: ligero (local)
'
caso "matiz vigente + ligero limpio COMENTADO detras"   deny  'Rigor: ligero (local)
<!-- Rigor: ligero -->
'
caso "ligero limpio en el CUERPO no revoca el matiz"    deny  'Rigor: ligero (local)

## Criterios
Rigor: ligero
'
caso "comentario que ABRE y no cierra tras el matiz"    deny  'Rigor: ligero (local)
<!-- nota sin cerrar
'
caso "matiz con CR al final de la linea (transporte)"   deny  "Rigor: ligero (local)"$'\r'"
"
caso "sensibilidad DUDOSA + matiz -> suelo critico"     deny  'Sensible a seguridad: quiza
Rigor: ligero (local)
'
caso "sensibilidad dudosa + ligero limpio -> suelo critico" deny 'Sensible a seguridad: quiza
Rigor: ligero
'
echo "  -------  $P PASS / $F FAIL  ($n casos de puerta)"
