# Sección 46 del banco (mitad 2 de 2) — 46-emparejamiento-texto-y-hook-2-denominadores-y-mudas
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco) — tampoco de su otra mitad, y por eso la
# maquinaria propia está DUPLICADA en las dos: es lo que `PISO_AUTONOMO_SECCION` contabiliza.
#
# POR QUÉ HAY DOS MITADES: `CA-18`. Al entrar la reparación de la DERIVACIÓN VACÍA el archivo único llegó
# a 592 líneas contra un techo de 400, y el piso NO se infla para caber —regresión declarada en
# `REQ-014`—, así que se parte. El corte va por VERBO: la mitad 1 CONTRASTA (el emparejamiento
# texto↔hook, sus suelos, las gemelas y los dos discriminantes); esta mitad 2 DECLARA (los
# denominadores y las sedes detectadas que no se pudieron interpretar, con regresión y control).
#
# EL CONTRATO COMPLETO DE LA SECCIÓN ESTÁ EN LA MITAD 1 y no se copia aquí: qué mide y por qué no
# cabe en la 44, de dónde sale el instrumento (la sonda fechada del `qa-tester` del 2026-09-11
# sobre `98f0ecd`), las DOS direcciones de fail-before y lo que la sección NO mide. Esta mitad
# añade el reverso del emparejamiento: lo que NO se pudo contrastar.
#
# TRES ESTADOS, Y NO DOS — la reparación de la DERIVACIÓN VACÍA (hallazgo de Codex del 2026-09-12
# sobre `5d1b1d1`), y aquí es donde se publica: una afirmación puede estar DETECTADA (el barrido la
# trajo), INTERPRETADA (se leyeron de ella celdas) y CONTRASTADA (se compararon con el hook real).
# Hasta esta vuelta sólo distinguía dos: lo que no lograba interpretar lo descontaba con un
# `continue` MUDO y el caso pasaba en verde con las celdas de las otras sedes. Medido: insertada
# en §13 la frase «Un `QA:` pendiente no deja cerrar en `ligero`» —FALSA, porque por VALOR un
# `QA:` no-`aprobado` SÍ cierra en `ligero`—, la sección daba 17 PASS · 0 FAIL y publicaba «2 de 5
# sedes lo declaran»: doce celdas verdes tapaban una sede muda. La corrección NO ensancha el
# reconocedor —eso cubriría ESA frase y no la CLASE—: trata el ESTADO «derivación VACÍA», en el
# que cae cualquier sede detectada y no interpretada.
#
# EL CONJUNTO DE SEDES SE DERIVA, NO SE ESCRIBE (`CA-14`, «Dado»): la unidad de §13 —fila o
# párrafo— nombra una clave de veredicto (`` `QA: `` o `` `Seguridad: ``) Y dice qué le ocurre al
# CIERRE. Esa segunda mitad es una FAMILIA reconocida por expresión, no una lista; residuo
# declarado: una forma que no case deja esa sede FUERA, y por eso cada corrida PUBLICA el
# denominador, que es lo que hace visible un conjunto que encoge.
CASOS_ESPERADOS_SECCION=8
PISO_AUTONOMO_SECCION=221  # 37 preámbulo con sus dos declaraciones y el titular (líneas 1-37) + 144 maquinaria propia, que el corredor no tiene: el barrido por propiedad, el partidor de oraciones con sus dos reconocedores, el extractor entre anclas, los tres lectores de niveles, el derivador de celdas, el lector de estado `interp46` con su `motivo46`, el constructor de REQ y la sonda que devuelve la decisión del hook como VALOR (líneas 44-187) + 40 bloque indivisible mayor (el caso `46/13`, el CONTROL de la regresión, líneas 361-400) · REQ-014 CA-18 · REGLA para re-derivar los tres términos sin preguntar: «preámbulo» son las líneas hasta el titular inclusive; un «bloque» es un grupo de líneas consecutivas sin blanca en medio; «maquinaria» es la que esta mitad define porque el corredor no la tiene, no una copia de otra parte, y va DUPLICADA en la otra mitad porque ninguna sección hace `source` de otra (invariante 4)

