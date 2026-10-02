# Sección 28 del banco — 28-rotacion-seccion-2-el-estado
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=23
PISO_AUTONOMO_SECCION=86  # 8 preámbulo + 11 maquinaria compartida duplicada + 67 bloque indivisible mayor · REQ-014 CA-18

seccion_nueva "Continuidad bajo averia: el manifiesto ilegible y la escritura que falla:"

# Los dos ayudantes de comparacion vienen DUPLICADOS de `28-rotacion-seccion-1-la-historia.sh`
# a proposito: un archivo de seccion no hace `source` de otro (invariante 4 del README del
# banco), y copiar once lineas cuesta menos que abrir una puerta trasera entre secciones.
rsec_check() {
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=$2 obtenido=$3"; diag; FAIL=$((FAIL+1)); fi
}
rsec_cnt() {   # <patron> <archivo> -> cuenta, y 0 si el archivo no existe
  local n
  n="$(grep -c -- "$1" "$2" 2>/dev/null)" || n=0
  [ -n "$n" ] || n=0
  printf '%s' "$n"
}

# DEV 1.31.0 v4 (SEC-011): CON EL MANIFIESTO ILEGIBLE, `docs/ESTADO.md` NO SE PIERDE.
# Es el archivo de continuidad —lo unico que queda cuando el contexto se pierde— y ademas
# lleva texto de una persona fuera de los marcadores. Medido antes del arreglo: con el
# manifiesto roto la parada dejaba dos `jq: parse error` crudos y NINGUN bloque; con el
# manifiesto VACIO el hook moria con `unbound variable`. Ahora se deriva igual con las
# rutas por defecto del codigo, el bloque DICE que el enforcement esta degradado, y lo de
# fuera de los marcadores sigue byte a byte.
for MEST in '{"agentes":{,}' '' 'null' '[]'; do
  EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs" "$EPROJ/requirements"
  printf '%s' "$MEST" > "$EPROJ/.arnes/config.json"
  printf '# ESTADO\n\n## Fase\nlo que escribio una persona\n' > "$EPROJ/docs/ESTADO.md"
  ETIQ="$(printf '%s' "${MEST:-<vacio>}" | head -c 14)"
  : > "$ERRLOG"
  printf '%s' "$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
    | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"; EST_RC=$?
  rsec_check "DEV 1.31.0 v4: SEC-011 manifiesto ilegible ($ETIQ): bloque derivado + linea de degradado, sale 0" "si-si-0" \
    "$(grep -q 'ARNES:DERIVADO' "$EPROJ/docs/ESTADO.md" && echo si || echo no)-$(grep -q 'enforcement degradado' "$EPROJ/docs/ESTADO.md" && echo si || echo no)-$EST_RC"
  rsec_check "DEV 1.31.0 v4: SEC-011 manifiesto ilegible ($ETIQ): lo de la persona sigue, y sin jq crudo" "1-no" \
    "$(grep -c 'lo que escribio una persona' "$EPROJ/docs/ESTADO.md")-$(grep -q '^jq:' "$ERRLOG" && echo si || echo no)"
  rm -rf "$EPROJ"
done

# LOS CAMINOS EN QUE NO SE PUEDE LEER EL DESTINO: NO SE ESCRIBE NADA Y EL ARCHIVO QUEDA
# BYTE A BYTE. Medidos antes del arreglo: los dos DESTRUIAN el texto de la persona, porque
# se reescribia a partir de una lectura que habia fallado. Un bloque que no se escribe es
# un inconveniente; uno que borra el documento es una perdida.
EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs" "$EPROJ/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$EPROJ/.arnes/config.json"
{ printf '# ESTADO\nantes del NUL\n'; printf 'x\000y\n'; printf 'DETRAS DEL NUL\n'; } > "$EPROJ/docs/ESTADO.md"
EST_MD5="$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)"
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
rsec_check "DEV 1.31.0 v4: SEC-011 un NUL en ESTADO.md: no se escribe nada, byte a byte, y se avisa" "iguales-si" \
  "$([ "$EST_MD5" = "$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)" ] && echo iguales || echo distintos)-$(grep -q 'NUL' "$ERRLOG" && echo si || echo no)"
