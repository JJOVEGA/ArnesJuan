#!/usr/bin/env bash
# bateria-r7.sh — QA-023-13 y los campos relacionados, a nivel de hook, en cuatro árboles
# (cd6afa6 = antes de esta reparación; 9596e39 y 1.33.2 = referencias; cand = el worktree).
# Uso: bash bateria-r7.sh   (imprime una línea por caso y el motivo de la candidata)
set -u
. "$(dirname "$0")/lib-r7.sh"
nuevo_proyecto
echo "== proyecto: $P   fuera: $F"
for k in "${ORDEN[@]}"; do printf '   %-8s lib.sh %s  guard-codigo %s  guard-completado %s\n' "$k" \
  "$(sha256sum < "${ARB[$k]}/lib.sh" | cut -c1-16)" "$(sha256sum < "${ARB[$k]}/guard-codigo.sh" | cut -c1-16)" \
  "$(sha256sum < "${ARB[$k]}/guard-completado.sh" | cut -c1-16)"; done

# --- El escenario de QA-023-13: `<fuera>/d␍` es un enlace a la raíz; `<fuera>/d` un directorio normal.
ln -s "$P" "$F/d$CR"; mkdir -p "$F/d"
# Variantes del CR en otras posiciones: en medio (`e␍f` -> raíz) y antes de un salto (`g␍␊h` -> raíz,
# con `g␊h` como directorio normal fuera).
ln -s "$P" "$F/e${CR}f"; ln -s "$P" "$F/g$CR${NL}h"; mkdir -p "$F/g${NL}h"
# Un `cwd` con CR final que NO existe recortado (para el motivo).
ln -s "$P" "$F/s$CR"

echo; echo "== A. El cwd con CR (QA-023-13) =="
fila "A1 coordinadora: echo x > src/a.ts, cwd <fuera>/d␍ (-> raíz)" guard-codigo.sh "$(j Bash "$F/d$CR" - 'command=echo x > src/a.ts')"
fila "A1g idem por guard.sh"                                          guard.sh        "$(j Bash "$F/d$CR" - 'command=echo x > src/a.ts')"
fila "A2 sed -i que cierra REQ-900 (rojo), cwd <fuera>/d␍"             guard-completado.sh "$(j Bash "$F/d$CR" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
fila "A2g idem por guard.sh"                                           guard.sh        "$(j Bash "$F/d$CR" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
fila "A3 coordinadora: echo x > src/a.ts, cwd <fuera>/e␍f (CR en medio)" guard.sh     "$(j Bash "$F/e${CR}f" - 'command=echo x > src/a.ts')"
fila "A4 coordinadora: echo x > src/a.ts, cwd <fuera>/g␍␊h (CR antes de LF)" guard.sh "$(j Bash "$F/g$CR${NL}h" - 'command=echo x > src/a.ts')"
fila "A5 coordinadora: echo x > src/a.ts, cwd <fuera>/s␍ (recortado no existe)" guard.sh "$(j Bash "$F/s$CR" - 'command=echo x > src/a.ts')"
fila "A6 Write de la coordinadora a src/a.ts RELATIVO, cwd <fuera>/d␍" guard.sh "$(j Write "$F/d$CR" - 'file_path=src/a.ts' content=x)"
fila "A7 Edit que cierra REQ-900 por ruta relativa, cwd <fuera>/d␍"   guard.sh "$(j Edit "$F/d$CR" - 'file_path=requirements/REQ-900.md' 'old_string=Estado: en-revisión' 'new_string=Estado: completado')"

echo; echo "== B. Controles con el mismo cwd con CR (lo que no depende de él) =="
fila "B1 coordinadora: Write ABSOLUTO a docs/n.md, cwd <fuera>/d␍"     guard.sh "$(j Write "$F/d$CR" - "file_path=$P/docs/n.md" content=x)"
fila "B2 coordinadora: Write ABSOLUTO a src/a.ts, cwd <fuera>/d␍"      guard.sh "$(j Write "$F/d$CR" - "file_path=$P/src/a.ts" content=x)"
fila "B3 Edit ABSOLUTO que cierra REQ-900 (rojo), cwd <fuera>/d␍"      guard.sh "$(j Edit "$F/d$CR" - "file_path=$P/requirements/REQ-900.md" 'old_string=Estado: en-revisión' 'new_string=Estado: completado')"
fila "B4 Edit ABSOLUTO que cierra REQ-901 (verde), cwd <fuera>/d␍"     guard.sh "$(j Edit "$F/d$CR" - "file_path=$P/requirements/REQ-901.md" 'old_string=Estado: en-revisión' 'new_string=Estado: completado')"
fila "B5 ls -la, cwd <fuera>/d␍"                                       guard.sh "$(j Bash "$F/d$CR" - 'command=ls -la')"
fila "B6 printf x > ABSOLUTO docs/n.md, cwd <fuera>/d␍"                guard.sh "$(j Bash "$F/d$CR" - "command=printf x > $P/docs/n.md")"
fila "B7 coordinadora: echo x > n.md RELATIVO, cwd <fuera>/d␍"         guard.sh "$(j Bash "$F/d$CR" - 'command=echo x > n.md')"
fila "B8 desarrollador: echo x > src/a.ts RELATIVO, cwd <fuera>/d␍"    guard.sh "$(j Bash "$F/d$CR" desarrollador 'command=echo x > src/a.ts')"
fila "B9 desarrollador: sed -i completado docs/x.md RELATIVO, cwd <fuera>/d␍" guard.sh "$(j Bash "$F/d$CR" desarrollador "command=sed -i 's/x/completado/' docs/x.md")"

