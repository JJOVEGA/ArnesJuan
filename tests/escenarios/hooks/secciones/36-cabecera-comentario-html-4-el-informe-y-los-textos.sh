# Sección 36 (4 de 5) del banco — 36-cabecera-comentario-html-4-el-informe-y-los-textos
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
#
# CUARTO ARCHIVO, y el motivo es el límite que el banco se impone a sí mismo: ningún
# archivo de sección pasa de 400 líneas (`autoprueba-corredor.sh`, CA-18). Al añadir a
# `36-…-2-los-lectores.sh` el par con un CR interior y las guardas que le faltaban a sus
# casos (H-01 y H-02), esa mitad llegó a 459 líneas. La costura elegida NO es «cortar por
# donde cabe» sino la que ya estaba en el texto: la 2 certifica lo que la MÁQUINA LEE
# —los dos lectores y la invariante sobre el corpus—; aquí van lo que el INFORME DICE
# (CA-05, CA-06), el coste de la lectura (CA-08) y los TEXTOS que un proyecto hereda
# (CA-09, CA-10). La quinta —`36-…-5-el-cr-que-no-termina.sh`— nació en la vuelta 2 por la
# misma costura y el mismo límite: la guarda del CR interior (SEC-024) no cabía en la 1, que
# ya iba por 347 líneas. Las cinco mitades son independientes: ninguna hace `source` de otra
# ni depende del estado que deje.
#
# FAIL-BEFORE: como el resto de la sección 36,
#   ARNES_HOOKS_DIR=/ruta/a/los/hooks/de/1.32.0 bash tests/escenarios/hooks/run.sh secciones/36-*.sh
# y los casos que llevan «(era ALLOW)» tienen que fallar ahí. Los de CA-09/CA-10 son sobre
# TEXTO del repositorio y no sobre los hooks bajo prueba: se derivan de `$SEC_DIR` a
# propósito, para que apuntar el banco a una instalación anterior siga midiendo los hooks
# viejos contra los textos de HOY.
CASOS_ESPERADOS_SECCION=23
PISO_AUTONOMO_SECCION=103  # 26 preámbulo + 18 maquinaria compartida duplicada + 59 bloque indivisible mayor · REQ-014 CA-18
  seccion_nueva "Noción de cita (4/5): lo que el informe dice, el coste y los textos heredados (REQ-016):"

# ---------- CA-05 y CA-06 · EL INFORME NOMBRA LA LINEA QUE GOBIERNA ----------
# Tras acotar donde se lee, queda un residual que NO es un defecto y no se prohibe: una
# linea con la clave decorada o sangrada FUERA de todo rango sigue pudiendo gobernar, y la
# produce el CORTE DE UN PARRAFO, no su contenido — el ajuste de linea deja la clave al
# principio de un renglon. Eso es forma legitima (CA-04), asi que se hace VISIBLE en vez de
# prohibirse. Y se separa del hallazgo: en el barrido de un proyecto real, 28 de 42
# anomalias del informe eran falsas y el ruido enterraba las 14 verdaderas.
LP="$(mktemp -d)"; mkdir -p "$LP/.arnes" "$LP/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$LP/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$LP/PENDING_APPROVAL.md"

# CA-05: la clave decorada gobierna y el valor es impecable -> se NOMBRA...
printf '# REQ-970\nEstado: en-revisión\nQA: aprobado\n**Seguridad:** aprobado\n' > "$LP/requirements/REQ-970.md"
lec_check "REQ-016 CA-05 la línea decorada que gobierna se nombra, con la línea tal como está escrita" \
  0 'LÍNEAS DECORADAS QUE GOBIERNAN' si
lec_check "REQ-016 CA-05 ...y enseña la línea literal y el valor que lee la máquina" \
  0 'linea:    «\*\*Seguridad:\*\* aprobado»' si
# CA-06: y NO altera el codigo de salida por si solo.
lec_check "REQ-016 CA-06 el aviso de forma NO cambia el código de salida (sale 0)" \
  0 'VALORES QUE LA MÁQUINA NO LEE' no
