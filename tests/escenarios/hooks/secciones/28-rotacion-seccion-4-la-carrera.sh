# Sección 28 del banco — 28-rotacion-seccion-4-la-carrera
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=8
PISO_AUTONOMO_SECCION=104  # 19 preámbulo (1-19) + 57 maquinaria compartida duplicada (20-76: los dos ayudantes copiados de las partes 1 y 3, más el montaje del fixture y el lanzador con reloj, que cualquier partición de esta parte tendría que duplicar) + 28 bloque indivisible mayor (78-105, el positivo del guardián con su calibración) · REQ-014 CA-18

# PARTE 4 Y NO PARTE 3 porque la 3 está en 400 de 400 líneas, el techo exacto de REQ-014
# CA-18, y REQ-026 CA-18 (vi) fija esta sede sin proponer subir el techo.
#
# QUE SE PRUEBA AQUI: la ACTUALIZACION PERDIDA (SEC-067). La rotacion lee el documento
# entero, calcula, y lo reescribe DESDE ESA LECTURA; si alguien escribe en medio, la
# publicacion lo pisa con contenido completo y valido. Medido 3/3 por el auditor en carrera
# real --un `Seguridad: aprobado` que volvio a `pendiente`, rc 0 y sin aviso, ventana de
# 355-361 ms-- y reproducido aqui 3/3 con una ventana de 295-312 ms.
#
# NO es la escritura DESGARRADA de REQ-015 (dos escrituras entrelazadas a mitad de archivo),
# y una no implica la otra: el arnes solo tenia defensa para la segunda.
  seccion_nueva "La rotacion no publica sobre una lectura caducada (REQ-026 CA-18):"

# MAQUINARIA DUPLICADA de las partes 1 y 3 a proposito: un archivo de seccion no hace
# `source` de otro (invariante 4 del README del banco).
rsec_check() {
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=$2 obtenido=$3"; diag; FAIL=$((FAIL+1)); fi
}
rsec_cnt() {
  local n
  n="$(grep -c -- "$1" "$2" 2>/dev/null)" || n=0
  [ -n "$n" ] || n=0
  printf '%s' "$n"
}
CAR_CAB='| Fecha | Antes → Después | Causa | ADR |'
CAR_SEP='|------------|-----------------|-------------------------|--------|'
CAR_FILAS=1200      # bastantes para que el calculo dure ~300 ms: la ventana tiene que ser
CAR_RETARDO=0.15    # mas larga que el retardo del escritor, no al reves
# car_proj <estado_derivado.activo>
car_proj() {
  RP4="$(mktemp -d)"; mkdir -p "$RP4/.arnes" "$RP4/requirements" "$RP4/docs"
  printf '# ESTADO\n\n## Fase\ntexto de una persona\n' > "$RP4/docs/ESTADO.md"
  jq -n --argjson ed "$1" \
    '{agentes:{agente_codigo:"desarrollador"}, requirements_dir:"requirements",
      estado_derivado:{activo:$ed},
      rotacion:{activo:true, artefactos:[{glob:"requirements/REQ-*.md",
        seccion:"## Historial de cambios", conservar_entradas:10, umbral_bytes:1000,
        orden:"nuevo-al-final", archivo_dir:"requirements/historial"}]}}' > "$RP4/.arnes/config.json"
  { printf '# REQ-450 — el contrato\nEstado: en-revisión\nQA: aprobado\nSeguridad: pendiente\nRigor: critico\n\n'
    printf '## Historial de cambios\n%s\n%s\n' "$CAR_CAB" "$CAR_SEP"
    local i; for i in $(seq -w 1 "$CAR_FILAS"); do
      printf '| 2026-01-%s | fila %s con relleno de sobra para que el calculo dure lo suyo | causa | — |\n' "$i" "$i"
    done
    printf '\n## Trazabilidad\nintacta\n'
  } > "$RP4/requirements/REQ-450.md"
  # LA ESCRITURA AJENA es la forma exacta de SEC-067: el MISMO documento con el veredicto de
  # seguridad firmado. Lo que tiene que sobrevivir byte a byte es un `Seguridad: aprobado`.
  sed 's/^Seguridad: pendiente$/Seguridad: aprobado (2026-09-09)/' \
    "$RP4/requirements/REQ-450.md" > "$RP4/ajeno.md"
  cp "$RP4/requirements/REQ-450.md" "$RP4/antes.md"
}
car_corre() {   # car_corre [ruta-a-escribir-en-medio] -> CAR_DUR en us
  local t0 t1 esc=''
  : > "$ERRLOG"
  if [ -n "${1:-}" ]; then
    ( sleep "$CAR_RETARDO"; cp "$1" "$RP4/requirements/REQ-450.md" ) & esc=$!
  fi
  t0=${EPOCHREALTIME/./}
  printf '%s' "$(CLAUDE_PROJECT_DIR="$RP4" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
    | CLAUDE_PROJECT_DIR="$RP4" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
  CAR_RC=$?
  t1=${EPOCHREALTIME/./}
  # SIEMPRE se espera al escritor: nada de una seccion sobrevive a su seccion (REQ-017 CA-06).
  [ -z "$esc" ] || wait "$esc" 2>/dev/null
  CAR_DUR=$(( t1 - t0 ))
}
car_fila() { rsec_cnt '^| 2026-01-' "$1"; }

