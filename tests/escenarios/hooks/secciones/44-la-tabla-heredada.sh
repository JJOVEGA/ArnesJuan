# Sección 44 del banco — 44-la-tabla-heredada
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna
# otra sección (invariantes 3 y 4 del README del banco).
#
# QUÉ MIDE Y POR QUÉ ESTÁ APARTE DE LA 42 Y DE LA 43. La 42 fija QUÉ FORMAS disparan cada
# aviso; la 43, QUÉ PROMETE el texto de ESE AVISO. Aquí se mide la TERCERA superficie, que
# no es el mensaje sino el DOCUMENTO: la tabla de `AGENTS.md` §13 y su gemela de plantilla,
# que es lo que todo proyecto hereda por `arnes-upgrade`. Un mensaje corregido y una tabla
# que sigue prometiendo lo contrario dejan a la máquina contradiciendo su documentación, y
# quien lee la tabla no ve el mensaje (`QA-024-38`, `SEC-084`; el contrato de los bloques A2, B, C y D es `REQ-024 CA-14` —(i)–(vi)—, y el de la fila del ORDEN del bloque A sigue siendo `CA-12 (ii)`, cuyo `Dado` está acotado a ella).
#
# TRES BLOQUES DE TEXTO Y NO DOS. A la fila del ORDEN (bloque A) y al párrafo del AVISO
# (bloque B) se suma la fila del CIERRE (bloque A2), que es la CUARTA sede de la misma
# promesa absoluta y la única que quedó sin corregir cuando se corrigieron las otras: decía
# «No completar sin `QA: aprobado` (salvo `Rigor: ligero`)» y, tras corregir el párrafo, el
# documento pasó a contradecirse a sí mismo.
#
# LO QUE UN PROYECTO YA INSTALADO RECIBE NO SE MIDE AQUÍ, y se dice para que nadie lea de
# más: esta sección acredita los DOS documentos del arnés. Un proyecto ya inicializado tiene
# su `AGENTS.md` CONGELADO y no recibe nada de esto sin migrar; quien mide que la migración
# lleve los tres bloques y no pise lo personalizado es `45-migracion-de-la-tabla-heredada.sh`.
#
# ESTA SECCIÓN ES SOBRE TEXTO, y por eso no usa `$HOOKS_DIR`: la ruta de los documentos se
# deriva de `$SEC_DIR`, igual que `40-…-3-los-textos-heredados.sh` y que los casos de
# `REQ-016 CA-10` en `36-…-4-el-informe-y-los-textos.sh`. Apuntar el banco a una instalación
# anterior (`ARNES_HOOKS_DIR`) tiene que seguir midiendo los hooks viejos contra los textos
# de HOY, que es justo lo que hay que poder distinguir.
#
# EL FAIL-BEFORE DE UN CASO SOBRE TEXTO NECESITA EL TEXTO DE ANTES, y `ARNES_HOOKS_DIR` no
# lo da. Por eso la raíz de los dos documentos se lee de `ARNES_DOCS_RAIZ` si está puesta
# —la misma técnica y el mismo motivo que `ARNES_SKILL_UPGRADE` en `40-…-3-…`—:
#   ARNES_DOCS_RAIZ=<copia del árbol anterior> bash tests/escenarios/hooks/run.sh secciones/44-*.sh
# tiene que FALLAR, y sin la variable tiene que pasar. Con la variable puesta la vuelta NO
# acredita el árbol: mide otros archivos, y lo dice el nombre de la variable.
#
# LOS CASOS MIDEN TEXTO, NO CONDUCTA, Y SE DICE AQUÍ (misma declaración que `REQ-024 CA-06
# (v)` en la 40/3): comprueban que el documento DIGA lo que la máquina hace, no que la
# máquina lo haga. Quien mide la conducta del aviso y de las seis celdas del cierre es
# `43-condicion-del-aviso.sh`; quien mide la del orden de las firmas —incluida la ausencia
# de `QA:` en los dos estados de la llave— es `13-orden-del-ciclo.sh` y `40-…-4-el-veredicto
# -de-seguridad.sh`. Aquí se cierra la otra mitad: que las dos sedes heredadas no digan otra
# cosa.
#
# EL RECONOCIMIENTO ES POR FRAGMENTO LITERAL Y SOBRE EL BLOQUE APLANADO, no línea a línea:
# una prueba de texto que casa un renglón concreto falla el día que alguien reajusta el
# ancho del párrafo sin cambiar ni una palabra, y ese rojo enseña a desactivar el control
# (H-11). El residuo conocido de reconocer por cadena queda dicho: una redacción nueva que
# dijera lo mismo con otras palabras pondría estos casos en rojo. Por eso cada FAIL publica
# el tamaño del bloque que midió, y por eso el discriminante del final comprueba que el
# reconocedor distingue un fragmento presente de uno inventado.
CASOS_ESPERADOS_SECCION=57
PISO_AUTONOMO_SECCION=174  # 55 preámbulo con sus dos declaraciones y el titular (líneas 1-55) + 31 maquinaria propia, que el corredor no tiene: los tres extractores, el reconocedor y el juez de fragmento (líneas 62-92) + 12 el juez de gemelas, que es maquinaria y va aparte porque vive con su bloque (líneas 188-199) + 76 bloque indivisible mayor (el bloque E, líneas 264-339: el negativo vivo lee el registro de ESTE archivo y no se lee suelto) · REQ-014 CA-18 · REGLA para re-derivar los términos sin preguntar: «preámbulo» son las líneas hasta el titular inclusive; un «bloque» es un grupo de líneas consecutivas sin blanca en medio, y el mayor que no es el preámbulo ni la maquinaria es el E; «maquinaria» es la que esta sección define porque el corredor no la tiene, no una copia de otra parte

