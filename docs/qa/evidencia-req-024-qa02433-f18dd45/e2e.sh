#!/usr/bin/env bash
# Ejercicio END-TO-END del hook real: acto de FIRMAR (aviso) y acto de CIERRE (deny/motivo).
set -u
REPO=/home/juan/dev/ArnesJuan-1.34-reparaciones
PROJ=/tmp/claude-1000/-home-juan-dev-ArnesJuan/23a8ee5a-8587-4923-8f15-1fc9bf03aaf2/scratchpad/proj
rm -rf "$PROJ"; mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/src"
cat > "$PROJ/.arnes/config.json" <<'J'
{ "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
J
printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
export CLAUDE_PROJECT_DIR="$PROJ"

firmar() {  # <rotulo> <linea que se escribe>
  local rot="$1" ns="$2" out msg deny
  printf '# REQ-950\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: pendiente\n' > "$PROJ/requirements/REQ-950.md"
  out="$(jq -n --arg fp "$PROJ/requirements/REQ-950.md" --arg ns "$ns" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,old_string:"x",new_string:$ns}}' | "$REPO/hooks/guard-completado.sh" 2>/dev/null)"
  msg="$(printf '%s' "$out" | jq -r '.systemMessage // ""' 2>/dev/null)"
  deny=no; printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"' && deny=SI
  printf 'FIRMAR  %-40s aviso=%-3s deny=%-3s :: %s\n' "$rot" "$([ -n "$msg" ] && echo SI || echo no)" "$deny" "$(printf '%s' "$msg" | head -c 110)"
}

cerrar() { # <rotulo> <linea de seguridad tal cual> <rigor>
  local rot="$1" linea="$2" rigor="$3" out deny motivo
  { printf '# REQ-951\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\n'
    printf '%s\n' "$linea"
    printf 'Hallazgos abiertos: (ninguno)\nRigor: %s\n\n## Historia\n' "$rigor"; } > "$PROJ/requirements/REQ-951.md"
  out="$(jq -n --arg fp "$PROJ/requirements/REQ-951.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' \
    | "$REPO/hooks/guard-completado.sh" 2>/dev/null)"
  deny=allow; printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"' && deny=DENY
  motivo="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // .systemMessage // ""' 2>/dev/null)"
  printf 'CIERRE  %-40s rigor=%-8s %-5s :: %s\n' "$rot" "$rigor" "$deny" "$(printf '%s' "$motivo" | head -c 150)"
}

echo "########## ACTO DE FIRMAR — el aviso ##########"
firmar "control Seguridad: (limpia, vocab ok)"  'Seguridad: aprobado'
firmar "seguridad: minuscula (desfase)"          'seguridad: aprobado'
firmar "Segurídad: NFC (desfase)"                $'Segur\xc3\xaddad: aprobado'
firmar "Segurídad: NFD (desfase)"                $'Seguri\xcc\x81dad: aprobado'
firmar "Séguridad: NFC (desfase)"                $'S\xc3\xa9guridad: aprobado'
firmar "QÁ: NFC (desfase)"                       $'Q\xc3\x81: aprobado'
firmar "QÁ: NFD (desfase)"                       $'QA\xcc\x81: aprobado'
firmar "_Segurídad_: acento+marcado"             $'_Segur\xc3\xaddad_: aprobado'
firmar "Ѕeguridad: homoglifo U+0405 (clase no)"  $'\xd0\x85eguridad: aprobado'
firmar "Segurida: truncada (clase no)"           'Segurida: aprobado'
firmar "Seguridad+ZWSP (clase no)"               $'Seguri\xe2\x80\x8bdad: aprobado'
firmar "BOM+Seguridad (clase no)"                $'\xef\xbb\xbfSeguridad: aprobado'
firmar "Segur idad (blanco de mas)"              'Segur idad: aprobado'
firmar "QĀ: macron NFC (clase no)"               $'Q\xc4\x80: aprobado'

echo
echo "########## ACTO DE CIERRE — que resuelve sobre la clase 'no' ##########"
cerrar "control: Seguridad: aprobado"            'Seguridad: aprobado'                  critico
cerrar "Ѕeguridad homoglifo"                     $'\xd0\x85eguridad: aprobado'          critico
cerrar "Segurida: truncada"                      'Segurida: aprobado'                   critico
cerrar "Seguridad+ZWSP"                          $'Seguri\xe2\x80\x8bdad: aprobado'     critico
cerrar "BOM+Seguridad"                           $'\xef\xbb\xbfSeguridad: aprobado'     critico
cerrar "Segur idad (blanco de mas)"              'Segur idad: aprobado'                 critico
cerrar "QĀ macron (clase no)"                    $'Q\xc4\x80: aprobado'                 critico
echo "--- los mismos con Rigor: ligero (donde 'por ausencia' y 'no medible' se separan) ---"
cerrar "ligero: Ѕeguridad homoglifo"             $'\xd0\x85eguridad: aprobado'          ligero
cerrar "ligero: Segurida truncada"               'Segurida: aprobado'                   ligero
cerrar "ligero: Seguridad+ZWSP"                  $'Seguri\xe2\x80\x8bdad: aprobado'     ligero
cerrar "ligero: BOM+Seguridad"                   $'\xef\xbb\xbfSeguridad: aprobado'     ligero
cerrar "ligero: Segur idad blanco"               'Segur idad: aprobado'                 ligero
cerrar "ligero: Segurídad NFC (desfase)"         $'Segur\xc3\xaddad: aprobado'          ligero

echo
echo "########## CONTROL: ¿se mueve alguna decision? (clave LIMPIA, mismos rigores) ##########"
cerrar "CONTROL limpia, Seguridad AUSENTE"      'Notas: x'                             ligero
cerrar "CONTROL limpia, Seguridad AUSENTE"      'Notas: x'                             critico
cerrar "CONTROL limpia, Seguridad: aprobado"    'Seguridad: aprobado'                  ligero
cerrar "estandar: Ѕeguridad homoglifo"          $'\xd0\x85eguridad: aprobado'          estandar
cerrar "estandar: Seguridad+ZWSP"               $'Seguri\xe2\x80\x8bdad: aprobado'     estandar
