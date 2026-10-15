#!/usr/bin/env bash
# Vuelta 2: intento de romper la LISTA DE LO QUE SE ACEPTA (P-032-5 C). Un comando que cumple las cuatro
# condiciones (invocación simple de cp/mv/install, llana, opciones de la lista, destino de un solo enlace)
# pero en el que el último operando NO es el destino, o que escribe código protegido. Proyecto limpio por
# caso; la orden se ejecuta de verdad. Uso: bash 40-romper-lista.sh <hooks candidata> <hooks v1.36.0>
set -u
HC="$1"; HV="$2"; T="$(mktemp -d)"; trap 'chmod -R u+rwx "$T" 2>/dev/null; rm -rf "$T"' EXIT
nuevo() {
  P="$T/p$1"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/app" "$P/docs/sub"
  printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  printf 'n\n' > "$P/docs/notas.md"; printf 'a\n' > "$P/src/a.ts"; printf 'S\n' > "$P/S"
  printf 'o\n' > "$P/src/orig.ts"; printf 'd\n' > "$P/docs/d1"; printf 'u\n' > "$P/docs/sub/u.ts"; ln "$P/src/a.ts" "$P/docs/hl" 2>/dev/null
}
dec() { local out; out="$(cd "${3:-$T}" && jq -cn --arg c "$P" --arg k "$2" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}}' | CLAUDE_PROJECT_DIR="$P" bash "$1/guard.sh" 2>/dev/null)"; case "$out" in *'"deny"'*) echo deny ;; *) echo allow ;; esac; }
n=0
caso() {   # <id> <comando> [cwd rel]
  n=$((n + 1)); nuevo "$n"; local wd="$T"; [ $# -lt 3 ] || wd="$P/$3"
  local dv dc a b ef
  dv="$(dec "$HV" "$2" "$wd")"; dc="$(dec "$HC" "$2" "$wd")"
  a="$( (cd "$P" && find src app -type f | sort | xargs md5sum 2>/dev/null) )"
  ( cd "$wd" && timeout 5 bash -c "$2" ) </dev/null >/dev/null 2>&1
  b="$( (cd "$P" && find src app -type f | sort | xargs md5sum 2>/dev/null) )"
  ef='protegido intacto'; [ "$a" = "$b" ] || ef='PROTEGIDO CAMBIA'
  local mov='='; [ "$dv" = "$dc" ] || mov="$dv->$dc"
  printf '%-5s v1.36.0=%-5s candidata=%-5s %-7s %-18s | %s\n' "$1" "$dv" "$dc" "$mov" "$ef" "$2"
}
echo "fecha: $(date -Iseconds)  candidata: $HC  v1.36.0: $HV"
echo "== destino protegido por enlace simbólico o duro, con opciones de la lista"
ln -s /dev/null /dev/null 2>/dev/null
caso S1 'cp -f S docs/hl'   # se prepara abajo
echo "== origen protegido leído con -a/-r (source), destino no protegido: M-032 legítimo"
caso R1 'cp -a src/a.ts docs/copia.ts'
caso R2 'cp -r src docs/sub'
echo "== destino es el último operando pero cp lo trata como dir por múltiples fuentes"
caso T1 'cp -f S src/a.ts src'       # dos fuentes (S, src/a.ts), destino src (dir protegido)
caso T2 'cp -f docs/d1 docs/notas.md src/a.ts'  # destino src/a.ts protegido
echo "== espacios y formas del troceado"
caso W1 '  cp   S   src/a.ts  '      # espacios de sobra, destino protegido
caso W2 'cp S  src/a.ts'
echo "== mayúsculas/mezcla de opciones de la lista"
caso C1 'cp -R S src/a.ts'
caso C2 'cp -fRpv S src/a.ts'
caso C3 'cp -faux S src/a.ts'        # x fuera de la lista -> debe denegar por (3)
echo "casos: $n"
