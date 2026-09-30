# Sección 35 del banco — 35-arnes-paralelo-fail-open (REQ-013, hallazgos de QA de 1.32.0)
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
#
# QUÉ ACREDITA: los cuatro fail-open que QA midió en la vuelta 1 de 1.32.0 sobre
# `tools/arnes-paralelo.sh` (QA-201 a QA-204). Los cuatro son la MISMA clase — la
# herramienta respondía `disjunto` con rc 0 cuando NO PODÍA SABERLO —, y el arnés ya
# tenía la regla decidida para la cola de aprobaciones: lo que no se puede leer entero
# no se descarta, se declara, y una herramienta que no midió no responde «adelante».
#
# POR QUÉ EN OTRO ARCHIVO Y NO AL FINAL DE LA 34: la 34 llegaba a 444 líneas con estos
# casos dentro, y ningún archivo de sección pasa de 400 (CA-18 de REQ-014). Se parte por
# tema, como la 28, y no se renombra la 34: el nombre está declarado en el mapa de
# archivos de REQ-013.
#
# VUELTA 2 (QA-211, QA-212 y la simetría de QA-202): los tres fail-open que quedaban, y
# el defecto de MÉTODO que los tapaba — los dos casos de QA-202 estaban escritos sólo en
# la dirección que pasaba, así que acreditaban la mitad que ya funcionaba.
#
# AUDITORÍA R-004 (SEC-014 y SEC-018): el sexto fail-open —un paréntesis INTERMEDIO
# borraba la cola del mapa y la respuesta era `disjunto`/rc 0— y el `--json` que emitía
# JSON inválido con caracteres de control. Los dos al final del archivo.
#
# FAIL-BEFORE: con `ARNES_HOOKS_DIR` apuntando a un árbol cuya `tools/arnes-paralelo.sh`
# es la de antes de cada arreglo, fallan los casos que acreditan el arreglo y pasan los
# CONTROLES POSITIVOS, que tienen que pasar antes y después: si fallaran, el arreglo
# estaría haciendo colisionar a todo el mundo con todo el mundo, que también es no medir.
# Medido contra la herramienta de la vuelta 1: 9 de 10 fallan. Contra la de la vuelta 2:
# 6 de 19 fallan (los 6 nuevos), y los 3 controles pasan en las dos. Contra la que auditó
# R-004: fallan los 5 nuevos (3 de SEC-014 y 2 de SEC-018) y pasan los 2 controles nuevos.
CASOS_ESPERADOS_SECCION=26
PISO_AUTONOMO_SECCION=171  # 35 preámbulo + 79 maquinaria compartida duplicada + 57 bloque indivisible mayor · REQ-014 CA-18

seccion_nueva "tools/arnes-paralelo.sh: lo que no se puede medir no autoriza nada:"

PARA="$HOOKS_DIR/../tools/arnes-paralelo.sh"

mkdir -p "$PROJ/hooks" "$PROJ/tools" "$PROJ/docs/gobernanza"
for a in hooks/lib.sh hooks/guard-codigo.sh hooks/hooks.json tools/arnes-lectura.sh \
         docs/gobernanza/x.md; do
  : > "$PROJ/$a"
done

# pr <id> <valor del campo Archivos:> — un REQ abierto con su mapa declarado.
pr() { printf '# %s\nEstado: pendiente\nArchivos: %s\n\n## Historia\ncuerpo\n' "$1" "$2" \
         > "$PROJ/requirements/$1.md"; }

