# Sección 45 (1 de 2) del banco — 45-migracion-de-la-tabla-heredada-1-el-merge
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna
# otra sección (invariantes 3 y 4 del README del banco).
#
# QUÉ MIDE Y POR QUÉ NO CABE EN LA 44. La 44 mide que los DOS documentos del arnés
# —`AGENTS.md` y `templates/AGENTS.md.tpl`— digan lo que la máquina hace. Eso sirve a los
# proyectos que se instalan a partir de hoy y **a nadie más**: el `AGENTS.md` de un proyecto
# ya inicializado está CONGELADO (skill `arnes-upgrade`, § «Por qué existe»), así que sin
# migración ese proyecto actualiza a 1.34.0 y conserva las promesas falsas. Aquí se mide la
# CUARTA superficie: que la corrección LLEGUE a un proyecto ya instalado y que, cuando ese
# proyecto personalizó la zona, NO se le pise y el resultado LO DIGA (`QA-024-38`, `SEC-084`,
# `REQ-024 CA-12 (ii)`).
#
# LAS DOS COMPROBACIONES QUE ESTA SECCIÓN FIJA, que son las que el propietario exige:
#   (1) INSTALACIÓN NUEVA — un proyecto que instala hoy recibe la fila y el párrafo
#       CORREGIDOS: las tres anclas de DESTINO aparecen una vez cada una en la plantilla que
#       `arnes-init` copia, y ninguna de las tres de ORIGEN sobrevive.
#   (2) ACTUALIZACIÓN CON PERSONALIZACIONES — un proyecto que MODIFICÓ esa zona no la pierde,
#       y la salida DICE que ahí hay un conflicto por resolver. El verde exige las DOS
#       mitades: que el texto de la persona siga entero Y que el registro lo publique. Un
#       resumen que dijera «migrado» sobre un proyecto con un conflicto sin resolver es el
#       fail-open de esta familia, y va medido aparte, en el titular derivado (caso 7).
#
# ESTA SECCIÓN NO EJECUTA NINGÚN HOOK, y por eso no usa `$HOOKS_DIR`: las rutas se derivan de
# `$SEC_DIR`, igual que en `44-la-tabla-heredada.sh`, para que apuntar el banco a una
# instalación anterior (`ARNES_HOOKS_DIR`) siga midiendo los hooks viejos contra los textos de
# HOY. La guarda de la invariante 1 no aplica; a cambio, TODO extractor trata el bloque VACÍO
# como FAIL o SKIP y nunca como igualdad: comparar dos vacíos diría «idéntico» sobre nada.
#
# EL FAIL-BEFORE NECESITA LOS TEXTOS DE ANTES, y `ARNES_HOOKS_DIR` no los da. Por eso
# `ARNES_DOCS_RAIZ=<árbol anterior>` (la raíz de `templates/AGENTS.md.tpl`) y
# `ARNES_MIG45_BASE=<ref>` (la línea base del merge, por defecto `v1.33.0`). Con la primera
# puesta la vuelta NO acredita el árbol: mide otros archivos, y lo dice el nombre.
#
# LA LÍNEA BASE SALE DE GIT Y NO SE ESCRIBE A MANO: materializar del tag la plantilla de la
# versión de ORIGEN es lo único que acredita que el clasificador compara DOS documentos (caso 1).
#
# Y ABSTENERSE NO ES LO MISMO QUE FALLAR, así que las dos causas van separadas (`EST45`): sin
# `.git`, sin el tag o sin esa ruta en el tag, los casos ejecutables ABSTIENEN con SKIP y su
# motivo —nunca PASS: un clasificador que no pudo leer la base no ha clasificado nada—; pero
# que la plantilla de destino NO traiga uno de los tres bloques corregidos es EL DEFECTO que
# esta sección caza, y sale ROJO nombrando el bloque. Medido: con las dos causas en el mismo
# SKIP, el fail-before contra el árbol anterior salía en 20 abstenciones y 0 rojos, y una
# abstención no acredita nada en ninguna de las dos direcciones. La comprobación (1) va además
# por su propio portero, porque no necesita el merge: juzga bloque a bloque, así que sobre el
# árbol anterior sale roja SÓLO en el bloque que faltaba por corregir y verde en los otros dos.
#
# LAS ANCLAS SE ESCRIBEN AQUÍ Y SU RESIDUAL VA DICHO. El clasificador necesita las seis
# cadenas (origen y destino de los tres bloques) y las lleva escritas, no derivadas del
# Markdown de la skill: parsear celdas de una tabla con comillas invertidas anidadas añade un
# instrumento que puede fallar en silencio justo donde este banco no lo vería. A cambio, el
# caso `45/17` —en la PARTE 2— comprueba que LAS SEIS estén declaradas en la entrada de
# migración de la skill, así que una divergencia entre el banco y la guía sale en rojo en vez
# de pasar inadvertida. El residuo conocido: una redacción nueva de las anclas pondría estos
# casos en rojo, y la vía conforme es actualizarlas en los dos archivos, nunca retirar el caso.
#
# QUÉ VIVE EN LA PARTE 2 Y POR QUÉ (`REQ-014 CA-18`). Los siete casos que miden que la SKILL
# mande esta migración están en `45-…-2-la-guia.sh`: juntas medían 445 líneas sobre un techo
# de `max(400, piso × 1,25)` y la autoprueba lo dijo en rojo. El corte cae en la frontera
# natural entre EJERCER el mecanismo —aquí— y LEER un documento.
CASOS_ESPERADOS_SECCION=20
PISO_AUTONOMO_SECCION=227  # 65 preámbulo con sus dos declaraciones y el titular (líneas 1-65) + 86 maquinaria propia, que el corredor no tiene: el materializador de línea base, el extractor de bloque, el contador, el clasificador, el sustituidor, el corredor de migración y los dos jueces (líneas 73-158) + 76 bloque indivisible mayor (las cuatro tablas de anclas, los dos porteros y las cinco maquetas de proyecto, líneas 160-235: ningún caso de esta parte puede prescindir de ellos) · REQ-014 CA-18 · REGLA para re-derivar los tres términos sin preguntar: «preámbulo» son las líneas hasta el titular inclusive; un «bloque» es un grupo de líneas consecutivas sin blanca en medio, y el mayor que no es el preámbulo ni la maquinaria es el de las anclas y las maquetas; «maquinaria» es la que esta parte define porque el corredor no la tiene, no una copia de otra parte

