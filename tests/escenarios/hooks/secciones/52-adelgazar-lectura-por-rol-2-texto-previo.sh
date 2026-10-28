# Sección 52 del banco, parte 2 de 2 — 52-adelgazar-lectura-por-rol-2-texto-previo
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# REQ-036 CA-18, «Fuente sin marcas», pieza 1, tras QA-036-03 (variante con marcas parciales, vuelta 2 de QA): el texto
# propio antes de la primera marca —desde la primera línea que no está en blanco ni empieza por `# ` hasta la anterior
# a la marca— es un bloque sin marca, de obligado ilegible: va a los cuatro archivos por rol, sin cambiar un byte y en
# su sitio, con aviso `fuente:línea`, y el generador sale 0. Casos S3 (revisado), S3b, S3c (control, sin fail-before)
# y S9 (la fixture de QA), y L4 (P-137-AG). PARTE 2 DE 2 POR REQ-014 CA-18: la parte 1 (`52-adelgazar-lectura-por-rol.sh`, que conserva
# su nombre para no romper sus citas) estaba a 11 líneas del tope de 400. Ninguna parte hace `source` de otra, así que
# el materializador, `rellena`, el extractor aparte, `gen52`, `en52`, `c1_52`, `ord52` y `filar52` vienen DUPLICADOS de
# la parte 1 —el extractor, literal: la misma regla en las dos— y lo dice el piso. DOS ÁRBOLES por fila: la CANDIDATA y
# `3c8394b` —la cabeza de la vuelta 2 de QA, la del fail-before—, archivo a archivo y verificada contra su objeto; sin
# ella, SKIP y motivo, nunca PASS. S9 instala con las plantillas de `081cb10` (la línea base de REQ-036).
CASOS_ESPERADOS_SECCION=9
PISO_AUTONOMO_SECCION=135  # 16 preámbulo (líneas 1-16, con seccion_nueva) + 88 maquinaria compartida duplicada de la parte 1 (los árboles, mat52, rellena, el extractor, ext52, gen52, en52, c1_52 y c1r52, líneas 17-82; ord52, líneas 114-124; filar52, líneas 152-162) + 31 bloque indivisible mayor (fxp52, pre52, S3, S3b y S3c, líneas 83-113)
seccion_nueva "--- 52 (2/2) · lectura por rol: el texto previo a la primera marca va a los cuatro (REQ-036 CA-18, QA-036-03) ---"
REPO52="${SEC_DIR%/}/../../../.."; CAND52="${TPL_DIR%/*}"
v52() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }
ARB52=''; MOT52=''; RC52=0; FX52="$RAIZ/fx52t-$BASHPID"; mkdir -p "$FX52"
ROLES52='analista desarrollador qa seguridad'
RE52="$RAIZ/re52-$BASHPID"; RB52="$RAIZ/rb52t-$BASHPID"; RE52_OK=si; RE52_MOT=''
mat52() {   # <ref> <dir> <rutas…>
  local ref="$1" dir="$2" f d; shift 2
  for f in "$@"; do
    d="${f%/*}"; mkdir -p "$dir/$d"
    git -C "$REPO52" show "$ref:$f" > "$dir/$f" 2>/dev/null \
      && [ "$(git -C "$REPO52" hash-object "$dir/$f" 2>/dev/null)" = "$(git -C "$REPO52" rev-parse "$ref:$f" 2>/dev/null)" ] \
      || { RE52_OK=no; RE52_MOT="$ref no se materializó ($f)"; return 1; }
  done
}
TPL52='templates/AGENTS.md.tpl templates/requirements-README.md.tpl templates/arnes-config.json.tpl templates/CLAUDE.md.tpl'
mat52 3c8394b "$RE52" tools/arnes-lectura-rol.sh skills/arnes-upgrade/SKILL.md agents/analista-requerimientos.md agents/desarrollador.md \
  agents/qa-tester.md agents/auditor-seguridad.md $TPL52 && mat52 081cb10 "$RB52" $TPL52
# `rellena` (los marcadores de arnes-init con los valores de «tienda-demo») tiene su sede en el guion de medida.
eval "$(awk '/<!-- guion: medida-4a/ { e = 1; next } e == 1 && /^```bash/ { e = 2; next } e == 2 && /^```/ { exit } e == 2' \
  "$CAND52/docs/explicacion/medida-4a.md" 2>/dev/null | awk '/^rellena\(\)/, /^}/')"
