# Sección 47 del banco — 47-decision-emitida
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# 1.36.0, paso 6, FASE 1 (casos con fail-before, SIN reparar): REQ-007 CA-67, CA-68 y CA-69, a NIVEL DE HOOK,
# Linux/WSL2, bajo C.UTF-8, con las TRES comprobaciones separadas de REQ-031 CA-A15 punto 4 —(a) respuesta,
# código de salida, JSON válido y duración bajo `timeout 60`, como el cliente; (b) la decisión que recibe el
# entorno; (c) el archivo protegido tras aplicar lo que la herramienta haría si no se deniega—:
#   D  SEC-118 / CA-67: toda denegación decidida se EMITE —los puntos que en 1.35.0 salían sin decisión, y sus
#      dos controles (1 601 líneas ASCII largas y 2 501 cortas, que ya deniegan)—;
#   A  SEC-118 / CA-67, «Los avisos entran»: el `QA:` y el `Seguridad:` de unos 140 KB, por Edit SIN cerrar, con
#      contenido ASCII, de 2 y de 4 bytes: el aviso llega (JSON con `systemMessage`) y la decisión no cambia;
#   T  SEC-115 / CA-68: T1 (R-044-C §2, vía (a)), T2 (vía (b), 2 025 113 y 1 012 650 bytes) y T3 (R-045-A §5, la
#      búsqueda del `old_string`; tamaño por el procedimiento registrado antes de medir en el árbol de evidencia,
#      cand-1.36.0/sec115-118/00-): `deny` emitido en no más de 40 s (el plazo de P-136-C);
#   M  SEC-129 / CA-68 (ii): las filas de `casos` de cand-1.36.0/sec127/seg-posix/02-matriz.sh (su sitio único)
#      en seis modos —normal, POSIXLY_CORRECT=1, POSIXLY_CORRECT vacía, SHELLOPTS=posix (lanzada con `env`: asignada
#      desde un bash es de sólo lectura y la fila no valdría), BASH_ENV con `set -o posix` y `bash --posix`—, por
#      guard.sh, y las tres de Bash además por su guardián: la misma decisión que en modo normal.
# UN SOLO ÁRBOL, `$HOOKS_DIR`. El fail-before (CA-69 punto 1) se mide corriendo esta sección con ARNES_HOOKS_DIR en
# los hooks de 78a2f33 y en los de v1.35.0: los casos D, A, T y M que esperan otra cosa que el modo normal salen
# FAIL en los dos, y los controles PASS (docs/arnes/v1.36.0-sec115-118-fase1.md). T1 y T2b (1 MB) no reproducen
# su fail-before aquí (deciden antes de 60 s en los dos árboles) y quedan como CONTROLES; T2b, medida de 29 a 49 s,
# roza el plazo de 40 s y antes de la reparación puede salir FAIL por (a). Esto NO es el host.
CASOS_ESPERADOS_SECCION=93
PISO_AUTONOMO_SECCION=81  # 26 preámbulo (líneas 1-26, con seccion_nueva) + 0 maquinaria compartida duplicada (ninguna) + 55 bloque indivisible mayor (r47, h47 y j47, el brazo y el juez de los casos, líneas 32-86)
seccion_nueva "--- 47 · la decisión se emite siempre (SEC-118, SEC-115, SEC-129; REQ-007 CA-67, CA-68) ---"
PD47="$RAIZ/de47-$BASHPID"; W47="$RAIZ/w47-$BASHPID"; mkdir -p "$W47"; BE47="$W47/bashenv"; printf 'set -o posix\n' > "$BE47"
O47=''; RC47=0; MS47=0; E47_IN=''; E47_APLICA=':'; E47_F=''; E47_C=intacto
# El locale UTF-8 del que dependen los casos multibyte: sin él no medirían lo que dicen. SKIP con motivo.
U47="$(env -u LC_ALL LANG=C.UTF-8 "$BASH" -c 'x=ñ; printf %s "${#x}"' 2>/dev/null)"
U47_MOT='el locale C.UTF-8 no está disponible en este anfitrión: el caso multibyte no mediría lo que dice'
# r47 <guardián> <modo> <entrada> -> O47, RC47, MS47. El BRAZO: ejecuta el hook como lo lanza el cliente, con
# `timeout 60`, en el directorio del proyecto, LANG=C.UTF-8 y sin LC_ALL; no juzga nada.
r47() {
  local s="$1" m="$2" t0 t1
  : > "$ERRLOG"; t0=${EPOCHREALTIME/./}
  O47="$(cd "$PD47" || exit 97; unset LC_ALL POSIXLY_CORRECT BASH_ENV SHELLOPTS 2>/dev/null
    export LANG=C.UTF-8 CLAUDE_PROJECT_DIR="$PD47"
    case "$m" in
      normal)   timeout 60 "$BASH" "$HOOKS_DIR/$s" ;;
      PC=1)     POSIXLY_CORRECT=1 timeout 60 "$BASH" "$HOOKS_DIR/$s" ;;
      PC=)      POSIXLY_CORRECT= timeout 60 "$BASH" "$HOOKS_DIR/$s" ;;
      SHELLOPTS) timeout 60 env SHELLOPTS=posix "$BASH" "$HOOKS_DIR/$s" ;;
      BASH_ENV) BASH_ENV="$BE47" timeout 60 "$BASH" "$HOOKS_DIR/$s" ;;
      --posix)  timeout 60 "$BASH" --posix "$HOOKS_DIR/$s" ;;
      *)        exit 98 ;;
    esac < "$3" 2>>"$ERRLOG")"; RC47=$?
  t1=${EPOCHREALTIME/./}; MS47=$(( (t1 - t0) / 1000 ))
}
# h47 -> la huella de los archivos protegidos del caso (E47_F): contenido por cksum, o `-` si no existe.
h47() { local f r=''; for f in $E47_F; do if [ -e "$PD47/$f" ]; then r+="$f=$(cksum < "$PD47/$f");"; else r+="$f=-;"; fi; done; printf '%s' "$r"; }
# j47 <nombre> <esperado: deny|aviso|nada> <guardián> <modo> <plazo_ms|-> — sobre E47_IN (la entrada),
# E47_APLICA (lo que la herramienta haría si el entorno no recibe deny), E47_F y E47_C (intacto: la huella no
# cambia; abierto: el REQ no queda en `Estado: completado`). Las tres comprobaciones, por separado.
j47() {
  local nom="$1" esp="$2" s="$3" m="$4" plazo="$5" ent="$E47_IN" sal got a='' c cok=si antes despues nb
  if [ -n "$FILTRO" ] && ! printf '%s' "$nom" | grep -qi -- "$FILTRO"; then return 0; fi
  json_no_vacio "$nom" "$ent" || { FAIL=$((FAIL + 1)); return 0; }
  printf '%s' "$ent" > "$W47/in"; antes="$(h47)"
  r47 "$s" "$m" "$W47/in"; sal="$O47"; nb="$(LC_ALL=C; printf '%s' "${#sal}")"
  # (a) que el hook RESPONDA, con código 0, JSON válido (o nada) y, si el caso lo pide, dentro del plazo.
  if [ "$RC47" -eq 124 ]; then a="(a) NO RESPONDIÓ en 60 s: el timeout lo cortó, y un hook muerto no decide"
  elif [ "$RC47" -ne 0 ]; then a="(a) código de salida $RC47, no 0"
  elif [ -n "$sal" ] && ! jq -e . >/dev/null 2>&1 <<< "$sal"; then a="(a) la salida no es un JSON válido"
  elif [ "$plazo" != - ] && [ "$MS47" -gt "$plazo" ]; then a="(a) respondió en ${MS47}ms, por encima del plazo de ${plazo}ms"; fi
  # (b) la decisión que recibe el entorno.
  case "$sal" in
    *'"permissionDecision":"deny"'*) got=deny ;;
    *'"systemMessage"'*)              got=aviso ;;
    '')                               got=nada ;;
    *)                                got=otra ;;
  esac
  # (c) si el entorno no recibe deny, la herramienta se ejecuta: se aplica y se mira el archivo protegido.
  [ "$got" = deny ] || (cd "$PD47" && eval "$E47_APLICA") >/dev/null 2>&1
  despues="$(h47)"
  case "$E47_C" in
    intacto) if [ "$antes" = "$despues" ]; then c='(c) intacto'; else c='(c) MODIFICADO'; cok=no; fi ;;
    abierto) if grep -q '^Estado: completado' "$PD47/requirements/REQ-950.md"; then c='(c) CERRADO'; cok=no; else c='(c) sin cerrar'; fi ;;
    *)       c='(c) -' ;;
  esac
  if [ -z "$a" ] && [ "$got" = "$esp" ] && [ "$cok" = si ]; then
    echo "  PASS  $nom  (a) rc 0 en ${MS47}ms, salida ${nb} bytes; (b) $got; $c"; PASS=$((PASS + 1))
  else
    echo "  FAIL  $nom  ${a:-(a) rc $RC47 en ${MS47}ms}, salida ${nb} bytes; (b) esperado=$esp got=$got; $c"; diag; FAIL=$((FAIL + 1))
  fi
}
# rep47 <n> <texto> -> el texto n veces (por duplicación: sin un printf por repetición).
rep47() { local n="$1" s="$2" r=''; while [ "$n" -gt 0 ]; do [ $((n & 1)) -eq 0 ] || r+="$s"; s+="$s"; n=$((n >> 1)); done; printf '%s' "$r"; }
# pr47 -> un proyecto recién hecho, con el manifiesto base del corredor, en PD47.
pr47() {
  rm -rf "$PD47"; mkdir -p "$PD47/.arnes" "$PD47/requirements" "$PD47/src" "$PD47/docs"
  printf '%s\n' "$MANIFIESTO_BASE" > "$PD47/.arnes/config.json"; printf '## Pendientes\n\n## Resueltas\n' > "$PD47/PENDING_APPROVAL.md"
}
# w47 <en disco> <contenido>: un Write de la coordinadora a requirements/REQ-950.md. La entrada se arma desde
# ARCHIVO (`jq -Rs`): por `--arg` el emisor revienta a 128 KB y el caso no mediría nada.
w47() {
  pr47; cp "$1" "$PD47/requirements/REQ-950.md"
  E47_IN="$(jq -Rs --arg fp "$PD47/requirements/REQ-950.md" --arg c "$PD47" \
    '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:$c,tool_input:{file_path:$fp,content:.}}' < "$2")"
  E47_APLICA="cp '$2' requirements/REQ-950.md"; E47_F='requirements/REQ-950.md'
}
# e47: un Edit de la coordinadora; en disco pre+old+post, y lo que la herramienta escribiría, pre+new+post
# (los cuatro trozos en $W47; se construye el «después» en vez de buscar `old` en el texto, que en T3 es
# justo la operación cara que el caso mide).
e47() {
  pr47; cat "$W47/pre" "$W47/old" "$W47/post" > "$PD47/requirements/REQ-950.md"; cat "$W47/pre" "$W47/new" "$W47/post" > "$W47/desp"
  E47_IN="$(jq -n --rawfile o "$W47/old" --rawfile n "$W47/new" --arg fp "$PD47/requirements/REQ-950.md" --arg c "$PD47" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$c,tool_input:{file_path:$fp,old_string:$o,new_string:$n}}')"
  E47_APLICA="cp '$W47/desp' requirements/REQ-950.md"; E47_F='requirements/REQ-950.md'
}
CAB47='# REQ-950\nEstado: %s\nQA: %s\nSeguridad: %s\nSensible a seguridad: sí\nRigor: critico\n'
# hall47 <n> <valor>: la cabecera, que sin la repetición cerraría, con `Hallazgos abiertos: <valor>` n veces, por Write.
hall47() {
  { printf "$CAB47" completado aprobado aprobado; rep47 "$1" "Hallazgos abiertos: $2"$'\n'; printf '\n## Texto\nx\n'; } > "$W47/cont"
  { printf "$CAB47" en-revisión aprobado aprobado; printf '\n## Texto\nx\n'; } > "$W47/disco"; w47 "$W47/disco" "$W47/cont"
}
# g47 <a|2|4> -> unos 140 KB (143 360 bytes) de `x`, de `ñ` o de `𝄞`.
g47() { case "$1" in a) rep47 143360 x ;; 2) rep47 71680 ñ ;; 4) rep47 35840 𝄞 ;; esac; }
# trozos47 <pre> <old> <new> <post> (printf-formatos sin argumentos; el nuevo puede llevar un relleno en $W47/g)
trozos47() { printf "$1" > "$W47/pre"; printf "$2" > "$W47/old"; printf "$3" > "$W47/new"; printf "$4" > "$W47/post"; }
POST47='\nSensible a seguridad: sí\nRigor: critico\n\n## Texto\nx\n'
# pg47: el proyecto de SEC-129, con la cabecera de 02-matriz.sh, en un repositorio git con un cambio sin
# confirmar (docs/t.txt) y un archivo sin seguimiento (docs/u.txt): lo que `reset --hard` y `clean -fd` borrarían.
pg47() {
  pr47; printf '# REQ-900\nEstado: en-revision\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: si\n\n## Texto\nx\n' > "$PD47/requirements/REQ-900.md"
  printf 'orig\n' > "$PD47/src/a.ts"; printf 'base\n' > "$PD47/docs/t.txt"
  git -C "$PD47" init -q 2>/dev/null && git -C "$PD47" add -A && git -C "$PD47" -c user.name=banco -c user.email=banco@invalid \
    -c core.hooksPath=/dev/null -c commit.gpgsign=false commit -qm base >/dev/null 2>&1 || return 1
  printf 'local\n' > "$PD47/docs/t.txt"; printf 'nuevo\n' > "$PD47/docs/u.txt"
  E47_F='src/a.ts requirements/REQ-900.md docs/t.txt docs/u.txt'; E47_C=intacto
}