# par_check — DUPLICADO a propósito desde `34-arnes-paralelo.sh`: un archivo de sección
# no hace `source` de otro (invariante 4 del README del banco), y copiar veinte líneas
# cuesta menos que abrir una puerta trasera entre secciones.
# GUARDA DE SALIDA VACÍA (invariante 1): una herramienta muda no es un caso que pasa, es
# un caso que no se ejecutó. Los modos degradados hablan por stderr, así que se mira
# también ahí antes de declarar el silencio.
par_check() {
  local nombre="$1" rc_esp="$2" patron="$3"; shift 3
  local out rc
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  : > "$ERRLOG"
  out="$(bash "$PARA" --proyecto "$PROJ" "$@" 2>"$ERRLOG")"; rc=$?
  [ -n "$out" ] || out="$(cat "$ERRLOG")"
  if [ -z "$out" ]; then
    echo "  FAIL  $nombre  la herramienta no imprimio NADA: el caso no midio nada"
    FAIL=$((FAIL+1)); return 0
  fi
  if [ "$rc" != "$rc_esp" ]; then
    echo "  FAIL  $nombre  rc=$rc (esperado $rc_esp)"; diag
    printf '%s\n' "$out" | head -8 | sed 's/^/          salida| /'; FAIL=$((FAIL+1)); return 0
  fi
  if ! printf '%s' "$out" | grep -Eq -- "$patron"; then
    echo "  FAIL  $nombre  la salida no casa /$patron/"
    printf '%s\n' "$out" | head -8 | sed 's/^/          salida| /'; FAIL=$((FAIL+1)); return 0
  fi
  echo "  PASS  $nombre"; PASS=$((PASS+1))
}

# El REQ de referencia contra el que se comparan los casos de abajo.
pr REQ-760 'hooks/lib.sh'

# --- QA-201 · un REQ que no se puede leer ENTERO no desaparece del análisis.
# Antes: `IFS= read -r -d '' texto < "$f" || :` se tragaba el fallo de lectura, el REQ se
# caía de la lista sin una palabra y `3 REQ evaluados / colisiona / rc 1` se convertía en
# `2 REQ evaluados / todos disjuntos / rc 0`.
if [ -z "$FILTRO" ] || printf '%s' "paralelo: ilegible" | grep -qi -- "$FILTRO"; then
  ilg="$RAIZ/ilegible-$BASHPID"; mkdir -p "$ilg/.arnes" "$ilg/requirements" "$ilg/hooks" "$ilg/docs"
  cp "$PROJ/.arnes/config.json" "$ilg/.arnes/config.json"
  : > "$ilg/hooks/lib.sh"; : > "$ilg/docs/otro.md"
  printf '# REQ-801\nEstado: pendiente\nArchivos: hooks/lib.sh\n\n## H\n' > "$ilg/requirements/REQ-801.md"
  printf '# REQ-802\nEstado: pendiente\nArchivos: docs/otro.md\n\n## H\n'  > "$ilg/requirements/REQ-802.md"
  printf '# REQ-803\nEstado: pendiente\nArchivos: hooks/lib.sh\n\n## H\n' > "$ilg/requirements/REQ-803.md"
  chmod 000 "$ilg/requirements/REQ-803.md"
  if [ -r "$ilg/requirements/REQ-803.md" ]; then
    # Como root todo es legible: el caso no puede medir lo que dice medir, y un caso que
    # no mide no se cuenta como verde.
    echo "  SKIP  paralelo: un REQ SIN PERMISO de lectura no desaparece  (corriendo como root: todo es legible)"
    echo "  SKIP  paralelo: el recuento de REQ evaluados no baja en silencio  (corriendo como root: todo es legible)"
  else
    salida="$(bash "$PARA" --proyecto "$ilg" 2>"$ERRLOG")"; rc=$?
    if [ -z "$salida" ]; then
      echo "  FAIL  paralelo: un REQ SIN PERMISO de lectura  la herramienta no imprimio NADA"; diag; FAIL=$((FAIL+1))
      echo "  FAIL  paralelo: ...y por lo mismo el recuento no midio nada"; FAIL=$((FAIL+1))
    else
      if [ "$rc" -eq 1 ] && printf '%s' "$salida" | grep -Eq 'REQ-803.*SIN DECLARAR.*permisos'; then
        echo "  PASS  paralelo: un REQ SIN PERMISO de lectura se declara y colisiona con todos"; PASS=$((PASS+1))
      else
        echo "  FAIL  paralelo: un REQ SIN PERMISO de lectura  rc=$rc (esperado 1), no lo declara"
        printf '%s\n' "$salida" | head -8 | sed 's/^/          salida| /'; FAIL=$((FAIL+1))
      fi
      if printf '%s' "$salida" | grep -q '3 REQ evaluados'; then
        echo "  PASS  paralelo: el recuento de REQ evaluados no baja en silencio"; PASS=$((PASS+1))
      else
        echo "  FAIL  paralelo: el recuento bajo sin decirlo (la poblacion evaluada se encogio)"
        printf '%s\n' "$salida" | head -3 | sed 's/^/          salida| /'; FAIL=$((FAIL+1))
      fi
    fi
  fi
  chmod 644 "$ilg/requirements/REQ-803.md"