seccion_nueva "Las dos sedes heredadas dicen lo que la maquina hace (REQ-024 CA-12 (ii), SEC-084, QA-024-38):"

REPO44="${SEC_DIR%/}/../../../.."
RAIZ44="${ARNES_DOCS_RAIZ:-$REPO44}"
SEDE_A44="$RAIZ44/AGENTS.md"
SEDE_T44="$RAIZ44/templates/AGENTS.md.tpl"

# --- MAQUINARIA PROPIA, y va con su motivo -----------------------------------------
# Ningún ayudante del corredor extrae un bloque de un documento ni reconoce texto: los que
# hay ejecutan hooks y juzgan su respuesta. Se define aquí porque NO lo hay, no por
# comodidad (README del banco, «Los ayudantes compartidos»). Ninguno ejecuta un hook, así
# que la guarda de la invariante 1 no aplica; a cambio, todos tratan el bloque VACÍO como
# FAIL: un documento que no se pudo leer no puede dar verde.
fila44() {   # <archivo> -> la fila de la tabla de §13 del orden de las firmas, entera
  awk 'substr($0, 1, 1) == "|" && index($0, "Seguridad no firma lo que QA no ha validado") { print; exit }' "$1" 2>/dev/null
}
cier44() {   # <archivo> -> la fila de la tabla de §13 del CIERRE, entera
  awk 'substr($0, 1, 1) == "|" && index($0, "El CIERRE juzga DOS cosas distintas") { print; exit }' "$1" 2>/dev/null
}
parr44() {   # <archivo> -> el bloque «Un hook que avisa sin decidir», APLANADO en una línea
  awk 'index($0, "**Un hook que avisa sin decidir.**") == 1 { d = 1 }
       d && $0 ~ /^[ \t]*$/ { exit }
       d { t = t $0 " " }
       END { sub(/[ \t]+$/, "", t); print t }' "$1" 2>/dev/null
}
esta44() {   # <texto> <fragmento literal> -> 0 si el texto lo dice
  case "$1" in *"$2"*) return 0 ;; *) return 1 ;; esac
}
mira44() {   # <nombre> <texto> <fragmento literal> — el bloque tiene que decirlo
  local nombre="$1" texto="$2" frag="$3"
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ -z "$texto" ]; then
    echo "  FAIL  $nombre  el bloque a medir salió VACÍO (¿falta el documento en $RAIZ44?): no hay texto que medir"
    FAIL=$((FAIL+1)); return 0
  fi
  if esta44 "$texto" "$frag"; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  el bloque medido (${#texto} caracteres) no dice «$frag»"; FAIL=$((FAIL+1)); fi
}

FILA_A44="$(fila44 "$SEDE_A44")"; FILA_T44="$(fila44 "$SEDE_T44")"
PARR_A44="$(parr44 "$SEDE_A44")"; PARR_T44="$(parr44 "$SEDE_T44")"
CIER_A44="$(cier44 "$SEDE_A44")"; CIER_T44="$(cier44 "$SEDE_T44")"

# --- A. LA FILA DEL ORDEN DE LAS FIRMAS (REQ-024 CA-12 (ii), salida (b)) -----------
# Ocho propiedades por sede. No son ocho maneras de decir lo mismo: son las que el criterio
# enumera —titular verdadero leído solo, el radio de la llave, la salida REAL, el disparador
# (`SEC-084`), el reparto por clasificación del lector, la consecuencia que NO es una sola
# cosa, y la frontera abierta con su sitio único—, y cada una cayó por separado en alguna
# vuelta. Se miden en las DOS sedes porque una corrección en una sola es el defecto que este
# proyecto lleva persiguiendo; que además sean IDÉNTICAS lo mide el bloque C.
for s44 in AGENTS.md templates/AGENTS.md.tpl; do
  [ "$s44" = "AGENTS.md" ] && f44="$FILA_A44" || f44="$FILA_T44"
  mira44 "44/A CA-12 (ii) [$s44] el titular cubre la ausencia: la linea QA: que no llega a declararse se trata como no validado" \
    "$f44" 'Seguridad no firma lo que QA no ha validado, tampoco cuando la línea `QA:` no llega a declararse: la ausencia se trata como no validado y se deniega nombrando el campo'
  mira44 "44/A CA-12 (ii) [$s44] ...y deniega en los DOS estados de campos.ausencia_exige, que no es opcion de proyecto" \
    "$f44" 'deniega en los DOS estados de `campos.ausencia_exige`'
  mira44 "44/A CA-12 (ii) [$s44] ...con la SALIDA que el propietario exige: pasar por la revision de QA" \
    "$f44" 'La salida es pasar por la revisión de QA y escribir el veredicto que ÉSA emita'
  mira44 "44/A CA-12 (ii) [$s44] ...diciendo que rellenar el campo sin la validacion es el fallo que la guarda impide" \
    "$f44" 'sin la validación detrás, es exactamente el fallo que esta guarda existe para impedir'
  mira44 "44/A SEC-084 [$s44] declara sobre QUE se ENTRA el acto: lo que el LECTOR lee, con su sitio unico citado y no enumerado" \
    "$f44" 'esta guarda juzga la firma que el **LECTOR** lee como el campo `Seguridad:` —conjunto de formas cuyo sitio único es el lector (`hooks/lib.sh`), citado y no enumerado—'
  mira44 "44/A SEC-084 [$s44] ...y reparte por la CLASIFICACION DEL LECTOR: desfase avisa sin denegar, y si ni eso, pasa sin aviso" \
    "$f44" 'si el lector la clasifica como **desfase** —no la lee como el campo, pero su plegado sí devuelve la clave— el arnés **AVISA sin denegar**; si ni siquiera eso, esta guarda la deja pasar **SIN aviso**'
  mira44 "44/A SEC-084 [$s44] ...y la consecuencia posterior NO es una sola cosa: medibilidad deniega, la ausencia no siempre" \
    "$f44" 'parte de esas líneas las coge la **guarda de medibilidad**, que **deniega citando la línea**; el resto llega al cierre como **campo no declarado**, donde manda la **dirección de la ausencia**, que **no siempre deniega**'
  mira44 "44/A SEC-084 [$s44] ...con la frontera declarada ABIERTA y su sitio unico, nombrando SEC-084" \
    "$f44" 'Frontera declarada y **abierta**: su clase, su dueño y su vencimiento viven en `docs/seguridad/registro-seguridad.md` (**SEC-084**)'
done

# --- A2. LA FILA DEL CIERRE (REQ-024 CA-14 (i)(ii)(iii), QA-024-38: la CUARTA sede) -
# La fila del CIERRE es de la misma familia que el párrafo del bloque B: prometía sin
# condición «No completar sin `QA: aprobado` (salvo `Rigor: ligero`)», y después de corregir
# el párrafo el propio documento se contradecía — con `campos.ausencia_exige` APAGADA, que es
# como nace todo proyecto, un REQ SIN línea `QA:` CIERRA en los TRES rigores (`43/E`, `40/6`).
# Diez propiedades por sede, y no son diez maneras de decir lo mismo: son los DOS EJES que esa
# fila confundía —el VALOR del campo y que el campo llegue a DECLARARSE—, cada uno con su
# gobernante y con sus umbrales, más el acotamiento del sujeto que la separa de la fila del
# orden (bloque A) y la evidencia medida. Se miden en las DOS sedes porque corregir una sola
# es el defecto que este proyecto lleva persiguiendo; la igualdad la mide el bloque C.
for s44 in AGENTS.md templates/AGENTS.md.tpl; do
  [ "$s44" = "AGENTS.md" ] && c44="$CIER_A44" || c44="$CIER_T44"
  mira44 "44/A2 CA-14 (i) · QA-024-38 [$s44] el titular separa los DOS ejes: el VALOR del campo y que el campo llegue a DECLARARSE" \
    "$c44" 'El CIERRE juzga DOS cosas distintas sobre cada veredicto, y NO las gobierna el mismo eje: qué VALOR lleva el campo, y que el campo llegue a DECLARARSE'
  mira44 "44/A2 CA-14 (ii) · QA-024-38 [$s44] ...y por VALOR el eje es el rigor efectivo, con los dos umbrales que NO coinciden" \
    "$c44" 'Por VALOR manda el rigor efectivo, y los dos umbrales NO coinciden'
  mira44 "44/A2 CA-14 (ii) · QA-024-38 [$s44] ...umbral de QA por valor: no cierra en estandar ni critico, y SI cierra en ligero" \
    "$c44" 'un `QA:` cuyo valor no sea `aprobado` no deja cerrar en `estandar` ni en `critico`, y **sí deja cerrar en `ligero`**'
  mira44 "44/A2 CA-14 (ii) · QA-024-38 [$s44] ...umbral de Seguridad por valor: solo en critico" \
    "$c44" 'un `Seguridad:` cuyo valor no sea `aprobado` no deja cerrar **sólo** en `critico`'
  mira44 "44/A2 CA-14 (ii) · QA-024-38 [$s44] ...y la llave NO mueve las celdas del VALOR, porque ahi el campo esta declarado" \
    "$c44" 'la llave `campos.ausencia_exige` **no mueve nada**: ahí el campo **está** declarado'
  mira44 "44/A2 CA-14 (iii) [$s44] ...la AUSENCIA es una PROPIEDAD y no una lista de vias, con sus ejemplos no exhaustivos y su sitio unico" \
    "$c44" 'Ausencia es una **propiedad** —que el campo no llegue a declararse—, no una lista de vías'
  mira44 "44/A2 CA-14 (iii) [$s44] ...y esos ejemplos van marcados no exhaustivos y remiten al registro de seguridad" \
    "$c44" 'son ejemplos **no exhaustivos**, y el sitio único de las vías conocidas es `docs/seguridad/registro-seguridad.md`'
  mira44 "44/A2 CA-14 (iii) · QA-024-38 [$s44] ...el eje de la AUSENCIA de QA: es LA LLAVE, y apagada el REQ cierra en los TRES rigores" \
    "$c44" 'con la llave APAGADA —como nace todo proyecto— un REQ SIN línea `QA:` CIERRA en los TRES rigores, también en `critico`'
  mira44 "44/A2 CA-14 (iii) · QA-024-38 [$s44] ...y el de la AUSENCIA de Seguridad: sigue siendo el RIGOR, igual en los dos estados" \
    "$c44" 'Para `Seguridad:` el eje sigue siendo el **rigor**: su ausencia no para el cierre por debajo de `critico`, idéntico en los dos estados de la llave'
  mira44 "44/A2 CA-14 (i) [$s44] ...y acota su sujeto al CIERRE, remitiendo el acto de FIRMAR a la fila del orden" \
    "$c44" 'esta fila habla del CIERRE y de nada más:** FIRMAR la seguridad sobre un REQ cuyo `QA:` no llega a declararse **deniega en los dos estados de la llave**, y eso va en la fila del **orden de las firmas**'
done

# --- B. EL PÁRRAFO DEL AVISO (REQ-024 CA-14 (ii)(iii)(iv), QA-024-38) --------------
# Seis propiedades por sede. La promesa vieja era una sola frase y su corrección no es una
# coletilla: el eje (el rigor), los DOS umbrales —que no coinciden—, lo que la llave NO
# mueve, el segundo aviso cuyo eje SÍ es la llave, y que ninguno de los dos avisos decide.
# Sin la última, el párrafo contradiría la fila del bloque A, que sí deniega esa edición.
for s44 in AGENTS.md templates/AGENTS.md.tpl; do
  [ "$s44" = "AGENTS.md" ] && p44="$PARR_A44" || p44="$PARR_T44"
  mira44 "44/B CA-14 (ii) · QA-024-38 [$s44] el aviso lleva su condicion, y la decide el RIGOR EFECTIVO" \
    "$p44" 'el aviso lleva su condición, porque la consecuencia sobre el cierre NO es incondicional:** lo que la decide es el **rigor efectivo**'
  mira44 "44/B CA-14 (ii) · QA-024-38 [$s44] ...y el umbral de QA: es estandar y critico, pero NO ligero, con su motivo" \
    "$p44" 'un `QA:` fuera de vocabulario impide cerrar en `estandar` y en `critico`, pero **no** en `ligero`, que no pide veredicto de QA y no juzga su valor'
  mira44 "44/B CA-14 (ii) · QA-024-38 [$s44] ...y el de Seguridad: es SOLO critico —los dos umbrales no coinciden—" \
    "$p44" 'un `Seguridad:` fuera de vocabulario impide cerrar **sólo** en `critico`'
  mira44 "44/B CA-14 (ii) · QA-024-38 [$s44] ...y dice que la llave NO mueve esas seis celdas, porque ahi el campo esta declarado" \
    "$p44" 'la llave `campos.ausencia_exige` **no mueve** ninguna de esas seis celdas: ahí el campo **está** declarado'
  mira44 "44/B CA-14 (iii) · QA-024-35 [$s44] ...y el OTRO aviso, el de la linea que parece el campo, con su eje por clave" \
    "$p44" 'para `QA:` lo resuelve `campos.ausencia_exige` (**apagada, como nace un proyecto**, el REQ cierra sin veredicto de QA; encendida, el cierre se deniega en los tres rigores) y para `Seguridad:` lo sigue resolviendo el **rigor**'
  mira44 "44/B CA-14 (iv) [$s44] ...y ningun aviso decide: quien deniega esa edicion es la guarda del orden, y la salida es pasar por QA" \
    "$p44" 'la del **orden de las firmas** deniega si emite `Seguridad: aprobado` sobre un REQ cuyo `QA:` no llega a declararse, y la salida es **pasar por QA**, no rellenar el campo'
done

# --- C. LAS DOS SEDES SON GEMELAS, Y ESO SE MIDE, NO SE AFIRMA (CA-14 (vi)) -------
# Los veintiocho de arriba pasarían con las dos sedes diciendo cosas PARECIDAS: cada uno
# mide su propio bloque. La igualdad byte a byte es una propiedad distinta y es la que este
# proyecto ha visto romperse —una corrección aplicada a una sola sede—, así que se compara
# el texto entero de los dos bloques y no una lista de fragmentos.
# EL JUEZ VA EN UNA FUNCIÓN Y NO REPETIDO TRES VECES, y eso no es estilo: el negativo vivo
# del bloque E tiene que poder EJERCERLO sobre un par mutado, y un juez copiado tres veces no
# se puede ejercer — se re-transcribe, y dos transcripciones se desfasan.
gemelas44() {   # <id> <sujeto> <texto en AGENTS.md> <texto en la plantilla>
  local id="$1" sujeto="$2" a="$3" b="$4"
  if [ -n "$FILTRO" ] && ! printf '%s' "$id $sujeto" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ -z "$a" ] || [ -z "$b" ]; then
    echo "  FAIL  $id $sujeto: no se pudo extraer de una de las dos sedes (${#a} caracteres en AGENTS.md, ${#b} en templates/AGENTS.md.tpl)"; FAIL=$((FAIL+1))
  elif [ "$a" = "$b" ]; then
    echo "  PASS  $id: $sujeto coincide byte a byte en las dos sedes (${#a} caracteres)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $id: $sujeto DIVERGE (${#a} caracteres en AGENTS.md contra ${#b} en templates/AGENTS.md.tpl): el proyecto y lo que heredan los demas prometen cosas distintas"; FAIL=$((FAIL+1))
  fi
}
gemelas44 "44/C CA-14 (vi) gemelas" "la fila del orden de las firmas" "$FILA_A44" "$FILA_T44"
gemelas44 "44/C CA-14 (vi) gemelas" "el parrafo del aviso" "$PARR_A44" "$PARR_T44"
gemelas44 "44/C CA-14 (vi) gemelas" "la fila del CIERRE" "$CIER_A44" "$CIER_T44"
# INYECCIÓN DEL COMPARADOR: sin ella, una comparación que siempre dijera «iguales» —dos
# extractores que devolvieran lo mismo vacío, por ejemplo— pasaría los dos casos de arriba.
if [ -z "$FILTRO" ] || printf '%s' "44/C CA-14 (vi) inyeccion gemelas" | grep -qi -- "$FILTRO"; then
  MUT44="${FILA_T44/DOS estados/UN estado}"
  if [ -z "$FILA_A44" ]; then
    echo "  FAIL  44/C CA-14 (vi) inyeccion gemelas: la fila de AGENTS.md salio vacia, no hay nada que mutar"; FAIL=$((FAIL+1))
  elif [ "$MUT44" = "$FILA_T44" ]; then
    echo "  FAIL  44/C CA-14 (vi) inyeccion gemelas: la mutacion no cambio nada (la fila no dice «DOS estados»), asi que la inyeccion no prueba el comparador"; FAIL=$((FAIL+1))
  elif [ "$FILA_A44" != "$MUT44" ]; then
    echo "  PASS  44/C CA-14 (vi) inyeccion gemelas: mutada una sola copia, la comparacion la ve divergente"; PASS=$((PASS+1))
  else
    echo "  FAIL  44/C CA-14 (vi) inyeccion gemelas: la comparacion da IGUALES una copia mutada: no compara nada"; FAIL=$((FAIL+1))
  fi
