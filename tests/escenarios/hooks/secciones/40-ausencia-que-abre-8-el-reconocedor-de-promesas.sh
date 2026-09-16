# Sección 40 (8ª parte) del banco — 40-ausencia-que-abre-8-el-reconocedor-de-promesas
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-024 · `CA-06`, mitad del RECONOCEDOR: «ninguna promesa de equivalencia se enuncia sin su
# acto». La mitad de TEXTO —lo que la nota de migración tiene que decir, y el `_doc` de
# `campos.ausencia_exige` en sus dos sedes— se quedó en `40/3`, donde vivían las dos hasta hoy.
#
# PARTIDA POR REQ-014 CA-18, Y LA DUPLICACIÓN ES LO QUE EL TECHO CUENTA. `40/3` medía 629 líneas
# contra un techo de 400 —su piso (78) no llega a `N / k` = 320, así que lo gobierna `N`— tras la
# cadena de reparaciones del reconocedor: 325 → 382 → 477 (`I-5`) → 554 (`I-7`) → 629 (`SEC-102`).
# El corte va por la frontera que el archivo ya tenía y por la que ha crecido: los casos que miden
# TEXTO con `mira40c` de un lado y los que miden con el RECONOCEDOR del otro; las cuatro
# reparaciones cayeron enteras de ESTE lado. Ninguna mitad usa un nombre definido en la otra.
# Las tres invariantes de REQ-014 —CA-04 (subshell propio y en paralelo), CA-19 (ninguna sección
# hace `source` de otra) y H-04 (en `secciones/` no cabe un archivo auxiliar)— hacen IMPOSIBLE
# factorizar lo que dos partes comparten: se duplica o se sube al corredor, y subirlo es cambio de
# mecanismo y NO está autorizado. Por eso el aplanado del apartado viene DUPLICADO aquí y en
# `40/3`, con su motivo escrito — el mismo precedente que `mat37` en las tres partes de la 37.
# Los casos se miden sobre el apartado APLANADO —un registro por viñeta, no línea a línea: un rojo
# por reajustar el ancho de un párrafo enseña a desactivar el control (H-11)— y el documento se lee
# de `ARNES_SKILL_UPGRADE` si está puesta, para poder medir el texto de ANTES; con la variable
# puesta la vuelta NO acredita el árbol.
CASOS_ESPERADOS_SECCION=5  # Los CINCO casos del reconocedor, que vienen de `40/3` SIN cambiar ni uno: las promesas del apartado con su acto, el DISCRIMINANTE (par fail-before/pass-after), las SIETE regresiones conocidas de `I-5` con sus controles positivos, los SEIS falsos positivos de `I-7` con la falsación `v2`, y el COSTE DEL BORDE de `SEC-102` (los dos lados a la vez). La partición NO añade, quita ni renombra ningún caso: `40/3` pasa de 30 a 25 y esta parte declara 5, así que `CASOS_ESPERADOS` del banco NO cambia · REQ-014 CA-18
PISO_AUTONOMO_SECCION=129  # 27 preámbulo con sus dos declaraciones y el titular (líneas 1-27) + 20 maquinaria compartida duplicada (el aplanado del apartado, duplicado de `40/3` porque en `secciones/` no cabe un auxiliar y CA-19 prohíbe el `source`; líneas 29-48) + 82 bloque indivisible mayor (el reconocedor: los patrones de los dos ejes y `mide40p`, líneas 116-197; ninguno de los cinco casos puede prescindir de él). La documentación de los dos ejes NO se cuenta en el piso aunque viva pegada al reconocedor: un piso se declara por lo que ninguna partición baja, y el comentario sí podría repartirse · REQ-014 CA-18
seccion_nueva "--- 40/8 · la ausencia que abre: el reconocedor de promesas de equivalencia (REQ-024 CA-06) ---"