rm -rf "$EPROJ"

EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs" "$EPROJ/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$EPROJ/.arnes/config.json"
printf '# ESTADO\nlo que escribio una persona\n' > "$EPROJ/docs/ESTADO.md"
EST_MD5="$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)"
chmod 200 "$EPROJ/docs/ESTADO.md"
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
chmod 600 "$EPROJ/docs/ESTADO.md"
rsec_check "DEV 1.31.0 v4: SEC-011 ESTADO.md sin permiso de lectura: no se escribe nada, byte a byte" "iguales-si" \
  "$([ "$EST_MD5" = "$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)" ] && echo iguales || echo distintos)-$(grep -q 'no se puede leer' "$ERRLOG" && echo si || echo no)"
rm -rf "$EPROJ"

# Y LA CARPETA SIN PERMISO DE ESCRITURA: el original intacto, CERO temporales huerfanos y
# un aviso. El `mv` ya protegia el destino; lo que faltaba era decirlo y no dejar basura.
EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs" "$EPROJ/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$EPROJ/.arnes/config.json"
printf '# ESTADO\nlo que escribio una persona\n' > "$EPROJ/docs/ESTADO.md"
EST_MD5="$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)"
chmod 500 "$EPROJ/docs"
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
  | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
EST_TMP="$(ls -1 "$EPROJ/docs" | grep -c 'arnes.tmp' || true)"
chmod 700 "$EPROJ/docs"
rsec_check "DEV 1.31.0 v4: SEC-011 carpeta sin permiso: original intacto, 0 temporales, y avisa" "iguales-0-si" \
  "$([ "$EST_MD5" = "$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)" ] && echo iguales || echo distintos)-$EST_TMP-$(grep -q 'no se pudo escribir' "$ERRLOG" && echo si || echo no)"
rm -rf "$EPROJ"

# QA 1.31.0 v4 (CA-64.2): EL DISCO LLENO DE VERDAD, NO SOLO LA CARPETA SIN PERMISO.
# El caso de arriba mide un fallo de escritura por PERMISOS; este mide un fallo de
# escritura por ESPACIO, que es otra rama del `printf` y la que de verdad se sufre en
# produccion. Se provoca sin privilegios haciendo que el temporal apunte a `/dev/full`,
# que devuelve ENOSPC en cada escritura. Las tres exigencias de CA-64.2 juntas: hash
# identico, cero temporales huerfanos y un aviso propio (no el error crudo del sistema).
#
# REESCRITO EN 1.32.1, Y EL MOTIVO ES EL ARREGLO MISMO (REQ-015 CA-01): el temporal ya no
# se llama `<destino>.arnes.tmp` —ese nombre fijo era la carrera— sino
# `<destino>.arnes.tmp.<pid del proceso que publica>`, y desde fuera no se puede plantar el
# enlace a `/dev/full` en una ruta que aun no se conoce. Se resuelve con un PUNTO DE
# SINCRONIZACION, no adivinando: el hook se lanza con su stdin en una FIFO, asi que queda
# BLOQUEADO en la primera cosa que hace (leer la entrada) mientras el caso planta el enlace
# usando `$!`, que es exactamente el `BASHPID` del hook. Cuando la FIFO recibe el JSON, el
# hook arranca y su unico temporal posible ya es `/dev/full`.
#
# Con eso el caso mide DOS cosas a la vez y ninguna por casualidad: la rama ENOSPC de
# siempre, y —end-to-end— que el temporal que el hook usa de verdad es el de su propio
# proceso y esta junto al destino. Contra los hooks de 1.32.0 falla (nombre fijo: el enlace
# no se toca, el archivo se reescribe y queda un resto).
if [ -c /dev/full ]; then
  EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs" "$EPROJ/requirements"
  printf '%s\n' "$MANIFIESTO_BASE" > "$EPROJ/.arnes/config.json"
  printf '# ESTADO\nlo que escribio una persona\ny una segunda linea suya\n' > "$EPROJ/docs/ESTADO.md"
  EST_MD5="$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)"
  EST_IN="$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
  mkfifo "$EPROJ/entrada"
  : > "$ERRLOG"
  CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/stop.sh" < "$EPROJ/entrada" >/dev/null 2>"$ERRLOG" &
  EST_PID=$!
  ln -s /dev/full "$EPROJ/docs/ESTADO.md.arnes.tmp.$EST_PID"
  printf '%s' "$EST_IN" > "$EPROJ/entrada"       # libera al hook: de aqui en adelante corre
  EST_RC=0; wait "$EST_PID" || EST_RC=$?
  EST_TMP="$(ls -1 "$EPROJ/docs" | grep -c 'arnes.tmp' || true)"
  rsec_check "QA 1.31.0 v4: CA-64.2 disco lleno (ENOSPC): byte a byte, 0 temporales, avisa, sale 0" "iguales-0-si-0" \
    "$([ "$EST_MD5" = "$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)" ] && echo iguales || echo distintos)-$EST_TMP-$(grep -q 'no se pudo escribir' "$ERRLOG" && echo si || echo no)-$EST_RC"
  rm -rf "$EPROJ"
