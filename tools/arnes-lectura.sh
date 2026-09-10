#!/usr/bin/env bash
# arnes-lectura.sh — qué LEE la máquina en los REQ de este proyecto.
#
# POR QUÉ EXISTE
# Un banco de pruebas sólo caza lo que falla. Los peores defectos que ha tenido este
# arnés no fallaban: la puerta que debía existir simplemente no existía, y todo se
# veía verde. Medido en un proyecto real: siete REQ declaraban
# `Sensible a seguridad: **sí**`, la negrita impedía que casara con `si`, y esos siete
# se saltaban la revisión de seguridad en silencio. Uno gobernaba datos personales y
# estaba a un campo de cerrarse sin auditoría.
#
# Esto no es una prueba: es un INFORME. No pregunta «¿falla algo?» sino «¿qué lee la
# máquina en tus datos?». Pasa cada campo por EL MISMO normalizador que usan los
# hooks —no una copia, que se desfasaría— y enseña todo valor que no reconozca.
#
# Habría cazado los siete el primer día, sin que nada fallara.
#
# LO QUE NO HACE, dicho por delante: detecta valores que la máquina lee distinto de
# como se escribieron. NO detecta una puerta que falta en la lógica. Para eso sigue
# haciendo falta que alguien la busque.
#
# Uso:  tools/arnes-lectura.sh [ruta-del-proyecto]      (por defecto, el directorio actual)
# Sale 0 si no hay anomalías, 1 si las hay, 2 si no puede leer el proyecto.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/../hooks/lib.sh"

PROY="${1:-$PWD}"
MAN="$PROY/.arnes/config.json"
if [ ! -f "$MAN" ]; then
  printf 'No hay .arnes/config.json en %s — esto no es un proyecto del arnés.\n' "$PROY" >&2
  exit 2
fi
command -v jq >/dev/null 2>&1 || { printf 'Hace falta jq.\n' >&2; exit 2; }

ARNES_MANIFEST="$MAN"
# `campos.ausencia_exige` viaja en la MISMA llamada a jq que las otras tres claves: sin ella
# este informe resolveria la ausencia de un campo del lado HEREDADO mientras la puerta la
# resuelve del lado que cierra, y diria `estandar` donde la puerta dice `critico` — que es
# exactamente el desfase entre lectores que este informe existe para detectar (REQ-024
# CA-02/CA-11 ii). Cero procesos añadidos (CA-07 i).
arnes_jq_file "$MAN" -r '[(.requirements_dir // "requirements"),
                          (.estados.completado // "completado"),
                          (.pending_approval // "PENDING_APPROVAL.md"),
                          (if .campos.ausencia_exige == true then "true" else "false" end)] | .[]'
REQ_DIR=''; DONE=''; PEND_REL=''; ARNES_AUSENCIA_EXIGE=false
{ IFS= read -r REQ_DIR; IFS= read -r DONE; IFS= read -r PEND_REL
  IFS= read -r ARNES_AUSENCIA_EXIGE; } <<< "$ARNES_JQ"
arnes_jq_file "$MAN" -r '(.estados.todos // ["borrador","pendiente","en-progreso","en-revisión","completado","bloqueado"])[]'
ESTADOS_OK=''
while IFS= read -r e; do arnes_norm_campo "$e"; ESTADOS_OK+="|$ARNES_CAMPO"; done <<< "$ARNES_JQ"
ESTADOS_OK+="|"   # cerrado por los dos lados: la comparacion es `|valor|`, exacta, no por prefijo

# Formas que la máquina reconoce en cada campo. Un valor fuera de aquí no es
# necesariamente un error del proyecto: puede ser un error del arnés al leerlo, y
# distinguirlo es justo lo que este informe existe para permitir.
# EL VOCABULARIO VIVE EN hooks/lib.sh (`ARNES_VOCAB_*`): el mismo que usa la puerta, no
# una copia. Dos transcripciones de la misma lista se desfasan, y este informe existe
# justo para detectar ese tipo de desfase — tenerlo dentro seria cómico.
QA_OK="|$ARNES_VOCAB_QA|"
SEG_OK="|$ARNES_VOCAB_SEG|"
RIG_OK="|$ARNES_VOCAB_RIGOR|"

# EL CONJUNTO DE CAMPOS DE CABECERA NO SE ENUMERA AQUI: SE DERIVA de su sitio unico, que
# es el lector de `hooks/lib.sh`. Una lista escrita a mano en el informe envejece el dia en
# que alguien añade un campo, y entonces el informe deja de hablar de ese campo SIN DECIRLO
# — que es la forma de mentir que este informe existe para no tener.
#
# DE DONDE SE DERIVA, y cambio en 1.34.0: hasta entonces se sacaba con `sed` DEL TEXTO de los
# brazos del `case` sobre `$ARNES_CLAVE`, porque el conjunto no existia como lista en ninguna
# parte de bash. Desde REQ-023 CA-06 existe: es la constante `ARNES_CLAVES`, de la que
# derivan tambien esos brazos y la guarda de medibilidad. Se lee de ahi —una expansion, sin
# un solo proceso— y no del texto del archivo: una derivacion que lee CODIGO se rompe con la
# primera mudanza del codigo, y este informe tiene que seguir hablando de todos los campos.
CAMPOS=(); vistos='|'
while IFS= read -r c; do
  [ -n "$c" ] || continue
  case "$vistos" in *"|$c|"*) continue ;; esac
  vistos+="$c|"; CAMPOS+=("$c")