echo; echo "== C. Controles sin CR (deciden como antes) =="
fila "C1 coordinadora: echo x > src/a.ts, cwd <raíz>"                  guard.sh "$(j Bash "$P" - 'command=echo x > src/a.ts')"
fila "C2 coordinadora: echo x > src/a.ts, cwd <fuera>/d (real fuera)"  guard.sh "$(j Bash "$F/d" - 'command=echo x > src/a.ts')"
fila "C3 sed -i cierra REQ-900, cwd <raíz>"                            guard.sh "$(j Bash "$P" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
fila "C4 coordinadora: echo x > n.md, cwd <raíz>/docs"                 guard.sh "$(j Bash "$P/docs" - 'command=echo x > n.md')"
fila "C5 Write ABSOLUTO a docs/n.md, cwd <raíz>"                       guard.sh "$(j Write "$P" - "file_path=$P/docs/n.md" content=x)"
fila "C6 cwd con LF /tmp␊b: Edit que cierra REQ-900"                   guard.sh "$(j Edit "/tmp${NL}b" - "file_path=$P/requirements/REQ-900.md" 'old_string=Estado: en-revisión' 'new_string=Estado: completado')"
fila "C7 cwd con LF /tmp␊b: Write a docs/n.md"                         guard.sh "$(j Write "/tmp${NL}b" - "file_path=$P/docs/n.md" content=x)"

echo; echo "== D. file_path con CR (punto 12 por coherencia) =="
ln -s ../src/a.ts "$P/docs/l$CR"                       # enlace DENTRO de la raíz, último componente con CR
ln -s "$P/src/a.ts" "$F/l$CR"                          # enlace FUERA de la raíz hacia código
cp "$P/requirements/REQ-900.md" "$P/requirements/REQ-901.md$CR"   # el REQ «con CR» está en ROJO; REQ-901.md en verde
fila "D1 coordinadora: Write <raíz>/docs/l␍ (enlace dentro -> src/a.ts)" guard.sh "$(j Write "$P" - "file_path=$P/docs/l$CR" content=x)"
fila "D2 coordinadora: Write <fuera>/l␍ (enlace fuera -> src/a.ts)"     guard.sh "$(j Write "$P" - "file_path=$F/l$CR" content=x)"
fila "D3 Edit que cierra <REQ-901.md␍> (rojo; REQ-901.md verde)"         guard-completado.sh "$(j Edit "$P" - "file_path=$P/requirements/REQ-901.md$CR" 'old_string=Estado: en-revisión' 'new_string=Estado: completado')"
fila "D3g idem por guard.sh"                                             guard.sh "$(j Edit "$P" - "file_path=$P/requirements/REQ-901.md$CR" 'old_string=Estado: en-revisión' 'new_string=Estado: completado')"
fila "D4 coordinadora: Write <raíz>/src/a.ts␍"                           guard.sh "$(j Write "$P" - "file_path=$P/src/a.ts$CR" content=x)"
fila "D5 coordinadora: Write <raíz>/docs/n.md␍ (fuera del ámbito)"       guard.sh "$(j Write "$P" - "file_path=$P/docs/n.md$CR" content=x)"
fila "D6 coordinadora: Write <raíz>/docs/n␍x.md (CR en medio)"           guard.sh "$(j Write "$P" - "file_path=$P/docs/n${CR}x.md" content=x)"
fila "D7 desarrollador: Write <raíz>/src/a.ts␍"                          guard.sh "$(j Write "$P" desarrollador "file_path=$P/src/a.ts$CR" content=x)"
fila "D8 Bash con file_path con CR (ninguna puerta lo juzga): ls"        guard.sh "$(j Bash "$P" - 'command=ls' "file_path=$P/src/a.ts$CR")"