else
  echo "  SKIP  QA 1.31.0 v4: CA-64.2 disco lleno (no hay /dev/full)"
fi

# DEV 1.31.0 v5 (QA-118): LA MUERTE POR SENAL A MITAD DE LA ESCRITURA TAMPOCO DEJA BASURA.
# Los dos casos de arriba miden fallos que DEVUELVEN error —permisos, ENOSPC—, y ahi el
# `rm -f` del hook corre. Falta la tercera forma de fallar: que al proceso lo MATEN mientras
# escribe. Con un limite de tamano de archivo (`ulimit -f`) el kernel manda SIGXFSZ, el
# interprete muere dentro del `printf` y ningun `rm` posterior llega a correr: medido antes
# del arreglo, el hook salia 153 y dejaba `ESTADO.md.arnes.tmp` de 1024 bytes junto al
# archivo de continuidad, en silencio. El destino quedaba intacto —eso ya estaba bien—, pero
# un temporal huerfano al lado del unico archivo que sobrevive al contexto es basura que
# alguien tendra que interpretar. Se exige lo mismo que a las otras dos averias.
if ( ulimit -f 1 ) 2>/dev/null; then
  EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs" "$EPROJ/requirements"
  printf '%s\n' "$MANIFIESTO_BASE" > "$EPROJ/.arnes/config.json"
  # El texto humano se rellena a proposito por encima del limite: `ulimit -f` cuenta en
  # bloques de 1024 bytes en bash, y el bloque derivado de un proyecto minimo cabe en uno
  # (medido: 1020 bytes). Sin el relleno la escritura NO llegaria al limite y el caso
  # estaria en verde sin haber provocado nunca la senal que dice medir.
  { printf '# ESTADO\nlo que escribio una persona\n'
    printf 'relleno de la persona %s\n' 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
    printf 'relleno de la persona %s\n' 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40
  } > "$EPROJ/docs/ESTADO.md"
  EST_MD5="$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)"
  # El stderr va a un archivo PROPIO y vacio: con `ulimit -f` activo, el limite se aplica a
  # TODO archivo que se escriba, y un `$ERRLOG` que ya viniera crecido mataria al hook en su
  # propio aviso, midiendo el banco en vez del hook.
  EST_ERR118="$EPROJ/err.log"; : > "$EST_ERR118"
  EST_IN118="$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
  EST_RC=0
  ( ulimit -f 1
    printf '%s' "$EST_IN118" | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$EST_ERR118"
  ) || EST_RC=$?
  EST_TMP="$(ls -1 "$EPROJ/docs" | grep -c 'arnes.tmp' || true)"
  rsec_check "DEV 1.31.0 v5: QA-118 muerte por SIGXFSZ: byte a byte, 0 temporales, avisa, sale 0" "iguales-0-si-0" \
    "$([ "$EST_MD5" = "$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)" ] && echo iguales || echo distintos)-$EST_TMP-$(grep -q 'no se pudo escribir' "$EST_ERR118" && echo si || echo no)-$EST_RC"
  rm -rf "$EPROJ"
