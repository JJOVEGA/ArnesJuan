#!/usr/bin/env bash
# qa-fidelidad.sh <dir-hooks> — instrumento INDEPENDIENTE del qa-tester (QA-024-35, vuelta 6).
# Para cada celda: (A) el TEXTO del aviso, (B) la DECISION REAL del cierre sobre un REQ en
# ESE MISMO estado, y (C) el VEREDICTO DE FIDELIDAD: lo que el aviso promete vs lo que pasa.
set -u
H="$1"; BASE="$(mktemp -d)"; trap 'rm -rf "$BASE"' EXIT
mkproj() { # $1=valor de campos.ausencia_exige (o la palabra SINCAMPOS)
  local P="$BASE/p-$1"; rm -rf "$P"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  local campos="\"campos\": { \"ausencia_exige\": $1 }"
  [ "$1" = SINCAMPOS ] && campos='"_sin_campos": true'
  cat > "$P/.arnes/config.json" <<JSON
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md", $campos }
JSON
  echo "$P"; }
req() { local f="$1" sens="$2" rig="$3"; shift 3
  { printf '# R\nEstado: en-revisión\nSensible a seguridad: %s\nRigor: %s\nHallazgos abiertos: (ninguno)\n' "$sens" "$rig"
    for l in "$@"; do printf '%s\n' "$l"; done; } > "$f"; }