done <<< "${ARNES_CLAVES//|/$'\n'}"
if [ "${#CAMPOS[@]}" -eq 0 ]; then
  printf 'No pude derivar los campos de cabecera de hooks/lib.sh: el informe no puede medir la forma.\n' >&2
  exit 2
fi

VERSION="$(jq -r '.version // "?"' "$DIR/../.claude-plugin/plugin.json" 2>/dev/null || echo '?')"
printf 'Lectura del arnés sobre %s/ — plugin %s\n\n' "$REQ_DIR" "$VERSION"

anomalias=0; reqs=0; notas=0; nc=0; ne=0; nl=0; formas=0
detalle=''; formato=''
# FALLO EN ABIERTO medido (1.30.1): `avisa` se llamaba dentro de `$( ... )` para capturar
# su texto, y el `anomalias=$((anomalias+1))` moria en ese subshell. El informe decia
# «Ningún valor anómalo» y salia 0 con cuatro REQ fuera del vocabulario en un proyecto
# real —justo la familia que vino a cazar—. El texto se ACUMULA ahora en una variable del
# proceso padre (`printf -v`) y el contador vive ahi. El banco exige que salga 1 y lo nombre.
avisa() {   # <req> <campo> <crudo> <leido> <consecuencia>
  local t
  anomalias=$((anomalias+1))
  printf -v t '  %-12s %s\n  %-12s   escrito:  «%s»\n  %-12s   se lee:   <%s>\n  %-12s   %s\n\n' \
    "$1" "$2" '' "$3" '' "$4" '' "$5"
  detalle+="$t"
}
# AVISO DE FORMA — NO ES UNA ANOMALIA, Y ESA ES LA DECISION.
#
# `avisa` significa «la maquina lee algo distinto de lo que pone» y saca el informe con
# codigo != 0. Una clave decorada NO es eso: `**Seguridad:** aprobado` se lee `aprobado`,
# exactamente lo que su autor quiso decir, y la tolerancia que lo permite cerro un
# fail-open real. Meterla entre las anomalias repetiria el caso medido en un proyecto real
# —28 de 42 anomalias falsas enterrando las 14 verdaderas—: un informe que grita por lo
# inofensivo deja de leerse, y entonces tampoco se lee lo que si importa.
#
# Pero callarlo tampoco vale: la linea que GOBIERNA un veredicto puede no ser la que
# cualquiera diria al mirar el documento —basta que el corte de un parrafo deje la clave al
# principio de una linea— y eso hay que poder verlo sin ejecutar la puerta. Asi que se
# NOMBRA en su propio bloque y no toca el codigo de salida.
nota_forma() {   # <req> <campo> <linea tal como esta escrita> <valor que lee la maquina>
  local t
  formas=$((formas+1))
  printf -v t '  %-12s %s\n  %-12s   linea:    «%s»\n  %-12s   se lee:   <%s>\n  %-12s   %s\n\n' \
    "$1" "$2" '' "$3" '' "$4" '' 'gobierna este campo, y la forma es legitima; el aviso existe porque la linea que manda no es la que parece.'
  formato+="$t"
}

