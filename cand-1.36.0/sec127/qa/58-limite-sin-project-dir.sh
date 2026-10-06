#!/usr/bin/env bash
# QA-007-05: el límite escrito de CA-47 punto 20 sin CLAUDE_PROJECT_DIR, frente a lo medido. guard.sh, tres árboles,
# con el proceso FUERA del proyecto y DENTRO de él.
source /home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/sec127/qa/sonda-qa.sh; prep_proy
mkdir -p $S/fuera $PQ/sub; OBJ="{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Write\",\"cwd\":\"$PQ\",\"tool_input\":{\"file_path\":\"src/a.ts\",\"content\":\"x\"}}"
OBJD="{\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Write\",\"cwd\":\"$PQ\",\"tool_input\":{\"file_path\":\"docs/x.md\",\"content\":\"x\"}}"
ent() { case "$1" in
  objeto-legible-src)        printf '%s' "$OBJ";;
  objeto-legible-docs)       printf '%s' "$OBJD";;
  objeto+basura)             printf '%s xyz' "$OBJD";;
  objeto+NUL)                printf '%s\0{}' "$OBJD";;
  tool_input-numerico)       printf '{"tool_name":"Write","cwd":"%s","tool_input":5}' "$PQ";;
  dos-objetos)               printf '%s%s' "$OBJD" "$OBJD";;
  JSON-roto-sin-cwd)         printf '{"tool_name":"Wri';;
  JSON-roto-cwd-al-final)    printf '{"tool_name":"Write","cwd":"%s"' "$PQ";;
  cwd-sin-manifiesto)        printf '{"tool_name":"Write","cwd":"%s","tool_input":5}' "$S/fuera";;
  cwd-subdirectorio)         printf '{"tool_name":"Write","cwd":"%s/sub","tool_input":5}' "$PQ";;
  cwd-numerico)              printf '{"tool_name":"Write","cwd":5,"tool_input":5}';;
  vacia)                     printf '';;
esac; }
for donde in fuera proyecto; do
  d=$S/fuera; [ $donde = proyecto ] && d=$PQ
  for e in objeto-legible-src objeto-legible-docs objeto+basura objeto+NUL tool_input-numerico dos-objetos JSON-roto-sin-cwd JSON-roto-cwd-al-final cwd-sin-manifiesto cwd-subdirectorio cwd-numerico vacia cerrada directorio; do
    r=""; for a in cand 413c v135; do
      case $e in
        cerrada)    out="$(cd $d; unset CLAUDE_PROJECT_DIR; bash ${H[$a]}/guard.sh <&- 2>/dev/null)";;
        directorio) out="$(cd $d; unset CLAUDE_PROJECT_DIR; bash ${H[$a]}/guard.sh < $PQ/dirent 2>/dev/null)";;
        *)          out="$(cd $d; unset CLAUDE_PROJECT_DIR; ent $e | bash ${H[$a]}/guard.sh 2>/dev/null)";;
      esac; r+="$a=$(dec "$out" | cut -c1-38)  "; done
    printf 'proceso-%-9s %-24s %s\n' $donde $e "$r"
  done
done
