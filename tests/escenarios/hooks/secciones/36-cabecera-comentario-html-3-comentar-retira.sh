# Sección 36 (3 de 5) del banco — 36-cabecera-comentario-html-3-comentar-retira
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
#
# TERCER ARCHIVO Y NO UN AÑADIDO A LOS OTROS: `-1-la-puerta.sh` estaba en 345 líneas y
# CA-11 no cabía sin pasarse del límite de 400 por archivo (`autoprueba-corredor.sh`,
# CA-18). Se sigue la convención `-N-` de las secciones 28 y 33.
#
# QUÉ CERTIFICA: CA-11 de REQ-016 — «comentar una declaración la RETIRA», y la puerta
# decide EXACTAMENTE lo mismo que si la línea se hubiera borrado.
CASOS_ESPERADOS_SECCION=6

# --- REQ-016 CA-11: COMENTAR UNA DECLARACION LA RETIRA --------------------------------
# La conducta existia y ningun criterio la decia, asi que nadie podia saber si era la regla
# o un fallo: envolver en `<!-- ... -->` una linea de veredicto que YA estaba no añade una
# cita, RETIRA una declaracion, y un campo ausente es lo que la puerta perdona por
# compatibilidad con los REQ anteriores a que los veredictos existieran. Medido por QA
# (H-03) y subido a criterio por el analista.
#
# LA EQUIVALENCIA ES EL CRITERIO, y es lo que se comprueba: no «comentar permite» ni
# «comentar deniega», sino que la pareja <linea comentada> / <linea borrada> decide LO
# MISMO. Un caso escrito al reves —fijando la decision de cada campo— seria una segunda
# transcripcion de que ausencias se perdonan, y esa lista vive en UN solo sitio,
# `hooks/guard-completado.sh`. Aqui no se copia: se compara.
  seccion_nueva "Noción de cita (3/5): comentar una declaración la RETIRA — CA-11 (REQ-016):"

# LAS CLAVES SE DERIVAN DEL LECTOR, no se enumeran: son las del `case` de
# `arnes_campos_req` en `hooks/lib.sh`, que es el sitio unico del conjunto de campos de
# cabecera. Asi la propiedad crece sola cuando alguien añade un campo — y si el campo nuevo
# no trae valor de ejemplo aqui, el caso FALLA en vez de saltarselo en silencio.
CLAVES11="$(sed -n \
  -e "s/^[[:space:]]*'\([A-Za-z][^']*\)')[[:space:]]*ARNES_[A-Z]*=\"\$ARNES_VALOR\".*/\1/p" \
  "$HOOKS_DIR/lib.sh" | sort -u)"
CAMPOS11=(); sin_valor11=''
while IFS= read -r k11; do
  [ -n "$k11" ] || continue
  case "$k11" in
    'Sensible a seguridad') v11='sí' ;;
    'QA')                   v11='aprobado' ;;
    'Seguridad')            v11='aprobado' ;;
    'Hallazgos abiertos')   v11='(ninguno)' ;;
    'Rigor')                v11='critico' ;;
    *) sin_valor11="$k11"; continue ;;
  esac
  CAMPOS11+=("$k11: $v11")
done <<< "$CLAVES11"
if [ -n "$sin_valor11" ]; then
  echo "  FAIL  REQ-016 CA-11 el lector declara el campo '$sin_valor11' y esta sección no le da valor de ejemplo: la equivalencia no lo mediría"; FAIL=$((FAIL+1))
elif [ "${#CAMPOS11[@]}" -ge 3 ]; then
  echo "  PASS  REQ-016 CA-11 los campos de la equivalencia se derivan del lector de lib.sh (${#CAMPOS11[@]} campos)"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-016 CA-11 la derivación de campos devolvió ${#CAMPOS11[@]}: la equivalencia no mediría nada"; FAIL=$((FAIL+1))
fi

# Un documento de cabecera con TODOS los campos menos el que se retira. `$1` = estado,
# `$2` = indice del campo a retirar, `$3` = `comentada` | `borrada` | `intacta`.
doc11() {
  local est="$1" quita="$2" forma="$3" i
  printf '# REQ-975\nEstado: %s\n' "$est"
  for i in "${!CAMPOS11[@]}"; do
    if [ "$i" -ne "$quita" ] || [ "$forma" = intacta ]; then
      printf '%s\n' "${CAMPOS11[i]}"
    elif [ "$forma" = comentada ]; then
      printf '<!--\n%s\n-->\n' "${CAMPOS11[i]}"
    fi   # `borrada`: no se escribe nada
  done
}
# <disco> <entrante> -> DECISION11
decide11() {
  local out
  printf '%s' "$1" > "$PROJ/requirements/REQ-975.md"
  out="$(corre guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-975.md" "$2")")"
  if printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"'; then DECISION11=deny; else DECISION11=allow; fi
}

