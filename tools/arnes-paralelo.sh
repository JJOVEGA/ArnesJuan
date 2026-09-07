#!/usr/bin/env bash
# arnes-paralelo.sh — ¿qué dos comisiones pueden despacharse a la vez?
#
# POR QUÉ EXISTE
# Medido en el ciclo 2 (2026-09-06): siete REQ se resolvieron en tres comisiones grandes
# de desarrollador y UNA sola de QA, y el tiempo de reloj del ciclo fue prácticamente
# igual a la suma del tiempo de agente. No es que hubiera una regla que prohibiera
# paralelizar: es que NADIE PODÍA AFIRMAR SIN ADIVINAR qué dos comisiones no iban a
# pisarse. Esta herramienta responde esa pregunta —y sólo esa— leyendo el campo
# `Archivos:` de la cabecera de cada REQ e intersecando los conjuntos que declara.
#
# LO QUE NO HACE, dicho por delante:
#   * NO despacha agentes, no escribe en `PENDING_APPROVAL.md` y no toca ningún REQ.
#     Informa; quien decide es la coordinadora (misma frontera que el bloque derivado
#     de `docs/ESTADO.md`: informa sin decidir).
#   * NO evalúa el ORDEN DE FASES. Que dos REQ sean disjuntos en archivos no autoriza a
#     correr el `auditor-seguridad` a la vez que el `qa-tester`: esa regla vive en
#     `AGENTS.md` §6 y esta herramienta no la comprueba. La advertencia sale SIEMPRE en
#     la salida, porque un `disjunto` leído como permiso general produce una firma falsa,
#     que es el fallo más caro que este arnés puede tener.
#   * NO es una puerta. Ningún hook la invoca (`hooks/hooks.json` no la registra) y la
#     ausencia del campo no impide cerrar ningún REQ: el fail-closed vive AQUÍ —sin mapa,
#     no hay paralelismo—, donde el coste de equivocarse es volver a la serie.
#
# UNA REGLA, UN LECTOR. El valor de `Archivos:` se obtiene con la NORMALIZACIÓN de
# `hooks/lib.sh` —la misma que leen las dos puertas—: el recorte de la cabecera antes del
# primer `## ` (los campos valen sólo en la cabecera), la clave decorada
# (`arnes_norm_clave`), el desenvoltorio del marcado (`arnes_desenvuelve`) y la regla del
# paréntesis de evidencia (`arnes_veredicto`). Aquí no hay ni un `grep '^Archivos:'` ni un
# `awk`/`sed` que reimplemente nada de eso: dos transcripciones de la misma regla se
# desfasan en silencio, y este arnés ya pagó esa lección tres veces.
#
# Y lo que NO se comparte es el MAPEO: `Archivos:` no se añade a la lista de campos que
# leen las puertas (`arnes_campos_req`/`arnes_estado_cabecera` siguen devolviendo lo
# mismo). Un campo que no gobierna nada no entra en el lector que sí gobierna. El diff de
# `hooks/lib.sh` para este cambio es VACÍO, y ésa es la comprobación.
#
# Uso:
#   tools/arnes-paralelo.sh                       todos los REQ abiertos del proyecto
#   tools/arnes-paralelo.sh REQ-012 REQ-013        sólo esos
#   tools/arnes-paralelo.sh --json                 la misma respuesta en JSON
#   tools/arnes-paralelo.sh --proyecto DIR         otra raíz (por defecto, el cwd)
#
# Sale 0 si todos los pares son disjuntos; 1 si alguno colisiona o hay un REQ sin mapa
# legible; 2 si NO PUDO MEDIR (sin jq, sin manifiesto, sin REQ). Una herramienta que no
# midió no responde «adelante».
set -uo pipefail

DIR="${BASH_SOURCE[0]%/*}"
[ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/../hooks/lib.sh"

# --- Argumentos ---------------------------------------------------------------
JSON=no
PROY="$PWD"
IDS=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --json)      JSON=si ;;
    --proyecto)  shift; PROY="${1:-}" ;;
    --proyecto=*) PROY="${1#--proyecto=}" ;;
    -h|--help)   sed -n '2,45p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)          printf 'arnes-paralelo: opción desconocida «%s».\n' "$1" >&2; exit 2 ;;
    *)           IDS+=("$1") ;;
  esac
  shift
done

no_medido() { printf 'arnes-paralelo: %s\n' "$1" >&2
              printf 'No se midió nada, así que no se responde «adelante»: el modo por defecto es la serie.\n' >&2
              exit 2; }

command -v jq >/dev/null 2>&1 || no_medido 'hace falta jq y no está en el PATH.'
[ -n "$PROY" ] && [ -d "$PROY" ] || no_medido "no existe el directorio de proyecto «${PROY:-}»."
MAN="$PROY/.arnes/config.json"
[ -f "$MAN" ] || no_medido "no hay .arnes/config.json en $PROY — esto no es un proyecto del arnés."