# CA-06: DOS declaraciones del mismo campo y gobierna la decorada -> ANOMALIA, salida != 0.
printf '# REQ-971\nEstado: en-revisión\nQA: aprobado\nSeguridad: pendiente\n**Seguridad:** aprobado\n' > "$LP/requirements/REQ-971.md"
lec_check "REQ-016 CA-06 dos declaraciones y gobierna la decorada -> anomalía con salida ≠ 0" \
  1 'REQ-971' si
lec_check "REQ-016 CA-06 ...y lo dice por la vía única de las anomalías, no en el bloque de forma" \
  1 'VALORES QUE LA MÁQUINA NO LEE COMO ESTÁN ESCRITOS' si
rm -f "$LP/requirements/REQ-971.md"
# El rango SIN CERRAR si es anomalia: es exactamente lo que la puerta deniega.
printf '# REQ-972\nEstado: en-revisión\nQA: aprobado\nSeguridad: aprobado\n<!-- nota sin cerrar\n\n## Historia\n' > "$LP/requirements/REQ-972.md"
lec_check "REQ-016 CA-05 un rango sin cerrar en la cabecera es anomalía y lo dice (sale 1)" \
  1 'abre un comentario HTML que no cierra' si
rm -f "$LP/requirements/REQ-972.md"
# Y el caso PELIGROSO que hasta 1.32.0 pasaba callado: el informe decia `rc 0` y «ningun
# valor anomalo» sobre el REQ que la puerta iba a cerrar sin auditoria. Ahora el informe lee
# lo que lee la puerta: el veredicto vigente es `pendiente` y la cita no gobierna nada.
rm -f "$LP/requirements/REQ-970.md"
printf '# REQ-973\nEstado: en-revisión\nSensible a seguridad: sí\nQA: aprobado\nSeguridad: pendiente\n<!-- historia:\n**Seguridad:** aprobado\n-->\n' > "$LP/requirements/REQ-973.md"
lec_check "REQ-016 CA-01 el informe no reporta la cita como anomalía: dentro del rango no hay campo" \
  0 'REQ-973' no
lec_check "REQ-016 CA-01 ...y tampoco la cuenta como línea decorada que gobierna" \
  0 'LÍNEAS DECORADAS QUE GOBIERNAN' no
rm -rf "$LP"

# ---------- CA-08 · EL COSTE DE LA LECTURA NO SUBE ----------
# La nocion de cita se paga con expansion de parametros, como el resto del lector. Dos
# medidas, una por lector.
# PRIMERO SE EXIGE QUE LA FUNCION EXISTA. Un rango de awk cuyo inicio no casa nunca
# devuelve VACIO, y un `grep -q` sobre vacio no encuentra nada: el caso salia verde contra
# los hooks de 1.32.0, donde `arnes_sin_cita` NO existe (H-02.d). Una guarda que pasa
# cuando lo que guarda no esta no guarda nada.
CUERPO36="$(awk '/^arnes_sin_cita\(\)/,/^}/' "$HOOKS_DIR/lib.sh")"
if [ -z "$CUERPO36" ]; then
  echo "  FAIL  REQ-016 CA-08 no existe 'arnes_sin_cita' en $HOOKS_DIR/lib.sh: no hay noción de cita que medir"; FAIL=$((FAIL+1))
elif printf '%s\n' "$CUERPO36" | grep -Eq '\b(sed|tr|awk|grep|cut|iconv|perl|python3?)\b'; then
  echo "  FAIL  REQ-016 CA-08 la noción de cita invoca un binario externo en el camino de la puerta"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-016 CA-08 'arnes_sin_cita' existe y es sólo expansión de parámetros (ningún proceso)"; PASS=$((PASS+1))
