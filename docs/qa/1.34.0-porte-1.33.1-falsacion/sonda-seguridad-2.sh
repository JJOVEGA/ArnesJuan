. "$S/falsa.sh"
edra() { jq -n --arg fp "$1" --arg os "$2" --arg ns "$3" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:$os,new_string:$ns,replace_all:true}}'; }
r() { printf '  %-58s -> %s\n' "$1" "$(veredicto "$2")"; }
# REQ cuyo UNICO 'pendiente' es el de Seguridad
mk() { local f="$PROJ/requirements/$1.md"
  printf '# %s\nEstado: en-revisión\nSensible a seguridad: no\nQA: con-hallazgos\nSeguridad: pendiente\nRigor: estandar\n\n## Cuerpo\ntexto\n' "$1" > "$f"; echo "$f"; }
f="$(mk B1)"; r "B2' Edit SOLO el valor (unico 'pendiente')"        "$(ed "$f" 'pendiente' 'aprobado')"
f="$(mk B2)"; r "B3' Edit SOLO el valor con replace_all"            "$(edra "$f" 'pendiente' 'aprobado')"
f="$(mk B3)"; sed -i 's/$/\r/' "$f"; r "H'  disk CRLF; Edit SOLO el valor"  "$(ed "$f" 'pendiente' 'aprobado')"
f="$(mk B4)"; r "I'  old_string INEXISTENTE, new firma (disk=pend)" "$(ed "$f" 'ZZZ-no-existe' 'Seguridad: aprobado')"
f="$(mk B5)"; r "T1 valor con espacio final anadido"                "$(ed "$f" 'Seguridad: pendiente' 'Seguridad: aprobado   ')"
f="$(mk B6)"; r "T2 valor en MAYUSCULAS"                            "$(ed "$f" 'Seguridad: pendiente' 'Seguridad: APROBADO')"
f="$(mk B7)"; r "T3 valor decorado **aprobado**"                     "$(ed "$f" 'Seguridad: pendiente' 'Seguridad: **aprobado**')"
f="$(mk B8)"; r "T4 clave con espacio antes de los dos puntos"       "$(ed "$f" 'Seguridad: pendiente' 'Seguridad : aprobado')"
f="$(mk B9)"; r "T5 firma dentro de comentario <!-- -->"             "$(ed "$f" 'Seguridad: pendiente' '<!-- Seguridad: aprobado -->')"
f="$(mk C1)"; r "T6 inserta 2a linea Seguridad: aprobado DESPUES"    "$(ed "$f" 'Seguridad: pendiente' 'Seguridad: pendiente
Seguridad: aprobado')"
f="$(mk C2)"; r "T7 inserta 2a linea Seguridad: aprobado ANTES"      "$(ed "$f" 'Seguridad: pendiente' 'Seguridad: aprobado
Seguridad: pendiente')"
f="$(mk C3)"; r "T8 mueve la firma al cuerpo y aprueba alli"         "$(ed "$f" 'Seguridad: pendiente' '')"
