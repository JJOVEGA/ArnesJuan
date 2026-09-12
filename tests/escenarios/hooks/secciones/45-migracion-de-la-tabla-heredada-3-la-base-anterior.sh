# Sección 45 (3 de 3) del banco — 45-migracion-de-la-tabla-heredada-3-la-base-anterior
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna
# otra sección (invariantes 3 y 4 del README del banco).
#
# QUÉ MIDE Y POR QUÉ NO CABE EN LA 45/1. La parte 1 ejerce el merge con una base que YA TRAE
# los tres bloques (`v1.33.0`), y por eso sus 20 casos —27 con la parte 2— no vieron nunca
# este defecto: es un hueco de COBERTURA, no de redacción. Aquí la base es ANTERIOR al bloque,
# que es el caso de todo proyecto instalado antes de que el bloque naciera, y el de este mismo
# repositorio: su `.arnes/plantillas-origen/` está congelado en `v1.30.3` y el párrafo del
# aviso NO EXISTE antes de 1.31.0 (`QA-024-41`, `REQ-024 CA-12 (ii)`).
#
# EL DEFECTO QUE ESTA PARTE CAZA, medido antes del arreglo con `ARNES_MIG45_BASE=v1.30.3`
# sobre la parte 1: el párrafo del aviso salía `ELIMINADO → CONFLICTO: pendiente de resolver`,
# el titular quedaba `PARCIAL` y la Fase 5 NO subía `arnes_version`. Y no hay nada que una
# persona pueda resolver ahí: no existe conflicto: existe un bloque POSTERIOR a la base. El
# efecto es que el proyecto NO PUEDE MIGRAR NUNCA, en silencio y con dos de los tres bloques
# ya aplicados. La respuesta ya estaba escrita en la skill —«si no existía en la base,
# entonces sí es `NUEVO` y se añade»— y se perdió al transcribirla a la tabla de tres bloques.
#
# LOS DOS LÍMITES DEL PROPIETARIO, que son lo que cada caso comprueba por separado: se
# preservan las personalizaciones (`NUEVO` AÑADE, nunca sustituye; y si el proyecto ya tiene
# algo en esa ancla NO es `NUEVO`, vuelve al camino del conflicto) y no se permite una
# actualización incompleta (`UNKNOWN` es tan terminal como `CONFLICTO`: no sube
# `arnes_version` y no se declara migrada).
#
# AQUÍ VIVE TAMBIÉN LA COMPROBACIÓN (1), INSTALACIÓN NUEVA (`45/2` y `45/3`), que venía de la
# parte 1. No necesita el merge ni la línea base —`arnes-init` copia la plantilla y ya—, y en
# la parte 1 dejó de caber bajo el techo de `REQ-014 CA-18` al entrar la pregunta previa. Los
# nombres de caso NO cambian: renombrarlos rompería toda cita anterior a ellos.
#
# ESTA SECCIÓN NO EJECUTA NINGÚN HOOK, y por eso no usa `$HOOKS_DIR`: las rutas se derivan de
# `$SEC_DIR`, igual que en la parte 1, para que apuntar el banco a una instalación anterior
# (`ARNES_HOOKS_DIR`) siga midiendo los hooks viejos contra los textos de HOY. A cambio, TODO
# extractor trata el bloque VACÍO como FAIL o SKIP y nunca como igualdad.
#
# LAS TRES PALANCAS DE FAIL-BEFORE, y cada una dice qué deja de acreditar:
#   ARNES_DOCS_RAIZ=<árbol anterior>   la plantilla de DESTINO es otra: con una que no traiga
#                                      los bloques corregidos, `45/2`, `45/3` y el portero
#                                      salen ROJOS nombrando el bloque.
#   ARNES_MIG45_BASE3=<ref>            otra línea base. Por defecto `v1.30.3`, que es el origen
#                                      real de este repositorio y la razón de que exista esta
#                                      parte. Si la ref elegida SÍ trae el párrafo del aviso,
#                                      esta parte no mide lo que dice y se ABSTIENE.
#   ARNES_MIG45_PREV=off               apaga la PREGUNTA PREVIA contra la base, o sea restaura
#                                      el clasificador de antes del arreglo. El caso `45/32` la
#                                      apaga él mismo y exige que el defecto reaparezca: sin
#                                      eso, estos casos podrían estar verdes por otra razón.
#
# Y ABSTENERSE NO ES LO MISMO QUE FALLAR (`EST45C`): sin `.git`, sin el tag o con una base que
# no sirve para lo que esta parte mide, los casos del merge ABSTIENEN con SKIP y su motivo
# —nunca PASS: un clasificador que no pudo leer la base no ha clasificado nada—; pero que la
# plantilla de destino NO traiga uno de los tres bloques corregidos es EL DEFECTO que la
# familia 45 caza, y sale ROJO nombrando el bloque. Medido en la parte 1: con las dos causas
# en el mismo SKIP, el fail-before entero salía en abstenciones y 0 rojos.
#
# LAS ANCLAS ESTÁN DUPLICADAS RESPECTO DE LAS PARTES 1 Y 2, Y VA DICHO PORQUE ES UNA DECISIÓN:
# en `secciones/` no cabe un archivo auxiliar y ninguna sección hace `source` de otra (README
# del banco). Lo que esa duplicación NO tapa —que nadie compruebe que las copias coincidan— lo
# cierra `45/33`, que compara el CLASIFICADOR de esta parte con el de la parte 1 leyéndola como
# DATO, nunca ejecutándola; y `45/17`, en la parte 2, que exige que la guía declare las anclas.
CASOS_ESPERADOS_SECCION=17
PISO_AUTONOMO_SECCION=223  # 65 preámbulo con sus dos declaraciones y el titular (líneas 1-65) + 89 maquinaria propia, que el corredor no tiene: el materializador de línea base, el extractor de bloque, el contador, el clasificador con su pregunta previa, el sustituidor-insertador, el corredor de migración y los dos jueces (líneas 74-162) + 69 bloque indivisible mayor (las cinco tablas de anclas, los dos porteros y las cinco maquetas de proyecto, líneas 164-232: ningún caso de esta parte puede prescindir de ellos) · REQ-014 CA-18 · REGLA para re-derivar los tres términos sin preguntar: «preámbulo» son las líneas hasta el titular inclusive; un «bloque» es un grupo de líneas consecutivas sin blanca en medio; «maquinaria» es la que esta parte define porque el corredor no la tiene, no una copia de otra parte