# --- D · SEC-118 / CA-67: la denegación decidida se emite -----------------------------------------------
# Las líneas repetidas: el motivo cita 60 caracteres de cada una. Valores: L66 = 66 caracteres ASCII; CORTA = 29
# ASCII; N2 = 66 con 40 `ñ`; N4 = 66 con 40 caracteres de 4 bytes; CN = 32 caracteres con 12 `ñ`. Los bytes del
# motivo que el hook INTENTA emitir están medidos fuera del banco (cand-1.36.0/sec115-118/05-).
L47="QA-1 (instrumento, $(rep47 40 r))"; C47='(ninguno)'; N2_47="QA-1 (instrumento, $(rep47 40 ñ))"
N4_47="QA-1 (instrumento, $(rep47 40 𝄞))"; CN47="$(rep47 12 ñ)"; E47_C=intacto
hall47 1601 "$L47"
j47 "SEC-118 CA-67 D0a control: 'Hallazgos abiertos:' 1601 veces, líneas ASCII de 66 caracteres, por Write -> deny" deny guard.sh normal -
hall47 2501 "$C47"
j47 "SEC-118 CA-67 D0b control: 'Hallazgos abiertos:' 2501 veces, líneas ASCII de 29 caracteres, por Write -> deny" deny guard.sh normal -
hall47 1801 "$L47"
j47 "SEC-118 CA-67 D1 'Hallazgos abiertos:' 1801 veces, líneas ASCII de 66 caracteres, por Write -> deny emitido" deny guard.sh normal -
hall47 3000 "$C47"
j47 "SEC-118 CA-67 D2 'Hallazgos abiertos:' 3000 veces, líneas ASCII de 29 caracteres, por Write -> deny emitido" deny guard.sh normal -
if [ "$U47" = 1 ]; then
  hall47 1601 "$N2_47"
  j47 "SEC-118 CA-67 D3 'Hallazgos abiertos:' 1601 veces con ñ, por Write -> deny emitido" deny guard.sh normal -
  hall47 1001 "$N4_47"
  j47 "SEC-118 CA-67 D4 'Hallazgos abiertos:' 1001 veces con caracteres de 4 bytes, por Write -> deny emitido" deny guard.sh normal -
  hall47 2501 "$CN47"
  j47 "SEC-118 CA-67 D5 'Hallazgos abiertos:' 2501 veces, cortas con ñ, por Write -> deny emitido" deny guard.sh normal -
