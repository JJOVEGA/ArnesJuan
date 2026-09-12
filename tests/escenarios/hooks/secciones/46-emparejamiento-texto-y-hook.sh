# Sección 46 del banco — 46-emparejamiento-texto-y-hook
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna
# otra sección (invariantes 3 y 4 del README del banco).
#
# QUÉ MIDE Y POR QUÉ NO CABE EN LA 44 — la diferencia es el VERBO. La 44 comprueba que cada
# sede DIGA un fragmento literal, sobre una LISTA de tres bloques escrita en el archivo. Aquí
# se cumple lo que `REQ-024 CA-14 (ii)`–`(iii)` piden y que ninguna prueba hacía en cada
# corrida: EMPAREJAR, en la MISMA vuelta, lo que la sede AFIRMA con lo que el HOOK REAL hace
# sobre un REQ en ese estado —no comparar cadenas—, sobre un conjunto de sedes DERIVADO
# barriendo los documentos y nunca de una lista. Un documento puede decir el fragmento
# correcto y ser falso: eso es lo que midió `QA-024-38` (4 de 6 celdas falsas, y hacia el lado
# que tranquiliza). La redacción y la VERDAD de esa redacción son propiedades distintas, y
# ninguna implica la otra.
#
# DE DÓNDE SALE EL INSTRUMENTO, Y POR QUÉ ENTRA AL BANCO. El `qa-tester` midió estas celdas el
# 2026-09-11 sobre `98f0ecd` con una sonda propia
# (`docs/qa/evidencia-req-024-d12-98f0ecd/probe-d12.sh`, salida en `ejes-cierre-firma.txt`).
# Esa medición es EVIDENCIA FECHADA de un árbol: no vuelve a correr y no dice nada del árbol de
# mañana. Aquí se reimplanta sobre los ayudantes del banco para que se re-ejecute en CADA
# corrida, con el mismo reparto por rigor y por estado de la llave. El eje 3 de aquella sonda
# —FIRMAR con `QA:` sin declararse— ya lo miden `13-orden-del-ciclo.sh` y `40-…-4-…`, y no se
# repite aquí.
#
# MIDE LAS DOS COSAS A LA VEZ, así que tiene DOS direcciones de fail-before y las dos han de
# salir en ROJO (con cualquiera de las dos puesta la vuelta NO acredita este árbol):
#   ARNES_DOCS_RAIZ=<copia del árbol anterior> bash tests/escenarios/hooks/run.sh secciones/46-*.sh
#   ARNES_HOOKS_DIR=<instalación anterior>     bash tests/escenarios/hooks/run.sh secciones/46-*.sh
#
# EL CONJUNTO DE SEDES SE DERIVA, NO SE ESCRIBE (`CA-14`, «Dado»): la unidad de §13 —fila o
# párrafo— nombra una clave de veredicto (`` `QA: `` o `` `Seguridad: ``) Y dice qué le ocurre
# al CIERRE. Esa segunda mitad es una FAMILIA reconocida por expresión, no una lista de sedes;
# residuo declarado: una forma que no case deja esa sede FUERA, y por eso cada corrida PUBLICA
# el denominador —sedes y afirmaciones por sede—, que es lo que hace visible un conjunto que
# encoge. Por el mismo motivo la derivación de celdas va por anclas literales (H-11): una
# redacción nueva dejaría de derivarse, y sin afirmación el caso ABORTA con SKIP y su motivo,
# NUNCA con PASS; la vía conforme es actualizar el ancla, jamás retirar el caso.
#
# LO QUE NO MIDE, para que no se lea de más: no mide la MIGRACIÓN —que la guía la MANDE es
# `45/2`, y comprobar que el clasificador decide bien NO es haber ejecutado el procedimiento
# real de actualización sobre un proyecto instalado (`CA-14 (viii)`, limitación declarada
# allí)—; no mide la conducta del aviso (la 43) ni la del orden de las firmas (la 13 y la
# 40/4); y no contrata la redacción de la fila del ORDEN, que es `CA-12 (ii)`, aunque el
# barrido la incluya en su conjunto. Los NEGATIVOS VIVOS de `CA-14` viven donde vive cada
# registro de obligaciones —`44/E` para las sedes y `45/24` para la guía—, porque un negativo
# que no recorre el registro real envejece hacia el lado que abre.
CASOS_ESPERADOS_SECCION=17
PISO_AUTONOMO_SECCION=212  # 50 preámbulo con sus dos declaraciones y el titular (líneas 1-50) + 124 maquinaria propia, que el corredor no tiene: el barrido por propiedad, el partidor de oraciones con sus dos reconocedores, el extractor entre anclas, los tres lectores de niveles, el derivador de celdas, el constructor de REQ y la sonda que devuelve la decisión del hook como VALOR (líneas 57-180) + 38 bloque indivisible mayor (el emparejador `empareja46`, líneas 219-256: ningún caso de esta sección se lee sin él) · REQ-014 CA-18 · REGLA para re-derivar los tres términos sin preguntar: «preámbulo» son las líneas hasta el titular inclusive; un «bloque» es un grupo de líneas consecutivas sin blanca en medio, y el mayor que no es el preámbulo ni la maquinaria es el emparejador; «maquinaria» es la que esta sección define porque el corredor no la tiene, no una copia de otra parte