seccion_nueva "--- 45/1 · la correccion de §13 llega a los proyectos YA instalados (REQ-024 CA-12 (ii), QA-024-38) ---"

REPO45="${SEC_DIR%/}/../../../.."
RAIZ45="${ARNES_DOCS_RAIZ:-$REPO45}"
TPL45="$RAIZ45/templates/AGENTS.md.tpl"
BASE45="${ARNES_MIG45_BASE:-v1.33.0}"
DIR45="$RAIZ/mig45-$BASHPID"; mkdir -p "$DIR45"

# --- MAQUINARIA PROPIA, y va con su motivo -----------------------------------------
# Ningún ayudante del corredor materializa un árbol anterior, extrae un bloque de un
# documento ni lo sustituye: los que hay ejecutan hooks y juzgan su respuesta. Se define
# aquí porque NO lo hay, no por comodidad (README del banco, «Los ayudantes compartidos»).
MOT45='-'
base45() {   # <destino> -> 0 si la plantilla de la version de ORIGEN quedo materializada
  local dst="$1"
  MOT45='-'
  [ -e "$REPO45/.git" ] || { MOT45='no-hay-.git-en-el-repositorio'; return 1; }
  git -C "$REPO45" rev-parse -q --verify "$BASE45^{tree}" >/dev/null 2>&1 \
    || { MOT45="la-referencia-no-resuelve:$BASE45"; return 1; }
  git -C "$REPO45" show "$BASE45:templates/AGENTS.md.tpl" > "$dst" 2>/dev/null \
    || { MOT45="la-referencia-no-trae-templates/AGENTS.md.tpl:$BASE45"; return 1; }
  [ -s "$dst" ] || { MOT45="la-plantilla-de-$BASE45-salio-vacia"; return 1; }
  MOT45="ok:$BASE45"
  return 0
}
# El BLOQUE que un ancla de INICIO localiza: si la linea casada empieza por `|` es una fila
# de la tabla y el bloque es esa linea; si no, es un parrafo y llega hasta la primera linea
# en blanco. El `\r` FINAL se retira —misma normalizacion que `hooks/lib.sh`— para que un
# proyecto Windows no produzca un conflicto falso, que es preguntar por nada.
bloq45() {   # <archivo> <ancla-de-inicio> -> el bloque, o vacio
  awk -v a="$2" '
    !d && index($0, a) { d = 1; l = $0; sub(/\r$/, "", l); print l
                         if (substr($0, 1, 1) == "|") exit
                         next }
    d { if ($0 ~ /^[ \t]*\r?$/) exit; l = $0; sub(/\r$/, "", l); print l }
  ' "$1" 2>/dev/null
}
cuenta45() {   # <archivo> <ancla> -> cuantas lineas lo contienen
  awk -v a="$2" 'index($0, a) { n++ } END { print n + 0 }' "$1" 2>/dev/null
}
# EL CLASIFICADOR, que transcribe la tabla de la skill y nada mas. Devuelve UNA palabra.
clas45() {   # <archivo-proyecto> <indice de bloque> <archivo-base> -> estado
  local proy="$1" i="$2" base="$3" no nd bp bb
  no="$(cuenta45 "$proy" "${AO45[$i]}")"; nd="$(cuenta45 "$proy" "${AD45[$i]}")"
  if [ "$no" -ge 2 ] || [ "$nd" -ge 2 ] || { [ "$no" -eq 1 ] && [ "$nd" -eq 1 ]; }; then printf 'UNKNOWN'; return; fi
  if [ "$no" -eq 0 ] && [ "$nd" -eq 0 ]; then printf 'ELIMINADO'; return; fi
  if [ "$no" -eq 0 ] && [ "$nd" -eq 1 ]; then printf 'APLICADO-YA'; return; fi
  bp="$(bloq45 "$proy" "${AI45[$i]}")"; bb="$(bloq45 "$base" "${AI45[$i]}")"
  if [ -z "$bp" ] || [ -z "$bb" ]; then printf 'UNKNOWN'; return; fi
  [ "$bp" = "$bb" ] && printf 'INTACTO' || printf 'MODIFICADO'
}
sust45() {   # <archivo> <ancla-inicio-de-origen> <archivo-con-el-bloque-destino>
  local f="$1" ao="$2" nuevo="$3" tmp="$1.sust"
  awk -v a="$ao" -v nv="$nuevo" '
    !d && index($0, a) { d = 1
                         while ((getline l < nv) > 0) print l
                         close(nv)
                         if (substr($0, 1, 1) == "|") next
                         salta = 1; next }
    salta { if ($0 ~ /^[ \t]*\r?$/) { salta = 0; print }; next }
    { print }
  ' "$f" > "$tmp" 2>/dev/null && mv "$tmp" "$f"
}
# LA MIGRACION tal como la manda la skill: bloque a bloque, solo lo `INTACTO`, y el titular
# DERIVADO de las lineas y no redactado.
migra45() {   # <dir-proyecto> <archivo-base> -> escribe .arnes/migracion.md
  local proy="$1" base="$2" i est reg parcial=no
  reg="$proy/.arnes/migracion.md"
  mkdir -p "$proy/.arnes"; : > "$reg"
  for i in 0 1 2; do
    est="$(clas45 "$proy/AGENTS.md" "$i" "$base")"
    case "$est" in
      INTACTO)     sust45 "$proy/AGENTS.md" "${AI45[$i]}" "$DIR45/dest-$i.txt"
                   printf '%s: APLICADO\n' "${NOM45[$i]}" >> "$reg" ;;
      APLICADO-YA) printf '%s: APLICADO (ya estaba; no se toca)\n' "${NOM45[$i]}" >> "$reg" ;;
      MODIFICADO|ELIMINADO)
                   printf '%s: CONFLICTO: pendiente de resolver (%s; el contenido del proyecto se conserva y el bloque de destino se cita sin aplicar)\n' "${NOM45[$i]}" "$est" >> "$reg"
                   parcial=si ;;
      *)           printf '%s: UNKNOWN: detenido\n' "${NOM45[$i]}" >> "$reg"; parcial=si ;;
    esac
  done
  if [ "$parcial" = si ]; then
    printf 'RESULTADO: PARCIAL\n' >> "$reg"
  else
    printf 'RESULTADO: COMPLETA\n' >> "$reg"
    printf '1.34.0\n' > "$proy/.arnes/version-migrada"
  fi
}
juzga45() {   # <nombre> <si|no ya evaluado> <detalle del fallo>
  local nombre="$1" ok="$2" det="$3"
  if [ "$ok" = si ]; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  $det"; FAIL=$((FAIL+1)); fi
}
mide45() { [ -z "$FILTRO" ] || printf '%s' "$1" | grep -qi -- "$FILTRO"; }