else
  for d47 in D3 D4 D5; do echo "  SKIP  SEC-118 CA-67 $d47 multibyte  $U47_MOT"; done
fi
# Por Edit, unos 140 KB que el motivo cita enteros: QA y Seguridad sin paréntesis final, Sensible a seguridad
# dudoso y una línea de cabecera sin `:` con un retorno de carro interior.
G47="$(g47 a)"
trozos47 '# REQ-950\n' 'Estado: en-revisión\nQA: pendiente\nSeguridad: pendiente' "Estado: completado\nQA: pendiente ${G47}\nSeguridad: pendiente" "$POST47"; e47
j47 "SEC-118 CA-67 D6 'QA:' de unos 140 KB sin paréntesis final, cierre por Edit -> deny emitido" deny guard.sh normal -
trozos47 '# REQ-950\n' 'Estado: en-revisión\nQA: pendiente\nSeguridad: pendiente' "Estado: completado\nQA: aprobado\nSeguridad: pendiente ${G47}" "$POST47"; e47
j47 "SEC-118 CA-67 D7 'Seguridad:' de unos 140 KB sin paréntesis final, cierre por Edit -> deny emitido" deny guard.sh normal -
trozos47 '# REQ-950\n' 'Estado: en-revisión\nQA: aprobado\nSeguridad: pendiente\nSensible a seguridad: sí' \
  "Estado: completado\nQA: aprobado\nSeguridad: pendiente\nSensible a seguridad: quizá ${G47}" '\nRigor: critico\n\n## Texto\nx\n'; e47