else
  echo "  SKIP  DEV 1.31.0 v5: QA-118 SIGXFSZ (esta shell no acepta 'ulimit -f')"
fi
# QA 1.31.0 v4 (CA-64.2, concurrencia): DOS AGENTES QUE PARAN A LA VEZ.
# Cuatro paradas a la vez, cinco rondas, y tres invariantes en cada ronda: ni se pierde el
# texto humano, ni quedan DOS bloques, ni queda basura.
#
# ESTE CASO ENCONTRO EL DEFECTO Y NO PODIA ACREDITAR SU ARREGLO, Y ESA DISTINCION IMPORTA
# (REQ-015 CA-05/CA-06). Con el temporal de nombre FIJO de <=1.32.0 fallaba 1 de 25 vueltas
# completas del banco y 0 de 92 dirigidas (H-12, 2026-09-06): suficiente para saber que
# habia una carrera, insuficiente para afirmar que un arreglo la cierra —una vuelta verde
# de un caso que falla 1 de 25 no dice nada—. Por eso los cuatro casos que siguen fuerzan
# el solapamiento con un punto de sincronizacion explicito en vez de repetir a ver si cae.
# Este se conserva porque mide otra cosa que ninguno de ellos mide: cuatro procesos DE
# VERDAD, sin nada forzado. Ya no es un rojo intermitente con causa conocida abierta: la
# causa —el nombre compartido— la retira `arnes_tmp_publicacion`.
EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs" "$EPROJ/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$EPROJ/.arnes/config.json"
EST_IN="$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
EST_PERD=0; EST_DOBLE=0; EST_BASURA=0
for EST_R in 1 2 3 4 5; do
  printf '# ESTADO\nlo que escribio una persona\n' > "$EPROJ/docs/ESTADO.md"
  for EST_K in 1 2 3 4; do
    printf '%s' "$EST_IN" | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/stop.sh" >/dev/null 2>/dev/null &
  done
  wait
  grep -q 'lo que escribio una persona' "$EPROJ/docs/ESTADO.md" || EST_PERD=$((EST_PERD+1))
  [ "$(grep -c 'ARNES:DERIVADO inicio' "$EPROJ/docs/ESTADO.md")" -eq 1 ] || EST_DOBLE=$((EST_DOBLE+1))
  [ "$(ls -1 "$EPROJ/docs" | grep -c 'arnes.tmp' || true)" -eq 0 ] || EST_BASURA=$((EST_BASURA+1))
done
rsec_check "QA 1.31.0 v4: CA-64.2 cuatro paradas a la vez x5: ni se pierde, ni se duplica, ni deja basura" "0-0-0" \
  "$EST_PERD-$EST_DOBLE-$EST_BASURA"
rm -rf "$EPROJ"

# DEV 1.31.0 v4 (SEC-011): LA REPARACION DEL MANIFIESTO DEJA RASTRO, Y DISTINGUIBLE.
# Con el manifiesto ilegible la escritura de `.arnes/config.json` esta permitida a
# proposito —es la que devuelve la capacidad de medir—, pero su `stderr` era IDENTICO al de
# cualquier otra llamada durante la averia: la unica escritura privilegiada del arnes era
# indistinguible de que no hubiera pasado nada.
EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes"
printf '%s' '{"agentes":{,}' > "$EPROJ/.arnes/config.json"
: > "$ERRLOG"
printf '%s' "$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n --arg f "$EPROJ/.arnes/config.json" \
  '{tool_name:"Write",agent_id:"q1",agent_type:"qa-tester",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:$f,content:"{}"}}')" \
  | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/guard.sh" >/dev/null 2>"$ERRLOG"