seccion_nueva "--- 45/3 · la base mas VIEJA que el bloque: NUEVO se anade, y el proyecto migra (QA-024-41) ---"

REPO45C="${SEC_DIR%/}/../../../.."
RAIZ45C="${ARNES_DOCS_RAIZ:-$REPO45C}"
TPL45C="$RAIZ45C/templates/AGENTS.md.tpl"
BASE45C="${ARNES_MIG45_BASE3:-v1.30.3}"
PREV45C="${ARNES_MIG45_PREV:-on}"
DIR45C="$RAIZ/mig45c-$BASHPID"; mkdir -p "$DIR45C"

# --- MAQUINARIA PROPIA, y va con su motivo -----------------------------------------
# Ningún ayudante del corredor materializa un árbol anterior, extrae un bloque de un documento,
# lo sustituye ni lo inserta: los que hay ejecutan hooks y juzgan su respuesta.
MOT45C='-'
base45c() {   # <destino> -> 0 si la plantilla de la version de ORIGEN quedo materializada
  local dst="$1"
  MOT45C='-'
  [ -e "$REPO45C/.git" ] || { MOT45C='no-hay-.git-en-el-repositorio'; return 1; }
  git -C "$REPO45C" rev-parse -q --verify "$BASE45C^{tree}" >/dev/null 2>&1 \
    || { MOT45C="la-referencia-no-resuelve:$BASE45C"; return 1; }
  git -C "$REPO45C" show "$BASE45C:templates/AGENTS.md.tpl" > "$dst" 2>/dev/null \
    || { MOT45C="la-referencia-no-trae-templates/AGENTS.md.tpl:$BASE45C"; return 1; }
  [ -s "$dst" ] || { MOT45C="la-plantilla-de-$BASE45C-salio-vacia"; return 1; }
  MOT45C="ok:$BASE45C"
  return 0
}
bloq45c() {   # <archivo> <ancla-de-inicio> -> el bloque, o vacio
  awk -v a="$2" '
    !d && index($0, a) { d = 1; l = $0; sub(/\r$/, "", l); print l
                         if (substr($0, 1, 1) == "|") exit
                         next }
    d { if ($0 ~ /^[ \t]*\r?$/) exit; l = $0; sub(/\r$/, "", l); print l }
  ' "$1" 2>/dev/null
}
cuenta45c() {   # <archivo> <ancla> -> cuantas lineas lo contienen
  awk -v a="$2" 'index($0, a) { n++ } END { print n + 0 }' "$1" 2>/dev/null
}
# EL CLASIFICADOR, transcripcion de la tabla de la skill y nada mas. `nb` es LA PREGUNTA PREVIA:
# cuantas veces trae la BASE el ancla de origen. 0 -> el bloque es POSTERIOR a la base.
clas45c() {   # <archivo-proyecto> <indice de bloque> <archivo-base> -> estado
  local proy="$1" i="$2" base="$3" no nd nb bp bb
  no="$(cuenta45c "$proy" "${AO45C[$i]}")"; nd="$(cuenta45c "$proy" "${AD45C[$i]}")"
  nb=1; [ "$PREV45C" = on ] && nb="$(cuenta45c "$base" "${AO45C[$i]}")"
  if [ "$no" -ge 2 ] || [ "$nd" -ge 2 ] || [ "$nb" -ge 2 ] || { [ "$no" -eq 1 ] && [ "$nd" -eq 1 ]; }; then printf 'UNKNOWN'; return; fi
  if [ "$no" -eq 0 ] && [ "$nd" -eq 1 ]; then printf 'APLICADO-YA'; return; fi
  if [ "$nb" -eq 0 ]; then   # el bloque es POSTERIOR a la base: NUEVO si no hay nada en esa ancla
    [ "$no" -eq 1 ] && { printf 'MODIFICADO'; return; }
    [ "$(cuenta45c "$proy" "${AINS45C[$i]}")" -eq 1 ] && printf 'NUEVO' || printf 'UNKNOWN'; return
  fi
  if [ "$no" -eq 0 ] && [ "$nd" -eq 0 ]; then printf 'ELIMINADO'; return; fi
  bp="$(bloq45c "$proy" "${AI45C[$i]}")"; bb="$(bloq45c "$base" "${AI45C[$i]}")"
  if [ -z "$bp" ] || [ -z "$bb" ]; then printf 'UNKNOWN'; return; fi
  [ "$bp" = "$bb" ] && printf 'INTACTO' || printf 'MODIFICADO'
}
sust45c() {   # <archivo> <ancla-inicio> <archivo-con-el-bloque-destino> [ins]
  # Con <ins> no vacio el ancla es la de INSERCION y la linea casada SE CONSERVA: `NUEVO` anade
  # delante y no sustituye nada. Sin el, el ancla es la de ORIGEN y el bloque se sustituye.
  local f="$1" ao="$2" nuevo="$3" ins="${4:-}" tmp="$1.sust"
  awk -v a="$ao" -v nv="$nuevo" -v ins="$ins" '
    !d && index($0, a) { d = 1
                         while ((getline l < nv) > 0) print l
                         close(nv)
                         if (ins != "") { if (substr($0, 1, 1) != "|") print ""; print; next }
                         if (substr($0, 1, 1) == "|") next
                         salta = 1; next }
    salta { if ($0 ~ /^[ \t]*\r?$/) { salta = 0; print }; next }
    { print }
  ' "$f" > "$tmp" 2>/dev/null && mv "$tmp" "$f"
}
migra45c() {   # <dir-proyecto> <archivo-base> -> escribe .arnes/migracion.md
  local proy="$1" base="$2" i est reg parcial=no
  reg="$proy/.arnes/migracion.md"
  mkdir -p "$proy/.arnes"; : > "$reg"
  for i in 0 1 2; do
    est="$(clas45c "$proy/AGENTS.md" "$i" "$base")"
    case "$est" in
      INTACTO)     sust45c "$proy/AGENTS.md" "${AI45C[$i]}" "$DIR45C/dest-$i.txt"
                   printf '%s: APLICADO\n' "${NOM45C[$i]}" >> "$reg" ;;
      NUEVO)       sust45c "$proy/AGENTS.md" "${AINS45C[$i]}" "$DIR45C/dest-$i.txt" ins
                   printf '%s: APLICADO (NUEVO: no existia en la base; se anade sin sustituir nada)\n' "${NOM45C[$i]}" >> "$reg" ;;
      APLICADO-YA) printf '%s: APLICADO (ya estaba; no se toca)\n' "${NOM45C[$i]}" >> "$reg" ;;
      MODIFICADO|ELIMINADO)
                   printf '%s: CONFLICTO: pendiente de resolver (%s; el contenido del proyecto se conserva y el bloque de destino se cita sin aplicar)\n' "${NOM45C[$i]}" "$est" >> "$reg"
                   parcial=si ;;
      *)           printf '%s: UNKNOWN: detenido\n' "${NOM45C[$i]}" >> "$reg"; parcial=si ;;
    esac
  done
  if [ "$parcial" = si ]; then
    printf 'RESULTADO: PARCIAL\n' >> "$reg"
  else
    printf 'RESULTADO: COMPLETA\n' >> "$reg"
    printf '1.34.0\n' > "$proy/.arnes/version-migrada"
  fi
}
juzg45c() {   # <nombre> <si|no ya evaluado> <detalle del fallo>
  if [ "$2" = si ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  $3"; FAIL=$((FAIL+1)); fi
}
mide45c() { [ -z "$FILTRO" ] || printf '%s' "$1" | grep -qi -- "$FILTRO"; }

# --- LAS ANCLAS Y LAS MAQUETAS ----------------------------------------------------
NOM45C=("fila del CIERRE" "fila del ORDEN de las firmas" "parrafo del aviso")
AO45C=('No completar sin `QA: aprobado`'
       'Seguridad no firma lo que QA no ha validado (salvo'
       '**no deniega** la edición: ese REQ no podrá cerrarse')
AD45C=('El CIERRE juzga DOS cosas distintas'
       'tampoco cuando la línea `QA:` no llega a declararse'
       'el aviso lleva su condición')
AI45C=('No completar sin `QA: aprobado`'
       'Seguridad no firma lo que QA no ha validado (salvo'
       '**Un hook que avisa sin decidir.**')
AID45C=('El CIERRE juzga DOS cosas distintas'
        'tampoco cuando la línea `QA:` no llega a declararse'
        '**Un hook que avisa sin decidir.**')
AINS45C=('La transición a `completado` no se hace por shell'
         'Los campos del REQ valen sólo en la cabecera'
         '**Es una barandilla, no una jaula.**')
BASE45CF="$DIR45C/base.tpl"; BASE45C_OK=no
base45c "$BASE45CF" && BASE45C_OK=si
MAQ45C=no; EST45C='ok'
gate45c() {   # <nombre> -> 0 si se puede juzgar; si no, emite SKIP o FAIL y devuelve 1
  case "$EST45C" in
    ok)     return 0 ;;
    skip:*) echo "  SKIP  $1  ${EST45C#skip:}" ;;
    *)      echo "  FAIL  $1  ${EST45C#fail:}"; FAIL=$((FAIL+1)) ;;
  esac
  return 1
}
if [ "$BASE45C_OK" = si ] && [ -f "$TPL45C" ] && [ "$(cuenta45c "$BASE45CF" "${AO45C[2]}")" -eq 0 ]; then
  for i45c in 0 1 2; do bloq45c "$TPL45C" "${AID45C[$i45c]}" > "$DIR45C/dest-$i45c.txt"; done
  for p45c in viejo viejoperso viejodoble viejosinsitio discri; do
    mkdir -p "$DIR45C/$p45c/.arnes/plantillas-origen"
    cp "$BASE45CF" "$DIR45C/$p45c/AGENTS.md"
    cp "$BASE45CF" "$DIR45C/$p45c/.arnes/plantillas-origen/AGENTS.md.tpl"
    printf '{ "arnes_version": "%s" }\n' "${BASE45C#v}" > "$DIR45C/$p45c/.arnes/config.json"
  done
  # `viejoperso`: el proyecto SI tiene texto suyo en el ancla del parrafo del aviso, aunque la
  # base no lo tenga. Es el caso de este mismo repositorio y el limite del propietario: hay algo
  # ahi, asi que NO es `NUEVO` — y la base no puede decir quien lo escribio.
  PERSO45C='**Un hook que avisa sin decidir.** En ESTE proyecto el aviso **no deniega** la edición: ese REQ no podrá cerrarse, y ademas lo revisa el area legal.'
  for v45c in viejoperso viejodoble; do
    awk -v a="${AINS45C[2]}" -v nv="$PERSO45C" 'index($0, a) && !d { print nv; print ""; d = 1 } { print }' \
      "$BASE45CF" > "$DIR45C/$v45c/AGENTS.md.n" && mv "$DIR45C/$v45c/AGENTS.md.n" "$DIR45C/$v45c/AGENTS.md"
  done
  awk -v a="${AINS45C[2]}" -v nv="$PERSO45C" 'index($0, a) && !d { print nv; print ""; d = 1 } { print }' \
    "$DIR45C/viejodoble/AGENTS.md" > "$DIR45C/viejodoble/AGENTS.md.n" \
    && mv "$DIR45C/viejodoble/AGENTS.md.n" "$DIR45C/viejodoble/AGENTS.md"
  awk -v a="${AINS45C[2]}" 'index($0, a) { print; print "" } { print }' \
    "$DIR45C/viejosinsitio/AGENTS.md" > "$DIR45C/viejosinsitio/AGENTS.md.n" \
    && mv "$DIR45C/viejosinsitio/AGENTS.md.n" "$DIR45C/viejosinsitio/AGENTS.md"
  [ -s "$DIR45C/dest-0.txt" ] && [ -s "$DIR45C/dest-1.txt" ] && [ -s "$DIR45C/dest-2.txt" ] && MAQ45C=si