j47 "SEC-118 CA-67 D8 'Sensible a seguridad:' dudoso de unos 140 KB, cierre por Edit -> deny emitido" deny guard.sh normal -
trozos47 '# REQ-950\n' 'Estado: en-revisión' "Estado: completado\nNota sin dos puntos ${G47:0:71680}\r${G47:0:71680}" \
  '\nQA: aprobado\nSeguridad: aprobado\nSensible a seguridad: sí\nRigor: critico\n\n## Texto\nx\n'; e47
j47 "SEC-118 CA-67 D9 línea de cabecera sin ':' de unos 140 KB con un retorno de carro interior, cierre por Edit -> deny emitido" deny guard.sh normal -

# --- A · SEC-118 / CA-67, «Los avisos entran»: el aviso llega y la decisión no cambia ---------------------
# Un Edit que NO cierra: el veredicto fuera del vocabulario, de unos 140 KB, da aviso (AGENTS.md §13, «Un hook
# que avisa sin decidir»); la decisión de v1.35.0 es ninguna (allow). (c): el REQ queda sin cerrar.
E47_C=abierto
for c47 in a 2 4; do
  for k47 in QA Seguridad; do
    case "$c47" in a) q47='ASCII' ;; *) q47="de $c47 bytes" ;; esac
    nom47="SEC-118 CA-67 A $k47 de unos 140 KB fuera del vocabulario, contenido $q47, Edit sin cerrar -> aviso emitido, sin decisión"
    if [ "$c47" != a ] && [ "$U47" != 1 ]; then echo "  SKIP  $nom47  $U47_MOT"; continue; fi
    if [ "$k47" = QA ]; then trozos47 '# REQ-950\nEstado: en-revisión\n' 'QA: pendiente' "QA: pendiente $(g47 "$c47")" "\nSeguridad: pendiente$POST47"
    else trozos47 '# REQ-950\nEstado: en-revisión\nQA: pendiente\n' 'Seguridad: pendiente' "Seguridad: pendiente $(g47 "$c47")" "$POST47"; fi
    e47; j47 "$nom47" aviso guard.sh normal -
  done
