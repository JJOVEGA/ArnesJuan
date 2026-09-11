#!/usr/bin/env bash
# Enumera las RAMAS del lector de `Rigor:` (no valores al azar) y publica el nivel
# efectivo de un lib.sh dado. Uso: ramas-lector.sh <ruta/lib.sh>
set -u
LIB="$1"
. "$LIB" 2>/dev/null || { echo "no puedo cargar $LIB" >&2; exit 2; }

BOM=$'\xef\xbb\xbf'
ZWSP=$'\xe2\x80\x8b'
FWO=$'\xef\xbc\x88'; FWC=$'\xef\xbc\x89'

# id|descripcion de la rama|valor de Rigor
RAMAS=(
"R01|campo ausente (cadena vacia)|"
"R02|solo blancos (valor vacio tras normalizar)|   "
"R03|ligero limpio|ligero"
"R04|estandar limpio|estandar"
"R05|critico limpio|critico"
"R06|valor no reconocido|basura"
"R07|mayusculas (rama del ,,)|LIGERO"
"R08|tabulador delante (rama //\\t)|	ligero"
"R09|blanco de mas interior (rama // )|li gero"
"R10|acento (rama pliega_ortografia NFC)|lígero"
"R11|acento NFD (rama pliega_ortografia NFD)|li"$'\x65\xcc\x81'"gero"
"R12|markdown ** envolviendo (rama desenvuelve)|**ligero**"
"R13|markdown backtick envolviendo|\`ligero\`"
"R14|markdown _ envolviendo|_ligero_"
"R15|MATIZ: parentesis simple|ligero (local)"
"R16|MATIZ: parentesis pegado sin espacio|ligero(local)"
"R17|MATIZ: parentesis vacio|ligero ()"
"R18|MATIZ: parentesis anidado|ligero ((a) b)"
"R19|MATIZ: dos parentesis|ligero (a) (b)"
"R20|MATIZ: markdown envolviendo nivel+parentesis|**ligero (local)**"
"R21|MATIZ: markdown solo en el nivel|**ligero** (local)"
"R22|MATIZ: backtick solo en el nivel|\`ligero\` (local)"
"R23|MATIZ: parentesis con tab dentro|ligero (	local	)"
"R24|MATIZ: parentesis con parentesis interior desbalanceado|ligero (a) b)"
"R25|parentesis SIN CERRAR (no es parentesis, es texto)|ligero (local"
"R26|parentesis SIN ABRIR (no ends-with-( )|ligero local)"
"R27|parentesis AL PRINCIPIO (no final)|(local) ligero"
"R28|MATIZ sobre estandar|estandar (x)"
"R29|MATIZ sobre critico|critico (por suelo)"
"R30|MATIZ sobre valor no reconocido|basura (x)"
"R31|MATIZ: solo parentesis, sin nivel|(local)"
"R32|BOM delante del nivel|${BOM}ligero"
"R33|BOM delante + matiz|${BOM}ligero (local)"
"R34|espacio de anchura cero dentro del nivel|li${ZWSP}gero"
"R35|parentesis de anchura completa (no ASCII)|ligero ${FWO}local${FWC}"
"R36|CR interior en el valor|ligero"$'\r'"(local)"
"R37|matiz cuyo texto ES otro nivel|ligero (critico)"
"R38|matiz cuyo texto es critico, nivel estandar|estandar (critico)"
"R39|nivel critico con matiz que dice ligero|critico (ligero)"
"R40|parentesis con solo blancos dentro|ligero ( 	 )"
)

SENSES=("no" "si" "" "quiza")

printf '%-5s %-52s %-10s %-9s %-9s %s\n' ID RAMA SENS RIGOR MATIZ VALOR_HEX
for r in "${RAMAS[@]}"; do
  id="${r%%|*}"; rest="${r#*|}"; desc="${rest%%|*}"; val="${rest#*|}"
  for s in "${SENSES[@]}"; do
    unset ARNES_RIGOR_MATIZ
    ARNES_QA=''; ARNES_SEG=''; ARNES_SENS=''; ARNES_HALL=''; ARNES_RIGOR=''
    arnes_campos_normaliza "aprobado" "aprobado" "$s" "" "$val" 2>/dev/null
    printf '%-5s %-52s %-10s %-9s %-9s %s\n' \
      "$id" "$desc" "${s:-<ausente>}" "$ARNES_RIGOR" "${ARNES_RIGOR_MATIZ:-unset}" \
      "$(printf '%s' "$val" | od -An -tx1 | tr -d '\n' | tr -s ' ')"
  done
done