fi
if [ "$MAQ45C" != si ]; then
  if [ "$BASE45C_OK" != si ]; then EST45C="skip:no se pudo materializar la linea base ($MOT45C): un clasificador que no pudo leer la base no ha clasificado nada"
  elif [ ! -f "$TPL45C" ]; then EST45C="fail:no existe la plantilla de destino $TPL45C: no hay texto corregido que llevar a ningun proyecto"
  elif [ "$(cuenta45c "$BASE45CF" "${AO45C[2]}")" -ne 0 ]; then EST45C="skip:la linea base $BASE45C SI trae el parrafo del aviso: esta parte mide una base ANTERIOR al bloque y con esta no lo seria"
  else
    vac45c=''
    for i45c in 0 1 2; do [ -s "$DIR45C/dest-$i45c.txt" ] || vac45c="$vac45c ${NOM45C[$i45c]}"; done
    EST45C="fail:la plantilla de destino no trae el bloque corregido:$vac45c — un proyecto que migre hoy no recibiria esa correccion"
  fi
fi
NUEVO45C=no
if [ -f "$TPL45C" ]; then mkdir -p "$DIR45C/nuevo"; cp "$TPL45C" "$DIR45C/nuevo/AGENTS.md"; NUEVO45C=si; fi
gaten45c() {   # <nombre> -> 0 si hay maqueta de instalacion nueva que medir
  [ "$NUEVO45C" = si ] && return 0
  echo "  FAIL  $1  no existe la plantilla $TPL45C: no hay texto que un proyecto nuevo pueda recibir"
  FAIL=$((FAIL+1)); return 1
}

