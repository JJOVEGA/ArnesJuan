# Sección 20 del banco — 20-continuidad-automatica
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=28
PISO_AUTONOMO_SECCION=52  # 8 preámbulo + 13 maquinaria compartida duplicada + 31 bloque indivisible mayor · REQ-014 CA-18

  seccion_nueva "Continuidad automatica (hook Stop -> bloque derivado):"

EST_PROJ="$(mktemp -d)"
mkdir -p "$EST_PROJ/.arnes" "$EST_PROJ/requirements" "$EST_PROJ/docs"
cp "$PROJ/.arnes/config.json" "$EST_PROJ/.arnes/config.json"
# REQ-009: la cola se cuenta con LA REGLA DE LA PUERTA —encabezados `###`—, no con
# vinetas. Esta sonda escribia dos vinetas y esperaba 2; la puerta habria dicho 0 sobre
# ese mismo archivo, asi que el caso acreditaba un numero que no bloqueaba nada. Ahora la
# sonda escribe DOS ENTRADAS del formato documentado, con su cuerpo de vinetas debajo: el
# 2 que se comprueba es el mismo 2 que deniega el cierre.
printf '## Pendientes\n### [2026-09-05] (coordinadora) — decidir el proveedor\n- **Contexto** x\n- **Espera** aprobación\n\n### [2026-09-05] (coordinadora) — aprobar el borrado\n- **Contexto** y\n\n## Resueltas\n### [2026-09-01] (coordinadora) — otra\n' > "$EST_PROJ/PENDING_APPROVAL.md"
printf '# REQ-001\nEstado: completado\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n' > "$EST_PROJ/requirements/REQ-001.md"
printf '# REQ-002\nEstado: en-revisión\nSensible a seguridad: **sí**\nQA: con-hallazgos\nSeguridad: pendiente\n' > "$EST_PROJ/requirements/REQ-002.md"
printf '# Los REQ\nEste README no es un REQ y no debe contarse.\n' > "$EST_PROJ/requirements/README.md"
printf '# ESTADO\n\n## Fase actual\nESTO LO ESCRIBIO UNA PERSONA.\n' > "$EST_PROJ/docs/ESTADO.md"

# corre_estado <dir-proyecto> -> ejecuta el hook Stop contra ese proyecto
corre_estado() {
  local d="$1" json
  json="$(CLAUDE_PROJECT_DIR="$d" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')"
  : > "$ERRLOG"
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$d" "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>"$ERRLOG"
}
# check_estado <nombre> <patron-grep> <si|no: debe aparecer> <archivo>
check_estado() {
  local nombre="$1" patron="$2" debe="$3" archivo="$4" hay=no
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  [ -f "$archivo" ] && grep -q -- "$patron" "$archivo" && hay=si
  if [ "$hay" = "$debe" ]; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  esperaba aparece=$debe, fue=$hay"; diag; FAIL=$((FAIL+1)); fi
}

corre_estado "$EST_PROJ"; EST_RC=$?
if [ "$EST_RC" -eq 0 ]; then echo "  PASS  el hook sale 0 (no bloquea la parada)"; PASS=$((PASS+1))
else echo "  FAIL  el hook salio $EST_RC: una parada bloqueada es peor que no tener el bloque"; diag; FAIL=$((FAIL+1)); fi

check_estado "escribe el bloque derivado"          "ARNES:DERIVADO inicio"  si "$EST_PROJ/docs/ESTADO.md"
check_estado "no pisa lo que escribio una persona" "ESTO LO ESCRIBIO UNA"   si "$EST_PROJ/docs/ESTADO.md"
check_estado "cuenta los REQ, no el README"        "REQ:\*\* 2"             si "$EST_PROJ/docs/ESTADO.md"
check_estado "lee la cola de aprobaciones"         "pendientes:\*\* 2"      si "$EST_PROJ/docs/ESTADO.md"
# El REQ-002 dice `**si**`: desde 1.21.0 su rigor efectivo es critico, y el bloque
# derivado lo ENSEÑA. Es la utilidad de mostrar los valores como los lee la maquina.
check_estado "el bloque delata el rigor efectivo"  "critico"                si "$EST_PROJ/docs/ESTADO.md"
# Sin repositorio el estado del arbol es DESCONOCIDO. Decir "limpio" o "con cambios"
# seria afirmar un hecho que no se tiene.
check_estado "arbol sin repo -> desconocido, no inventado" "desconocido"    si "$EST_PROJ/docs/ESTADO.md"

