#!/usr/bin/env bash
# t2 — El límite declarado en CA-47 F3 / punto 16: «una cadena que, tras llegar al directorio de trabajo,
# sube con `..` por encima de la entrada de /proc desde la que se resuelve —cinco niveles— sale de ella y no
# se ve». Se mide a nivel de hook con el hook corriendo en la raíz del proyecto (como lo lanza el host), para
# k = 1..8 segmentos `..` tras /proc/self/cwd, y la ruta que vuelve a bajar hasta el archivo protegido desde
# donde aterriza EL PROCESO QUE ESCRIBE (cuyo directorio de trabajo es la raíz del proyecto).
set -u
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/ev8/lib-sonda8.sh
proyecto_nuevo "$S/p2"
printf 'x\n' > "$S/ct.txt"
IFS=/ read -r -a comp <<< "${P#/}"; d=${#comp[@]}
echo "proyecto=$P  profundidad=$d"
ruta() {  # <k> <sufijo bajo la raiz>  -> R
  local k="$1" suf="$2" i r="/proc/self/cwd" baja=""
  for ((i = 0; i < k; i++)); do r+="/.."; done
  for ((i = d - k; i < d; i++)); do [ "$i" -ge 0 ] && baja+="/${comp[i]}"; done
  [ "$k" -ge "$d" ] && baja="$P"
  R="$r$baja/$suf"
}
for k in 1 2 3 4 5 6 7 8; do
  ruta "$k" "requirements/REQ-900.md"
  j_edit "$R" "Estado: en-revisión" "Estado: completado"; fila "k=$k Edit cierra REQ rojo" "$J"
  ruta "$k" "src/a.ts"
  j_write "$R" "$S/ct.txt"; fila "k=$k Write coordinadora src/a.ts" "$J"
  j_bash "echo x > $R" ""; fila "k=$k Bash SIN cwd: echo > …src/a.ts" "$J"
  j_bash "echo x > $R"; fila "k=$k Bash cwd=raiz (control): echo > …src/a.ts" "$J"
done
echo "== Efecto: ¿a dónde escribe un proceso cuyo directorio es la raíz? (árbol aparte, misma profundidad) =="
T="$S/efe2"; proyecto_nuevo "$T"
IFS=/ read -r -a comp <<< "${P#/}"; d=${#comp[@]}
for k in 4 5 6; do
  ruta "$k" "src/a.ts"
  ( cd "$P" && echo "INTRUSO-k$k" >> "$R" ) 2>&1
done
echo "src/a.ts de $T:"; cat "$T/src/a.ts"
echo "== Lectura léxica de las mismas rutas (lo que haría un host que normaliza) =="
for k in 4 5 6; do ruta "$k" "src/a.ts"; printf 'k=%s %s -> %s\n' "$k" "$R" "$(realpath -m -s "$R")"; done
rm -rf "$T"
