#!/usr/bin/env bash
# ¿ARNES_RIGOR_MATIZ contamina de un documento al SIGUIENTE, a nivel de PUERTA
# y de los dos consumidores que leen VARIOS REQ en UN MISMO PROCESO?
#
# La sonda del proyecto ya cubre el LECTOR. Aquí se mide:
#   (A) la puerta invocada en SECUENCIA sobre dos REQ (matiz -> limpio y al revés);
#   (B) la puerta sobre un REQ limpio cuando en la MISMA carpeta hay REQ con matiz,
#       en los dos ordenes alfabeticos posibles (por si algo recorre el directorio);
#   (C) hooks/estado-derivado.sh, que recorre TODOS los REQ en un solo proceso;
#   (D) tools/arnes-lectura.sh, idem.
# El REQ limpio es `Rigor: ligero` con QA y Seguridad PENDIENTES: si se contamina,
# deja de cerrar (deny) y la contaminacion se ve.
set -u
HOOKS="${1:-/home/juan/dev/ArnesJuan-1.33.2/hooks}"
TOOLS="${2:-/home/juan/dev/ArnesJuan-1.33.2/tools}"
RAIZ="$(mktemp -d)"; trap 'rm -rf "$RAIZ"' EXIT
nuevo_proj() {
  PROJ="$RAIZ/p$RANDOM$RANDOM"; mkdir -p "$PROJ/.arnes" "$PROJ/requirements" "$PROJ/docs" "$PROJ/src"
  cat > "$PROJ/.arnes/config.json" <<'CFG'
{ "agentes": { "agente_codigo": "desarrollador", "conocidos": ["desarrollador","qa-tester"] },
  "codigo_app": { "globs": ["src/*"] }, "quality_gates": ["true"],
  "estados": { "completado": "completado" }, "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md" }
CFG
  printf '## Pendientes\n\n## Resueltas\n' > "$PROJ/PENDING_APPROVAL.md"
  export CLAUDE_PROJECT_DIR="$PROJ"
}
req() { # <nombre> <rigor> <qa> <seg>
  { printf '# %s\nEstado: en-revisión\nSensible a seguridad: no\n' "$1"
    printf 'QA: %s\nSeguridad: %s\n' "$3" "$4"
    [ -n "$2" ] && printf 'Rigor: %s\n' "$2"; } > "$PROJ/requirements/$1.md"
}
cierra() { # <nombre> -> allow|deny
  local j o
  j="$(jq -n --arg fp "$PROJ/requirements/$1.md" '{hook_event_name:"PreToolUse",tool_name:"Edit",
      cwd:env.CLAUDE_PROJECT_DIR,
      tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}')"
  o="$(printf '%s' "$j" | "$HOOKS/guard-completado.sh" 2>/dev/null)"
  if printf '%s' "$o" | grep -Eq '"permissionDecision": *"deny"'; then echo deny; else echo allow; fi
}
ok() { [ "$2" = "$3" ] && echo "  PASS  $1 ($2)" || echo "  FAIL  $1  esperado=$3 got=$2"; }

echo "(A) PUERTA EN SECUENCIA, mismo shell, invocaciones consecutivas"
nuevo_proj
req REQ-A "ligero (local)" pendiente pendiente
req REQ-B "ligero"         pendiente pendiente
ok "A1 matiz primero -> deny"                 "$(cierra REQ-A)" deny
ok "A2 limpio DESPUES del matiz -> allow"     "$(cierra REQ-B)" allow
ok "A3 limpio primero -> allow"               "$(cierra REQ-B)" allow
ok "A4 matiz DESPUES del limpio -> deny"      "$(cierra REQ-A)" deny
ok "A5 limpio otra vez -> allow"              "$(cierra REQ-B)" allow

echo
echo "(B) REQ limpio con vecinos CON MATIZ en la misma carpeta, ambos ordenes"
nuevo_proj
req REQ-001 "ligero (a)" pendiente pendiente   # alfabeticamente ANTES
req REQ-500 "ligero"     pendiente pendiente
req REQ-999 "ligero (z)" pendiente pendiente   # alfabeticamente DESPUES
ok "B1 limpio entre dos con matiz -> allow"   "$(cierra REQ-500)" allow
nuevo_proj
req AAA-001 "ligero (a) (b)" pendiente pendiente
req ZZZ-999 "ligero"         pendiente pendiente
ok "B2 limpio ultimo del directorio -> allow" "$(cierra ZZZ-999)" allow

echo
echo "(C) hooks/estado-derivado.sh: TODOS los REQ en UN proceso, ambos ordenes"
for orden in "matiz-primero" "limpio-primero"; do
  nuevo_proj
  if [ "$orden" = "matiz-primero" ]; then
    req REQ-100 "ligero (local)" pendiente pendiente; req REQ-200 "ligero" pendiente pendiente
    req REQ-300 "critico (por suelo)" pendiente pendiente; req REQ-400 "ligero" pendiente pendiente
  else
    req REQ-100 "ligero" pendiente pendiente; req REQ-200 "ligero (local)" pendiente pendiente
    req REQ-300 "ligero" pendiente pendiente; req REQ-400 "critico (x)" pendiente pendiente
  fi
  printf '# Estado\n<!-- ARNES:ESTADO-DERIVADO:INICIO -->\n<!-- ARNES:ESTADO-DERIVADO:FIN -->\n' > "$PROJ/docs/ESTADO.md"
  printf '{"hook_event_name":"Stop","cwd":"%s"}' "$PROJ" | "$HOOKS/estado-derivado.sh" >/dev/null 2>&1
  echo "  --- orden: $orden ---"
  grep -oE 'REQ-[0-9]+[^|]*\|[^|]*\|[^|]*\|[^|]*\|[^|]*' "$PROJ/docs/ESTADO.md" 2>/dev/null | head -8 \
    || sed -n '/INICIO/,/FIN/p' "$PROJ/docs/ESTADO.md"
  echo "  rigor por REQ segun el bloque derivado:"
  sed -n '/INICIO/,/FIN/p' "$PROJ/docs/ESTADO.md" | grep -E 'REQ-[0-9]' | sed 's/^/    /'
done

echo
echo "(D) tools/arnes-lectura.sh: TODOS los REQ en UN proceso"
nuevo_proj
req REQ-100 "ligero (local)" pendiente pendiente
req REQ-200 "ligero" pendiente pendiente
req REQ-300 "ligero (x)" pendiente pendiente
req REQ-400 "ligero" pendiente pendiente
( cd "$PROJ" && ARNES_HOOKS_DIR="$HOOKS" "$TOOLS/arnes-lectura.sh" 2>&1 | grep -E 'rigor efectivo|REQ-' | sed 's/^/    /' )
echo "    (esperado: ligero 2 · estandar 2 · critico 0)"