j_edit() { jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:$os,new_string:$ns}}'; }
run() { printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" bash "$H/guard-completado.sh" 2>/dev/null; }
aviso() { run "$1" "$2" | jq -r 'select(.systemMessage!=null)|.systemMessage' 2>/dev/null | tr '\n' ' '; }
decis() { local out rc dec=allow; out="$(run "$1" "$2")"; rc=$?
  printf '%s' "$out" | grep -Eq '"permissionDecision":"deny"' && dec=deny
  printf '%s rc=%s' "$dec" "$rc"; }

for llave in false true SINCAMPOS; do
 P="$(mkproj "$llave")"
 for sens_rig in "no|ligero" "no|estandar" "no|critico" "si|ligero"; do
  sens="${sens_rig%|*}"; rig="${sens_rig#*|}"; k="llave=$llave sens=$sens rigor=$rig"

  # ---------- VIA 1: QA: AUSENTE para el lector (linea 'qa:' en minuscula) ----------
  f="$BASE/x1"; req "$f" "$sens" "$rig" 'QA: pendiente' 'Seguridad: aprobado'
  cp "$f" "$P/requirements/A1.md"
  msg="$(aviso "$P" "$(j_edit "$P/requirements/A1.md" 'QA: pendiente' 'qa: aprobado')")"
  # promesa extraida del propio texto
  prom=indeterminado
  case "$msg" in *"REQ SI podra cerrarse sin veredicto de QA"*) prom=CIERRA ;; esac
  case "$msg" in *"ENCENDIDA, asi que el REQ no podra cerrarse"*) prom=NO_CIERRA ;; esac
  case "$msg" in *"sin declarar, asi que ninguna guarda juzga esta edicion y el REQ no podra cerrarse"*) prom=NO_CIERRA_SIN_COND ;; esac
  # el hecho: un REQ EN ESE ESTADO, ¿cierra?
  req "$P/requirements/A2.md" "$sens" "$rig" 'qa: aprobado' 'Seguridad: aprobado'
  hecho="$(decis "$P" "$(j_edit "$P/requirements/A2.md" 'Estado: en-revisión' 'Estado: completado')")"
  real=CIERRA; case "$hecho" in deny*) real=NO_CIERRA ;; esac
  ver=FIEL; [ "$prom" = "$real" ] || ver=INFIEL
  echo "QA-AUSENTE   $k :: promesa=$prom hecho=$hecho -> $ver"
  echo "TXT QA-AUS   $k :: $msg"

  # ---------- VIA 2: QA: FUERA DE VOCABULARIO ----------
  req "$P/requirements/B1.md" "$sens" "$rig" 'QA: pendiente' 'Seguridad: aprobado'
  msg2="$(aviso "$P" "$(j_edit "$P/requirements/B1.md" 'QA: pendiente' 'QA: aprobadisimo')")"
  prom2=indeterminado
  case "$msg2" in *"Si el rigor efectivo NO es 'ligero'"*) prom2=COND_LIGERO ;; esac
  case "$msg2" in *"veredicto ("*"). Asi este REQ no podra cerrarse."*) prom2=NO_CIERRA_SIN_COND ;; esac
  req "$P/requirements/B2.md" "$sens" "$rig" 'QA: aprobadisimo' 'Seguridad: aprobado'
  hecho2="$(decis "$P" "$(j_edit "$P/requirements/B2.md" 'Estado: en-revisión' 'Estado: completado')")"
  real2=CIERRA; case "$hecho2" in deny*) real2=NO_CIERRA ;; esac
  # fidelidad: COND_LIGERO es fiel si (rigor efectivo ligero => CIERRA) y (si no => NO_CIERRA)
  efec="$rig"; [ "$sens" = si ] && efec=critico
  esp=NO_CIERRA; [ "$efec" = ligero ] && esp=CIERRA
  ver2=INFIEL
  if [ "$prom2" = COND_LIGERO ] && [ "$real2" = "$esp" ]; then ver2=FIEL
  elif [ "$prom2" = NO_CIERRA_SIN_COND ] && [ "$real2" = NO_CIERRA ]; then ver2=FIEL; fi
  echo "QA-VOCAB     $k :: promesa=$prom2 hecho=$hecho2 esperado=$esp -> $ver2"
  echo "TXT QA-VOC   $k :: $msg2"

  # ---------- VIA 3 y 4: Seguridad, ausente y fuera de vocabulario ----------
  req "$P/requirements/C1.md" "$sens" "$rig" 'QA: aprobado' 'Seguridad: pendiente'
  msg3="$(aviso "$P" "$(j_edit "$P/requirements/C1.md" 'Seguridad: pendiente' 'seguridad: aprobado')")"
  req "$P/requirements/C2.md" "$sens" "$rig" 'QA: aprobado' 'seguridad: aprobado'
  hecho3="$(decis "$P" "$(j_edit "$P/requirements/C2.md" 'Estado: en-revisión' 'Estado: completado')")"
  real3=CIERRA; case "$hecho3" in deny*) real3=NO_CIERRA ;; esac
  esp3=CIERRA; [ "$efec" = critico ] && esp3=NO_CIERRA
  ver3=FIEL; [ "$real3" = "$esp3" ] || ver3=REVISAR
  echo "SEG-AUSENTE  $k :: hecho=$hecho3 esperado-por-el-texto(critico)=$esp3 -> $ver3"
  echo "TXT SEG-AUS  $k :: $msg3"
  req "$P/requirements/D1.md" "$sens" "$rig" 'QA: aprobado' 'Seguridad: pendiente'
  msg4="$(aviso "$P" "$(j_edit "$P/requirements/D1.md" 'Seguridad: pendiente' 'Seguridad: aprobadisimo')")"
  req "$P/requirements/D2.md" "$sens" "$rig" 'QA: aprobado' 'Seguridad: aprobadisimo'
  hecho4="$(decis "$P" "$(j_edit "$P/requirements/D2.md" 'Estado: en-revisión' 'Estado: completado')")"
  real4=CIERRA; case "$hecho4" in deny*) real4=NO_CIERRA ;; esac
  ver4=FIEL; [ "$real4" = "$esp3" ] || ver4=REVISAR
  echo "SEG-VOCAB    $k :: hecho=$hecho4 esperado-por-el-texto(critico)=$esp3 -> $ver4"
  echo "TXT SEG-VOC  $k :: $msg4"

  # ---------- CONTROLES ----------
  req "$P/requirements/E1.md" "$sens" "$rig" 'QA: aprobado' 'Seguridad: aprobado'
  echo "CTRL-POSITIVO $k :: $(decis "$P" "$(j_edit "$P/requirements/E1.md" 'Estado: en-revisión' 'Estado: completado')")"
  req "$P/requirements/E2.md" "$sens" "$rig" 'QA: aprobado' 'Seguridad: aprobado'
  m5="$(aviso "$P" "$(j_edit "$P/requirements/E2.md" 'QA: aprobado' 'QA: aprobado (R-045)')")"
  echo "CTRL-SILENCIO $k :: aviso='${m5}'"
  # el aviso de desfase dice «ninguna guarda juzga esta edicion»: ¿es cierto?
  req "$P/requirements/F1.md" "$sens" "$rig" 'qa: aprobado' 'Seguridad: pendiente'
  echo "CTRL-ORDEN    $k :: firmar Seguridad con QA en desfase -> $(decis "$P" "$(j_edit "$P/requirements/F1.md" 'Seguridad: pendiente' 'Seguridad: aprobado')")"
 done
done
