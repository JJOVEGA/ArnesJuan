# Sección 45 (2 de 3) del banco — 45-migracion-de-la-tabla-heredada-2-la-guia
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna
# otra sección (invariantes 3 y 4 del README del banco).
#
# QUÉ MIDE. Las partes 1 y 3 ejercen la MIGRACIÓN sobre maquetas de proyecto: clasifican, aplican,
# conserva lo personalizado y publica el conflicto. Esta parte mide la otra mitad, que no es
# mecánica sino de CONTRATO: que la skill `arnes-upgrade` MANDE esa migración. Un mecanismo
# correcto y una guía que no lo manda dejan al consumidor sin la corrección, porque la skill
# es lo único que un proyecto lee al actualizar — y el `AGENTS.md` de un proyecto ya
# inicializado está CONGELADO (`REQ-024 CA-14 (vii)`–`(viii)`, `QA-024-38`; la casa NO es `CA-12 (ii)`, cuyo `Dado` está acotado a la fila del orden de las firmas y no cubre el mandato de migración ni su algoritmo de clasificación).
#
# POR QUÉ VA APARTE Y NO AL FINAL DE LA PARTE 1: `REQ-014 CA-18`. Juntas medían 445 líneas
# sobre un techo de `max(400, piso × 1,25)`, y la autoprueba del corredor lo dijo en rojo. El
# corte no es por tamaño a ciegas: cae en la frontera natural entre EJERCER el mecanismo
# (parte 1, que necesita la línea base de git, las seis maquetas y el clasificador) y LEER un
# documento (parte 2, que sólo necesita el aplanador y las anclas).
#
# ESTA PARTE ES SOBRE TEXTO, y por eso no usa `$HOOKS_DIR`. El documento se lee de
# `ARNES_SKILL_UPGRADE` si está puesta —la misma técnica y el mismo motivo que en
# `40-…-3-los-textos-heredados.sh`—:
#   ARNES_SKILL_UPGRADE=<skill de antes> bash tests/escenarios/hooks/run.sh secciones/45-*-2-*.sh
# tiene que FALLAR, y sin la variable tiene que pasar. Con la variable puesta la vuelta NO
# acredita el árbol: mide otro archivo, y lo dice el nombre de la variable.
#
# LAS NUEVE ANCLAS ESTÁN DUPLICADAS RESPECTO DE LAS PARTES 1 Y 3, Y VA DICHO PORQUE ES UNA DECISIÓN.
# En `secciones/` no cabe un archivo auxiliar (el descubrimiento aborta ante lo que no case
# `NN-<slug>.sh`) y ninguna sección hace `source` de otra: veinte renglones copiados cuestan
# menos que una puerta trasera entre secciones (README del banco). Lo que esa duplicación NO
# tapa —que nadie comprueba que las dos copias coincidan— lo cierra el caso `45/17` —y `45/35` para las tres de INSERCIÓN, que entran con `QA-024-41`—: si las
# anclas de ESTE archivo no están en la guía, sale rojo; y si las partes ejecutables usaran
# otras, sus casos saldrían rojos sobre el documento real. Las copias sólo pueden quedarse
# calladas a la vez estando todas bien.
#
# EL RECONOCIMIENTO ES POR FRAGMENTO LITERAL SOBRE EL APARTADO APLANADO, no línea a línea:
# una prueba de texto que casa un renglón concreto falla el día que alguien reajusta el ancho
# del párrafo sin cambiar ni una palabra, y ese rojo enseña a desactivar el control (H-11). El
# residuo conocido: una redacción nueva que dijera lo mismo con otras palabras pondría estos
# casos en rojo, y la vía conforme es actualizar las anclas en los dos archivos, nunca retirar
# el caso. Por eso cada FAIL publica el tamaño del apartado que midió.
CASOS_ESPERADOS_SECCION=14
PISO_AUTONOMO_SECCION=131  # 44 preámbulo con sus dos declaraciones y el titular (líneas 1-44) + 20 maquinaria propia, que el corredor no tiene: el aplanador del apartado, el reconocedor y el juez de fragmento (líneas 62-81) + 67 bloque indivisible mayor (las cuatro tablas de anclas, líneas 49-60, y los casos que las recorren, líneas 83-137 — se declaran juntos porque ningún caso se lee sin ellas) · REQ-014 CA-18 · REGLA para re-derivar los tres términos sin preguntar: «preámbulo» son las líneas hasta el titular inclusive; un «bloque» es un grupo de líneas consecutivas sin blanca en medio; «maquinaria» es la que esta parte define porque el corredor no la tiene, no una copia de otra parte

