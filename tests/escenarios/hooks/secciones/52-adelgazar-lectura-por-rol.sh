# Sección 52 del banco — 52-adelgazar-lectura-por-rol
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# REQ-036 CA-18 y CA-19 (P-137-Z (A)): el archivo de lectura por rol `.arnes/lectura/<rol>.md`, DERIVADO de las marcas
# de `AGENTS.md` y `requirements/README.md` por `tools/arnes-lectura-rol.sh`, y la línea del ámbito alcanzado.
# Los números (1)…(7) son los de «Qué comprueba el banco» de CA-18; el (8) —ningún proceso por orden— es B10 de la 51.
# EL EXTRACTOR ES APARTE: `EXT52` es awk escrito aquí y no reutiliza el código del generador (bash), para que el
# generador no se compruebe a sí mismo. DOS ÁRBOLES por fila: la CANDIDATA (`$TPL_DIR/..`) y la cabeza `c330940` (la de
# antes de CA-18 y CA-19), archivo a archivo y verificada contra su objeto; sin ella, SKIP y motivo, nunca PASS. Todas
# las filas son fail-before contra `c330940`; (3a) y la cabecera rota son fail-before sobre fixtures de la candidata.
# La vuelta 1 de QA (QA-036-03 a 08: (3b) del obligado ilegible, (5b), (6) y S1 a S8 de «Fuente sin marcas») añade un
# TERCER árbol, `d722aed` —la cabeza que QA validó—, que es el de su fail-before (`filad52`). PARTE 1 DE 2 (REQ-014
# CA-18): S3 y la última pasada (QA-036-03, marcas parciales: S3b, S3c, S9) van en `52-…-2-texto-previo.sh`; aquí no cabían.
CASOS_ESPERADOS_SECCION=58
PISO_AUTONOMO_SECCION=131  # 16 preámbulo (líneas 1-16, con seccion_nueva) + 0 maquinaria compartida duplicada + 115 bloque indivisible mayor (los árboles c330940, d722aed y 081cb10, rellena, el extractor, gen52, hook52, c1_52, c2_52, fxs52 y en52, líneas 17-131)
seccion_nueva "--- 52 · lectura por rol, derivada y comprobada byte a byte; ámbito alcanzado (REQ-036 CA-18, CA-19) ---"
REPO52="${SEC_DIR%/}/../../../.."; REF52=c330940; CAND52="${TPL_DIR%/*}"
v52() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }
ARB52=''; MOT52=''; RC52=0; FX52="$RAIZ/fx52-$BASHPID"; mkdir -p "$FX52"
ROLES52='analista desarrollador qa seguridad'
# El árbol anterior: sólo lo que esta sección lee, cada archivo verificado contra el objeto de c330940.
RV52="$RAIZ/rv52-$BASHPID"; RV52_OK=si; RV52_MOT=''
for f52 in AGENTS.md requirements/README.md templates/requirements-README.md.tpl agents/analista-requerimientos.md \
           agents/desarrollador.md agents/qa-tester.md agents/auditor-seguridad.md \
           $(git -C "$REPO52" ls-tree -r --name-only "$REF52" -- hooks tools .arnes/lectura 2>/dev/null); do
  d52="${f52%/*}"; [ "$d52" = "$f52" ] && d52=.
  mkdir -p "$RV52/$d52"
  if git -C "$REPO52" show "$REF52:$f52" > "$RV52/$f52" 2>/dev/null \
     && [ "$(git -C "$REPO52" hash-object "$RV52/$f52" 2>/dev/null)" = "$(git -C "$REPO52" rev-parse "$REF52:$f52" 2>/dev/null)" ]; then :
  else RV52_OK=no; RV52_MOT="c330940 no se materializó ($f52)"; break; fi
done
[ -r "$RV52/hooks/inicio-sesion.sh" ] || { RV52_OK=no; RV52_MOT="c330940 no se materializó (hooks/inicio-sesion.sh)"; }
# La vuelta 1 (QA-036-03 a 08) se mide contra d722aed, la cabeza que validó QA; los proyectos de S7 y S8 se instalan
# con las plantillas de 081cb10 (la línea base de REQ-036). Cada archivo, verificado contra su objeto; sin él, SKIP.
RD52="$RAIZ/rd52-$BASHPID"; RB52="$RAIZ/rb52-$BASHPID"; RD52_OK=si; RD52_MOT=''
mat52() {   # <ref> <dir> <rutas…>
  local ref="$1" dir="$2" f d; shift 2
  for f in "$@"; do
    d="${f%/*}"; mkdir -p "$dir/$d"
    git -C "$REPO52" show "$ref:$f" > "$dir/$f" 2>/dev/null \
      && [ "$(git -C "$REPO52" hash-object "$dir/$f" 2>/dev/null)" = "$(git -C "$REPO52" rev-parse "$ref:$f" 2>/dev/null)" ] \
      || { RD52_OK=no; RD52_MOT="$ref no se materializó ($f)"; return 1; }
  done
}
TPL52='templates/AGENTS.md.tpl templates/requirements-README.md.tpl templates/arnes-config.json.tpl templates/CLAUDE.md.tpl'
mat52 d722aed "$RD52" tools/arnes-lectura-rol.sh hooks/inicio-sesion.sh agents/analista-requerimientos.md agents/desarrollador.md \
  agents/qa-tester.md agents/auditor-seguridad.md skills/arnes-upgrade/SKILL.md $TPL52 && mat52 081cb10 "$RB52" $TPL52