# --- CA-18 (vi) EL POSITIVO DEL GUARDIAN: se provoca la carrera y el cambio ajeno sobrevive
car_proj true
car_corre "$RP4/ajeno.md"
# LA PRUEBA SE ABSTIENE SI NO PUDO PROVOCAR LA CARRERA, en vez de ponerse roja: si la parada
# duro menos que el retardo del escritor, la escritura ajena cayo FUERA de la ventana y este
# caso no midio lo que dice medir. Es la conducta de una sonda que no converge (REQ-021).
CAR_MIN=$(( 150000 + 20000 ))
if [ "$CAR_DUR" -lt "$CAR_MIN" ]; then
  echo "  SKIP  CA-18 (vi) positivo: la parada duro ${CAR_DUR}us y el escritor entra a los 150000us; la carrera no se provoco y el caso no mide lo que dice"
  SKIP=$((SKIP+1))
else
  # Las cuatro mitades de la propiedad, en un solo veredicto: (1) el documento es BYTE A BYTE
  # el que dejo la escritura ajena; (2) NO se rotó --las 1200 filas siguen ahi--; (3) no se
  # creo el archivo de destino; (4) la parada salio 0 (CA-18 (iv) de CA-08: nunca bloquea).
  rsec_check "CA-18 (vi) positivo: con la carrera, la escritura ajena sobrevive byte a byte y no se rota" "iguales-1200-no-0" \
    "$(cmp -s "$RP4/ajeno.md" "$RP4/requirements/REQ-450.md" && echo iguales || echo distintos)-$(car_fila "$RP4/requirements/REQ-450.md")-$([ -e "$RP4/requirements/historial/REQ-450.md" ] && echo si || echo no)-$CAR_RC"
fi
# EL VEREDICTO CONCRETO QUE SE PERDIA, nombrado: no es "un byte cambio", es que un
# `Seguridad: aprobado` volvia a `pendiente`. Eso es lo que hace a SEC-067 usuario/dinero.
rsec_check "CA-18 (vi) positivo: el 'Seguridad: aprobado' escrito en medio NO vuelve a 'pendiente'" "1-0" \
  "$(rsec_cnt '^Seguridad: aprobado (2026-09-09)' "$RP4/requirements/REQ-450.md")-$(rsec_cnt '^Seguridad: pendiente' "$RP4/requirements/REQ-450.md")"
# CA-18 (vii): el aviso por stderr Y la linea en el bloque derivado, con texto que DISTINGUE
# esta rama de las otras cuatro --aqui no hay nada que corregir: la rotacion hizo lo
# correcto-- y sin robarles la suya.
rsec_check "CA-18 (vii) la carrera avisa por stderr y deja su linea propia en el bloque derivado" "si-si-si-no" \
  "$(grep -q 'cambio en el disco MIENTRAS' "$ERRLOG" && echo si || echo no)-$(grep -q 'cambiaron en el disco mientras' "$RP4/docs/ESTADO.md" && echo si || echo no)-$(grep -q 'REQ-450.md' "$RP4/docs/ESTADO.md" && echo si || echo no)-$(grep -qE 'estructura de tabla ambigua|no se pueden leer enteros' "$RP4/docs/ESTADO.md" && echo si || echo no)"