seccion_nueva "--- 45/2 · la guia de migracion MANDA la sustitucion (REQ-024 CA-14 (vii)-(viii), QA-024-38) ---"

REPO45B="${SEC_DIR%/}/../../../.."
SK45B="${ARNES_SKILL_UPGRADE:-$REPO45B/skills/arnes-upgrade/SKILL.md}"

NOM45B=("fila del CIERRE" "fila del ORDEN de las firmas" "parrafo del aviso")
AO45B=('No completar sin `QA: aprobado`'
       'Seguridad no firma lo que QA no ha validado (salvo'
       '**no deniega** la edición: ese REQ no podrá cerrarse')
AD45B=('El CIERRE juzga DOS cosas distintas'
       'tampoco cuando la línea `QA:` no llega a declararse'
       'el aviso lleva su condición')
# La tercera ancla dice DONDE va un bloque `NUEVO` (`QA-024-41`). Sin ella declarada en la
# guía, un proyecto más viejo que el bloque no tiene forma de saber dónde insertarlo.
AINS45B=('La transición a `completado` no se hace por shell'
         'Los campos del REQ valen sólo en la cabecera'
         '**Es una barandilla, no una jaula.**')

# --- MAQUINARIA PROPIA, y va con su motivo -----------------------------------------
# Ningún ayudante del corredor aplana un apartado de Markdown ni reconoce texto: los que hay
# ejecutan hooks y juzgan su respuesta. Ninguno de éstos ejecuta un hook, así que la guarda de
# la invariante 1 no aplica; a cambio, el apartado VACÍO es FAIL y nunca PASS: un documento
# que no se pudo leer no puede dar verde.
APM45B=''
[ -f "$SK45B" ] && APM45B="$(awk '!d && /^### Hacia 1\.34\.0[ \t]*$/ { d = 1; next }
  d && (/^## / || /^\*\(/) { exit }
  d { s = $0; sub(/^[ \t]+/, "", s); printf "%s ", s }' "$SK45B")"
esta45b() { case "$1" in *"$2"*) return 0 ;; *) return 1 ;; esac; }
guia45b() {   # <nombre> <fragmento literal> — el apartado tiene que decirlo
  local nombre="$1" frag="$2"
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ -z "$APM45B" ]; then
    echo "  FAIL  $nombre  el apartado «Hacia 1.34.0» de ${SK45B##*/} salio VACIO: no hay guia que medir"
    FAIL=$((FAIL+1)); return 0
  fi
  if esta45b "$APM45B" "$frag"; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  el apartado medido (${#APM45B} caracteres) no dice «$frag»"; FAIL=$((FAIL+1)); fi
}

N45B="45/17 CA-14 (vii) la guia declara las SEIS anclas que la parte 1 ejerce"
if [ -z "$FILTRO" ] || printf '%s' "$N45B" | grep -qi -- "$FILTRO"; then
  if [ -z "$APM45B" ]; then
    echo "  FAIL  $N45B  el apartado «Hacia 1.34.0» de ${SK45B##*/} salio VACIO: no hay guia que medir"; FAIL=$((FAIL+1))
  else
    falta45b=''
    for i45b in 0 1 2; do
      esta45b "$APM45B" "${AO45B[$i45b]}" || falta45b="$falta45b origen-${NOM45B[$i45b]}"
      esta45b "$APM45B" "${AD45B[$i45b]}" || falta45b="$falta45b destino-${NOM45B[$i45b]}"
    done
    if [ -z "$falta45b" ]; then
      echo "  PASS  $N45B"; PASS=$((PASS+1))
    else
      echo "  FAIL  $N45B  el banco y la guia han divergido; la guia no declara:$falta45b"; FAIL=$((FAIL+1))
    fi
  fi
fi
N45B="45/35 CA-14 (viii) la guia declara las TRES anclas de INSERCION que dicen donde va un bloque NUEVO"
if [ -z "$FILTRO" ] || printf '%s' "$N45B" | grep -qi -- "$FILTRO"; then
  if [ -z "$APM45B" ]; then
    echo "  FAIL  $N45B  el apartado «Hacia 1.34.0» de ${SK45B##*/} salio VACIO: no hay guia que medir"; FAIL=$((FAIL+1))
  else
    falta45b=''
    for i45b in 0 1 2; do
      esta45b "$APM45B" "${AINS45B[$i45b]}" || falta45b="$falta45b insercion-${NOM45B[$i45b]}"
    done
    if [ -z "$falta45b" ]; then
      echo "  PASS  $N45B"; PASS=$((PASS+1))
    else
      echo "  FAIL  $N45B  el banco y la guia han divergido; la guia no declara:$falta45b"; FAIL=$((FAIL+1))
    fi
  fi
fi
guia45b "45/36 CA-14 (viii) la guia hace la PREGUNTA PREVIA antes de las dos cuentas: ¿tenia la base este bloque?" \
  '¿tenía la BASE este bloque?'
guia45b "45/37 CA-14 (viii) ...y dice el efecto de omitirla: el proyecto no puede migrar nunca, sin conflicto real que resolver" \
  'el proyecto no puede migrar nunca'
guia45b "45/38 CA-14 (viii) ...y clasifica NUEVO el bloque que no existia en la base, con su sitio" \
  '| 0 / 0 | **no** | `NUEVO` | **añadir** inmediatamente antes del ancla de inserción, y nada más |'
guia45b "45/39 CA-14 (viii) ...y limita NUEVO a anadir: el resto del AGENTS.md del proyecto no se toca" \
  '**Añade y no sustituye:**'
guia45b "45/40 CA-14 (viii) ...y si el proyecto ya tiene algo en esa ancla, NO es NUEVO: vuelve al camino del conflicto" \
  '**Si el proyecto ya tiene algo en esa ancla, no es `NUEVO`:**'
guia45b "45/18 CA-14 (vii) la guia manda sustituir los tres textos en el AGENTS.md ya congelado del proyecto" \
  'TRES TEXTOS DE `AGENTS.md` §13 QUE HAY QUE SUSTITUIR EN EL PROYECTO'
guia45b "45/19 CA-14 (vii) ...y dice por que no basta corregir la plantilla: el proyecto instalado se queda con las promesas falsas" \
  'un proyecto actualiza a 1.34.0 y **se queda con las promesas falsas**'
guia45b "45/20 CA-14 (vii) ...con el mecanismo existente: merge a tres vias, bloque a bloque, sin sobrescribir AGENTS.md entero" \
  'con el merge a tres vías de esta misma skill, BLOQUE A BLOQUE'
guia45b "45/21 CA-14 (vii) ...y prohibe retocar la instantanea de origen para que el diff salga limpio" \
  'no se retoca antes de comparar, ni para que el diff salga más limpio'
guia45b "45/22 CA-14 (vii) ...y ante un conflicto conserva el contenido y lo publica como pendiente de resolver" \
  'el contenido del proyecto **sigue ahí entero**'
guia45b "45/23 CA-14 (vii) ...y con un conflicto abierto NO declara la migracion completada" \
  'en ninguna parte se escribe que el proyecto quedó migrado'

# --- EL NEGATIVO VIVO DE `CA-14` SOBRE LA GUÍA, POR PROPIEDAD Y NO POR LISTA -------
# `CA-14`: «aplicado a un árbol en el que alguien RETIRE cualquiera de las obligaciones (i)–(viii)
# de una sede del conjunto, el caso FALLA nombrando la sede y la obligación retirada, en vez de
# pasar en silencio» — y la forma de lista está prohibida ahí porque una enumeración de negativos
# envejece hacia el lado que abre. Aquí la sede es `skills/arnes-upgrade/SKILL.md` y las
# obligaciones son las de `(vii)` —que la guía MANDE la sustitución— y `(viii)` —que ese mandato
# ATERRICE sobre una base anterior al bloque—.
# EL REGISTRO SE LEE DE ESTE MISMO ARCHIVO, que es donde vive: los fragmentos que `guia45b`
# exige. Una obligación añadida mañana entra en el negativo sin tocar este bloque, y una retirada
# lo delata bajando el DENOMINADOR que se publica. Y el juez que se ejerce es EL DE VERDAD:
# `guia45b` corre dentro de `$( )` —en un subshell—, así que su veredicto se captura y sus
# contadores no tocan los del padre; un juez reescrito para el negativo probaría el juez reescrito.
# LO QUE ESTE NEGATIVO NO ES: no es una ejecución de la migración. Retirar una frase de la guía y
# ver el rojo acredita el CONTRATO de la guía, nunca que un proyecto instalado haya migrado
# (`CA-14 (viii)`, limitación declarada; las partes 1 y 3 ejercen el clasificador, que tampoco es
# el procedimiento real).
N45B="45/24 CA-14 (vii)-(viii) (negativo vivo) retirada CUALQUIERA de las obligaciones de la guia, el caso sale ROJO citando la frase"
if [ -z "$FILTRO" ] || printf '%s' "$N45B" | grep -qi -- "$FILTRO"; then
  nobl45b=0; mudas45b=0; sincita45b=0; primera45b=''
  while IFS= read -r frag45b; do
    [ -z "$frag45b" ] && continue
    case "$APM45B" in *"$frag45b"*) ;; *) continue ;; esac
    nobl45b=$((nobl45b + 1))
    mut45b="${APM45B//"$frag45b"/}"
    salida45b="$(FILTRO=''; APM45B="$mut45b"; guia45b "45/24 ensayo [${SK45B##*/}]" "$frag45b")"
    case "$salida45b" in
      *"  FAIL  "*)
        case "$salida45b" in
          *"$frag45b"*) ;;
          *) sincita45b=$((sincita45b + 1)); [ -n "$primera45b" ] || primera45b="retirada «${frag45b:0:60}…», el rojo NO cita la frase" ;;
        esac ;;
      *) mudas45b=$((mudas45b + 1)); [ -n "$primera45b" ] || primera45b="retirada la obligacion «${frag45b:0:60}…», el caso NO se puso en rojo" ;;
    esac
  done <<< "$(awk '
      prev ~ /^guia45b / && $0 ~ /^[ \t]*\047/ {
        i = index($0, "\047"); j = length($0)
        while (j > i && substr($0, j, 1) != "\047") j--
        if (j > i) print substr($0, i + 1, j - i - 1)
      }
      { prev = $0 }' "$SEC_DIR"/45-*-2-la-guia.sh)"
  if [ "$nobl45b" -eq 0 ]; then
    echo "  SKIP  $N45B  el registro de obligaciones de la guia salio VACIO (suelo 1): sin obligaciones no hay negativo, y un verde aqui seria por vacio"; SKIP=$((${SKIP:-0} + 1))
  elif [ "$mudas45b" -eq 0 ] && [ "$sincita45b" -eq 0 ]; then
    echo "  PASS  $N45B  ($nobl45b obligaciones del registro, retiradas una a una de la guia: las $nobl45b salen en rojo citando la frase)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $N45B  de $nobl45b obligaciones, $mudas45b pasan en silencio al retirarlas y $sincita45b se ponen en rojo sin citar la frase: $primera45b"; FAIL=$((FAIL+1))
  fi
fi