# El único proceso externo por invocación: leer el manifiesto. Todo lo demás —lectura de
# los REQ, normalización, expansión de globs e intersección— es expansión de parámetros y
# globs de bash. En esta plataforma cada fork cuesta entre 1,2 y 6 s, y una herramienta
# que se paga por REQ leído multiplicaría ese coste por el número de REQ.
arnes_jq_file "$MAN" -r '[(.requirements_dir // "requirements"),
                          (.estados.completado // "completado")] | .[]' \
  || no_medido "no se pudo leer $MAN (¿JSON válido?)."
REQ_DIR=''; TERMINAL=''
{ IFS= read -r REQ_DIR; IFS= read -r TERMINAL; } <<< "$ARNES_JQ"
[ -n "$REQ_DIR" ] || REQ_DIR=requirements
arnes_norm_campo "$TERMINAL"; TERMINAL="$ARNES_CAMPO"

# A partir de aquí se trabaja DESDE la raíz del proyecto: los globs del campo son
# relativos a ella (CA-01) y expandirlos desde otro sitio daría un conjunto distinto.
cd -- "$PROY" || no_medido "no se pudo entrar en $PROY."
[ -d "$REQ_DIR" ] || no_medido "no existe el directorio $REQ_DIR/ en el proyecto."

# --- Lectura del campo, con el lector de las puertas --------------------------
# El campo vale SÓLO en la cabecera, antes del primer `## `: la misma regla estructural
# que aplican `arnes_campos_req` y `arnes_estado_cabecera`, y por el mismo motivo (una
# línea igual dentro de una sección no es una declaración).
#
# DUPLICADOS: GANA EL ÚLTIMO, como en `arnes_campos_req`. Aquel recorre la cabecera
# ENTERA sin salir, así que una segunda línea `QA:` pisa a la primera; aquí se salía en
# la primera aparición y ganaba la de arriba. Dos lectores del mismo campo con
# precedencias distintas es la copia que CA-03 prohíbe, y divergía hacia el lado que
# abre: `Archivos: (ninguno)` seguido de `Archivos: hooks/lib.sh` daba `disjunto`.
lee_campo_archivos() {   # <texto> -> ARNES_ARCH_CRUDO ; 1 si el REQ no declara el campo
  ARNES_ARCH_CRUDO=''
  local l hallado=1
  # `arnes_campo_linea` y no `arnes_norm_clave` a secas: el lector de cabecera es UNO, y
  # desde 1.32.1 incluye la noción de CITA —lo que vive dentro de un `<!-- … -->` no
  # declara campo—. Este análisis leía el interior de un comentario como una declaración
  # de `Archivos:`, así que un mapa comentado seguía gobernando el reparto.
  ARNES_CITA=0
  while IFS= read -r l; do
    case "$l" in '## '*) break ;; esac
    arnes_campo_linea "$l" || continue
    case "$ARNES_CLAVE" in 'Archivos') ARNES_ARCH_CRUDO="$ARNES_VALOR"; hallado=0 ;; esac
  done <<< "$1"
  return "$hallado"
}

# LEER ENTERO O DECIRLO. `IFS= read -r -d '' texto < "$f" || :` se tragaba las dos
# averías que hacen desaparecer un REQ del análisis: el archivo que no se puede abrir
# (permisos) y el que lleva un byte NUL en banda —`read -d ''` corta AHÍ y el resto,
# cabecera incluida, no existe para nadie—. En los dos casos el REQ se caía de la lista
# sin una palabra y `colisiona`/rc 1 se convertía en `disjunto`/rc 0. La regla del arnés
# ya está decidida para la cola de aprobaciones: lo que no se puede leer entero no se
# descarta, se declara y contamina el veredicto.
#
# El código de `read` distingue los tres casos sin un solo proceso: 9 = la redirección
# ni siquiera abrió el archivo · 0 = paró en un NUL y queda cola por leer · 1 = llegó
# al final del archivo, que es el camino normal.
MOTIVO_LECTURA=''
lee_texto() {   # <archivo> -> ARNES_TEXTO ; 1 si no se pudo leer ENTERO
  ARNES_TEXTO=''; MOTIVO_LECTURA=''
  local rc=9
  { IFS= read -r -d '' ARNES_TEXTO; rc=$?; } 2>/dev/null < "$1"
  case "$rc" in
    9) MOTIVO_LECTURA='no se pudo abrir (¿permisos?)'; return 1 ;;
    0) MOTIVO_LECTURA='lleva un byte NUL en banda'; ARNES_TEXTO=''; return 1 ;;
  esac
  return 0
}