rm -rf "$RP4"

# --- CA-18 (vi) SU CONTROL OBLIGATORIO: el mismo fixture, la misma configuracion, SIN carrera
# Sin esto, "no rotó" lo cumple igual un fixture que se quedo bajo el umbral, y la prueba no
# distingue "el guardian funciono" de "no habia nada que mover". Es la mitad que discrimina.
car_proj true
car_corre
rsec_check "CA-18 (vi) control: el MISMO fixture sin carrera rota de verdad, y el destino es legible" "10-1190-si-silencio" \
  "$(car_fila "$RP4/requirements/REQ-450.md")-$(car_fila "$RP4/requirements/historial/REQ-450.md")-$(awk -v c="$CAR_CAB" -v s="$CAR_SEP" 'p2==c && p1==s && /^\| 2026-01-/{n++} {p2=p1;p1=$0} END{print (n>0)?"si":"no"}' "$RP4/requirements/historial/REQ-450.md")-$(grep -q 'cambio en el disco MIENTRAS' "$ERRLOG" && echo aviso || echo silencio)"
rm -rf "$RP4"

# --- CA-18 (ii) LA DUDA DECIDE HACIA NO ROTAR, TAMBIEN SOBRE EL DESTINO ----------------
# El temporal del destino se arma sobre lo que el destino decia AL LEERLO, asi que si esa
# lectura no es fiable, publicar encima BORRA el bloque que ya habia --perdida de historia, y
# CA-05 roto sobre la union--. Aqui la vigencia NO SE PUEDE COMPROBAR: el archivo de historia
# lleva un byte NUL. La duda decide igual que en CA-08: no se rota y se avisa.
#
# ESTE CASO ES DETERMINISTA A PROPOSITO. La otra mitad de la misma rama --que el destino
# CAMBIE entre su lectura y su publicacion-- esta implementada y NO tiene caso: su ventana es
# el residuo de microsegundos entre la comprobacion y el `mv`, y un caso de reloj ahi seria
# intermitente. Se declara en el REQ en vez de fingir cobertura con un caso que no converge.
car_proj true
mkdir -p "$RP4/requirements/historial"
{ printf '# REQ-450 — historia archivada\n\n<!-- ARNES:ROTADO 2026-01-01 00:00 -->\n%s\n%s\n' "$CAR_CAB" "$CAR_SEP"
  printf '| 2026-00-00 | bloque de una rotacion anterior '; printf '\000'; printf ' con un NUL | causa | — |\n'
} > "$RP4/requirements/historial/REQ-450.md"
cp "$RP4/requirements/historial/REQ-450.md" "$RP4/hist-antes.md"
car_corre
# El documento no se toca, el destino no se toca, y el aviso lo nombra a EL, no al documento.
rsec_check "CA-18 (ii) si el ARCHIVO DE HISTORIA no se puede leer entero, no se publica nada" "1200-iguales-si-0" \
  "$(car_fila "$RP4/requirements/REQ-450.md")-$(cmp -s "$RP4/hist-antes.md" "$RP4/requirements/historial/REQ-450.md" && echo iguales || echo distintos)-$(grep -q 'historial/REQ-450.md.* NO SE PUEDE LEER ENTERO' "$ERRLOG" && echo si || echo no)-$CAR_RC"
rm -rf "$RP4"

