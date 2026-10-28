# Sección 52 del banco, parte 3 de 3 — 52-adelgazar-lectura-por-rol-3-sin-arnes
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# REQ-036 CA-17, «Inerte sin `.arnes/`» y «Pruebas de la inercia sin `.arnes/`», y CA-18, «El orden del generador»
# (P-137-AI (A), SEC-145): sin `.arnes/` —`.arnes` no resuelve a un directorio— el hook de inicio de sesión sale 0 sin
# emitir nada, sin lanzar el generador y sin leer fuentes, y el generador comprueba `.arnes` (y los enlaces) ANTES de
# abrir ninguna fuente. Tres fixtures —directorio vacío, `AGENTS.md` ajeno, fuente de 1,5 MB—, cada una con fail-before
# contra `7af469c` (la cabeza donde R-063 midió SEC-145, materializada aparte y verificada contra su objeto; sin ella,
# SKIP y motivo, nunca PASS); los controles c1, c2 y c4 no se mueven (pasan en los dos árboles); c3 (`.arnes` archivo o
# enlace roto) es inerte en la candidata y en `7af469c` no lo es, así que lleva fail-before; y las comprobaciones de
# enlace del generador, con las mismas tres fixtures. «Sin lectura» se observa por dos vías que no dependen del reloj:
# el SEÑUELO (un `sha256sum` antepuesto al `PATH` que escribe un centinela y delega en el de verdad) y el mensaje del
# generador, que sólo puede ser «no existe …/.arnes». El reloj: el MÍNIMO de 5 repeticiones del hook, no más de 1 s.
# PARTE 3 DE 3 POR REQ-014 CA-18: la parte 1 está a 9 líneas del tope. Ningún ayudante viene de las otras partes.
CASOS_ESPERADOS_SECCION=18
PISO_AUTONOMO_SECCION=129  # 17 preámbulo (líneas 1-17, con seccion_nueva) + 2 maquinaria compartida duplicada (REPO52/CAND52 y v52, líneas 18-19) + 110 bloque indivisible mayor (el árbol 7af469c, el señuelo, hook52, gen52, foto52, mide52, inerte52, fx52, las fixtures, los controles, enl52 y filai52, líneas 20-129)
seccion_nueva "--- 52 (3/3) · sin .arnes/ el hook y el generador no hacen nada, y la comprobación va primero (REQ-036 CA-17, CA-18, P-137-AI) ---"
REPO52="${SEC_DIR%/}/../../../.."; CAND52="${TPL_DIR%/*}"
v52() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }
ARB52=''; MOT52=''; RC52=0; US52=0; FX52="$RAIZ/fx52i-$BASHPID"; mkdir -p "$FX52"
# El árbol 7af469c: sólo el hook y el generador, cada uno verificado contra su objeto.
RI52="$RAIZ/ri52-$BASHPID"; RI52_OK=si; RI52_MOT=''
for f52 in hooks/inicio-sesion.sh tools/arnes-lectura-rol.sh; do
  mkdir -p "$RI52/${f52%/*}"
  git -C "$REPO52" show "7af469c:$f52" > "$RI52/$f52" 2>/dev/null \
    && [ "$(git -C "$REPO52" hash-object "$RI52/$f52" 2>/dev/null)" = "$(git -C "$REPO52" rev-parse "7af469c:$f52" 2>/dev/null)" ] \
    || { RI52_OK=no; RI52_MOT="7af469c no se materializó ($f52)"; break; }