seccion_nueva "--- 46/1 · lo que la superficie heredada PROMETE, emparejado con lo que el hook HACE (REQ-024 CA-14 (ii)-(iii)) ---"

REPO46="${SEC_DIR%/}/../../../.."
RAIZ46="${ARNES_DOCS_RAIZ:-$REPO46}"
DOCS46="AGENTS.md templates/AGENTS.md.tpl"
ESCALERA46="ligero estandar critico"   # el orden del rigor, que es el del propio proyecto

# --- MAQUINARIA PROPIA, y va con su motivo -----------------------------------------
# Ningún ayudante del corredor barre un documento por propiedad, ni deriva celdas de una
# frase, ni devuelve la decisión del hook como VALOR (el compartido `check` la compara contra
# una esperada, que es justo lo que aquí no se puede hacer: la esperada sale del texto). Se
# define aquí porque NO lo hay. La única que ejecuta un hook es `dec46`, y lleva su guarda:
# un JSON vacío no es un caso, es un caso que no se ejecutó.
barre46() {   # <archivo> -> una línea por SEDE del conjunto DERIVADO, aplanada
  awk '
    /^## 13\./ { d = 1 }
    d && /^## 14\./ { exit }
    !d { next }
    substr($0, 1, 1) == "|" { if (u != "") { emite(u); u = "" } emite($0); next }
    /^[ \t]*$/ { if (u != "") { emite(u); u = "" } next }
    { u = (u == "" ? $0 : u " " $0) }
    END { if (u != "") emite(u) }
    function emite(t,   c) {
      if (index(t, "`QA:") == 0 && index(t, "`Seguridad:") == 0) return
      c = t; gsub(/«[^»]*»/, "", c)
      if (c !~ /(no |NO )?(podrá|puede|deja|dejan|permite|permiten) cerrar|(impide|impiden|impedir) (que|el|cerrar)|(deniega|deniegan|denegar) (el cierre|cerrar)|cierre se deniega|se deniega en los|[Nn]o completar|CIERRA en|cierra en|cierra sin|no para el cierre|llega al cierre|no cierra/) return
      print t
    }' "$1" 2>/dev/null
}
oraciones46() {   # <texto> <clase: consec|neces-sin-condicion> -> una línea por oración
  printf '%s\n' "$1" | awk -v clase="$2" '
    {
      # Lo que va entre «» es CITA y no afirmación de este documento: el texto corregido cita
      # la promesa vieja para decir que quedó medida falsa, y eso no vuelve a prometerla.
      gsub(/«[^»]*»/, "", $0)
      n = split($0, frase, "\\. +")
      for (i = 1; i <= n; i++) {
        s = frase[i]
        if (clase == "consec") {
          if (s ~ /(no |NO )?(podrá|puede|deja|dejan|permite|permiten) cerrar|(impide|impiden|impedir) (que|el|cerrar)|(deniega|deniegan|denegar) (el cierre|cerrar)|cierre se deniega|se deniega en los|[Nn]o completar|CIERRA en|cierra en|cierra sin|no para el cierre|llega al cierre|no cierra/) print s
        } else {
          # Necesidad o imposibilidad: «no podrá cerrarse», «no deja cerrar», «No completar
          # sin…». Una afirmación así SIN su condición dentro de la misma oración INCUMPLE
          # (`CA-14 (ii)`), aunque la conducta pase. Una posibilidad —«puede impedir»— no
          # promete y no entra: la frontera va dicha y es una decisión, no un descuido.
          if (s !~ /no podrá cerrar|no puede cerrar|no se puede cerrar|no deja cerrar|impide cerrar|impiden cerrar|deniega el cierre|el cierre se deniega|[Nn]o completar sin|no permite cerrar|no cierra/) continue
          if (s ~ /ligero|estandar|critico|[Tt]res rigores|en los tres|ausencia_exige|la llave/) continue
          print s
        }
      }
    }'
}
entre46() {   # <texto> <ancla inicial> <ancla final> -> lo que hay entre las dos (vacío si falta)
  local t="$1" ini="$2" fin="$3" resto
  case "$t" in *"$ini"*) resto="${t#*"$ini"}" ;; *) return 0 ;; esac
  case "$resto" in *"$fin"*) printf '%s' "${resto%%"$fin"*}" ;; *) return 0 ;; esac
}
niveles46() {   # <trozo> -> los niveles de rigor que NOMBRA («tres» = los tres)
  local t="$1" out=''
  [ -z "$t" ] && return 0
  case "$t" in *[Tt][Rr][Ee][Ss]*) printf '%s' "$ESCALERA46"; return 0 ;; esac
  case "$t" in *ligero*)   out="$out ligero" ;; esac
  case "$t" in *estandar*) out="$out estandar" ;; esac
  case "$t" in *critico*)  out="$out critico" ;; esac
  printf '%s' "${out# }"
}
resto46() {   # <niveles> -> el complemento sobre la escalera (lo licencia la palabra «sólo»)
  local dentro=" $1 " n out=''
  for n in $ESCALERA46; do case "$dentro" in *" $n "*) ;; *) out="$out $n" ;; esac; done
  printf '%s' "${out# }"
}
debajo46() {   # <trozo con UN nivel> -> los niveles estrictamente por debajo, en la escalera
  local tope n out=''
  tope="$(niveles46 "$1")"
  [ -z "$tope" ] && return 0
  for n in $ESCALERA46; do [ "$n" = "$tope" ] && break; out="$out $n"; done
  printf '%s' "${out# }"
}
deriva46() {   # <sede> <clave: QA|Seguridad> <eje: valor|ausencia> -> «<llave> <rigor> <deny|allow>»
  local t="$1" trozo denys allows n
  case "$2/$3" in
    QA/valor)
      trozo="$(entre46 "$t" '`QA:` cuyo valor no sea `aprobado` no deja cerrar en ' ', y **sí deja cerrar en')"
      if [ -n "$trozo" ]; then
        denys="$(niveles46 "$trozo")"
        allows="$(niveles46 "$(entre46 "$t" '**sí deja cerrar en ' ', que no pide veredicto')")"
      else
        denys="$(niveles46 "$(entre46 "$t" '`QA:` fuera de vocabulario impide cerrar en ' ', pero **no** en')")"
        allows="$(niveles46 "$(entre46 "$t" ', pero **no** en ' ', que no pide veredicto')")"
      fi ;;
    Seguridad/valor)
      trozo="$(entre46 "$t" '`Seguridad:` cuyo valor no sea `aprobado` no deja cerrar **sólo** en ' '. ')"
      [ -z "$trozo" ] && trozo="$(entre46 "$t" '`Seguridad:` fuera de vocabulario impide cerrar **sólo** en ' '. ')"
      denys="$(niveles46 "$trozo")"; allows="$(resto46 "$denys")" ;;
    QA/ausencia)
      # Único eje que CAMBIA con el estado de la llave, así que cada mitad va por su lado.
      allows="$(niveles46 "$(entre46 "$t" 'un REQ SIN línea `QA:` CIERRA en los ' '**;')")"
      trozo="$(entre46 "$t" 'encendida, se deniega en los ' ' nombrando el campo')"
      [ -z "$trozo" ] && trozo="$(entre46 "$t" 'encendida, el cierre se deniega en los ' ')')"
      denys="$(niveles46 "$trozo")"
      for n in $allows; do printf 'false %s allow\n' "$n"; done
      for n in $denys;  do printf 'true %s deny\n'  "$n"; done
      return 0 ;;
    Seguridad/ausencia)
      trozo="$(entre46 "$t" 'su ausencia no para el cierre por debajo de ' ', idéntico en los dos estados')"
      [ -z "$trozo" ] && return 0
      allows="$(debajo46 "$trozo")"; denys="$(resto46 "$allows")" ;;
  esac
  # En el eje del VALOR la sede sólo cubre los DOS estados de la llave si DICE que ahí la llave
  # no mueve nada; si no lo dice, no hay afirmación que emparejar y el suelo lo delata.
  case "$t" in *'no mueve'*) ;; *) return 0 ;; esac
  for n in $denys;  do printf 'false %s deny\n'  "$n"; printf 'true %s deny\n'  "$n"; done
  for n in $allows; do printf 'false %s allow\n' "$n"; printf 'true %s allow\n' "$n"; done
}
req46() {   # <nombre> <rigor> <valor QA o vacío> <valor Seguridad o vacío>
  # `Hallazgos abiertos:` va SIEMPRE, y no es adorno: con `campos.ausencia_exige` encendida su
  # AUSENCIA también deniega, y contaminaría las celdas de las otras dos claves.
  { printf '# %s\nEstado: en-revisión\nSensible a seguridad: no\n' "$1"
    [ -n "$3" ] && printf 'QA: %s\n' "$3"
    [ -n "$4" ] && printf 'Seguridad: %s\n' "$4"
    printf 'Rigor: %s\nHallazgos abiertos: (ninguno)\n' "$2"
  } > "$PROJ/requirements/$1.md"
  return 0
}
dec46() {   # <nombre de REQ> -> deny|allow|ERROR — la decisión del hook REAL, como VALOR
  local json salida
  json="$(emite_edit_real "$PROJ/requirements/$1.md" 'Estado: en-revisión' 'Estado: completado')"
  if [ -z "$json" ]; then printf 'ERROR'; return 0; fi
  salida="$(corre guard-completado.sh "$json")"
  case "$salida" in *'"permissionDecision": "deny"'*|*'"permissionDecision":"deny"'*) printf 'deny' ;; *) printf 'allow' ;; esac
}