done

# --- T · SEC-115 / CA-68: un juicio que no termina a tiempo emite deny en no más de 40 s -----------------
E47_C=intacto; P47T=40000
# T1, R-044-C §2 vía (a): `QA: pendiente (…)` con unos 255 KB de evidencia con blancos y un Edit a completado.
trozos47 '# REQ-950\n' 'Estado: en-revisión' 'Estado: completado' "\nQA: pendiente ($(rep47 25500 'evidencia '))\nSeguridad: pendiente\nRigor: critico\n\n## Texto\nx\n"; e47
j47 "SEC-115 CA-68 T1 control del fail-before: QA pendiente con unos 255 KB de evidencia con blancos, Edit a completado -> deny en no más de 40 s" deny guard.sh normal "$P47T"
# T2, vía (b): un Write con la cabecera pendiente y cuerpo de líneas de 80 bytes, de 2 025 113 y de 1 012 650 bytes.
for t47 in 2025113 1012650; do
  { printf "$CAB47" completado pendiente pendiente; printf '\n## Texto\n'; } > "$W47/cont"
  f47="$(( (t47 - $(wc -c < "$W47/cont")) / 80 ))"; rep47 "$f47" "$(rep47 4 'relleno de cuerpo ')relleno"$'\n' >> "$W47/cont"
  f47="$(( t47 - $(wc -c < "$W47/cont") ))"; [ "$f47" -le 0 ] || { rep47 $((f47 - 1)) z; printf '\n'; } >> "$W47/cont"
  printf "$CAB47" en-revisión pendiente pendiente > "$W47/disco"; w47 "$W47/disco" "$W47/cont"
  case "$t47" in
    2025113) j47 "SEC-115 CA-68 T2a Write de 2025113 bytes con la cabecera pendiente -> deny en no más de 40 s" deny guard.sh normal "$P47T" ;;
    *)       j47 "SEC-115 CA-68 T2b control del fail-before: Write de 1012650 bytes con la cabecera pendiente -> deny en no más de 40 s" deny guard.sh normal "$P47T" ;;
  esac