seccion_nueva "--- 46/6 · los DENOMINADORES del barrido, y las sedes que se detectaron y no se pudieron comprobar (REQ-024 CA-14) ---"

REPO46="${SEC_DIR%/}/../../../.."
RAIZ46="${ARNES_DOCS_RAIZ:-$REPO46}"
DOCS46="AGENTS.md templates/AGENTS.md.tpl"
ESCALERA46="ligero estandar critico"   # el orden del rigor, que es el del propio proyecto

# --- MAQUINARIA PROPIA, y va con su motivo -----------------------------------------
# Ningún ayudante del corredor barre un documento por propiedad, ni deriva celdas de una frase,
# ni devuelve la decisión del hook como VALOR (el compartido `check` la compara contra una
# esperada, y aquí la esperada sale del TEXTO). La única que ejecuta un hook es `dec46`, con su
# guarda: un JSON vacío no es un caso, es un caso que no se ejecutó.
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
interp46() {   # <sede> -> las combinaciones clave/eje que SÍ derivan celdas; VACÍO = sede MUDA
  # La función que separa DETECTAR de COMPROBAR: `barre46` DETECTA, `deriva46` INTERPRETA, el
  # emparejador CONTRASTA. Sin celdas no hay nada que contrastar, y eso no puede pasar por verde.
  local t="$1" c e out=''
  for c in QA Seguridad; do
    for e in valor ausencia; do
      case "$(deriva46 "$t" "$c" "$e")" in '') ;; *) out="$out $c/$e" ;; esac
    done
  done
  printf '%s' "${out# }"
}
motivo46() {   # <sede MUDA> -> por qué no se pudo interpretar, en los términos que el instrumento SÍ conoce
  # Dice lo que la máquina sabe y nada más: por qué entró al conjunto y qué le faltó. NO
  # diagnostica la causa —orden de las firmas, posibilidad en vez de necesidad, redacción nueva—,
  # porque distinguirlas exigiría el analizador del español que `CA-14` prohíbe: un motivo
  # inventado reaparece como diagnóstico falso.
  local t="$1" claves=''
  case "$t" in *'`QA:'*) claves='`QA:`' ;; esac
  case "$t" in *'`Seguridad:'*) claves="${claves:+$claves y }\`Seguridad:\`" ;; esac
  printf 'entro al conjunto porque nombra %s y afirma sobre el CIERRE, y ninguna de las 4 derivaciones (2 claves x 2 ejes) reconocio su forma: no se pudo leer en que NIVELES ni en que ESTADO de la llave cae, asi que no hay celda que contrastar' "$claves"
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
# 2 claves × 2 ejes × 3 rigores × 2 estados de la llave: `CA-14 (ii)` pide no menos de 12 en el
# eje del VALOR y `(iii)` otras tantas en el de la AUSENCIA. Se mide una vez porque el hook no
# depende del documento: lo que cambia de un caso a otro es lo que el TEXTO promete.
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

