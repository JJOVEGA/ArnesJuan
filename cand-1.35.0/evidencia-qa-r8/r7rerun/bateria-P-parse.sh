#!/usr/bin/env bash
# Batería P (QA r7, reutilizada de r6 con la clase CWD-CR-vaciado): arnes_parse_input contra la verdad de jq, campo a campo, con entradas hostiles.
# Para cada entrada compara los seis campos que deja la biblioteca con el valor que jq lee del JSON
# (el mismo `// ""` y `tostring`; `cwd` no cadena -> ""). Una diferencia se clasifica:
#   CR-transporte = sólo difiere en un CR que precede a un LF o cierra el campo (declarado en CA-47 p.11)
#   NUL           = bash no puede guardar NUL (preexistente, fuera de la lectura por campos)
#   FINAL-LF-cmd  = el último campo pierde sus LF finales (declarado en CA-47 p.11)
#   OTRA          = cualquier otra: sería un desplazamiento, truncamiento o sustitución no declarada
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8/r7rerun/qa-lib-r8.sh
campos_lib() {   # <hooks> <json> -> seis líneas, cada campo en JSON (jq -Rs), de la biblioteca
  ( . "$1/lib.sh" 2>/dev/null; ARNES_INPUT="$2"; ARNES_INPUT_LISTO=''; arnes_parse_input 2>/dev/null
    for v in "$ARNES_TOOL" "$ARNES_AGENT_ID" "$ARNES_AGENT_TYPE" "${ARNES_CWD-}" "$ARNES_FP" "$ARNES_CMD"; do
      printf '%s' "$v" | jq -Rsc .; done )
}
campos_jq() {   # <json> -> seis líneas, la verdad de jq
  jq -c '[.tool_name // "", .agent_id // "", .agent_type // "",
          (.cwd // "" | if type == "string" then . else "" end),
          .tool_input.file_path // "", .tool_input.command // ""] | map(tostring) | .[]' <<< "$1" 2>/dev/null
}
NOMBRES=(tool_name agent_id agent_type cwd file_path command)
clasif() {   # <jq json> <lib json> -> clase
  local v l
  v="$(jq -r . <<< "$1")"; l="$(jq -r . <<< "$2")"   # jq -r añade \n; ambos igual
  v="$(jq -j . <<< "$1"; printf X)"; v="${v%X}"; l="$(jq -j . <<< "$2"; printf X)"; l="${l%X}"
  if [ "${v//$'\r\n'/$'\n'}" = "$l" ] || [ "${v%$'\r'}" = "$l" ] || [ "$(printf '%s' "${v//$'\r\n'/$'\n'}")" = "$l" ] \
     || { t="${v//$'\r\n'/$'\n'}"; [ "${t%$'\r'}" = "$l" ]; }; then echo CR-transporte; return; fi
  case "$v" in *$'\x01'*) ;; esac
  if [ "${v//$'\n'/}" != "$v" ] && [ "${v%"${v##*[!$'\n']}"}" = "$l" ]; then echo FINAL-LF-cmd; return; fi
  echo OTRA
}
caso() {   # <id> <json>
  local id="$1" json="$2" i a b c43 out='' cl
  mapfile -t VJ < <(campos_jq "$json")
  mapfile -t VL < <(campos_lib "$CAND" "$json")
  mapfile -t V4 < <(campos_lib "$CD6" "$json")
  if [ "${#VJ[@]}" -ne 6 ]; then printf '%-44s jq no lee la entrada (%d campos) | cand: %s\n' "$id" "${#VJ[@]}" "$(printf '%s,' "${VL[@]}")"; return; fi
  local dif=0 d43=0
  for i in 0 1 2 3 4 5; do
    if [ "${VJ[i]}" != "${VL[i]}" ]; then
      cl="$(clasif "${VJ[i]}" "${VL[i]}")"
      if [ "$i" = 3 ] && [ "${VL[i]}" = '""' ] && [[ "$(jq -j . <<< "${VJ[i]}")" == *$'\r'* ]]; then cl=CWD-CR-vaciado; fi
      [ "$i" = 5 ] || [ "$cl" != FINAL-LF-cmd ] || cl=OTRA
      out+=" ${NOMBRES[i]}:$cl jq=${VJ[i]} lib=${VL[i]}"; dif=1
    fi
    [ "${VJ[i]}" = "${V4[i]}" ] || d43=1
  done
  if [ "$dif" = 0 ]; then printf '%-44s cand=IGUAL a jq en los seis      cd6afa6=%s\n' "$id" "$([ $d43 = 0 ] && echo igual || echo DIFIERE)"
  else printf '%-44s cand=DIFIERE%s      cd6afa6=%s\n' "$id" "$out" "$([ $d43 = 0 ] && echo igual || echo DIFIERE)"; fi
}
J() { jq -cn "$@"; }
echo "== Batería P: arnes_parse_input frente a jq, campo a campo ($(date -Iseconds)) =="
caso P01-todo-normal          "$(J '{tool_name:"Write",agent_id:"a1",agent_type:"qa-tester",cwd:"/tmp",tool_input:{file_path:"/x/y",command:"ls"}}')"
caso P02-LF-en-cada-campo     "$(J '{tool_name:"W\nr",agent_id:"a\n1",agent_type:"q\na",cwd:"/t\nm",tool_input:{file_path:"/x\ny",command:"l\ns"}}')"
caso P03-LF-al-inicio         "$(J '{tool_name:"\nW",agent_id:"\na",agent_type:"\nq",cwd:"\n/t",tool_input:{file_path:"\n/x",command:"\nls"}}')"
caso P04-LF-al-final          "$(J '{tool_name:"W\n",agent_id:"a\n",agent_type:"q\n",cwd:"/t\n",tool_input:{file_path:"/x\n",command:"ls"}}')"
caso P05-solo-LF              "$(J '{tool_name:"\n",agent_id:"\n\n",agent_type:"\n\n\n",cwd:"\n\n\n\n",tool_input:{file_path:"\n\n\n\n\n",command:"\n"}}')"
caso P06-LF-consecutivos      "$(J '{tool_name:"Bash",cwd:"/a\n\n\nb",tool_input:{file_path:"x\n\n\n\n\ny",command:"a\n\n\nb"}}')"
caso P07-vacios               "$(J '{tool_name:"",agent_id:"",agent_type:"",cwd:"",tool_input:{file_path:"",command:""}}')"
caso P08-ausentes             "$(J '{}')"
caso P09-nulls                "$(J '{tool_name:null,agent_id:null,agent_type:null,cwd:null,tool_input:{file_path:null,command:null}}')"
caso P10-tool_input-null      "$(J '{tool_name:"Write",tool_input:null,cwd:"/t\nx"}')"
caso P11-numeros              "$(J '{tool_name:12,agent_id:3,agent_type:4.5,cwd:7,tool_input:{file_path:8,command:9}}')"
caso P12-booleanos            "$(J '{tool_name:true,agent_id:false,agent_type:true,cwd:true,tool_input:{file_path:true,command:false}}')"
caso P13-arrays-con-LF        "$(J '{tool_name:["Wr\nite"],agent_id:["a"],agent_type:["q\nx"],cwd:["/t\nm"],tool_input:{file_path:["/x\ny","z"],command:["l\ns"]}}')"
caso P14-objetos-con-LF       "$(J '{tool_name:{"a":"B\nash"},agent_type:{"x":"d\ne"},cwd:{"c":"/t"},tool_input:{file_path:{"p":"src/a.ts\n"},command:{"c":"x\ny"}}}')"
caso P15-CR-solo              "$(J '{tool_name:"W\rr",agent_id:"a\r1",agent_type:"q\ra",cwd:"/t\rm",tool_input:{file_path:"/x\ry",command:"l\rs"}}')"
caso P16-CR-final             "$(J '{tool_name:"Write\r",agent_id:"a\r",agent_type:"q\r",cwd:"/t\r",tool_input:{file_path:"/x\r",command:"ls\r"}}')"
caso P17-CRLF-dentro          "$(J '{tool_name:"W\r\nr",agent_id:"a\r\n1",agent_type:"q\r\na",cwd:"/t\r\nm",tool_input:{file_path:"/x\r\ny",command:"l\r\ns"}}')"
caso P18-CR-final-fp-cmd-vacio "$(J '{tool_name:"Write",cwd:"/t",tool_input:{file_path:"/x\r",command:""}}')"
caso P19-doble-CR-final       "$(J '{tool_name:"Write",cwd:"/t\r\r",tool_input:{file_path:"/x\r\r",command:"ls\r\r"}}')"
caso P20-unicode              "$(J '{tool_name:"Wríte",agent_type:"désarrollador",cwd:"/tmp/ñ😀",tool_input:{file_path:"/x/ü v\u0085w",command:"echo ñ"}}')"
caso P21-NUL                  "$(J '{tool_name:"Wr\u0000ite",cwd:"/t\u0000m",tool_input:{file_path:"/x\u0000y",command:"l\u0000s"}}')"
caso P22-parece-contador      "$(J '{tool_name:"9 9 9 9 9",agent_id:"0 0 0 0 0",agent_type:"-1 x",cwd:"5\n5",tool_input:{file_path:"1 1 1 1 1\n2",command:"3 3"}}')"
caso P23-tabs-espacios        "$(J '{tool_name:" Write ",agent_id:"\ta",agent_type:"q ",cwd:" /t ",tool_input:{file_path:"\t/x\t",command:"  ls  "}}')"
caso P24-cmd-multilinea-LF-final "$(J '{tool_name:"Bash",cwd:"/a\nb",tool_input:{command:"echo a\necho b > c\n\n\n"}}')"
caso P25-fp-LF-final-cmd-vacio "$(J '{tool_name:"Write",cwd:"/a",tool_input:{file_path:"/x\n\n",command:""}}')"
caso P26-cwd-LF-todo-vacio-despues "$(J '{tool_name:"Write",cwd:"/a\n\n"}')"
caso P27-backslash-n-literal  "$(J '{tool_name:"Write",cwd:"/a\\nb",tool_input:{file_path:"/x\\ny"}}')"
caso P28-claves-duplicadas    '{"tool_name":"Bash","tool_name":"Write","cwd":"/a\nb","cwd":"/c","tool_input":{"file_path":"/x"}}'
caso P29-texto-largo-1MB-una-linea "$(jq -cn --arg c "$(head -c 1000000 /dev/zero | tr '\0' a)" '{tool_name:"Bash",cwd:"/t",tool_input:{command:$c}}')"
echo "== entradas que jq no lee o que no son un objeto =="
caso P30-truncada             '{"tool_name":"Write","cwd":"/t'
caso P31-array                '[{"tool_name":"Write"}]'
caso P32-cadena               '"Write"'
caso P33-numero               '42'
caso P34-tool_input-cadena    '{"tool_name":"Write","tool_input":"x"}'
caso P35-dos-objetos          '{"tool_name":"Bash","tool_input":{"command":"ls"}}{"tool_name":"Write","tool_input":{"file_path":"/x/src/a.ts"}}'
caso P36-null                 'null'