# --- LA TABLA DE LAS 24 CELDAS, MEDIDA UNA VEZ POR CORRIDA CON EL HOOK REAL --------
# 2 claves × 2 ejes × 3 rigores × 2 estados de la llave. `CA-14 (ii)` pide no menos de 12 en el
# eje del VALOR y `(iii)` las mismas en el de la AUSENCIA, en los dos estados; aquí salen 24 y
# cada afirmación derivada se empareja contra ellas. Se mide una vez porque el hook no depende
# del documento: lo que cambia de un caso a otro es lo que el TEXTO promete.
TABLA46=''
for k46 in false true; do
  setcfg ".campos.ausencia_exige = $k46"
  for r46 in $ESCALERA46; do
    req46 Qv "$r46" 'aprobadisimo' 'aprobado'
    req46 Sv "$r46" 'aprobado' 'aprobadisimo'
    req46 Qa "$r46" '' 'aprobado'
    req46 Sa "$r46" 'aprobado' ''
    TABLA46="${TABLA46}QA valor $k46 $r46 $(dec46 Qv)
Seguridad valor $k46 $r46 $(dec46 Sv)
QA ausencia $k46 $r46 $(dec46 Qa)
Seguridad ausencia $k46 $r46 $(dec46 Sa)
"
  done
done
celda46() {   # <clave> <eje> <llave> <rigor> -> lo que el hook REAL hizo en esa celda
  local linea
  linea="$(printf '%s\n' "$TABLA46" | awk -v c="$1" -v e="$2" -v k="$3" -v r="$4" \
    '$1 == c && $2 == e && $3 == k && $4 == r { print $5; exit }')"
  printf '%s' "$linea"
}