fi
# QA-201, variante B: un byte NUL en banda corta `read -d ''` antes de la cabecera y el
# REQ se queda sin `Estado:` — descartado por «no es un REQ, es una nota». Bytes de
# control en banda es una familia de evasión ya catalogada (REQ-007).
if [ -z "$FILTRO" ] || printf '%s' "paralelo: byte NUL" | grep -qi -- "$FILTRO"; then
  nul="$RAIZ/nul-$BASHPID"; mkdir -p "$nul/.arnes" "$nul/requirements" "$nul/hooks"
  cp "$PROJ/.arnes/config.json" "$nul/.arnes/config.json"; : > "$nul/hooks/lib.sh"
  printf '# REQ-804\nEstado: pendiente\nArchivos: hooks/lib.sh\n\n## H\n' > "$nul/requirements/REQ-804.md"
  printf '# REQ-805\n\000\nEstado: pendiente\nArchivos: hooks/lib.sh\n\n## H\n' > "$nul/requirements/REQ-805.md"
  salida="$(bash "$PARA" --proyecto "$nul" 2>"$ERRLOG")"; rc=$?
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: byte NUL  la herramienta no imprimio NADA"; diag; FAIL=$((FAIL+1))
  elif [ "$rc" -eq 1 ] && printf '%s' "$salida" | grep -Eq 'REQ-805.*SIN DECLARAR.*NUL'; then
    echo "  PASS  paralelo: un REQ truncado por un byte NUL se declara, no se descarta"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: byte NUL  rc=$rc (esperado 1), no lo declara"
    printf '%s\n' "$salida" | head -6 | sed 's/^/          salida| /'; FAIL=$((FAIL+1))
  fi
fi

# --- QA-202 · el archivo que TODAVÍA NO EXISTE, contra el glob y contra el directorio
# que lo contendrá. El caso 34 comparaba literal contra literal —los dos REQ declaraban
# la MISMA ruta—, así que probaba igualdad de cadenas y no lo que CA-08 promete. Aquí las
# dos declaraciones son DISTINTAS, que es donde fallaba.
pr REQ-750 'hooks/post-bash.sh'
pr REQ-751 'hooks/*.sh'
par_check "paralelo: un archivo que AUN NO EXISTE colisiona con el glob que lo alcanzara" 1 \
  'REQ-750 +vs +REQ-751 +colisiona +hooks/post-bash\.sh' REQ-750 REQ-751
pr REQ-752 'tools/nuevo.sh'
pr REQ-753 'tools/'
par_check "paralelo: un archivo que AUN NO EXISTE colisiona con el DIRECTORIO que lo contendra" 1 \
  'REQ-752 +vs +REQ-753 +colisiona +tools/nuevo\.sh' REQ-752 REQ-753
# CONTROL: la regla no puede hacer colisionar a todo el mundo con todo el mundo. Este
# caso pasa antes y después del arreglo, y por eso está.
pr REQ-754 'docs/gobernanza/nuevo.md'
par_check "paralelo: control, un archivo futuro AJENO al glob sigue siendo disjunto" 0 \
  'REQ-754 +vs +REQ-751 +disjunto' REQ-754 REQ-751