rsec_check "DEV 1.31.0 v4: SEC-011 la reparacion avisa una vez, nombra el archivo y el agente" "1-si-si" \
  "$(grep -c 'REPARACION DEL MANIFIESTO' "$ERRLOG")-$(grep -q '.arnes/config.json' "$ERRLOG" && echo si || echo no)-$(grep -q "qa-tester" "$ERRLOG" && echo si || echo no)"
# CONTROL: cualquier OTRA ruta durante la averia sigue denegada y no lleva ese aviso.
: > "$ERRLOG"
EST_OUT="$(printf '%s' "$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n \
  '{tool_name:"Write",agent_id:"q1",agent_type:"qa-tester",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{file_path:"docs/n.md",content:"x"}}')" \
  | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/guard.sh" 2>"$ERRLOG")"
rsec_check "DEV 1.31.0 v4: SEC-011 control: otra ruta sigue deny y sin el aviso de reparacion" "deny-0" \
  "$(printf '%s' "$EST_OUT" | jq -r '.hookSpecificOutput.permissionDecision // "allow"')-$(grep -c 'REPARACION DEL MANIFIESTO' "$ERRLOG")"
rm -rf "$EPROJ"

# CA-17: no regresion. La forma ANTERIOR —artefacto por ruta, secciones `## `— sigue
# rotando igual que en 1.30.3.
RP3="$(mktemp -d)"; mkdir -p "$RP3/.arnes"
jq -n '{agentes:{agente_codigo:"desarrollador"},
        rotacion:{activo:true, umbral_bytes:2000, conservar_secciones:3, orden:"nuevo-primero",
                  artefactos:["CHANGELOG.md"]}}' > "$RP3/.arnes/config.json"
{ printf '# CHANGELOG\n\n'
  for v in 10 9 8 7 6 5 4 3 2 1; do
    printf '## [1.%s.0]\n' "$v"
    for i in 1 2 3 4 5 6; do printf 'relleno %s de 1.%s.0 para que el archivo pese lo suyo\n' "$i" "$v"; done
    printf '\n'
  done
} > "$RP3/CHANGELOG.md"
RSEC_JSON="$(CLAUDE_PROJECT_DIR="$RP3" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
: > "$ERRLOG"
printf '%s' "$RSEC_JSON" | CLAUDE_PROJECT_DIR="$RP3" "$HOOKS_DIR/rotar-artefactos.sh" >/dev/null 2>"$ERRLOG"
rsec_check "CA-17 la forma anterior (por ruta, secciones ##) no cambia" "3-7" \
  "$(rsec_cnt '^## ' "$RP3/CHANGELOG.md")-$(rsec_cnt '^## ' "$RP3/CHANGELOG-archivo.md")"
rm -rf "$RP3"

# --- REQ-015: LA CARRERA DE PUBLICACION, FORZADA. NO "REPETIR A VER SI CAE" -----------
#
# EL PUNTO DE SINCRONIZACION, QUE ES LO QUE HACE DETERMINISTAS ESTOS CUATRO CASOS: el
# recurso que dos paradas simultaneas comparten no es "el momento", es EL INODO del
# temporal de nombre fijo. Y ese solapamiento se puede sostener abierto sin depender de
# ningun reparto de CPU, porque un descriptor de archivo dura lo que uno quiera:
#
#   1. el caso hace de OTRA PARADA y abre el temporal compartido con `exec 9> ...`, que
#      es un `open(O_WRONLY|O_CREAT|O_TRUNC)` — literalmente el `printf > "$tmp"` del hook
#      partido en su apertura y su escritura;
#   2. la parada REAL corre entera: escribe su temporal y lo mueve encima del destino. Con
#      nombre compartido, ese `mv` convierte el inodo que el caso tiene abierto EN el
#      destino;
#   3. el caso completa su escritura, que ahora cae sobre el destino ya publicado y desde
#      el byte 0 — que es justo donde vive lo que escribio una persona.
#
# Los tres pasos van en orden fijo y el descriptor mantiene la ventana abierta entre el 2
# y el 3, asi que no hay nada que temporizar: el caso falla en TODAS las vueltas contra los
# hooks de 1.32.0 y pasa en TODAS con el temporal por proceso. Verificado en los dos
# sentidos con `ARNES_HOOKS_DIR` apuntando a 1.32.0.
EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs" "$EPROJ/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$EPROJ/.arnes/config.json"
printf '# ESTADO\nlo que escribio una persona\n' > "$EPROJ/docs/ESTADO.md"
EST_IN="$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
exec 9> "$EPROJ/docs/ESTADO.md.arnes.tmp"
: > "$ERRLOG"
printf '%s' "$EST_IN" | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
printf 'BASURA DE LA OTRA PARADA QUE LLEGA TARDE Y PISA EL PRINCIPIO DEL ARCHIVO PUBLICADO\n' >&9
exec 9>&-
rm -f "$EPROJ/docs/ESTADO.md.arnes.tmp"   # el temporal lo planto el caso, no el hook
rsec_check "DEV 1.32.1: REQ-015 CA-03/CA-05 carrera forzada: el texto humano sigue, UN bloque bien formado, sin restos" "1-1-1-0" \
  "$(rsec_cnt 'lo que escribio una persona' "$EPROJ/docs/ESTADO.md")-$(rsec_cnt 'ARNES:DERIVADO inicio' "$EPROJ/docs/ESTADO.md")-$(rsec_cnt 'ARNES:DERIVADO fin' "$EPROJ/docs/ESTADO.md")-$(ls -1 "$EPROJ/docs" | grep -c 'arnes.tmp' || true)"