# Una ruta o glob declarado -> forma canónica. Fail-closed: lo que no se entiende NO se
# adivina, se rechaza con motivo y el REQ entero pasa a `sin declarar` (y colisiona con
# todos).
#   1 = vacío · 2 = absoluta · 3 = sale de la raíz · 4 = lleva blancos
#   5 = no designa nada: no existe, ningún ancestro suyo existe y no tiene forma de archivo
#   6 = le queda un paréntesis sin cerrar tras aplicarle la regla de la evidencia
MOTIVO_RUTA=''
norm_ruta() {   # <elemento crudo> -> ARNES_RUTA
  ARNES_RUTA=''; MOTIVO_RUTA=''
  _arnes_recorta_blancos "$1"
  # El marcado no es parte del valor, aquí igual que en la cabecera: `hooks/lib.sh`
  # entre acentos graves, en negrita o en cursiva es la misma ruta. Se reutiliza la
  # función de `hooks/lib.sh`, no una copia.
  arnes_desenvuelve "$ARNES_TRIM"
  _arnes_recorta_blancos "$ARNES_DESENV"
  local p="$ARNES_TRIM" seg rest out=''
  [ -n "$p" ] || { MOTIVO_RUTA='elemento vacío'; return 1; }
  # Una ruta ABSOLUTA está fuera de la forma documentada (rutas relativas a la raíz del
  # repositorio). No se traduce ni se adivina la raíz: se rechaza. Un mapa que a veces
  # habla de otro árbol no es un mapa.
  case "$p" in /*|[A-Za-z]:*|[A-Za-z]:[\\/]*) MOTIVO_RUTA="ruta absoluta «$p» (la forma documentada es relativa a la raíz)"; return 2 ;; esac
  # UN PARÉNTESIS QUE SOBREVIVE NO ES UNA RUTA, Y NO SE BORRA EN SILENCIO (SEC-014). La
  # regla del paréntesis ya se aplicó a este elemento antes de llamar aquí, así que lo que
  # llegue con paréntesis es una anotación SIN CERRAR (`hooks/lib.sh (x, tools/y.sh`) o un
  # paréntesis suelto: no se adivina dónde acaba la ruta y dónde empieza la nota. Se
  # rechaza CON SU MOTIVO y el REQ entero pasa a SIN DECLARAR; antes desaparecía en
  # silencio junto con todo lo que venía detrás. Se juzga antes que los blancos porque una
  # anotación también lleva espacios y el motivo genérico no dice qué hacer.
  # Efecto lateral declarado: un archivo real cuyo nombre lleve un paréntesis desparejado
  # se rechaza. Es la dirección segura —colisiona, no autoriza— y sale nombrado.
  case "$p" in
    *'('*|*')'*) MOTIVO_RUTA="«$p» lleva un paréntesis sin cerrar: la evidencia de un elemento va entre paréntesis balanceados al final de ESE elemento, como «tools/x.sh (nuevo)», y los elementos se separan por comas"; return 6 ;;
  esac
  case "$p" in *[[:blank:]]*) MOTIVO_RUTA="«$p» lleva espacios (los elementos se separan por comas, no por blancos)"; return 4 ;; esac
  # Barras repetidas y contrabarras: la MISMA función que usan las dos puertas
  # (`arnes_norm_path`). La barra duplicada fue la evasión más barata medida en todo el
  # arnés y no puede volver a desactivar una comprobación por otra puerta.
  arnes_norm_path "$p"; p="$ARNES_NORM"
  # Segmentos `.` y `..`. Esto sí es propio: `hooks/lib.sh` no resuelve `..` porque sus
  # puertas no lo necesitan. Es resolución de RUTAS, no lectura de campos: la regla que
  # CA-02 protege —cómo se lee un campo de la cabecera— sigue viviendo una sola vez.
  rest="$p"
  while [ -n "$rest" ]; do
    seg="${rest%%/*}"
    if [ "$seg" = "$rest" ]; then rest=''; else rest="${rest#*/}"; fi
    case "$seg" in
      ''|'.') ;;
      '..')  case "$out" in
               */*) out="${out%/*}" ;;
               ?*)  out='' ;;
               *)   MOTIVO_RUTA="«$p» sale de la raíz del proyecto"; return 3 ;;
             esac ;;
      *)     out="${out:+$out/}$seg" ;;
    esac
  done
  [ -n "$out" ] || { MOTIVO_RUTA="«$p» se queda en nada al normalizarla"; return 1; }
  # UN MARCADOR DE POSICIÓN NO ES UNA RUTA FUTURA. `TBD`, `todo`, `-` o `?` son
  # indistinguibles de un archivo por crear para un comparador de texto, y la lectura
  # optimista respondía `disjunto` con todo y rc 0 justo cuando el autor del REQ
  # todavía no sabe qué va a tocar — el caso en que más caro sale decir «adelante».
  #
  # Se juzga por PROPIEDAD, no por lista. La primera versión de la propiedad era «no
  # tiene `/` y no tiene punto», y eso deja pasar a los marcadores que llevan uno de los
  # dos por accidente: `n/d` y `s/d` —los equivalentes castellanos de `n/a` en un
  # proyecto que documenta en español—, `n.a.`, `t.b.d.` o `pendiente.` (QA-212).
  # Alargar la lista no es el arreglo; enunciar bien la propiedad, sí.
  #
  # LA PROPIEDAD: un elemento que NO existe en el árbol designa un archivo FUTURO sólo si
  #   (a) algún prefijo suyo —un ancestro— SÍ existe (`hooks/post-bash.sh`: `hooks/` está
  #       ahí; `tools/nuevo.sh`: `tools/` está ahí), o
  #   (b) su último segmento tiene EXTENSIÓN de verdad: un punto con nombre a la izquierda
  #       y sufijo no vacío a la derecha (`carpeta-nueva/x.sh`, `*.md`).
  # `n/d` no cumple ninguna: `n/` no existe y `d` no tiene extensión. `n.a.` y `pendiente.`
  # tampoco: acaban en punto, así que el sufijo está vacío. Un archivo real sin extensión
  # (`Makefile`, `hooks`) existe y pasa por el `-e`; uno futuro sin extensión ni ancestro
  # cae aquí — falso positivo conocido, en la dirección segura (colisiona, no autoriza).
  if [ ! -e "$out" ]; then
    local ult="${out##*/}" pre="$out" ancestro=no sufijo raiz
    while case "$pre" in */*) true ;; *) false ;; esac; do
      pre="${pre%/*}"
      if [ -e "$pre" ]; then ancestro=si; break; fi
    done
    if [ "$ancestro" = no ]; then
      sufijo=''; raiz=''
      case "$ult" in *.*) sufijo="${ult##*.}"; raiz="${ult%.*}" ;; esac
      if [ -z "$sufijo" ] || [ -z "$raiz" ]; then
        MOTIVO_RUTA="«$p» no designa nada: no existe en el árbol, ningún directorio suyo existe y no tiene forma de archivo (¿es un marcador de posición?)"
        return 5
      fi
    fi
  fi
  ARNES_RUTA="$out"
}

# Un patrón -> los archivos REALES que alcanza. La intersección se resuelve EXPANDIENDO
# CONTRA EL ÁRBOL, no razonando sobre el texto de los patrones: `hooks/guard-*.sh` y
# `hooks/*completado*` no se parecen en nada como cadenas y comparten un archivo.
# Un patrón que no casa con NADA se conserva como ruta literal —un archivo que todavía no
# existe es exactamente donde dos comisiones chocan— y se compara por texto normalizado.
# Y un DIRECTORIO arrastra todo lo que cuelga de él: declarar `tools/` y `tools/x.sh` por
# separado y llamarlos disjuntos sería el falso negativo más fácil de producir.
EXPANSION=()
expande() {   # <patrón normalizado> -> EXPANSION
  local pat="$1" x y
  local -a m sub
  EXPANSION=()
  m=( $pat )
  for x in "${m[@]}"; do
    x="${x%/}"
    [ -n "$x" ] || continue
    EXPANSION+=( "$x" )
    if [ -d "$x" ]; then
      sub=( "$x"/** )
      for y in "${sub[@]}"; do y="${y%/}"; [ -n "$y" ] && EXPANSION+=( "$y" ); done
    fi
  done
  [ "${#EXPANSION[@]}" -gt 0 ] || EXPANSION=( "$pat" )
}

# --- Qué REQ se evalúan -------------------------------------------------------
shopt -s nullglob globstar
if [ "${#IDS[@]}" -gt 0 ]; then
  ARCHIVOS_REQ=()
  for id in "${IDS[@]}"; do
    id="${id%.md}"
    if   [ -f "$REQ_DIR/$id.md" ]; then ARCHIVOS_REQ+=( "$REQ_DIR/$id.md" )
    elif [ -f "$id" ];             then ARCHIVOS_REQ+=( "$id" )
    else no_medido "no encuentro «$id» en $REQ_DIR/."
    fi
  done
else
  ARCHIVOS_REQ=( "$REQ_DIR"/*.md )
fi
[ "${#ARCHIVOS_REQ[@]}" -gt 0 ] || no_medido "no hay ni un REQ en $REQ_DIR/: no hay nada que intersecar."

ID=(); DECL=(); MOTIVO=(); PATRONES=(); ESTADO=()
RUTAS=()          # todas las rutas expandidas, en orden de aparición
FUTUROS=()        # las que NO existen todavía en el árbol
declare -A DUENOS=()   # ruta -> " i j k "
declare -A VISTA=()    # ruta -> 1 (para el orden de RUTAS)
n=0
for f in "${ARCHIVOS_REQ[@]}"; do
  base="${f##*/}"
  case "$base" in README.md|readme.md) continue ;; esac
  if ! lee_texto "$f"; then
    # No se descarta: se declara. Un archivo de `requirements/` que no se puede leer
    # entero es, para esta herramienta, un REQ del que no sabemos nada — y de lo que no
    # se sabe no se dice «disjunto». Aparece en la lista, colisiona con todos y sale ≠ 0.
    ID[n]="${base%.md}"; ESTADO[n]='?'; DECL[n]=no; PATRONES[n]=''
    MOTIVO[n]="no se pudo leer entero: $MOTIVO_LECTURA"
    n=$((n+1)); continue
  fi
  texto="$ARNES_TEXTO"
  arnes_estado_cabecera "$texto"; est="$ARNES_ESTADO"
  # UN CR QUE NO TERMINA LA LINEA: la cabecera no se puede medir, y de lo que no se sabe
  # esta herramienta no dice «disjunto» (misma regla que el archivo ilegible, arriba). Lo
  # publica el lector de cabecera de `hooks/lib.sh`, que es el mismo que usa la puerta, así
  # que aquí no hay una segunda opinión sobre qué es medible.
  #
  # SE JUZGA ANTES QUE EL `Estado:`, y a propósito: el CR puede FABRICAR la clave o un
  # delimitador de comentario, así que el propio `Estado:` que se acaba de leer es lo que
  # está en duda — saltarse un REQ por «ya está cerrado» sería creerle a la lectura que se
  # está declarando no medible. Efecto lateral declarado: un REQ en estado terminal con un
  # CR suelto aparece en la lista y colisiona. Es la dirección segura y sale nombrado.
  if [ "$ARNES_ESTADO_CR" = "1" ]; then
    ID[n]="${base%.md}"; ESTADO[n]="${est:-?}"; DECL[n]=no; PATRONES[n]=''
    MOTIVO[n]="su cabecera lleva un retorno de carro (CR) que NO termina la línea, en «$ARNES_ESTADO_CR_LINEA»: no se puede medir (la puerta de cierre también la deniega)"
    n=$((n+1)); continue
  fi
  if [ "${#IDS[@]}" -eq 0 ]; then
    # Sin argumentos se evalúan los REQ ABIERTOS: los que NO están en el estado terminal
    # que declara el manifiesto. Un REQ cerrado ya no se despacha, y saltarlo no esconde
    # nada: se sabe por qué se saltó.
    #
    # QA-211 — EL QUINTO FAIL-OPEN, Y LA MISMA CLASE QUE LOS CUATRO ANTERIORES. Aquí
    # había un `[ -n "$est" ] || continue` mudo, con el razonamiento «un archivo sin
    # `Estado:` no es un REQ, es una nota». El razonamiento es defendible; el silencio no:
    # una cabecera cuyos campos quedaron debajo del primer `## `, un REQ a medio redactar
    # o un archivo de 0 bytes desaparecían de la población evaluada SIN UNA PALABRA, el
    # recuento bajaba de 3 a 2 y `colisiona`/rc 1 se convertía en `disjunto`/rc 0. Y la
    # herramienta se contradecía consigo misma: el MISMO archivo, pasado como argumento
    # explícito, sí se evaluaba y sí colisionaba.
    #
    # Se resuelve por donde CA-13 manda —el sitio único: un motivo en `MOTIVO[…]`— y no
    # con una línea suelta de aviso. Efecto lateral asumido y declarado: un `.md` que de
    # verdad sea una nota, y no un REQ, empuja la respuesta a `colisiona`/rc 1. Es la
    # dirección segura, dice cuál es el archivo y qué le falta, y la salida es de una
    # línea: o se le pone `Estado:`, o se saca de `requirements/`.
    if [ -z "$est" ]; then
      ID[n]="${base%.md}"; ESTADO[n]='?'; DECL[n]=no; PATRONES[n]=''
      MOTIVO[n]='no se le pudo leer el `Estado:` de la cabecera (¿está vacío, o los campos quedaron debajo del primer `## `?)'
      n=$((n+1)); continue
    fi
    [ "$est" != "$TERMINAL" ] || continue
  fi
  ID[n]="${base%.md}"; ESTADO[n]="${est:-?}"; DECL[n]=si; MOTIVO[n]=''; PATRONES[n]=''
  if ! lee_campo_archivos "$texto"; then
    DECL[n]=no; MOTIVO[n]='no declara el campo `Archivos:` en su cabecera'
    n=$((n+1)); continue
  fi
  # La regla del paréntesis de evidencia, reutilizada —y aplicada DONDE VALE en un campo
  # de lista, que es después del último separador (ver más abajo, SEC-014):
  # `Archivos: a.sh, b.sh (medido 6/9)` declara dos archivos, no tres.
  _arnes_recorta_blancos "$ARNES_ARCH_CRUDO"
  arnes_desenvuelve "$ARNES_TRIM"
  crudo="$ARNES_DESENV"
  arnes_norm_campo "$crudo"; plano="$ARNES_CAMPO"
  case "$plano" in
    '(ninguno)'|ninguno)
      # Una declaración, no una omisión: un REQ que no toca el árbol no puede colisionar.
      PATRONES[n]='(ninguno)'; n=$((n+1)); continue ;;
    # El valor ENTERO es un marcador de posición. LA RED ES LA PROPIEDAD DE `norm_ruta`
    # (no existe, ningún ancestro suyo existe y no tiene forma de archivo), que ya
    # rechaza estas siete formas y también `n/d`, `s/d`, `n.a.` o `pendiente.` (QA-212).
    # Esta lista NO decide nada que la propiedad no decidiera: sólo cambia el MENSAJE por
    # uno que nombra lo que pasa —«es un marcador de posición»— en vez del genérico.
    # Por eso puede ser corta y es de verdad NO EXHAUSTIVA: lo que no esté aquí cae en la
    # propiedad, no se cuela. El criterio es «el autor declara que aún no lo sabe».
    'n/a'|'tbd'|'tba'|'pordefinir'|'pordeterminar'|'sindefinir'|'porver')
      DECL[n]=no
      MOTIVO[n]="«$plano» es un marcador de posición, no un mapa de archivos"
      n=$((n+1)); continue ;;
  esac
  _arnes_recorta_blancos "$crudo"; crudo="$ARNES_TRIM"
  if [ -z "$crudo" ]; then
    DECL[n]=no; MOTIVO[n]='el valor de `Archivos:` está vacío'
    n=$((n+1)); continue
  fi
  # SEC-014 — EL SEXTO FAIL-OPEN: LA REGLA DE UN VALOR ÚNICO APLICADA A UNA LISTA.
  # `arnes_veredicto` es la regla del paréntesis de UN veredicto: si el valor acaba en
  # `)`, corta en el PRIMER `(`. Aquí se aplicaba al valor ENTERO, así que
  # `Archivos: tools/x.sh (nuevo), hooks/lib.sh (modificado)` se quedaba en `tools/x.sh`
  # y el resto del mapa DESAPARECÍA antes de llegar a `norm_ruta`: sin motivo, sin bajar
  # el recuento y sin cambiar el código de salida — `disjunto`/rc 0 sobre un mapa que la
  # herramienta misma había truncado. Y la asimetría iba hacia el lado que ABRE: anotar
  # todos los elementos —lo prolijo, y lo que la plantilla enseña— abría; dejar el último
  # desnudo cerraba.
  #
  # LO QUE CAMBIA ES EL GRANO, NO LA FUNCIÓN (CA-03, reescrito por el analista a raíz de
  # este hallazgo): se separa la lista PRIMERO y la normalización compartida —incluida la
  # regla del paréntesis— se aplica A CADA ELEMENTO. La evidencia es del elemento que la
  # lleva, así que `tools/x.sh (nuevo)` declara `tools/x.sh` y nada se pierde. Sigue
  # siendo la misma función de `hooks/lib.sh`, envuelta en un bucle, que es exactamente la
  # salida que CA-03 deja escrita cuando la función de valor único no cabe en un campo de
  # lista.
  #
  # LA PROPIEDAD QUE MANDA, por encima de cualquier detalle de reutilización: ningún
  # elemento declarado desaparece nunca en silencio. Elementos evaluados = elementos
  # separados por comas, con paréntesis en cualquier posición; y el que no se entienda
  # manda el REQ a SIN DECLARAR con su motivo (CA-04, CA-11 ii, CA-13).
  #
  # EL SEPARADOR ES LA COMA QUE NO ESTÁ DENTRO DE UN PARÉNTESIS. La evidencia lleva comas
  # —`(medido el 6/9, 2 archivos)` es la forma que la plantilla enseña para todos los
  # campos—, así que partir por cualquier coma rompería la evidencia en dos y convertiría
  # su cola en un elemento que no es una ruta. La profundidad se lleva contando paréntesis
  # con expansión de parámetros, sin un solo proceso.
  elems=(); resto="$crudo"; buf=''
  while : ; do
    if case "$resto" in *,*) true ;; *) false ;; esac; then
      pieza="${resto%%,*}"; resto="${resto#*,}"; hay_mas=si
    else
      pieza="$resto"; resto=''; hay_mas=no
    fi
    buf+="$pieza"
    abre="${buf//[^(]/}"; cierra="${buf//[^)]/}"
    if [ "$hay_mas" = si ] && [ "${#abre}" -gt "${#cierra}" ]; then
      buf+=','; continue          # la coma era de la evidencia, no un separador
    fi
    [ -z "${buf//[[:blank:]]/}" ] || elems+=( "$buf" )
    buf=''
    [ "$hay_mas" = si ] || break
  done
  lista=''; malo=''
  for elem in ${elems[@]+"${elems[@]}"}; do
    # La regla del paréntesis, la compartida, sobre ESTE elemento.
    _arnes_recorta_blancos "$elem"
    arnes_veredicto "$ARNES_TRIM"
    _arnes_recorta_blancos "$ARNES_VEREDICTO"; elem="$ARNES_TRIM"
    # Un elemento que era SÓLO una anotación (`hooks/lib.sh, (medido 6/9)`) no declara
    # ninguna ruta. No se salta: se dice. Saltarlo sería exactamente el silencio que este
    # arreglo quita —y la lectura amable, «era evidencia del campo», es una suposición
    # sobre lo que el autor quiso decir, que es lo que un fail-closed no hace.
    if [ -z "$elem" ]; then
      malo='un elemento del valor es sólo una anotación entre paréntesis y no declara ninguna ruta (la evidencia acompaña a un elemento, no va suelta entre comas)'
      break
    fi
    if ! norm_ruta "$elem"; then malo="$MOTIVO_RUTA"; break; fi
    lista+="${lista:+ }$ARNES_RUTA"
    expande "$ARNES_RUTA"
    for r in "${EXPANSION[@]}"; do
      DUENOS[$r]="${DUENOS[$r]:-} $n "
      if [ -z "${VISTA[$r]:-}" ]; then
        VISTA[$r]=1; RUTAS+=( "$r" )
        # El archivo que TODAVÍA NO EXISTE se aparta aquí: es el único que no puede
        # encontrarse con nadie expandiendo contra el árbol, y es exactamente donde dos
        # comisiones chocan. Se resuelve abajo, contra el TEXTO de los patrones ajenos.
        [ -e "$r" ] || FUTUROS+=( "$r" )
      fi
    done
  done
  if [ -n "$malo" ]; then
    DECL[n]=no; MOTIVO[n]="$malo"
  elif [ -z "$lista" ]; then
    DECL[n]=no; MOTIVO[n]='el valor de `Archivos:` no contiene ninguna ruta legible'
  else
    PATRONES[n]="$lista"
  fi
  n=$((n+1))