# --- CA-18 (vii) SIN CANAL DE CONSTANCIA DURADERA NO SE ROTA (SEC-069) -----------------
# Con `estado_derivado.activo: false` NINGUNA de las lineas de "no se rota" se escribe, asi
# que la constancia que sobrevive a la sesion desaparece por una opcion ajena a este
# fail-closed. Un fail-closed invisible es indistinguible de una seccion que lleva meses sin
# archivarse, asi que la rotacion de seccion cede.
car_proj false
car_corre
rsec_check "CA-18 (vii) con el bloque derivado apagado no se rota, y lo dice por stderr" "1200-no-si-0" \
  "$(car_fila "$RP4/requirements/REQ-450.md")-$([ -e "$RP4/requirements/historial/REQ-450.md" ] && echo si || echo no)-$(grep -q "estado_derivado.activo' es false" "$ERRLOG" && echo si || echo no)-$CAR_RC"
rm -rf "$RP4"
# SU CONTROL: el MISMO fixture con el canal encendido rota. Ya lo prueba el control de (vi)
# con la misma configuracion, pero aqui se compara lo unico que cambia --el interruptor-- y
# se comprueba que el aviso de (vii) NO sale cuando el canal esta encendido: un aviso emitido
# siempre pasaria por acierto.
car_proj true
car_corre
rsec_check "CA-18 (vii) control: con el canal encendido rota y no menciona 'estado_derivado'" "10-1190-no" \
  "$(car_fila "$RP4/requirements/REQ-450.md")-$(car_fila "$RP4/requirements/historial/REQ-450.md")-$(grep -q "estado_derivado.activo' es false" "$ERRLOG" && echo si || echo no)"
rm -rf "$RP4"

# --- CA-18 (iv) DOS ROTACIONES CONCURRENTES sobre el mismo documento -------------------
# El criterio declaraba el duplicado MODELADO, NO MEDIDO. SE MIDIO, y por eso deja de estar
# modelado: contra `1fe975f`, con este mismo montaje, 1 de cada 5 vueltas y 1 de cada 10
# dejaron DOS bloques en el destino y 1190 filas DUPLICADAS, con CA-05 roto sobre la union.
#
# Y POR ESO ESTE CASO ES DE CONFORMIDAD, NO UN DISCRIMINANTE: el duplicado es INTERMITENTE
# --depende del entrelazado-- asi que una vuelta suelta pasa tambien contra el codigo viejo,
# y de hecho pasa. Lo que aporta es lo contrario: tres vueltas que exigen el resultado que
# (iv) contrata, para que una regresion tenga tres oportunidades de salir. Quien quiera el
# fail-before de esta parte lo tiene medido arriba, fuera del banco, con su frecuencia.
car_dupe=0
for CAR_V in 1 2 3; do
  car_proj true
  CAR_J="$(CLAUDE_PROJECT_DIR="$RP4" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')"
  : > "$ERRLOG"
  printf '%s' "$CAR_J" | CLAUDE_PROJECT_DIR="$RP4" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG" & CAR_A=$!
  printf '%s' "$CAR_J" | CLAUDE_PROJECT_DIR="$RP4" "$HOOKS_DIR/stop.sh" >/dev/null 2>>"$ERRLOG" & CAR_B=$!
  wait "$CAR_A"; wait "$CAR_B"
  CAR_H="$RP4/requirements/historial/REQ-450.md"
  # a lo sumo un bloque, ninguna fila repetida, y CA-05 sobre la union de origen y destino
  [ "$(rsec_cnt '^<!-- ARNES:ROTADO' "$CAR_H")" -le 1 ] || car_dupe=$((car_dupe+1))
  [ "$(grep -h '^| 2026-01-' "$CAR_H" 2>/dev/null | sort | uniq -d | wc -l | tr -d ' ')" -eq 0 ] || car_dupe=$((car_dupe+1))
  cmp -s <(grep '^| 2026-01-' "$RP4/antes.md" | sort) \
         <(cat <(grep '^| 2026-01-' "$RP4/requirements/REQ-450.md") <(grep '^| 2026-01-' "$CAR_H" 2>/dev/null) | sort) \
    || car_dupe=$((car_dupe+1))
  rm -rf "$RP4"
done
rsec_check "CA-18 (iv) dos rotaciones a la vez, tres vueltas: nunca dos bloques, ni filas duplicadas, ni CA-05 roto" "0" "$car_dupe"