rm -rf "$EPROJ"

# CA-01: LAS DOS CONDICIONES SE VERIFICAN JUNTAS, Y ESE "JUNTAS" ES EL CASO.
# Acreditar la ubicacion sin la colision es el error medido de R-003: el temporal estaba
# donde debia y aun asi dos procesos lo compartian. Ocho procesos piden nombre para el
# MISMO destino: ocho rutas, ocho distintas (no colision) y las ocho en el directorio del
# destino (ubicacion; un `mv` entre sistemas de archivos deja de ser atomico). Un solo
# veredicto para las dos: la conjuncion es el criterio.
EST_RUTAS="$(for EST_K in 1 2 3 4 5 6 7 8; do
  ( . "$HOOKS_DIR/lib.sh"; ARNES_PROJ=/x; arnes_tmp_publicacion /x/docs/ESTADO.md && printf '%s\n' "$ARNES_TMP" ) 2>/dev/null &
done; wait)"
rsec_check "DEV 1.32.1: REQ-015 CA-01 ocho procesos, ocho rutas DISTINTAS y todas junto al destino" "8-8-0" \
  "$(printf '%s\n' "$EST_RUTAS" | grep -c .)-$(printf '%s\n' "$EST_RUTAS" | sort -u | grep -c .)-$(printf '%s\n' "$EST_RUTAS" | grep -vc '^/x/docs/ESTADO\.md\.arnes\.tmp\.[0-9][0-9]*$' || true)"

# CA-01, la mitad fail-closed: SIN COMPONENTE UNICA NO SE CAE AL NOMBRE COMPARTIDO.
# Caer seria reintroducir la carrera en silencio, y en silencio es como se perdio el texto
# la primera vez. Se mide end-to-end quitandole `BASHPID` al interprete que corre el hook
# (`unset` funciona: la variable pierde su condicion especial en ese proceso), y se exige
# lo mismo que a los demas caminos de lectura fallida: no se escribe nada, el archivo queda
# byte a byte, se avisa y la parada no se bloquea.
EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs" "$EPROJ/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$EPROJ/.arnes/config.json"
printf '# ESTADO\nlo que escribio una persona\n' > "$EPROJ/docs/ESTADO.md"
EST_MD5="$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)"
EST_IN="$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
: > "$ERRLOG"
printf '%s' "$EST_IN" | CLAUDE_PROJECT_DIR="$EPROJ" bash -c 'unset BASHPID; . "$0"' "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"; EST_RC=$?
rsec_check "DEV 1.32.1: REQ-015 CA-01 sin componente unica: fail-closed, byte a byte, 0 temporales, avisa, sale 0" "iguales-0-si-0" \
  "$([ "$EST_MD5" = "$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)" ] && echo iguales || echo distintos)-$(ls -1 "$EPROJ/docs" | grep -c 'arnes.tmp' || true)-$(grep -q 'BASHPID' "$ERRLOG" && echo si || echo no)-$EST_RC"
