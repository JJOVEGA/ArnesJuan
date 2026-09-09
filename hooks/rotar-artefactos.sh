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
#   LO QUE ESTA LINEA DECIA HASTA 1.34.0 ERA FALSO, y lo dijo una medicion: "si dos paradas
#   rotan el mismo artefacto, una de las dos no encontrara nada que mover, y eso es
#   conforme". Las dos SI encuentran que mover --leen el mismo documento antes de que
#   ninguna publique-- y la segunda publicaba encima de la primera. Ese era el agujero de
#   SEC-067: no una escritura desgarrada (que es la que cierra el temporal propio del
#   proceso, arriba), sino una ACTUALIZACION PERDIDA, completa y valida, sobre una lectura
#   ya caducada. Se cierra en el paso 6b de `arnes_rotar_seccion` con un testigo de
#   vigencia; no se promete serializacion, se promete que nadie publica sobre una lectura
#   que ya no describe el disco.
# - NUNCA BLOQUEA la parada, como el resto de hooks Stop. Y el control de vigencia tampoco
#   espera a nadie: comprueba y cede (CA-18 (v)(b)); no hay cerrojos.
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
  #
  # Y SE LEE CON `arnes_lee_archivo`, NO CON `read -d ''` A PELO (SEC-002/R-001, QA-026-01).
  # `read -d ''` se detiene en el PRIMER NUL y devuelve 0: la variable queda TRUNCADA y el
  # llamador cree tener el documento entero. Aqui eso no es leer mal, es ESCRIBIR mal --el
  # paso final publica lo leido encima del original--, asi que un solo byte NUL borraba todo
  # lo que viniera detras. Si la lectura no es fiable, NO SE ROTA y se avisa.
  if ! arnes_lee_archivo "$f"; then arnes_rot_no_medible "$f"; return 0; fi
  texto="$ARNES_TEXTO"
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

# Los dos avisos de "no se rota", cada uno en UN solo sitio. `arnes_rot_ambigua` se emite
# desde DOS puntos --antes de trocear y durante el troceado-- porque la estructura se puede
# desmentir en los dos; el texto vive aqui una vez, porque dos transcripciones de la misma
# regla se desfasan (la leccion del descuento de comillas de `guard-git`).
arnes_rot_no_medible() {   # <archivo de origen>
  arnes_warn "rotacion: '${1#"$ARNES_PROJ/"}' NO SE PUEDE LEER ENTERO --un byte NUL lo trunca, o no hay permiso de lectura--; no se rota nada y el archivo no se toca. Rotar con una lectura truncada publicaria ESA MITAD encima del documento y borraria todo lo que viniera detras (SEC-002/R-001). Salida: quita el byte NUL del archivo, o arregla los permisos."
  # CA-08 (v): las CUATRO ramas de "no se rota" dejan constancia por un canal que sobrevive a
  # la sesion, y esta no delega su visibilidad en otra puerta. Que un NUL haga denegar a
  # `guard-completado` es cierto y NO basta: esa denegacion depende de que alguien edite ese
  # REQ y de donde caiga el NUL, mientras que el silencio de la rotacion no depende de nada.
  # Un canal condicionado a un segundo suceso no es un canal.
  ARNES_ROT_NO_MEDIBLE=$(( ${ARNES_ROT_NO_MEDIBLE:-0} + 1 ))
  [ -n "${ARNES_ROT_NO_MEDIBLE_EJ:-}" ] || ARNES_ROT_NO_MEDIBLE_EJ="${1##*/}"
}
arnes_rot_ambigua() {      # <archivo de origen> <seccion> <motivo>
  arnes_warn "rotacion: '${1#"$ARNES_PROJ/"}' SI contiene la seccion '$2' y supera el umbral, pero su ESTRUCTURA DE TABLA es AMBIGUA ($3); no se archiva nada y el archivo queda igual. Para que las filas de una tabla cuenten como entradas, la seccion tiene que ser UNA tabla: su fila de cabecera y su fila separadora ('|---|---|') seguidas y en el preambulo, antes de cualquier otra entrada, y ninguna otra separadora despues. Revisa el formato de la seccion."
  ARNES_ROT_AMBIGUA=$(( ${ARNES_ROT_AMBIGUA:-0} + 1 ))
  [ -n "${ARNES_ROT_AMBIGUA_EJ:-}" ] || ARNES_ROT_AMBIGUA_EJ="${1##*/}|$2"
}
# LECTURA CADUCADA (CA-18). No es un error del documento ni del manifiesto: es una carrera, y
# lo que hay que saber es que la escritura ajena GANO --se conserva-- y que por eso esta
# rotacion no se hizo. Sin este aviso, "no rote" y "rote y me comi tu cambio" se ven igual
# desde fuera: rc 0 y silencio, que es exactamente como se midio SEC-067.
arnes_rot_caducada() {     # <archivo de origen> <seccion> <que cambio>
  arnes_warn "rotacion: '${1#"$ARNES_PROJ/"}' cambio en el disco MIENTRAS se calculaba su rotacion ($3 ya no es el que se leyo); NO se ha publicado nada y se conserva la escritura ajena byte a byte, sin rotar. No es un error: es una carrera, y la rotacion cede siempre. Publicar habria pisado un cambio posterior a la lectura --una actualizacion perdida, y en un REQ eso puede devolver un veredicto a 'pendiente' (SEC-067)--. La seccion '$2' se archivara en una parada posterior."
  ARNES_ROT_CADUCADA=$(( ${ARNES_ROT_CADUCADA:-0} + 1 ))
  [ -n "${ARNES_ROT_CADUCADA_EJ:-}" ] || ARNES_ROT_CADUCADA_EJ="${1##*/}|$2"
}
# SIN CANAL DE CONSTANCIA DURADERA (CA-18 (vii), SEC-069). Aqui NO se cuenta para el bloque
# derivado a proposito: el bloque derivado esta apagado, que es justo el motivo de no rotar.
# Este aviso vive y muere con la sesion, y es lo unico que hay -- por eso dice como recuperar
# el canal en la misma frase.
arnes_rot_sin_constancia() {   # <archivo de origen> <seccion>
  arnes_warn "rotacion: '${1#"$ARNES_PROJ/"}' tiene la seccion '$2' por encima del umbral y habria que archivarla, pero 'estado_derivado.activo' es false: con el bloque derivado apagado, NINGUNA de las ramas de 'no se rota' puede dejar constancia que sobreviva a la sesion, y un fail-closed invisible es indistinguible de una seccion que lleva meses sin archivarse (SEC-069). NO se rota nada. Salida: pon 'estado_derivado.activo: true' en .arnes/config.json, o quita este artefacto de 'rotacion.artefactos'."
}