fi

# --- D. LA PROMESA VIEJA NO SOBREVIVE EN NINGUNA DE LAS DOS SEDES (CA-14 (v)) -----
# Caso NEGATIVO, y es el que impide el arreglo «por añadidura»: dejar la frase absoluta y
# colgarle debajo la condición deja la promesa igual de falsa para quien la lee sola, que es
# exactamente la forma que `SEC-079` midió. Se busca la cadena ENTERA de antes, no la
# palabra «cerrarse»: el texto nuevo cita esa frase para decir que quedó medida falsa.
if [ -z "$FILTRO" ] || printf '%s' "44/D CA-14 (v) la promesa vieja" | grep -qi -- "$FILTRO"; then
  VIEJA44='**no deniega** la edición: ese REQ no podrá cerrarse'
  if [ -z "$PARR_A44" ] || [ -z "$PARR_T44" ]; then
    echo "  FAIL  44/D CA-14 (v) la promesa vieja: no se pudo extraer el parrafo de una de las dos sedes"; FAIL=$((FAIL+1))
  elif esta44 "$PARR_A44" "$VIEJA44" || esta44 "$PARR_T44" "$VIEJA44"; then
    echo "  FAIL  44/D CA-14 (v) la promesa vieja sigue enunciada sin condicion en alguna de las dos sedes: «$VIEJA44»"; FAIL=$((FAIL+1))
  else
    echo "  PASS  44/D CA-14 (v) la promesa vieja no sobrevive en ninguna de las dos sedes"; PASS=$((PASS+1))
  fi
