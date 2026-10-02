set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev/lib-sonda.sh
PD="/dev/shm/arnes-r046-projb-$$"; proyecto_nuevo "$PD"; trap 'rm -rf "$PD"' EXIT
ln -s ../requirements/REQ-900.md "$P/docs/enlace.md"
echo "proyecto=$P"
for a in cand 9596e39 v1.33.2; do
  j_edit "$P/requirements/REQ-900.md" "Estado: en-revisión" "Estado: completado"; juzga $a "$J"; echo "P0 $a: $DEC | ${MOT:0:330}"
done
j_edit "$P/requirements/REQ-901.md" "Estado: en-revisión" "Estado: completado"; fila "V1 Edit literal cierra REQ VERDE (legítimo)" "$J"
j_edit "$P/requirements/REQ-901.md" "texto" "texto nuevo"; fila "V2 Edit literal cuerpo REQ verde (legítimo)" "$J"
printf '%s' "${REQ_VERDE/en-revisión/completado}" > "$S/v.txt"; j_write "$P/requirements/REQ-901.md" "$S/v.txt"; fila "V3 Write cierra REQ VERDE (legítimo)" "$J"
printf '%s' "${REQ_ROJO/en-revisión/completado}" > "$S/r.txt"; j_write "$P/requirements/REQ-900.md" "$S/r.txt"; fila "V4 Write cierra REQ ROJO" "$J"
j_edit "$P/docs/enlace.md" "Estado: en-revisión" "Estado: completado"; fila "P1 Edit por enlace último componente (cierra)" "$J"
echo "--- efecto: si la herramienta aplica P1, el REQ queda:"; sed -i 's/Estado: en-revisión/Estado: completado/' "$P/docs/enlace.md"; sed -n '2p' "$P/requirements/REQ-900.md"; [ -L "$P/docs/enlace.md" ] && echo "(docs/enlace.md sigue siendo enlace: sed -i lo habría roto; se mira el REQ)"