# --- EL CONJUNTO DERIVADO, barrido UNA VEZ por documento --------------------------
SEDES_A46="$(barre46 "$RAIZ46/AGENTS.md")"
SEDES_T46="$(barre46 "$RAIZ46/templates/AGENTS.md.tpl")"
sedes46() { case "$1" in AGENTS.md) printf '%s' "$SEDES_A46" ;; *) printf '%s' "$SEDES_T46" ;; esac; }
nom46() {   # <sede> -> nombre corto y legible para el mensaje de un fallo
  local t="${1//\*/}"; t="${t//\`/}"; t="${t//|/}"; t="${t# }"; printf '%s' "${t:0:56}"
}
CELDAS_VALOR46=0; CELDAS_AUSENCIA46=0

empareja46() {   # <nombre> <documento> <clave> <eje> — EL caso: texto contra hook, misma corrida
  local nombre="$1" doc="$2" clave="$3" eje="$4"
  local sede claims llave rigor esperado real primera=''
  local nsedes=0 conafirmacion=0 celdas=0 malas=0
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  while IFS= read -r sede; do
    [ -z "$sede" ] && continue
    nsedes=$((nsedes + 1))
    claims="$(deriva46 "$sede" "$clave" "$eje")"
    [ -z "$claims" ] && continue
    conafirmacion=$((conafirmacion + 1))
    while read -r llave rigor esperado; do
      [ -z "$esperado" ] && continue
      celdas=$((celdas + 1))
      real="$(celda46 "$clave" "$eje" "$llave" "$rigor")"
      if [ "$real" != "$esperado" ]; then
        malas=$((malas + 1))
        [ -n "$primera" ] || primera="«$(nom46 "$sede")…» promete $esperado y el hook hace ${real:-SIN MEDIR} (llave=$llave, rigor=$rigor)"
      fi
    done <<< "$claims"
  done <<< "$(sedes46 "$doc")"
  [ "$eje" = valor ] && CELDAS_VALOR46=$((CELDAS_VALOR46 + celdas)) || CELDAS_AUSENCIA46=$((CELDAS_AUSENCIA46 + celdas))
  if [ "$nsedes" -eq 0 ]; then
    echo "  SKIP  $nombre  el barrido de $doc no encontro NINGUNA sede (denominador 0, suelo 1): no hay nada que emparejar"
    SKIP=$((${SKIP:-0} + 1)); return 0
  fi
  if [ "$conafirmacion" -eq 0 ]; then
    echo "  SKIP  $nombre  de las $nsedes sedes barridas NINGUNA declara esta afirmacion (0 celdas, suelo 1): el texto no dice que hace la maquina aqui"
    SKIP=$((${SKIP:-0} + 1)); return 0
  fi
  if [ "$malas" -eq 0 ]; then
    echo "  PASS  $nombre  ($conafirmacion de $nsedes sedes lo declaran; $celdas celdas emparejadas con el hook real)"
    PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  el TEXTO promete algo distinto de lo que el HOOK hace en $malas de $celdas celdas: $primera"
    FAIL=$((FAIL+1))
  fi
}

