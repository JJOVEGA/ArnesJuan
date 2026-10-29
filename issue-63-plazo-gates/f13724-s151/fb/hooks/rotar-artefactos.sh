#!/usr/bin/env bash
# Hook Stop / SubagentStop: mueve las secciones viejas de un artefacto que crecio
# demasiado a un archivo aparte, dejando un puntero. Y, desde 1.31.0, mueve las ENTRADAS
# viejas de UNA SECCION declarada de un documento, dejando el resto intacto.
#
# POR QUE EXISTE
# Un artefacto de bitacora --CHANGELOG, registro de seguridad, hallazgos-- crece sin
# tope, y todo lo que crece sin tope acaba entrando entero en la ventana de contexto.
# Medido en un proyecto real: el CHANGELOG.md llego a 1,17 MB. A ~4 caracteres por
# token son del orden de 300.000 tokens en UN archivo, y se pagan otra vez en cada
# sesion que lo lea. No es un problema de disco: es presupuesto.
#
# QUE NO HACE, Y ES LA PARTE IMPORTANTE
# No resume, no reescribe, no borra. MUEVE texto de un archivo a otro y deja un
# puntero. Un resumen aqui seria peor que el problema: convertiria la bitacora en
# la version que el modelo recuerda de la bitacora.
#
# INVARIANTES
# - APAGADO salvo que el proyecto lo encienda. Reestructurar un documento que
#   escribio una persona no puede ser el comportamiento por defecto.
# - NUNCA BORRA. Primero se anade al archivo destino, se RELEE para comprobar que
#   esta, y solo entonces se recorta el origen. Si la comprobacion falla, no se toca
#   el origen: se prefiere un archivo grande a un archivo perdido.
# - CORTA SOLO EN LIMITES DE SECCION (`## `) O DE ENTRADA. Si no encuentra limites
#   seguros, no hace nada. Un corte a media seccion parte una entrada en dos.
# - EN LA ROTACION DE SECCION, NO TOCA NADA FUERA DE ELLA. Ni la cabecera del documento
#   ni las demas secciones: los criterios de un REQ son el CONTRATO, y una rotacion que
#   pudiera alterar la cabecera seria un camino para cerrar o firmar un REQ sin pasar por
#   ninguna puerta.
# - EL "TODO O NADA" AGUANTA TAMBIEN CON DOS PARADAS A LA VEZ (REQ-015): los cuatro
#   temporales de publicacion de este archivo llevan una componente PROPIA DEL PROCESO,
#   asi que dos paradas simultaneas no comparten archivo. Con nombre fijo si lo
#   compartian, y tras el `mv` de una la escritura tardia de la otra caia encima del
#   destino ya publicado -- en la rotacion de seccion, encima de un REQ o de ESTADO.md.
#   Lo que NO se promete: no hay serializacion; si dos paradas rotan el mismo artefacto,
#   una de las dos no encontrara nada que mover, y eso es conforme.
# - NUNCA BLOQUEA la parada, como el resto de hooks Stop.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/lib.sh"

arnes_rotar_artefactos() {
  local tipo ruta orden umbral conservar seccion adir f
  arnes_parse_manifest_rotacion || return 0
  [ "$ARNES_ROT_ACTIVO" = "true" ] || return 0
  [ -n "$ARNES_ROT_LISTA" ] || return 0
  while IFS=$'	' read -r tipo ruta orden umbral conservar seccion adir; do
    [ -n "$ruta" ] || continue
    arnes_ruta_interna "$ruta" || continue   # fuera del proyecto: no se toca
    case "$tipo" in
      seccion)
        [ -n "$seccion" ] || continue        # sin seccion declarada no hay rotacion de seccion
        # El glob se expande AQUI, y cada archivo pasa despues por la misma contencion
        # fisica que un artefacto declarado por ruta.
        for f in "$ARNES_PROJ"/$ruta; do
          [ -f "$f" ] || continue
          arnes_rotar_seccion "$f" "$seccion" "$orden" "$umbral" "$conservar" "$adir" || true
        done ;;
      *)
        arnes_rotar_uno "$ARNES_PROJ/$ruta" "$orden" "$umbral" "$conservar" || true ;;
    esac
  done <<< "$ARNES_ROT_LISTA"
  return 0
}