# --- LAS ANCLAS Y LAS MAQUETAS ----------------------------------------------------
NOM45=("fila del CIERRE" "fila del ORDEN de las firmas" "parrafo del aviso")
AO45=('No completar sin `QA: aprobado`'
      'Seguridad no firma lo que QA no ha validado (salvo'
      '**no deniega** la edición: ese REQ no podrá cerrarse')
AD45=('El CIERRE juzga DOS cosas distintas'
      'tampoco cuando la línea `QA:` no llega a declararse'
      'el aviso lleva su condición')
# El ancla de INICIO no es el ancla de cuenta: la del parrafo de destino cae a mitad del
# bloque, y extraer desde ahi lo truncaria. El titular del parrafo es el mismo antes y
# despues, asi que sirve para las dos versiones y para el proyecto que lo personalizo.
AI45=('No completar sin `QA: aprobado`'
      'Seguridad no firma lo que QA no ha validado (salvo'
      '**Un hook que avisa sin decidir.**')
AID45=('El CIERRE juzga DOS cosas distintas'
       'tampoco cuando la línea `QA:` no llega a declararse'
       '**Un hook que avisa sin decidir.**')
BASE45F="$DIR45/base.tpl"; BASE45_OK=no
base45 "$BASE45F" && BASE45_OK=si
REG45="$MOT45"
MAQ45=no
# EST45 separa ABSTENERSE de FALLAR, y la distinción es la del banco entero: no poder
# materializar la línea base (sin `.git`, sin el tag) es una limitación del entorno y ABSTIENE;
# que la plantilla de destino no traiga uno de los tres bloques corregidos ES EL DEFECTO que
# esta sección existe para cazar, y tiene que salir ROJO. Meter las dos cosas en el mismo SKIP
# convertía el fail-before entero en veinte abstenciones —medido contra el árbol anterior— y
# una abstención no acredita nada en ninguna de las dos direcciones.
EST45='ok'
gate45() {   # <nombre> -> 0 si se puede juzgar; si no, emite SKIP o FAIL y devuelve 1
  local nombre="$1"
  case "$EST45" in
    ok)     return 0 ;;
    skip:*) echo "  SKIP  $nombre  ${EST45#skip:}" ;;
    *)      echo "  FAIL  $nombre  ${EST45#fail:}"; FAIL=$((FAIL+1)) ;;
  esac
  return 1
}
if [ "$BASE45_OK" = si ] && [ -f "$TPL45" ]; then
  for i45 in 0 1 2; do bloq45 "$TPL45" "${AID45[$i45]}" > "$DIR45/dest-$i45.txt"; done
  for p45 in intacto perso borrado doble ya; do
    mkdir -p "$DIR45/$p45/.arnes/plantillas-origen"
    cp "$BASE45F" "$DIR45/$p45/AGENTS.md"
    cp "$BASE45F" "$DIR45/$p45/.arnes/plantillas-origen/AGENTS.md.tpl"
    printf '{ "arnes_version": "1.33.0" }\n' > "$DIR45/$p45/.arnes/config.json"
  done
  PERSO45='| No completar sin `QA: aprobado` — y en ESTE proyecto tampoco sin el visto bueno del area legal | §9 | `guard-completado` | `Edit`/`Write`/`MultiEdit` |'
  awk -v a="${AI45[0]}" -v nv="$PERSO45" 'index($0, a) && !d { print nv; d = 1; next } { print }' \
    "$BASE45F" > "$DIR45/perso/AGENTS.md.n" && mv "$DIR45/perso/AGENTS.md.n" "$DIR45/perso/AGENTS.md"
  awk -v a="${AI45[0]}" 'index($0, a) && !d { d = 1; next } { print }' \
    "$BASE45F" > "$DIR45/borrado/AGENTS.md.n" && mv "$DIR45/borrado/AGENTS.md.n" "$DIR45/borrado/AGENTS.md"
  awk -v a="${AI45[0]}" 'index($0, a) && !d { print; d = 1 } { print }' \
    "$BASE45F" > "$DIR45/doble/AGENTS.md.n" && mv "$DIR45/doble/AGENTS.md.n" "$DIR45/doble/AGENTS.md"
  migra45 "$DIR45/ya" "$BASE45F"           # el que YA migro, construido aplicando
  [ -s "$DIR45/dest-0.txt" ] && [ -s "$DIR45/dest-1.txt" ] && [ -s "$DIR45/dest-2.txt" ] && MAQ45=si
