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
  printf 'o\n' > "$P/src/orig.ts"; printf 'd\n' > "$P/docs/d1"; printf 'u\n' > "$P/docs/sub/u.ts"
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
echo "== origen que es directorio (cp -r / -a), destino archivo o inexistente"
caso D1 'cp -r docs/sub src/a.ts'
caso D2 'cp -a docs/sub src/a.ts'
caso D3 'cp -r docs/sub app/x'
caso D4 'cp -R docs/sub src/nuevo'
echo "== -f -n -i -p -u -v con destino archivo o directorio protegido"
caso O1 'cp -f S src/a.ts'
caso O2 'cp -n S src/a.ts'
caso O3 'cp -p S src/a.ts'
caso O4 'cp -u S src/a.ts'
caso O5 'cp -fi S src/a.ts'
caso O6 'cp -v S src'
caso O7 'install -p S src/a.ts'
caso O8 'mv -f S src/a.ts'
echo "== operandos que empiezan por - sin ser opciones (tras -- no; aquí sin --)"
caso G1 'cp S -f'
caso G2 'cp -- S src/a.ts'
caso G3 'cp S src/a.ts extra'
caso G4 'cp -f -- S src/a.ts'
echo "== un solo operando (n<2): no debería retirar la marca"
caso U1 'cp src/a.ts'
caso U2 'cp -f src/a.ts'
echo "== nombres raros del conjunto permitido en el destino"
caso N1 'cp S src/a=b.ts'    # destino nuevo con =
caso N2 'cp S src/a.ts'      # el caso base M-032 legítimo
caso N3 'cp S ./src/a.ts'    # . y / permitidos; sigue siendo src/a.ts
caso N4 'cp S src/sub/u.ts' src
caso N5 'cp S +x'            # destino '+x' inexistente en raíz
echo "== find -exec y otros portadores del destino, llanos"
caso X1 'find docs -name notas.md -exec cp S {} ;'
caso X2 'find src -name a.ts -exec cp S {} +'
echo "== cp con tres operandos y el del medio protegido (varios orígenes, un destino dir)"
caso M1 'cp S src/a.ts docs/sub'   # destino docs/sub (dir), src/a.ts es ORIGEN
caso M2 'mv src/orig.ts S docs'    # destino docs (dir)
echo "casos: $n"