REPO40C="${SEC_DIR%/}/../../../.."
SK40="${ARNES_SKILL_UPGRADE:-$REPO40C/skills/arnes-upgrade/SKILL.md}"
AP40="$RAIZ/ap40h-$BASHPID.txt"
# El apartado de migración de ESTA versión, aplanado: `<línea de arranque><TAB><viñeta entera>`.
# DUPLICADO de `40/3` por CA-04 + CA-19 + H-04 (ver cabecera). El temporal lleva nombre propio
# (`ap40h-`) para que las dos partes no compartan archivo si corren a la vez.
if [ -f "$SK40" ]; then
  awk '
    !d && /^### Hacia 1\.34\.0[ \t]*$/ { d = 1; next }
    d && (/^## / || /^### / || /^\*\(/) { exit }
    d {
      if ($0 ~ /^- /) { if (rec != "") print n "\t" rec; n = FNR; rec = $0 }
      else { s = $0; sub(/^[ \t]+/, "", s); if (rec != "") rec = rec " " s }
    }
    END { if (rec != "") print n "\t" rec }
  ' "$SK40" > "$AP40"
else
  : > "$AP40"
fi
VIN40="$(awk 'END { print NR + 0 }' "$AP40")"

# ---------- CA-06 · NINGUNA PROMESA DE EQUIVALENCIA SE ENUNCIA SIN SU ACTO ----------
# La otra mitad de la cláusula final de `CA-06` —«ninguna frase afirma … que un proyecto que no
# activa nada no note NADA»—, medida como PROPIEDAD y no buscando una frase mala. `CA-05` dejó de
# contratar la equivalencia sobre «la puerta» y la contrata sobre el ACTO DE CIERRE (`ADR-011`),
# así que en este apartado toda promesa de equivalencia con la versión heredada tiene que llevar
# el acto DENTRO de la propia promesa. Con una coletilla al lado no vale: es exactamente la forma
# que `SEC-079` midió, y quien lee la promesa sola se queda con la promesa.
#
# LA FAMILIA PROHIBIDA SE RECONOCE POR CADENA LITERAL, Y ES UN CONJUNTO ABIERTO (`QA-024-05`):
# son las formas SIN acto medidas en este documento —dos de ellas vivían aquí hasta hoy: «la
# resolución de la ausencia de un campo de cabecera decide exactamente lo mismo que 1.33.0» y
# «sin la llave, 1.34.0 decide como las anteriores»—, no la lista de todas las maneras de
# prometer equivalencia. Una tercera forma redactada con otras palabras se le escapa, y por eso
# el caso PUBLICA su denominador —cuántas promesas ve y cuántas llevan su acto— en vez de decir
# «ninguna»: un instrumento que no puede enumerar su clase tiene que enseñar su cuenta.
# Y ABSTIENE con 0 promesas: «todas llevan su acto» es cierto por vacío cuando no hay ninguna, y
# un verde por no medir es la familia que `REQ-020` existe para cazar.
# QUÉ ES UNA PROMESA DE EQUIVALENCIA, Y POR QUÉ HIZO FALTA DECIRLO (`CA-06`, falso positivo medido
# en CI, PR #50). El reconocedor buscaba los VERBOS de la familia sobre el apartado entero, y el
# apartado dejó de ser sólo prosa sobre la llave: ahora lleva además la tabla de migración, cuya
# fila `MODIFICADO` dice «Tu texto **se queda como está**». Esa frase NO promete equivalencia con
# ninguna versión heredada — su sujeto es **el texto del proyecto ante un conflicto**, y su acto va
# al lado («el conflicto se lista para el humano») —, pero casaba con el verbo y teñía el caso de
# rojo. Y la instrucción que protege el texto personalizado NO se reformula para esquivar una
# prueba: se arregla el ALCANCE del reconocedor.
#
# La distinción se hace POR PROPIEDAD, no excluyendo la línea, la fila ni la tabla por su nombre
# —una exclusión por nombre deja de valer en cuanto la tabla se mueva—: **una promesa de
# equivalencia compara con una VERSIÓN HEREDADA, y por tanto nombra el término de la comparación**.
# Las dos promesas reales del apartado lo llevan («cierra exactamente como cerraba **en 1.33.0**»,
# «sin la llave, 1.34.0 cierra **como las anteriores**»); «tu texto se queda como está» no lo lleva,
# porque no hay versión con la que comparar. Sin término heredado no hay equivalencia que prometer.
#
# EL DETECTOR QUEDÓ POR PROPIEDAD EN UN EJE DE DOS, Y ESO FUE `I-5`. La primera versión de esta
# corrección acotó bien el eje del VERBO/ACTO y dejó el del TÉRMINO HEREDADO como una **enumeración
# cerrada** y un alcance de **una sola oración**. Resultado medido por QA y por el auditor: **siete**
# formas que el reconocedor anterior sí cazaba dejaron de caer, **ninguna de ellas espuria** — las
# siete eran promesas que debían seguir bloqueadas. Efecto sobre el texto de entonces: nulo.
# Cobertura futura: perdida. Los dos ejes se enuncian ahora por propiedad:
#
#   EJE 1 · QUÉ ES UN TÉRMINO HEREDADO — **por propiedad, con ejemplos NO EXHAUSTIVOS**
#   (`requirements/README.md`: una enumeración cerrada envejece hacia el lado que abre). Es toda
#   expresión que señale **un estado anterior de este arnés**, y se reconoce de dos maneras:
#     (i) un IDENTIFICADOR DE VERSIÓN — con `v` o sin ella, completo o truncado: `1.33.0`, `1.33.`,
#         `v1`—; o
#     (ii) una EXPRESIÓN DE ANTERIORIDAD — «anterior», «previa», «antes», «hasta ahora»,
#         «heredada»…
#   Los ejemplos de abajo son **ejemplos**, no la clase: una forma nueva de decir «antes» se le
#   escapa, y por eso el caso **publica su denominador** en vez de afirmar «ninguna».
#
#   EJE 2 · DÓNDE PUEDE ESTAR ESE TÉRMINO — en la oración del verbo **o en una vecina inmediata**,
#   dentro del MISMO BLOQUE. Una promesa se reparte entre dos frases con toda naturalidad («La
#   comparación es con la versión 1.33.0. Sin la llave, decide exactamente lo mismo.»), así que la
#   oración sola suelta la mitad de la familia. **El bloque es el límite**, y es lo que impide que
#   esto se vuelva laxo: una celda de tabla es un bloque, así que el término de una celda **no le
#   presta** a otra — que era la ganancia por la que se acotó, y se conserva.
#
# LÍMITE DECLARADO, PORQUE SIGUE SIENDO UN RECONOCEDOR POR CADENA Y NO UN ANALIZADOR: no entiende
# castellano. Reconoce las formas que se le enumeran en los dos ejes y **no las demás**; la ventana
# de dos oraciones es una heurística de vecindad, no una noción de párrafo. Lo que lo hace fiable no
# es su cobertura, sino que **lo que suelta y lo que muerde está ejercido**: las SIETE regresiones
# conocidas y los controles positivos corren en cada vuelta, abajo.
# Con acto DENTRO de la promesa (el verbo de la equivalencia es cerrar) / sin acto (sujeto
# abierto: «decide», «no nota nada», «se queda como está»). Conjunto ABIERTO (`QA-024-05`).
# Se definen a NIVEL DE ARCHIVO, no dentro del primer caso: los cinco casos de este archivo los
# usan, y con `FILTRO` el primero puede no ejecutarse.
con40='cierra exactamente como cerraba|cierra como las anteriores|cierra exactamente como cerró'
sin40='decide[ ]*exactamente lo mismo|decide como las anteriores|no nota nada|se queda[ ]*exactamente como está|se queda como está|resuelve como las anteriores'
# EJE 1, con sus ejemplos declaradamente NO EXHAUSTIVOS (ver cabecera): identificador de versión
# —con `v` o sin ella, completo o truncado— o expresión de anterioridad.
#
# LAS DOS CAUTELAS DE ABAJO SON `I-7`, Y LAS DOS SON DEFECTOS QUE ESTE MISMO CASO INTRODUJO:
#
#  (1) EL PUNTO TIENE QUE LLEGAR A `awk` COMO PUNTO LITERAL. Estos patrones NO se pasan con
#      `awk -v`, y no es un capricho: `-v` **procesa las secuencias de escape**, así que `\.` llega
#      como `.` —cualquier carácter— y el patrón de versión se vuelve enorme: `123`, `2026` o una
#      fecha ISO casaban como «identificador de versión», y bastaba una fecha cerca de la frase
#      protegida para teñir el caso de rojo. Se pasan por **ENVIRON**, que entrega el valor **byte a
#      byte, sin interpretar nada**. Es la forma que **no depende de que nadie recuerde una regla de
#      escapes** al editar el patrón más tarde: lo que se escriba aquí es exactamente lo que ve
#      `awk`. (El síntoma también era visible y nadie lo miraba: `-v` emitía 12 avisos
#      `escape sequence \. treated as plain .` por corrida. Con ENVIRON son **0**, y ese cero es
#      parte de lo que se comprueba.)
#
#  (2) LA ANTERIORIDAD CASA POR EL PRINCIPIO DE LA PALABRA, NO COMO SUBCADENA — Y EL BORDE VA EN
#      UN SOLO LADO. Sin límites, «bast-antes», «rest-antes» e «inst-antes» mordían. El límite se
#      escribe **sin extensiones de gawk** —`\<`, `\>` y `\b` no son portables—: se exige **borde
#      de cadena o carácter no alfabético** **a la IZQUIERDA**, y **nada a la derecha**.
#
#      POR QUÉ SÓLO A LA IZQUIERDA, Y ESTÁ MEDIDO (`SEC-102`). Los tres falsos positivos llevan el
#      término como **sufijo** (`bast|antes`, `rest|antes`, `inst|antes`), así que el borde
#      izquierdo ya los rechaza **enteros**: con él solo siguen dando «0 0». El borde DERECHO no
#      compraba **ni uno** de los tres y costaba **tres verdaderos** —«anteriormente»,
#      «previamente», «con anterioridad»—, que son la misma clase con el término como **prefijo** y
#      que la cabeza anterior sí cazaba. Dejaron de morder **en silencio** y la dirección del fallo
#      era **hacia el VERDE**: una promesa real escrita con «anteriormente» pasaba inadvertida.
#      Retirar el borde derecho las recupera **sin resucitar ningún negativo medido**, y el caso
#      «el COSTE del borde», abajo, ejerce **los dos lados en la misma vuelta**, para que el
#      siguiente ajuste tenga que decidir entre ellos **a la vista** y no en silencio.
#
#      Las terminaciones (`anterior(es)`, `previ[ao]s`, `heredad[ao]s`) se CONSERVAN, y ya no por
#      el borde derecho sino porque siguen restringiendo por sí solas: `previ[ao]s?` no alcanza
#      «previsto», que un `previ` a secas sí alcanzaría.
ver40_ver='[0-9]+\.[0-9]+|(^|[^a-zA-Z0-9])v[0-9]+'
ver40_ant='(^|[^[:alpha:]])(anterior(es)?|previ[ao]s?|antes|hasta ahora|heredad[ao]s?)'
ver40="$ver40_ver|$ver40_ant"
# EJE 2. `mide40p <archivo-en-formato-AP> [detalle]` -> «<con> <sin>», o con `detalle` una línea
# `<clase>|<verbo>|<término heredado>` por promesa vista. Parte cada viñeta en BLOQUES por el
# separador de celda, cada bloque en ORACIONES por punto+espacio, y para cada oración con verbo de
# la familia busca el término heredado en ella o en una vecina del mismo bloque.
# (Nota de precisión, porque la versión anterior de este comentario lo decía mal: un «1.33.0» a
# mitad de frase no se parte, pero uno que CIERRA la oración va seguido de punto y espacio y SÍ se
# parte. Por eso el término se busca también en la vecina, y no sólo en la propia oración.)
# Los nombres de las variables de awk llevan prefijo A PROPÓSITO: `sin` es una función interna de
# gawk y usarla como variable aborta el programa. Y NO se enmascara el error: si el medidor no
# puede correr, no imprime nada, y quien lo llama **falla nombrándolo** en vez de leer un 0. Un
# medidor roto que devuelve «0 promesas sin acto» es un verde por no medir, que es justo la familia
# que este banco existe para cazar.
mide40p() {
    ARNES40_CON="$con40" ARNES40_SIN="$sin40" ARNES40_VER="$ver40" ARNES40_MODO="${2:-cuenta}" \
    awk '
      BEGIN {
        rcon = ENVIRON["ARNES40_CON"]; rsin = ENVIRON["ARNES40_SIN"]
        rver = ENVIRON["ARNES40_VER"]; modo = ENVIRON["ARNES40_MODO"]
      }
      {
        nb = split($0, B, /\|/)
        for (b = 1; b <= nb; b++) {
          t = B[b]; gsub(/\. /, ".\n", t)
          no = split(t, S, /\n/)
          for (i = 1; i <= no; i++) {
            v = (S[i] ~ rcon) ? "con" : ((S[i] ~ rsin) ? "sin" : "")
            if (v == "") continue
            ctx = S[i]
            if (i > 1)  ctx = S[i-1] " " ctx
            if (i < no) ctx = ctx " " S[i+1]
            if (ctx !~ rver) continue
            if (modo == "cuenta") { if (v == "con") c++; else s++; continue }
            verbo = ""; if (match(S[i], (v == "con") ? rcon : rsin)) verbo = substr(S[i], RSTART, RLENGTH)
            term = "";  if (match(ctx, rver)) term = substr(ctx, RSTART, RLENGTH)
            gsub(/^[^[:alnum:]]+|[^[:alnum:]]+$/, "", term)
            print v "|" verbo "|" term
          }
        }
      }
      END { if (modo == "cuenta") printf "%d %d", c + 0, s + 0 }
    ' "$1"
}

if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 promesas con su acto" | grep -qi -- "$FILTRO"; then
  m40="$(mide40p "$AP40")"; c40p="${m40%% *}"; s40p="${m40##* }"
  tot40p=$(( ${c40p:-0} + ${s40p:-0} ))
  if [ -z "$m40" ]; then
    echo "  FAIL  REQ-024 CA-06 promesas con su acto: el MEDIDOR no pudo correr y no hay medición; esto no se da por bueno ni se cuenta como «0 promesas sin acto»"; FAIL=$((FAIL+1))
  elif [ "$tot40p" -lt 1 ]; then
    echo "  SKIP  REQ-024 CA-06 promesas con su acto  el apartado no enuncia ninguna promesa de equivalencia de las formas conocidas ($VIN40 viñetas): «todas llevan su acto» sería cierto por vacío"
  elif [ "${s40p:-0}" -eq 0 ]; then
    echo "  PASS  REQ-024 CA-06 las $tot40p promesas de equivalencia del apartado llevan el ACTO dentro de la promesa (${c40p} con acto, 0 de sujeto abierto; oraciones con verbo de la familia Y término heredado, conjunto ABIERTO)"; PASS=$((PASS+1))
  else
    # El rojo nombra el VERBO **y el término heredado que hizo contar la oración**. Sin el término,
    # el mensaje señalaba sólo la frase con el verbo —típicamente la que protege el texto
    # personalizado— e inducía a reescribirla, que es justo lo que no hay que hacer: lo que hay que
    # mirar es la pareja, y muchas veces lo que sobra es el término, no el verbo.
    echo "  FAIL  REQ-024 CA-06 promesas de equivalencia: $tot40p vistas y ${s40p} enunciadas SIN acto (sujeto abierto): $(mide40p "$AP40" detalle | awk -F'|' '$1 == "sin" { printf "· verbo «%s» + término heredado «%s» ", $2, $3 }')"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-06 · EL DISCRIMINANTE DEL RECONOCEDOR (par fail-before / pass-after) ----------
# Sin esto, el arreglo de arriba sería indistinguible de haber aflojado el reconocedor hasta que
# dejara de morder. Se inyectan en una COPIA del apartado las dos formas que tienen que decidir
# distinto, y se exige que decidan distinto:
#   (b1) promesa de equivalencia con la versión heredada SIN su acto  -> tiene que SEGUIR FALLANDO
#   (b2) la misma promesa CON su acto dentro                          -> tiene que PASAR
# El control (a) —que la frase protectora del texto personalizado pasa SIN haber sido cambiada— lo
# da el caso de arriba sobre el apartado real, que la contiene tal cual.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 discriminante del reconocedor" | grep -qi -- "$FILTRO"; then
  INY40="$RAIZ/iny40-$BASHPID.txt"
  # (b1) sintética SIN acto, con término heredado explícito.
  { cat "$AP40"; printf '0\t- sin la llave, esta version decide como las anteriores.\n'; } > "$INY40"
  b1="$(mide40p "$INY40")"; b1s="${b1##* }"
  # (b2) sintética CON su acto dentro de la promesa.
  { cat "$AP40"; printf '0\t- sin la llave, esta version cierra como las anteriores.\n'; } > "$INY40"
  b2="$(mide40p "$INY40")"; b2s="${b2##* }"; b2c="${b2%% *}"
  # (c) control de no-vacuidad: la frase protectora, SOLA, no es una promesa de equivalencia.
  printf '0\t- Tu texto **se queda como está** y el conflicto **se lista para el humano**.\n' > "$INY40"
  b3="$(mide40p "$INY40")"
  if [ "$b1s" -ge 1 ] && [ "$b2s" -eq 0 ] && [ "$b2c" -ge 1 ] && [ "$b3" = "0 0" ]; then
    echo "  PASS  REQ-024 CA-06 discriminante: el reconocedor sigue mordiendo lo que debe y suelta lo que no  (inyectada SIN acto -> $b1s sin acto, muerde; la MISMA CON acto -> $b2s sin acto y $b2c con acto, pasa; la frase que protege el texto personalizado, sola -> «$b3», ni promesa ni infracción)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 discriminante: el reconocedor no distingue los dos casos  (SIN acto -> «$b1» (se esperaba sin>=1); CON acto -> «$b2» (se esperaba sin=0 y con>=1); frase protectora sola -> «$b3» (se esperaba «0 0»))"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-06 · LAS SIETE REGRESIONES CONOCIDAS, Y LOS CONTROLES POSITIVOS ----------
# Las siete formas que el reconocedor de `d913575` dejó de cazar y el anterior sí cazaba (`I-5`,
# medidas por QA y confirmadas por el auditor: **ninguna era espuria**; las siete son promesas de
# equivalencia sin su acto y debían seguir bloqueadas). Se inyecta cada una en una COPIA del
# apartado y se exige que **siga mordiendo**.
#
# NO SON LA DEFINICIÓN NI UN CONJUNTO CERRADO, y esto importa tanto como el caso: son las
# regresiones **conocidas**, es decir las que ya se escaparon una vez. La clase la enuncian los dos
# ejes de la cabecera, por propiedad y con ejemplos no exhaustivos; estas siete son el suelo
# ejercido, no el techo. Tampoco son excepciones escritas una a una: el arreglo está en la
# PROPIEDAD —el término heredado por clase, y la vecindad dentro del bloque—, y estas siete sólo
# comprueban que la propiedad las alcanza.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 regresiones conocidas" | grep -qi -- "$FILTRO"; then
  REG40="$RAIZ/reg40-$BASHPID.txt"
  # Cada entrada: <etiqueta del eje que la dejó escapar>::<texto inyectado>
  REGS40=(
    'vecina/término en la oración anterior::La comparación es con la versión 1.33.0. Sin la llave, decide exactamente lo mismo.'
    'vecina/«no nota nada» en la siguiente::Frente a las anteriores no hay cambio. Un proyecto no nota nada.'
    'enumeración/versión sin punto decimal::sin la llave, la v1 decide exactamente lo mismo.'
    'corte/versión que cierra la oración::respecto a la versión 1.33. decide exactamente lo mismo.'
    'enumeración/anterioridad natural::respecto a antes, decide exactamente lo mismo.'
    'enumeración/anterioridad natural::como hasta ahora, no nota nada.'
    'enumeración/«previa» no estaba::igual que en la versión previa, decide exactamente lo mismo.'
  )
  reg_tot=0; reg_ok=0; reg_mal=''
  for entrada in "${REGS40[@]}"; do
    reg_tot=$((reg_tot+1))
    eje="${entrada%%::*}"; texto="${entrada#*::}"
    { cat "$AP40"; printf '0\t- %s\n' "$texto"; } > "$REG40"
    r="$(mide40p "$REG40")"; rs="${r##* }"
    if [ "${rs:-0}" -ge 1 ]; then reg_ok=$((reg_ok+1)); else reg_mal="$reg_mal · #$reg_tot [$eje] «$texto»"; fi
  done
  # Controles POSITIVOS, en la misma vuelta: el apartado SIN inyectar tiene que seguir dando sus dos
  # promesas con acto y ninguna sin acto — es decir, la frase protectora de la fila `MODIFICADO`
  # sigue pasando SIN haber sido reformulada, y las dos promesas reales del apartado también.
  pos="$(mide40p "$AP40")"; posc="${pos%% *}"; poss="${pos##* }"
  if [ "$reg_ok" -eq "$reg_tot" ] && [ "${poss:-1}" -eq 0 ] && [ "${posc:-0}" -ge 2 ]; then
    echo "  PASS  REQ-024 CA-06 las $reg_tot regresiones conocidas de I-5 siguen mordiendo, y los controles positivos siguen pasando  ($reg_ok de $reg_tot inyectadas dan «sin acto» >= 1 —conjunto de regresiones CONOCIDAS, NO exhaustivo—; y el apartado sin inyectar sigue en $posc con acto y $poss sin acto, así que la frase protectora y las dos promesas reales pasan sin haberse tocado)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 regresiones/controles: $reg_ok de $reg_tot regresiones muerden (se esperaban $reg_tot)$reg_mal · controles positivos: $posc con acto (se esperaba >=2) y $poss sin acto (se esperaba 0)"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-06 · LOS FALSOS POSITIVOS DE `I-7`, Y LA FALSACIÓN `v2` ----------
# `I-7` fueron DOS defectos que la reparación de `I-5` introdujo al ensanchar el eje del término
# heredado: el escape `\.` perdido al pasar por `awk -v` (cualquier número de 3+ cifras o una fecha
# ISO casaba como versión) y la anterioridad sin límite de palabra («bastantes», «restantes»).
# Los dos están corregidos arriba —ENVIRON y borde izquierdo no alfabético; el borde DERECHO se
# retiró después por `SEC-102` y no hacía falta para esto— y aquí se EJERCEN, porque un arreglo de
# reconocedor que no se ejerce en los dos sentidos no se distingue de aflojarlo.
#
# Y con ellos va `v2`, la falsación de QA: una forma que **no está entre las siete** y que tiene que
# morder igual. Es lo que separa «arreglé la propiedad» de «añadí siete excepciones».
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 falsos positivos I-7" | grep -qi -- "$FILTRO"; then
  NEG40="$RAIZ/neg40-$BASHPID.txt"
  # Negativos: la frase que protege el texto personalizado, con un vecino inocente al lado. Ninguno
  # es un término heredado, así que ninguno puede convertirla en promesa de equivalencia.
  NEGS40=(
    'fecha ISO junto a la frase protectora::Decidido el 2026-09-14: tu texto se queda como está'
    'fecha ISO en la oración vecina::Corregido el 2026-09-14. Tu texto se queda como está'
    '«bastantes» (anterioridad dentro de otra palabra)::Hay bastantes casos y tu texto se queda como está'
    '«restantes» (ídem)::Los restantes: tu texto se queda como está'
    '«instantes» (ídem)::Durante unos instantes, tu texto se queda como está'
    'número suelto de 3 cifras::Nota 123: tu texto se queda como está'
  )
  neg_tot=0; neg_ok=0; neg_mal=''
  for entrada in "${NEGS40[@]}"; do
    neg_tot=$((neg_tot+1))
    eje="${entrada%%::*}"; texto="${entrada#*::}"
    printf '0\t- %s\n' "$texto" > "$NEG40"
    r="$(mide40p "$NEG40")"
    if [ "$r" = "0 0" ]; then neg_ok=$((neg_ok+1)); else neg_mal="$neg_mal · #$neg_tot [$eje] dio «$r» en vez de «0 0»: «$texto»"; fi
  done
  # Positivo de no-vacuidad: `v2` NO está entre las siete regresiones conocidas y tiene que morder.
  # Sin esto, «0 falsos positivos» sería cierto por haber dejado el reconocedor mudo.
  printf '0\t- sin la llave, la v2 decide exactamente lo mismo.\n' > "$NEG40"
  v2="$(mide40p "$NEG40")"; v2s="${v2##* }"
  if [ "$neg_ok" -eq "$neg_tot" ] && [ "${v2s:-0}" -ge 1 ]; then
    echo "  PASS  REQ-024 CA-06 los $neg_tot falsos positivos de I-7 ya no muerden, y el reconocedor no se quedó mudo  ($neg_ok de $neg_tot dan «0 0» —fechas ISO, números de 3 cifras y la anterioridad dentro de «bastantes»/«restantes»/«instantes»—; y la falsación «v2», que NO está entre las siete regresiones, sigue mordiendo con $v2s sin acto)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 falsos positivos I-7: $neg_ok de $neg_tot dan «0 0» (se esperaban $neg_tot)$neg_mal · y la falsación «v2» dio «$v2» (se esperaba sin acto >= 1; un 0 aquí significa que el reconocedor quedó mudo, no limpio)"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-06 · EL COSTE DEL BORDE, EJERCIDO POR LOS DOS LADOS (`SEC-102`) ----------
# Este caso existe porque es la TERCERA vez en esta cadena que un ajuste del reconocedor estrecha
# en silencio: `I-5` soltó siete formas al acotar el alcance, y el borde de palabra de `I-7` soltó
# otras tres al poner límites por ambos lados. El patrón es siempre el mismo —cada arreglo se
# ejerce sólo sobre los casos para los que se escribió—, y la respuesta no es más vigilancia sino
# un caso que mida **el COSTE** del ajuste, no sólo su ganancia.
#
# Las tres de abajo son REGRESIONES CONOCIDAS PERMANENTES, y por tanto POSITIVOS QUE DEBEN MORDER:
# las cazaba la cabeza anterior al borde derecho, están dentro de la clase que el EJE 1 enuncia
# —«toda expresión que señale un estado anterior de este arnés»— y las tres son promesas de
# equivalencia SIN su acto. NO SON EXCEPCIONES escritas una a una ni la definición de la clase: el
# arreglo vive en la PROPIEDAD (el borde va sólo a la izquierda, porque los falsos positivos llevan
# el término como sufijo y los verdaderos como prefijo), y estas tres sólo comprueban que la
# propiedad las alcanza. Como las siete de `I-5`, son **suelo ejercido y NO techo**, y el conjunto
# es declaradamente **NO EXHAUSTIVO**: una cuarta forma de decir «antes» se le escapa, y por eso el
# caso publica lo que ve en vez de afirmar «ninguna».
#
# Y LOS TRES NEGATIVOS VAN EN LA MISMA VUELTA, que es lo que este caso añade sobre los de arriba:
# los dos lados del borde se deciden JUNTOS y A LA VISTA. Quien vuelva a poner un límite por la
# derecha verá en el acto los tres verdaderos que cuesta; quien lo quite entero verá los tres
# falsos positivos que vuelven. Un caso que sólo mirase un lado enseña a pagar el otro sin saberlo.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 el coste del borde" | grep -qi -- "$FILTRO"; then
  BOR40="$RAIZ/bor40-$BASHPID.txt"
  # Positivos: el término heredado como PREFIJO de una palabra más larga. Se inyectan sobre una
  # COPIA del apartado, igual que las siete regresiones de `I-5`, y tienen que seguir mordiendo.
  BORS40=(
    'prefijo/«anteriormente»::anteriormente, decide exactamente lo mismo.'
    'prefijo/«previamente»::previamente, no nota nada.'
    'prefijo/«con anterioridad»::con anterioridad, decide exactamente lo mismo.'
  )
  bor_tot=0; bor_ok=0; bor_mal=''
  for entrada in "${BORS40[@]}"; do
    bor_tot=$((bor_tot+1))
    eje="${entrada%%::*}"; texto="${entrada#*::}"
    { cat "$AP40"; printf '0\t- %s\n' "$texto"; } > "$BOR40"
    r="$(mide40p "$BOR40")"; rs="${r##* }"
    if [ "${rs:-0}" -ge 1 ]; then bor_ok=$((bor_ok+1)); else bor_mal="$bor_mal · #$bor_tot [$eje] «$texto» no muerde"; fi
  done
  # El OTRO lado, aquí y no sólo en el caso de `I-7`: el término como SUFIJO tiene que seguir
  # rechazado por el borde IZQUIERDO. Van solos —no sobre el apartado—, porque lo que se exige es
  # el «0 0» exacto: sobre el apartado se mezclarían con sus dos promesas legítimas.
  BORN40=(
    'sufijo/«bastantes»::Hay bastantes casos y tu texto se queda como está'
    'sufijo/«restantes»::Los restantes: tu texto se queda como está'
    'sufijo/«instantes»::Durante unos instantes, tu texto se queda como está'
  )
  born_tot=0; born_ok=0; born_mal=''
  for entrada in "${BORN40[@]}"; do
    born_tot=$((born_tot+1))
    eje="${entrada%%::*}"; texto="${entrada#*::}"
    printf '0\t- %s\n' "$texto" > "$BOR40"
    r="$(mide40p "$BOR40")"
    if [ "$r" = "0 0" ]; then born_ok=$((born_ok+1)); else born_mal="$born_mal · #$born_tot [$eje] dio «$r» en vez de «0 0»: «$texto»"; fi
  done
  if [ "$bor_ok" -eq "$bor_tot" ] && [ "$born_ok" -eq "$born_tot" ]; then
    echo "  PASS  REQ-024 CA-06 el coste del borde: las $bor_tot formas con el término como PREFIJO vuelven a morder y los $born_tot negativos con el término como SUFIJO siguen en «0 0»  ($bor_ok de $bor_tot dan «sin acto» >= 1 —«anteriormente», «previamente», «con anterioridad»: regresiones CONOCIDAS de SEC-102, conjunto NO exhaustivo y NO excepciones—; $born_ok de $born_tot dan «0 0» —«bastantes», «restantes», «instantes»—, así que el borde izquierdo basta y el derecho no compra ninguno)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 el coste del borde: $bor_ok de $bor_tot prefijos muerden (se esperaban $bor_tot)$bor_mal · $born_ok de $born_tot sufijos dan «0 0» (se esperaban $born_tot)$born_mal · los dos lados se deciden juntos: recuperar unos no puede comprarse soltando los otros"; FAIL=$((FAIL+1))
  fi
fi

rm -f "$AP40"