corre_estado "$EST_PROJ"
EST_N="$(grep -c 'ARNES:DERIVADO inicio' "$EST_PROJ/docs/ESTADO.md")"
if [ "$EST_N" = "1" ]; then echo "  PASS  idempotente: dos pasadas, un solo bloque"; PASS=$((PASS+1))
else echo "  FAIL  idempotente: hay $EST_N bloques tras dos pasadas"; FAIL=$((FAIL+1)); fi

# Medido: el bloque decia 58 REQ y habia 57, porque contaba una nota sin `Estado:`.
# Y pesaba 10,4 KB con 58 filas, un 25 % de un ESTADO.md que se lee en CADA sesion.
printf '# Nota\nEsto NO tiene Estado y no es un REQ.\n' > "$EST_PROJ/requirements/consecuencias.md"
corre_estado "$EST_PROJ"
check_estado "una nota sin Estado: no cuenta como REQ"  "REQ:\*\* 2 "              si "$EST_PROJ/docs/ESTADO.md"
check_estado "...y se dice cuantas hay, no se esconden" "notas, no REQ):\*\* 1"    si "$EST_PROJ/docs/ESTADO.md"
check_estado "un REQ completado NO ocupa fila"          "^| REQ-001 "              no "$EST_PROJ/docs/ESTADO.md"
check_estado "un REQ abierto SI ocupa fila"             "^| REQ-002 "              si "$EST_PROJ/docs/ESTADO.md"

# `Estado:` lleva la MISMA regla que los veredictos: el parentesis es evidencia.
# Medido: sin esto el bloque decia 2 completados donde habia 9 y metia 44 REQ en
# "otros". La PUERTA no estaba afectada --caza el estado en el texto crudo-- asi que
# era un tablero que mentia; serio igual, porque el proyecto apago la continuidad.
printf '# REQ-020\nEstado: completado (2026-09-01)\nQA: aprobado\nSeguridad: n/a\n' > "$EST_PROJ/requirements/REQ-020.md"
corre_estado "$EST_PROJ"
check_estado "Estado con evidencia cuenta como completado" "REQ:\*\* 3 .* completado 2" si "$EST_PROJ/docs/ESTADO.md"
check_estado "...y no ocupa fila entre los abiertos"        "^| REQ-020 "                    no "$EST_PROJ/docs/ESTADO.md"
# La version instalada, visible en cada parada. Un proyecto real corrio 1.13.0 un MES
# con 1.24.0 publicada, sin ninguna senal. No se consulta la red: se ensena lo gratis.
check_estado "la version del plugin se ve en el bloque"     "plugin instalado"               si "$EST_PROJ/docs/ESTADO.md"

# --- Una ruta del manifiesto no puede salir del proyecto --------------------------
# `estado_derivado.archivo` y las `ruta` de rotacion se concatenaban tal cual: con
# `"archivo": "../fuera.md"` el hook de parada escribia FUERA del repositorio en cada
# parada. El manifiesto tambien lo puede escribir un agente y no lo protege guard-codigo.
EST_RAIZ="$(mktemp -d)"; EST_FUERA="$EST_RAIZ/proyecto"; mkdir -p "$EST_FUERA/.arnes" "$EST_FUERA/requirements" "$EST_FUERA/docs"
jq '.estado_derivado = {activo:true, archivo:"../fuera.md"}' "$PROJ/.arnes/config.json" > "$EST_FUERA/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$EST_FUERA/PENDING_APPROVAL.md"
corre_estado "$EST_FUERA"; EST_RC=$?
if [ ! -e "$EST_RAIZ/fuera.md" ]; then echo "  PASS  estado_derivado.archivo '../fuera.md' NO escribe fuera del proyecto"; PASS=$((PASS+1))
else echo "  FAIL  el bloque derivado se escribio FUERA del proyecto"; FAIL=$((FAIL+1)); fi
if [ "$EST_RC" -eq 0 ]; then echo "  PASS  ...y sigue saliendo 0"; PASS=$((PASS+1))
else echo "  FAIL  salio $EST_RC"; FAIL=$((FAIL+1)); fi
rm -rf "$EST_RAIZ"