for d46 in $DOCS46; do
  empareja46 "46/1 CA-14 (ii) [$d46] por VALOR de QA: el texto y el hook dicen lo mismo en las 3+3 celdas" "$d46" QA valor
  empareja46 "46/2 CA-14 (ii) [$d46] por VALOR de Seguridad: el texto y el hook dicen lo mismo en las 3+3 celdas" "$d46" Seguridad valor
  empareja46 "46/3 CA-14 (iii) [$d46] por AUSENCIA de QA: el eje es LA LLAVE, y el hook lo confirma en los dos estados" "$d46" QA ausencia
  empareja46 "46/4 CA-14 (iii) [$d46] por AUSENCIA de Seguridad: el eje sigue siendo el RIGOR, igual en los dos estados" "$d46" Seguridad ausencia
done

# --- LOS SUELOS DE `CA-14 (ii)` Y `(iii)`: 12 CELDAS POR EJE, HACIA ARRIBA ---------
# «Operativos, dirección hacia arriba: más es conforme y NO es hallazgo; menos ABORTA con SKIP
# y su motivo, nunca PASS.» El número se publica en cada corrida y sube con cada forma nueva
# del corpus: ninguna de estas cifras fija techo ni suelo de nada más.
for e46 in valor ausencia; do
  N46="46/5 CA-14 suelo del eje $e46: no menos de 12 celdas emparejadas con el hook real"
  [ "$e46" = valor ] && n46=$CELDAS_VALOR46 || n46=$CELDAS_AUSENCIA46
  if [ -n "$FILTRO" ] && ! printf '%s' "$N46" | grep -qi -- "$FILTRO"; then :
  elif [ "$n46" -ge 12 ]; then
    echo "  PASS  $N46  ($n46 celdas: 2 claves x 3 rigores x 2 estados de la llave, por las sedes que lo declaran)"; PASS=$((PASS+1))
  else
    echo "  SKIP  $N46  solo $n46 celdas emparejadas (suelo 12): el instrumento no alcanza a acreditar el eje, y un verde aqui seria por vacio"; SKIP=$((${SKIP:-0} + 1))
  fi
