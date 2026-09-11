#!/usr/bin/env bash
# Verificacion ACOTADA de la correccion estructural de CA-13 (REQ-024), sobre el hook REAL.
# Base: /home/juan/dev/ArnesJuan-1.34-reparaciones @ 587cbb0 — hooks/ IDENTICOS a a05994f
# (git diff a05994f HEAD -- hooks tools .github == vacio).
# NO repite las 56 celdas ni las 41 formas: ejerce solo las dudas de la verificacion.
set -u
REPO=/home/juan/dev/ArnesJuan-1.34-reparaciones
PROJ=/tmp/claude-1000/-home-juan-dev-ArnesJuan/23a8ee5a-8587-4923-8f15-1fc9bf03aaf2/scratchpad/p13
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

# ---- A) El TEXTO del aviso de desfase, tal cual lo emite la maquina ----------------
aviso_txt() { # <rotulo> <linea>
  local rot="$1" ns="$2" out msg
  printf '# REQ-950\nEstado: en-revisión\nSensible a seguridad: no\nQA: pendiente\nSeguridad: pendiente\n' > "$PROJ/requirements/REQ-950.md"
  out="$(jq -n --arg fp "$PROJ/requirements/REQ-950.md" --arg ns "$ns" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,old_string:"x",new_string:$ns}}' | "$REPO/hooks/guard-completado.sh" 2>/dev/null)"
  msg="$(printf '%s' "$out" | jq -r '.systemMessage // ""' 2>/dev/null)"
  echo "--- $rot"
  printf '    %s\n' "$msg"
  printf '    CONDICIONADO(\"si el rigor efectivo es critico\")=%s\n' \
    "$(printf '%s' "$msg" | grep -q 'rigor efectivo es critico' && echo SI || echo NO)"
}

# ---- B) El CIERRE: campo AUSENTE por rigor (la sede es CA-01) ----------------------
cierre() { # <rotulo> <bloque de cabecera SIN Estado> <rigor>
  local rot="$1" cab="$2" rigor="$3" out deny motivo
  { printf '# REQ-951\nEstado: en-revisión\nSensible a seguridad: no\n'
    printf '%s\n' "$cab"
    printf 'Hallazgos abiertos: (ninguno)\nRigor: %s\n\n## Historia\n' "$rigor"; } > "$PROJ/requirements/REQ-951.md"
  out="$(jq -n --arg fp "$PROJ/requirements/REQ-951.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' \
    | "$REPO/hooks/guard-completado.sh" 2>/dev/null)"
  deny=ALLOW; printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"' && deny=DENY
  motivo="$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecisionReason // ""' 2>/dev/null | tr '\n' ' ')"
  printf '  %-46s rigor=%-9s %-5s :: %s\n' "$rot" "$rigor" "$deny" "$(printf '%s' "$motivo" | head -c 165)"
}

echo "########## A — TEXTO REAL DEL AVISO DE DESFASE (guard-completado.sh:287-292) ##########"
aviso_txt "desfase de QA:        (qa: minuscula)"        'qa: aprobado'
aviso_txt "desfase de Seguridad: (seguridad: minuscula)" 'seguridad: aprobado'

echo
echo "########## B1 — QA: AUSENTE por rigor (el aviso de QA NO lleva condicion) ##########"
for r in ligero estandar critico; do
  cierre "QA: AUSENTE, Seguridad: aprobado" 'Seguridad: aprobado' "$r"
done
echo "  [control] QA: aprobado declarado, mismo cuerpo"
for r in ligero estandar critico; do
  cierre "QA: aprobado + Seguridad: aprobado" $'QA: aprobado\nSeguridad: aprobado' "$r"
done

echo
echo "########## B2 — Seguridad: AUSENTE por rigor (el aviso SI lleva condicion) ##########"
for r in ligero estandar critico; do
  cierre "Seguridad: AUSENTE, QA: aprobado" 'QA: aprobado' "$r"
done

echo
echo "########## C — HOMOGLIFO y TRUNCADA (clase 'no'): lo que CA-13 (v) afirma ##########"
for r in ligero estandar critico; do
  cierre "Ѕeguridad: U+0405 (homoglifo)" $'QA: aprobado\n\xd0\x85eguridad: aprobado' "$r"
done
for r in ligero estandar critico; do
  cierre "Segurida: truncada" $'QA: aprobado\nSegurida: aprobado' "$r"
done

echo
echo "########## D — ZWSP / BOM / blanco de mas: guarda de MEDIBILIDAD, tambien en ligero ##########"
for r in ligero estandar critico; do
  cierre "Seguri<ZWSP>dad:" $'QA: aprobado\nSeguri\xe2\x80\x8bdad: aprobado' "$r"
done
for r in ligero estandar critico; do
  cierre "<BOM>Seguridad:" $'QA: aprobado\n\xef\xbb\xbfSeguridad: aprobado' "$r"
done
for r in ligero estandar critico; do
  cierre "Segur idad: (blanco de mas)" $'QA: aprobado\nSegur idad: aprobado' "$r"
done

echo
echo "########## E — Segurídad: (desfase) en ligero: lo que (ii) retiro por falso ##########"
for r in ligero estandar critico; do
  cierre "Segurídad: NFC (desfase)" $'QA: aprobado\nSegur\xc3\xaddad: aprobado' "$r"
done