fi
# La maqueta de INSTALACION NUEVA no depende del merge ni de la linea base: `arnes-init` copia
# la plantilla y ya. Se prepara aparte para que la comprobacion (1) pueda JUZGAR bloque a
# bloque —y salir roja sobre el bloque concreto que no se corrigio— en vez de abstenerse en
# bloque porque el merge no se pudo montar.
NUEVO45=no
if [ -f "$TPL45" ]; then mkdir -p "$DIR45/nuevo"; cp "$TPL45" "$DIR45/nuevo/AGENTS.md"; NUEVO45=si; fi
gaten45() {   # <nombre> -> 0 si hay maqueta de instalacion nueva que medir
  local nombre="$1"
  [ "$NUEVO45" = si ] && return 0
  echo "  FAIL  $nombre  no existe la plantilla $TPL45: no hay texto que un proyecto nuevo pueda recibir"
  FAIL=$((FAIL+1)); return 1
}
if [ "$MAQ45" != si ]; then
  if [ "$BASE45_OK" != si ]; then EST45="skip:no se pudo materializar la linea base ($REG45): un clasificador que no pudo leer la base no ha clasificado nada"
  elif [ ! -f "$TPL45" ]; then EST45="fail:no existe la plantilla de destino $TPL45: no hay texto corregido que llevar a ningun proyecto"
  else
    vac45=''
    for i45 in 0 1 2; do [ -s "$DIR45/dest-$i45.txt" ] || vac45="$vac45 ${NOM45[$i45]}"; done
    EST45="fail:la plantilla de destino no trae el bloque corregido:$vac45 — un proyecto que migre hoy no recibiria esa correccion"
  fi