# arnes_rotar_uno <ruta> <orden> <umbral> <conservar> — rota UN artefacto si le toca.
# Los ajustes llegan por parametro, no por global: cada artefacto tiene los suyos.
arnes_rotar_uno() {
  local f="$1" orden="$2" umbral="$3" conservar="$4" destino tam texto linea
  local preambulo='' seccion='' secciones=0 i=0 corte
  [ -f "$f" ] || return 0
  arnes_dir_interno "${f%/*}" || return 0   # contencion FISICA: el directorio del artefacto, resuelto, dentro del proyecto

  # Sin `wc -c`: era un fork por artefacto en CADA parada, aunque no hubiera nada que
  # rotar (medido: 12,6 s en un proyecto real con dos artefactos y nada que mover).
  # El archivo se lee de todos modos justo despues; se compara la longitud leida. Cuenta
  # caracteres y no bytes --con UTF-8 queda un poco por debajo--, y para un umbral de
  # rotacion eso es aceptable: se rota un poco mas tarde, nunca antes de tiempo.
  # `umbral_bytes` mide BYTES, y ${#texto} cuenta CARACTERES salvo en locale C: un
  # archivo UTF-8 de 4 032 bytes y 2 032 caracteres con umbral 3 000 rotaba en 1.29.2 y
  # dejo de rotar en 1.29.3. Lo midio una revision externa. LC_ALL=C solo para la
  # cuenta, y se restaura: el resto de la funcion no depende del locale, pero no hay
  # razon para cambiarselo a `date` ni a `grep`.
  IFS= read -r -d '' texto < "$f"
  local _lc_prev="${LC_ALL-__sin__}" tam_bytes
  LC_ALL=C; tam_bytes="${#texto}"
  if [ "$_lc_prev" = "__sin__" ]; then unset LC_ALL; else LC_ALL="$_lc_prev"; fi
  [ "$tam_bytes" -gt "$umbral" ] 2>/dev/null || return 0

  # --- Se parte en secciones de nivel 2. Sin limites, no se toca nada. ---
  local -a cuerpos=()
  while IFS= read -r linea; do
    case "$linea" in
      '## '*)
        if [ "$secciones" -eq 0 ]; then preambulo="$seccion"; else cuerpos+=("$seccion"); fi
        seccion="$linea"$'\n'; secciones=$((secciones+1)) ;;
      *)
        seccion+="$linea"$'\n' ;;
    esac
  done <<< "$texto"
  if [ "$secciones" -eq 0 ]; then return 0; fi
  cuerpos+=("$seccion")

  # Sin excedente por encima de lo que hay que conservar, no hay nada que mover.
  # Y como al terminar quedan EXACTAMENTE `conservar` secciones, la siguiente pasada
  # no encuentra excedente: la idempotencia sale de aqui, no de una comprobacion
  # aparte. (La primera version restaba al reves --conservaba `total - conservar`--
  # y cada pasada volvia a rotar, vaciando el archivo a trozos.)
  local total="${#cuerpos[@]}"
  [ "$total" -gt "$conservar" ] || return 0
  corte="$conservar"

  # --- Que mitad es "lo viejo" NO se adivina: se declara ---
  # Un CHANGELOG pone lo nuevo arriba; un registro cronologico lo anade al final.
  # Adivinar mal significa archivar lo mas RECIENTE, que es justo lo que hay que
  # tener a mano. Por defecto se asume la convencion del CHANGELOG, que es la que
  # usan las plantillas del arnes; lo contrario se declara con
  # `rotacion.orden: "nuevo-al-final"`.
  local viejo='' nuevo=''
  if [ "$orden" = "nuevo-al-final" ]; then
    for (( i=0; i<total-corte; i++ )); do viejo+="${cuerpos[$i]}"; done
    for (( i=total-corte; i<total; i++ )); do nuevo+="${cuerpos[$i]}"; done
  else
    for (( i=corte; i<total; i++ )); do viejo+="${cuerpos[$i]}"; done
    for (( i=0; i<corte; i++ )); do nuevo+="${cuerpos[$i]}"; done
  fi
  [ -n "$viejo" ] || return 0

  destino="${f%.md}-archivo.md"

  # --- 1) Construir el destino COMPLETO aparte, verificarlo, y solo entonces mover --
  #
  # Antes se anadia al destino y DESPUES se verificaba. Cuando la verificacion
  # fallaba, el contenido ya estaba en el destino y el origen no se recortaba: quedaba
  # DUPLICADO, y la siguiente parada lo volvia a anadir. Medido con un archivo CRLF:
  # 3 -> 6 -> 9 secciones en tres pasadas. Una fuga sin tope, justo en la funcion cuyo
  # proposito es frenar el crecimiento sin tope.
  #
  # Ahora el destino se arma en un temporal y solo se publica si la verificacion pasa.
  # Todo o nada: ni se pierde contenido ni se duplica.
  #
  # Y LOS DOS TEMPORALES SE NOMBRAN AQUI, ANTES DE PUBLICAR NADA: son propios de este
  # proceso (REQ-015 CA-01), porque con nombre fijo dos paradas simultaneas escribian el
  # mismo archivo y, tras el `mv` de una, la escritura tardia de la otra caia sobre el
  # destino ya publicado. Se piden los dos ANTES del primer `mv` a proposito: si el nombre
  # unico no se puede formar hay que salir SIN HABER TOCADO nada, porque abortar entre el
  # destino y el recorte del origen es justo la duplicacion que CA-07 prohibe.
  local marca tmp_dest tmp_orig
  marca="<!-- ARNES:ROTADO $(date '+%Y-%m-%d %H:%M') -->"
  if ! arnes_tmp_publicacion "$destino"; then arnes_rot_sin_tmp "$f"; return 0; fi
  tmp_dest="$ARNES_TMP"
  if ! arnes_tmp_publicacion "$f"; then arnes_rot_sin_tmp "$f"; return 0; fi
  tmp_orig="$ARNES_TMP"
  if [ -f "$destino" ]; then
    cat "$destino" > "$tmp_dest" || { rm -f "$tmp_dest"; return 0; }
  else
    printf '# Archivo de %s\n\n> Secciones retiradas de `%s` para que no crezca sin tope.\n> Se MOVIERON tal cual: aqui no hay resumen ni reescritura.\n\n' \
      "$(basename "$f")" "$(basename "$f")" > "$tmp_dest" || { rm -f "$tmp_dest"; return 0; }
  fi
  printf '%s\n%s\n' "$marca" "$viejo" >> "$tmp_dest" || { rm -f "$tmp_dest"; return 0; }

  # La prueba no es que el append no fallara: es que el texto ESTE en el disco.
  #
  # Se comprueba con `grep -F`, no con `case`: un encabezado de CHANGELOG lleva
  # corchetes --`## [1.20.0]`-- y en un patron de `case` los corchetes son una CLASE
  # DE CARACTERES, no texto.
  #
  # Y a la sonda se le RETIRA EL CR FINAL. En un archivo CRLF, cortar por el salto de
  # linea deja el CR pegado al final de la sonda, mientras que grep en Windows lee el
  # archivo en modo texto y ya lo ha quitado de sus lineas: 92 bytes contra 91, y no
  # casaba NUNCA. Es la misma familia que el CR de jq que dejaba `guard-codigo` en
  # abierto -- solo que aqui viene del propio archivo, y en Windows eso es la mayoria
  # de los archivos. Quitarlo es seguro en los dos casos: `-F` busca subcadena, asi
  # que la sonda sin CR casa igual con una linea que lo conserve.
  local sonda NL=$'\n' CR=$'\r'
  sonda="${viejo%%"$NL"*}"
  sonda="${sonda%"$CR"}"
  grep -qF -- "$sonda" "$tmp_dest" || { rm -f "$tmp_dest"; return 0; }
  mv -f "$tmp_dest" "$destino" || { rm -f "$tmp_dest"; return 0; }

  # --- 2) Solo ahora se recorta el origen ---
  local puntero="> Las secciones anteriores se movieron a [\`$(basename "$destino")\`]($(basename "$destino")) — el arnés las rota para que este archivo no crezca sin tope."
  printf '%s%s\n\n%s' "$preambulo" "$puntero" "$nuevo" > "$tmp_orig" && mv -f "$tmp_orig" "$f"
  # Si el `printf` fallo, el temporal no se queda de resto. El `[ -f ]` es un builtin y en el
  # camino bueno el `mv` ya se lo llevo, asi que el `rm` --el unico proceso de esta linea--
  # solo se paga cuando de verdad hay algo que retirar (REQ-015 CA-11).
  [ -f "$tmp_orig" ] && rm -f "$tmp_orig" 2>/dev/null
  return 0
}

