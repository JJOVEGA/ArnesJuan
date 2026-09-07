# Sección 28 del banco — 28-rotacion-seccion-2-el-estado
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=17

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
if [ -w /dev/full ] || [ -c /dev/full ]; then
  EPROJ="$(mktemp -d)"; mkdir -p "$EPROJ/.arnes" "$EPROJ/docs" "$EPROJ/requirements"
  printf '%s\n' "$MANIFIESTO_BASE" > "$EPROJ/.arnes/config.json"
  printf '# ESTADO\nlo que escribio una persona\ny una segunda linea suya\n' > "$EPROJ/docs/ESTADO.md"
  EST_MD5="$(md5sum "$EPROJ/docs/ESTADO.md" | cut -d' ' -f1)"
  ln -s /dev/full "$EPROJ/docs/ESTADO.md.arnes.tmp"
  : > "$ERRLOG"
  printf '%s' "$(CLAUDE_PROJECT_DIR="$EPROJ" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
    | CLAUDE_PROJECT_DIR="$EPROJ" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"; EST_RC=$?
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
# `estado-derivado` publica por un temporal de nombre FIJO (`<destino>.arnes.tmp`), asi que
# dos paradas simultaneas lo comparten. Es la carrera obvia y hay que medirla, no razonarla:
# lo intolerable seria que una parada leyera el archivo mientras la otra lo mueve y el
# resultado perdiera el texto humano, quedara con DOS bloques o dejara basura. Cuatro
# paradas a la vez, cinco rondas, y las tres invariantes en cada ronda.
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