# `rellena` (los marcadores de arnes-init con los valores de «tienda-demo») tiene su sede en el guion de medida.
eval "$(awk '/<!-- guion: medida-4a/ { e = 1; next } e == 1 && /^```bash/ { e = 2; next } e == 2 && /^```/ { exit } e == 2' \
  "$CAND52/docs/explicacion/medida-4a.md" 2>/dev/null | awk '/^rellena\(\)/, /^}/')"
# --- El extractor aparte (awk). Un bloque va de su marca a la línea anterior a la siguiente. Antes de la primera
# marca, el título y los blancos no son bloque; desde la primera línea que no es ni lo uno ni lo otro, sí: bloque sin
# marca, para los cuatro (CA-18, «Qué contiene»; QA-036-03). Obligación LEGIBLE (CA-18, QA-036-07): tras `[[<id> · `,
# exactamente `explicativo` (nadie) u `obliga:` y una lista cuyos elementos son TODOS un rol, `coordinadora` o `todos`
# (mayúsculas y blancos alrededor tolerados). Todo lo demás —sin cierre, sin ` · `, un elemento mal escrito, la lista
# vacía— la leen los cuatro.
EXT52='
function lim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
function lee(m,   r, n, i, t, sel) {
  m = lim(m)
  if (m !~ /^\[\[.*\]\]$/) return 1
  r = substr(m, 3, length(m) - 4); i = index(r, " · "); if (!i) return 1
  r = lim(substr(r, i + length(" · ")))
  if (r == "explicativo") return 0
  if (substr(r, 1, 7) != "obliga:") return 1
  n = split(substr(r, 8), t, ","); if (n == 0) return 1
  sel = 0
  for (i = 1; i <= n; i++) {
    t[i] = tolower(lim(t[i]))
    if (t[i] == "todos" || t[i] == rol) sel = 1
    else if (t[i] !~ /^(analista|desarrollador|qa|seguridad|coordinadora)$/) return 1
  }
  return sel
}
FNR == 1 { dentro = 0; previo = 1 }
/^\[\[/ { dentro = lee($0); previo = 0 }
previo && !dentro && $0 !~ /^# / && $0 ~ /[^ \t\r\f\v]/ { dentro = 1 }
dentro { print }'
ext52() { LC_ALL=C awk -v rol="$1" "$EXT52" "$2/AGENTS.md" "$2/requirements/README.md"; }   # <rol> <proyecto>
gen52() {   # [--verificar] <proyecto>: el generador del árbol en prueba; deja RC52
  [ -r "$ARB52/tools/arnes-lectura-rol.sh" ] || { MOT52='el árbol no trae tools/arnes-lectura-rol.sh'; RC52=127; return 1; }
  bash "$ARB52/tools/arnes-lectura-rol.sh" "$@" > /dev/null 2> "$FX52/gen.err"; RC52=$?
  return 0
}
# hook52 <proyecto> [PATH] [raíz del plugin]: lo que Claude Code hace al abrir la sesión; deja la salida en
# $FX52/hook.out, su stderr en $FX52/hook.err y RC52.
hook52() {
  CLAUDE_PLUGIN_ROOT="${3:-$ARB52}" CLAUDE_PROJECT_DIR="$1" PATH="${2:-$PATH}" "$BASH" "${3:-$ARB52}/hooks/inicio-sesion.sh" \
    < /dev/null > "$FX52/hook.out" 2> "$FX52/hook.err"; RC52=$?
}
recuerda52() { [ "$RC52" -eq 0 ] && grep -q 'AGENTS.md ENTERO' "$FX52/hook.out"; }
# c1_52 <rol> <proyecto>: (1) el archivo, sin sus cuatro líneas de cabecera, es byte a byte lo que da el extractor.
c1_52() {
  local f="$2/.arnes/lectura/$1.md"
  [ -f "$f" ] || { MOT52="no existe ${f#"$2"/}"; return 1; }
  ext52 "$1" "$2" > "$FX52/esp.$1"; tail -n +5 "$f" > "$FX52/cue.$1"
  cmp -s "$FX52/esp.$1" "$FX52/cue.$1" || { MOT52="$1.md no es la concatenación de sus marcas ($(cmp "$FX52/esp.$1" "$FX52/cue.$1" 2>&1 | head -c 80))"; return 1; }
  MOT52="$(wc -c < "$f") B"
}
# c2_52 <proyecto>: (2) las tres líneas de cabecera, exactas, con el tamaño y el sha256 reales de las fuentes, y la blanca.
c2_52() {
  local r f h a=() n1 n2 s1 s2
  n1="$(wc -c < "$1/AGENTS.md")"; n2="$(wc -c < "$1/requirements/README.md")"
  s1="$(sha256sum < "$1/AGENTS.md")"; s2="$(sha256sum < "$1/requirements/README.md")"
  for r in $ROLES52; do
    f="$1/.arnes/lectura/$r.md"; [ -f "$f" ] || { MOT52="no existe $r.md"; return 1; }
    mapfile -t a < <(head -n 4 "$f")
    h="<!-- Fuentes: AGENTS.md $((n1)) B sha256 ${s1%% *}; requirements/README.md $((n2)) B sha256 ${s2%% *} -->"
    [ "${a[0]:-}" = '<!-- DERIVADO — no editar a mano: lo genera tools/arnes-lectura-rol.sh y se pisa en la siguiente generación. -->' ] \
      && [ "${a[1]:-}" = "<!-- Rol: $r -->" ] && [ "${a[2]:-}" = "$h" ] && [ "${a[3]-x}" = '' ] \
      || { MOT52="la cabecera de $r.md no es la de contrato o no casa con las fuentes"; return 1; }
  done
}
c1r52() { local r; for r in $ROLES52; do c1_52 "$r" "$1" || return 1; done; }
# fxs52 <nombre> -> FXS52: un proyecto sintético con una marca de cada clase y un contenido único por bloque.
fxs52() {
  FXS52="$FX52/$1"; rm -rf "$FXS52"; mkdir -p "$FXS52/requirements" "$FXS52/.arnes"
  printf '%s\n' '# Título, no es bloque' '' '[[X-1 · obliga: todos]]' 'uno-todos' '' '[[X-2 · obliga: qa]]' 'dos-qa' \
    '[[X-3 · explicativo]]' 'tres-explicativo' '[[X-4 · obliga: coordinadora]]' 'cuatro-coord' \
    '[[X-5 sin obligado legible]]' 'cinco-ilegible' '[[X-6 · obliga: QA , Analista]]' 'seis-qa-analista' \
    '[[X-7 · obliga: nadie-conocido]]' 'siete-sin-rol' '[[X-8 · obliga: todos' 'ocho-sin-cierre' '' > "$FXS52/AGENTS.md"
  printf '%s\n' '# R' '[[Y-1 · obliga: analista, coordinadora]]' 'y-uno-analista' > "$FXS52/requirements/README.md"
}
en52() {   # <texto> <roles en que debe estar>: está exactamente en esos archivos por rol de FXS52
  local r
  for r in $ROLES52; do
    if grep -qx -- "$1" "$FXS52/.arnes/lectura/$r.md" 2>/dev/null; then
      case " $2 " in *" $r "*) ;; *) MOT52="«$1» está en $r.md"; return 1 ;; esac
    else case " $2 " in *" $r "*) MOT52="«$1» no está en $r.md"; return 1 ;; esac; fi
  done
}
c1_rep() { c1_52 "${1}" "$ARB52"; }
c1a52() { c1_rep analista; }; c1d52() { c1_rep desarrollador; }; c1q52() { c1_rep qa; }; c1s52() { c1_rep seguridad; }
c2rep52() { c2_52 "$ARB52"; }
c3b52() {   # (3b) una marca ilegible —sin `obliga:`, sin rol reconocido, sin cierre— va a los cuatro; y extractor = generador
  fxs52 s3b; gen52 "$FXS52" || return 1; [ "$RC52" -eq 0 ] || { MOT52="el generador salió $RC52"; return 1; }
  en52 cinco-ilegible "$ROLES52" && en52 siete-sin-rol "$ROLES52" && en52 ocho-sin-cierre "$ROLES52" && c1r52 "$FXS52"
}
c3c52() { fxs52 s3c; gen52 "$FXS52" || return 1; [ -f "$FXS52/.arnes/lectura/qa.md" ] || { MOT52='no generó'; return 1; }; en52 tres-explicativo ''; }
c3d52() { fxs52 s3d; gen52 "$FXS52" || return 1; [ -f "$FXS52/.arnes/lectura/qa.md" ] || { MOT52='no generó'; return 1; }; en52 cuatro-coord ''; }
c3e52() {   # (3e) `qa` va a qa.md y no a analista.md; la lista se normaliza (blancos, mayúsculas); el título no es bloque
  fxs52 s3e; gen52 "$FXS52" || return 1
  en52 dos-qa qa && en52 seis-qa-analista 'analista qa' && en52 y-uno-analista analista && en52 uno-todos "$ROLES52" \
    && en52 '# Título, no es bloque' ''
}
c4_52() {   # (4) idempotente: mismos bytes, mismo inodo (no reescribe) y fecha de ahora (frescura)
  local antes despues
  fxs52 s4; gen52 "$FXS52" || return 1; [ "$RC52" -eq 0 ] || { MOT52="salió $RC52"; return 1; }
  cat "$FXS52"/.arnes/lectura/*.md > "$FX52/s4.bytes"
  touch -d '2000-01-02 00:00:00' "$FXS52"/.arnes/lectura/*.md
  antes="$(stat -c '%i' "$FXS52"/.arnes/lectura/*.md)"
  gen52 "$FXS52"; [ "$RC52" -eq 0 ] || { MOT52="la segunda corrida salió $RC52"; return 1; }
  cat "$FXS52"/.arnes/lectura/*.md | cmp -s - "$FX52/s4.bytes" || { MOT52='la segunda corrida cambió los bytes'; return 1; }
  despues="$(stat -c '%i' "$FXS52"/.arnes/lectura/*.md)"
  [ "$antes" = "$despues" ] || { MOT52='la segunda corrida reescribió (otro inodo)'; return 1; }
  [ -z "$(find "$FXS52/.arnes/lectura" -name '*.md' ! -newermt '2000-01-03')" ] || { MOT52='no actualizó la fecha'; return 1; }
}
c5a52() {   # (5) fuente ausente: el hook avisa, sale 0 y BORRA los archivos por rol (se leerán por marcas)
  local r
  fxs52 s5a; mkdir -p "$FXS52/.arnes/lectura"
  for r in $ROLES52; do printf 'viejo\n' > "$FXS52/.arnes/lectura/$r.md"; done
  rm -f "$FXS52/requirements/README.md"; hook52 "$FXS52"
  recuerda52 || { MOT52="sin recordatorio o salida $RC52"; return 1; }
  [ -z "$(find "$FXS52/.arnes/lectura" -name '*.md')" ] || { MOT52='con una fuente ausente quedaron archivos por rol'; return 1; }
}
c5b52() {   # (5) destino no escribible: no escribe, avisa y sale 0; control: escribible, genera
  fxs52 s5b; mkdir -p "$FXS52/.arnes/lectura"; chmod 555 "$FXS52/.arnes/lectura"
  if [ -w "$FXS52/.arnes/lectura" ]; then chmod 755 "$FXS52/.arnes/lectura"; MOT52='el directorio sigue escribible tras chmod 555 (¿root?): no se puede montar el caso'; return 2; fi
  hook52 "$FXS52"; chmod 755 "$FXS52/.arnes/lectura"
  recuerda52 || { MOT52="sin recordatorio o salida $RC52"; return 1; }
  [ -z "$(find "$FXS52/.arnes/lectura" -name '*.md*')" ] || { MOT52='escribió en un destino no escribible'; return 1; }
  hook52 "$FXS52"; recuerda52 && c1r52 "$FXS52" || { MOT52="control: escribible no generó ($MOT52)"; return 1; }
}
c5c52() {   # (5) `.arnes/lectura` enlace simbólico: no escribe ni borra a través de él; control: sin enlace, genera
  fxs52 s5c; mkdir -p "$FX52/s5c-otro"; printf 'centinela\n' > "$FX52/s5c-otro/analista.md"
  ln -s "$FX52/s5c-otro" "$FXS52/.arnes/lectura"; hook52 "$FXS52"
  recuerda52 || { MOT52="sin recordatorio o salida $RC52"; return 1; }
  [ "$(cat "$FX52/s5c-otro/analista.md")" = centinela ] && [ "$(ls -A "$FX52/s5c-otro")" = analista.md ] \
    || { MOT52='escribió o borró a través del enlace'; return 1; }
  rm -f "$FXS52/.arnes/lectura"; hook52 "$FXS52"; recuerda52 && c1r52 "$FXS52" || { MOT52="control: sin enlace no generó ($MOT52)"; return 1; }
}
c5d52() {   # (5) sin jq: el hook avisa, sale 0 y el generador genera igual (no usa jq)
  local d="$FX52/s5d-path" b
  mkdir -p "$d"; for b in sha256sum touch mkdir mv rm; do ln -sf "$(command -v "$b")" "$d/$b"; done
  PATH="$d" command -v jq > /dev/null 2>&1 && { MOT52='jq sigue en el PATH del caso'; return 1; }
  fxs52 s5d; hook52 "$FXS52" "$d"
  recuerda52 || { MOT52="sin recordatorio o salida $RC52"; return 1; }
  c1r52 "$FXS52" || { MOT52="sin jq no generó ($MOT52)"; return 1; }
}
c6_52() {   # (6) cada definición manda el Read del archivo, el Glob en el mismo bloque y el respaldo por marcas
  local p r t
  for p in analista:analista-requerimientos desarrollador:desarrollador qa:qa-tester seguridad:auditor-seguridad; do
    r="${p%%:*}"; t="$(<"$ARB52/agents/${p#*:}.md")"; t="${t//$'\n'/ }"
    while [[ $t == *'  '* ]]; do t="${t//  / }"; done
    [[ $t == *"En un solo bloque de llamadas emite \`Read\` de \`.arnes/lectura/$r.md\`"* \
       && $t == *"\`Glob\` de \`{AGENTS.md,requirements/README.md,.arnes/lectura/$r.md}\` (del más antiguo al más reciente)"* \
       && $t == *"úsalo sólo si sale el último y su cabecera dice \`Rol: $r\`; si no, búscalos con \`^\\[\\[\` y número"* ]] \
      || { MOT52="la definición de $r no manda Read + Glob en un bloque con respaldo por marcas"; return 1; }
  done
}
c7_52() {   # (7) --verificar: 1 ausente (y no escribe), 0 al día, 1 si cambia una fuente, 1 si cambia un archivo
  fxs52 s7; gen52 --verificar "$FXS52" || return 1
  [ "$RC52" -eq 1 ] && [ ! -e "$FXS52/.arnes/lectura" ] || { MOT52="ausente: salió $RC52 o escribió"; return 1; }
  gen52 "$FXS52"; gen52 --verificar "$FXS52"; [ "$RC52" -eq 0 ] || { MOT52="al día: salió $RC52"; return 1; }
  printf 'nuevo\n' >> "$FXS52/AGENTS.md"; gen52 --verificar "$FXS52"; [ "$RC52" -eq 1 ] || { MOT52="fuente cambiada: salió $RC52"; return 1; }
  gen52 "$FXS52"; printf 'a mano\n' >> "$FXS52/.arnes/lectura/qa.md"
  gen52 --verificar "$FXS52"; [ "$RC52" -eq 1 ] || { MOT52="archivo editado a mano: salió $RC52"; return 1; }
}
c19_52() {  # CA-19: la línea del ámbito alcanzado, una sola y la misma en los dos archivos, con `Seguridad: pendiente`
  local f l=() n
  for f in templates/requirements-README.md.tpl requirements/README.md; do
    n="$(grep -c '^  Ámbito alcanzado → ' "$ARB52/$f")"; [ "$n" -eq 1 ] || { MOT52="$f tiene $n líneas de ámbito alcanzado"; return 1; }
    l+=("$(grep '^  Ámbito alcanzado → ' "$ARB52/$f")")
    grep -qxF '  Normal → `Rigor: ligero`, `Sensible a seguridad: no`, `QA: pendiente`, `Seguridad: n/a`.' "$ARB52/$f" \
      || { MOT52="$f cambió la línea de lo normal"; return 1; }
  done
  [[ ${l[0]} == *'`Rigor: critico`'*'`QA: pendiente`'*'`Seguridad: pendiente`'*'`Sensible a seguridad: sí` si toca sesión, seguridad o datos personales'* ]] \
    || { MOT52='la línea no dice Rigor critico, QA y Seguridad pendiente y sensible sólo si toca sesión, seguridad o datos'; return 1; }
  [ "${l[0]}" = "${l[1]}" ] || { MOT52='la plantilla y requirements/README.md no dicen lo mismo'; return 1; }
}
# --- QA-036-07: el obligado ilegible, por propiedad, con aviso que nombra el bloque y la línea. ----------------------
c3f52() {   # (3b) un elemento mal escrito junto a uno válido, un nombre que no es rol y «explicativo» sin los dos puntos
  local l      # van a los cuatro y avisan con bloque y línea; control: `obliga: QA ` va a qa y no avisa; extractor = generador
  FXS52="$FX52/s3f"; rm -rf "$FXS52"; mkdir -p "$FXS52/requirements" "$FXS52/.arnes"
  printf '%s\n' '# T' '[[X-1 · obliga: coordinadora, desarollador]]' 'x-uno' '[[X-2 · obliga: qa-tester]]' 'x-dos' \
    '[[X-4 · obliga explicativo de la regla]]' 'x-cuatro' '[[X-3 · obliga: QA ]]' 'x-tres' > "$FXS52/AGENTS.md"
  printf '%s\n' '# R' '[[Y-1 · obliga: todos]]' 'y-uno' > "$FXS52/requirements/README.md"
  gen52 "$FXS52" || return 1; [ "$RC52" -eq 0 ] || { MOT52="el generador salió $RC52"; return 1; }
  en52 x-uno "$ROLES52" && en52 x-dos "$ROLES52" && en52 x-cuatro "$ROLES52" && en52 x-tres qa && c1r52 "$FXS52" || return 1
  for l in 2:X-1 4:X-2 6:X-4; do
    grep -q "AGENTS.md:${l%%:*}: .*\[\[${l#*:} " "$FX52/gen.err" || { MOT52="sin aviso con bloque y línea de ${l#*:}"; return 1; }
  done
  ! grep -q 'X-3' "$FX52/gen.err" || { MOT52='avisó del control legible X-3'; return 1; }
}
# --- QA-036-05 (5b): el hook borra por su cuenta si el generador no sirve, sin seguir enlaces, y avisa. --------------
plug52() {  # <ilegible|ausente|roto> -> PLUG52: un plugin con el hook del árbol en prueba y un generador que no sirve
  PLUG52="$FX52/plug-$1"; rm -rf "$PLUG52"; mkdir -p "$PLUG52/hooks" "$PLUG52/tools"; cp "$ARB52/hooks/inicio-sesion.sh" "$PLUG52/hooks/"
  case "$1" in ilegible) printf 'exit 0\n' > "$PLUG52/tools/arnes-lectura-rol.sh"; chmod 000 "$PLUG52/tools/arnes-lectura-rol.sh" ;;
               roto) printf 'exit 3\n' > "$PLUG52/tools/arnes-lectura-rol.sh" ;; esac
}
viejos52() { local r; mkdir -p "$FXS52/.arnes/lectura"; for r in $ROLES52; do printf 'viejo\n' > "$FXS52/.arnes/lectura/$r.md"; done; }
nada52() { [ -z "$(find "$FXS52/.arnes" -path '*/lectura/*' -name '*.md' 2>/dev/null)" ] || { MOT52="quedan archivos por rol: $(ls "$FXS52/.arnes/lectura" | tr '\n' ' ')"; return 1; }; }
c5e52() {   # generador ilegible, ausente o que sale ≠ 0 sin borrar: el hook los quita, recuerda y sale 0; control del
  local m   # límite L2: con `.arnes/lectura` enlace no toca nada a través de él
  for m in ilegible ausente roto; do
    plug52 "$m"; [ "$m" = ilegible ] && [ -r "$PLUG52/tools/arnes-lectura-rol.sh" ] && { MOT52='chmod 000 no impide leer (¿root?)'; return 2; }
    fxs52 "s5e-$m"; viejos52; hook52 "$FXS52" "$PATH" "$PLUG52"
    recuerda52 || { MOT52="$m: sin recordatorio o salida $RC52"; return 1; }
    nada52 || { MOT52="generador $m: $MOT52"; return 1; }
  done
  plug52 roto; fxs52 s5e-enl; mkdir -p "$FX52/s5e-otro"; printf 'centinela\n' > "$FX52/s5e-otro/qa.md"; ln -s "$FX52/s5e-otro" "$FXS52/.arnes/lectura"
  hook52 "$FXS52" "$PATH" "$PLUG52"
  recuerda52 && [ "$(cat "$FX52/s5e-otro/qa.md")" = centinela ] || { MOT52='con .arnes/lectura enlace tocó algo o no recordó'; return 1; }
  MOT52='ilegible, ausente y roto: borrados; enlace: intacto'
}
c5f52() {   # destino no escribible con archivos viejos: el hook avisa por stderr con la ruta que no pudo quitar y sale 0
  fxs52 s5f; viejos52; chmod 555 "$FXS52/.arnes/lectura"
  if [ -w "$FXS52/.arnes/lectura" ]; then chmod 755 "$FXS52/.arnes/lectura"; MOT52='sigue escribible tras chmod 555 (¿root?)'; return 2; fi
  hook52 "$FXS52"; chmod 755 "$FXS52/.arnes/lectura"
  recuerda52 || { MOT52="sin recordatorio o salida $RC52"; return 1; }
  grep -qF "no se pudo quitar $FXS52/.arnes/lectura/qa.md" "$FX52/hook.err" || { MOT52="sin aviso con la ruta ($(head -c 60 "$FX52/hook.err"))"; return 1; }
}
# --- QA-036-08 (6) y S6: lo que manda cada una de las cuatro definiciones (blancos y saltos normalizados). ----------
def52() {
  local p t f
  for p in analista-requerimientos desarrollador qa-tester auditor-seguridad; do
    t="$(<"$ARB52/agents/$p.md")"; t="${t//$'\n'/ }"; while [[ $t == *'  '* ]]; do t="${t//  / }"; done
    for f in "$@"; do [[ $t == *"$f"* ]] || { MOT52="$p no dice «${f:0:60}…»"; return 1; }; done
  done
}
c6e52() { def52 'Lee el archivo por rol entero, en un solo `Read` sin `offset` ni `limit`; si llega truncado, sigue leyendo hasta el final antes de actuar.'; }
s6_52() { def52 'búscalos con `^\[\[`' '(una fuente sin ninguna marca, léela entera: leer por marcas un archivo sin marcas no lee nada)'; }
# --- «Fuente sin marcas» (QA-036-03 y 04), S1 a S5: el generador no genera y borra; el hook no deja archivos. -------
fsm52() {   # <nombre> <AGENTS.md: marcado|sin> <README: marcado|sin>  (el texto previo a la primera marca: parte 2)
  FXS52="$FX52/$1"; rm -rf "$FXS52"; mkdir -p "$FXS52/requirements" "$FXS52/.arnes"
  case "$2" in marcado) printf '%s\n' '# A' '' '[[A-1 · obliga: todos]]' 'a-uno' ;; sin) printf '%s\n' '# A' '' 'Un AGENTS.md de 1.36: sin marcas.' ;;
               esac > "$FXS52/AGENTS.md"
  case "$3" in marcado) printf '%s\n' '# R' '[[R-1 · obliga: todos]]' 'r-uno' ;; sin) printf '%s\n' '# R' '' 'Un README sin marcas.' ;; esac \
    > "$FXS52/requirements/README.md"
}
sgen52() {  # <AGENTS> <README> <lo que stderr nombra>: el generador sale ≠ 0, no deja ninguno y nombra la fuente
  fsm52 "s-$1-$2" "$1" "$2"; gen52 "$FXS52" || return 1
  [ "$RC52" -ne 0 ] || { MOT52="salió 0 y dejó: $(ls "$FXS52/.arnes/lectura" 2>/dev/null | tr '\n' ' ')"; return 1; }
  nada52 && grep -qF -- "$3" "$FX52/gen.err" || { MOT52="${MOT52:-stderr no nombra «$3»}"; return 1; }
  MOT52="código $RC52: $(head -c 70 "$FX52/gen.err")"
}
s1_52() { sgen52 sin marcado 'AGENTS.md: sin ninguna marca'; }
s2_52() { sgen52 marcado sin 'requirements/README.md: sin ninguna marca'; }
s4_52() {   # archivos por rol al día y una fuente que pierde sus marcas: se borran los cuatro
  fsm52 s4 marcado marcado; gen52 "$FXS52" || return 1
  [ "$RC52" -eq 0 ] && [ -f "$FXS52/.arnes/lectura/qa.md" ] || { MOT52="el control no generó (código $RC52)"; return 1; }
  printf '%s\n' '# A' '' 'Sin marcas ya.' > "$FXS52/AGENTS.md"; gen52 "$FXS52"
  [ "$RC52" -ne 0 ] || { MOT52='salió 0'; return 1; }; nada52
}
s5_52() { fsm52 s5 sin sin; hook52 "$FXS52"; recuerda52 || { MOT52="sin recordatorio o salida $RC52"; return 1; }; nada52; }
# --- S7 y S8: la orden de `arnes-upgrade` del árbol en prueba con el plan completo, sobre un proyecto de 081cb10. -----
ord52() {   # <proyecto>: plan, los cuatro archivos (cada uno escrito sólo con código 0) y el paso 4b; RC52 = el generador
  local o q
  o="$(awk '/<!-- orden: adelgazar/ { e = 1; next } e == 1 && /```/ { e = 2; next } e == 2 && /```/ { exit } e == 2' "$ARB52/skills/arnes-upgrade/SKILL.md")"
  [ -n "$o" ] || { MOT52='la skill no trae la orden de adelgazar'; return 1; }
  for q in plan AGENTS.md requirements/README.md .arnes/config.json CLAUDE.md; do
    (cd "$1" && QUE="$q" PLUGIN="$ARB52" bash -c "$o") > "$FX52/o.out" 2> /dev/null || continue
    if [ "$q" = plan ]; then cat "$FX52/o.out" > "$1/.arnes/migracion.md"; else cat "$FX52/o.out" > "$1/$q"; fi
  done
  (cd "$1" && bash "$ARB52/tools/arnes-lectura-rol.sh") > /dev/null 2>&1; RC52=$?
}
s7_52() {   # QA-036-03 (a): sección propia en AGENTS.md -> UNKNOWN; CLAUDE.md con su import; manifiesto sin tocar; sin archivos
  local a c
  FXS52="$FX52/s7"; rm -rf "$FXS52"; mkdir -p "$FXS52/requirements" "$FXS52/.arnes/plantillas-origen"
  rellena "$RB52/templates/AGENTS.md.tpl" "$FXS52/AGENTS.md"; rellena "$RB52/templates/requirements-README.md.tpl" "$FXS52/requirements/README.md"
  rellena "$RB52/templates/arnes-config.json.tpl" "$FXS52/.arnes/config.json"; rellena "$RB52/templates/CLAUDE.md.tpl" "$FXS52/CLAUDE.md"
  cp "$RB52"/templates/*.tpl "$FXS52/.arnes/plantillas-origen/"; printf '\n## 2b. Notas del equipo\n\nUsamos pnpm.\n' >> "$FXS52/AGENTS.md"
  a="$(cksum < "$FXS52/AGENTS.md")"; c="$(cksum < "$FXS52/.arnes/config.json")"; ord52 "$FXS52" || return 1
  [ "$(cksum < "$FXS52/AGENTS.md")" = "$a" ] || { MOT52='AGENTS.md se tocó: debía salir UNKNOWN'; return 1; }
  grep -qx '@AGENTS.md' "$FXS52/CLAUDE.md" || { MOT52='CLAUDE.md perdió su import con AGENTS.md sin marcas'; return 1; }
  grep -q '^## CLAUDE.md — OK: pendiente: `AGENTS.md` sin marcas' "$FXS52/.arnes/migracion.md" || { MOT52='el plan no dice «pendiente»'; return 1; }
  [ "$(cksum < "$FXS52/.arnes/config.json")" = "$c" ] && ! grep -q '§ 14' "$FXS52/.arnes/config.json" \
    || { MOT52='el manifiesto apunta a un «§ 14» que no resuelve'; return 1; }
  [ "$RC52" -ne 0 ] && nada52 || { MOT52="${MOT52:-el paso 4b salió 0} (generador $RC52)"; return 1; }
  MOT52='AGENTS.md UNKNOWN; CLAUDE.md con import (pendiente); _doc con su texto; ningún archivo por rol'
}
s8_52() {   # control: tras S7 el propietario deja AGENTS.md migrable; la siguiente arnes-upgrade, con la misma base,
  local p a n=0 sec   # retira el import, deja punteros que resuelven y genera los archivos por rol
  s7_52 || return 1
  rellena "$RB52/templates/AGENTS.md.tpl" "$FXS52/AGENTS.md"; ord52 "$FXS52" || return 1
  grep -q '^\[\[' "$FXS52/AGENTS.md" || { MOT52='AGENTS.md no se migró'; return 1; }
  ! grep -q '@AGENTS.md' "$FXS52/CLAUDE.md" && grep -qF 'lee AGENTS.md según tu rol, por sus marcas' "$FXS52/CLAUDE.md" \
    || { MOT52='la segunda arnes-upgrade no retiró el import'; return 1; }
  sec="$(awk '/^## 14\./ { f = 1; next } f && /^## / { exit } f' "$FXS52/AGENTS.md")"; sec="${sec//\`/}"
  while IFS= read -r p; do
    n=$((n + 1)); a="${p#*«}"; a="${a%%»*}"; [[ $sec == *"$a"* ]] || { MOT52="el puntero «$a» no resuelve"; return 1; }
  done < <(jq -r '.. | ._doc? // empty | select(contains("§ 14"))' "$FXS52/.arnes/config.json")
  [ "$n" -ge 3 ] && [ "$RC52" -eq 0 ] && [ -f "$FXS52/.arnes/lectura/analista.md" ] || { MOT52="$n punteros; generador $RC52"; return 1; }
  MOT52="2.ª arnes-upgrade: import retirado, $n punteros que resuelven, archivos por rol generados"
}
# filar52 <id> <función> <árbol> <nombre> <ok> <motivo>: la misma función sobre la candidata (cumple) y sobre el árbol
# anterior (no cumple: fail-before). Una función que devuelve 2 no pudo montar su caso: SKIP con el motivo, nunca PASS.
filar52() {
  local nom="REQ-036 $1" rc
  MOT52=''; ARB52="$CAND52"; "$2"; rc=$?
  case "$rc" in 0) v52 PASS "$nom candidata${MOT52:+  ($MOT52)}" ;; 2) v52 SKIP "$nom candidata  $MOT52" ;; *) v52 FAIL "$nom candidata  $MOT52" ;; esac
  if [ "$5" != si ]; then v52 SKIP "$nom $4 (fail-before)  $6"; return 0; fi
  MOT52=''; ARB52="$3"; "$2"; rc=$?
  case "$rc" in 0) v52 FAIL "$nom $4 (fail-before)  ya se cumple en $4: el caso no discrimina" ;;
    2) v52 SKIP "$nom $4 (fail-before)  $MOT52" ;; *) v52 PASS "$nom $4 (fail-before)  ($MOT52)" ;; esac
}
fila52() { filar52 "$1" "$2" "$RV52" c330940 "$RV52_OK" "$RV52_MOT"; }
filad52() { filar52 "$1" "$2" "$RD52" d722aed "$RD52_OK" "$RD52_MOT"; }
fila52 "B11 CA-18 (1): analista.md versionado = concatenación de sus marcas (extractor aparte)" c1a52
fila52 "B11 CA-18 (1): desarrollador.md versionado = concatenación de sus marcas (extractor aparte)" c1d52
fila52 "B11 CA-18 (1): qa.md versionado = concatenación de sus marcas (extractor aparte)" c1q52
fila52 "B11 CA-18 (1): seguridad.md versionado = concatenación de sus marcas (extractor aparte)" c1s52
fila52 "B11 CA-18 (2): cabecera de tres líneas exactas con tamaño y sha256 reales de las fuentes" c2rep52
fila52 "B11 CA-18 (3b): una marca ilegible va a los cuatro, y extractor = generador" c3b52
fila52 "B11 CA-18 (3c): un bloque explicativo no va a ninguno" c3c52
fila52 "B11 CA-18 (3d): un bloque sólo de la coordinadora no va a ninguno" c3d52
fila52 "B11 CA-18 (3e): un bloque qa va a qa.md y no a analista.md; lista normalizada; el título no es bloque" c3e52
fila52 "B11 CA-18 (4): idempotente, sin reescribir, y con la fecha al día" c4_52
fila52 "B11 CA-18 (5): fuente ausente -> el hook borra, avisa y sale 0" c5a52
fila52 "B11 CA-18 (5): destino no escribible -> no escribe, avisa y sale 0 (control: escribible, genera)" c5b52
fila52 "B11 CA-18 (5): .arnes/lectura enlace simbólico -> nada a través de él, avisa y sale 0 (control: genera)" c5c52
fila52 "B11 CA-18 (5): sin jq -> avisa, sale 0 y genera igual" c5d52
fila52 "B11 CA-18 (6): las cuatro definiciones mandan Read + Glob en un bloque y el respaldo por marcas" c6_52
fila52 "B11 CA-18 (7): --verificar sale 1 ausente o viejo, 0 al día, y no escribe" c7_52
fila52 "B12 CA-19: ámbito alcanzado -> critico, QA y Seguridad pendiente; mismo texto en los dos" c19_52
# Vuelta 1 de QA (QA-036-03 a 08): cada fila es fail-before contra d722aed.
filad52 "B11 CA-18 (3b) QA-036-07: elemento mal escrito, nombre que no es rol y «obliga explicativo» van a los cuatro con aviso; QA con blanco, sólo a qa" c3f52
filad52 "B11 CA-18 (5b) QA-036-05: generador ilegible, ausente o roto -> el hook borra y sale 0; con enlace no toca nada" c5e52
filad52 "B11 CA-18 (5b) QA-036-05: destino no escribible -> el hook avisa por stderr con la ruta y sale 0" c5f52
filad52 "B11 CA-18 (6) QA-036-08: las cuatro definiciones mandan leerlo entero, sin offset ni limit, y completar si llega truncado" c6e52
filad52 "B11 CA-18 (9) S1: AGENTS.md sin marcas -> sale ≠ 0, ningún archivo y stderr nombra la fuente" s1_52
filad52 "B11 CA-18 (9) S2: requirements/README.md sin marcas -> sale ≠ 0, ningún archivo y stderr nombra la fuente" s2_52
filad52 "B11 CA-18 (9) S4: archivos por rol al día y una fuente que pierde sus marcas -> se borran los cuatro" s4_52
filad52 "B11 CA-18 (9) S5: el hook con fuentes sin marcas recuerda, sale 0 y no deja archivos" s5_52
filad52 "B11 CA-18 (9) S6: las cuatro definiciones mandan leer entera una fuente sin marcas" s6_52
filad52 "B11 CA-18 (9) S7: migración parcial (AGENTS.md UNKNOWN) -> CLAUDE.md con import, _doc con su texto, sin archivos" s7_52
filad52 "B11 CA-18 (9) S8: control, tras S7 y AGENTS.md migrable, la 2.ª arnes-upgrade retira el import y los punteros resuelven" s8_52
# (3a) fail-before de (1) y (2) sobre un fixture de la candidata: un bloque de AGENTS.md cambiado sin regenerar.
MOT52=''; ARB52="$CAND52"; F52="$FX52/s3a"; mkdir -p "$F52/requirements" "$F52/.arnes"
cp "$CAND52/AGENTS.md" "$F52/"; cp "$CAND52/requirements/README.md" "$F52/requirements/"; cp -r "$CAND52/.arnes/lectura" "$F52/.arnes/" 2>/dev/null
if c1_52 analista "$F52" && c2_52 "$F52"; then
  awk '{ print } /^\[\[A-1 / { print "línea añadida sin regenerar" }' "$CAND52/AGENTS.md" > "$F52/AGENTS.md"
  if c1_52 analista "$F52"; then v52 FAIL "REQ-036 B11 CA-18 (3a) fixture: un bloque cambiado sin regenerar NO hace fallar (1)"
  elif c2_52 "$F52"; then v52 FAIL "REQ-036 B11 CA-18 (3a) fixture: un bloque cambiado sin regenerar NO hace fallar (2)"
  else v52 PASS "REQ-036 B11 CA-18 (3a) fixture: un bloque de AGENTS.md cambiado sin regenerar hace fallar (1) y (2)"; fi
else v52 FAIL "REQ-036 B11 CA-18 (3a) fixture: la copia sin cambiar ya no pasa ($MOT52)"; fi
# Cabecera rota: un tamaño falso en la línea de fuentes hace fallar (2) aunque el cuerpo sea el bueno.
F52="$FX52/s2r"; rm -rf "$F52"; cp -r "$FX52/s3a" "$F52"; cp "$CAND52/AGENTS.md" "$F52/"
awk 'NR == 3 { sub(/AGENTS\.md [0-9]+ B/, "AGENTS.md 1 B") } { print }' "$CAND52/.arnes/lectura/qa.md" > "$F52/.arnes/lectura/qa.md"
if c1_52 qa "$F52" && ! c2_52 "$F52"; then v52 PASS "REQ-036 B11 CA-18 (2) fixture: una cabecera con un tamaño falso hace fallar (2)"
else v52 FAIL "REQ-036 B11 CA-18 (2) fixture: la cabecera falsa no hizo fallar (2), o el cuerpo dejó de casar"; fi