fi

# --- (1) EL INSTRUMENTO ANTES DEL RESULTADO: la base es OTRO documento -------------
# Sin esto un «INTACTO» no acreditaria nada: si la base ya llevara el texto de destino, el
# clasificador estaria comparando el arbol contra si mismo.
N45="45/1 instrumento: la linea base es OTRO documento que la plantilla de hoy"
if mide45 "$N45"; then
  if ! gate45 "$N45"; then :
  else
    juzga45 "$N45" "$([ "$(cuenta45 "$BASE45F" "${AD45[0]}")" -eq 0 ] && [ "$(cuenta45 "$TPL45" "${AD45[0]}")" -eq 1 ] && [ "$(cuenta45 "$BASE45F" "${AO45[0]}")" -eq 1 ] && echo si || echo no)" \
      "base y destino no se distinguen por las anclas de la fila del cierre (destino en la base=$(cuenta45 "$BASE45F" "${AD45[0]}"), destino en la plantilla=$(cuenta45 "$TPL45" "${AD45[0]}"), origen en la base=$(cuenta45 "$BASE45F" "${AO45[0]}"))"
  fi
fi

# --- (2) y (3) COMPROBACION 1: INSTALACION NUEVA ----------------------------------
# Lo que `arnes-init` copia es `templates/AGENTS.md.tpl`. Se mide sobre la COPIA del proyecto
# y no sobre la plantilla, porque lo que se contrata es lo que el proyecto RECIBE.
for i45 in 0 1 2; do
  N45="45/2 instalacion nueva: el proyecto recibe CORREGIDO el bloque «${NOM45[$i45]}»"
  if mide45 "$N45"; then
    if ! gaten45 "$N45"; then :
    else
      n45="$(cuenta45 "$DIR45/nuevo/AGENTS.md" "${AD45[$i45]}")"
      juzga45 "$N45" "$([ "$n45" -eq 1 ] && echo si || echo no)" \
        "el ancla de DESTINO aparece $n45 veces (se espera 1) en el AGENTS.md que sale de la plantilla"
    fi
  fi
  N45="45/3 instalacion nueva: no sobrevive la promesa vieja del bloque «${NOM45[$i45]}»"
  if mide45 "$N45"; then
    if ! gaten45 "$N45"; then :
    else
      n45="$(cuenta45 "$DIR45/nuevo/AGENTS.md" "${AO45[$i45]}")"
      juzga45 "$N45" "$([ "$n45" -eq 0 ] && echo si || echo no)" \
        "el ancla de ORIGEN sigue apareciendo $n45 veces: se corrigio el documento del arnes y no la plantilla que heredan los proyectos"
    fi
  fi