# --- (1) y (2) COMPROBACION 1: INSTALACION NUEVA ----------------------------------
# Lo que `arnes-init` copia es `templates/AGENTS.md.tpl`. Se mide sobre la COPIA del proyecto
# y no sobre la plantilla, porque lo que se contrata es lo que el proyecto RECIBE.
for i45c in 0 1 2; do
  N45C="45/2 instalacion nueva: el proyecto recibe CORREGIDO el bloque «${NOM45C[$i45c]}»"
  if mide45c "$N45C"; then
    if ! gaten45c "$N45C"; then :
    else
      n45c="$(cuenta45c "$DIR45C/nuevo/AGENTS.md" "${AD45C[$i45c]}")"
      juzg45c "$N45C" "$([ "$n45c" -eq 1 ] && echo si || echo no)" \
        "el ancla de DESTINO aparece $n45c veces (se espera 1) en el AGENTS.md que sale de la plantilla"
    fi
  fi
  N45C="45/3 instalacion nueva: no sobrevive la promesa vieja del bloque «${NOM45C[$i45c]}»"
  if mide45c "$N45C"; then
    if ! gaten45c "$N45C"; then :
    else
      n45c="$(cuenta45c "$DIR45C/nuevo/AGENTS.md" "${AO45C[$i45c]}")"
      juzg45c "$N45C" "$([ "$n45c" -eq 0 ] && echo si || echo no)" \
        "el ancla de ORIGEN sigue apareciendo $n45c veces: se corrigio el documento del arnes y no la plantilla que heredan los proyectos"
    fi
  fi
