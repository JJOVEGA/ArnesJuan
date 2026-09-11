#!/usr/bin/env bash
# Ejerce el LECTOR (arnes_declara_clave) sobre formas de clave de cabecera.
# Base: /home/juan/dev/ArnesJuan-1.34-reparaciones @ f18dd45 (hooks/ identicos a a05994f).
set -u
cd /home/juan/dev/ArnesJuan-1.34-reparaciones
. hooks/lib.sh

probar() {  # <rotulo> <clave literal> <campo objetivo>
  local rot="$1" clave="$2" obj="$3" cab
  cab="# REQ-999 — t
Estado: en-revision
Rigor: critico
${clave}: aprobado
Hallazgos abiertos: (ninguno)

## Historia
"
  arnes_declara_clave "$cab" "$obj"
  # tambien el plegado de la clave sola, para contrastar la glosa del criterio
  arnes_norm_campo "$clave"; local pleg="$ARNES_CAMPO"
  arnes_norm_campo "$obj";   local objn="$ARNES_CAMPO"
  local pl='no'; [ "$pleg" = "$objn" ] && pl='SI'
  printf '%-42s | %-7s | plegado->clave:%-3s | %s\n' "$rot" "$ARNES_DECLARA" "$pl" "$(printf '%s' "$clave" | od -An -tx1 | tr -d '\n' | tr -s ' ')"
}

echo "=== CONTROLES ==="
probar "Seguridad: (limpia)"            "Seguridad"                 "Seguridad"
probar "_Seguridad_: (marcado)"         "_Seguridad_"               "Seguridad"
probar "seguridad: (minuscula)"         "seguridad"                 "Seguridad"
probar "QA: (limpia)"                   "QA"                        "QA"

echo
echo "=== LOS CINCO EJEMPLOS QUE EL CRITERIO DECLARA ==="
probar "S(U+0405)eguridad: homoglifo"   $'\xd0\x85eguridad'         "Seguridad"
probar "Segurida: truncada"             "Segurida"                  "Seguridad"
probar "Segurídad: NFC (i->U+00ED)"     $'Segur\xc3\xaddad'         "Seguridad"
probar "Segurídad: NFD (i+U+0301)"      $'Seguri\xcc\x81dad'        "Seguridad"
probar "Séguridad: NFC"                 $'S\xc3\xa9guridad'         "Seguridad"
probar "Séguridad: NFD"                 $'Se\xcc\x81guridad'        "Seguridad"
probar "QÁ: NFC"                        $'Q\xc3\x81'                "QA"
probar "QÁ: NFD"                        $'QA\xcc\x81'               "QA"

echo
echo "=== LAS QUE BUSCO YO ==="
probar "Segúridad: (u->u acento)"       $'Seg\xc3\xbaridad'         "Seguridad"
probar "SegurIdad: (caja interior)"     "SegurIdad"                 "Seguridad"
probar "SEGURÍDAD: mayusc acentuada"    $'SEGUR\xc3\x8dDAD'         "Seguridad"
probar "Següridad: dieresis NFC"        $'Seg\xc3\xbcridad'         "Seguridad"
probar "Següridad: dieresis NFD"        $'Segu\xcc\x88ridad'        "Seguridad"
probar "Seguriñad: (d->n con tilde)"    $'Seguri\xc3\xb1ad'         "Seguridad"
probar "Seguridañ: (d final->n tilde)"  $'Seguridan\xcc\x83'        "Seguridad"
probar "_Segurídad_: acento+marcado"    $'_Segur\xc3\xaddad_'       "Seguridad"
probar "**Segurídad**: acento+negrita"  $'**Segur\xc3\xaddad**'     "Seguridad"
probar " Segurídad : acento+blancos"    $' Segur\xc3\xaddad '       "Seguridad"
probar "Segurîdad: circunflejo NFC"     $'Segur\xc3\xaedad'         "Seguridad"
probar "Segurĩdad: tilde sobre i NFD"   $'Seguri\xcc\x83dad'        "Seguridad"
probar "Segurīdad: macron U+0304 NFD"   $'Seguri\xcc\x84dad'        "Seguridad"
probar "Seguridad con U+0307 NFD"       $'Seguri\xcc\x87dad'        "Seguridad"
probar "Segurıdad: i sin punto U+0131"  $'Segur\xc4\xb1dad'         "Seguridad"
probar "S(U+0435 cirilica e)guridad"    $'S\xd0\xb5guridad'         "Seguridad"
probar "Seguridadd: letra de mas"       "Seguridadd"                "Seguridad"
probar "Seguridad + ZWSP dentro"        $'Seguri\xe2\x80\x8bdad'    "Seguridad"
probar "Seguridad + BOM delante"        $'\xef\xbb\xbfSeguridad'    "Seguridad"
probar "Seguridad + blanco de mas"      "Segur idad"                "Seguridad"
probar "QÁ con marcado _QÁ_"            $'_Q\xc3\x81_'              "QA"
probar "Qá: (minuscula+acento)"         $'q\xc3\xa1'                "QA"
probar "QÀ: grave NFC"                  $'Q\xc3\x80'                "QA"
probar "QÄ: dieresis NFC"               $'Q\xc3\x84'                "QA"
probar "QÅ: anillo (NO plegado)"        $'Q\xc3\x85'                "QA"
probar "QĀ: macron NFC U+0100"          $'Q\xc4\x80'                "QA"
probar "QA + U+030A anillo NFD"         $'QA\xcc\x8a'               "QA"
