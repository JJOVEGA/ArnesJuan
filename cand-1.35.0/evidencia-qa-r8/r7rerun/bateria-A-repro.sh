#!/usr/bin/env bash
# Batería A — la reproducción de QA-023-13 (evidencia-qa-r6/27-), antes (cd6afa6) y después (candidato),
# en guard-codigo, guard-completado y guard.sh; el motivo; qué ruta juzga la puerta; y el efecto real del shell.
source /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-r8/r7rerun/qa-lib-r8.sh
PRJ=$Q/proj-a; FUERA=$Q/fuera-a
rm -rf "$PRJ" "$FUERA"; mkproj "$PRJ"; mkdir -p "$FUERA"
req "$PRJ/requirements/REQ-900.md"
ln -s "$PRJ" "$FUERA/d$CR"; mkdir -p "$FUERA/d"            # d␍ -> raíz ; d = dir normal fuera
mkdir -p "$FUERA/r"; ln -s "$PRJ" "$FUERA/r-alias"          # para la variante inversa, abajo
echo "== Batería A — QA-023-13, la reproducción original antes y después ($(date -Iseconds)) =="
echo "-- 0. Qué hace el shell desde ese cwd (árbol aparte, efecto real):"
T=$Q/sh-a; rm -rf "$T"; mkdir -p "$T/root/src" "$T/x"; ln -s "$T/root" "$T/x/d$CR"; mkdir -p "$T/x/d"
( cd "$T/x/d$CR" && printf 'ESCRITO-EN-CODIGO\n' > src/a.ts )
printf '   cd "x/d<CR>" && printf > src/a.ts  =>  root/src/a.ts: %s ; x/d/src/a.ts existe: %s\n' \
  "$(cat "$T/root/src/a.ts" 2>/dev/null || echo 'no')" "$([ -e "$T/x/d/src/a.ts" ] && echo SI || echo no)"
echo
echo "-- 1. guard-codigo (coordinadora, echo x > src/a.ts, cwd=FUERA/d<CR>)"
J1="$(j Bash "$FUERA/d$CR" - 'command=echo x > src/a.ts')"
quad "A1 guard-codigo.sh"   guard-codigo.sh "$J1"
quad "A1g guard.sh"          guard.sh "$J1"
echo "-- 2. guard-completado (sed -i que cierra REQ-900 en rojo, cwd=FUERA/d<CR>)"
J2="$(j Bash "$FUERA/d$CR" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
quad "A2 guard-completado.sh" guard-completado.sh "$J2"
quad "A2g guard.sh"           guard.sh "$J2"
echo "-- 3. el mismo caso por Edit con ruta relativa (R3) y por Write relativo de la coordinadora a src/a.ts"
quad "A3 Edit relativo cierra REQ-900 [guard-completado]" guard-completado.sh "$(cierre "$FUERA/d$CR" requirements/REQ-900.md)"
quad "A3g idem guard.sh" guard.sh "$(cierre "$FUERA/d$CR" requirements/REQ-900.md)"
quad "A4 Write relativo src/a.ts coordinadora [guard-codigo]" guard-codigo.sh "$(j Write "$FUERA/d$CR" - file_path=src/a.ts content=x)"
echo
echo "-- 4. QUÉ RUTA JUZGA LA PUERTA (biblioteca de cada árbol, misma entrada J1):"
for k in CAND CD6; do
  d="${!k}"
  ( . "$d/lib.sh"; ARNES_INPUT="$J1"; ARNES_INPUT_LISTO=''; arnes_parse_input
    CLAUDE_PROJECT_DIR="$PRJ"; ARNES_PROJ="$PRJ"; ARNES_MANIFEST="$PRJ/.arnes/config.json"
    declare -p ARNES_CWD ARNES_CWD_CR 2>/dev/null | tr '\n' ' ' | sed "s/^/   $k: /"; echo
    if declare -F arnes_identidad >/dev/null; then
      arnes_parse_manifest 2>/dev/null; arnes_identidad src/a.ts
      printf '   %s: identidad de src/a.ts -> E=%s  F(física)=%q  C=%q\n' "$k" "$ARNES_ID_E" "$ARNES_ID_F" "${ARNES_ID_C:0:120}"
    fi )
done
echo
echo "-- 5. VARIANTE INVERSA (no decide sobre otra ruta, en la dirección contraria): FUERA2/d<CR> es un dir"
echo "      normal fuera y FUERA2/d (el recortado) es un ENLACE a la raíz. El shell escribe FUERA, no código."
FUERA2=$Q/fuera-a2; rm -rf "$FUERA2"; mkdir -p "$FUERA2/d$CR/src"; ln -s "$PRJ" "$FUERA2/d"
( cd "$FUERA2/d$CR" && printf 'FUERA\n' > src/a.ts ); printf '   shell: FUERA2/d<CR>/src/a.ts = %s ; raíz/src/a.ts = %s\n' "$(cat "$FUERA2/d$CR/src/a.ts")" "$(cat "$PRJ/src/a.ts")"
quad "A5 coordinadora echo x > src/a.ts, cwd=FUERA2/d<CR> (designa algo FUERA)" guard.sh "$(j Bash "$FUERA2/d$CR" - 'command=echo x > src/a.ts')"
echo "   (cd6afa6 deniega 'src/a.ts' juzgando <FUERA2>/d -> raíz: OTRA ruta; el candidato no la juzga: no determinable)"
echo
echo "-- 6. CONTROLES SIN CR, mismo proyecto"
quad "A6 echo x > src/a.ts, cwd=raíz" guard.sh "$(j Bash "$PRJ" - 'command=echo x > src/a.ts')"
quad "A7 echo x > src/a.ts, cwd=FUERA/d (dir normal: designa FUERA/d/src/a.ts, L8)" guard.sh "$(j Bash "$FUERA/d" - 'command=echo x > src/a.ts')"
quad "A8 sed -i cierra REQ-900, cwd=raíz" guard.sh "$(j Bash "$PRJ" - "command=sed -i 's/en-revisión/completado/' requirements/REQ-900.md")"
echo "-- 7. sha de REQ-900 y src/a.ts sin cambio (las puertas no escriben): $(sha256sum "$PRJ/requirements/REQ-900.md" | cut -c1-16) $(cat "$PRJ/src/a.ts")"
