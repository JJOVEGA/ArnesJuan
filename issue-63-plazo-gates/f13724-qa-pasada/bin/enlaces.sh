#!/usr/bin/env bash
# enlaces.sh — QA-037-11 sobre la candidata: la puerta de Bash ante `ln`/`link`/`cp -l|-s` con el registro, y la puerta
# de cierre ante un registro enlazado. Proyecto con gate `false` (veredicto real: rojo); VJ = un verde falsificado con
# el hash correcto. Si la puerta de Bash deja pasar una forma, se ejecuta y se juzga el cierre.
R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/issue-63-f13724-qa-pasada
A=$R/arb/d89316c; B=$R/arb/46ee7ca; W=$R/w-enlaces; rm -rf $W; mkdir -p $W
nuevo() { bash $R/bin/cierres.sh $A rojo 0 $W >/dev/null 2>&1; P=$W/p-rojo
  (cd $P && bash -c '. "$1/hooks/lib.sh"; arnes_hash_arbol . && jq -n --argjson f "$ARNES_VEREDICTO_FORMATO" --arg a "$ARNES_ARBOL_DEF" --arg h "$ARNES_HASH" "{formato:\$f,arbol:\$a,hash:\$h,gates:[{comando:\"false\",rc:0,ms:1}],fecha:\"2026-10-28T00:00:00Z\",quien:\"qa-tester\"}"' _ "$A") > $W/v.json; }
cierre() { local o; o=$(cd $P && CLAUDE_PROJECT_DIR=$P bash $A/hooks/guard.sh < $W/in-rojo 2>/dev/null); [ -n "$o" ] && jq -r '.hookSpecificOutput.permissionDecision + " (" + (.hookSpecificOutput.permissionDecisionReason | capture("(?<m>no salio 0|ilegible|leer como un veredicto completo \\([^)]*\\)|no es del arbol|no hay veredicto)").m // "otro") + ")"' <<< "$o" 2>/dev/null || echo allow; }
juzga() { local o; o=$(cd $P && CLAUDE_PROJECT_DIR=$P bash $1/hooks/guard.sh <<< "$2" 2>/dev/null); [ -n "$o" ] && jq -r '.hookSpecificOutput.permissionDecision' <<< "$o" || echo allow; }
in_bash() { jq -cn --arg c "$1" --arg cwd "$P" --arg t "$2" '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:$cwd,tool_input:{command:$c}} + (if $t=="" then {} else {agent_id:"a1",agent_type:$t} end)'; }
echo "# QA-037-11 sobre d89316c (qa-tester, Opus), $(date -Is)"
nuevo; echo "control: cierre con el veredicto real: $(cierre)"
echo "## La puerta de cierre ante un registro enlazado, creado SIN pasar por la puerta de Bash (el caso de una forma que el detector no ve)"
nuevo; ln -sf $W/v.json $P/.arnes/gates-veredicto.json; echo "  simbólico a un verde falsificado: $(cierre)"
nuevo; rm -f $P/.arnes/gates-veredicto.json; ln $W/v.json $P/.arnes/gates-veredicto.json; echo "  duro (2 enlaces) a un verde falsificado: $(cierre)"
nuevo; rm -f $P/.arnes/gates-veredicto.json; ln $W/v.json $P/.arnes/gates-veredicto.json; rm -f $W/v.json; echo "  duro y después rm de la otra ruta (queda 1 enlace, contenido falso): $(cierre)   [equivale a escribirlo]"
nuevo; (cd $P && bash $A/tools/arnes-gates.sh --quien qa-tester >/dev/null 2>&1); ln $P/.arnes/gates-veredicto.json $W/copia; echo "  el registro real con un enlace duro de más: $(cierre)"
echo "## La puerta de Bash (qa-tester | coordinadora | v1.36.2 a qa-tester); si la candidata deja pasar a qa-tester, se ejecuta y se juzga el cierre"
while IFS= read -r c; do [ -n "$c" ] || continue; nuevo; c2="${c//VJ/$W/v.json}"; c2="${c2//OTRO/$W/otro}"
  dA=$(juzga $A "$(in_bash "$c2" qa-tester)"); dC=$(juzga $A "$(in_bash "$c2" '')"); dB=$(juzga $B "$(in_bash "$c2" qa-tester)")
  r=''; if [ "$dA" = allow ]; then (cd $P && eval "$c2") >/dev/null 2>&1; r=" → ejecutada; cierre: $(cierre)"; fi
  echo "  [$c] $dA | $dC | $dB$r"; done <<'L'
ln -sf VJ .arnes/gates-veredicto.json
ln -s VJ .arnes/gates-veredicto.json
ln VJ .arnes/gates-veredicto.json
ln -f VJ .arnes/gates-veredicto.json
ln --symbolic --force VJ .arnes/gates-veredicto.json
ln -sfT VJ .arnes/gates-veredicto.json
ln -s -t .arnes VJ
ln -st .arnes VJ
ln --target-directory=.arnes VJ
ln -sf VJ .arnes/
ln -- VJ .arnes/gates-veredicto.json
ln .arnes/gates-veredicto.json OTRO
ln -s .arnes/gates-veredicto.json OTRO
ln -s VJ OTRO; cp OTRO .arnes/gates-veredicto.json
link VJ .arnes/gates-veredicto.json
cp -l VJ .arnes/gates-veredicto.json
cp -s VJ .arnes/gates-veredicto.json
cp --link VJ .arnes/
true; ln -s VJ .arnes/gates-veredicto.json
echo hola && ln VJ .arnes/gates-veredicto.json
L
echo "## El permitido: ln -s <registro> otro (el registro como fuente de un simbólico); ¿se puede escribir a través de él?"
nuevo; (cd $P && bash $A/tools/arnes-gates.sh --quien qa-tester >/dev/null 2>&1); ln -s .arnes/gates-veredicto.json $P/atajo
for c in "cp VJ atajo" "cat VJ > atajo" "tee atajo < VJ" "sed -i s/1/0/ atajo" "cp VJ ./atajo" "mv VJ atajo"; do c2="${c//VJ/$W/v.json}"; echo "  [$c] qa-tester: $(juzga $A "$(in_bash "$c2" qa-tester)") | coordinadora: $(juzga $A "$(in_bash "$c2" '')")"; done
echo "  si una de esas pasara, el registro quedaría con contenido falso y un enlace: cp por el atajo, ejecutado a mano → cierre: $(cp $W/v.json $P/atajo 2>/dev/null; cierre)"