done
# El señuelo: si se lanza, deja el centinela y delega en el sha256sum de verdad (la base sigue su camino y se mide).
SEN52="$FX52/senuelo"; CEN52="$FX52/centinela"; mkdir -p "$SEN52"
printf '#!/bin/sh\n: > %q\nexec %q "$@"\n' "$CEN52" "$(command -v sha256sum)" > "$SEN52/sha256sum"; chmod +x "$SEN52/sha256sum"
hook52() {   # <proyecto>: el hook del árbol en prueba con el señuelo en el PATH; deja hook.out, hook.err, RC52 y US52 (µs)
  local t0="${EPOCHREALTIME//[!0-9]/}"
  CLAUDE_PLUGIN_ROOT="$ARB52" CLAUDE_PROJECT_DIR="$1" PATH="$SEN52:$PATH" "$BASH" "$ARB52/hooks/inicio-sesion.sh" \
    < /dev/null > "$FX52/hook.out" 2> "$FX52/hook.err"; RC52=$?
  US52=$(( ${EPOCHREALTIME//[!0-9]/} - t0 ))
}
gen52() {   # [--verificar] <proyecto>: el generador del árbol en prueba, a mano, con el señuelo; deja gen.err y RC52
  PATH="$SEN52:$PATH" "$BASH" "$ARB52/tools/arnes-lectura-rol.sh" "$@" > /dev/null 2> "$FX52/gen.err"; RC52=$?
}
foto52() { find "$@" -printf '%p|%y|%s|%T@\n' 2>/dev/null | LC_ALL=C sort; }   # qué hay, de qué tipo, tamaño y fecha
mide52() {   # <proyecto>, tras una corrida de hook52: el MÍNIMO de 5 (ésa y cuatro más), en MS52 (ms) y MIN52 (µs)
  local k; MIN52=$US52
  for k in 2 3 4 5; do hook52 "$1"; [ "$US52" -lt "$MIN52" ] && MIN52=$US52; done
  printf -v MS52 '%d,%03d' "$((MIN52 / 1000))" "$((MIN52 % 1000))"
}
# inerte52 <proyecto>: CA-17 (i), (ii) y (iii), TODO a la vez y sin atajo (el motivo nombra cada observable que falla).
inerte52() {
  local p="$1" antes mal=''
  antes="$(foto52 "$p")"; rm -f "$CEN52"; hook52 "$p"
  [ "$RC52" -eq 0 ] && [ ! -s "$FX52/hook.out" ] && [ ! -s "$FX52/hook.err" ] \
    || mal+="(i) hook: código $RC52, $(wc -c < "$FX52/hook.out") B por stdout y $(wc -c < "$FX52/hook.err") B por stderr; "
  [ ! -e "$CEN52" ] || mal+='(ii) el hook disparó el señuelo; '
  mide52 "$p"; [ "$MIN52" -le 1000000 ] || mal+="(iii) hook en $MS52 ms > 1 s (mínimo de 5); "
  rm -f "$CEN52"; gen52 "$p"
  [ "$RC52" -ne 0 ] && [ "$(<"$FX52/gen.err")" = "arnes-lectura-rol: no existe $p/.arnes" ] \
    || mal+="(ii) generador: código $RC52, «$(head -c 140 "$FX52/gen.err" | tr '\n' ' ')»; "
  [ ! -e "$CEN52" ] || mal+='(ii) el generador disparó el señuelo; '
  [ "$(foto52 "$p")" = "$antes" ] || mal+='(ii) se creó o cambió algo en el proyecto; '
  [ -z "$mal" ] || { MOT52="${mal}hook en $MS52 ms (mínimo de 5)"; return 1; }
  MOT52="0 B por stdout y stderr, sin señuelo, nada creado, generador ≠ 0 con sólo «no existe …/.arnes»; hook en $MS52 ms (mínimo de 5)"
}
fx52() {   # <nombre> <vacio|ajeno|grande> -> FXS52, un proyecto SIN .arnes
  FXS52="$FX52/$1"; rm -rf "$FXS52"; mkdir -p "$FXS52"
  [ "$2" = vacio ] && return 0
  mkdir -p "$FXS52/requirements"; printf '%s\n' '[[R-1 · obliga: todos]]' 'Requisitos de otro proyecto.' > "$FXS52/requirements/README.md"
  if [ "$2" = ajeno ]; then printf '%s\n' '# Otro proyecto' '' 'Instrucciones de otro equipo.' '' '[[x · obliga: todos]]' 'Regla ajena.' > "$FXS52/AGENTS.md"
  else { printf '%s\n' '[[x · obliga: todos]]'; awk 'BEGIN { l = sprintf("%0300d", 0); for (i = 0; i < 5000; i++) print l }'; } > "$FXS52/AGENTS.md"; fi
}
f1_52() { fx52 f1 vacio; inerte52 "$FXS52"; }
f2_52() { fx52 f2 ajeno; inerte52 "$FXS52"; }
f3_52() { fx52 f3 grande; [ "$(wc -c < "$FXS52/AGENTS.md")" -ge 1500000 ] || { MOT52='la fuente no llega a 1,5 MB'; return 2; }; inerte52 "$FXS52"; }
c3_52() {  # (c3) `.arnes` archivo o enlace roto: inerte como las tres fixtures
  fx52 c3a ajeno; printf 'no soy un directorio\n' > "$FXS52/.arnes"; inerte52 "$FXS52" || { MOT52="archivo: $MOT52"; return 1; }
  fx52 c3b ajeno; ln -s "$FX52/no-existe" "$FXS52/.arnes"; inerte52 "$FXS52" || { MOT52="enlace roto: $MOT52"; return 1; }
  MOT52="archivo y enlace roto: $MOT52"
}
c1_52() { fx52 c1 vacio; mkdir "$FXS52/.arnes"; hook52 "$FXS52"   # (c1) `.arnes/` vacío: recuerda y sale 0
  [ "$RC52" -eq 0 ] && grep -q 'AGENTS.md ENTERO' "$FX52/hook.out" || { MOT52="código $RC52, sin recordatorio"; return 1; }
  MOT52='código 0 y el recordatorio'; }
c2_52() {  # (c2) `.arnes` enlace a un directorio: recuerda, y el generador no escribe ni borra nada (L2)
  local antes; fx52 c2 ajeno; rm -rf "$FX52/c2-dest"; mkdir -p "$FX52/c2-dest/lectura"; printf 'centinela\n' > "$FX52/c2-dest/lectura/qa.md"
  ln -s "$FX52/c2-dest" "$FXS52/.arnes"; antes="$(foto52 "$FXS52" "$FX52/c2-dest")"; hook52 "$FXS52"
  [ "$RC52" -eq 0 ] && grep -q 'AGENTS.md ENTERO' "$FX52/hook.out" || { MOT52="código $RC52, sin recordatorio"; return 1; }
  [ "$(foto52 "$FXS52" "$FX52/c2-dest")" = "$antes" ] || { MOT52='escribió o borró a través del enlace'; return 1; }
  MOT52='código 0, el recordatorio, y nada escrito ni borrado en el proyecto ni en el destino del enlace'; }
c4_52() {  # (c4) `.arnes/` y las fuentes de este repositorio: --verificar da 0 y los cuatro no cambian un byte
  local r; fx52 c4 vacio; mkdir -p "$FXS52/requirements" "$FXS52/.arnes"; cp "$CAND52/AGENTS.md" "$FXS52/"
  cp "$CAND52/requirements/README.md" "$FXS52/requirements/"; cp -R "$CAND52/.arnes/lectura" "$FXS52/.arnes/"
  gen52 --verificar "$FXS52"; [ "$RC52" -eq 0 ] || { MOT52="--verificar salió $RC52"; return 1; }
  hook52 "$FXS52"; grep -q 'AGENTS.md ENTERO' "$FX52/hook.out" || { MOT52='sin recordatorio'; return 1; }
  for r in analista desarrollador qa seguridad; do
    cmp -s "$CAND52/.arnes/lectura/$r.md" "$FXS52/.arnes/lectura/$r.md" || { MOT52="$r.md cambió"; return 1; }; done
  MOT52='--verificar 0; tras el hook, los cuatro idénticos byte a byte a los versionados'; }
# enl52 <.arnes|lectura>: CA-18, el generador con `.arnes` (o `.arnes/lectura`) enlazado sobre las TRES fixtures: sale 1
# con sólo el mensaje del enlace, sin señuelo y sin tocar nada; el reloj (mínimo de 5) sólo si todo lo demás se cumple.
enl52() {
  local t k antes m mal=''; m="arnes-lectura-rol: .arnes es un enlace simbólico: no se escribe"
  [ "$1" = lectura ] && m="arnes-lectura-rol: .arnes/lectura es un enlace simbólico: no se escribe"
  for t in vacio ajeno grande; do   # las tres, sin atajo: el motivo nombra lo que falla en cada una
    fx52 "e-$1-$t" "$t"; rm -rf "$FX52/e-dest"; mkdir -p "$FX52/e-dest"
    if [ "$1" = lectura ]; then mkdir "$FXS52/.arnes"; ln -s "$FX52/e-dest" "$FXS52/.arnes/lectura"; else ln -s "$FX52/e-dest" "$FXS52/.arnes"; fi
    antes="$(foto52 "$FXS52" "$FX52/e-dest")"; rm -f "$CEN52"; gen52 "$FXS52"
    [ "$RC52" -eq 1 ] && [ "$(<"$FX52/gen.err")" = "$m" ] || mal+="$t: código $RC52, «$(head -c 100 "$FX52/gen.err" | tr '\n' ' ')»; "
    [ ! -e "$CEN52" ] || mal+="$t: el generador disparó el señuelo; "
    [ "$(foto52 "$FXS52" "$FX52/e-dest")" = "$antes" ] || mal+="$t: tocó algo; "
  done
  [ -z "$mal" ] || { MOT52="$mal"; return 1; }
  MIN52=''; for k in 1 2 3 4 5; do t="${EPOCHREALTIME//[!0-9]/}"; gen52 "$FXS52"; t=$(( ${EPOCHREALTIME//[!0-9]/} - t ))
    [ -z "$MIN52" ] || [ "$t" -lt "$MIN52" ] && MIN52=$t; done
  [ "$MIN52" -le 1000000 ] || { MOT52="grande: $MIN52 µs > 1 s"; return 1; }
  MOT52="las tres fixtures: código 1, sólo el mensaje del enlace, sin señuelo ni cambios; 1,5 MB en $((MIN52 / 1000)) ms (mínimo de 5)"
}
enla52() { enl52 .arnes; }; enll52() { enl52 lectura; }
# filai52 <id> <función> <fb|control> [lo que el motivo de 7af469c tiene que nombrar]: candidata y 7af469c. `fb`: en
# 7af469c no se cumple (fail-before); `control`: se cumple en las dos (no se mueve). 2 = no se pudo montar: SKIP.
filai52() {
  local nom="REQ-036 $1" rc
  MOT52=''; ARB52="$CAND52"; "$2"; rc=$?
  case "$rc" in 0) v52 PASS "$nom candidata  ($MOT52)" ;; 2) v52 SKIP "$nom candidata  $MOT52" ;; *) v52 FAIL "$nom candidata  $MOT52" ;; esac
  if [ "$RI52_OK" != si ]; then v52 SKIP "$nom 7af469c  $RI52_MOT"; return 0; fi
  MOT52=''; ARB52="$RI52"; "$2"; rc=$?
  if [ "$rc" -eq 2 ]; then v52 SKIP "$nom 7af469c  $MOT52"
  elif [ "$3" = control ]; then
    if [ "$rc" -eq 0 ]; then v52 PASS "$nom 7af469c (control, no se mueve)${MOT52:+  ($MOT52)}"; else v52 FAIL "$nom 7af469c (control)  se movió: $MOT52"; fi
  elif [ "$rc" -eq 0 ]; then v52 FAIL "$nom 7af469c (fail-before)  ya se cumple en 7af469c: el caso no discrimina"
  elif [[ $MOT52 == *"${4:-}"* ]]; then v52 PASS "$nom 7af469c (fail-before)  ($MOT52)"
  else v52 FAIL "$nom 7af469c (fail-before)  falla, pero sin «$4»: $MOT52"; fi
}
filai52 "B13 CA-17 F1: directorio vacío sin .arnes/ -> sin aviso, sin lectura, <= 1 s" f1_52 fb '(i)'
filai52 "B13 CA-17 F2: AGENTS.md y README ajenos sin .arnes/ -> sin aviso, sin lectura, <= 1 s" f2_52 fb '(ii) el hook disparó el señuelo'
filai52 "B13 CA-17 F3: AGENTS.md de 1,5 MB sin .arnes/ -> sin aviso, sin lectura, <= 1 s" f3_52 fb '(iii)'
filai52 "B13 CA-17 c3: .arnes archivo o enlace roto -> inerte como las fixtures" c3_52 fb '(i)'
filai52 "B13 CA-17 c1: .arnes/ vacío (sin config.json) -> recuerda y sale 0" c1_52 control
filai52 "B13 CA-17 c2: .arnes enlace a un directorio -> recuerda; el generador no escribe ni borra (L2)" c2_52 control
filai52 "B13 CA-17 c4: .arnes/ y las fuentes de este repositorio -> --verificar 0 y los cuatro sin cambiar un byte" c4_52 control
filai52 "B13 CA-18 orden: .arnes enlazado -> el enlace se rechaza antes de leer una fuente (tres fixtures)" enla52 fb
filai52 "B13 CA-18 orden: .arnes/lectura enlazado -> el enlace se rechaza antes de leer una fuente (tres fixtures)" enll52 fb
