#!/usr/bin/env bash
# t5 — La continuación de línea (`\` + salto, SIN retorno de carro) en el detector de escrituras. Ajeno al delta:
# se mide para saber si es preexistente y en qué formas. Decisión del hook y efecto real del shell.
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/lib-sonda8.sh
proyecto_nuevo "$S/p5"
declare -a NOM CMD
add() { NOM+=("$1"); CMD+=("$2"); }
NL=$'\n'
add "C1 echo x > \\<LF>src/a.ts" "echo C1 > \\${NL}src/a.ts"
add "C2 echo x >\\<LF>src/a.ts" "echo C2 >\\${NL}src/a.ts"
add "C3 echo x \\<LF>> src/a.ts" "echo C3 \\${NL}> src/a.ts"
add "C4 cp /etc/hostname \\<LF>src/a.ts" "cp /etc/hostname \\${NL}src/a.ts"
add "C5 tee \\<LF>src/a.ts < /dev/null" "tee \\${NL}src/a.ts < /dev/null"
add "C6 sed -i 's/…/completado/' \\<LF>requirements/REQ-900.md" "sed -i 's/en-revisión/completado/' \\${NL}requirements/REQ-900.md"
add "C7 sed -i \\<LF>'s/…/completado/' requirements/REQ-900.md" "sed -i \\${NL}'s/en-revisión/completado/' requirements/REQ-900.md"
add "C8 echo x > src/\\<LF>a.ts (corta el nombre)" "echo C8 > src/\\${NL}a.ts"
add "C9 control: echo x > src/a.ts en una línea" "echo C9 > src/a.ts"
for i in "${!NOM[@]}"; do j_bash "${CMD[i]}"; fila "${NOM[i]}" "$J"; done
echo "== Efecto real del shell, árbol aparte =="
T="$S/efe5"
for i in "${!NOM[@]}"; do
  proyecto_nuevo "$T"; ( cd "$T" && bash -c "${CMD[i]}" ) >/dev/null 2>&1
  printf '%-58s src/a.ts=%s | REQ-900 l2=%s\n' "${NOM[i]:0:58}" "$(tr '\n' '|' < "$T/src/a.ts")" "$(sed -n 2p "$T/requirements/REQ-900.md")"
done
rm -rf "$T"