for f in "$PROY/$REQ_DIR"/*.md; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  case "$base" in README.md|readme.md) continue ;; esac
  texto=''; IFS= read -r -d '' texto < "$f"

  # Los campos CRUDOS, para poder enseñar el contraste con lo que la máquina lee, y de
  # cada uno: cuantas veces lo declara la cabecera, cual es la linea que GOBIERNA y si esa
  # linea venia decorada. Los tres se necesitan para separar el aviso de forma (CA-05) de
  # la anomalia de veras (CA-06), y los tres salen del MISMO lector que la puerta.
  declare -A CRU=() DEC=() CNT=() LIN=()
  # El rango de comentario cruza lineas: su estado se reinicia por documento. El CR que no
  # termina la linea tambien lo acumula el lector, y por el mismo motivo.
  ARNES_CITA=0; ARNES_CR=0; ARNES_CR_LINEA=''
  # Y la clave con algo insertado dentro, que el lector acumula por la misma via.
  ARNES_OCULTA=0; ARNES_OCULTA_CLAVE=''; ARNES_OCULTA_REPR=''; ARNES_OCULTA_ESTADO=''
  while IFS= read -r l; do
    # Solo la cabecera cuenta, como para la puerta: lo que haya en una seccion no es un campo.
    case "$l" in '## '*) break ;; esac
    # La CLAVE se lee con `arnes_campo_linea` (hooks/lib.sh), la misma regla que la puerta:
    # retira las CITAS —lo que vive dentro de un `<!-- ... -->` no declara campo— y
    # normaliza la clave. Un informe que no reconoce `**Estado:**` diria «nota sin Estado»
    # sobre un REQ que la puerta ya juzga cerrado, y un informe que leyera el interior de un
    # comentario diria que gobierna un veredicto que la puerta ya no lee: las dos formas de
    # mentir son la misma, y por eso hay UN solo lector.
    arnes_campo_linea "$l" || continue
    case "$vistos" in *"|$ARNES_CLAVE|"*) ;; *) continue ;; esac
    k="$ARNES_CLAVE"
    CNT[$k]=$(( ${CNT[$k]:-0} + 1 ))
    # `Estado:` gobierna por su PRIMERA aparicion y los demas campos por la ULTIMA: es la
    # asimetria heredada que aplican la puerta y `campos-req.awk`, y este informe la
    # respeta en vez de tener su propia opinion. Solo se nota en un REQ malformado — que
    # es, exactamente, el REQ que hay que mirar.
    if [ "$k" != "$ARNES_CLAVE_ESTADO" ] || [ "${CNT[$k]}" -eq 1 ]; then
      CRU[$k]="$ARNES_VALOR"; DEC[$k]="$ARNES_CLAVE_DECORADA"; LIN[$k]="$l"
    fi
  done <<< "$texto"
  cita_abierta="$ARNES_CITA"; cr_interior="$ARNES_CR"; cr_linea="$ARNES_CR_LINEA"

  # UNA CLAVE CON ALGO INSERTADO DENTRO ES ANOMALIA, y va ANTES de todo lo demas — incluido
  # el descarte de los archivos sin `Estado:`— porque ese descarte es justamente donde se
  # esconde el caso peor: si el caracter cayo sobre la clave del ESTADO, este informe leia
  # «archivo sin Estado, no es un REQ», lo contaba como nota y salia con rc=0 sobre el
  # documento mas peligroso que hay. Es LITERALMENTE «la maquina no lee este campo como esta
  # escrito», y encima el caracter es invisible y el diff no lo muestra: este informe es la
  # UNICA superficie donde una persona puede verlo antes de intentar cerrar (REQ-023 CA-07).
  if [ "${ARNES_OCULTA:-0}" != "0" ]; then
    avisa "${base%.md}" "${ARNES_OCULTA_CLAVE}:" "${ARNES_OCULTA_REPR}:" 'cabecera no medible' \
      "esa clave lleva DENTRO uno o más bytes ajenos —se muestran como \`\\xNN\`; en el archivo son invisibles—: un BOM (\`\\xef\\xbb\\xbf\`, el que PowerShell añade al redirigir), un espacio de anchura cero (\`\\xe2\\x80\\x8b\`), un byte de control, un multibyte partido, o un BLANCO de más o puesto en el sitio de otro (\`Sensible a  seguridad\`; los blancos salen en \`\\xNN\` sólo cuando alguno de ellos ES lo insertado). Una persona lee ahí \`${ARNES_OCULTA_CLAVE}:\` y la máquina NO lo lee como ese campo, así que la cabecera no se puede medir y la puerta de cierre DENIEGA. Reescribe esa línea dejando la clave limpia."
  fi

  cru_est="${CRU[$ARNES_CLAVE_ESTADO]:-}"; cru_qa="${CRU[$ARNES_CLAVE_QA]:-}"
  cru_seg="${CRU[$ARNES_CLAVE_SEG]:-}"; cru_sens="${CRU[$ARNES_CLAVE_SENS]:-}"
  cru_rig="${CRU[$ARNES_CLAVE_RIGOR]:-}"

  # EL MISMO LECTOR QUE LA PUERTA, tambien para `Estado:`. La regla del parentesis de
  # evidencia se le aplica en la puerta desde 1.26.0 y este informe no lo hacia, asi que
  # un `Estado: en-revisión (2026-08-25, tras la ronda 3)` salia como «ninguna puerta lo
  # reconoce». Medido en un proyecto real: 28 de 42 anomalias eran falsas, y el ruido
  # enterraba las 14 reales. Un informe que lee distinto de la puerta sobre la que informa
  # miente.
  arnes_norm_campo "$cru_est"; arnes_veredicto "$ARNES_CAMPO"; est="$ARNES_VEREDICTO"
  if [ -z "$est" ]; then notas=$((notas+1)); continue; fi
  reqs=$((reqs+1))

  # El mismo camino que recorren los hooks, ni uno distinto.
  arnes_campos_req "$texto" ''
  case "$ARNES_RIGOR" in critico) nc=$((nc+1)) ;; estandar) ne=$((ne+1)) ;; ligero) nl=$((nl+1)) ;; esac

  case "$ESTADOS_OK" in *"|$est|"*) ;; *)
    avisa "${base%.md}" "Estado:" "${cru_est# }" "$est" \
      "no está en \`estados.todos\` del manifiesto; ninguna puerta lo reconoce." ;;
  esac
  if [ "${ARNES_SENS_DUDOSA:-0}" = "1" ]; then
    avisa "${base%.md}" "Sensible a seguridad:" "${cru_sens# }" "$ARNES_SENS_CRUDO" \
      "no se lee ni como sí ni como no → se trata como SENSIBLE (lado seguro). Escribe \`sí\` o \`no\`."
  fi
  if [ -n "$ARNES_QA" ]; then case "$QA_OK" in *"|$ARNES_QA|"*) ;; *)
    avisa "${base%.md}" "QA:" "${cru_qa# }" "$ARNES_QA" \
      "no es \`aprobado\` ni ningún veredicto conocido → este REQ NO puede cerrarse." ;;
  esac; fi
  if [ -n "$ARNES_SEG" ]; then case "$SEG_OK" in *"|$ARNES_SEG|"*) ;; *)
    avisa "${base%.md}" "Seguridad:" "${cru_seg# }" "$ARNES_SEG" \
      "no es un veredicto conocido → si el rigor es \`critico\`, este REQ NO puede cerrarse." ;;
  esac; fi
  if [ -n "$cru_rig" ]; then
    arnes_norm_campo "$cru_rig"; r="$ARNES_CAMPO"
    case "$RIG_OK" in *"|$r|"*) ;; *)
      avisa "${base%.md}" "Rigor:" "${cru_rig# }" "$r" \
        "no es un nivel válido → se IGNORA y el REQ se juzga como si no lo declarara." ;;
    esac
  fi

  # --- LA FORMA DE LA LINEA QUE GOBIERNA, campo por campo ---------------------------
  # Dos hechos distintos, y separarlos es el punto:
  #   * la linea que manda viene DECORADA y es la unica que declara el campo -> aviso de
  #     forma: el valor es impecable, la puerta lo lee bien y el informe NO cambia de
  #     codigo por esto;
  #   * la cabecera declara el campo MAS DE UNA VEZ y la que gobierna es la decorada ->
  #     ANOMALIA por la via unica (`avisa`, salida != 0): el documento dice dos cosas y la
  #     maquina elige una sin avisar. Ahi no sobra el ruido: falta el aviso.
  for k in "${CAMPOS[@]}"; do
    [ "${DEC[$k]:-0}" = "1" ] || continue
    arnes_norm_campo "${CRU[$k]:-}"; arnes_veredicto "$ARNES_CAMPO"
    if [ "${CNT[$k]:-0}" -gt 1 ]; then
      avisa "${base%.md}" "$k:" "${LIN[$k]}" "$ARNES_VEREDICTO" \
        "la cabecera declara \`$k:\` ${CNT[$k]} veces y la que GOBIERNA es esta, escrita con la clave decorada o sangrada. El documento dice dos cosas y la máquina elige una: deja una sola declaración."
    else
      nota_forma "${base%.md}" "$k:" "${LIN[$k]}" "$ARNES_VEREDICTO"
    fi
  done

  # UN RANGO DE COMENTARIO SIN CERRAR EN LA CABECERA SI ES ANOMALIA, y de las que importan:
  # es exactamente lo que la puerta de cierre DENIEGA, porque con el rango abierto no se
  # sabe que campos se han quedado dentro. Aqui no hay nada que interpretar ni ruido que
  # sopesar: el informe dice lo mismo que decidira la puerta.
  if [ "${cita_abierta:-0}" != "0" ]; then
    avisa "${base%.md}" "(cabecera)" '<!-- … sin -->' 'cabecera incompleta' \
      "la cabecera abre un comentario HTML que no cierra antes del primer \`## \`: los campos que vienen detrás NO se leen y la puerta de cierre DENIEGA. Cierra el comentario dentro de la cabecera."
  fi
  # UN CR QUE NO TERMINA LA LINEA TAMBIEN ES ANOMALIA, y de las que este informe existe para
  # nombrar: es LITERALMENTE «la máquina no lee este valor como está escrito», y encima el
  # carácter es invisible. Faltaba, y la ausencia no era neutral — este informe respondía
  # «ningún valor anómalo, rc=0» sobre un documento con un `Seg`+CR+`uridad:` que cerraba un
  # REQ `critico` (SEC-024, R-007): el discriminante `ARNES_CLAVE_DECORADA` se deriva DESPUÉS
  # del descuento del CR, así que la reparación era invisible a la única función que existe
  # para nombrarla. Ahora la nombra el lector de línea, que es el mismo que la puerta.
  if [ "${cr_interior:-0}" != "0" ]; then
    avisa "${base%.md}" "(cabecera)" "$cr_linea" 'cabecera no medible' \
      "esa línea lleva un retorno de carro (CR) que NO la termina —se muestra como \`\\r\`, en el archivo es invisible—. Puede FABRICAR delimitadores para unos lectores y no para otros, así que la cabecera no se puede medir y la puerta de cierre DENIEGA. Retira ese CR. El CR que TERMINA una línea es transporte (CRLF) y no cuenta."
  fi
done

# LA COLA SE MIDE AQUI, ANTES DE AFIRMAR NADA (REQ-024 CA-08 iii). Se medía al final, en el
# RESUMEN, y por eso este informe podía imprimir «Ningún valor anómalo» y salir 0 sobre un
# archivo de cola que no se pudo medir — el mismo fail-open de tres canales que SEC-051
# midió, con el informe como el único sitio donde una persona busca anomalías. Es la MISMA
# función que usa la puerta de cierre y el bloque derivado (`arnes_cola_pendientes`,
# hooks/lib.sh): una tercera transcripción de la regla de conteo aquí sería cómica.
COLA_RC=0
arnes_cola_pendientes "$PROY/$PEND_REL" || COLA_RC=$?

if [ "$anomalias" -gt 0 ]; then
  printf 'VALORES QUE LA MÁQUINA NO LEE COMO ESTÁN ESCRITOS (%s)\n\n%s' "$anomalias" "$detalle"
elif [ "$COLA_RC" -ne 0 ]; then
  # NO se afirma «Ningún valor anómalo»: la afirmación abarca el proyecto, y de este
  # proyecto hay una parte que no se pudo medir. Decir que todo está bien porque lo que se
  # pudo leer estaba bien es la forma de mentir que este informe existe para no tener.
  printf 'LA COLA DE APROBACIONES NO SE PUDO MEDIR — este informe NO puede afirmar «Ningún valor anómalo»\n\n'
  printf '  Los %s REQ leídos no traen ningún valor que la máquina lea distinto de como está\n' "$reqs"
  printf '  escrito, pero %s no se pudo medir (ver RESUMEN), así que el estado del proyecto\n' "$PEND_REL"
  printf '  queda sin acreditar y la puerta de cierre DENIEGA.\n\n'
else
  printf 'Ningún valor anómalo: la máquina lee los %s REQ como están escritos.\n\n' "$reqs"
fi
# En su PROPIO bloque y detrás de las anomalías: no compite con ellas y no las entierra.
if [ "$formas" -gt 0 ]; then
  printf 'LÍNEAS DECORADAS QUE GOBIERNAN UN CAMPO (%s) — forma legítima, NO altera el código de salida\n\n%s' \
    "$formas" "$formato"
fi

printf 'RESUMEN\n'
printf '  %s REQ leídos' "$reqs"
[ "$notas" -gt 0 ] && printf ' · %s archivo(s) sin `Estado:` (notas, no REQ)' "$notas"
printf '\n  rigor efectivo: critico %s · estandar %s · ligero %s\n' "$nc" "$ne" "$nl"
# La cola de aprobaciones, ya medida arriba (una sola llamada: medirla dos veces costaría
# una lectura de archivo por informe y podría publicar dos números distintos).
if [ "$COLA_RC" -eq 0 ]; then
  printf '  cola de aprobaciones (%s): %s pendiente(s) — %s\n' "$PEND_REL" "$ARNES_COLA" \
    "$([ "$ARNES_COLA" -gt 0 ] && echo 'ningún REQ puede cerrarse' || echo 'no bloquea el cierre')"
elif [ "${ARNES_COLA_ABIERTA:-0}" = "1" ]; then
  printf '  cola de aprobaciones (%s): sin datos — ABRE un rango de comentario en la línea %s («%s») que no cierra; la puerta de cierre DENIEGA\n' \
    "$PEND_REL" "${ARNES_COLA_ABRE_LN:-?}" "${ARNES_COLA_ABRE_TEXTO:-}"
else
  printf '  cola de aprobaciones (%s): sin datos — no se pudo leer entera; la puerta de cierre DENIEGA\n' "$PEND_REL"
fi
printf '\n  El rigor efectivo es DERIVADO: `Sensible a seguridad: sí` impone `critico`\n'
printf '  aunque no se declare `Rigor:`. Si un REQ que crees crítico sale `estandar`,\n'
printf '  su campo de sensibilidad no se está leyendo como crees.\n'
# EL CODIGO DE SALIDA CUBRE LAS DOS COSAS (REQ-024 CA-08 iii): un valor que la maquina no
# lee como esta escrito, Y una cola que no se pudo medir. Salir 0 con la cola sin datos
# convertia el `sin datos` del RESUMEN en un adorno: quien automatiza este informe mira el
# codigo de salida, no el texto.
[ "$anomalias" -eq 0 ] && [ "$COLA_RC" -eq 0 ]