fi

# Y LA PROMESA VIEJA DE LA FILA DEL CIERRE TAMPOCO SOBREVIVE. Es el caso negativo gemelo del
# de arriba, sobre la CUARTA sede: dejar la frase absoluta —«No completar sin `QA: aprobado`
# (salvo `Rigor: ligero`)»— y colgarle la condición debajo la deja igual de falsa para quien
# lee la fila sola, que es como se lee una tabla. Se busca sobre el DOCUMENTO entero y no
# sobre la fila nueva: lo que no puede quedar es la fila vieja en ninguna parte de §13.
if [ -z "$FILTRO" ] || printf '%s' "44/D CA-14 (v) la promesa vieja de la fila del cierre" | grep -qi -- "$FILTRO"; then
  VIEJAC44='| No completar sin `QA: aprobado` (salvo `Rigor: ligero`)'
  if [ ! -f "$SEDE_A44" ] || [ ! -f "$SEDE_T44" ]; then
    echo "  FAIL  44/D CA-14 (v) la promesa vieja de la fila del cierre: falta una de las dos sedes ($SEDE_A44 / $SEDE_T44)"; FAIL=$((FAIL+1))
  elif grep -qF -- "$VIEJAC44" "$SEDE_A44" || grep -qF -- "$VIEJAC44" "$SEDE_T44"; then
    echo "  FAIL  44/D CA-14 (v) la fila vieja del cierre sigue en alguna de las dos sedes: «$VIEJAC44…»"; FAIL=$((FAIL+1))
  else
    echo "  PASS  44/D CA-14 (v) la fila vieja del cierre no sobrevive en ninguna de las dos sedes"; PASS=$((PASS+1))
  fi