done

# --- (3) EL INSTRUMENTO ANTES DEL RESULTADO ----------------------------------------
# Sin esto, «NUEVO» no acreditaria nada: si la base ya trajera el parrafo, no habria base
# ANTERIOR al bloque que medir y estos casos estarian midiendo otra cosa.
N45C="45/24 instrumento: la linea base es ANTERIOR al bloque — no trae el parrafo y la plantilla de hoy si"
if mide45c "$N45C"; then
  if gate45c "$N45C"; then
    juzg45c "$N45C" "$([ "$(cuenta45c "$BASE45CF" "${AI45C[2]}")" -eq 0 ] && [ "$(cuenta45c "$TPL45C" "${AI45C[2]}")" -eq 1 ] && [ "$(cuenta45c "$BASE45CF" "${AO45C[0]}")" -eq 1 ] && echo si || echo no)" \
      "base y destino no se distinguen como esta parte necesita (parrafo en la base=$(cuenta45c "$BASE45CF" "${AI45C[2]}"), en la plantilla=$(cuenta45c "$TPL45C" "${AI45C[2]}"), fila del cierre en la base=$(cuenta45c "$BASE45CF" "${AO45C[0]}"))"
  fi
fi

# --- (4)-(8) EL CASO REAL: un proyecto mas viejo que el bloque ---------------------
CL45C=''; SAL45C=0; ESP45C=0; SEC45C='no medido'
if [ "$MAQ45C" = si ]; then
  cp "$DIR45C/viejo/AGENTS.md" "$DIR45C/viejo-antes.md"
  for i45c in 0 1 2; do
    e45c="$(clas45c "$DIR45C/viejo/AGENTS.md" "$i45c" "$BASE45CF")"; CL45C="$CL45C${CL45C:+/}$e45c"
    nd45c="$(grep -c . "$DIR45C/dest-$i45c.txt")"
    if [ "$e45c" = NUEVO ]; then
      case "${AINS45C[$i45c]}" in '|'*) ESP45C=$((ESP45C + nd45c)) ;; *) ESP45C=$((ESP45C + nd45c + 1)) ;; esac
    else
      ESP45C=$((ESP45C + nd45c - $(bloq45c "$BASE45CF" "${AI45C[$i45c]}" | grep -c .)))
    fi
  done
  migra45c "$DIR45C/viejo" "$BASE45CF"
  cp "$DIR45C/viejo/AGENTS.md" "$DIR45C/viejo-1a.md"
  migra45c "$DIR45C/viejo" "$BASE45CF"     # segunda corrida: no puede tocar nada
  SAL45C=$(( $(grep -c '' "$DIR45C/viejo/AGENTS.md") - $(grep -c '' "$DIR45C/viejo-antes.md") ))
  SEC45C="$(diff <(grep '^## ' "$DIR45C/viejo-antes.md") <(grep '^## ' "$DIR45C/viejo/AGENTS.md") 2>&1)"