done

# --- ANTI-VACUIDAD: EL DENOMINADOR DEL BARRIDO, PUBLICADO POR DOCUMENTO -----------
# `CA-14`: se publica cuántas SEDES encontró el barrido y cuántas AFIRMACIONES se comprobaron en
# cada una, y se aborta con SKIP —nunca PASS— si cualquiera de los dos sale 0. «Ninguna sede
# promete de más» es cierto POR VACÍO con el conjunto vacío, y eso es lo que `REQ-020` caza.
for d46 in $DOCS46; do
  N46="46/6 CA-14 (anti-vacuidad) [$d46] el barrido publica su denominador: sedes y afirmaciones por sede"
  if [ -n "$FILTRO" ] && ! printf '%s' "$N46" | grep -qi -- "$FILTRO"; then continue; fi
  ns46=0; sinafirm46=''; detalle46=''
  while IFS= read -r s46; do
    [ -z "$s46" ] && continue
    ns46=$((ns46 + 1))
    na46="$(oraciones46 "$s46" consec | grep -c .)"
    detalle46="$detalle46 [$na46]"
    [ "$na46" -eq 0 ] && sinafirm46="$sinafirm46 «$(nom46 "$s46")…»"
  done <<< "$(sedes46 "$d46")"
  if [ "$ns46" -eq 0 ]; then
    echo "  SKIP  $N46  el barrido encontro 0 sedes (suelo 1): con el conjunto vacio, «ninguna promete de mas» es cierto por vacio"; SKIP=$((${SKIP:-0} + 1))
  elif [ -n "$sinafirm46" ]; then
    echo "  SKIP  $N46  $ns46 sedes, y alguna con 0 afirmaciones (suelo 1 por sede):$sinafirm46"; SKIP=$((${SKIP:-0} + 1))
  else
    echo "  PASS  $N46  ($ns46 sedes barridas; afirmaciones comprobadas por sede:$detalle46)"; PASS=$((PASS+1))
  fi