# arnes_rot_es_separadora <linea ya recortada> — ¿es la FILA SEPARADORA de una tabla?
#
# Que es una fila separadora NO lo define el arnes: es la de la tabla de Markdown (GFM), y
# ahi vive su definicion. Aqui solo se usa: celdas hechas de guiones con dos puntos
# opcionales a un lado, al otro o a los dos (`|---|`, `| :--- |`, `|:-:|`).
#
# Se comprueba por SUSTRACCION --se retiran los caracteres legales y tiene que no quedar
# nada-- en vez de por una expresion regular celda a celda: sin forks, sin `grep`, y una
# forma que no enumera. El guion es obligatorio: una fila de solo espacios y dos puntos no
# es separadora. Y `— ` (raya, multibyte) NO es `-`, asi que una fila de datos con rayas
# --como el `| — |` de la columna ADR de los REQ de este repositorio-- no se confunde con
# una separadora. Nada de esto depende del locale: se compara texto, no clases de idioma.
arnes_rot_es_separadora() {
  local s="$1"
  case "$s" in '|'*) ;; *) return 1 ;; esac
  case "$s" in *-*) ;; *) return 1 ;; esac
  [ -z "${s//[-|:[:space:]]/}" ] || return 1
  return 0
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
# QUE ES UNA ENTRADA. Dos formas, y la segunda existe porque la primera se pudrio contra
# su propio corpus (REQ-026):
#   (a) LISTA: lo que empieza a columna cero por `- `, `* `, `### ` o `N. `.
#   (b) TABLA: las FILAS DE DATOS de la tabla, cuando esa tabla es LA ESTRUCTURA DE LA
#       SECCION -- es decir, cuando su fila de cabecera y su fila separadora aparecen en el
#       PREAMBULO, seguidas y antes de cualquier otra entrada. La cabecera y la separadora
#       NUNCA son entradas: son preambulo, y el preambulo se queda en el documento.
# Cualquier otra linea pertenece a la entrada anterior (continuacion: una linea indentada,
# un parrafo suelto y, en una seccion de LISTA, tambien una fila de tabla) o, antes de la
# primera, al preambulo.
#
# POR QUE POR PROPIEDAD Y NO CON UN PREFIJO MAS. Hasta 1.33.0 esto era una enumeracion de
# prefijos, y el corpus contra el que corre son TABLAS: medido en tres REQ de este
# repositorio, 30, 24 y 44 filas de tabla y CERO entradas reconocibles. El 23 % de
# `requirements/` (409.699 B medidos) era historia que el rotador no sabia mover, y
# encenderlo no habria hecho nada. Anadir `|` a la lista repetiria el error: lo que decide
# no es con que caracter empieza una linea, es si la tabla ES la seccion o vive DENTRO de
# una entrada (REQ-026 CA-07). De ahi que la regla se enuncie por propiedad.
#
# Y CUANDO LA PROPIEDAD NO SE PUEDE RESPONDER, NO SE ADIVINA (REQ-026 CA-08). Una seccion
# sin entradas reconocibles no se toca --no hay limite seguro donde cortar, y cortar sin
# limite parte una entrada en dos--, y una cuya estructura de tabla es AMBIGUA tampoco:
# aqui adivinar mal no deja un archivo feo, mueve el contrato de un REQ. En los dos casos
# se avisa, con textos distintos, porque piden acciones distintas.
arnes_rotar_seccion() {
  local f="$1" sec="$2" orden="$3" umbral="$4" conservar="$5" adir="$6"
  local texto linea antes='' cab='' cuerpo='' despues='' fase=0 rec fin_nl=0
  [ -f "$f" ] || return 0
  arnes_dir_interno "${f%/*}" || return 0
  # LA LECTURA TIENE QUE DECIR SI NO PUDO LEER (SEC-002/R-001, QA-026-01). Con
  # `read -d ''` a pelo, un byte NUL detiene la lectura, devuelve 0, y el paso 7 publica
  # ESA MITAD encima del REQ: medido sobre una copia de `REQ-007`, -17.697 B y cinco filas
  # de historia que desaparecen del documento Y del archivo, con rc 0 y sin un aviso. La via
  # existia desde antes, pero una seccion en forma de tabla no daba entradas y la funcion
  # salia antes de llegar aqui; reconocer tablas la hizo alcanzable en cada rotacion.
  # Fail-closed, la misma direccion que CA-08: si no se puede leer, no se rota y se avisa.
  if ! arnes_lee_archivo "$f"; then arnes_rot_no_medible "$f"; return 0; fi
  texto="$ARNES_TEXTO"
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
  #
  # EL SALTO FINAL DE `cuerpo` SE APARTA ANTES DE TROCEAR, y desde REQ-026 eso no es
  # cosmetica: `<<<` anade su propio salto al texto, asi que un `cuerpo` que ya termina en
  # salto entrega UNA LINEA VACIA DE MAS a los dos bucles. Con el reconocedor de tablas esa
  # linea fantasma decide: una seccion de cabecera + separadora y CERO filas (CA-09) parecia
  # llevar una linea entre la separadora y los datos, y se habria denegado como ambigua en vez
  # de avisar de que no tiene entradas. Antes solo colaba un salto de mas al final de la
  # seccion en cada rotacion.
  local -a ent=()
  local pre='' cur='' hay=0 hueco2=0 cuerpo1="${cuerpo%$'\n'}"
  # 3a) PRIMERO se decide QUE ESTRUCTURA tiene la seccion, mirando SOLO su preambulo: o es
  #     una tabla (cabecera + separadora seguidas, antes de cualquier otra entrada) o es una
  #     lista. Se decide aparte del troceado a proposito: la pregunta "¿de que esta hecha
  #     esta seccion?" se responde una vez y con el preambulo entero delante; mezclarla con
  #     el troceado es lo que convierte una regla en una lista de prefijos.
  #
  #     El preambulo llega hasta la PRIMERA ENTRADA, y por eso el estado 2 sigue leyendo
  #     despues de encontrar la pareja: en `cabecera / separadora / separadora / filas` la
  #     segunda separadora esta todavia en el preambulo, y esa es una de las dos formas
  #     ambiguas que CA-08 nombra. Cortar en la pareja la habria tomado por fila de datos.
  local modo=lista tab_cab='' tab_sep='' amb='' nlin=0 nsep=0 est=0 hueco=0
  while IFS= read -r linea || [ -n "$linea" ]; do
    nlin=$((nlin+1))
    rec="${linea%"${linea##*[![:space:]]}"}"
    case "$est" in
      0) # Buscando la fila de cabecera. Prosa y lineas vacias son preambulo y no deciden.
        case "$rec" in
          '|'*)
            if arnes_rot_es_separadora "$rec"; then
              amb="hay una fila separadora que no va detras de una fila de cabecera"; break
            fi
            tab_cab="$linea"; est=1 ;;
          '- '*|'* '*|'### '*|[0-9]'. '*|[0-9][0-9]'. '*|[0-9][0-9][0-9]'. '*)
            # Empieza una entrada de LISTA: el preambulo termina aqui, asi que la tabla que
            # venga despues vive DENTRO de una entrada y no es la estructura de la seccion
            # (CA-07). Estructura de lista, y no hay nada ambiguo.
            break ;;
        esac ;;
      1) # La cabecera solo cuenta si la separadora es la linea SIGUIENTE (asi lo define
         # GFM). Cualquier otra cosa --incluida una linea vacia-- deja una tabla a medias.
        if arnes_rot_es_separadora "$rec"; then tab_sep="$linea"; nsep="$nlin"; est=2
        elif [ "${rec:0:1}" = '|' ]; then
          amb="hay filas a columna cero que empiezan por '|' sin una fila separadora que las preceda"; break
        else
          amb="hay una fila de cabecera de tabla sin su separadora detras"; break
        fi ;;
      *) # Pareja completa. La primera fila de datos confirma la estructura; una segunda
         # separadora la vuelve ambigua; y entre la separadora y la primera fila NO cabe
         # nada, porque el puntero y las filas conservadas tienen que quedar pegados a la
         # separadora (CA-04) y aqui solo se reproduce lo que el documento ya trae.
         #
         # Un hueco NO decide por si mismo: `cabecera / separadora / vacia` y nada mas es
         # una tabla SIN FILAS --de eso avisa CA-09-- mientras que `cabecera / separadora /
         # vacia / filas` es ambiguo, porque en GFM esa linea vacia ya cerro la tabla y
         # reproducirla dejaria las filas conservadas separadas de su separadora.
        if arnes_rot_es_separadora "$rec"; then
          amb="hay mas de una fila separadora en el preambulo"; break
        fi
        case "$rec" in
          '|'*)
            if [ "$hueco" -eq 1 ]; then amb="hay lineas entre la fila separadora y la primera fila de datos"
            else modo=tabla; fi
            break ;;
          *) hueco=1 ;;
        esac ;;
    esac
  done <<< "$cuerpo1"
  # La seccion se acabo antes de resolver: una cabecera colgando sin separadora es ambigua;
  # una pareja completa sin filas es una tabla vacia, y de eso avisa CA-09 mas abajo.
  if [ -z "$amb" ] && [ "$modo" != tabla ]; then
    case "$est" in
      1) amb="hay una fila de cabecera de tabla sin su separadora detras" ;;
      2) modo=tabla ;;
    esac
  fi

  # ESTRUCTURA AMBIGUA: FAIL-CLOSED, Y NO EN SILENCIO (CA-08). Si no se puede decir cual es
  # la cabecera, cual la separadora y cuales las filas de datos, no se archiva nada. Una
  # comprobacion que no puede responder no dice "no se", dice "si" -- y aqui eso significa
  # partir una tabla o mover el contrato de un REQ desde una parada, fuera de la via que
  # vigila `guard-completado`. Se avisa con un texto DISTINTO del de "sin entradas
  # reconocibles" porque la accion que pide es otra: alli falta formato o sobra expectativa;
  # aqui hay una tabla a medio hacer que hay que arreglar antes de que se pueda rotar.
  if [ -n "$amb" ]; then arnes_rot_ambigua "$f" "$sec" "$amb"; return 0; fi

  # 3b) Ahora si, el troceado. En modo TABLA el preambulo llega hasta la separadora
  #     (incluida) y cada fila de datos posterior abre una entrada; en modo LISTA manda el
  #     prefijo de siempre. Las continuaciones viajan con su entrada en los dos modos.
  #
  #     Y AQUI SE VALIDA EL RESTO DE LA SECCION, NO SOLO SU PREAMBULO (QA-026-02). El paso
  #     3a decide la estructura y para en la primera fila de datos, asi que por si solo NO
  #     mira nada de lo que venga despues: con DOS tablas en la seccion, la cabecera y la
  #     separadora de la segunda se contaban como filas de datos de la primera y sus filas
  #     acababan bajo las columnas de otra tabla --dato REETIQUETADO en silencio, y sin
  #     perder ni duplicar ninguna fila, asi que ninguna comprobacion de perdida lo veia--.
  #     La propiedad que se contrata no es la enumeracion de CA-08 (que se declara "no
  #     exhaustiva"), es esta: si no se reconoce la estructura de TODA la seccion, no se rota
  #     y se avisa. La comprobacion vive DENTRO de este bucle --que ya recorre la seccion
  #     entera-- y no en una tercera pasada, porque el coste de una pasada mas se paga en
  #     CADA parada y esta pregunta se responde con lo que ya se esta leyendo.
  nlin=0
  while IFS= read -r linea || [ -n "$linea" ]; do
    nlin=$((nlin+1))
    if [ "$modo" = tabla ] && [ "$nlin" -le "$nsep" ]; then pre+="$linea"$'\n'; continue; fi
    rec="${linea%"${linea##*[![:space:]]}"}"
    case "$modo" in
      tabla) case "$rec" in
               '|'*)
                 if arnes_rot_es_separadora "$rec"; then
                   amb="hay otra fila separadora entre las filas de datos: la seccion tiene mas de una tabla, y la cabecera de la segunda no es una fila de datos de la primera"
                   break
                 fi
                 # Y EL ESPEJO DEL `hueco` DEL PREAMBULO, que es la MISMA propiedad aplicada
                 # al resto: una linea que no es fila de datos ENTRE dos filas corta la tabla
                 # ahi --en GFM una linea vacia o un parrafo la cierran-- asi que lo de
                 # despues ya no es la misma tabla. Medido: con un estorbo pegado a una fila
                 # que se archiva, el bloque del destino quedaba con esa linea ENTRE dos
                 # filas de datos, o sea dejaba de leerse como tabla (CA-03), y en silencio.
                 # Las tres formas que lo producen --una segunda tabla INDENTADA (GFM admite
                 # hasta tres espacios, asi que no llega a este `case`), un parrafo suelto y
                 # una linea vacia-- son la misma cosa vista tres veces: por eso la
                 # comprobacion no las enumera, mira la propiedad.
                 if [ "$hueco2" -eq 1 ]; then
                   amb="hay lineas que no son filas de datos entre dos filas de datos: la tabla se corta ahi y lo que viene despues ya no es la misma tabla"
                   break
                 fi
                 [ "$hay" -eq 1 ] && ent+=("$cur"); cur="$linea"$'\n'; hay=1 ;;
               *)    if [ "$hay" -eq 1 ]; then hueco2=1; cur+="$linea"$'\n'; else pre+="$linea"$'\n'; fi ;;
             esac ;;
      *)     case "$linea" in
               '- '*|'* '*|'### '*|[0-9]'. '*|[0-9][0-9]'. '*|[0-9][0-9][0-9]'. '*)
                 [ "$hay" -eq 1 ] && ent+=("$cur")
                 cur="$linea"$'\n'; hay=1 ;;
               *)
                 if [ "$hay" -eq 1 ]; then cur+="$linea"$'\n'; else pre+="$linea"$'\n'; fi ;;
             esac ;;
    esac
  done <<< "$cuerpo1"
  # La ambiguedad vista durante el troceado decide igual que la del preambulo: no se ha
  # escrito nada todavia --el destino no se toca hasta el paso 6-- asi que salir aqui deja
  # el archivo byte a byte igual, que es justo lo que promete el fail-closed.
  if [ -n "$amb" ]; then arnes_rot_ambigua "$f" "$sec" "$amb"; return 0; fi
  [ "$hay" -eq 1 ] && ent+=("$cur")
  local total="${#ent[@]}"
  # LA SECCION EXISTE PERO NO TIENE NI UNA ENTRADA RECONOCIBLE (CA-09, rama hermana;
  # QA-109). No rotar sigue siendo lo correcto —sin entradas no hay limite seguro donde
  # cortar, y cortar sin limite parte una entrada en dos—, pero callarse repite EXACTAMENTE
  # el error que CA-09 declara inaceptable un parrafo mas arriba: el proyecto declaro una
  # seccion que crece, la seccion crece, y nadie se entera de que no se archiva nada. Es la
  # otra mitad del mismo error de mapeo. Desde REQ-026 esta rama YA NO es la del corpus de
  # este repositorio --el `## Historial de cambios` de los REQ es una tabla y ahora sus
  # filas SI son entradas--; queda para lo que de verdad no tiene ni una: una tabla con
  # cabecera y separadora y NINGUNA fila de datos (CA-09), o una seccion de prosa suelta.
  #
  # SOLO se avisa POR ENCIMA DEL UMBRAL, porque el paso 2 ya salio antes en caso contrario:
  # por debajo no se toca nada por diseno (CA-06) y avisar seria ruido en cada parada.
  #
  # El texto DISTINGUE los dos casos —"no contiene la seccion" vs "la contiene sin
  # entradas"— porque la accion que pide cada uno es distinta: alli se corrige el nombre
  # en el manifiesto; aqui, o el formato de la seccion, o la expectativa de rotarla.
  if [ "$total" -eq 0 ]; then
    arnes_warn "rotacion: '${f#"$ARNES_PROJ/"}' SI contiene la seccion '$sec' y supera el umbral, pero no tiene ni una ENTRADA reconocible; no se rota nada en ese archivo. Una entrada es una linea de lista a columna cero ('- ', '* ', '### ', 'N. ') o una FILA DE DATOS de la tabla que ES la seccion (cabecera y separadora seguidas en el preambulo); las lineas indentadas y los parrafos sueltos son continuaciones, y la cabecera y la separadora son preambulo. Revisa el formato de la seccion o la expectativa de rotarla."
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

  # 4b) SIN CANAL DE CONSTANCIA DURADERA, NO SE ROTA (CA-18 (vii), SEC-069). Las cuatro ramas
  #     de "no se rota" publican su linea en el bloque derivado, y con
  #     `estado_derivado.activo: false` NINGUNA se escribe: la constancia que sobrevive a la
  #     sesion desaparece por una opcion ajena a este fail-closed, y entonces un fail-closed
  #     invisible es indistinguible de una seccion que lleva meses sin archivarse. Se decide
  #     AQUI, y no al entrar en la funcion, por CA-10: si no habia nada que mover no hay nada
  #     que decir, y avisar en cada parada seria ruido. Va tambien ANTES del `mkdir -p` del
  #     destino: no se crea `historial/` para luego no rotar.
  #     Solo afecta a la rotacion DE SECCION, que es la que reescribe contratos; el artefacto
  #     entero (`arnes_rotar_uno`) no se toca.
  if [ "${ARNES_ROT_CONSTANCIA:-true}" = "false" ]; then
    arnes_rot_sin_constancia "$f" "$sec"
    return 0
  fi

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
  local marca tmp_dest tmp_orig sonda dest_ini='' dest_habia=0
  marca="<!-- ARNES:ROTADO $(date '+%Y-%m-%d %H:%M') -->"
  if ! arnes_tmp_publicacion "$destino"; then arnes_rot_sin_tmp "$f"; return 0; fi
  tmp_dest="$ARNES_TMP"
  if ! arnes_tmp_publicacion "$f"; then arnes_rot_sin_tmp "$f"; return 0; fi
  tmp_orig="$ARNES_TMP"
  # El destino se lee A UNA VARIABLE, no con `cat` al temporal, por tres razones y ninguna
  # es de estilo: (1) hace falta GUARDAR lo que el destino decia al leerlo, para poder
  # comprobar su vigencia antes de publicar (CA-18: el destino tambien puede cambiar debajo,
  # y publicar sobre una lectura caducada de EL pierde un bloque archivado); (2) el lector
  # fiable dice si no pudo leer entero, y `cat` copiaria feliz media lectura; (3) se ahorra
  # un fork en un camino que ya paga varios.
  if [ -f "$destino" ]; then
    dest_habia=1
    if ! arnes_lee_archivo "$destino"; then
      rm -f "$tmp_dest" "$tmp_orig"; arnes_rot_no_medible "$destino"; return 0
    fi
    dest_ini="$ARNES_TEXTO"
    printf '%s' "$dest_ini" > "$tmp_dest" 2>/dev/null || { rm -f "$tmp_dest" "$tmp_orig"; return 0; }
  else
    printf '# %s — historia archivada\n\n> Entradas retiradas de la sección `%s` de `%s` para que no crezca sin tope.\n> Se MOVIERON tal cual: aquí no hay resumen ni reescritura, y el resto del documento no se tocó.\n\n' \
      "${nombre%.md}" "$cab1" "$nombre" > "$tmp_dest" 2>/dev/null || { rm -f "$tmp_dest" "$tmp_orig"; return 0; }
  fi
  # EN MODO TABLA, CADA BLOQUE ARCHIVADO LLEVA SU PROPIA CABECERA Y SU SEPARADORA, y van
  # PEGADAS a sus filas (REQ-026 CA-03). Un monton de filas sueltas debajo de una marca HTML
  # no se lee como tabla en ningun visor: el destino existe para poder consultar la historia,
  # y una historia ilegible es exactamente lo que este hook promete no hacer. Se copian las
  # del ORIGEN tal cual --byte a byte, CR incluido si el archivo es CRLF-- en vez de
  # fabricarlas, porque el numero y el nombre de las columnas son del documento, no del
  # arnes. Y por bloque, no una vez por archivo: dos rotaciones pueden traer tablas con
  # columnas distintas, y la marca de la segunda no puede quedar entre dos filas de la
  # primera. La marca va ANTES de la cabecera: asi ninguna linea de texto se cuela dentro
  # del bloque.
  if [ "$modo" = tabla ]; then
    printf '%s\n%s\n%s\n%s\n' "$marca" "$tab_cab" "$tab_sep" "$viejo" >> "$tmp_dest" 2>/dev/null || { rm -f "$tmp_dest"; return 0; }
  else
    printf '%s\n%s\n' "$marca" "$viejo" >> "$tmp_dest" 2>/dev/null || { rm -f "$tmp_dest"; return 0; }
  fi
  # La prueba no es que el append no fallara: es que el texto ESTE en el disco. `grep -F`
  # y no `case`, porque una entrada puede llevar corchetes y en `case` son una clase de
  # caracteres. Y a la sonda se le retira el CR final (archivos CRLF: 92 bytes contra 91).
  sonda="${viejo%%"$NL"*}"; sonda="${sonda%"$CR"}"
  grep -qF -- "$sonda" "$tmp_dest" || { rm -f "$tmp_dest" "$tmp_orig"; return 0; }

  # 6b) TESTIGO DE VIGENCIA: NO SE PUBLICA SOBRE UNA LECTURA CADUCADA (CA-18, SEC-067).
  #
  # QUE FALLO CIERRA. La ACTUALIZACION PERDIDA: esta funcion lee el documento entero,
  # calcula, y reescribe el documento entero DESDE ESA LECTURA. Si alguien --otra parada, una
  # persona, otra herramienta-- escribe en el medio, la publicacion lo pisa con contenido
  # completo y valido. Medido 3/3 en carrera real: un `Seguridad: aprobado` escrito durante
  # la rotacion volvio a `pendiente`, con rc 0 y sin un aviso. NO es la escritura DESGARRADA
  # que cierra REQ-015 con el temporal propio del proceso --dos escrituras entrelazadas a
  # mitad de archivo--, y una no implica la otra: el arnes solo tenia defensa para la segunda.
  #
  # POR QUE RELEER Y COMPARAR, Y NO UN CERROJO. Un cerrojo solo obliga a quien lo respeta, y
  # la escritura ajena que hay que sobrevivir incluye A UNA PERSONA con su editor: un cerrojo
  # no puede dar esta propiedad. Ademas anade un modo de fallo peor que el que arregla --un
  # cerrojo huerfano deja un documento que no vuelve a rotar nunca-- y obligaria a decidir
  # cuando esta rancio, que es adivinar. La relectura no obliga a nadie a nada, no espera a
  # nadie (CA-18 (v)(b)) y cuesta una lectura de un archivo que estamos a punto de reescribir.
  #
  # POR QUE AQUI Y NO ANTES. Este es el ultimo instante antes de la primera publicacion. La
  # ventana que queda es la de publicar (dos `mv` y un `printf`), no la del calculo: la
  # medida era de 355-361 ms y lo que queda es de microsegundos. NO se cierra del todo, y no
  # se puede en shell: no existe un "renombra-si-no-ha-cambiado" atomico. Lo que se contrata
  # es que ninguna publicacion se derive de una lectura ya caducada, y eso es lo que se
  # comprueba; el residuo queda declarado en el REQ, no escondido aqui.
  #
  # SE COMPRUEBAN LOS DOS ARCHIVOS. El origen, porque es el contrato. Y el destino, porque
  # `tmp_dest` se armo sobre lo que el destino decia al leerlo: si otro lo cambio en medio,
  # publicar encima BORRA su bloque --perdida de historia, y CA-05 roto sobre la union--.
  # Y en los dos, la duda decide igual que en CA-08: si no se puede leer para comprobar, no
  # se rota (CA-18 (ii)); no hay ninguna condicion bajo la que la duda autorice publicar.
  # EL TESTIGO SE RECONSTRUYE AQUI, NO SE GUARDA AL LEER, y no es un detalle de estilo:
  # guardar una copia del documento entero justo despues de leerlo costaba una copia POR
  # ARCHIVO Y POR PARADA, tambien en los que no se iban a rotar. Medido pareado sobre la
  # misma maquina y en el mismo instante, con el montaje de CA-15: 140.583 us contra 128.742
  # del codigo anterior, +11.841 us (+9,2 %) en REGIMEN ESTACIONARIO, donde este control no
  # tiene nada que hacer -- y por encima del techo de 140.000 us de CA-15. Reconstruirlo aqui
  # lo deja en CERO fuera del camino de rotacion.
  # La reconstruccion es exacta: la normalizacion de arriba quita UN salto final y solo uno,
  # y `fin_nl` recuerda si lo habia. No se compara "normalizado contra normalizado" a
  # proposito: dos documentos que solo difieren en el salto final compararian IGUAL, y
  # publicar encima devolveria ese byte al estado viejo -- una actualizacion perdida de un
  # byte sigue siendo una actualizacion perdida, y CA-18 (i) dice BYTE A BYTE.
  local texto_ini="$texto"
  [ "$fin_nl" -eq 1 ] && texto_ini+=$'\n'
  if ! arnes_lee_archivo "$f"; then
    rm -f "$tmp_dest" "$tmp_orig"; arnes_rot_no_medible "$f"; return 0
  fi
  if [ "$ARNES_TEXTO" != "$texto_ini" ]; then
    rm -f "$tmp_dest" "$tmp_orig"; arnes_rot_caducada "$f" "$sec" "el documento"; return 0
  fi
  if [ "$dest_habia" -eq 1 ]; then
    if ! arnes_lee_archivo "$destino"; then
      rm -f "$tmp_dest" "$tmp_orig"; arnes_rot_no_medible "$destino"; return 0
    fi
    if [ "$ARNES_TEXTO" != "$dest_ini" ]; then
      rm -f "$tmp_dest" "$tmp_orig"; arnes_rot_caducada "$f" "$sec" "el archivo de historia"; return 0
    fi
  elif [ -e "$destino" ]; then
    # No existia cuando se leyo y ahora si: otra rotacion lo publico en el medio. Publicar
    # encima se llevaria su bloque por delante.
    rm -f "$tmp_dest" "$tmp_orig"; arnes_rot_caducada "$f" "$sec" "el archivo de historia"; return 0
  fi
  mv -f "$tmp_dest" "$destino" || { rm -f "$tmp_dest" "$tmp_orig"; return 0; }

  # 7) Solo ahora se recorta el origen: lo de antes + la cabecera de la seccion + su
  #    preambulo + el puntero (una sola vez) + lo conservado + lo de despues. La cabecera
  #    del documento viaja dentro de `antes` y no se reescribe nunca.
  #    Y EL PUNTERO VA FUERA DE LA TABLA (REQ-026 CA-04). En modo tabla el preambulo TERMINA
  #    en la fila separadora, asi que anadirle el puntero al final lo mete entre la separadora
  #    y las filas conservadas: eso rompe la tabla EN EL ORIGEN --en un REQ, no en un archivo
  #    de bitacora-- y deja la historia conservada sin cabecera. Va DELANTE de la cabecera,
  #    pegado al encabezado de la seccion; en modo lista sigue donde estaba (al final del
  #    preambulo), que ahi no hay tabla que partir. La segunda pasada lo reconoce como prosa
  #    del preambulo y el `case` evita duplicarlo, igual que antes.
  local puntero="> Entradas anteriores de esta sección en [\`$rel_dest\`]($rel_dest) — el arnés las movió para que este archivo no crezca sin tope; aquí quedan las $conservar más recientes y el resto del documento no se toca."
  case "$pre" in
    *"$rel_dest"*) ;;
    *) if [ "$modo" = tabla ]; then pre="$puntero"$'\n\n'"$pre"; else pre+="$puntero"$'\n\n'; fi ;;
  esac
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
    | [ ((if $m.rotacion.activo == true then "true" else "false" end)
         # SEGUNDO CAMPO DE LA PRIMERA FILA: si el canal de constancia duradera esta
         # encendido (CA-18 (vii)). La rotacion corre ANTES del bloque derivado --tiene que,
         # para que el bloque pueda contar lo que la rotacion vio-- asi que este ajuste se
         # lee AQUI y no se hereda de alli. Y con el mismo cuidado con `//` que
         # `estado-derivado.sh`: `false` se trata igual que ausente, asi que se compara
         # contra `false` EXPLICITO. Ausente o null = encendido, que es como se comporta el
         # bloque derivado, y con el encendido la rotacion no se estorba.
         + "\t" + (if $m.estado_derivado.activo == false then "false" else "true" end)) ]
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
  ARNES_ROT_CONSTANCIA='true'
  while IFS= read -r l; do
    if [ "$primera" = 1 ]; then
      ARNES_ROT_ACTIVO="${l%%$'\t'*}"
      # Si por lo que sea no viniera el segundo campo, se queda en `true`: el lado que NO
      # cambia la conducta de un proyecto que no declara nada.
      case "$l" in *$'\t'*) ARNES_ROT_CONSTANCIA="${l#*$'\t'}" ;; esac
      primera=0; continue
    fi
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