# El aviso de que no hay componente unica para el temporal, en un solo sitio: los cuatro
# puntos de publicacion de este archivo dicen lo mismo porque el motivo es el mismo.
arnes_rot_sin_tmp() {   # <archivo de origen>
  arnes_warn "rotacion: no se pudo formar un nombre de temporal propio de este proceso ('BASHPID' vacio o no numerico); NO se rota nada en '${1#"$ARNES_PROJ/"}' y ni el destino ni el origen se tocan. Caer al nombre compartido reintroduciria la carrera de dos paradas simultaneas (REQ-015)."
}

# arnes_rotar_seccion <archivo> <seccion> <orden> <umbral> <conservar> <archivo_dir>
#
# Rota UNA SECCION de un documento —la que declare el proyecto— moviendo sus entradas
# viejas a un archivo aparte y dejando un puntero. EL RESTO DEL DOCUMENTO NO SE TOCA.
#
# POR QUE. Medido en un proyecto real: `requirements/` pesaba 3,73 MB en 47 archivos, el
# mayor de 244 KB. Ese peso lo paga CADA agente que abre el REQ para leer dos criterios.
# La rotacion por secciones `## ` que existia desde 1.20.0 no servia aqui: en un REQ lo
# que crece es UNA seccion y el resto es el contrato.
#
# QUE SECCION ES "HISTORIA" NO LO DECIDE EL ARNES. No hay ninguna seccion por defecto en
# este archivo: sin `seccion` declarada no hay rotacion de seccion. El arnes trae el
# mecanismo (cuantas entradas conservar, adonde moverlas, en que orden); el mapeo lo pone
# el manifiesto del proyecto.
#
# ENTRADA = lo que empieza a columna cero por `- `, `* `, `### ` o `N. `. Cualquier otra
# linea pertenece a la entrada anterior (continuacion: una linea indentada, una fila de
# tabla, un parrafo suelto) o, antes de la primera, al preambulo de la seccion, que se
# conserva. Una seccion sin entradas reconocibles no se toca: no hay limite seguro donde
# cortar, y cortar sin limite parte una entrada en dos.
arnes_rotar_seccion() {
  local f="$1" sec="$2" orden="$3" umbral="$4" conservar="$5" adir="$6"
  local texto linea antes='' cab='' cuerpo='' despues='' fase=0 rec fin_nl=0
  [ -f "$f" ] || return 0
  arnes_dir_interno "${f%/*}" || return 0
  texto=''; IFS= read -r -d '' texto < "$f"
  # El salto FINAL se aparta y se repone tal cual. Si no, el troceado por lineas lo
  # devuelve como una linea vacia de mas y el documento reconstruido gana un salto en cada
  # pasada: CA-03 exige que todo lo que no es la seccion quede byte a byte igual, y "casi
  # igual" en un archivo que se reescribe en cada parada crece sin tope.
  case "$texto" in *$'\n') fin_nl=1; texto="${texto%$'\n'}" ;; esac

  # 1) La seccion va de SU CABECERA a la siguiente cabecera `## ` o al final. La
  #    comparacion del nombre es EXACTA sobre la linea entera (recortando el espacio final
  #    y el CR de un archivo CRLF), NUNCA por prefijo: con prefijo, declarar
  #    `## Historial` se llevaria por delante `## Historial de cambios` —o al reves— y la
  #    rotacion escribiria en una seccion que el proyecto no nombro. Lo de antes y lo de
  #    despues se conserva byte a byte.
  while IFS= read -r linea || [ -n "$linea" ]; do
    rec="${linea%"${linea##*[![:space:]]}"}"
    case "$fase" in
      0) if [ "$rec" = "$sec" ]; then cab="$linea"$'\n'; fase=1; else antes+="$linea"$'\n'; fi ;;
      1) case "$linea" in '## '*) despues+="$linea"$'\n'; fase=2 ;; *) cuerpo+="$linea"$'\n' ;; esac ;;
      *) despues+="$linea"$'\n' ;;
    esac
  done <<< "$texto"
  # EL DOCUMENTO NO TIENE ESA SECCION: no se toca, Y SE DICE (CA-09, QA-102).
  #
  # No rotar es lo correcto —la comparacion es exacta y rotar por prefijo seria adivinar
  # que quiso decir el manifiesto—, pero salir en silencio convierte un ERROR DE MAPEO en
  # un acierto aparente: el proyecto declaro `## Historial`, su documento dice `## Historial
  # de cambios`, y cree que rota desde hace meses. Un artefacto declarado que no existe hay
  # que verlo. Se avisa por stderr (no bloquea nunca: es un hook de parada) y se cuenta,
  # para que el bloque derivado lo refleje sin volver a mirar el disco.
  if [ "$fase" -lt 1 ]; then
    arnes_warn "rotacion: '${f#"$ARNES_PROJ/"}' casa el artefacto declarado pero NO contiene la seccion '$sec'; no se rota nada en ese archivo. La comparacion del nombre de la seccion es EXACTA (nunca por prefijo): revisa 'rotacion.artefactos[].seccion' en .arnes/config.json, o el encabezado del documento."
    ARNES_ROT_SIN_SECCION=$(( ${ARNES_ROT_SIN_SECCION:-0} + 1 ))
    [ -n "${ARNES_ROT_SIN_SECCION_EJ:-}" ] || ARNES_ROT_SIN_SECCION_EJ="${f##*/}|$sec"
    return 0
  fi

  # 2) Manda el tamano de LA SECCION, no el del archivo, y en BYTES (`LC_ALL=C` solo para
  #    la cuenta, como en `arnes_rotar_uno`: `${#texto}` cuenta caracteres en UTF-8).
  local _lc_prev="${LC_ALL-__sin__}" tam_bytes
  LC_ALL=C; tam_bytes="${#cuerpo}"
  if [ "$_lc_prev" = "__sin__" ]; then unset LC_ALL; else LC_ALL="$_lc_prev"; fi
  [ "$tam_bytes" -gt "$umbral" ] 2>/dev/null || return 0

  # 3) Preambulo de la seccion + entradas con sus continuaciones.
  local -a ent=()
  local pre='' cur='' hay=0
  while IFS= read -r linea || [ -n "$linea" ]; do
    case "$linea" in
      '- '*|'* '*|'### '*|[0-9]'. '*|[0-9][0-9]'. '*|[0-9][0-9][0-9]'. '*)
        [ "$hay" -eq 1 ] && ent+=("$cur")
        cur="$linea"$'\n'; hay=1 ;;
      *)
        if [ "$hay" -eq 1 ]; then cur+="$linea"$'\n'; else pre+="$linea"$'\n'; fi ;;
    esac
  done <<< "$cuerpo"
  [ "$hay" -eq 1 ] && ent+=("$cur")
  local total="${#ent[@]}"
  # LA SECCION EXISTE PERO NO TIENE NI UNA ENTRADA RECONOCIBLE (CA-09, rama hermana;
  # QA-109). No rotar sigue siendo lo correcto —sin entradas no hay limite seguro donde
  # cortar, y cortar sin limite parte una entrada en dos—, pero callarse repite EXACTAMENTE
  # el error que CA-09 declara inaceptable un parrafo mas arriba: el proyecto declaro una
  # seccion que crece, la seccion crece, y nadie se entera de que no se archiva nada. Es la
  # otra mitad del mismo error de mapeo, y no es hipotetica: el `## Historial de cambios`
  # de los REQ de este repositorio es una TABLA, y CA-07 cuenta las filas como
  # continuaciones, no como entradas.
  #
  # SOLO se avisa POR ENCIMA DEL UMBRAL, porque el paso 2 ya salio antes en caso contrario:
  # por debajo no se toca nada por diseno (CA-06) y avisar seria ruido en cada parada.
  #
  # El texto DISTINGUE los dos casos —"no contiene la seccion" vs "la contiene sin
  # entradas"— porque la accion que pide cada uno es distinta: alli se corrige el nombre
  # en el manifiesto; aqui, o el formato de la seccion, o la expectativa de rotarla.
  if [ "$total" -eq 0 ]; then
    arnes_warn "rotacion: '${f#"$ARNES_PROJ/"}' SI contiene la seccion '$sec' y supera el umbral, pero no tiene ni una ENTRADA reconocible; no se rota nada en ese archivo. Una entrada empieza a columna cero por '- ', '* ', '### ' o 'N. '; las filas de tabla, las lineas indentadas y los parrafos sueltos son continuaciones, no entradas. Revisa el formato de la seccion o la expectativa de rotarla."
    ARNES_ROT_SIN_ENTRADAS=$(( ${ARNES_ROT_SIN_ENTRADAS:-0} + 1 ))
    [ -n "${ARNES_ROT_SIN_ENTRADAS_EJ:-}" ] || ARNES_ROT_SIN_ENTRADAS_EJ="${f##*/}|$sec"
    return 0
  fi
  # Un `conservar` no numerico (manifiesto escrito a mano) hace fallar la comparacion y
  # el artefacto se ignora entero: no se toca nada. Una parada no se bloquea por esto.
  [ "$total" -gt "$conservar" ] 2>/dev/null || return 0

  # 4) Que mitad es "lo viejo" se DECLARA, igual que en el artefacto entero: un historial
  #    suele añadir al final (`nuevo-al-final`), un CHANGELOG pone lo nuevo arriba.
  #    Adivinar mal archiva lo MAS RECIENTE, que es lo que hay que tener a mano.
  local viejo='' nuevo='' i corte="$conservar"
  if [ "$orden" = "nuevo-al-final" ]; then
    for (( i=0; i<total-corte; i++ )); do viejo+="${ent[$i]}"; done
    for (( i=total-corte; i<total; i++ )); do nuevo+="${ent[$i]}"; done
  else
    for (( i=corte; i<total; i++ )); do viejo+="${ent[$i]}"; done
    for (( i=0; i<corte; i++ )); do nuevo+="${ent[$i]}"; done
  fi
  [ -n "$viejo" ] || return 0

  # 5) Destino: `<archivo_dir>/<nombre>`, o `historial/<nombre>` junto al documento. Las
  #    DOS contenciones, como en `estado_derivado.archivo` desde 1.29.1: LEXICA sobre lo
  #    declarado (relativa, sin `..`, sin `~`, sin barra invertida) y FISICA sobre el
  #    directorio ya resuelto (un enlace simbolico puede sacarte del proyecto con una ruta
  #    perfectamente limpia).
  local nombre="${f##*/}" dir_dest destino rel_dest NL=$'\n' CR=$'\r' cab1
  cab1="${cab%%"$NL"*}"; cab1="${cab1%"$CR"}"
  if [ -n "$adir" ]; then
    arnes_ruta_interna "$adir" || return 0
    dir_dest="$ARNES_PROJ/$adir"; rel_dest="$adir/$nombre"
  else
    dir_dest="${f%/*}/historial"; rel_dest="historial/$nombre"
  fi
  mkdir -p "$dir_dest" 2>/dev/null || return 0
  arnes_dir_interno "$dir_dest" || return 0
  destino="$dir_dest/$nombre"

  # 6) TODO O NADA, exactamente como en `arnes_rotar_uno`: el destino se arma en un
  #    temporal, se RELEE para comprobar que el texto llego, y solo entonces se publica y
  #    se recorta el origen. Se prefiere un archivo grande a un archivo perdido.
  #    Los DOS temporales son propios de este proceso y se piden ANTES de publicar nada
  #    (REQ-015 CA-01/CA-07): con nombre fijo, dos paradas simultaneas compartian archivo y
  #    la escritura tardia de una caia sobre lo que la otra ya habia publicado. Y aqui el
  #    origen puede ser `docs/ESTADO.md` o un REQ, asi que lo que se pisaria es el contrato.
  local marca tmp_dest tmp_orig sonda
  marca="<!-- ARNES:ROTADO $(date '+%Y-%m-%d %H:%M') -->"
  if ! arnes_tmp_publicacion "$destino"; then arnes_rot_sin_tmp "$f"; return 0; fi
  tmp_dest="$ARNES_TMP"
  if ! arnes_tmp_publicacion "$f"; then arnes_rot_sin_tmp "$f"; return 0; fi
  tmp_orig="$ARNES_TMP"
  if [ -f "$destino" ]; then
    cat "$destino" > "$tmp_dest" 2>/dev/null || { rm -f "$tmp_dest"; return 0; }
  else
    printf '# %s — historia archivada\n\n> Entradas retiradas de la sección `%s` de `%s` para que no crezca sin tope.\n> Se MOVIERON tal cual: aquí no hay resumen ni reescritura, y el resto del documento no se tocó.\n\n' \
      "${nombre%.md}" "$cab1" "$nombre" > "$tmp_dest" 2>/dev/null || { rm -f "$tmp_dest"; return 0; }
  fi
  printf '%s\n%s\n' "$marca" "$viejo" >> "$tmp_dest" 2>/dev/null || { rm -f "$tmp_dest"; return 0; }
  # La prueba no es que el append no fallara: es que el texto ESTE en el disco. `grep -F`
  # y no `case`, porque una entrada puede llevar corchetes y en `case` son una clase de
  # caracteres. Y a la sonda se le retira el CR final (archivos CRLF: 92 bytes contra 91).
  sonda="${viejo%%"$NL"*}"; sonda="${sonda%"$CR"}"
  grep -qF -- "$sonda" "$tmp_dest" || { rm -f "$tmp_dest"; return 0; }
  mv -f "$tmp_dest" "$destino" || { rm -f "$tmp_dest"; return 0; }

  # 7) Solo ahora se recorta el origen: lo de antes + la cabecera de la seccion + su
  #    preambulo + el puntero (una sola vez) + lo conservado + lo de despues. La cabecera
  #    del documento viaja dentro de `antes` y no se reescribe nunca.
  local puntero="> Entradas anteriores de esta sección en [\`$rel_dest\`]($rel_dest) — el arnés las movió para que este archivo no crezca sin tope; aquí quedan las $conservar más recientes y el resto del documento no se toca."
  case "$pre" in *"$rel_dest"*) ;; *) pre+="$puntero"$'\n\n' ;; esac
  local salida="$antes$cab$pre$nuevo$despues"
  [ "$fin_nl" -eq 1 ] || salida="${salida%$'\n'}"
  printf '%s' "$salida" > "$tmp_orig" && mv -f "$tmp_orig" "$f"
  [ -f "$tmp_orig" ] && rm -f "$tmp_orig" 2>/dev/null   # solo si quedo algo (CA-11)
  return 0
}