fi
N45C="45/25 base anterior: el bloque POSTERIOR a la base clasifica NUEVO y ninguno queda en conflicto"
mide45c "$N45C" && { gate45c "$N45C" && \
  juzg45c "$N45C" "$([ "$CL45C" = "INTACTO/INTACTO/NUEVO" ] && echo si || echo no)" \
    "clasifico «$CL45C» y se esperaba «INTACTO/INTACTO/NUEVO»: los dos primeros bloques SI estan en $BASE45C, el parrafo del aviso NO — y un bloque que no existia en la base es NUEVO, no ELIMINADO ni MODIFICADO"; }

N45C="45/26 base anterior: los tres quedan APLICADOS, el titular es COMPLETA y la Fase 5 SI sube arnes_version"
mide45c "$N45C" && { gate45c "$N45C" && \
  juzg45c "$N45C" "$([ "$(grep -c ': APLICADO' "$DIR45C/viejo/.arnes/migracion.md" 2>/dev/null)" -eq 3 ] && grep -q '^RESULTADO: COMPLETA$' "$DIR45C/viejo/.arnes/migracion.md" 2>/dev/null && [ -f "$DIR45C/viejo/.arnes/version-migrada" ] && echo si || echo no)" \
    "un conflicto que nadie puede resolver deja al proyecto sin migrar PARA SIEMPRE; el registro dice: $(tr '\n' '/' < "$DIR45C/viejo/.arnes/migracion.md" 2>/dev/null)"; }

N45C="45/27 base anterior: NUEVO ANADE y no sustituye — saldo exacto, en su sitio y sin mover ninguna seccion"
if mide45c "$N45C"; then
  if gate45c "$N45C"; then
    # El parrafo tiene que quedar ANTES del ancla de insercion, que es el sitio que ocupa en la
    # plantilla de destino. Se comprueba por numero de linea, no por presencia: presente y en
    # otro sitio seria una §13 con el aviso detras de la barandilla.
    lb45c="$(awk -v a="${AI45C[2]}" 'index($0, a) { print NR; exit }' "$DIR45C/viejo/AGENTS.md")"
    li45c="$(awk -v a="${AINS45C[2]}" 'index($0, a) { print NR; exit }' "$DIR45C/viejo/AGENTS.md")"
    juzg45c "$N45C" "$([ "$SAL45C" -eq "$ESP45C" ] && [ -z "$SEC45C" ] && [ -n "$lb45c" ] && [ -n "$li45c" ] && [ "$lb45c" -lt "$li45c" ] && echo si || echo no)" \
      "saldo de lineas=$SAL45C y el esperado por los tres bloques es $ESP45C; titulos movidos=<$SEC45C>; el parrafo quedo en la linea ${lb45c:-ninguna} y su ancla de insercion en la ${li45c:-ninguna}"
  fi
fi

