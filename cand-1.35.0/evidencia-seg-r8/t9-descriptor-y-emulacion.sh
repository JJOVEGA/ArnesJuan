#!/usr/bin/env bash
# t9 — (1) QA-023-17: enlace del último componente hacia un descriptor, dentro y fuera del ámbito.
#      (2) Emulación de la vía de transporte de Windows: un `jq` envoltorio que añade un CR a cada línea de su
#          salida (como el jq de Windows en modo texto). EMULACIÓN EN LINUX, no medición en Windows (F6).
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/lib-sonda8.sh
proyecto_nuevo "$S/p9"
ln -s /dev/stderr "$P/src/log"; ln -s /dev/stderr "$P/docs/err"; ln -s /proc/self/fd/1 "$P/requirements/out"
ln -s ../src/a.ts "$P/docs/k$CR"
printf 'x\n' > "$S/ct.txt"
echo "== (1) QA-023-17 =="
j_bash "echo x > src/log"; fila "D1 echo > src/log (-> /dev/stderr), coordinadora" "$J"
j_bash "echo completado > requirements/out"; fila "D2 echo completado > requirements/out (-> fd/1)" "$J"
j_bash "echo x > docs/err"; fila "D3 echo > docs/err (fuera del ámbito, allow)" "$J"
j_bash "echo x > src/log" "$P" desarrollador; fila "D4 D1 por el desarrollador (allow)" "$J"
j_write "$P/src/log" "$S/ct.txt"; fila "D5 Write src/log (enlace dentro: CA-49 (i))" "$J"
echo "== (2) Emulación del transporte de Windows (jq que añade CR a cada línea) =="
W="$S/jqcr"; mkdir -p "$W"; JQREAL="$(command -v jq)"
printf '#!/usr/bin/env bash\n"%s" "$@" | sed '"'"'s/$/\\r/'"'"'\nexit ${PIPESTATUS[0]}\n' "$JQREAL" > "$W/jq"; chmod +x "$W/jq"
printf 'comprobación del envoltorio: '; printf '{"a":"x"}' | "$W/jq" -r .a | od -c | head -1
declare -a NOM CMDJ
emu() {  # <nombre> : usa el $J ya escrito; compara candidato con jq real y con jq-CR
  local a=cand d1 d2
  juzga cand "$J"; d1="$DEC"
  DEC=''; out="$(cd "$P" && PATH="$W:$PATH" CLAUDE_PROJECT_DIR="$P" timeout 60 bash "$S/arb/cand/hooks/guard.sh" < "$J" 2>/dev/null)"
  case "$out" in *'"permissionDecision":"deny"'*) d2=deny ;; '') d2=allow ;; *) d2="otra:${out:0:40}" ;; esac
  printf '%-58s linux=%s  emul-win=%s %s\n' "$1" "$d1" "$d2" "$([ "$d1" = "$d2" ] && echo '' || echo '<-- DIFIERE')"
}
j_bash "printf x > docs/k$CR"; emu "W1 printf > docs/k<CR> (enlace a src/a.ts)"
j_bash "printf x > docs/n.md$CR"; emu "W2 printf > docs/n.md<CR> (allow)"
j_bash "cat > src/a.ts <<'EOF'$CR"$'\n'"x$CR"$'\n'"EOF$CR"$'\n'; emu "W3 heredoc delimitador con CR"
j_bash "git stash$CR"; emu "W4 git stash<CR>"
j_bash "echo x > src/a.ts"; emu "W5 echo > src/a.ts (control)"
j_bash "ls -la"; emu "W6 ls -la (allow)"
j_edit "$P/requirements/REQ-900.md" "Estado: en-revisión" "Estado: completado"; emu "W7 Edit canónico cierra REQ rojo"
j_edit "$P/requirements/REQ-901.md" "Estado: en-revisión" "Estado: completado"; emu "W8 Edit cierra REQ verde (allow)"
j_write "$P/src/a.ts" "$S/ct.txt"; emu "W9 Write src/a.ts coordinadora"
j_bash "echo x > src/a.ts" "$P$CR"; emu "W10 cwd con CR, relativa"
j_bash "cat <<EOF > docs/x.md"$'\n'"x"$'\n'"EOF$CR"$'\n'"echo y > src/a.ts"$'\n'"EOF"$'\n'; emu "W11 = E1 (cuerpo 'EOF<CR>')"
j_bash "echo hola > /dev/stderr"; emu "W12 > /dev/stderr (allow)"