# --- Contencion FISICA: un enlace simbolico no saca la escritura del proyecto ------
# La contencion lexica de 1.29.0 bloqueaba `..`, absolutas y `~`. Una revision externa
# reprodujo en 1.29.1 que `docs -> /externo` con `archivo: docs/ESTADO.md` escribia
# fuera. En Windows sin modo desarrollador `ln -s` no crea un enlace real, asi que aqui
# el caso sale SKIP y lo ejecuta el CI en Linux: es exactamente para lo que esta.
SYM_RAIZ="$(mktemp -d)"; SYM_P="$SYM_RAIZ/proyecto"; SYM_EXT="$SYM_RAIZ/externo"
mkdir -p "$SYM_P/.arnes" "$SYM_P/requirements" "$SYM_EXT"
ln -s "$SYM_EXT" "$SYM_P/docs" 2>/dev/null
if [ -L "$SYM_P/docs" ]; then
  jq '.estado_derivado = {activo:true, archivo:"docs/ESTADO.md"}' "$PROJ/.arnes/config.json" > "$SYM_P/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$SYM_P/PENDING_APPROVAL.md"
  corre_estado "$SYM_P"; SYM_RC=$?
  if [ ! -e "$SYM_EXT/ESTADO.md" ]; then echo "  PASS  docs -> externo (symlink): el bloque derivado NO se escribe fuera"; PASS=$((PASS+1))
  else echo "  FAIL  el bloque derivado atraveso el symlink y se escribio FUERA"; FAIL=$((FAIL+1)); fi
  if [ "$SYM_RC" -eq 0 ]; then echo "  PASS  ...y sigue saliendo 0"; PASS=$((PASS+1))
  else echo "  FAIL  salio $SYM_RC"; FAIL=$((FAIL+1)); fi
else
  echo "  SKIP  docs -> externo (symlink): el bloque derivado NO se escribe fuera  (sin symlinks reales en esta plataforma)"
  echo "  SKIP  ...y sigue saliendo 0  (sin symlinks reales en esta plataforma)"
fi
rm -rf "$SYM_RAIZ"

# --- El banco no tenia TAMANO, y por eso no vio 92 segundos ----------------------
# Medido en un proyecto real: 47 REQ, 3,73 MB, uno de 244 KB, y el bloque derivado
# tardaba 92 s por parada leyendo linea a linea en bash. Con REQ de cinco lineas eso son
# microsegundos; el banco certificaba la correccion y no veia el coste. Estos casos no
# miden tiempo --un temporizador es fragil entre maquinas-- pero SI exigen que el bloque
# sea correcto sobre un fixture del tamano real, y que los campos se encuentren aunque
# esten a doscientas lineas de la cabecera.
EST_G="$(mktemp -d)"; mkdir -p "$EST_G/.arnes" "$EST_G/requirements" "$EST_G/docs"
cp "$PROJ/.arnes/config.json" "$EST_G/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$EST_G/PENDING_APPROVAL.md"
EST_RELLENO="$(printf 'Esta linea documenta la historia del requerimiento con detalle suficiente para pesar lo que pesa uno real.\n%.0s' $(seq 1 700))"
for i in $(seq -w 1 47); do
  EST_ST=en-revisión; [ "$((10#$i % 3))" -eq 0 ] && EST_ST=completado
  { printf '# REQ-%s\nEstado: %s\nSensible a seguridad: no\nQA: aprobado (medido)\nSeguridad: n/a\n\n## Historia\n' "$i" "$EST_ST"; printf '%s' "$EST_RELLENO"; } > "$EST_G/requirements/REQ-$i.md"