# LAS TRES POSICIONES SON LAS TRES QUE NOMBRA EL CRITERIO: la declaracion se retira solo en
# el ENTRANTE (el disco la declara), solo en el DISCO (el entrante la declara), o en LOS
# DOS. Las dos primeras no son adorno: la puerta lee el disco y lo entrante con precedencia
# —lo entrante pisa, pero solo si declara—, asi que una divergencia entre comentar y borrar
# podria aparecer en una y no en la otra.
discrepa11=0; pares11=0; denys11=0; allows11=0; primera11=''
for i11 in "${!CAMPOS11[@]}"; do
  for pos11 in entrante disco ambos; do
    for forma11 in comentada borrada; do
      case "$pos11" in
        entrante) d11="$(doc11 'en-revisión' "$i11" intacta)"; e11="$(doc11 completado "$i11" "$forma11")" ;;
        disco)    d11="$(doc11 'en-revisión' "$i11" "$forma11")"; e11="$(doc11 completado "$i11" intacta)" ;;
        ambos)    d11="$(doc11 'en-revisión' "$i11" "$forma11")"; e11="$(doc11 completado "$i11" "$forma11")" ;;
      esac
      decide11 "$d11" "$e11"
      if [ "$forma11" = comentada ]; then com11="$DECISION11"; else bor11="$DECISION11"; fi
    done
    pares11=$((pares11+1))
    [ "$com11" = deny ] && denys11=$((denys11+1)) || allows11=$((allows11+1))
    if [ "$com11" != "$bor11" ]; then
      discrepa11=$((discrepa11+1))
      [ -n "$primera11" ] || primera11="«${CAMPOS11[i11]}» retirada en $pos11: comentada=$com11 borrada=$bor11"
    fi
  done
done
if [ "$pares11" -eq 0 ]; then
  echo "  FAIL  REQ-016 CA-11 no se comparó NI UNA pareja comentada/borrada: el caso no midió nada"; diag; FAIL=$((FAIL+1))
elif [ "$discrepa11" -ne 0 ]; then
  echo "  FAIL  REQ-016 CA-11 $discrepa11 de $pares11 parejas deciden distinto — la primera: $primera11"; diag; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-016 CA-11 comentar decide igual que borrar en las $pares11 parejas comprobadas"; PASS=$((PASS+1))
fi
# LA MISMA GUARDA QUE LE FALTABA A LA PROPIEDAD DE CA-02, y por la misma razon: una
# equivalencia entre dos formas es cierta por vacio si las dos caen SIEMPRE del mismo lado.
# Se exige que entre las parejas haya al menos un `deny` y al menos un `allow`; si no, la
# comparacion de arriba no discrimina nada y sale verde sin haber medido.
if [ "$denys11" -gt 0 ] && [ "$allows11" -gt 0 ]; then
  echo "  PASS  REQ-016 CA-11 las parejas tienen dientes en las dos direcciones ($denys11 deny · $allows11 allow)"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-016 CA-11 las parejas cayeron todas del mismo lado ($denys11 deny · $allows11 allow): la equivalencia era cierta por vacío"; FAIL=$((FAIL+1))
fi

# LA EXCEPCION, NOMBRADA: en un REQ de rigor efectivo `critico` la ausencia de `Seguridad:`
# NO se perdona, asi que envolver su `Seguridad: pendiente` en un comentario DENIEGA — igual
# que borrarla. Va aparte del bucle porque es la mitad del criterio que un lector busca por
# su nombre, y porque el bucle la mide con el veredicto en verde.
mkreq_r REQ-976 'sí' 'aprobado' 'pendiente' 'critico'
check "REQ-016 CA-11 la excepción: envolver 'Seguridad: pendiente' en un critico -> deny" deny \
  guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-976.md" '# REQ-976
Estado: completado
Sensible a seguridad: sí
QA: aprobado
<!--
Seguridad: pendiente
-->
Rigor: critico
')"
# Y LA CARA INCOMODA DEL CRITERIO, dicha en un caso y no en una nota: en un REQ que NO es
# critico, comentar el `QA: con-hallazgos` y el hallazgo bloqueante CIERRA — porque borrar
# esas dos lineas tambien cierra, y la ausencia se perdona por compatibilidad. El documento
# sigue diciendo en letra lo contrario de lo que la maquina decide; que eso se vea es
# trabajo del informe (CA-05/CA-06), no de la puerta. El caso existe para que la
# equivalencia quede escrita en su forma mas dura y nadie la «arregle» sin cambiar CA-11.
# Se retira en el DISCO y en lo ENTRANTE a la vez, que es la unica posicion en que la
# declaracion desaparece de verdad: la puerta lee los dos y lo entrante solo pisa cuando
# declara. Las dos formas, cada una con su caso, para que el nombre no prometa una
# comparacion que no se hace.
printf '# REQ-977\nEstado: en-revisión\nSensible a seguridad: no\n<!--\nQA: con-hallazgos\nHallazgos abiertos: SEC-9 (usuario/dinero)\n-->\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-977.md"
check "REQ-016 CA-11 comentar 'QA: con-hallazgos' y un hallazgo 'usuario/dinero' cierra -> allow" allow \
  guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-977.md" '# REQ-977
Estado: completado
Sensible a seguridad: no
<!--
QA: con-hallazgos
Hallazgos abiertos: SEC-9 (usuario/dinero)
-->
Seguridad: n/a
')"
printf '# REQ-977\nEstado: en-revisión\nSensible a seguridad: no\nSeguridad: n/a\n' > "$PROJ/requirements/REQ-977.md"
check "REQ-016 CA-11 ...y BORRAR esas dos líneas decide lo mismo -> allow (la equivalencia, en su forma más dura)" allow \
  guard-completado.sh "$(emite_write "$PROJ/requirements/REQ-977.md" '# REQ-977
Estado: completado
Sensible a seguridad: no
Seguridad: n/a
')"