fi

# --- DISCRIMINANTE. Sin él, un reconocedor roto que dijera «sí está» siempre pasaría los
# veintiocho casos de los bloques A y B, y uno que dijera «no está» siempre pondría el caso
# negativo D en verde. Se comprueban las dos direcciones sobre el mismo texto.
if [ -z "$FILTRO" ] || printf '%s' "44/discriminante CA-14 (anti-vacuidad)" | grep -qi -- "$FILTRO"; then
  if [ -z "$FILA_A44" ]; then
    echo "  FAIL  44/discriminante CA-14 (anti-vacuidad): la fila de AGENTS.md salio vacia, no hay sobre que discriminar"; FAIL=$((FAIL+1))
  elif esta44 "$FILA_A44" 'una frase que esta fila no dice en ninguna version'; then
    echo "  FAIL  44/discriminante CA-14 (anti-vacuidad): el reconocedor encuentra un fragmento INVENTADO: los casos de arriba no miden nada"; FAIL=$((FAIL+1))
  elif ! esta44 "$FILA_A44" 'Seguridad no firma lo que QA no ha validado'; then
    echo "  FAIL  44/discriminante CA-14 (anti-vacuidad): el reconocedor NO encuentra un fragmento que si esta en la fila"; FAIL=$((FAIL+1))
  else
    echo "  PASS  44/discriminante CA-14 (anti-vacuidad): el reconocedor distingue un fragmento presente de uno inventado"; PASS=$((PASS+1))
  fi