# --- QA-202, vuelta 2: LOS TRES DE ARRIBA ESTABAN ESCRITOS EN UNA SOLA DIRECCIÓN, y el
# arreglo sólo funcionaba en ésa. «Colisionar» es una relación SIMÉTRICA: el par {A,B} es
# el mismo par se mire por donde se mire. La primera versión del arreglo daba `colisiona`
# con el archivo futuro en el índice bajo y `disjunto`/rc 0 con el futuro en el índice
# alto —la clave del par se escribía "2|0" y se buscaba "0|2"—, y los casos de arriba no
# lo vieron porque probaban la mitad que funcionaba. Un guardián que ejercita una sola
# dirección de una relación simétrica acredita la mitad que ya andaba.
#
# EL ARREGLO DEL MÉTODO, no del caso: en vez de duplicar cada par a mano —que es
# enumerar, y se olvida uno— la simetría se comprueba POR PROPIEDAD. `sim_check` corre el
# mismo par en los DOS órdenes y exige (a) el veredicto declarado y (b) que las dos
# direcciones digan lo mismo, veredicto y código de salida. Un caso nuevo aquí cubre las
# dos direcciones sin que nadie tenga que acordarse.
# GUARDA DE SALIDA VACÍA (invariante 1): se mira que las dos corridas dijeran algo.
sim_check() {   # <nombre> <colisiona|disjunto> <Archivos: de A> <Archivos: de B>
  local nombre="$1" esperado="$2" va="$3" vb="$4"
  local ida vuelta rc_ida rc_vuelta v_ida v_vuelta rc_esp=1
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  [ "$esperado" != disjunto ] || rc_esp=0
  pr REQ-770 "$va"; pr REQ-771 "$vb"
  ida="$(bash "$PARA" --proyecto "$PROJ" REQ-770 REQ-771 2>"$ERRLOG")"; rc_ida=$?
  vuelta="$(bash "$PARA" --proyecto "$PROJ" REQ-771 REQ-770 2>"$ERRLOG")"; rc_vuelta=$?
  if [ -z "$ida" ] || [ -z "$vuelta" ]; then
    echo "  FAIL  $nombre  la herramienta no imprimio NADA en alguna de las dos direcciones"
    diag; FAIL=$((FAIL+1)); return 0
  fi
  v_ida="$(printf '%s' "$ida" | grep -Eo 'colisiona|disjunto' | head -1)"
  v_vuelta="$(printf '%s' "$vuelta" | grep -Eo 'colisiona|disjunto' | head -1)"
  if [ "$v_ida-$rc_ida" != "$esperado-$rc_esp" ]; then
    echo "  FAIL  $nombre  ida: $v_ida/rc$rc_ida (esperado $esperado/rc$rc_esp)"
    printf '%s\n' "$ida" | head -6 | sed 's/^/          salida| /'; FAIL=$((FAIL+1)); return 0
  fi
  if [ "$v_vuelta-$rc_vuelta" != "$esperado-$rc_esp" ]; then
    echo "  FAIL  $nombre  VUELTA (orden invertido): $v_vuelta/rc$rc_vuelta (esperado $esperado/rc$rc_esp)"
    printf '%s\n' "$vuelta" | head -6 | sed 's/^/          salida| /'; FAIL=$((FAIL+1)); return 0
  fi
  echo "  PASS  $nombre"; PASS=$((PASS+1))
}
sim_check "paralelo: SIMETRIA, archivo futuro y glob colisionan en los DOS ordenes" \
  colisiona 'hooks/post-bash.sh' 'hooks/*.sh'
sim_check "paralelo: SIMETRIA, archivo futuro y su DIRECTORIO colisionan en los DOS ordenes" \
  colisiona 'tools/nuevo.sh' 'tools/'
# CONTROL, también en las dos direcciones: si el arreglo hiciera colisionar a todos con
# todos, este caso lo delata — y lo delata igual se declare en el orden que se declare.
sim_check "paralelo: SIMETRIA control, un futuro AJENO al glob es disjunto en los DOS ordenes" \
  disjunto 'docs/gobernanza/nuevo.md' 'hooks/*.sh'
rm -f "$PROJ/requirements/REQ-770.md" "$PROJ/requirements/REQ-771.md"

