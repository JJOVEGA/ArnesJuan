# Rutas no canonicas (QA-023-07 y su clase): guard-completado y guard-codigo, a nivel de hook.
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2/lib-sonda.sh
S0='Estado: en-revisión'; C='Estado: completado'
doc "$S0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: (ninguno)' 'Rigor: critico'
rm -rf $P/lnk $P/docs/lnk /tmp/claude-1000/lnk-arnes-sec; ln -s $P/requirements $P/lnk; ln -s $P/requirements /tmp/claude-1000/lnk-arnes-sec
FP=$F caso "RC0 control: ruta canonica" jedit "$S0" "$C"
FP=$P/docs/../requirements/REQ-900.md caso "RC1 '<raiz>/docs/../requirements/'" jedit "$S0" "$C"
FP=$P/././requirements/REQ-900.md caso "RC2 '<raiz>/././requirements/'" jedit "$S0" "$C"
FP=$P/lnk/REQ-900.md caso "RC3 directorio enlazado dentro del proyecto" jedit "$S0" "$C"
FP=/tmp/claude-1000/lnk-arnes-sec/REQ-900.md caso "RC4 directorio enlazado fuera del proyecto" jedit "$S0" "$C"
FP=$P/requirements/./REQ-900.md caso "RC5 '<raiz>/requirements/./' (control: casa el glob)" jedit "$S0" "$C"
echo "## guard-codigo (coordinadora escribe src/a.ts)"
unset DOC; DOC='x'
gc() { local id="$1" fp="$2" j h d; j=$(jq -cn --arg f "$fp" --arg p "$P" '{tool_name:"Write",cwd:$p,agent_type:"",tool_input:{file_path:$f,content:"y"}}')
  for h in "$CAND" "$BASE"; do juzga "$h" "$j"; d+="$(basename $(dirname $h))=$DEC "; done; printf '%-58s %s\n' "$id" "$d"; }
gc "GC0 control: <raiz>/src/a.ts" $P/src/a.ts
gc "GC1 <raiz>/docs/../src/a.ts" $P/docs/../src/a.ts
gc "GC2 <raiz>/././src/a.ts" $P/././src/a.ts
ln -sfn $P/src $P/lsrc; gc "GC3 directorio enlazado a src/" $P/lsrc/a.ts