done

# --- (4)-(9) COMPROBACION 2: ACTUALIZACION CON PERSONALIZACIONES -------------------
CLAS45P=''; REGP45="$DIR45/no-existe"
if [ "$MAQ45" = si ]; then
  cp "$DIR45/perso/AGENTS.md" "$DIR45/perso-antes.md"
  CLAS45P="$(clas45 "$DIR45/perso/AGENTS.md" 0 "$BASE45F")"
  migra45 "$DIR45/perso" "$BASE45F"
  REGP45="$DIR45/perso/.arnes/migracion.md"
fi
N45="45/4 personalizado: la fila reescrita por el proyecto clasifica MODIFICADO"
mide45 "$N45" && { gate45 "$N45" && \
  juzga45 "$N45" "$([ "$CLAS45P" = MODIFICADO ] && echo si || echo no)" \
    "clasifico «$CLAS45P» y no MODIFICADO: un bloque que difiere de la base es trabajo de una persona"; }

N45="45/5 personalizado: tras migrar, el texto de la persona sigue BYTE A BYTE igual"
if mide45 "$N45"; then
  if ! gate45 "$N45"; then :
  elif cmp -s "$DIR45/perso-antes.md" "$DIR45/perso/AGENTS.md"; then
    juzga45 "$N45" no "el archivo entero quedo IDENTICO, asi que los otros dos bloques tampoco se aplicaron: esta comparacion no discrimina"
  elif [ "$(cuenta45 "$DIR45/perso/AGENTS.md" 'el visto bueno del area legal')" -eq 1 ] \
       && [ "$(bloq45 "$DIR45/perso/AGENTS.md" "${AI45[0]}")" = "$(bloq45 "$DIR45/perso-antes.md" "${AI45[0]}")" ]; then
    juzga45 "$N45" si ''
  else
    juzga45 "$N45" no "la fila personalizada se perdio o cambio: una migracion que sobrescribe ese texto no es una migracion con un detalle mejorable, es un fallo de esta entrada"
  fi
fi

N45="45/6 personalizado: el registro lo publica como CONFLICTO pendiente de resolver"
mide45 "$N45" && { gate45 "$N45" && \
  juzga45 "$N45" "$(grep -q '^fila del CIERRE: CONFLICTO: pendiente de resolver' "$REGP45" 2>/dev/null && echo si || echo no)" \
    "el registro no publica el conflicto de la fila del cierre; dice: $(tr '\n' '/' < "$REGP45" 2>/dev/null)"; }

N45="45/7 personalizado: el titular DERIVADO es PARCIAL, y en ninguna parte dice migrado"
mide45 "$N45" && { gate45 "$N45" && \
  juzga45 "$N45" "$(grep -q '^RESULTADO: PARCIAL$' "$REGP45" 2>/dev/null && ! grep -q 'RESULTADO: COMPLETA' "$REGP45" 2>/dev/null && echo si || echo no)" \
    "un resumen que diga «migrado» sobre un proyecto con un conflicto sin resolver deja la promesa falsa Y el registro afirmando que ya no la tiene; dice: $(tr '\n' '/' < "$REGP45" 2>/dev/null)"; }

N45="45/8 personalizado: la salida DISTINGUE lo aplicado de lo pendiente en el mismo proyecto"
mide45 "$N45" && { gate45 "$N45" && \
  juzga45 "$N45" "$([ "$(grep -c ': APLICADO' "$REGP45" 2>/dev/null)" -eq 2 ] && [ "$(grep -c ': CONFLICTO' "$REGP45" 2>/dev/null)" -eq 1 ] && echo si || echo no)" \
    "se esperaban 2 APLICADO y 1 CONFLICTO; dice: $(tr '\n' '/' < "$REGP45" 2>/dev/null)"; }