done

# --- `CA-14 (ii)`, ÚLTIMA FRASE: PROMETER EL CIERRE SIN LA CONDICIÓN DENTRO INCUMPLE ---
# «Aunque la conducta pase»: es el defecto exacto de `QA-024-38`, y es el caso que pone en ROJO
# —y no en abstención— la versión heredada de estas sedes. La frontera va dicha: se persiguen las
# formas de NECESIDAD o IMPOSIBILIDAD; una de POSIBILIDAD («la máquina PUEDE impedir que un REQ
# se cierre») no promete que la consecuencia valga siempre y no entra. Lo de dentro de «» es CITA.
for d46 in $DOCS46; do
  N46="46/7 CA-14 (ii)(v) [$d46] ninguna sede promete una consecuencia sobre el CIERRE sin su condicion DENTRO de la oracion"
  if [ -n "$FILTRO" ] && ! printf '%s' "$N46" | grep -qi -- "$FILTRO"; then continue; fi
  ns46=0; malas46=0; primera46=''
  while IFS= read -r s46; do
    [ -z "$s46" ] && continue
    ns46=$((ns46 + 1))
    while IFS= read -r o46; do
      [ -z "$o46" ] && continue
      malas46=$((malas46 + 1))
      [ -n "$primera46" ] || primera46="sede «$(nom46 "$s46")…», frase «${o46:0:110}…»"
    done <<< "$(oraciones46 "$s46" neces)"
  done <<< "$(sedes46 "$d46")"
  if [ "$ns46" -eq 0 ]; then
    echo "  SKIP  $N46  el barrido encontro 0 sedes (suelo 1): sin conjunto, la afirmacion seria cierta por vacio"; SKIP=$((${SKIP:-0} + 1))
  elif [ "$malas46" -eq 0 ]; then
    echo "  PASS  $N46  ($ns46 sedes barridas, 0 promesas sin condicion)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $N46  $malas46 promesa(s) de cierre SIN su condicion dentro: $primera46"; FAIL=$((FAIL+1))
  fi
done

# --- `CA-14 (vi)`: LAS GEMELAS DEL CONJUNTO DERIVADO, COTEJADAS EN ESTA MISMA CORRIDA ---
# La 44 coteja los TRES bloques de su lista; aquí se cotejan TODAS las sedes que el barrido
# derive, que es lo que `(vi)` dice («cada sede y su gemela»). Una sede nueva —o una cuarta que
# ya estaba y nadie listó— queda cubierta sin tocar este archivo.
N46="46/8 CA-14 (vi) cada sede del conjunto DERIVADO es identica byte a byte a su gemela de la plantilla"
if [ -z "$FILTRO" ] || printf '%s' "$N46" | grep -qi -- "$FILTRO"; then
  na46=0; nb46=0; divergen46=0; primera46=''
  while IFS= read -r s46; do [ -n "$s46" ] && na46=$((na46 + 1)); done <<< "$(sedes46 AGENTS.md)"
  while IFS= read -r s46; do [ -n "$s46" ] && nb46=$((nb46 + 1)); done <<< "$(sedes46 templates/AGENTS.md.tpl)"
  if [ "$na46" -eq 0 ] || [ "$nb46" -eq 0 ]; then
    echo "  SKIP  $N46  el barrido dio $na46 y $nb46 sedes (suelo 1 en cada documento): sin conjunto no hay cotejo"; SKIP=$((${SKIP:-0} + 1))
  elif [ "$SEDES_A46" = "$SEDES_T46" ]; then
    echo "  PASS  $N46  ($na46 sedes cotejadas una a una contra sus gemelas, y las $na46 identicas)"; PASS=$((PASS+1))
  else
    while IFS= read -r s46; do
      [ -z "$s46" ] && continue
      case "$SEDES_T46" in *"$s46"*) ;; *) divergen46=$((divergen46 + 1)); [ -n "$primera46" ] || primera46="templates/AGENTS.md.tpl no tiene la sede «$(nom46 "$s46")…» tal cual esta en AGENTS.md" ;; esac
    done <<< "$SEDES_A46"
    echo "  FAIL  $N46  $na46 sedes en AGENTS.md y $nb46 en la plantilla, $divergen46 sin gemela identica: $primera46"; FAIL=$((FAIL+1))
  fi
