#!/usr/bin/env bash
source /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127/qa/sonda-qa.sh; prep_proy
mk() { # <tool> <fp-json> <agente|-> -> json
  local ti; case "$1" in Edit) ti="{file_path:$2,old_string:\"a\",new_string:\"b\"}";; Write) ti="{file_path:$2,content:\"x\"}";;
    MultiEdit) ti="{file_path:$2,edits:[{old_string:\"a\",new_string:\"b\"}]}";; esac
  jq -cn --arg c "$PQ" --arg a "$3" "{hook_event_name:\"PreToolUse\",tool_name:\"$1\",cwd:\$c,tool_input:$ti} + (if \$a == \"-\" then {} elif \$a == \"SINTIPO\" then {agent_id:\"a1\"} else {agent_id:\"a1\",agent_type:\$a} end)"; }
for enl in sin con; do
  if [ $enl = con ]; then for n in 5 5.5 true false 0 -1 1e3; do ln -sfn src/a.ts "$PQ/$n"; done; fi
  echo "##### enlaces en la raiz: $enl"
  for fp in 5 5.5 0 -1 1e3 true false null '[]' '["src/a.ts"]' '{}' '{"a":"src/a.ts"}' '"src/a.ts"' '"docs/x.md"' '""'; do
    for t in Edit Write MultiEdit; do
      for ag in - desarrollador arnes-juan:desarrollador qa-tester auditor-seguridad intruso SINTIPO; do
        j="$(mk $t "$fp" "$ag")"
        printf '%-4s %-9s fp=%-18s ag=%-26s' $enl $t "$fp" "$ag"
        for a in cand a599 v135; do printf ' | %s gc=%s' $a "$(pr $a guard-codigo.sh "$j")"; done
        printf ' | cand guard.sh=%s\n' "$(pr cand guard.sh "$j")"
      done
    done
  done
done