done
N="$n"
[ "$N" -gt 0 ] || no_medido "no hay ningún REQ abierto que evaluar en $REQ_DIR/."

# --- El archivo que aún no existe, contra el TEXTO de los patrones ------------
# La expansión contra el árbol resuelve todo lo demás, y no puede resolver esto: un
# archivo que nadie ha creado no lo devuelve ningún glob, así que `hooks/post-bash.sh`
# y `hooks/*.sh` salían disjuntos —y `tools/nuevo.sh` con `tools/` también—, que es el
# falso negativo más caro que esta herramienta puede producir: el choque ocurre justo
# en el archivo que una de las dos comisiones va a crear.
#
# Se compara el literal futuro contra el patrón AJENO tal como está escrito, con el
# mismo motor de patrones de bash (`[[ == ]]`): casa el glob (`hooks/*.sh`) y también
# la contención por directorio (`tools` alcanza `tools/nuevo.sh`), que es la misma
# regla que ya aplica `expande` a los directorios que sí existen.
#
# Sólo se paga cuando hay algún literal futuro: con el árbol completo declarado, este
# bucle no se ejecuta ni una vez.
if [ "${#FUTUROS[@]}" -gt 0 ]; then
  # `set -f` porque los patrones viajan en una cadena separada por blancos y hay que
  # partirla SIN que bash los expanda contra el árbol al hacerlo.
  set -f
  for r in "${FUTUROS[@]}"; do
    for ((a = 0; a < N; a++)); do
      [ "${DECL[a]}" = si ] || continue
      case " ${DUENOS[$r]:-} " in *" $a "*) continue ;; esac
      for pat in ${PATRONES[a]}; do
        [ "$pat" != '(ninguno)' ] || continue
        if [[ $r == $pat || $r == $pat/* ]]; then
          DUENOS[$r]="${DUENOS[$r]:-} $a "
          break
        fi
      done
    done
  done
  set +f
fi

# --- Intersección -------------------------------------------------------------
# Una sola pasada por las rutas: cada una sabe qué REQ la reclaman, así que el archivo
# compartido de un par sale directamente en vez de comparar todos contra todos.
#
# LA CLAVE DEL PAR SE ORDENA AL ESCRIBIRLA, y no es cosmético: es la mitad que faltaba
# del arreglo de QA-202. Aquí se escribía `${d[a]}|${d[b]}` dando por hecho que los
# dueños de una ruta venían en orden creciente —cierto para las rutas que se expanden
# contra el árbol, porque el bucle de REQ va de 0 a N-1—, y la pasada de los FUTUROS
# añade dueños FUERA DE ORDEN: con el glob en el índice 0 y el archivo futuro en el 2,
# `DUENOS` queda " 2  0 ", se escribía la clave "2|0" y el bucle de salida buscaba
# "0|2". Resultado medido: `hooks/post-bash.sh` vs `hooks/*.sh` colisionaba en un orden
# y salía `disjunto`/rc 0 en el contrario. El par {a,b} es el mismo par se mire por
# donde se mire, así que su clave no puede depender del orden en que se descubrió.
declare -A CHOQUE=()
for r in "${RUTAS[@]}"; do
  d=(${DUENOS[$r]})
  [ "${#d[@]}" -ge 2 ] || continue
  for ((a = 0; a < ${#d[@]}; a++)); do
    for ((b = a + 1; b < ${#d[@]}; b++)); do
      [ "${d[a]}" != "${d[b]}" ] || continue
      if [ "${d[a]}" -lt "${d[b]}" ]; then k="${d[a]}|${d[b]}"; else k="${d[b]}|${d[a]}"; fi
      [ -n "${CHOQUE[$k]:-}" ] || CHOQUE[$k]="$r"
    done
  done
done


# --- Salida -------------------------------------------------------------------
# La advertencia sale SIEMPRE, en texto y en JSON. Sin ella, un `disjunto` se lee como
# permiso para lanzar QA y el auditor a la vez, que es exactamente el fallo que la regla
# del orden de fases existe para evitar.
ADVERTENCIA='Esta herramienta evalúa ARCHIVOS y NO el orden de fases: un «disjunto» no autoriza a correr el auditor-seguridad a la vez que el qa-tester, ni el qa-tester antes que el desarrollador. Esa regla es aparte, vive en AGENTS.md §6 y esta herramienta no la comprueba.'

# Escape de JSON SIN PROCESOS y sin `$( )`: deja el resultado en JSTR en vez de
# imprimirlo. Una sustitución de comandos bifurca un subshell, y con 60 REQ son 1 770
# pares — tres forks por par serían miles de forks a cambio de nada (en Windows cada uno
# cuesta entre 1,2 y 6 s).
#
# SEC-018 — Y NO SÓLO `\` Y `"`. El comentario anterior decía «sólo `\` y `"` pueden
# aparecer en una ruta ya validada»: cierto para los patrones que llegan al final, y
# falso para los MOTIVOS —que citan el elemento crudo tal como se escribió— y para las
# rutas que no pasan por el filtro de blancos (un tabulador vertical no es `[:blank:]`).
# Medido: `Archivos: /tmp/a<TAB>b.sh` producía una salida que `jq` rechaza («Invalid
# string: control characters from U+0000 through U+001F must be escaped»), y con
# `tools/a<VT>b.sh` el JSON inválido salía además con rc 0. `--json` es justo el modo que
# consume una máquina, y un consumidor que no falle cerrado convierte esto en fail-open.
#
# El coste se paga SÓLO cuando los hay: la clase se comprueba con una expansión de
# patrón —sin proceso— y el bucle por carácter no se ejecuta en el camino normal.
JSTR=''
jstr() {
  local s="${1//\\/\\\\}"; s="${s//\"/\\\"}"
  case "$s" in
    *[[:cntrl:]]*)
      local out='' c i
      for ((i = 0; i < ${#s}; i++)); do
        c="${s:i:1}"
        case "$c" in
          [[:cntrl:]])
            case "$c" in
              $'\n') out+='\n' ;;
              $'\t') out+='\t' ;;
              $'\r') out+='\r' ;;
              $'\b') out+='\b' ;;
              $'\f') out+='\f' ;;
              # Cualquier otro control va en su forma `\uXXXX`, que es la que el propio
              # JSON define para lo que no tiene atajo. `printf -v` no bifurca.
              *) printf -v c '\\u%04x' "'$c"; out+="$c" ;;
            esac ;;
          *) out+="$c" ;;
        esac
      done
      s="$out" ;;
  esac
  JSTR="\"$s\""
}

RC=0
for ((a = 0; a < N; a++)); do [ "${DECL[a]}" = si ] || RC=1; done

PARES_TXT=''; PARES_JSON=''
for ((a = 0; a < N; a++)); do
  for ((b = a + 1; b < N; b++)); do
    k="$a|$b"
    if [ "${DECL[a]}" = no ] || [ "${DECL[b]}" = no ]; then
      # Sin mapa no hay paralelismo: un REQ que no declara colisiona con TODOS.
      v=colisiona; comp='(sin declarar)'; RC=1
    elif [ -n "${CHOQUE[$k]:-}" ]; then
      v=colisiona; comp="${CHOQUE[$k]}"; RC=1
    else
      v=disjunto; comp=''
    fi
    printf -v linea '  %-10s vs %-10s  %-10s %s\n' "${ID[a]}" "${ID[b]}" "$v" "$comp"
    PARES_TXT+="$linea"
    if [ "$JSON" = si ]; then
      jstr "${ID[a]}"; par="{\"a\":$JSTR"
      jstr "${ID[b]}"; par+=",\"b\":$JSTR,\"veredicto\":\"$v\",\"compartido\":"
      if [ -n "$comp" ] && [ "$comp" != '(sin declarar)' ]; then jstr "$comp"; par+="$JSTR}"
      else par+='null}'; fi
      PARES_JSON+="${PARES_JSON:+,}$par"
    fi
  done
done

if [ "$JSON" = si ]; then
  REQ_JSON=''
  for ((a = 0; a < N; a++)); do
    arr=''
    if [ "${DECL[a]}" = si ] && [ "${PATRONES[a]}" != '(ninguno)' ]; then
      # `set -f` al partir la cadena de patrones: sin él, `hooks/*.sh` se expandía
      # contra el árbol AL LEERLO y el JSON declaraba los archivos casados mientras el
      # texto declaraba el patrón. La misma respuesta contada de dos maneras (CA-06).
      set -f
      for pat in ${PATRONES[a]}; do jstr "$pat"; arr+="${arr:+,}$JSTR"; done
      set +f
    fi
    jstr "${ID[a]}";     uno="{\"id\":$JSTR"
    jstr "${ESTADO[a]}"; uno+=",\"estado\":$JSTR,\"declarado\":"
    if [ "${DECL[a]}" = si ]; then uno+='true'; else uno+='false'; fi
    uno+=",\"archivos\":[$arr],\"motivo\":"
    if [ -n "${MOTIVO[a]}" ]; then jstr "${MOTIVO[a]}"; uno+="$JSTR}"; else uno+='null}'; fi
    REQ_JSON+="${REQ_JSON:+,}$uno"
  done
  jstr "$ADVERTENCIA"; adv="$JSTR"
  if [ "$RC" -eq 0 ]; then res='"disjunto"'; else res='"colisiona"'; fi
  printf '{"advertencia":%s,"requerimientos":[%s],"pares":[%s],"resultado":%s}\n' \
    "$adv" "$REQ_JSON" "$PARES_JSON" "$res"
  exit "$RC"
fi

printf 'Paralelismo por archivos — %s/ (%s REQ evaluados)\n\n' "$REQ_DIR" "$N"
for ((a = 0; a < N; a++)); do
  if [ "${DECL[a]}" = si ]; then
    printf '  %-10s %-13s %s\n' "${ID[a]}" "${ESTADO[a]}" "${PATRONES[a]}"
  else
    printf '  %-10s %-13s SIN DECLARAR: %s\n' "${ID[a]}" "${ESTADO[a]}" "${MOTIVO[a]}"
    printf '  %-10s %-13s (colisiona con todos: una herramienta que no puede medir no autoriza)\n' '' ''
  fi
done
printf '\n%s\n' "$PARES_TXT"
if [ "$RC" -eq 0 ]; then
  printf 'Todos los pares son DISJUNTOS por archivos.\n'
else
  printf 'Hay pares que COLISIONAN: esas comisiones van en serie.\n'
fi
printf '\n%s\n' "$ADVERTENCIA"
exit "$RC"
