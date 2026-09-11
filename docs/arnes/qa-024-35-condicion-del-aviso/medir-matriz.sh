#!/usr/bin/env bash
# medir3.sh <dir-con-hooks> — matriz completa: TEXTO de los 4 avisos + DECISION/rc de los
# 4 cierres, para los 2 estados de `campos.ausencia_exige` x los 3 niveles de rigor.
# Salida estable, una linea por celda, para diffear ANTES contra DESPUES.
set -u
H="$1"; BASE="$(mktemp -d)"; trap 'rm -rf "$BASE"' EXIT
mkproj() { local P="$BASE/p-$1"; rm -rf "$P"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  cat > "$P/.arnes/config.json" <<JSON
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md", "campos": { "ausencia_exige": $1 } }
JSON
  echo "$P"; }
req() { # <ruta> <rigor> <lineas extra...>
  local f="$1" rig="$2"; shift 2
  { printf '# R\nEstado: en-revisión\nSensible a seguridad: no\nRigor: %s\nHallazgos abiertos: (ninguno)\n' "$rig"
    for l in "$@"; do printf '%s\n' "$l"; done; } > "$f"; }
edit_nuevo() { jq -n --arg fp "$1" --arg ns "$2" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"x",new_string:$ns}}'; }
edit_cierre() { jq -n --arg fp "$1" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}'; }
salida() { printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" bash "$H/guard-completado.sh" 2>/dev/null; }
aviso() { local out; out="$(salida "$1" "$2")"
  printf '%s' "$out" | jq -r 'select(.systemMessage!=null)|.systemMessage' 2>/dev/null | tr '\n' ' '; }
decis() { local out rc dec=allow
  out="$(salida "$1" "$2")"; rc=$?
  printf '%s' "$out" | grep -Eq '"permissionDecision":"deny"' && dec=deny
  printf '%s rc=%s' "$dec" "$rc"; }

for llave in false true; do
  P="$(mkproj "$llave")"
  for rigor in ligero estandar critico; do
    k="llave=$llave rigor=$rigor"
    f="$P/requirements/A-$rigor.md"; req "$f" "$rigor" 'QA: pendiente' 'Seguridad: pendiente'
    echo "TEXTO  aviso-QA-vocab    $k :: $(aviso "$P" "$(edit_nuevo "$f" 'QA: aprobadisimo')")"
    echo "TEXTO  aviso-QA-desfase  $k :: $(aviso "$P" "$(edit_nuevo "$f" 'qa: aprobado')")"
    echo "TEXTO  aviso-SEG-vocab   $k :: $(aviso "$P" "$(edit_nuevo "$f" 'Seguridad: aprobado-ish')")"
    echo "TEXTO  aviso-SEG-desfase $k :: $(aviso "$P" "$(edit_nuevo "$f" 'seguridad: aprobado')")"
    b="$P/requirements/B-$rigor.md"; req "$b" "$rigor" 'QA: aprobadisimo' 'Seguridad: aprobado'
    echo "DECIS  cierre-QA-vocab   $k :: $(decis "$P" "$(edit_cierre "$b")")"
    c="$P/requirements/C-$rigor.md"; req "$c" "$rigor" 'Seguridad: aprobado'
    echo "DECIS  cierre-QA-ausente $k :: $(decis "$P" "$(edit_cierre "$c")")"
    d="$P/requirements/D-$rigor.md"; req "$d" "$rigor" 'QA: aprobado' 'Seguridad: aprobado-ish'
    echo "DECIS  cierre-SEG-vocab  $k :: $(decis "$P" "$(edit_cierre "$d")")"
    e="$P/requirements/E-$rigor.md"; req "$e" "$rigor" 'QA: aprobado'
    echo "DECIS  cierre-SEG-ausent $k :: $(decis "$P" "$(edit_cierre "$e")")"
    g="$P/requirements/G-$rigor.md"; req "$g" "$rigor" 'QA: aprobado' 'Seguridad: aprobado'
    echo "DECIS  cierre-control-ok $k :: $(decis "$P" "$(edit_cierre "$g")")"
    # desfase real en disco (la linea en minuscula escrita, el campo ausente para el lector)
    i="$P/requirements/I-$rigor.md"; req "$i" "$rigor" 'qa: aprobado' 'Seguridad: aprobado'
    echo "DECIS  cierre-QA-minusc  $k :: $(decis "$P" "$(edit_cierre "$i")")"
  done
done