# --- El extractor aparte (awk), el mismo de la parte 1. Un bloque va de su marca a la línea anterior a la siguiente.
# Antes de la primera marca, el título y los blancos no son bloque; desde la primera línea que no es ni lo uno ni lo
# otro, sí: bloque sin marca, para los cuatro (CA-18, «Qué contiene»; QA-036-03). Obligación LEGIBLE: la de la parte 1.
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
gen52() {   # <proyecto>: el generador del árbol en prueba; deja RC52 y su stderr en $FX52/gen.err
  [ -r "$ARB52/tools/arnes-lectura-rol.sh" ] || { MOT52='el árbol no trae tools/arnes-lectura-rol.sh'; RC52=127; return 1; }
  bash "$ARB52/tools/arnes-lectura-rol.sh" "$@" > /dev/null 2> "$FX52/gen.err"; RC52=$?
  return 0
}
en52() {   # <texto> <roles en que debe estar>: está exactamente en esos archivos por rol de FXS52
  local r
  for r in $ROLES52; do
    if grep -qx -- "$1" "$FXS52/.arnes/lectura/$r.md" 2>/dev/null; then
      case " $2 " in *" $r "*) ;; *) MOT52="«$1» está en $r.md"; return 1 ;; esac
    else case " $2 " in *" $r "*) MOT52="«$1» no está en $r.md"; return 1 ;; esac; fi
  done
}
c1_52() {   # <rol> <proyecto>: el archivo, sin sus cuatro líneas de cabecera, es byte a byte lo que da el extractor
  local f="$2/.arnes/lectura/$1.md"
  [ -f "$f" ] || { MOT52="no existe ${f#"$2"/}"; return 1; }
  ext52 "$1" "$2" > "$FX52/esp.$1"; tail -n +5 "$f" > "$FX52/cue.$1"
  cmp -s "$FX52/esp.$1" "$FX52/cue.$1" || { MOT52="$1.md no es la concatenación de sus marcas ($(cmp "$FX52/esp.$1" "$FX52/cue.$1" 2>&1 | head -c 80))"; return 1; }
}
c1r52() { local r; for r in $ROLES52; do c1_52 "$r" "$1" || return 1; done; }
# fxp52 <nombre> <texto previo de AGENTS.md o ''> <texto previo del README o ''> -> FXS52. El texto previo va tras el
# título y un blanco, seguido de un blanco, un subtítulo `# ` y otro blanco: todo eso hasta la marca es SU bloque.
fxp52() {
  FXS52="$FX52/$1"; rm -rf "$FXS52"; mkdir -p "$FXS52/requirements" "$FXS52/.arnes"
  { printf '%s\n' '# A' ''; [ -z "$2" ] || printf '%s\n' "$2" '' '# Subtítulo propio' ''
    printf '%s\n' '[[A-1 · obliga: todos]]' 'a-uno' '[[A-2 · obliga: qa]]' 'a-dos' '[[A-3 · obliga: todos]]' 'a-tres'; } > "$FXS52/AGENTS.md"
  { printf '%s\n' '# R' '' ''; [ -z "$3" ] || printf '%s\n' "$3" ''; printf '%s\n' '[[R-1 · obliga: todos]]' 'r-uno'; } \
    > "$FXS52/requirements/README.md"
}
pre52() {   # <fuente:línea> <texto> <línea que lo precede> <línea que lo sigue>: sale 0, en los cuatro, en su sitio y con aviso
  local r
  gen52 "$FXS52" || return 1; [ "$RC52" -eq 0 ] || { MOT52="salió $RC52: $(head -c 90 "$FX52/gen.err")"; return 1; }
  en52 "$2" "$ROLES52" && c1r52 "$FXS52" || return 1
  for r in $ROLES52; do
    awk -v a="$3" -v b="$2" -v c="$4" '!i && $0 == a { i = NR } !j && $0 == b { j = NR } !k && $0 == c { k = NR }
      END { exit !(i && j == i + 1 && k > j) }' "$FXS52/.arnes/lectura/$r.md" || { MOT52="en $r.md no está en su sitio"; return 1; }
  done
  grep -qF -- "$1: obligado ilegible" "$FX52/gen.err" || { MOT52="stderr no nombra $1"; return 1; }
  MOT52="código 0; en los cuatro, en su sitio; aviso $1"
}
s3_52() { fxp52 s3 'Nota propia de AGENTS.md.' ''; pre52 AGENTS.md:3 'Nota propia de AGENTS.md.' '' '[[A-1 · obliga: todos]]'; }
s3b52() { fxp52 s3b '' 'Nota propia del README.'; pre52 requirements/README.md:4 'Nota propia del README.' 'a-tres' '[[R-1 · obliga: todos]]'; }
s3c52() {   # control: sólo título y blancos antes de la primera marca -> sin bloque ni aviso; tras la cabecera, la primera marca
  local r
  fxp52 s3c '' ''; gen52 "$FXS52" || return 1; [ "$RC52" -eq 0 ] || { MOT52="salió $RC52"; return 1; }
  ! grep -q 'aviso' "$FX52/gen.err" || { MOT52="avisó: $(head -c 80 "$FX52/gen.err")"; return 1; }
  for r in $ROLES52; do
    [ "$(sed -n 5p "$FXS52/.arnes/lectura/$r.md")" = '[[A-1 · obliga: todos]]' ] || { MOT52="$r.md no sigue a la cabecera con la primera marca"; return 1; }
  done
  c1r52 "$FXS52" && MOT52='sin bloque previo ni aviso; extractor = generador'
}
# --- S9: la orden de `arnes-upgrade` del árbol en prueba con el plan completo, sobre un proyecto de 081cb10. ----------
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
nota52() {  # <plantilla> <destino> <nota>: la plantilla rellena, con la nota propia en la línea 3 (tras el título y un blanco)
  rellena "$1" "$FX52/nota.tmp"; awk -v n="$3" 'NR == 3 { print n; print "" } { print }' "$FX52/nota.tmp" > "$2"
}
s9_52() {   # QA-036-03 (c): AGENTS.md y README de 1.36 con una nota propia tras el título; arnes-upgrade y paso 4b
  local r f falta='' n1='Nota del equipo: todo cambio en src/pagos/ es de cobro y es crítico.' n2='Nota: los REQ de cobro llevan siempre seguridad.'
  [ -r "$RB52/templates/CLAUDE.md.tpl" ] || { MOT52="081cb10 no se materializó"; return 2; }
  FXS52="$FX52/s9"; rm -rf "$FXS52"; mkdir -p "$FXS52/requirements" "$FXS52/.arnes/plantillas-origen"
  nota52 "$RB52/templates/AGENTS.md.tpl" "$FXS52/AGENTS.md" "$n1"; nota52 "$RB52/templates/requirements-README.md.tpl" "$FXS52/requirements/README.md" "$n2"
  rellena "$RB52/templates/arnes-config.json.tpl" "$FXS52/.arnes/config.json"; rellena "$RB52/templates/CLAUDE.md.tpl" "$FXS52/CLAUDE.md"
  cp "$RB52"/templates/*.tpl "$FXS52/.arnes/plantillas-origen/"; ord52 "$FXS52" || return 1
  for r in $ROLES52; do
    f="$FXS52/.arnes/lectura/$r.md"; grep -qxF -- "$n1" "$f" 2>/dev/null && grep -qxF -- "$n2" "$f" || falta+=" $r"
  done
  [ "$RC52" -eq 0 ] && [ -z "$falta" ] && ! grep -q '@AGENTS.md' "$FXS52/CLAUDE.md" \
    || { MOT52="generador $RC52; sin las dos notas:${falta:- ninguno}; import en CLAUDE.md: $(grep -c '@AGENTS.md' "$FXS52/CLAUDE.md")"; return 1; }
  MOT52='generador 0; CLAUDE.md sin import; las dos notas literales en los cuatro'
}
# L4 (P-137-AG (A)): cada una de las cuatro definiciones, al caer al respaldo por marcas, lee también el texto previo.
l4_52() {
  local p t   # saltos y blancos dobles normalizados, como en la parte 1: un reflujo del párrafo no cambia la frase
  for p in analista-requerimientos desarrollador qa-tester auditor-seguridad; do
    t="$(<"$ARB52/agents/$p.md")"; t="${t//$'\n'/ }"; while [[ $t == *'  '* ]]; do t="${t//  / }"; done
    [[ $t == *'no lee nada). Si una fuente tiene texto antes de su primera marca, léelo también.'* ]] \
      || { MOT52="$p no dice la frase de L4"; return 1; }
  done
  MOT52='la frase de L4, literal, en las cuatro'
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
filae52() { filar52 "$1" "$2" "$RE52" 3c8394b "$RE52_OK" "$RE52_MOT"; }
filae52 "B11 CA-18 (9) S3: texto propio antes de la primera marca de AGENTS.md -> sale 0, en los cuatro, en su sitio y aviso AGENTS.md:<línea>" s3_52
filae52 "B11 CA-18 (9) S3b: texto propio antes de la primera marca del README -> tras los bloques de AGENTS.md y delante del primero del README" s3b52
# S3c es un control: se cumple también en 3c8394b (allí el título y los blancos ya no eran causa de fallo), sin fail-before.
MOT52=''; ARB52="$CAND52"
if s3c52; then v52 PASS "REQ-036 B11 CA-18 (9) S3c control: sólo título y blancos antes de la primera marca -> sin bloque ni aviso  ($MOT52)"
else v52 FAIL "REQ-036 B11 CA-18 (9) S3c control: sólo título y blancos antes de la primera marca -> sin bloque ni aviso  $MOT52"; fi
filae52 "B11 CA-18 (9) S9: fixture de QA-036-03 (marcas parciales), arnes-upgrade y paso 4b -> generador 0, sin import, las dos notas en los cuatro" s9_52
filae52 "B11 CA-18 L4 (P-137-AG): las cuatro definiciones leen también el texto anterior a la primera marca al caer al respaldo" l4_52