done
# Un REQ con los veredictos DESPUES de doscientas lineas de historia: se encuentran igual.
{ printf '# REQ-099\nEstado: en-revisión\n\n## Historia\n'; printf '%s' "$EST_RELLENO"; printf '\nQA: con-hallazgos\nRigor: critico\nHallazgos abiertos: SEC-1 (usuario/dinero)\n'; } > "$EST_G/requirements/REQ-099.md"
corre_estado "$EST_G"
check_estado "47 REQ grandes (3,7 MB): el bloque los cuenta todos"    "REQ:\*\* 48 "                       si "$EST_G/docs/ESTADO.md"
check_estado "...y los 15 completados salen como completados"          "completado 15 "                      si "$EST_G/docs/ESTADO.md"
# Los campos valen SOLO en la cabecera. Ayer este mismo banco fijaba lo contrario --"campos
# a 200 lineas de la cabecera se encuentran igual"-- porque eso hacia el codigo. Medido hoy:
# una linea `Seguridad: aprobado (A-009, 2026-09-02)` dentro de `## Historial` se leia como
# EL veredicto y cerraba un REQ critico con la cabecera en pendiente. El caso se da la
# vuelta: lo que hay dentro de una seccion NO es un campo.
# REQ-010: la celda muestra el valor NORMALIZADO (`en-revision`), que es el que aplica la
# puerta. CA-16 lo exige: puerta, informe y bloque derivado tienen que coincidir caracter a
# caracter, y desde 1.31.0 el acento ya no es parte del valor.
check_estado "campos DENTRO de una seccion NO se leen: QA queda vacio"  "^| REQ-099 | en-revision | — | — | estandar | — |" si "$EST_G/docs/ESTADO.md"
check_estado "...y Rigor cae al defecto, no al 'critico' de la historia" "^| REQ-099 | en-revisión | — | — | critico"      no "$EST_G/docs/ESTADO.md"
rm -rf "$EST_G"

# Un .md VACIO es un archivo sin Estado y se cuenta como nota, como antes de 1.29.3:
# awk no emite linea para un archivo sin lineas, y desaparecia del conteo en silencio.
: > "$EST_PROJ/requirements/vacio.md"
corre_estado "$EST_PROJ"
check_estado "un .md VACIO cuenta como nota, no desaparece" "notas, no REQ):\*\* 2" si "$EST_PROJ/docs/ESTADO.md"
rm -f "$EST_PROJ/requirements/vacio.md"

# Apagable: quien no lo quiera, lo apaga.
EST_OFF="$(mktemp -d)"; mkdir -p "$EST_OFF/.arnes" "$EST_OFF/requirements" "$EST_OFF/docs"
jq '.estado_derivado.activo = false' "$PROJ/.arnes/config.json" > "$EST_OFF/.arnes/config.json"
corre_estado "$EST_OFF"
check_estado "con activo:false no escribe" "ARNES:DERIVADO" no "$EST_OFF/docs/ESTADO.md"

# INERTE en un repo ajeno: sin manifiesto no se toca nada. Es la invariante que
# permite instalar el plugin sin que estorbe fuera de un proyecto del arnes.
EST_AJENO="$(mktemp -d)"; mkdir -p "$EST_AJENO/docs"
printf '# El ESTADO de OTRO proyecto\n' > "$EST_AJENO/docs/ESTADO.md"
corre_estado "$EST_AJENO"; EST_RC=$?
check_estado "sin manifiesto no escribe (repo ajeno)" "ARNES:DERIVADO" no "$EST_AJENO/docs/ESTADO.md"
if [ "$EST_RC" -eq 0 ]; then echo "  PASS  sin manifiesto tambien sale 0"; PASS=$((PASS+1))
else echo "  FAIL  sin manifiesto salio $EST_RC"; FAIL=$((FAIL+1)); fi

# Sin la carpeta destino no se inventa: crear `docs/` en un proyecto que no la tiene
# seria decidir su estructura, y eso no le toca al arnes.
EST_SIN="$(mktemp -d)"; mkdir -p "$EST_SIN/.arnes" "$EST_SIN/requirements"
cp "$PROJ/.arnes/config.json" "$EST_SIN/.arnes/config.json"
corre_estado "$EST_SIN"
if [ ! -e "$EST_SIN/docs" ]; then echo "  PASS  sin la carpeta destino no la inventa"; PASS=$((PASS+1))
else echo "  FAIL  creo docs/ en un proyecto que no la tenia"; FAIL=$((FAIL+1)); fi

rm -rf "$EST_PROJ" "$EST_OFF" "$EST_AJENO" "$EST_SIN"

# --- Rotacion de artefactos: una bitacora no crece sin tope --------------------
# Medido en un proyecto real: el CHANGELOG.md llego a 1,17 MB, del orden de 300.000
# tokens que entran en la ventana cada vez que alguien lo lee.
#
# Estos casos existen porque los DOS fallos de este hook los encontro una prueba
# desechable de scratchpad, no una lectura del codigo: la comprobacion con `case`
# --que fallaba siempre porque `## [1.20.0]` lleva corchetes, y en un patron de
# `case` los corchetes son una clase de caracteres-- y el conteo invertido, que
# conservaba `total - conservar` y vaciaba el archivo a trozos en cada pasada.
# Una prueba que encuentra un fallo y luego se tira no protege de nada manana.