fi
# El bloque derivado sigue haciendo UNA sola pasada de awk sobre TODOS los REQ, con citas y
# sin ellas: se instrumenta `awk` en el PATH y se cuentan las invocaciones.
BIN36="$RAIZ/bin36-$BASHPID"; mkdir -p "$BIN36"
awk_real36="$(command -v awk 2>/dev/null || true)"
printf '#!/bin/sh\necho x >> "%s/registro-awk"\nexec %s "$@"\n' "$BIN36" "${awk_real36:-/bin/true}" > "$BIN36/awk"
chmod +x "$BIN36/awk"
mkdir -p "$PROJ/docs"
cuenta_awk36() {   # <con|sin> -> deja FORKS36
  local n
  : > "$BIN36/registro-awk"
  printf '%s' "$(jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')" \
    | PATH="$BIN36:$PATH" bash "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>>"$ERRLOG"
  n="$(wc -l < "$BIN36/registro-awk" 2>/dev/null || echo 0)"
  FORKS36="${n// /}"
}
rm -f "$PROJ/requirements/"*.md
printf '# ESTADO\n\n## Fase\nx\n' > "$PROJ/docs/ESTADO.md"
for n36 in 1 2 3 4 5; do
  printf '# REQ-98%s\nEstado: en-revisión\nQA: aprobado\nSeguridad: n/a\n' "$n36" > "$PROJ/requirements/REQ-98$n36.md"
done
cuenta_awk36; sin36="$FORKS36"
for n36 in 1 2 3 4 5; do
  printf '# REQ-98%s\nEstado: en-revisión\nQA: aprobado\nSeguridad: n/a\n<!-- historia:\n**Seguridad:** con-hallazgos\n-->\n' "$n36" > "$PROJ/requirements/REQ-98$n36.md"
done
printf '# ESTADO\n\n## Fase\nx\n' > "$PROJ/docs/ESTADO.md"
cuenta_awk36; con36="$FORKS36"
if [ -n "$sin36" ] && [ "$sin36" -gt 0 ] && [ "$con36" = "$sin36" ]; then
  echo "  PASS  REQ-016 CA-08 el bloque derivado gasta las mismas pasadas de awk con citas que sin ellas ($con36)"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-016 CA-08 pasadas de awk: $sin36 sin citas y $con36 con citas"; diag; FAIL=$((FAIL+1))
fi
rm -f "$PROJ/requirements/"*.md

# ---------- CA-09 y CA-10 · LOS TEXTOS QUE UN PROYECTO HEREDA ----------
# Un arreglo del mecanismo que no llega al proyecto que ya corrio la version afectada deja
# el dano hecho y sin auditar. Estos casos son sobre TEXTO a proposito: es la unica parte de
# esta version que exige una accion humana.
# LOS TEXTOS VIVEN EN EL REPOSITORIO, NO EN LOS HOOKS BAJO PRUEBA: la ruta se deriva del
# directorio de secciones y no de `$HOOKS_DIR`, para que apuntar el banco a una instalacion
# anterior (fail-before) siga midiendo los hooks viejos contra los textos de HOY — que es
# justo lo que hay que distinguir.
REPO36="${SEC_DIR%/}/../../../.."
SK36="$REPO36/skills/arnes-upgrade/SKILL.md"
mira36() {   # <nombre> <archivo> <regex> — el archivo tiene que decirlo
  local nombre="$1" archivo="$2" patron="$3" hay
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ ! -f "$archivo" ]; then
    echo "  FAIL  $nombre  no existe $archivo"; FAIL=$((FAIL+1)); return 0
  fi
  hay="$(grep -c -E -- "$patron" "$archivo" 2>/dev/null || true)"; hay="${hay:-0}"
  if [ "$hay" -gt 0 ]; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  ningún renglón de ${archivo##*/} casa /$patron/"; FAIL=$((FAIL+1)); fi
}
mira36 "REQ-016 CA-09 la migración lo dice sin eufemismo: se pudo cerrar un critico sin auditoría" \
  "$SK36" 'pudiste cerrar un REQ .critico. sin auditoría de seguridad aprobada'
mira36 "REQ-016 CA-09 ...y trae el comando que barre las cabeceras con un comentario" \
  "$SK36" 'awk .FNR==1 \{ cab=1 \}'
mira36 "REQ-016 CA-09 ...y dice que la pertenencia de versiones se deriva del historial del lector" \
  "$SK36" 'no es una lista escrita a mano.*: se decide por|se decide por el historial del \*\*lector de cabecera\*\*'
