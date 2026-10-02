set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev/lib-sonda.sh
PD="/dev/shm/arnes-r046-projc-$$"; proyecto_nuevo "$PD"; trap 'rm -rf "$PD"' EXIT
ln -s ../requirements/REQ-900.md "$P/docs/enlace.md"
j_edit "$P/docs/enlace.md" "Estado: en-revisión" "Estado: completado"; fila "P1 Edit por enlace último componente (cierra)" "$J"
# Emulación de la herramienta: lee por la ruta, sustituye literal, escribe por la ruta (sigue el enlace, como fs.writeFileSync).
t="$(cat "$P/docs/enlace.md"; printf x)"; t="${t%x}"; t="${t/Estado: en-revisión/Estado: completado}"; printf '%s' "$t" > "$P/docs/enlace.md"
echo "efecto emulado -> requirements/REQ-900.md, línea 2: $(sed -n 2p "$P/requirements/REQ-900.md"); QA: $(grep '^QA:' "$P/requirements/REQ-900.md")"
[ -L "$P/docs/enlace.md" ] && echo "docs/enlace.md sigue siendo enlace"