N45C="45/28 base anterior: la segunda corrida es idempotente BYTE A BYTE y deja UNA sola copia"
mide45c "$N45C" && { gate45c "$N45C" && \
  juzg45c "$N45C" "$(cmp -s "$DIR45C/viejo-1a.md" "$DIR45C/viejo/AGENTS.md" && [ "$(cuenta45c "$DIR45C/viejo/AGENTS.md" "${AI45C[2]}")" -eq 1 ] && [ "$(cuenta45c "$DIR45C/viejo/AGENTS.md" "${AD45C[2]}")" -eq 1 ] && echo si || echo no)" \
    "la segunda corrida cambio el archivo o dejo $(cuenta45c "$DIR45C/viejo/AGENTS.md" "${AI45C[2]}") copias del parrafo: un NUEVO que se vuelve a anadir duplica la seccion en cada actualizacion"; }

N45C="45/29 base anterior: la instantanea de .arnes/plantillas-origen/ sigue intacta"
mide45c "$N45C" && { gate45c "$N45C" && \
  juzg45c "$N45C" "$(cmp -s "$BASE45CF" "$DIR45C/viejo/.arnes/plantillas-origen/AGENTS.md.tpl" && echo si || echo no)" \
    "la instantanea cambio: retocar el origen congelado no limpia el diff, falsifica la comparacion de la que cuelga todo"; }

# --- (9)-(11) LOS DOS LIMITES DEL PROPIETARIO, cada uno con su caso ----------------
CL45CP=''; CL45CD=''; CL45CS=''
if [ "$MAQ45C" = si ]; then
  cp "$DIR45C/viejoperso/AGENTS.md" "$DIR45C/viejoperso-antes.md"
  CL45CP="$(clas45c "$DIR45C/viejoperso/AGENTS.md" 2 "$BASE45CF")"; migra45c "$DIR45C/viejoperso" "$BASE45CF"
  CL45CD="$(clas45c "$DIR45C/viejodoble/AGENTS.md" 2 "$BASE45CF")"; migra45c "$DIR45C/viejodoble" "$BASE45CF"
  cp "$DIR45C/viejosinsitio/AGENTS.md" "$DIR45C/viejosinsitio-antes.md"
  CL45CS="$(clas45c "$DIR45C/viejosinsitio/AGENTS.md" 2 "$BASE45CF")"; migra45c "$DIR45C/viejosinsitio" "$BASE45CF"
fi
N45C="45/30 limite 1: si el proyecto YA tiene texto suyo en esa ancla NO es NUEVO — se conserva entero y se publica el conflicto"
mide45c "$N45C" && { gate45c "$N45C" && \
  juzg45c "$N45C" "$([ "$CL45CP" = MODIFICADO ] && [ "$(cuenta45c "$DIR45C/viejoperso/AGENTS.md" 'lo revisa el area legal')" -eq 1 ] && [ "$(bloq45c "$DIR45C/viejoperso/AGENTS.md" "${AI45C[2]}")" = "$(bloq45c "$DIR45C/viejoperso-antes.md" "${AI45C[2]}")" ] && grep -q '^parrafo del aviso: CONFLICTO' "$DIR45C/viejoperso/.arnes/migracion.md" 2>/dev/null && grep -q '^RESULTADO: PARCIAL$' "$DIR45C/viejoperso/.arnes/migracion.md" 2>/dev/null && echo si || echo no)" \
    "clasifico «$CL45CP»; NUEVO anade y NUNCA sustituye, asi que con texto del proyecto en esa ancla el camino es el del conflicto; el registro dice: $(tr '\n' '/' < "$DIR45C/viejoperso/.arnes/migracion.md" 2>/dev/null)"; }

N45C="45/31 limite 2: con el bloque DOS veces es UNKNOWN, la migracion se detiene y NO sube arnes_version"
mide45c "$N45C" && { gate45c "$N45C" && \
  juzg45c "$N45C" "$([ "$CL45CD" = UNKNOWN ] && grep -q '^parrafo del aviso: UNKNOWN: detenido$' "$DIR45C/viejodoble/.arnes/migracion.md" 2>/dev/null && grep -q '^RESULTADO: PARCIAL$' "$DIR45C/viejodoble/.arnes/migracion.md" 2>/dev/null && [ ! -f "$DIR45C/viejodoble/.arnes/version-migrada" ] && echo si || echo no)" \
    "clasifico «$CL45CD»: UNKNOWN es tan terminal como CONFLICTO y no se declara migrada; el registro dice: $(tr '\n' '/' < "$DIR45C/viejodoble/.arnes/migracion.md" 2>/dev/null)"; }