mira36 "REQ-016 CA-09 ...con el comando que lo comprueba tag a tag" \
  "$SK36" 'git show v1\.31\.0:hooks/lib\.sh \| grep -c .arnes_sin_cita'
# SEC-025 · UNA FRASE QUE PROMETIA COMPLETITUD Y ERA FALSA. El barrido busca `<!--`, asi que
# no encuentra ni el delimitador de apertura fabricado (`<!`+CR+`--`) ni la clave fabricada
# (`Seg`+CR+`uridad:`) — las dos medidas en R-007. El remedio NO es ensanchar el patron: es
# que la guia enuncie la pregunta que no envejece —de ESTADO, «¿cuales de mis REQ en estado
# terminal NO cerrarian hoy?»— y que cada barrido POR VIA declare, junto al comando, que
# interroga una via y que su silencio no acredita nada. Estos casos son sobre TEXTO heredado,
# como los de arriba, y por eso viven aqui y no en la mitad 5.
mira36 "REQ-016 CA-09 (i) la guía enuncia la propiedad por ESTADO: 'REQ en estado terminal que NO cerrarían hoy'" \
  "$SK36" 'en estado terminal NO cerrarían hoy'
mira36 "REQ-016 CA-09 (i) ...y dice que la pregunta de estado no envejece con la vía siguiente" \
  "$SK36" 'no envejece con la vía siguiente'
mira36 "REQ-016 CA-09 (ii) ...y que un barrido por vía calla sin acreditar: 'no acredita ausencia de exposición'" \
  "$SK36" 'NO acredita ausencia de exposición'
mira36 "REQ-016 CA-09 (ii) ...y nombra las dos vías conocidas que el comando NO encuentra" \
  "$SK36" 'delimitador de apertura fabricado|clave fabricada'
mira36 "REQ-016 CA-09 ...y dice que ningún comando del apartado responde hoy la pregunta de estado" \
  "$SK36" 'Ningún comando de este apartado la responde todavía'
# EL ORDEN ES PARTE DEL CRITERIO, no una preferencia de redacción: CA-09 (i) exige la propiedad
# ANTES de ofrecer ningún comando, porque una guía que enseña el comando primero se lee hasta el
# comando. Un `grep` de presencia no mide orden; esto sí, y por eso es un caso aparte.
if [ -z "$FILTRO" ] || printf '%s' "REQ-016 CA-09 orden" | grep -qi -- "$FILTRO"; then
  ord36="$(awk '
    /^### Hacia 1\.32\.1/ { dentro = 1 }
    /^## / && !/^### / { dentro = 0 }
    dentro && prop == 0 && /en estado terminal NO cerrarían hoy/ { prop = FNR }
    dentro && cmd == 0 && /^  awk .FNR==1 \{ cab=1 \}/ { cmd = FNR }
    END { printf "%d %d", prop, cmd }
  ' "$SK36")"
  set -- $ord36
  if [ "${1:-0}" -gt 0 ] && [ "${2:-0}" -gt 0 ] && [ "$1" -lt "$2" ]; then
    echo "  PASS  REQ-016 CA-09 (i) la propiedad se enuncia ANTES del primer comando (línea $1 < $2)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-016 CA-09 (i) el orden no se cumple: propiedad en la línea ${1:-0}, primer comando en la ${2:-0}"; FAIL=$((FAIL+1))
  fi
fi
mira36 "REQ-016 CA-10 la plantilla trae la regla: la invariante manda sobre la preferencia de herramienta" \
  "$REPO36/templates/AGENTS.md.tpl" 'La invariante manda sobre cualquier preferencia de herramienta'
mira36 "REQ-016 CA-10 ...con su motivo: quien configura una sesión no suele ser quien lee esa sección" \
  "$REPO36/templates/AGENTS.md.tpl" 'quien.*configura una sesión no suele ser quien lee'
mira36 "REQ-016 CA-10 y también en el AGENTS.md de este repositorio" \
  "$REPO36/AGENTS.md" 'La invariante manda sobre cualquier preferencia de herramienta'