done
# T3, R-045-A §5: una racha de 256 000 `a` en la línea de título y un old_string de media racha, literal al final
# y seguido de la línea de Estado, que el Edit cierra. 256 000 sale del barrido registrado antes de medir
# (cand-1.36.0/sec115-118/00- y 02-: el primer tamaño que en v1.35.0 pasa de 60 s).
trozos47 "# REQ-950 $(rep47 128000 a)" "$(rep47 128000 a)\nEstado: en-revisión" "$(rep47 128000 a)\nEstado: completado" \
  '\nQA: pendiente\nSeguridad: pendiente\nSensible a seguridad: sí\nRigor: critico\n\n## Texto\nx\n'; e47
j47 "SEC-115 CA-68 T3 búsqueda del old_string de 128000 bytes en una racha de 256000, Edit a completado -> deny en no más de 40 s" deny guard.sh normal "$P47T"

# --- M · SEC-129 / CA-68 (ii): ninguna decisión depende del modo del intérprete heredado -----------------
# Las filas de `casos` de 02-matriz.sh, de la coordinadora: <herramienta>|<esperado>|<guardián propio o ->|<objetivo>.
# El objetivo de Write/Edit es relativo al proyecto; el de Bash, la orden, que es también lo que se aplica.
M47=(
  "Write|deny|-|src/a.ts"
  "Write|deny|-|requirements/REQ-900.md"
  "Edit|deny|-|requirements/REQ-900.md"
  "Bash|deny|guard-codigo.sh|echo x > src/a.ts"
  "Bash|deny|-|printf x | tee src/a.ts"
  "Bash|deny|guard-completado.sh|sed -i s/en-revision/completado/ requirements/REQ-900.md"
  "Bash|deny|guard-git.sh|git reset --hard"
  "Bash|deny|-|git clean -fd"
  "Bash|nada|-|ls -la"
)
for f47 in "${M47[@]}"; do
  IFS='|' read -r t47 x47 g47s o47 <<< "$f47"
  case "$t47" in
    Write) [ "$o47" = src/a.ts ] && { k47='"x"'; a47='printf x > src/a.ts'; } \
             || { k47='"# REQ-900\nEstado: completado\nQA: pendiente\nSeguridad: pendiente\n"'; a47="printf '# REQ-900\nEstado: completado\nQA: pendiente\nSeguridad: pendiente\n' > $o47"; }
           ti47="{file_path:(\$c+\"/$o47\"),content:$k47}" ;;
    Edit)  ti47="{file_path:(\$c+\"/$o47\"),old_string:\"Estado: en-revision\",new_string:\"Estado: completado\"}"
           a47="sed -i 's/Estado: en-revision/Estado: completado/' $o47" ;;
    Bash)  ti47='{command:$k}'; a47="$o47" ;;
  esac
  for m47 in normal PC=1 PC= SHELLOPTS BASH_ENV --posix; do
    for s47 in guard.sh "$g47s"; do
      [ "$s47" != - ] || continue
      etq47="modo $m47"; [ "$m47" != normal ] || etq47='modo normal (control)'
      [ "$x47" != nada ] || etq47="$etq47, control sin falso positivo"
      nom47="SEC-129 CA-68 (ii) M $t47 $o47, $etq47, por $s47 -> ${x47/nada/sin decisión}"
      if ! pg47; then echo "  FAIL  $nom47  no se pudo preparar el repositorio del proyecto (git)"; FAIL=$((FAIL + 1)); continue; fi
      E47_IN="$(jq -cn --arg c "$PD47" --arg k "$o47" "{hook_event_name:\"PreToolUse\",tool_name:\"$t47\",cwd:\$c,session_id:\"s\",tool_input:$ti47}")"
      E47_APLICA="$a47"
      j47 "$nom47" "$x47" "$s47" "$m47" -
    done
  done
done
rm -rf "$PD47" "$W47"