fi

# --- DISCRIMINANTE 1: LA DERIVACIÓN NO ES UN ESPEJO DEL HOOK ----------------------
# Sin esto, una derivación rota que devolviera SIEMPRE lo que el hook acaba de decir pondría en
# verde los ocho emparejamientos sin leer una palabra del documento.
N46="46/9 CA-14 (ii) discriminante de la DERIVACION: mutado el nivel que el texto promete, el emparejamiento cambia"
if [ -z "$FILTRO" ] || printf '%s' "$N46" | grep -qi -- "$FILTRO"; then
  sede46=''
  while IFS= read -r s46; do
    case "$s46" in *'no deja cerrar en `estandar` ni en `critico`'*) sede46="$s46"; break ;; esac
  done <<< "$(sedes46 AGENTS.md)"
  mut46="${sede46/no deja cerrar en \`estandar\` ni en \`critico\`/no deja cerrar en \`ligero\` ni en \`critico\`}"
  ori46="$(deriva46 "$sede46" QA valor)"; nue46="$(deriva46 "$mut46" QA valor)"
  if [ -z "$sede46" ] || [ "$mut46" = "$sede46" ]; then
    echo "  FAIL  $N46  ninguna sede barrida dice el fragmento a mutar: la inyeccion no probaria nada"; FAIL=$((FAIL+1))
  elif [ -z "$ori46" ]; then
    echo "  FAIL  $N46  la derivacion del texto REAL salio vacia: no hay nada que discriminar"; FAIL=$((FAIL+1))
  elif [ "$ori46" = "$nue46" ]; then
    echo "  FAIL  $N46  mutado el nivel, la derivacion devuelve LO MISMO: no lee el documento"; FAIL=$((FAIL+1))
  else
    echo "  PASS  $N46  (la derivacion sigue al texto: mutado el nivel, las celdas esperadas cambian)"; PASS=$((PASS+1))
  fi
fi

# --- DISCRIMINANTE 2: EL SONDEO DEL HOOK NO ES CONSTANTE --------------------------
# `guard-completado` responde a un `allow` con SALIDA VACÍA: un hook que no llegara a ejecutarse
# se leería como «allow» en las 24 celdas y el emparejamiento pasaría por constancia.
N46="46/10 CA-14 (anti-vacuidad) la tabla medida no es constante: hay deny y allow en las 24 celdas"
if [ -z "$FILTRO" ] || printf '%s' "$N46" | grep -qi -- "$FILTRO"; then
  nd46="$(printf '%s\n' "$TABLA46" | grep -c ' deny$')"; na46="$(printf '%s\n' "$TABLA46" | grep -c ' allow$')"
  if [ $((nd46 + na46)) -ne 24 ]; then
    echo "  FAIL  $N46  la tabla trae $((nd46 + na46)) celdas y no 24 ($nd46 deny, $na46 allow): el sondeo no midio lo que dice medir"; FAIL=$((FAIL+1))
  elif [ "$nd46" -eq 0 ] || [ "$na46" -eq 0 ]; then
    echo "  FAIL  $N46  las 24 celdas dieron el MISMO veredicto ($nd46 deny, $na46 allow): el hook no esta decidiendo y el emparejamiento pasaria por constancia"; FAIL=$((FAIL+1))
  else
    echo "  PASS  $N46  (24 celdas medidas con el hook real: $nd46 deny y $na46 allow)"; PASS=$((PASS+1))
  fi
fi