arnes_parse_manifest_rotacion() {
  # `artefactos` acepta CADENA u OBJETO, la misma convencion que ya usan las
  # quality_gates. Una cadena hereda los ajustes globales; un objeto declara los
  # suyos. Asi un manifiesto que hoy dice ["CHANGELOG.md"] sigue funcionando igual.
  #
  # Un objeto con `glob` Y `seccion` es una rotacion DE SECCION: rota esa seccion en cada
  # archivo que case el glob, conservando `conservar_entradas` (20 por defecto) y moviendo
  # el resto a `archivo_dir` (por defecto `historial/` junto al documento). Sin las dos
  # claves no hay rotacion de seccion: se cae a la rotacion por `## ` de siempre.
  #
  # Cada fila: tipo \t ruta-o-glob \t orden \t umbral \t conservar \t seccion \t archivo_dir
  #
  # POR QUE por artefacto y no global: medido en un proyecto real, el CHANGELOG crece
  # por arriba y el registro de seguridad por abajo. Un solo `orden` no puede servir a
  # los dos, y equivocarse archiva lo MAS RECIENTE. Con el orden global la funcion era
  # inservible para uno de los dos archivos; el error fue mio y es el mismo de siempre:
  # el orden es una propiedad DEL ARTEFACTO, no del proyecto.
  arnes_jq_file "$ARNES_MANIFEST" -r '
    . as $m
    | ($m.rotacion.umbral_bytes // 262144) as $u
    | ($m.rotacion.conservar_secciones // 12) as $c
    | (if $m.rotacion.orden == "nuevo-al-final" then "nuevo-al-final" else "nuevo-primero" end) as $o
    | [ (if $m.rotacion.activo == true then "true" else "false" end) ]
      + [ ($m.rotacion.artefactos // [])[]
          | if type == "object" then
              (if (.glob // "") != "" and (.seccion // "") != "" then
                 [ "seccion", .glob,
                   (if (.orden // $o) == "nuevo-al-final" then "nuevo-al-final" else "nuevo-primero" end),
                   ((.umbral_bytes // $u) | tostring),
                   ((.conservar_entradas // 20) | tostring),
                   .seccion, (.archivo_dir // "") ]
               else
                 [ "archivo", (.ruta // .archivo // ""),
                   (if (.orden // $o) == "nuevo-al-final" then "nuevo-al-final" else "nuevo-primero" end),
                   ((.umbral_bytes // $u) | tostring),
                   ((.conservar_secciones // $c) | tostring), "", "" ]
               end)
            else [ "archivo", ., $o, ($u | tostring), ($c | tostring), "", "" ]
            end
          | join("	") ]
    | join("
")' 2>/dev/null || return 1   # manifiesto ilegible: no se rota nada, y el aviso lo da el bloque derivado (SEC-011)
  local primera=1 l
  ARNES_ROT_LISTA=''
  while IFS= read -r l; do
    if [ "$primera" = 1 ]; then ARNES_ROT_ACTIVO="$l"; primera=0; continue; fi
    ARNES_ROT_LISTA+="$l"$'
'
  done <<< "$ARNES_JQ"
  return 0
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  arnes_preludio || exit 0
  arnes_rotar_artefactos || true
  exit 0
fi