# --- QA-203 · un marcador de posición NO es una ruta futura. Es el caso en que el autor
# del REQ todavía no sabe qué va a tocar: el que menos puede responder «adelante».
pr REQ-755 'TBD'
par_check "paralelo: un marcador de posicion (TBD) no se acepta como ruta futura" 1 \
  'REQ-755.*SIN DECLARAR' REQ-755 REQ-760
pr REQ-756 'N/A'
par_check "paralelo: y tampoco el que TIENE forma de ruta por accidente (N/A)" 1 \
  'REQ-756.*SIN DECLARAR.*marcador de posici' REQ-756 REQ-760

# --- QA-204 · `Archivos:` duplicado: gana el ÚLTIMO, como en `arnes_campos_req`. Dos
# lectores del mismo campo con precedencias distintas es la copia que CA-03 prohíbe, y
# divergía hacia el lado que abre.
{ printf '# REQ-757\nEstado: pendiente\n'
  printf 'Archivos: (ninguno)\nArchivos: hooks/lib.sh\n'
  printf '\n## Historia\ncuerpo\n'; } > "$PROJ/requirements/REQ-757.md"
par_check "paralelo: con Archivos: duplicado gana el ULTIMO, igual que en las puertas" 1 \
  'REQ-757 +vs +REQ-760 +colisiona +hooks/lib\.sh' REQ-757 REQ-760

# --- CA-06, la otra mitad: «dice LO MISMO que el texto». El texto imprime el PATRÓN
# declarado y el JSON imprimía los archivos que ese patrón casa hoy, porque la cadena de
# patrones se partía sin desactivar el globbing y bash la expandía al leerla.
if [ -z "$FILTRO" ] || printf '%s' "paralelo: json patron" | grep -qi -- "$FILTRO"; then
  : > "$ERRLOG"
  salida="$(bash "$PARA" --proyecto "$PROJ" --json REQ-751 REQ-760 2>"$ERRLOG")"
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: json patron  la herramienta no imprimio NADA"; diag; FAIL=$((FAIL+1))
  elif printf '%s' "$salida" | jq -e '.requerimientos[0].archivos == ["hooks/*.sh"]' >/dev/null 2>&1; then
    echo "  PASS  paralelo: --json declara el PATRON, no los archivos que casa hoy"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: --json expandio el patron y dice algo distinto que el texto"
    # `head -c 300` corta por BYTES y puede dejar la última línea sin `\n`: entonces el
    # `  PASS ` siguiente se pega a ésta y el recuento por archivo pierde un caso —
    # medido en el fail-before de esta misma vuelta (43 declarados, 42 contados).
    printf '%s\n' "${salida:0:300}" | sed 's/^/          salida| /'; FAIL=$((FAIL+1))
  fi
fi

# --- QA-211 · EL QUINTO FAIL-OPEN, y la misma clase que los cuatro de la vuelta 1: la
# población evaluada se encogía SIN DECIRLO. Un REQ del que no se extrae `Estado:` de la
# cabecera —los campos debajo del primer `## `, un REQ a medio redactar, un archivo de 0
# bytes— caía de la lista con un `continue` mudo en el modo SIN ARGUMENTOS: el recuento
# bajaba de 3 a 2, no había línea de motivo, y `colisiona`/rc 1 pasaba a `disjunto`/rc 0.
# La herramienta se contradecía consigo misma: el MISMO archivo, pasado como argumento
# explícito, sí se evaluaba y sí colisionaba.
#
# El modo sin argumentos es el que usa CA-01 para verificarse y el que la coordinadora
# ejecuta al despachar, así que es justo donde no puede decir «adelante» sin haber mirado.
# par_proy <nombre> <dir del proyecto> <rc esperado> <regex que DEBE casar> <regex que NO debe aparecer>
# La herramienta SIN argumentos, que es el modo donde vivía el agujero.
par_proy() {
  local nombre="$1" dir="$2" rc_esp="$3" debe="$4" nodebe="$5" out rc
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  : > "$ERRLOG"
  out="$(bash "$PARA" --proyecto "$dir" 2>"$ERRLOG")"; rc=$?
  [ -n "$out" ] || out="$(cat "$ERRLOG")"
  if [ -z "$out" ]; then
    echo "  FAIL  $nombre  la herramienta no imprimio NADA: el caso no midio nada"
    FAIL=$((FAIL+1)); return 0
  fi
  if [ "$rc" != "$rc_esp" ]; then
    echo "  FAIL  $nombre  rc=$rc (esperado $rc_esp)"
    printf '%s\n' "$out" | head -8 | sed 's/^/          salida| /'; FAIL=$((FAIL+1)); return 0
  fi
  if ! printf '%s' "$out" | grep -Eq -- "$debe"; then
    echo "  FAIL  $nombre  la salida no casa /$debe/"
    printf '%s\n' "$out" | head -8 | sed 's/^/          salida| /'; FAIL=$((FAIL+1)); return 0
  fi
  if printf '%s' "$out" | grep -Eq -- "$nodebe"; then
    echo "  FAIL  $nombre  la salida dice /$nodebe/ sin haber podido medir"
    printf '%s\n' "$out" | head -8 | sed 's/^/          salida| /'; FAIL=$((FAIL+1)); return 0
  fi
  echo "  PASS  $nombre"; PASS=$((PASS+1))
}