# --- ANTI-VACUIDAD: EL DENOMINADOR DEL BARRIDO, PUBLICADO POR DOCUMENTO -----------
# `CA-14`: se publica cuántas SEDES encontró el barrido y cuántas afirmaciones hay en cada una, y
# se aborta con SKIP —nunca PASS— si cualquiera de los dos sale 0: «ninguna sede promete de más»
# es cierto POR VACÍO con el conjunto vacío, y eso es lo que `REQ-020` caza. UNA FRASE NO ES UNA
# COMPARACIÓN, y llamarlas igual es lo que ocultó la DERIVACIÓN VACÍA: se publicaba «afirmaciones
# COMPROBADAS por sede» imprimiendo las frases DETECTADAS por el partidor, y de la sede muda
# decía `[1]` igual que de una cuyas celdas sí se contrastaron. Van ya por separado, `<f>f/<c>c`:
# frases detectadas y comparaciones derivadas de esa sede. `0c` es una sede muda.
for d46 in $DOCS46; do
  N46="46/6 CA-14 (anti-vacuidad) [$d46] el barrido publica su denominador, distinguiendo FRASES detectadas de COMPARACIONES contrastadas"
  if [ -n "$FILTRO" ] && ! printf '%s' "$N46" | grep -qi -- "$FILTRO"; then continue; fi
  ns46=0; sinafirm46=''; detalle46=''; c46=0; e46=''
  while IFS= read -r s46; do
    [ -z "$s46" ] && continue
    ns46=$((ns46 + 1))
    na46="$(oraciones46 "$s46" consec | grep -c .)"
    nc46=0
    for k46 in QA Seguridad; do
      for e46 in valor ausencia; do
        c46="$(deriva46 "$s46" "$k46" "$e46" | grep -c .)"; nc46=$((nc46 + c46))
      done
    done
    detalle46="$detalle46 [${na46}f/${nc46}c]"
    [ "$na46" -eq 0 ] && sinafirm46="$sinafirm46 «$(nom46 "$s46")…»"
  done <<< "$(sedes46 "$d46")"
  if [ "$ns46" -eq 0 ]; then
    echo "  SKIP  $N46  el barrido encontro 0 sedes (suelo 1): con el conjunto vacio, «ninguna promete de mas» es cierto por vacio"; SKIP=$((${SKIP:-0} + 1))
  elif [ -n "$sinafirm46" ]; then
    echo "  SKIP  $N46  $ns46 sedes, y alguna con 0 frases detectadas (suelo 1 por sede):$sinafirm46"; SKIP=$((${SKIP:-0} + 1))
  else
    echo "  PASS  $N46  ($ns46 sedes barridas; por sede <frases detectadas>f/<comparaciones contrastadas>c:$detalle46 — 0c es sede MUDA, y la identifica 46/11)"; PASS=$((PASS+1))
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

# --- EL REGISTRO DE LAS SEDES MUDAS: DETECTADA NO ES COMPROBADA ------
# Aquí la sede detectada y no interpretada queda IDENTIFICADA con su motivo.
# Y NO ACREDITAR ES SKIP, no PASS y no FAIL. FAIL diría que el DOCUMENTO miente, y eso es
# justamente lo que el instrumento no pudo comprobar; PASS diría que se comprobó. El SKIP dice lo
# único cierto —«detectada, no interpretada, sin acreditar»— y el corredor lo recapitula con su
# motivo al cerrar la corrida, que es la política vigente para un resultado inconcluso.
for d46 in $DOCS46; do
  N46="46/11 CA-14 (anti-vacuidad) [$d46] toda sede DETECTADA queda interpretada, o IDENTIFICADA con su motivo y sin acreditar"
  if [ -n "$FILTRO" ] && ! printf '%s' "$N46" | grep -qi -- "$FILTRO"; then continue; fi
  ns46=0; nm46=0; lista46=''
  while IFS= read -r s46; do
    [ -z "$s46" ] && continue
    ns46=$((ns46 + 1))
    if [ -z "$(interp46 "$s46")" ]; then
      nm46=$((nm46 + 1))
      lista46="$lista46 · «$(nom46 "$s46")…» [$(motivo46 "$s46")]"
    fi
  done <<< "$(sedes46 "$d46")"
  if [ "$ns46" -eq 0 ]; then
    echo "  SKIP  $N46  el barrido encontro 0 sedes (suelo 1): sin conjunto no hay nada que interpretar ni que declarar mudo"; SKIP=$((${SKIP:-0} + 1))
  elif [ "$nm46" -eq 0 ]; then
    echo "  PASS  $N46  ($ns46 sedes detectadas y las $ns46 interpretadas: ninguna afirmacion se descuenta en silencio)"; PASS=$((PASS+1))
  else
    echo "  SKIP  $N46  $nm46 de $ns46 sedes DETECTADAS sin interpretar: no se acreditan y no se descuentan en silencio$lista46"; SKIP=$((${SKIP:-0} + 1))
  fi
