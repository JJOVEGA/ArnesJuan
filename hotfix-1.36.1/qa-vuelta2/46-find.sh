#!/usr/bin/env bash
# (b) El enlace duro y `find`: si `find` falta o falla, la decisión tiene que ser la de v1.36.0.
# También la hermana de L1 en v1.36.0 (directorio como último operando). Uso: bash 36-find.sh <candidata> <v1.36.0>
set -u
HC="$1"; HV="$2"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
P="$T/p"; mkdir -p "$P/.arnes" "$P/requirements" "$P/src" "$P/docs/sub"
printf '%s\n' '{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*","app/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}' > "$P/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
printf 'n\n' > "$P/docs/notas.md"; printf 'a\n' > "$P/src/a.ts"; printf 'S\n' > "$P/S"; ln "$P/src/a.ts" "$P/docs/hl"
# PATH sin find: enlaces a todo ~/.local/bin (jq), /usr/local/bin, /usr/bin y /bin salvo find
SF="$T/sinfind"; mkdir -p "$SF"; for d in /home/juan/.local/bin /usr/local/bin /usr/bin /bin; do for f in "$d"/*; do b="${f##*/}"; [ "$b" = find ] || [ -e "$SF/$b" ] || ln -s "$f" "$SF/$b" 2>/dev/null; done; done
# find que falla, y find que no imprime nada
FF="$T/falla"; mkdir -p "$FF"; printf '#!/bin/sh\nexit 1\n' > "$FF/find"; chmod +x "$FF/find"
FV="$T/vacio"; mkdir -p "$FV"; printf '#!/bin/sh\nexit 0\n' > "$FV/find"; chmod +x "$FV/find"
dec() {   # <hooks> <PATH> <comando>
  local out; out="$(cd "$T" && jq -cn --arg c "$P" --arg k "$3" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$c,tool_input:{command:$k}}' | PATH="$2" CLAUDE_PROJECT_DIR="$P" "$(command -v bash)" "$1/guard.sh" 2>/dev/null)"
  case "$out" in *'"deny"'*) echo deny ;; '') echo 'SIN-DECISION/allow' ;; *) echo allow ;; esac
}
echo "fecha: $(date -Iseconds)  find del sistema: $(command -v find) ($(find --version 2>/dev/null | head -1))"
for k in 'cp S docs/notas.md' 'cp S docs/hl' 'ls -la' 'cp S src/a.ts'; do
  printf '%-22s | v1.36.0=%-5s | candidata: find normal=%-5s  sin find=%-18s  find falla=%-5s  find vacío=%-5s\n' "$k" \
    "$(dec "$HV" "$PATH" "$k")" "$(dec "$HC" "$PATH" "$k")" "$(dec "$HC" "$SF" "$k")" "$(dec "$HC" "$FF:$PATH" "$k")" "$(dec "$HC" "$FV:$PATH" "$k")"
done
echo "--- la hermana de L1 en v1.36.0: el último operando es un directorio"
k='echo src | xargs cp -r docs/sub'; printf '%-34s | v1.36.0=%s candidata=%s\n' "$k" "$(dec "$HV" "$PATH" "$k")" "$(dec "$HC" "$PATH" "$k")"
( cd "$P" && bash -c "$k" ) 2>/dev/null; echo "efecto: $(ls "$P/src" | tr '\n' ' ')"
