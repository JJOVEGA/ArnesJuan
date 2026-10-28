#!/usr/bin/env bash
# temporal.sh — arnes_gates_salida, lo funcional (qa-tester, Opus). Cada caso: decisión, dónde escribió y qué queda.
S=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad; . $S/proy.sh /dev/null '[]' 2>/dev/null
W=$S/w-temporal; rm -rf $W; mkdir -p $W
corre() {  # <etiqueta> <arbol> <gates-json> <TMPDIR o -> [traza]
  local P=$W/p-$1; . $S/proy.sh "$P" "$3"
  local o rc antes despues
  antes=$(ls /tmp/arnes_gate.* 2>/dev/null | wc -l)
  if [ "$4" = - ]; then o=$(cd "$P" && CLAUDE_PROJECT_DIR="$P" timeout 30 bash $S/arb/$2/hooks/guard.sh < "$P/in" 2>/dev/null); rc=$?
  else o=$(cd "$P" && TMPDIR="$4" CLAUDE_PROJECT_DIR="$P" timeout 30 bash $S/arb/$2/hooks/guard.sh < "$P/in" 2>/dev/null); rc=$?; fi
  despues=$(ls /tmp/arnes_gate.* 2>/dev/null | wc -l)
  local dec; dec=$(printf '%s' "$o" | jq -r '.hookSpecificOutput.permissionDecision + ": " + .hookSpecificOutput.permissionDecisionReason[0:90]' 2>/dev/null | tr '\n' '|'); [ -n "$o" ] || dec=allow
  local esc; esc=$(cat "$P/donde53" 2>/dev/null); [ -z "$esc" ] || esc="$esc (existe tras salir: $([ -e "$esc" ] && echo SI || echo no))"
  echo "$1 [$2] gates=$3 TMPDIR=$4 rc=$rc → $dec"; echo "    la gate escribió en: $esc"; echo "    /tmp/arnes_gate.* antes=$antes después=$despues"
}
U=$W/no-escribible; mkdir -p $U; chmod 555 $U
D='readlink /proc/$BASHPID/fd/1 > donde53'
corre base-verde cdbe2a8 "[\"$D; true\"]" -
corre base-roja cdbe2a8 "[\"$D; false\"]" -
corre sin-gates cdbe2a8 '[]' -
corre tmpdir-ro-verde cdbe2a8 "[\"$D; true\"]" $U
corre tmpdir-ro-roja cdbe2a8 "[\"$D; false\"]" $U
corre tmpdir-noexiste-roja cdbe2a8 "[\"$D; false\"]" $W/no/existe
corre tmpdir-barra-final cdbe2a8 "[\"$D; false\"]" /tmp/
corre tmpdir-raiz cdbe2a8 "[\"$D; false\"]" /
corre tmpdir-relativo cdbe2a8 "[\"$D; false\"]" rel
ls -la $W/p-tmpdir-relativo/rel 2>&1 | head -3
corre noclobber-no-llega cdbe2a8 '["echo a > f53; echo b > f53; [ \"$(cat f53)\" = b ]"]' -
# colisión (copia con el nombre fijo /tmp/arnes_gate.fijo): lo que ya existe se descarta sin abrirlo y se cae a mktemp
T=/tmp/arnes_gate.fijo
for forma in regular enlace-a-archivo enlace-colgante fifo directorio; do
  rm -rf $T $W/destino; echo intacto > $W/destino
  case $forma in regular) echo ajeno > $T;; enlace-a-archivo) ln -s $W/destino $T;; enlace-colgante) ln -s $W/no-hay $T;; fifo) mkfifo $T;; directorio) mkdir $T;; esac
  corre colision-$forma colision "[\"$D; echo GATE; false\"]" -
  echo "    tras: $(stat -c '%F' $T 2>&1) contenido=<$( [ -f $T ] && cat $T)> destino=<$(cat $W/destino)> no-hay=<$(ls $W/no-hay 2>&1 | head -c 40)>"
done
rm -rf $T $W/destino
# libre: la copia crea /tmp/arnes_gate.fijo y lo borra
corre colision-libre colision "[\"$D; echo GATE; false\"]" -
ls -la $T 2>&1 | head -1
chmod 755 $U