done

# --- LA REGRESIÓN DE LA DERIVACIÓN VACÍA, CON SU CONTROL AL LADO --------------------------
# Los dos casos son la misma medición con el signo cambiado, y por eso van juntos: si sólo
# estuviera el positivo, un instrumento que declarase MUDA a toda sede lo pondría en verde y
# habría cambiado un silencio por otro. La inyección va SIEMPRE sobre una COPIA en `$PROJ`; los
# documentos del candidato no se tocan.
cuenta46() {   # <archivo> -> «<detectadas> <interpretadas> <mudas>»
  local s ndet=0 nint=0 nmud=0
  while IFS= read -r s; do
    [ -z "$s" ] && continue
    ndet=$((ndet + 1))
    if [ -n "$(interp46 "$s")" ]; then nint=$((nint + 1)); else nmud=$((nmud + 1)); fi
  done <<< "$(barre46 "$1")"
  printf '%s %s %s' "$ndet" "$nint" "$nmud"
}
inyecta46() {   # <origen> <destino> <parrafo> — lo mete en §13, delante del ancla, como unidad propia
  awk -v f="$3" -v anc='**Anti-deriva — el techo honesto:**' '
    !hecho && index($0, anc) == 1 { print f; print ""; hecho = 1 }
    { print }' "$1" > "$2"
}
CTRL46="$PROJ/doc-control.md"
cp "$RAIZ46/AGENTS.md" "$CTRL46" 2>/dev/null
read -r DET46 INT46 MUD46 <<< "$(cuenta46 "$CTRL46")"

# La frase del hallazgo, palabra por palabra: FALSA en el escenario que el hook mide y no
# interpretable por el derivador. Antes de la reparación esto daba 17 PASS · 0 FAIL.
N46="46/12 CA-14 regresion de la DERIVACION VACIA: una afirmacion FALSA que el derivador NO interpreta queda identificada y SIN acreditar"
if [ -z "$FILTRO" ] || printf '%s' "$N46" | grep -qi -- "$FILTRO"; then
  FALSA46='Un `QA:` pendiente no deja cerrar en `ligero`.'
  INY46="$PROJ/doc-inyectado-falso.md"
  inyecta46 "$CTRL46" "$INY46" "$FALSA46"
  read -r det46 int46 mud46 <<< "$(cuenta46 "$INY46")"
  citada46=''
  while IFS= read -r s46; do
    [ -z "$s46" ] && continue
    [ -n "$(interp46 "$s46")" ] && continue
    case "$s46" in *'no deja cerrar en `ligero`'*) citada46=si ;; esac
  done <<< "$(barre46 "$INY46")"
  if [ "$DET46" -eq 0 ] || [ "$det46" -ne $((DET46 + 1)) ]; then
    echo "  FAIL  $N46  la inyeccion no llego al conjunto DETECTADO ($DET46 -> $det46 sedes): el caso no probaria nada"; FAIL=$((FAIL+1))
  elif [ "$int46" -ne "$INT46" ]; then
    echo "  FAIL  $N46  la frase falsa subio las INTERPRETADAS ($INT46 -> $int46): el derivador dice haberla leido, y no la lee"; FAIL=$((FAIL+1))
  elif [ "$mud46" -ne $((MUD46 + 1)) ]; then
    echo "  FAIL  $N46  la frase falsa NO subio las MUDAS ($MUD46 -> $mud46): se descuenta en silencio, que es el defecto de la DERIVACION VACIA"; FAIL=$((FAIL+1))
  elif [ -z "$citada46" ]; then
    echo "  FAIL  $N46  la frase falsa quedo sin interpretar pero NO se cita: sin la sede nombrada nadie puede ir a mirarla"; FAIL=$((FAIL+1))
  else
    echo "  PASS  $N46  (detectadas $DET46->$det46, interpretadas $INT46 sin moverse, mudas $MUD46->$mud46, y la sede sale CITADA: se declara no comprobada en vez de pasar en verde)"; PASS=$((PASS+1))
  fi