fi

# --- E. EL NEGATIVO VIVO DE `CA-14`, POR PROPIEDAD Y SOBRE EL REGISTRO REAL -------
# `CA-14`: «aplicado a un árbol en el que alguien RETIRE cualquiera de las obligaciones
# (i)–(viii) de una sede del conjunto, el caso FALLA nombrando la sede y la obligación retirada,
# en vez de pasar en silencio». La forma de LISTA está prohibida allí por el mismo motivo que en
# el «Dado»: una enumeración de negativos envejece hacia el lado que abre, y quien añada una
# obligación novena se quedaría sin su negativo sin que nada grite.
# POR ESO EL REGISTRO NO SE ESCRIBE AQUÍ: SE LEE DE ESTE MISMO ARCHIVO. Las obligaciones que
# esta sección contrata SON los fragmentos que `mira44` exige, y viven en un único sitio —el
# texto de la sección—, así que de ahí se sacan. Una obligación añadida mañana entra en el
# negativo sin tocar este bloque, y una retirada lo delata bajando el DENOMINADOR que se publica.
# Y EL JUEZ QUE SE EJERCE ES EL DE VERDAD: `mira44` y `gemelas44` corren dentro de `$( )` —o
# sea, en un subshell—, así que su veredicto se captura y sus contadores no tocan los del padre.
# Un juez reescrito para el negativo probaría el juez reescrito.
N44="44/E CA-14 (negativo vivo) retirada CUALQUIERA de las obligaciones del registro, el caso sale ROJO citando la frase"
if [ -z "$FILTRO" ] || printf '%s' "$N44" | grep -qi -- "$FILTRO"; then
  nobl44=0; mudas44=0; sincita44=0; primera44=''
  while IFS="$(printf '\t')" read -r var44 frag44; do
    [ -z "$frag44" ] && continue
    case "$var44" in
      f) texto44="$FILA_A44"; sede44='la fila del orden' ;;
      c) texto44="$CIER_A44"; sede44='la fila del cierre' ;;
      *) texto44="$PARR_A44"; sede44='el parrafo del aviso' ;;
    esac
    # Una obligación que HOY no está en la sede no se puede retirar: su ausencia ya la delata su
    # propio caso de los bloques A/A2/B, en rojo, y contarla aquí sería contarla dos veces.
    case "$texto44" in *"$frag44"*) ;; *) continue ;; esac
    nobl44=$((nobl44 + 1))
    mut44="${texto44//"$frag44"/}"
    salida44="$(FILTRO=''; mira44 "44/E ensayo [AGENTS.md, $sede44]" "$mut44" "$frag44")"
    case "$salida44" in
      *"  FAIL  "*)
        case "$salida44" in
          *"$frag44"*) ;;
          *) sincita44=$((sincita44 + 1)); [ -n "$primera44" ] || primera44="retirada de $sede44 «${frag44:0:60}…», el rojo NO cita la frase" ;;
        esac ;;
      *) mudas44=$((mudas44 + 1)); [ -n "$primera44" ] || primera44="retirada de $sede44 la obligacion «${frag44:0:60}…», el caso NO se puso en rojo" ;;
    esac
  done <<< "$(awk '
      /^[ \t]*"\$[fcp]44"[ \t]*\047/ {
        v = $0; sub(/^[ \t]*"\$/, "", v); v = substr(v, 1, 1)
        i = index($0, "\047"); j = length($0)
        while (j > i && substr($0, j, 1) != "\047") j--
        if (j <= i) next
        printf "%s\t%s\n", v, substr($0, i + 1, j - i - 1)
      }' "$SEC_DIR"/44-*.sh)"
  if [ "$nobl44" -eq 0 ]; then
    echo "  SKIP  $N44  el registro de obligaciones de esta seccion salio VACIO (suelo 1): sin obligaciones no hay negativo, y un verde aqui seria por vacio"; SKIP=$((${SKIP:-0} + 1))
  elif [ "$mudas44" -eq 0 ] && [ "$sincita44" -eq 0 ]; then
    echo "  PASS  $N44  ($nobl44 obligaciones del registro, retiradas una a una: las $nobl44 salen en rojo citando la frase)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $N44  de $nobl44 obligaciones, $mudas44 pasan en silencio al retirarlas y $sincita44 se ponen en rojo sin citar la frase: $primera44"; FAIL=$((FAIL+1))
  fi
fi
# Y LA OBLIGACIÓN (vi) NO SE RETIRA BORRANDO UNA FRASE, SINO DIVERGIENDO UNA COPIA, así que su
# negativo es otro acto sobre el mismo juez: mutada UNA de las dos gemelas, el cotejo tiene que
# salir en rojo y NOMBRAR el sujeto que diverge. La inyección de arriba (`44/C`) prueba que el
# comparador VE la mutación; ésta prueba que el CASO se pone en rojo y lo dice.
N44="44/E CA-14 (vi) (negativo vivo) divergida UNA gemela, el cotejo sale ROJO y nombra el sujeto"
if [ -z "$FILTRO" ] || printf '%s' "$N44" | grep -qi -- "$FILTRO"; then
  mut44="${CIER_T44/DOS cosas distintas/UNA cosa}"
  salida44="$(FILTRO=''; gemelas44 "44/E ensayo" "la fila del CIERRE" "$CIER_A44" "$mut44")"
  if [ -z "$CIER_A44" ] || [ -z "$CIER_T44" ]; then
    echo "  FAIL  $N44  la fila del cierre salio vacia en alguna sede: no hay gemela que divergir"; FAIL=$((FAIL+1))
  elif [ "$mut44" = "$CIER_T44" ]; then
    echo "  FAIL  $N44  la mutacion no cambio nada (la fila no dice «DOS cosas distintas»): el negativo no probaria nada"; FAIL=$((FAIL+1))
  else
    case "$salida44" in
      *"  FAIL  "*)
        case "$salida44" in
          *"la fila del CIERRE"*) echo "  PASS  $N44  (divergida una copia, el cotejo la caza y nombra el sujeto)"; PASS=$((PASS+1)) ;;
          *) echo "  FAIL  $N44  el cotejo se pone en rojo pero NO nombra el sujeto que diverge: «${salida44:0:120}…»"; FAIL=$((FAIL+1)) ;;
        esac ;;
      *) echo "  FAIL  $N44  divergida una copia, el cotejo NO se pone en rojo: «${salida44:0:120}…»"; FAIL=$((FAIL+1)) ;;
    esac
  fi
fi