echo; echo "== T. tool_name con CR (punto 13 por coherencia) =="
fila "T1 coordinadora: Bash␍ con ls y file_path src/a.ts"               guard-codigo.sh "$(j "Bash$CR" "$P" - 'command=ls' "file_path=$P/src/a.ts")"
fila "T1g idem por guard.sh"                                             guard.sh "$(j "Bash$CR" "$P" - 'command=ls' "file_path=$P/src/a.ts")"
fila "T2 coordinadora: Write␍ a src/a.ts"                                guard.sh "$(j "Write$CR" "$P" - "file_path=$P/src/a.ts" content=x)"
fila "T3 coordinadora: Edit␍ que cierra REQ-900"                         guard.sh "$(j "Edit$CR" "$P" - "file_path=$P/requirements/REQ-900.md" 'old_string=Estado: en-revisión' 'new_string=Estado: completado')"
fila "T4 coordinadora: Bash␍ con echo x > src/a.ts"                      guard.sh "$(j "Bash$CR" "$P" - 'command=echo x > src/a.ts')"
fila "T5 desarrollador: Write␍ a src/a.ts"                               guard.sh "$(j "Write$CR" "$P" desarrollador "file_path=$P/src/a.ts" content=x)"
fila "T6 coordinadora: B␍ash con ls (CR en medio)"                       guard.sh "$(j "B${CR}ash" "$P" - 'command=ls')"

echo; echo "== G. Campos del agente con CR =="
fila "G1 agent_type desarrollador␍ escribe src/a.ts"                    guard.sh "$(j Write "$P" "desarrollador$CR" "file_path=$P/src/a.ts" content=x)"
fila "G2 agent_type qa-tester␍ escribe src/a.ts"                        guard.sh "$(j Write "$P" "qa-tester$CR" "file_path=$P/src/a.ts" content=x)"
fila "G3 agent_id ␍ (solo CR), agent_type desarrollador, escribe src/a.ts" guard.sh \
  "$(jq -cn --arg c "$P" --arg f "$P/src/a.ts" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,agent_id:"\r",agent_type:"desarrollador",tool_input:{file_path:$f,content:"x"}}')"
fila "G4 agent_id ␍ (solo CR), agent_type qa-tester, escribe src/a.ts"    guard.sh \
  "$(jq -cn --arg c "$P" --arg f "$P/src/a.ts" '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,agent_id:"\r",agent_type:"qa-tester",tool_input:{file_path:$f,content:"x"}}')"
fila "G5 agent_type desarrollador␍␊qa escribe src/a.ts"                 guard.sh "$(j Write "$P" "desarrollador$CR${NL}qa" "file_path=$P/src/a.ts" content=x)"

echo; echo "== K. command de Bash con CR (solo se ANOTA; el analizador no se toca) =="
ln -s ../src/a.ts "$P/docs/k$CR"                       # enlace dentro de docs/ con CR final -> código
fila "K1 coordinadora: printf x > k␍ (CR final del command), cwd <raíz>/docs" guard.sh "$(j Bash "$P/docs" - "command=printf x > k$CR")"
fila "K2 coordinadora: printf x > k␍␊true, cwd <raíz>/docs"             guard.sh "$(j Bash "$P/docs" - "command=printf x > k$CR${NL}true")"
fila "K3 coordinadora: printf x > src/a.ts␍ (CR final), cwd <raíz>"      guard.sh "$(j Bash "$P" - "command=printf x > src/a.ts$CR")"

echo; echo "== Efecto en disco que el hook juzga (shell real, en una copia aparte) =="
nuevo_proyecto; ln -s "$P" "$F/d$CR"; mkdir -p "$F/d"; h0="$(sha256sum < "$P/src/a.ts" | cut -c1-16)"
( cd "$F/d$CR" && echo ESCRITO > src/a.ts ) 2>&1
printf '   cd "<fuera>/d␍" && echo ESCRITO > src/a.ts  ->  <raíz>/src/a.ts antes %s, despues %s, contenido "%s"; <fuera>/d/src/a.ts existe: %s\n' \
  "$h0" "$(sha256sum < "$P/src/a.ts" | cut -c1-16)" "$(cat "$P/src/a.ts")" "$( [ -e "$F/d/src/a.ts" ] && echo si || echo no)"
ln -s ../src/a.ts "$P/docs/k$CR"; ( cd "$P/docs" && printf 'K\n' > "k$CR" ); printf '   printf K > k␍ desde docs/  ->  <raíz>/src/a.ts contiene "%s"\n' "$(cat "$P/src/a.ts")"