fi

# El control. Una afirmación VÁLIDA —del propio corpus, así que el derivador la reconoce por
# construcción— sube las INTERPRETADAS y NO las mudas, y sus celdas siguen cuadrando con el hook.
# Es lo que separa «el instrumento distingue» de «se volvió ciego y lo llama prudencia».
N46="46/13 CA-14 control de la DERIVACION VACIA: una afirmacion VALIDA insertada SI se interpreta y sus celdas siguen cuadrando con el hook"
if [ -z "$FILTRO" ] || printf '%s' "$N46" | grep -qi -- "$FILTRO"; then
  VALIDA46=''
  while IFS= read -r s46; do
    case "$(deriva46 "$s46" QA valor)" in '') ;; *) VALIDA46="$s46"; break ;; esac
  done <<< "$(sedes46 AGENTS.md)"
  INYV46="$PROJ/doc-inyectado-valido.md"
  [ -n "$VALIDA46" ] && inyecta46 "$CTRL46" "$INYV46" "$VALIDA46"
  malas46=0; celdas46=0; primera46=''
  if [ -n "$VALIDA46" ]; then
    while read -r llave46 rigor46 esp46; do
      [ -z "$esp46" ] && continue
      celdas46=$((celdas46 + 1))
      real46="$(celda46 QA valor "$llave46" "$rigor46")"
      if [ "$real46" != "$esp46" ]; then
        malas46=$((malas46 + 1))
        [ -n "$primera46" ] || primera46="promete $esp46 y el hook hace ${real46:-SIN MEDIR} (llave=$llave46, rigor=$rigor46)"
      fi
    done <<< "$(deriva46 "$VALIDA46" QA valor)"
    read -r detv46 intv46 mudv46 <<< "$(cuenta46 "$INYV46")"
  else
    detv46=0; intv46=0; mudv46=0
  fi
  if [ -z "$VALIDA46" ]; then
    echo "  SKIP  $N46  ninguna sede del corpus deriva celdas por VALOR de QA: no hay afirmacion valida con la que controlar"; SKIP=$((${SKIP:-0} + 1))
  elif [ "$mudv46" -ne "$MUD46" ]; then
    echo "  FAIL  $N46  una afirmacion VALIDA subio las MUDAS ($MUD46 -> $mudv46): el instrumento declara no comprobado lo que si puede comprobar"; FAIL=$((FAIL+1))
  elif [ "$intv46" -ne $((INT46 + 1)) ]; then
    echo "  FAIL  $N46  una afirmacion VALIDA no subio las INTERPRETADAS ($INT46 -> $intv46): el derivador dejo de leer lo que si lee"; FAIL=$((FAIL+1))
  elif [ "$celdas46" -eq 0 ]; then
    echo "  FAIL  $N46  la sede de control no derivo ninguna celda (suelo 1): el control seria cierto por vacio"; FAIL=$((FAIL+1))
  elif [ "$malas46" -ne 0 ]; then
    echo "  FAIL  $N46  la sede de control discrepa del hook en $malas46 de $celdas46 celdas: $primera46"; FAIL=$((FAIL+1))
  else
    echo "  PASS  $N46  (interpretadas $INT46->$intv46, mudas $MUD46 sin moverse, y las $celdas46 celdas de la sede de control cuadran con el hook real)"; PASS=$((PASS+1))
  fi
fi