N45="45/9 personalizado: con un conflicto abierto la Fase 5 NO sube arnes_version"
mide45 "$N45" && { gate45 "$N45" && \
  juzga45 "$N45" "$([ ! -f "$DIR45/perso/.arnes/version-migrada" ] && echo si || echo no)" \
    "la migracion se registro como hecha con un conflicto pendiente: la siguiente ejecucion creera que esta hecho y el proyecto quedara a medias sin que nadie lo note"; }

# --- (10)-(12) EL CONTROL: un proyecto INTACTO si recibe los tres bloques ----------
CLAS45I=''
if [ "$MAQ45" = si ]; then
  cp "$DIR45/intacto/AGENTS.md" "$DIR45/intacto-antes.md"
  CLAS45I="$(clas45 "$DIR45/intacto/AGENTS.md" 0 "$BASE45F")"
  migra45 "$DIR45/intacto" "$BASE45F"
  cp "$DIR45/intacto/AGENTS.md" "$DIR45/intacto-1a.md"
  migra45 "$DIR45/intacto" "$BASE45F"     # segunda corrida: no puede tocar nada
fi
N45="45/10 control: un proyecto sin personalizar clasifica INTACTO y los tres bloques quedan APLICADOS"
mide45 "$N45" && { gate45 "$N45" && \
  juzga45 "$N45" "$([ "$CLAS45I" = INTACTO ] && [ "$(grep -c ': APLICADO' "$DIR45/intacto/.arnes/migracion.md" 2>/dev/null)" -eq 3 ] && grep -q '^RESULTADO: COMPLETA$' "$DIR45/intacto/.arnes/migracion.md" 2>/dev/null && echo si || echo no)" \
    "clasifico «$CLAS45I»; el registro dice: $(tr '\n' '/' < "$DIR45/intacto/.arnes/migracion.md" 2>/dev/null)"; }

N45="45/11 control: no se sobrescribe AGENTS.md entero — cambian los tres bloques y nada mas"
# DOS mitades, y hacen falta las dos. (a) NINGUN titulo de seccion se mueve: un `AGENTS.md`
# sobrescrito con la plantilla trae la §2, la §3 y la §5 del arnes en vez de las del proyecto,
# y eso se ve en la lista de titulos antes que en ningun otro sitio. (b) EL SALDO DE LINEAS
# cuadra EXACTO con el tamano de los tres bloques: destino menos base. El saldo se prefiere al
# recuento de lineas cambiadas porque `diff` no cuenta como cambiada la linea que los dos
# bloques comparten, asi que ese numero es una COTA y no una igualdad; el saldo, no.
if mide45 "$N45"; then
  if ! gate45 "$N45"; then :
  else
    sec45="$(diff <(grep '^## ' "$DIR45/intacto-antes.md") <(grep '^## ' "$DIR45/intacto/AGENTS.md") 2>&1)"
    esp45=0; tam45=0
    for i45 in 0 1 2; do
      nb45="$(bloq45 "$BASE45F" "${AI45[$i45]}" | grep -c .)"; nd45="$(grep -c . "$DIR45/dest-$i45.txt")"
      esp45=$(( esp45 + nd45 - nb45 )); tam45=$(( tam45 + nb45 + nd45 ))
    done
    sal45=$(( $(grep -c '' "$DIR45/intacto/AGENTS.md") - $(grep -c '' "$DIR45/intacto-antes.md") ))
    dif45="$(diff "$DIR45/intacto-antes.md" "$DIR45/intacto/AGENTS.md" 2>/dev/null | grep -c '^[<>]')"
    juzga45 "$N45" "$([ -z "$sec45" ] && [ "$sal45" -eq "$esp45" ] && [ "$dif45" -ge 1 ] && [ "$dif45" -le "$tam45" ] && echo si || echo no)" \
      "titulos de seccion movidos=<$sec45>; saldo de lineas=$sal45 y el esperado por los tres bloques es $esp45; lineas cambiadas=$dif45 sobre un tamano total de bloques de $tam45: si no cuadran, se toco algo que no era de esta migracion"
  fi
