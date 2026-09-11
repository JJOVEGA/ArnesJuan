#!/usr/bin/env bash
# R-029 · Barrido de NO-REGRESION y de la propiedad del nivel exento.
# Metodo y version base: ./LEEME.md . Solo lee; no escribe nada.
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAIZ="$(cd "$AQUI/../../.." && pwd)"
L330=${L330:-/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.0/hooks/lib.sh}
L331=${L331:-/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.1/hooks/lib.sh}
L332=${L332:-$RAIZ/hooks/lib.sh}

# Un lector por subproceso: cada version define las MISMAS funciones y no pueden
# convivir en un shell. Se emite <sens> TAB <rigor> TAB <nivel> TAB <orden>.
lee_todo() {
  local lib="$1"
  bash -c '
    set -u; . "$1" >/dev/null 2>&1
    niv() { case "$1" in ligero) echo 1;; estandar) echo 2;; critico) echo 3;; *) echo 0;; esac; }
    while IFS= read -r linea; do
      sens="${linea%%|*}"; rig="${linea#*|}"
      ARNES_RIGOR_MATIZ=""
      arnes_campos_normaliza "" "" "$sens" "" "$rig" 2>/dev/null
      printf "%s|%s|%s|%s\n" "$sens" "$rig" "$ARNES_RIGOR" "$(niv "$ARNES_RIGOR")"
    done
  ' _ "$lib"
}

# La matriz: 39 formas x 4 estados de sensibilidad. El alfabeto vive en un archivo
# aparte para que anadir una forma no exija tocar el codigo de la sonda.
matriz() {
  local s r
  for s in si no '' quiza; do
    while IFS= read -r r; do printf '%s|%s\n' "$s" "$r"; done < "$AQUI/alfabeto.tsv"
  done
}

M="$(matriz)"
A="$(lee_todo "$L330" <<< "$M")"
B="$(lee_todo "$L331" <<< "$M")"
C="$(lee_todo "$L332" <<< "$M")"

printf 'lectores:\n  1.33.0 %s\n  1.33.1 %s\n  1.33.2 %s\n\n' "$L330" "$L331" "$L332"
printf '%-6s %-24s %-9s %-9s %-9s %s\n' SENS 'RIGOR ESCRITO' 1.33.0 1.33.1 1.33.2 NOTA
regres=0; exentos=0; total=0
paste -d'|' <(printf '%s\n' "$A") <(printf '%s\n' "$B") <(printf '%s\n' "$C") \
| while IFS='|' read -r s1 r1 v1 n1 s2 r2 v2 n2 s3 r3 v3 n3; do
    nota=''
    [ "$n3" -lt "$n1" ] && nota="$nota REGRESION(1.33.2 por debajo de 1.33.0)"
    [ "$v3" = ligero ] && nota="$nota *EXENTO-QA*"
    printf '%-6s %-24s %-9s %-9s %-9s %s\n' "${s1:-<aus>}" "[$r1]" "$v1" "$v2" "$v3" "$nota"
  done > "${TMPDIR:-/tmp}/r029.$$"
cat "${TMPDIR:-/tmp}/r029.$$"
total=$(wc -l < "${TMPDIR:-/tmp}/r029.$$")
regres=$(grep -c 'REGRESION' "${TMPDIR:-/tmp}/r029.$$" || true)
exentos=$(grep -c 'EXENTO-QA' "${TMPDIR:-/tmp}/r029.$$" || true)
desnudos=$(grep 'EXENTO-QA' "${TMPDIR:-/tmp}/r029.$$" | grep -c '\[ligero\]' || true)
rm -f "${TMPDIR:-/tmp}/r029.$$"
echo
echo "combinaciones: $total   regresiones: $regres   celdas exentas de QA: $exentos (de ellas, forma DESNUDA: $desnudos)"
if [ "$regres" -eq 0 ] && [ "$exentos" -eq "$desnudos" ]; then
  echo 'RESULTADO: OK — 0 regresiones y el nivel exento solo se alcanza desde la forma DESNUDA.'
else
  echo 'RESULTADO: FALLA — revisar las lineas marcadas.'; exit 1
fi