# proy211 <sufijo> — proyecto de 3 REQ donde el tercero se escribe fuera, según la
# variante que se quiera medir. REQ-A y REQ-C declaran el MISMO archivo: si REQ-C
# desaparece, el veredicto pasa de `colisiona` a `disjunto`.
proy211() {
  Q211="$RAIZ/qa211-$BASHPID-$1"
  mkdir -p "$Q211/.arnes" "$Q211/requirements" "$Q211/hooks" "$Q211/tools"
  cp "$PROJ/.arnes/config.json" "$Q211/.arnes/config.json"
  : > "$Q211/hooks/lib.sh"; : > "$Q211/tools/arnes-lectura.sh"
  printf '# REQ-A\nEstado: pendiente\nArchivos: hooks/lib.sh\n\n## H\n' > "$Q211/requirements/REQ-A.md"
  printf '# REQ-B\nEstado: pendiente\nArchivos: tools/arnes-lectura.sh\n\n## H\n' > "$Q211/requirements/REQ-B.md"
}
# Control: con los tres bien escritos, colisiona. Sin él, los casos de abajo podrían
# pasar por un proyecto mal montado en vez de por el arreglo.
proy211 control
printf '# REQ-C\nEstado: pendiente\nArchivos: hooks/lib.sh\n\n## H\n' > "$Q211/requirements/REQ-C.md"
par_proy "paralelo: control de QA-211, tres REQ bien escritos -> 3 evaluados y colisiona" "$Q211" 1 \
  'REQ-A +vs +REQ-C +colisiona +hooks/lib\.sh' 'Todos los pares son DISJUNTOS'
proy211 cabecera
printf '# REQ-C\nArchivos: hooks/lib.sh\n\n## Cabecera\nEstado: pendiente\n' > "$Q211/requirements/REQ-C.md"
par_proy "paralelo: un REQ con los campos DEBAJO del primer ## no desaparece en silencio" "$Q211" 1 \
  'REQ-C.*SIN DECLARAR.*Estado' 'Todos los pares son DISJUNTOS'
proy211 sinestado
printf '# REQ-C\nArchivos: hooks/lib.sh\n\n## H\n' > "$Q211/requirements/REQ-C.md"
par_proy "paralelo: un REQ SIN Estado: no encoge la poblacion evaluada (siguen siendo 3)" "$Q211" 1 \
  '3 REQ evaluados' 'Todos los pares son DISJUNTOS'
proy211 vacio
: > "$Q211/requirements/REQ-C.md"
par_proy "paralelo: un REQ de 0 bytes se declara con motivo, no se descarta" "$Q211" 1 \
  'REQ-C.*SIN DECLARAR' 'Todos los pares son DISJUNTOS'