rm -rf "$EPROJ"

# CA-02, EL REVERSO DEL NOMBRE UNICO: NI ACUMULA RESTOS NI BORRA UNA PUBLICACION EN CURSO.
# Un nombre por proceso convierte un archivo que se sobrescribia a si mismo en una familia
# de nombres, asi que un temporal que sobreviva a su dueno ya no lo retira la parada
# siguiente al reutilizarlo. Se retira, pero SOLO el que no tiene dueno vivo: borrar el de
# un proceso que sigue publicando seria crear el problema que este REQ cierra. Tres
# temporales a la vez —uno de un pid muerto, uno con el nombre compartido de 1.32.0 y uno
# del pid VIVO del propio banco— y despues de la parada tiene que quedar exactamente ese.
EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs" "$EPROJ/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$EPROJ/.arnes/config.json"
printf '# ESTADO\nlo que escribio una persona\n' > "$EPROJ/docs/ESTADO.md"
EST_IN="$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
printf 'resto de una parada que murio sin darle salida\n' > "$EPROJ/docs/ESTADO.md.arnes.tmp.4194303"
printf 'resto con el nombre compartido de 1.32.0\n' > "$EPROJ/docs/ESTADO.md.arnes.tmp"
printf 'publicacion EN CURSO de un proceso vivo\n' > "$EPROJ/docs/ESTADO.md.arnes.tmp.$$"
: > "$ERRLOG"
printf '%s' "$EST_IN" | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
rsec_check "DEV 1.32.1: REQ-015 CA-02 restos sin dueno retirados, la publicacion en curso intacta, el texto humano sigue" "1-si-1" \
  "$(ls -1 "$EPROJ/docs" | grep -c 'arnes.tmp' || true)-$([ -f "$EPROJ/docs/ESTADO.md.arnes.tmp.$$" ] && echo si || echo no)-$(rsec_cnt 'lo que escribio una persona' "$EPROJ/docs/ESTADO.md")"
rm -rf "$EPROJ"

# CA-07: LOS DOS ROTADORES, CON EL MISMO PUNTO DE SINCRONIZACION Y SU PROPIA INVARIANTE.
# `rotar-artefactos` arma CUATRO temporales de publicacion, y con nombre fijo tenian la
# misma carrera: la escritura tardia de otra parada caia sobre el origen ya recortado o
# sobre el archivo de historia ya publicado. Aqui el origen es un documento con CABECERA
# de una persona —en un REQ eso es el contrato— y se exigen las dos mitades del todo o
# nada: ninguna entrada perdida (recortada del origen sin estar en el destino) ni
# duplicada, el puntero una sola vez, la cabecera intacta y cero restos en los dos
# directorios. Se sostienen DOS descriptores, uno por temporal.
EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs/historial" "$EPROJ/requirements"
jq -n '{agentes:{agente_codigo:"desarrollador"},
        rotacion:{activo:true, artefactos:[{glob:"docs/BITACORA.md", seccion:"## Historial",
                  umbral_bytes:200, conservar_entradas:5, orden:"nuevo-al-final"}]}}' > "$EPROJ/.arnes/config.json"
{ printf '# BITACORA\nCABECERA QUE ESCRIBIO UNA PERSONA\n\n## Historial\n'
  for EST_K in $(seq -w 1 20); do printf -- '- entrada %s con texto suficiente para pasar del umbral\n' "$EST_K"; done
  printf '\n## Notas\nfinal intacto\n'; } > "$EPROJ/docs/BITACORA.md"
