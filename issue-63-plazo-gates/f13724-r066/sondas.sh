#!/usr/bin/env bash
# sondas.sh — R-066 (auditor-seguridad): conductas deny->allow frente a v1.36.2, a nivel de hook (guard.sh).
# Columnas: candidato (d89316c) | v1.36.2. Sin ataques contra nada real: proyectos temporales en el scratchpad.
set -u
R=/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r066
C=$R/arb/cand; B=$R/arb/base; T=$C/tools/arnes-gates.sh
mk() {   # <dir> <gates como JSON>
  local P=$1; rm -rf "$P"; mkdir -p "$P/requirements" "$P/.arnes" "$P/src"
  jq -n --argjson g "$2" '{agentes:{agente_codigo:"desarrollador",conocidos:["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},codigo_app:{globs:["src/*"]},quality_gates:$g}' > "$P/.arnes/config.json"
  printf '# Aprobaciones\n\n## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
  printf '# REQ-001 — prueba\nEstado: en-revisión\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\nHallazgos abiertos: (ninguno)\nRigor: estandar\n\n## Historia\nTexto.\n' > "$P/requirements/REQ-001.md"
  echo bien > "$P/src/a.txt"; printf '.arnes/gates-veredicto.json\nbuild/\n' > "$P/.gitignore"
  ( cd "$P" && git init -q && git add -A && git -c user.name=s -c user.email=s@x commit -qm base )
}
cierra() {   # <hooks> <proj> -> allow | deny:<motivo corto> | rc=N sin salida
  local H=$1 P=$2 out rc
  out=$(jq -n --arg fp "$P/requirements/REQ-001.md" --arg cwd "$P" '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$cwd,agent_id:"a1",agent_type:"qa-tester",tool_input:{file_path:$fp,old_string:"Estado: en-revisión",new_string:"Estado: completado"}}' \
        | (cd "$P" && CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$H/hooks/guard.sh" 2>/dev/null)); rc=$?
  if [[ $out == *'"deny"'* ]]; then
    local m; m=$(jq -r '.hookSpecificOutput.permissionDecisionReason // .reason // empty' <<< "$out" 2>/dev/null | head -c 150)
    echo "deny:${m#ARNES: no se puede marcar*completado\': }"
  elif [ -z "$out" ] && [ "$rc" = 0 ]; then echo allow
  else echo "rc=$rc salida=${out:0:80}"; fi
}
herr() { ( cd "$1" && bash "$T" --quien auditor-seguridad >/dev/null 2>&1 ); echo "herramienta rc=$?"; }
W=$R/w; mkdir -p "$W"

echo "## S1 control: cierre legitimo (gate verde, herramienta, huella vigente)"
mk $W/c1 '["grep -q bien src/a.txt"]'; herr $W/c1; echo "  cand: $(cierra $C $W/c1)"; echo "  base: $(cierra $B $W/c1)"

echo "## S2 control: gate roja; registro rojo"
mk $W/c2 '["grep -q mal src/a.txt"]'; herr $W/c2; echo "  cand: $(cierra $C $W/c2)"; echo "  base: $(cierra $B $W/c2)"

echo "## S3 archivo IGNORADO cambia tras el verde (gate lo evalua)"
mk $W/c3 '["! grep -qs mal build/out.txt"]'; herr $W/c3; mkdir -p $W/c3/build; echo mal > $W/c3/build/out.txt
echo "  cand: $(cierra $C $W/c3)"; echo "  base: $(cierra $B $W/c3)"

echo "## S4 ruta EXCLUIDA cambia tras el verde (gate la evalua: docs/qa/)"
mk $W/c4 '["! grep -qs mal docs/qa/x.md"]'; herr $W/c4; mkdir -p $W/c4/docs/qa; echo mal > $W/c4/docs/qa/x.md
echo "  cand: $(cierra $C $W/c4)"; echo "  base: $(cierra $B $W/c4)"

echo "## S5 enlace simbolico seguido hacia FUERA del arbol; cambia el destino tras el verde"
mk $W/c5 '["grep -q bien src/ext/f.txt"]'; mkdir -p $W/fuera5; echo bien > $W/fuera5/f.txt; ln -s $W/fuera5 $W/c5/src/ext
( cd $W/c5 && git add -A && git -c user.name=s -c user.email=s@x commit -qm ext ); herr $W/c5; echo mal > $W/fuera5/f.txt
echo "  cand: $(cierra $C $W/c5)"; echo "  base: $(cierra $B $W/c5)"

echo "## S6 repositorio anidado: cambia su contenido tras el verde"
mk $W/c6 '["grep -q bien sub/f.txt"]'; mkdir -p $W/c6/sub; ( cd $W/c6/sub && git init -q && echo bien > f.txt && git add -A && git -c user.name=s -c user.email=s@x commit -qm s )
herr $W/c6; echo mal > $W/c6/sub/f.txt
echo "  cand: $(cierra $C $W/c6)"; echo "  base: $(cierra $B $W/c6)"

echo "## S7 cambio TRANSITORIO durante la corrida, restaurado antes del hash final (proceso concurrente, no gate)"
mk $W/c7 '["sleep 1", "grep -q bien src/a.txt", "sleep 2"]'; echo mal > $W/c7/src/a.txt; ( cd $W/c7 && git -c user.name=s -c user.email=s@x commit -qam mal )
( sleep 0.4; echo bien > $W/c7/src/a.txt; sleep 1.4; echo mal > $W/c7/src/a.txt ) & herr $W/c7; wait
echo "  arbol final: $(cat $W/c7/src/a.txt); registro rc: $(jq -c '[.gates[].rc]' $W/c7/.arnes/gates-veredicto.json 2>/dev/null)"
echo "  cand: $(cierra $C $W/c7)"; echo "  base (mismo arbol final, sin carrera): $(cierra $B $W/c7)"
echo "  base, misma carrera durante el hook:"; ( sleep 0.4; echo bien > $W/c7/src/a.txt; sleep 1.4; echo mal > $W/c7/src/a.txt ) & echo "    $(cierra $B $W/c7)"; wait

echo "## S8 la misma carrera hecha por gates (gate 1 cambia, gate 3 restaura)"
mk $W/c8 '["cp src/a.txt /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r066/s8.bak; echo bien > src/a.txt", "grep -q bien src/a.txt", "cp /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r066/s8.bak src/a.txt"]'
echo mal > $W/c8/src/a.txt; ( cd $W/c8 && git -c user.name=s -c user.email=s@x commit -qam mal ); herr $W/c8
echo "  arbol final: $(cat $W/c8/src/a.txt)"; echo "  cand: $(cierra $C $W/c8)"; echo "  base: $(cierra $B $W/c8)"

echo "## S9 gate hostil que mata al hook (v1.36.2) / a la herramienta (cand), con una roja detras"
mk $W/c9 '["kill -9 $$", "false"]'; herr $W/c9; echo "  registro: $(ls $W/c9/.arnes/gates-veredicto.json 2>&1 | head -c 80)"
echo "  cand: $(cierra $C $W/c9)"; echo "  base: $(cierra $B $W/c9)"
rm -f /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/r066/s8.bak