# --- QA-212 · residuo de QA-203: la lista de marcadores era cerrada en el código, así que
# `n/d` y `s/d` —los equivalentes castellanos de `n/a` en un proyecto que documenta en
# español— pasaban como ruta futura. El arreglo no es alargar la lista: es enunciar la
# propiedad. Un elemento que no existe, del que NINGÚN directorio suyo existe y que no
# tiene forma de archivo (extensión con nombre a la izquierda y sufijo no vacío) no
# designa nada.
pr REQ-758 'n/d'
par_check "paralelo: un marcador con barra (n/d) tampoco se acepta como ruta futura" 1 \
  'REQ-758.*SIN DECLARAR.*no designa nada' REQ-758 REQ-760
# CONTROL de la propiedad, en la dirección contraria: un archivo futuro en un directorio
# que TAMPOCO existe todavía es una ruta legítima y no puede caer en la red. Sin este
# control, el arreglo podría estar rechazando mapas correctos.
pr REQ-759 'carpeta-nueva/sub/archivo.sh'
par_check "paralelo: control, un futuro en un directorio que aun no existe SI es ruta" 0 \
  'REQ-759 +vs +REQ-760 +disjunto' REQ-759 REQ-760

# --- SEC-014 · EL SEXTO FAIL-OPEN, Y EL PEOR: un paréntesis INTERMEDIO borraba la cola
# del mapa. `Archivos:` es un campo de LISTA y se le aplicaba `arnes_veredicto`, que es la
# regla de un valor ÚNICO —si acaba en `)`, corta en el PRIMER `(`—, así que
# `tools/x.sh (nuevo), hooks/lib.sh (modificado)` se quedaba en `tools/x.sh` y todo lo
# demás desaparecía ANTES de llegar a `norm_ruta`: sin motivo, sin bajar el recuento y con
# `disjunto`/rc 0. Y la asimetría iba hacia el lado que ABRE: anotar todos los elementos
# —lo prolijo, y lo que la plantilla enseña— abría el mapa; dejar el último desnudo lo
# cerraba.
#
# CA-03 (reescrito por el analista a raíz del hallazgo) fija el grano: la normalización
# compartida se aplica ELEMENTO A ELEMENTO, así que la evidencia es del elemento que la
# lleva y NINGÚN elemento declarado desaparece. Se prueba con `sim_check` porque
# «colisiona» es simétrico y los casos escritos en una sola dirección ya acreditaron una
# vez la mitad que funcionaba (QA-202, vuelta 2).
sim_check "paralelo/SEC-014: anotar CADA elemento no borra la cola del mapa (los DOS ordenes)" \
  colisiona 'tools/arnes-lectura.sh (nuevo), hooks/lib.sh (modificado)' 'hooks/lib.sh'
# LA PROPIEDAD, no el caso: elementos evaluados = elementos separados por comas. El
# veredicto de arriba podría salir bien por el camino equivocado —declarando el REQ
# ilegible—, y entonces la herramienta acertaría sin haber leído el mapa. Aquí se mira el
# MAPA que usa: los dos archivos, en el orden declarado, y nada más en la línea.
pr REQ-761 'tools/arnes-lectura.sh (nuevo), hooks/lib.sh (modificado)'
par_check "paralelo/SEC-014: los DOS elementos anotados llegan al mapa, ninguno se pierde" 1 \
  'REQ-761 +pendiente +tools/arnes-lectura\.sh hooks/lib\.sh$' REQ-761 REQ-760
# Y lo que no es un elemento tampoco se traga en silencio: una anotación suelta entre
# comas no declara ninguna ruta, así que se DICE y el REQ colisiona con todos. La lectura
# amable —«sería evidencia del campo»— es una suposición sobre lo que el autor quiso
# decir, y un fail-closed no supone.
pr REQ-762 'hooks/lib.sh, (medido el 6/9)'
par_check "paralelo/SEC-014: una anotacion SUELTA entre comas se declara, no se descarta" 1 \
  'REQ-762.*SIN DECLARAR.*s.lo una anotaci' REQ-762 REQ-760
