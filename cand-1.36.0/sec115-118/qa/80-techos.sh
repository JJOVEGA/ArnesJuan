#!/usr/bin/env bash
# 80-techos.sh <scratch> <hooks>... — CA-68 «Cambio de compatibilidad declarado» y CA-69 p. 3: las dos fronteras de
# los techos, y llamadas LEGÍTIMAS sobre archivos reales del repositorio (copias, en un proyecto con el manifiesto
# base), dentro y FUERA de requirements/, por guard.sh, como la coordinadora y como el analista. Una corrida por punto.
set -u; S="$1"; shift; QD="$(cd "$(dirname "$0")" && pwd)"; . "$QD/h.sh"; R=/home/juan/dev/ArnesJuan-v1.36
W="$(mktemp -d "$S/techos-XXXX")"; trap 'rm -rf "$W"' EXIT; P="$W/p"
prep() { mkp "$P"; cp "$R"/requirements/REQ-007.md "$R"/requirements/REQ-021.md "$R"/requirements/REQ-023.md "$R"/requirements/REQ-014.md "$R"/requirements/README.md "$P/requirements/"
  cp "$R/CHANGELOG.md" "$R/PENDING_APPROVAL.md" "$P/"; mkdir -p "$P/docs/seguridad"; cp "$R/docs/seguridad/registro-seguridad.md" "$P/docs/seguridad/"; }
caso() { local H; for H in "${HS[@]}"; do printf '%-62s %-26s %s\n' "$1" "${H#/home/juan/dev/}" "$(corre "$H" guard.sh "$2" | cut -c1-150)"; done; }
wr() { jq -Rs --arg fp "$P/$1" --arg c "$P" --arg at "${2:-}" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$fp,content:.}} + (if $at!="" then {agent_id:"a1",agent_type:$at} else {} end)' < "$P/$1" > "$W/in"; }
ed() { # <rel> <offset> <len> [agente]
  local o; o="$(LC_ALL=C; t="$(cat "$P/$1"; printf x)"; printf '%s' "${t:$2:$3}")"
  jq -n --arg fp "$P/$1" --arg c "$P" --arg o "$o" --arg at "${4:-}" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:$o,new_string:($o+" ")}} + (if $at!="" then {agent_id:"a1",agent_type:$at} else {} end)' > "$W/in"; }
me() { # <rel> <n ediciones> <len cada una> — ediciones disjuntas consecutivas desde el byte 20000
  local i o args='[]' t; t="$(LC_ALL=C; cat "$P/$1"; printf x)"
  for ((i = 0; i < $2; i++)); do o="$(LC_ALL=C; printf '%s' "${t:$((20000 + i * ($3 + 7))):$3}")"; args="$(jq -c --arg o "$o" '. + [{old_string:$o,new_string:($o+" ")}]' <<< "$args")"; done
  jq -n --arg fp "$P/$1" --arg c "$P" --argjson e "$args" '{hook_event_name:"PreToolUse",tool_name:"MultiEdit",cwd:$c,tool_input:{file_path:$fp,edits:$e}}' > "$W/in"; }
HS=("$@")
echo "# $(date -Is); loadavg $(cat /proc/loadavg); tamaños: $(cd $R && wc -c requirements/REQ-007.md requirements/REQ-021.md requirements/REQ-023.md CHANGELOG.md PENDING_APPROVAL.md docs/seguridad/registro-seguridad.md | tr '\n' ';')"
prep
for f in requirements/REQ-007.md requirements/REQ-021.md requirements/REQ-023.md requirements/REQ-014.md requirements/README.md CHANGELOG.md PENDING_APPROVAL.md docs/seguridad/registro-seguridad.md; do
  wr "$f"; caso "Write de $f entero (coordinadora)" "$W/in"; wr "$f" analista-requerimientos; caso "Write de $f entero (analista)" "$W/in"; done
for L in 3000 6000 6100 6200 7000; do ed requirements/REQ-007.md 30000 "$L" analista-requerimientos; caso "Edit REQ-007 old_string $L B (analista)" "$W/in"; done
for L in 12000 60000; do ed CHANGELOG.md 30000 "$L"; caso "Edit CHANGELOG old_string $L B" "$W/in"; ed docs/seguridad/registro-seguridad.md 30000 "$L"; caso "Edit registro-seguridad old_string $L B" "$W/in"; done
ed requirements/REQ-021.md 30000 14000 analista-requerimientos; caso "Edit REQ-021 old_string 14000 B (analista)" "$W/in"
for ne in 10 20 30 60; do me requirements/REQ-007.md "$ne" 200; caso "MultiEdit REQ-007 $ne ediciones x 200 B" "$W/in"; done
# Fronteras: Write de un REQ nuevo con content de 393213 / 393214 bytes terminado en salto.
for n in 393213 393214; do mkp "$P"; { printf '# REQ-901\nEstado: en-revisión\n\n'; head -c $((n - 32)) /dev/zero | tr '\0' x; printf '\n'; } > "$W/c"; head -c "$n" "$W/c" > "$W/c2"; printf '%s' "$(cat "$W/c2")" > /dev/null
  jq -Rs --arg fp "$P/requirements/REQ-901.md" --arg c "$P" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$fp,content:.}}' < "$W/c2" > "$W/in"; caso "Write REQ nuevo content $(wc -c < "$W/c2") B" "$W/in"; done
# Presupuesto: doc (bytes) x old: 65536 x 65536 = 2^32 justo; el old de una racha al final.
for par in 65536:65535 65536:65536 65536:65537 131072:32767 131072:32768; do
  d=${par%%:*}; o=${par#*:}; mkp "$P"; dn=$(( d - o )); [ $dn -ge 0 ] || dn=0
  { printf '# REQ-900\nEstado: en-revisión\n'; head -c $(( d - 22 )) /dev/zero | tr '\0' a; } > "$P/requirements/REQ-900.md"
  jq -n --arg fp "$P/requirements/REQ-900.md" --arg c "$P" --arg o "$(head -c "$o" /dev/zero | tr '\0' a)" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:$o,new_string:""}}' > "$W/in"
  caso "Edit presupuesto: disco $(wc -c < "$P/requirements/REQ-900.md") B x old $o B (new vacío)" "$W/in"
done