fi

N45="45/12 control: la segunda corrida no duplica nada — el archivo queda identico"
mide45 "$N45" && { gate45 "$N45" && \
  juzga45 "$N45" "$(cmp -s "$DIR45/intacto-1a.md" "$DIR45/intacto/AGENTS.md" && [ "$(cuenta45 "$DIR45/intacto/AGENTS.md" "${AD45[0]}")" -eq 1 ] && echo si || echo no)" \
    "la segunda corrida cambio el archivo o dejo $(cuenta45 "$DIR45/intacto/AGENTS.md" "${AD45[0]}") copias del bloque de destino"; }

# --- (13)-(15) LOS BORDES QUE LA TABLA DE LA SKILL DECLARA -------------------------
N45="45/13 borde ELIMINADO: un bloque que el proyecto borro es CONFLICTO, y no se repone"
if mide45 "$N45"; then
  if ! gate45 "$N45"; then :
  else
    c45="$(clas45 "$DIR45/borrado/AGENTS.md" 0 "$BASE45F")"
    migra45 "$DIR45/borrado" "$BASE45F"
    juzga45 "$N45" "$([ "$c45" = ELIMINADO ] && [ "$(cuenta45 "$DIR45/borrado/AGENTS.md" "${AD45[0]}")" -eq 0 ] && grep -q '^RESULTADO: PARCIAL$' "$DIR45/borrado/.arnes/migracion.md" 2>/dev/null && echo si || echo no)" \
      "clasifico «$c45» y dejo $(cuenta45 "$DIR45/borrado/AGENTS.md" "${AD45[0]}") bloques de destino: una fila ausente pudo borrarse A PROPOSITO, y reponerla revierte una decision humana en silencio"
  fi
fi

N45="45/14 borde UNKNOWN: con el bloque DOS veces se detiene y no aplica nada"
if mide45 "$N45"; then
  if ! gate45 "$N45"; then :
  else
    c45="$(clas45 "$DIR45/doble/AGENTS.md" 0 "$BASE45F")"
    migra45 "$DIR45/doble" "$BASE45F"
    juzga45 "$N45" "$([ "$c45" = UNKNOWN ] && [ "$(cuenta45 "$DIR45/doble/AGENTS.md" "${AO45[0]}")" -eq 2 ] && grep -q '^RESULTADO: PARCIAL$' "$DIR45/doble/.arnes/migracion.md" 2>/dev/null && echo si || echo no)" \
      "clasifico «$c45»: nunca se convierte incertidumbre en decision, y quedan $(cuenta45 "$DIR45/doble/AGENTS.md" "${AO45[0]}") copias del bloque de origen"
  fi
fi

N45="45/15 la instantanea de .arnes/plantillas-origen/ no se toca durante la migracion"
mide45 "$N45" && { gate45 "$N45" && \
  juzga45 "$N45" "$(cmp -s "$BASE45F" "$DIR45/perso/.arnes/plantillas-origen/AGENTS.md.tpl" && cmp -s "$BASE45F" "$DIR45/intacto/.arnes/plantillas-origen/AGENTS.md.tpl" && echo si || echo no)" \
    "la instantanea cambio: retocar el origen congelado para que el diff salga limpio no limpia el diff, falsifica la comparacion de la que cuelgan todos los INTACTO y todos los MODIFICADO"; }

# --- (16) DISCRIMINANTE. Sin el, un clasificador que dijera siempre «INTACTO» pasaria los
# casos de control, y uno que dijera siempre «MODIFICADO» pasaria el de personalizacion.
N45="45/16 discriminante: el clasificador separa intacto, personalizado y ya-migrado"
if mide45 "$N45"; then
  if ! gate45 "$N45"; then :
  else
    v45="$(clas45 "$DIR45/ya/AGENTS.md" 0 "$BASE45F")"
    juzga45 "$N45" "$([ "$CLAS45I" = INTACTO ] && [ "$CLAS45P" = MODIFICADO ] && [ "$v45" = APLICADO-YA ] && echo si || echo no)" \
      "intacto=«$CLAS45I», personalizado=«$CLAS45P», ya-migrado=«$v45»: un clasificador que no separa estos tres no clasifica nada"
  fi
fi