# CONTROLES, en las dos direcciones, y los dos pasan ANTES y DESPUÉS: si fallaran, el
# arreglo estaría rechazando mapas correctos o colisionando a todos con todos, que también
# es no medir. El primero fija además que la coma DE DENTRO de la evidencia no es un
# separador —`(medido el 6/9, 2 archivos)` es la forma que la plantilla enseña—.
sim_check "paralelo/SEC-014 control: la coma DENTRO de la evidencia no parte la lista" \
  colisiona 'hooks/lib.sh, tools/arnes-lectura.sh (medido el 6/9, 2 archivos)' 'tools/arnes-lectura.sh'
sim_check "paralelo/SEC-014 control: dos elementos anotados AJENOS siguen siendo disjuntos" \
  disjunto 'docs/gobernanza/x.md (nuevo), hooks/guard-codigo.sh (modificado)' 'tools/arnes-lectura.sh'
rm -f "$PROJ/requirements/REQ-770.md" "$PROJ/requirements/REQ-771.md"

# --- SEC-018 · `--json` emitía JSON INVÁLIDO con caracteres de control. El escape sólo
# cubría `\` y `"`; un tabulador o un tabulador vertical viajaban crudos y `jq` rechaza la
# salida entera («control characters ... must be escaped»). `--json` es el modo que consume
# una MÁQUINA, así que una salida que no se puede parsear no es un detalle de formato: un
# consumidor que no falle cerrado convierte esto en un fail-open. Se mide en los dos sitios
# por donde entra el carácter: el MOTIVO (que cita el elemento crudo) y una RUTA aceptada
# (un tabulador vertical no es `[:blank:]`, así que pasa el filtro de blancos).
if [ -z "$FILTRO" ] || printf '%s' "paralelo: json control" | grep -qi -- "$FILTRO"; then
  ctl="$RAIZ/ctl-$BASHPID"; mkdir -p "$ctl/.arnes" "$ctl/requirements" "$ctl/hooks" "$ctl/tools"
  cp "$PROJ/.arnes/config.json" "$ctl/.arnes/config.json"
  : > "$ctl/hooks/lib.sh"
  printf '# REQ-A\nEstado: pendiente\nArchivos: /tmp/a\tb.sh\n\n## H\n'   > "$ctl/requirements/REQ-A.md"
  printf '# REQ-B\nEstado: pendiente\nArchivos: hooks/lib.sh\n\n## H\n'   > "$ctl/requirements/REQ-B.md"
  printf '# REQ-C\nEstado: pendiente\nArchivos: tools/a\vb.sh\n\n## H\n'  > "$ctl/requirements/REQ-C.md"
  : > "$ERRLOG"
  salida="$(bash "$PARA" --proyecto "$ctl" --json REQ-A REQ-B 2>"$ERRLOG")"
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: json control  la herramienta no imprimio NADA (motivo)"; diag; FAIL=$((FAIL+1))
  elif printf '%s' "$salida" | jq -e . >/dev/null 2>&1; then
    echo "  PASS  paralelo: un TABULADOR en el motivo no rompe el JSON"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: --json emite JSON que jq RECHAZA cuando el motivo lleva un control"
    printf '%s\n' "${salida:0:200}" | sed 's/^/          salida| /'; FAIL=$((FAIL+1))
  fi
  : > "$ERRLOG"
  salida="$(bash "$PARA" --proyecto "$ctl" --json REQ-C REQ-B 2>"$ERRLOG")"
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: json control  la herramienta no imprimio NADA (ruta)"; diag; FAIL=$((FAIL+1))
  elif printf '%s' "$salida" | jq -e '.requerimientos[0].archivos[0]' >/dev/null 2>&1 \
       && [ "$(printf '%s' "$salida" | jq -r '.requerimientos[0].archivos[0]')" = "$(printf 'tools/a\vb.sh')" ]; then
    echo "  PASS  paralelo: un control DENTRO de una ruta se escapa y vuelve igual al leerlo"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: --json no sobrevive a un caracter de control dentro de una ruta"
    printf '%s\n' "${salida:0:200}" | sed 's/^/          salida| /'; FAIL=$((FAIL+1))
  fi
fi
