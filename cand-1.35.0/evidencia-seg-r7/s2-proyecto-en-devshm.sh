#!/usr/bin/env bash
# s2 — un PROYECTO que vive bajo /dev/shm: ¿la exclusión de F3 apaga SEC-004 / CA-49 (i) y la identidad?
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev/lib-sonda.sh
PD="/dev/shm/arnes-r046-proj-$$"
proyecto_nuevo "$PD"
trap 'rm -rf "$PD"' EXIT
ln -s ../requirements/REQ-900.md "$P/docs/enlace.md"        # enlace en el ÚLTIMO componente, dentro
ln -s ../requirements "$P/docs/dreq"                           # directorio enlazado, dentro
ln -s ../src/a.ts "$P/docs/a-enlace.ts"
ln -s ../src "$P/docs/dsrc"
printf 'x\n' > "$S/ct.txt"
echo "proyecto=$P"
echo "== controles canónicos =="
j_edit "$P/requirements/REQ-900.md" "Estado: en-revisión" "Estado: completado"; fila "P0 Edit canónico cierra REQ rojo" "$J"
j_write "$P/src/a.ts" "$S/ct.txt"; fila "P0b Write canónico src/a.ts" "$J"
echo "== SEC-004 / CA-49 (i): enlace en el último componente, dentro del proyecto =="
j_edit "$P/docs/enlace.md" "Estado: en-revisión" "Estado: completado"; fila "P1 Edit por docs/enlace.md -> REQ-900 (cierra)" "$J"
j_edit "$P/docs/enlace.md" "texto" "texto2"; fila "P1b Edit por docs/enlace.md (no cierra)" "$J"
j_write "$P/docs/a-enlace.ts" "$S/ct.txt"; fila "P2 Write por docs/a-enlace.ts -> src/a.ts" "$J"
echo "== SEC-119: directorio enlazado dentro =="
j_edit "$P/docs/dreq/REQ-900.md" "Estado: en-revisión" "Estado: completado"; fila "P3 Edit por docs/dreq/REQ-900.md" "$J"
j_write "$P/docs/dsrc/a.ts" "$S/ct.txt"; fila "P4 Write por docs/dsrc/a.ts" "$J"
j_bash "echo x > docs/dsrc/a.ts"; fila "P5 echo > docs/dsrc/a.ts" "$J"
j_bash "sed -i 's/en-revisión/completado/' docs/dreq/REQ-900.md"; fila "P6 sed -i docs/dreq/REQ-900.md" "$J"
echo "== el mismo proyecto fuera de /dev (control: la diferencia es el prefijo) =="
proyecto_nuevo "$S/p2"
ln -s ../requirements/REQ-900.md "$P/docs/enlace.md"; ln -s ../requirements "$P/docs/dreq"; ln -s ../src "$P/docs/dsrc"
j_edit "$P/docs/enlace.md" "Estado: en-revisión" "Estado: completado"; fila "Q1 Edit por docs/enlace.md (fuera de /dev)" "$J"
j_edit "$P/docs/dreq/REQ-900.md" "Estado: en-revisión" "Estado: completado"; fila "Q3 Edit por docs/dreq (fuera de /dev)" "$J"
j_bash "echo x > docs/dsrc/a.ts"; fila "Q5 echo > docs/dsrc/a.ts (fuera de /dev)" "$J"
