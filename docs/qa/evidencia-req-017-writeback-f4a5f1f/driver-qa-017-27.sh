source "$SP/sonda.sh"
source "$SP/harness.sh"
S37=70000
echo "### GAP 1 — la DIRECTA mide de verdad; el fail-before NO mide (tag v1.32.1 ausente)"
if mide37i "$PWD/hooks/lib.sh" arnes_sin_cita "$(( S37*2 ))" "$S37" 20; then
  u2="$MED37_A"; x2="$MED37_AX"; u1="$MED37_B"; x1="$MED37_BX"
fi
echo "   tras la DIRECTA (medicion REAL): MED37_PLAT=<$MED37_PLAT> MED37_CARGA=<$MED37_CARGA>"
echo "   carga real del sistema ahora:    $(cut -d' ' -f1 /proc/loadavg)"
razon37 "REQ-017 CA-03 el escáner no crece más que linealmente: doblar la línea no cuadruplica" \
  "$u2" "$u1" 2600 "cociente de duplicación" "$x2" "$x1" no-excede \
  "modo=intercalado k=20 series=3 · plataforma=${MED37_PLAT:-n/a} carga=${MED37_CARGA:-n/a}"
echo
HER37_OK=no
if [ "$HER37_OK" != si ]; then MED37_MOTIVO='no hay línea base v1.32.1 (tag ausente o árbol a medias)'; fi
h2=''; h1=''; x2h=''; x1h=''
razon37 'REQ-017 CA-03 fail-before: la sonda distingue el árbol cuadrático' \
  "$h2" "$h1" 2600 "el mismo cociente sobre v1.32.1" "$x2h" "$x1h" excede \
  "modo=intercalado k=1 series=3 · plataforma=${MED37_PLAT:-n/a} carga=${MED37_CARGA:-n/a}"
echo
echo ">>> El fail-before NO MIDIO NADA, y aun asi publica plataforma y carga:"
echo ">>> son las de LA DIRECTA. No existe 'la medicion que la produjo'."