# El archivo SI cambia aqui, y tiene que cambiar: los otros dos bloques son `INTACTO` y se
# aplican. Lo que no puede ocurrir es que el parrafo se inserte a ciegas en uno de los dos
# sitios posibles, asi que se mide ESE bloque y no el archivo entero.
N45C="45/32 limite 2: si el sitio donde iria NUEVO no se localiza una sola vez, UNKNOWN y no se inserta nada"
mide45c "$N45C" && { gate45c "$N45C" && \
  juzg45c "$N45C" "$([ "$CL45CS" = UNKNOWN ] && [ "$(cuenta45c "$DIR45C/viejosinsitio/AGENTS.md" "${AI45C[2]}")" -eq 0 ] && [ "$(cuenta45c "$DIR45C/viejosinsitio/AGENTS.md" "${AD45C[2]}")" -eq 0 ] && grep -q '^parrafo del aviso: UNKNOWN: detenido$' "$DIR45C/viejosinsitio/.arnes/migracion.md" 2>/dev/null && [ ! -f "$DIR45C/viejosinsitio/.arnes/version-migrada" ] && echo si || echo no)" \
    "clasifico «$CL45CS» y quedaron $(cuenta45c "$DIR45C/viejosinsitio/AGENTS.md" "${AI45C[2]}") copias del parrafo: un sitio que no se localiza con seguridad no se adivina; el registro dice: $(tr '\n' '/' < "$DIR45C/viejosinsitio/.arnes/migracion.md" 2>/dev/null)"; }

# --- (12) DISCRIMINANTE: que lo verde de arriba lo decide LA PREGUNTA PREVIA -------
# Sin esto, los casos de arriba podrian estar verdes por cualquier otra razon. Se apaga la
# pregunta previa —o sea, el clasificador de ANTES del arreglo— y el defecto tiene que volver.
N45C="45/33 discriminante: apagada la pregunta previa, el parrafo vuelve a CONFLICTO y el proyecto no migra"
if mide45c "$N45C"; then
  if gate45c "$N45C"; then
    PREV45C=off
    d45c="$(clas45c "$DIR45C/discri/AGENTS.md" 2 "$BASE45CF")"
    migra45c "$DIR45C/discri" "$BASE45CF"
    PREV45C="${ARNES_MIG45_PREV:-on}"
    juzg45c "$N45C" "$([ "$d45c" = ELIMINADO ] && grep -q '^RESULTADO: PARCIAL$' "$DIR45C/discri/.arnes/migracion.md" 2>/dev/null && [ ! -f "$DIR45C/discri/.arnes/version-migrada" ] && echo si || echo no)" \
      "sin la pregunta previa el clasificador dijo «$d45c» (se esperaba ELIMINADO, el defecto de QA-024-41) y el registro dice: $(tr '\n' '/' < "$DIR45C/discri/.arnes/migracion.md" 2>/dev/null): si esto NO reaparece, los casos de arriba no estan midiendo la correccion"
  fi
fi

# --- (13) LAS DOS COPIAS DEL CLASIFICADOR NO PUEDEN DIVERGIR EN SILENCIO -----------
# La parte 1 se lee como DATO, nunca se ejecuta (invariante 4 del README del banco). Lo unico
# que se compara es el cuerpo del clasificador, con los sufijos de nombre normalizados.
N45C="45/34 las dos transcripciones del clasificador (parte 1 y parte 3) siguen diciendo lo mismo"
if mide45c "$N45C"; then
  P1_45C="${SEC_DIR%/}/45-migracion-de-la-tabla-heredada-1-el-merge.sh"
  cuerpo45c() { awk -v f="$2" '$0 ~ "^" f "\\(\\) \\{" { d = 1 } d { gsub(/45[Cc]?/, ""); print } d && /^}$/ { exit }' "$1"; }
  c1_45c="$(cuerpo45c "$P1_45C" clas45)"; c3_45c="$(cuerpo45c "${BASH_SOURCE[0]:-$P1_45C}" clas45c)"
  c3_45c="$(printf '%s\n' "$c3_45c" | sed 's/^  nb=1; \[ "\$PREV" = on \] && nb=/  nb=/')"
  if [ -z "$c1_45c" ] || [ -z "$c3_45c" ]; then
    echo "  FAIL  $N45C  no se pudo extraer el clasificador de $([ -z "$c1_45c" ] && echo 'la parte 1' || echo 'esta parte'): dos vacios no son iguales, son ilegibles"; FAIL=$((FAIL+1))
  else
    juzg45c "$N45C" "$([ "$c1_45c" = "$c3_45c" ] && echo si || echo no)" \
      "las dos copias han divergido; diff: $(diff <(printf '%s\n' "$c1_45c") <(printf '%s\n' "$c3_45c") | tr '\n' '/')"
  fi
fi