EST_IN="$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
exec 9> "$EPROJ/docs/BITACORA.md.arnes.tmp"
exec 8> "$EPROJ/docs/historial/BITACORA.md.arnes.tmp"
: > "$ERRLOG"
printf '%s' "$EST_IN" | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/rotar-artefactos.sh" >/dev/null 2>"$ERRLOG"
printf 'BASURA TARDIA DE LA OTRA PARADA SOBRE EL ORIGEN YA RECORTADO, PISANDO LA CABECERA\n' >&9
printf 'BASURA TARDIA DE LA OTRA PARADA SOBRE EL ARCHIVO DE HISTORIA YA PUBLICADO\n' >&8
exec 9>&- 8>&-
rm -f "$EPROJ/docs/BITACORA.md.arnes.tmp" "$EPROJ/docs/historial/BITACORA.md.arnes.tmp"
rsec_check "DEV 1.32.1: REQ-015 CA-07 rotacion de SECCION bajo la carrera: 5+15 entradas, cabecera intacta, un puntero, sin restos" "5-15-1-1-0-0" \
  "$(rsec_cnt '^- entrada' "$EPROJ/docs/BITACORA.md")-$(rsec_cnt '^- entrada' "$EPROJ/docs/historial/BITACORA.md")-$(rsec_cnt 'CABECERA QUE ESCRIBIO UNA PERSONA' "$EPROJ/docs/BITACORA.md")-$(rsec_cnt 'Entradas anteriores de esta' "$EPROJ/docs/BITACORA.md")-$(ls -1 "$EPROJ/docs" | grep -c 'arnes.tmp' || true)-$(ls -1 "$EPROJ/docs/historial" | grep -c 'arnes.tmp' || true)"
rm -rf "$EPROJ"

# CA-07, la otra forma: la rotacion POR RUTA (secciones `## `), con sus dos temporales.
EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/requirements"
jq -n '{agentes:{agente_codigo:"desarrollador"},
        rotacion:{activo:true, umbral_bytes:500, conservar_secciones:3, orden:"nuevo-primero",
                  artefactos:["CHANGELOG.md"]}}' > "$EPROJ/.arnes/config.json"
{ printf '# CHANGELOG\nCABECERA QUE ESCRIBIO UNA PERSONA\n\n'
  for EST_R in 10 9 8 7 6 5 4 3 2 1; do printf '## [1.%s.0]\n' "$EST_R"
    for EST_K in 1 2 3; do printf 'relleno %s de 1.%s.0 para que el archivo pese lo suyo\n' "$EST_K" "$EST_R"; done
    printf '\n'; done; } > "$EPROJ/CHANGELOG.md"
EST_IN="$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
exec 9> "$EPROJ/CHANGELOG.md.arnes.tmp"
exec 8> "$EPROJ/CHANGELOG-archivo.md.arnes.tmp"
: > "$ERRLOG"
printf '%s' "$EST_IN" | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/rotar-artefactos.sh" >/dev/null 2>"$ERRLOG"
printf 'BASURA TARDIA SOBRE EL CHANGELOG YA PUBLICADO, PISANDO SU CABECERA Y SU PUNTERO\n' >&9
printf 'BASURA TARDIA SOBRE EL ARCHIVO DE SECCIONES RETIRADAS\n' >&8
exec 9>&- 8>&-
rm -f "$EPROJ/CHANGELOG.md.arnes.tmp" "$EPROJ/CHANGELOG-archivo.md.arnes.tmp"
rsec_check "DEV 1.32.1: REQ-015 CA-07 rotacion por RUTA bajo la carrera: 3+7 secciones, cabecera intacta, un puntero, sin restos" "3-7-1-1-0" \
  "$(rsec_cnt '^## ' "$EPROJ/CHANGELOG.md")-$(rsec_cnt '^## ' "$EPROJ/CHANGELOG-archivo.md")-$(rsec_cnt 'CABECERA QUE ESCRIBIO UNA PERSONA' "$EPROJ/CHANGELOG.md")-$(rsec_cnt 'Las secciones anteriores se movieron' "$EPROJ/CHANGELOG.md")-$(ls -1 "$EPROJ" | grep -c 'arnes.tmp' || true)"
rm -rf "$EPROJ"
