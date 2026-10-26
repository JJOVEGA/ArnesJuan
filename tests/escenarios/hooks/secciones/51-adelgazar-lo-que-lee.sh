# Sección 51 del banco — 51-adelgazar-lo-que-lee
# Se hace `source` desde el corredor, en su propio subshell y con sus ayudantes; no se ejecuta
# suelto ni hace `source` de otra sección (invariantes 3 y 4 del README del banco).
# REQ-036 (1.37 · 4a): lo que lee cada agente baja por LECTURA POR DESTINATARIO, sin mover ni condensar normativa.
#   B1 CA-08 la orden de `arnes-upgrade` sobre (a) proyecto sin tocar, (b) texto propio, (c) sin base ·
#   B2 CA-09 el plan dice qué sale, de dónde y adónde, sin tocar el proyecto · B3 CA-07 el manifiesto ·
#   B4 CA-04/CA-05 punteros que resuelven y salvaguardas · B5 CA-01 (i) medido, techo de CA-20 · B6 CA-06 hooks/ y tools/ ·
#   B7 CA-14 marcas y listas de lectura · B8 CA-10 y CA-11 · B9 CA-16 CLAUDE.md sin import (texto y migración) ·
#   B10 CA-17 el recordatorio de SessionStart y el camino común sin coste (P-137-Y (A)).
# DOS ÁRBOLES por fila: la CANDIDATA (`$TPL_DIR/..`) y la cabeza `081cb10` (línea base de REQ-036), archivo a
# archivo y verificado contra su objeto; sin ella, SKIP y motivo, nunca PASS. Todo B1–B5, B7–B9 y la primera de B10 es
# fail-before. Sólo B10 ejecuta hooks; el resto mide textos y la orden de una skill (límite declarado de CA-08).
CASOS_ESPERADOS_SECCION=39
PISO_AUTONOMO_SECCION=106  # 15 preámbulo (líneas 1-15, con seccion_nueva) + 0 maquinaria compartida duplicada + 91 bloque indivisible mayor (B1: la línea base, el guion, orden51, corre51, fx51 y las tres fixtures, líneas 19-109)
seccion_nueva "--- 51 · adelgazar lo que lee cada agente: marcas, migración y medida (REQ-036, 1.37 · 4a) ---"
REPO51="${SEC_DIR%/}/../../../.."; REF51=081cb10; CAND51="${TPL_DIR%/*}"
v51() { echo "  $1  $2"; case "$1" in PASS) PASS=$((PASS + 1)) ;; FAIL) FAIL=$((FAIL + 1)) ;; esac; }
ARB51=''; MOT51=''; ORD51=''; RC51=0; FX51="$RAIZ/fx51-$BASHPID"; mkdir -p "$FX51"
# La línea base: sólo los archivos que esta sección lee, cada uno verificado contra el objeto de 081cb10.
RV51="$RAIZ/rv51-$BASHPID"; RV51_OK=si; RV51_MOT=''
for f51 in templates/AGENTS.md.tpl templates/requirements-README.md.tpl templates/arnes-config.json.tpl \
           agents/analista-requerimientos.md agents/desarrollador.md agents/qa-tester.md agents/auditor-seguridad.md \
           skills/arnes-upgrade/SKILL.md AGENTS.md requirements/README.md templates/CLAUDE.md.tpl CLAUDE.md \
           $(git -C "$REPO51" ls-tree --name-only "$REF51" hooks/ 2>/dev/null); do
  d51="${f51%/*}"; [ "$d51" = "$f51" ] && d51=.
  mkdir -p "$RV51/$d51"
  if git -C "$REPO51" show "$REF51:$f51" > "$RV51/$f51" 2>/dev/null \
     && [ "$(git -C "$REPO51" hash-object "$RV51/$f51" 2>/dev/null)" = "$(git -C "$REPO51" rev-parse "$REF51:$f51" 2>/dev/null)" ]; then :
  else RV51_OK=no; RV51_MOT="081cb10 no se materializó ($f51)"; break; fi
done
[ -r "$RV51/hooks/guard.sh" ] && chmod +x "$RV51"/hooks/*.sh || { RV51_OK=no; RV51_MOT="081cb10 no se materializó (hooks/)"; }
# El guion de medida es la sede de `rellena` (los marcadores de arnes-init con los valores de «tienda-demo»).
GUION51="$(awk '/<!-- guion: medida-4a/ { e = 1; next } e == 1 && /^```bash/ { e = 2; next } e == 2 && /^```/ { exit } e == 2' \
  "$CAND51/docs/explicacion/medida-4a.md" 2>/dev/null)"
eval "$(printf '%s\n' "$GUION51" | awk '/^rellena\(\)/, /^}/')"
lee51() { local t=''; [ -r "$1" ] && t="$(<"$1")"; printf '%s' "${t//$'\n'/ }"; }   # el texto en una línea
# orden51 <SKILL.md> -> ORD51: el bloque de código que sigue al marcador `<!-- orden: adelgazar`; vacía si no está.
orden51() {
  local l='' en=0 o=''
  ORD51=''
  [ -r "$1" ] || return 0
  while IFS= read -r l || [ -n "$l" ]; do
    case "$en:$l" in
      0:*'<!-- orden: adelgazar'*) en=1 ;;
      1:*'```'*) en=2 ;;
      2:*'```'*) ORD51="$o"; return 0 ;;
      2:*) o+="$l"$'\n' ;;
    esac
  done < "$1"
  return 0
}
# corre51 <proyecto> <QUE> [destino]: lo que la skill manda —ejecutar la orden y, SÓLO con código 0, escribir su
# salida entera en el destino (el `Write`)—. Deja RC51; 1 si la skill no trae la orden.
corre51() {
  RC51=127
  [ -n "$ORD51" ] || { MOT51='la skill no trae la orden de adelgazar'; return 1; }
  (cd "$1" && QUE="$2" PLUGIN="$ARB51" bash -c "$ORD51") > "$FX51/out" 2> "$FX51/err"; RC51=$?
  if [ "$RC51" -eq 0 ] && [ -n "${3:-}" ]; then cat "$FX51/out" > "$1/$3"; fi
  return 0
}
# fx51 <nombre> [sin-base] -> FXD51: un proyecto instalado con las plantillas de 081cb10, rellenadas.
fx51() {
  FXD51="$FX51/$1"; rm -rf "$FXD51"; mkdir -p "$FXD51/requirements" "$FXD51/.arnes/plantillas-origen"
  rellena "$RV51/templates/AGENTS.md.tpl" "$FXD51/AGENTS.md"
  rellena "$RV51/templates/requirements-README.md.tpl" "$FXD51/requirements/README.md"
  rellena "$RV51/templates/arnes-config.json.tpl" "$FXD51/.arnes/config.json"
  rellena "$RV51/templates/CLAUDE.md.tpl" "$FXD51/CLAUDE.md"
  [ "${2:-}" = sin-base ] || cp "$RV51"/templates/*.tpl "$FXD51/.arnes/plantillas-origen/"
}
fxa51() {   # (a) sin tocar -> los dos .md son el destino rellenado con los mismos valores; el manifiesto, sus _doc
  fx51 a; corre51 "$FXD51" AGENTS.md AGENTS.md || return 1
  [ "$RC51" -eq 0 ] || { MOT51="AGENTS.md: código $RC51"; return 1; }
  corre51 "$FXD51" requirements/README.md requirements/README.md; corre51 "$FXD51" .arnes/config.json .arnes/config.json
  rellena "$ARB51/templates/AGENTS.md.tpl" "$FX51/esp-a"; rellena "$ARB51/templates/requirements-README.md.tpl" "$FX51/esp-r"
  cmp -s "$FX51/esp-a" "$FXD51/AGENTS.md" || { MOT51='AGENTS.md no es el destino rellenado'; return 1; }
  cmp -s "$FX51/esp-r" "$FXD51/requirements/README.md" || { MOT51='el README no es el destino rellenado'; return 1; }
  rellena "$RV51/templates/arnes-config.json.tpl" "$FX51/base.json"; rellena "$ARB51/templates/arnes-config.json.tpl" "$FX51/esp.json"
  [ "$(jq -cS 'del(.. | ._doc?)' "$FXD51/.arnes/config.json")" = "$(jq -cS 'del(.. | ._doc?)' "$FX51/base.json")" ] \
    || { MOT51='cambió el manifiesto fuera de los _doc'; return 1; }
  [ "$(jq -c '[.. | ._doc? // empty]' "$FXD51/.arnes/config.json")" = "$(jq -c '[.. | ._doc? // empty]' "$FX51/esp.json")" ] \
    || { MOT51='los _doc no son los del destino'; return 1; }
}
fxb51() {   # (b) texto propio en § 6 y en un _doc -> conservados byte a byte, CONFLICTO, y lo demás sustituido
  local s6=''
  fx51 b
  awk '{ print } /^\*\*Loop de error\.\*\*/ && !d { print "NOTA PROPIA: aquí contamos distinto."; d = 1 }' "$FXD51/AGENTS.md" > "$FX51/t"
  cat "$FX51/t" > "$FXD51/AGENTS.md"
  jq '.agentes._doc = "doc propio"' "$FXD51/.arnes/config.json" > "$FX51/t"; cat "$FX51/t" > "$FXD51/.arnes/config.json"
  s6="$(awk '/^## 6\./ { f = 1 } f && /^\[\[A-7 |^## 7\./ { exit } f' "$FXD51/AGENTS.md")"
  corre51 "$FXD51" plan || return 1   # el plan va ANTES de aplicar (CA-09); después, la base ya no casa
  grep -q '^### 6\. Orquestación.* — CONFLICTO' "$FX51/out" && grep -q '^### agentes\._doc — CONFLICTO' "$FX51/out" \
    || { MOT51='el plan no declara los CONFLICTO'; return 1; }
  corre51 "$FXD51" AGENTS.md AGENTS.md
  [ "$RC51" -eq 0 ] || { MOT51="código $RC51"; return 1; }
  [ "$(awk '/^## 6\./ { f = 1 } f && /^\[\[A-7 |^## 7\./ { exit } f' "$FXD51/AGENTS.md")" = "$s6" ] \
    || { MOT51='la § 6 propia no se conservó byte a byte'; return 1; }
  grep -q '^\[\[A-13\.2 · obliga: todos\]\]$' "$FXD51/AGENTS.md" || { MOT51='la § 13 no se sustituyó'; return 1; }
  corre51 "$FXD51" .arnes/config.json .arnes/config.json
  [ "$(jq -r .agentes._doc "$FXD51/.arnes/config.json")" = 'doc propio' ] || { MOT51='el _doc propio no se conservó'; return 1; }
}
fxc51() {   # (c) sin plantillas de origen -> UNKNOWN en los tres, código ≠ 0 y nada tocado
  local antes=''
  fx51 c sin-base; antes="$(cd "$FXD51" && cksum AGENTS.md requirements/README.md .arnes/config.json)"
  corre51 "$FXD51" AGENTS.md AGENTS.md || return 1
  [ "$RC51" -ne 0 ] && grep -q UNKNOWN "$FX51/err" || { MOT51="AGENTS.md sin base: código $RC51"; return 1; }
  corre51 "$FXD51" requirements/README.md requirements/README.md; [ "$RC51" -ne 0 ] || { MOT51='README sin base aplicado'; return 1; }
  corre51 "$FXD51" .arnes/config.json .arnes/config.json; [ "$RC51" -ne 0 ] || { MOT51='manifiesto sin base aplicado'; return 1; }
  [ "$(cd "$FXD51" && cksum AGENTS.md requirements/README.md .arnes/config.json)" = "$antes" ] || { MOT51='tocó el proyecto'; return 1; }
}
fxp51() {   # CA-09: el plan sale ANTES de aplicar, no toca nada y dice de dónde sale cada texto y adónde va
  local antes=''
  fx51 p; antes="$(cd "$FXD51" && cksum AGENTS.md requirements/README.md .arnes/config.json)"
  corre51 "$FXD51" plan || return 1
  [ "$RC51" -eq 0 ] || { MOT51="el plan salió con código $RC51"; return 1; }
  [ "$(cd "$FXD51" && cksum AGENTS.md requirements/README.md .arnes/config.json)" = "$antes" ] || { MOT51='el plan tocó el proyecto'; return 1; }
  grep -q '^- \*\*Sale\*\* de `requirements/README.md` § «Cómo se escribe un criterio que no se desmiente»: \*\*Caso medido\.\*\*' "$FX51/out" \
    && grep -q '^  \*\*Va a:\*\* `requirements/README.md` § «Anexo explicativo — casos medidos»' "$FX51/out" \
    && grep -q '^- \*\*Sale\*\* de `.arnes/config.json` § «_doc»: Manifiesto machine-readable' "$FX51/out" \
    || { MOT51='el plan no dice qué sale, de dónde ni adónde'; return 1; }
  grep -q '^## \.arnes/lectura/.* — derivado: se regenera$' "$FX51/out" || { MOT51='el plan no lista los archivos por rol (CA-18)'; return 1; }
}
b3_51() {   # CA-07: JSON válido; el resto idéntico a la base; cada _doc cambiado apunta a un ancla que existe
  local t="$ARB51/templates/arnes-config.json.tpl" p='' n=0 a='' sec=''
  rellena "$t" "$FX51/c.json"; rellena "$RV51/templates/arnes-config.json.tpl" "$FX51/b.json"
  jq -e . "$FX51/c.json" >/dev/null 2>&1 || { MOT51='no es JSON'; return 1; }
  [ "$(jq -cS 'del(.. | ._doc?)' "$FX51/c.json")" = "$(jq -cS 'del(.. | ._doc?)' "$FX51/b.json")" ] || { MOT51='cambió algo fuera de los _doc'; return 1; }
  sec="$(awk '/^## 14\./ { f = 1 } f' "$ARB51/templates/AGENTS.md.tpl")"; sec="${sec//\`/}"
  while IFS= read -r p; do
    n=$((n + 1)); a="${p#*«}"; a="${a%%»*}"
    case "$p" in *'AGENTS.md § 14, «'*'»'*) ;; *) MOT51="un _doc cambiado sin puntero: ${p:0:60}"; return 1 ;; esac
    case "$sec" in *"$a"*) ;; *) MOT51="el ancla «$a» no está en AGENTS.md § 14"; return 1 ;; esac
  done < <(jq -rn --slurpfile c "$FX51/c.json" --slurpfile b "$FX51/b.json" \
             '$c[0] | paths(type == "string") as $q | select($q[-1] == "_doc") | select(getpath($q) != ($b[0] | getpath($q))) | getpath($q)')
  [ "$n" -ge 3 ] || { MOT51="sólo $n _doc retirados con puntero"; return 1; }
}
b4_51() {   # CA-04: todo puntero resuelve —archivo, ancla e identificadores—, en la plantilla y en este repositorio
  local t r p f a n=0 m=0 sec=''
  t="$(lee51 "$ARB51/templates/requirements-README.md.tpl")"
  grep -q '^## Anexo explicativo — casos medidos$' "$ARB51/templates/requirements-README.md.tpl" || { MOT51='la plantilla no tiene su anexo'; return 1; }
  for a in '*Por qué existe esta sección.*' '*(a)*' '*(b)*' '*(c)*' '*(d)*'; do
    grep -qxF -- "$a" "$ARB51/templates/requirements-README.md.tpl" || { MOT51="falta el ancla $a del anexo"; return 1; }
  done
  r="$t"; while [[ $r == *'§ «Anexo explicativo — casos medidos»'* ]]; do n=$((n + 1)); r="${r#*'§ «Anexo explicativo — casos medidos»'}"; done
  [ "$n" -ge 5 ] || { MOT51="la plantilla tiene $n punteros a su anexo"; return 1; }
  r="$(lee51 "$ARB51/requirements/README.md")"
  while [[ $r =~ \`docs/explicacion/([a-z0-9-]+\.md)\`\ §\ «([^»]+)» ]]; do
    m=$((m + 1)); f="${BASH_REMATCH[1]}"; a="${BASH_REMATCH[2]}"; r="${r#*"${BASH_REMATCH[0]}"}"
    grep -qxF -- "## $a" "$ARB51/docs/explicacion/$f" 2>/dev/null || { MOT51="no resuelve: $f § «$a»"; return 1; }
  done
  [ "$m" -ge 5 ] || { MOT51="el README de este repositorio tiene $m punteros"; return 1; }
  sec="$(awk '/^## \(d\)/ { f = 1 } f' "$ARB51/docs/explicacion/casos-medidos.md" 2>/dev/null)"
  [[ $sec == *REQ-016* && $sec == *CA-08* ]] || { MOT51='el ancla (d) no contiene REQ-016 CA-08'; return 1; }
}
# abierto51 <texto>: imprime los identificadores de hallazgo del texto que algún registro de hallazgos nombra —el
# registro de seguridad, los pendientes o un `Hallazgos abiertos:` de un REQ—. Fail-closed: nombrado = abierto.
abierto51() {
  local t="$1" id='' reg=''
  reg="$(cat "$REPO51/docs/seguridad/registro-seguridad.md" "$REPO51/docs/PENDIENTES.md" 2>/dev/null)
$(grep -h '^Hallazgos abiertos:' "$REPO51"/requirements/REQ-*.md 2>/dev/null)"
  while [[ $t =~ (^|[^A-Za-z0-9])((SEC|QA|F|PR|PC|AN)-[0-9]+(-[0-9]+)*) ]]; do
    id="${BASH_REMATCH[2]}"; t="${t#*"$id"}"
    [[ $reg == *"$id"* ]] && printf '%s\n' "$id"
  done
  return 0
}
b4s_51() {  # CA-05 (i) y (ii) sobre lo que de verdad salió: ningún hallazgo nombrado por un registro, ninguna sede única
  local mov='' hall=''
  [ -r "$ARB51/docs/explicacion/INVENTARIO-4a.md" ] || { MOT51='no hay inventario'; return 1; }
  [ -r "$ARB51/docs/explicacion/casos-medidos.md" ] || { MOT51='no hay destino de lo movido'; return 1; }
  mov="$(cat "$ARB51/docs/explicacion/casos-medidos.md")
$(awk '/^## Anexo explicativo/ { f = 1 } /^\[\[R-8 / { f = 0 } f' "$ARB51/templates/requirements-README.md.tpl")
$(awk '/^## 14\./ { f = 1 } f' "$ARB51/templates/AGENTS.md.tpl")"
  hall="$(abierto51 "$mov")"
  [ -z "$hall" ] || { MOT51="lo movido cita hallazgos de un registro: ${hall//$'\n'/ }"; return 1; }
  case "$mov" in *'norma única'*|*'sede única'*|*'sede normativa'*|*'SEDE NORMATIVA'*) MOT51='lo movido declara una sede'; return 1 ;; esac
}
b5_51() {   # CA-20: lo que la definición del analista manda leer (guion de CA-01 (i)), <= 75 280 B en CADA modo. Es el
  # techo de regresión de lo aceptado por P-137-AA (operativo), NO el de contrato de CA-01 (75 000 B), que no se retoca.
  local out='' tot='' rc=0 n=0
  out="$(TPL="$ARB51/templates" DEF="$ARB51/agents/analista-requerimientos.md" ROL=analista bash -c "$GUION51" 2>&1)"; rc=$?
  for tot in $(printf '%s\n' "$out" | sed -n 's/^modo=.* total=\([0-9]*\)$/\1/p'); do
    n=$((n + 1)); [ "$tot" -le 75280 ] || { MOT51="medido $tot B > 75 280 B (techo de regresión aceptado por P-137-AA; el de contrato de CA-01, 75 000 B, no se retoca)"; return 1; }
  done
  [ "$rc" -eq 0 ] && [ "$n" -eq 2 ] || { MOT51="el guion no midió (código $rc, $n de 2 modos): ${out:0:120}"; return 1; }   # cortado a medias no es medida
  MOT51="$(printf '%s\n' "$out" | sed -n 's/^modo=\([a-z]*\) .* total=\([0-9]*\)$/\1 \2 B/p' | tr '\n' ' ')<= 75 280 B, lo aceptado por P-137-AA, no el techo de contrato (75 000 B)"
}
b7_51() {   # CA-14: toda marca bien formada y única; cada definición lista exactamente los bloques que la obligan
  local f='' l='' rol='' def='' t='' lista='' calc='' tok=''
  for f in templates/AGENTS.md.tpl templates/requirements-README.md.tpl AGENTS.md requirements/README.md; do
    [ "$(grep -c '^\[\[' "$ARB51/$f")" -ge 10 ] || { MOT51="$f tiene menos de 10 marcas"; return 1; }
    while IFS= read -r l; do
      [[ $l =~ ^\[\[[AR]-[0-9]+(\.[0-9]+)?\ ·\ (explicativo|obliga:\ (todos|coordinadora|analista|desarrollador|qa|seguridad)(,\ (coordinadora|analista|desarrollador|qa|seguridad))*)\]\]$ ]] \
        || { MOT51="marca mal formada en $f: $l"; return 1; }
    done < <(grep '^\[\[' "$ARB51/$f")
    [ -z "$(grep '^\[\[' "$ARB51/$f" | awk '{ print $1 }' | sort | uniq -d)" ] || { MOT51="id repetido en $f"; return 1; }
  done
  for rol in analista:analista-requerimientos desarrollador:desarrollador qa:qa-tester seguridad:auditor-seguridad; do
    def="$ARB51/agents/${rol#*:}.md"; rol="${rol%%:*}"
    t="$(lee51 "$def")"; t="${t#*Hoy son}"; t="${t%%Si esta lista*}"; lista=''
    while [[ $t =~ ([AR]-[0-9]+(\.[0-9]+)?) ]]; do tok="${BASH_REMATCH[1]}"; lista+="$tok "; t="${t#*"$tok"}"; done
    calc="$(grep -h '^\[\[' "$ARB51/templates/AGENTS.md.tpl" "$ARB51/templates/requirements-README.md.tpl" \
      | awk -v r="$rol" '{ o = $0; sub(/^.*obliga: /, "", o); sub(/\]\]$/, "", o); gsub(/ /, "", o); o = "," o ","
                           if ($0 ~ /obliga: / && (index(o, "," r ",") || index(o, ",todos,"))) { id = $1; sub(/^\[\[/, "", id); printf "%s ", id } }')"
    [ -n "$lista" ] && [ "$lista" = "$calc" ] || { MOT51="la lista de $rol no es la de sus marcas: «$lista» frente a «$calc»"; return 1; }
  done
}
b8a_51() {  # CA-10: la regla de qué va siempre por Edit, por propiedad, en la plantilla y en este AGENTS.md
  local f='' t=''
  for f in templates/AGENTS.md.tpl AGENTS.md; do
    t="$(lee51 "$ARB51/$f")"
    [[ $t == *'todo archivo versionado del proyecto que un agente cambia a mano se cambia con `Edit`/`Write`/`MultiEdit`, haya o no una puerta que lo mire.'* \
       && $t == *'exige declarar **por qué** en el informe'* && $t == *'ninguna puerta lo comprueba'* ]] || { MOT51="$f no trae CA-10"; return 1; }
  done
}
b8b_51() {  # CA-11: sólo la plantilla trae «una corrección que sólo borra no gasta pasada»; este AGENTS.md no (F-137-19)
  local t=''
  t="$(lee51 "$ARB51/templates/AGENTS.md.tpl")"
  [[ $t == *'no cuenta como pasada correctiva** si y sólo si'* && $t == *'`git diff --numstat`'* && $t == *'la misma intervención'* ]] \
    || { MOT51='la plantilla no trae CA-11'; return 1; }
  ! grep -q 'no cuenta como pasada correctiva' "$ARB51/AGENTS.md" || { MOT51='este AGENTS.md recibió CA-11'; return 1; }
}
# --- CA-16, CA-14 (marca A-00 y § 12) y CA-17 (P-137-Y (A)) -----------------------------------------------------
INS51='lee AGENTS.md según tu rol, por sus marcas; la coordinadora lo lee entero al empezar'
c16t_51() { # CA-16 (i)(ii) y CA-14: CLAUDE.md sin import y con la instrucción; A-00 y § 12 dicen lo nuevo
  local f='' t=''
  for f in templates/CLAUDE.md.tpl CLAUDE.md; do
    [ -r "$ARB51/$f" ] || { MOT51="no se lee $f"; return 1; }
    ! grep -qE '@(\./)?AGENTS\.md' "$ARB51/$f" || { MOT51="$f importa AGENTS.md"; return 1; }
    grep -qF -- "$INS51" "$ARB51/$f" || { MOT51="$f no trae la instrucción literal"; return 1; }
  done
  for f in templates/AGENTS.md.tpl AGENTS.md; do
    ! grep -qE '`CLAUDE\.md` importa este archivo|← importa AGENTS\.md' "$ARB51/$f" || { MOT51="$f dice que CLAUDE.md lo importa"; return 1; }
    t="$(lee51 "$ARB51/$f")"; t="${t// > / }"   # la cita de A-00 parte la instrucción en líneas que empiezan por «> »
    [[ $t == *'`CLAUDE.md` **no** importa este archivo'*"$INS51"* ]] || { MOT51="la marca A-00 de $f no dice lo nuevo"; return 1; }
  done
}
fxa16_51() {   # CA-16 (a) sin tocar -> el CLAUDE.md del destino, rellenado con los mismos valores
  fx51 a16; corre51 "$FXD51" CLAUDE.md CLAUDE.md || return 1
  [ "$RC51" -eq 0 ] || { MOT51="CLAUDE.md: código $RC51"; return 1; }
  rellena "$ARB51/templates/CLAUDE.md.tpl" "$FX51/esp-c"
  cmp -s "$FX51/esp-c" "$FXD51/CLAUDE.md" || { MOT51='CLAUDE.md no es el destino rellenado'; return 1; }
}
fxb16_51() {   # CA-16 (b) texto propio -> byte a byte salvo el import, que deja su sitio a la instrucción; si no se
  local esp=''  # puede sin tocar lo propio (el import dos veces), CONFLICTO y el archivo entero intacto
  fx51 b16
  awk '{ print } /^@AGENTS\.md$/ { print "Nota propia: usamos pnpm." }' "$FXD51/CLAUDE.md" > "$FX51/t"; cat "$FX51/t" > "$FXD51/CLAUDE.md"
  esp="$(awk -v i="$(grep -F -- "$INS51" "$ARB51/templates/CLAUDE.md.tpl")" '/^@AGENTS\.md$/ { print i; next } { print }' "$FXD51/CLAUDE.md")"
  corre51 "$FXD51" plan || return 1
  grep -q '^### (preámbulo) — PROPIO' "$FX51/out" && grep -q '^- \*\*Sale\*\* de `CLAUDE.md` § «(preámbulo)»: @AGENTS.md$' "$FX51/out" \
    || { MOT51='el plan no declara el import que sale de lo propio'; return 1; }
  corre51 "$FXD51" CLAUDE.md CLAUDE.md
  [ "$RC51" -eq 0 ] || { MOT51="código $RC51"; return 1; }
  [ "$(<"$FXD51/CLAUDE.md")" = "$esp" ] || { MOT51='lo propio no se conservó byte a byte, o el import sigue'; return 1; }
  fx51 b16c; awk '{ print } /^@AGENTS\.md$/ { print }' "$FXD51/CLAUDE.md" > "$FX51/t"; cat "$FX51/t" > "$FXD51/CLAUDE.md"
  esp="$(cksum < "$FXD51/CLAUDE.md")"
  corre51 "$FXD51" plan; grep -q '^### (preámbulo) — CONFLICTO' "$FX51/out" || { MOT51='el import doble no sale CONFLICTO'; return 1; }
  corre51 "$FXD51" CLAUDE.md CLAUDE.md
  [ "$RC51" -eq 0 ] && [ "$(cksum < "$FXD51/CLAUDE.md")" = "$esp" ] || { MOT51='CONFLICTO: se tocó lo propio'; return 1; }
}
fxc16_51() {   # CA-16 (c) sin plantilla de origen -> UNKNOWN, código ≠ 0 y CLAUDE.md sin tocar
  local antes=''
  fx51 c16 sin-base; antes="$(cksum < "$FXD51/CLAUDE.md")"
  corre51 "$FXD51" CLAUDE.md CLAUDE.md || return 1
  [ "$RC51" -ne 0 ] && grep -q UNKNOWN "$FX51/err" || { MOT51="CLAUDE.md sin base: código $RC51 $(head -c 60 "$FX51/err")"; return 1; }
  [ "$(cksum < "$FXD51/CLAUDE.md")" = "$antes" ] || { MOT51='tocó CLAUDE.md'; return 1; }
}
fxp16_51() {   # CA-16 + CA-09: el plan incluye CLAUDE.md, no toca nada y dice qué sale (el import) antes de aplicar
  local antes=''
  fx51 p16; antes="$(cksum < "$FXD51/CLAUDE.md")"
  corre51 "$FXD51" plan || return 1
  [ "$RC51" -eq 0 ] && [ "$(cksum < "$FXD51/CLAUDE.md")" = "$antes" ] || { MOT51="el plan: código $RC51 o tocó CLAUDE.md"; return 1; }
  grep -q '^## CLAUDE.md — OK' "$FX51/out" && grep -q '^- \*\*Sale\*\* de `CLAUDE.md` § «(preámbulo)»: @AGENTS.md$' "$FX51/out" \
    || { MOT51='el plan no dice que sale el import de CLAUDE.md'; return 1; }
}
# evento51 <árbol> <evento> <entrada> [PATH]: lo que Claude Code haría con hooks.json —cada orden registrada en ese
# evento, con CLAUDE_PLUGIN_ROOT en el árbol— y deja su salida en $FX51/ev y el peor código en RC51.
evento51() {
  local c='' p="${4:-$PATH}"
  RC51=0; : > "$FX51/ev"
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    printf '%s' "$3" | CLAUDE_PLUGIN_ROOT="$1" PATH="$p" bash -c "$c" >> "$FX51/ev" 2>/dev/null || RC51=$?
  done < <(jq -r --arg e "$2" '.hooks[$e][]?.hooks[]?.command' "$1/hooks/hooks.json" 2>/dev/null)
}
c17a_51() { # CA-17: SessionStart recuerda leer AGENTS.md entero, sin manifiesto, con manifiesto roto y sin jq; sale 0
  local d="$FX51/s17" pr=''
  mkdir -p "$d/sinjq" "$d/roto/.arnes"; ln -sf "$(command -v bash)" "$d/sinjq/bash"; printf '{roto' > "$d/roto/.arnes/config.json"
  for pr in "$d" "$d/roto"; do
    CLAUDE_PROJECT_DIR="$pr" evento51 "$ARB51" SessionStart '{"hook_event_name":"SessionStart","source":"startup"}' "$d/sinjq"
    [ "$RC51" -eq 0 ] || { MOT51="SessionStart salió $RC51"; return 1; }
    grep -q 'AGENTS.md ENTERO' "$FX51/ev" || { MOT51="sin recordatorio al abrir la sesión (${pr##*/})"; return 1; }
  done
}
# c17b_51: CA-17 «sin coste en el camino común» y CA-06. Frente a 081cb10: (i) PreToolUse, Stop y SubagentStop
# registrados igual y SessionStart sólo con inicio-sesion.sh; (ii) la lista de procesos que lanzan las órdenes
# —la registra tests/util/sonda-procesos.sh, por sonda51— es idéntica, en el mismo orden y no vacía; (iii) ninguna orden
# emite el recordatorio; (iv) el script nuevo, contado aparte, no lanza ninguno y corre una vez.
c17b_51() {
  local e='' n='' j='' k=0
  [ "$(jq -cS '.hooks | del(.SessionStart)' "$CAND51/hooks/hooks.json")" = "$(jq -cS '.hooks | del(.SessionStart)' "$RV51/hooks/hooks.json")" ] \
    || { MOT51='cambió el registro de PreToolUse, Stop o SubagentStop'; return 1; }
  [ "$(jq -r '[.hooks.SessionStart[]?.hooks[]?.command | split("/") | last] | join(",")' "$CAND51/hooks/hooks.json")" = inicio-sesion.sh ] \
    || { MOT51='SessionStart no es sólo inicio-sesion.sh'; return 1; }
  for j in "$(emite_bash 'ls -la' '' '')" "$(emite_write "$PROJ/src/x.ts" 'x')" "$(emite_bash 'echo x > src/y.ts' a1 desarrollador)"; do
    k=$((k + 1))
    for n in "$RV51" "$CAND51"; do
      sonda51 "$n" PreToolUse "$j" "$FX51/esp-$k-${n##*/}" || return 1
      ! grep -q 'AGENTS.md ENTERO' "$FX51/ev" || { MOT51='una orden emitió el recordatorio'; return 1; }
    done
    [ -s "$FX51/esp-$k-${RV51##*/}" ] || { MOT51="la sonda no vio procesos en la orden $k: no mediría nada"; return 1; }
    cmp -s "$FX51/esp-$k-${RV51##*/}" "$FX51/esp-$k-${CAND51##*/}" || { MOT51="la orden $k lanza otros procesos que en 081cb10"; return 1; }
    e+="$(wc -l < "$FX51/esp-$k-${RV51##*/}") "
  done
  # El script nuevo, contado aparte y en un proyecto con fuentes, para que el generador de CA-18 trabaje de verdad.
  mkdir -p "$FX51/s18/requirements" "$FX51/s18/.arnes"; cp "$CAND51/AGENTS.md" "$FX51/s18/"; cp "$CAND51/requirements/README.md" "$FX51/s18/requirements/"
  CLAUDE_PROJECT_DIR="$FX51/s18" sonda51 "$CAND51" SessionStart '{}' "$FX51/esp-s" || return 1
  [ "$(grep -c 'AGENTS.md ENTERO' "$FX51/ev")" -eq 1 ] && [ "$CTA51" -ge 1 ] && [ -s "$FX51/s18/.arnes/lectura/qa.md" ] \
    || { MOT51="el script nuevo: $(grep -c 'AGENTS.md ENTERO' "$FX51/ev") recordatorios, $CTA51 procesos y sin generar"; return 1; }
  MOT51="procesos por orden, iguales y en el mismo orden: $e; inicio-sesion.sh, una vez al abrir: $CTA51 procesos (generador), un recordatorio"
}
# sonda51 <árbol> <evento> <entrada> <lista>: las órdenes del evento, bajo tests/util/sonda-procesos.sh (la sede
# única de contar procesos con envoltorios, REQ-021 CA-07.4). Deja la salida del hook en $FX51/ev, la CUENTA de la
# sonda en CTA51 y la LISTA ordenada en <lista>: el sujeto corre dentro de la sonda y copia su registro, `$SP_REG`
# (una línea por proceso, en orden) —acoplamiento declarado a ese nombre—. Sin registro de la sonda, falla.
sonda51() {
  local c='' s='' r=''
  while IFS= read -r c; do
    [ -n "$c" ] && s+="CLAUDE_PLUGIN_ROOT=$(printf %q "$1") bash -c $(printf %q "$c") <<< $(printf %q "$3") >> $(printf %q "$FX51/ev") 2>/dev/null; "
  done < <(jq -r --arg e "$2" '.hooks[$e][]?.hooks[]?.command' "$1/hooks/hooks.json" 2>/dev/null)
  : > "$FX51/ev"; : > "$4"
  r="$("$UTIL_DIR/sonda-procesos.sh" --etiqueta req036-ca17 --sujeto "${s}printf '%s\n' \"\$(<\"\$SP_REG\")\" > $(printf %q "$4")" \
       --binarios 'jq awk grep sed tr date cat basename dirname mktemp wc head tail sort git cut uniq find stat realpath readlink cksum ls rm mv cp touch mkdir tee od xargs sleep timeout id sha256sum' 2>/dev/null)"
  [[ " $r" =~ \ cuenta=([0-9]+) ]] || { MOT51="la sonda no emitió registro: ${r:0:80}"; return 1; }
  CTA51="${BASH_REMATCH[1]}"; [ "$CTA51" = 0 ] && : > "$4"
  return 0
}
# fila51 <id> <función>: la misma función sobre la candidata (cumple) y sobre 081cb10 (no cumple: fail-before).
fila51() {
  local nom="REQ-036 $1"
  MOT51=''; ARB51="$CAND51"; orden51 "$ARB51/skills/arnes-upgrade/SKILL.md"
  if [ "$RV51_OK" != si ]; then v51 FAIL "$nom candidata  sin línea base no se construyen los proyectos de prueba ($RV51_MOT)"
  elif "$2"; then v51 PASS "$nom candidata${MOT51:+  ($MOT51)}"; else v51 FAIL "$nom candidata  $MOT51"; fi
  if [ "$RV51_OK" != si ]; then v51 SKIP "$nom 081cb10 (fail-before)  $RV51_MOT"; return 0; fi
  MOT51=''; ARB51="$RV51"; orden51 "$ARB51/skills/arnes-upgrade/SKILL.md"
  if "$2"; then v51 FAIL "$nom 081cb10 (fail-before)  ya se cumple en 081cb10: el caso no discrimina"
  else v51 PASS "$nom 081cb10 (fail-before)  ($MOT51)"; fi
}
fila51 "B1 CA-08 (a): sin tocar -> el destino rellenado con los mismos valores" fxa51
fila51 "B1 CA-08 (b): texto propio -> conservado byte a byte y CONFLICTO" fxb51
fila51 "B1 CA-08 (c): sin plantillas de origen -> UNKNOWN y nada tocado" fxc51
fila51 "B2 CA-09: el plan sale antes de aplicar y dice qué sale, de dónde y adónde" fxp51
fila51 "B3 CA-07: el manifiesto es JSON, idéntico fuera de los _doc, y cada _doc retirado apunta a un ancla" b3_51
fila51 "B4 CA-04: todo puntero resuelve (archivo, ancla, identificadores)" b4_51
fila51 "B4 CA-05 (i)(ii): lo movido no cita hallazgos de un registro ni declara sede" b4s_51
fila51 "B5 CA-20: lo que lee el analista <= 75 280 B (lo aceptado por P-137-AA, no el techo de contrato de CA-01: 75 000 B)" b5_51
fila51 "B7 CA-14: marcas bien formadas y cada definición lista los bloques que la obligan" b7_51
fila51 "B8 CA-10: qué va siempre por Edit, por propiedad, en plantilla y AGENTS.md" b8a_51
fila51 "B8 CA-11: la corrección que sólo borra, sólo en la plantilla" b8b_51
fila51 "B9 CA-16/CA-14: CLAUDE.md sin import y con la instrucción; A-00 y § 12 dicen lo nuevo" c16t_51
fila51 "B9 CA-16 (a): CLAUDE.md sin tocar -> el destino rellenado" fxa16_51
fila51 "B9 CA-16 (b): CLAUDE.md propio -> byte a byte salvo el import; import doble -> CONFLICTO e intacto" fxb16_51
fila51 "B9 CA-16 (c): CLAUDE.md sin plantilla de origen -> UNKNOWN y nada tocado" fxc16_51
fila51 "B9 CA-16/CA-09: el plan muestra el import que sale de CLAUDE.md antes de aplicar" fxp16_51
fila51 "B10 CA-17: SessionStart recuerda leer AGENTS.md entero, sin manifiesto y sin jq, y sale 0" c17a_51
# B10 CA-17: sin coste en el camino común (no es fail-before: compara la candidata CON la línea base).
MOT51=''
if [ "$RV51_OK" != si ]; then v51 FAIL "REQ-036 B10 CA-17: sin línea base no se comparan los procesos ($RV51_MOT)"
elif c17b_51; then v51 PASS "REQ-036 B10 CA-17: las órdenes lanzan los mismos procesos que en 081cb10 y no recuerdan nada ($MOT51)"
else v51 FAIL "REQ-036 B10 CA-17: $MOT51"; fi
# B4 CA-05 (i), fail-before de la REGLA: un bloque que cita un hallazgo abierto la detiene (control positivo).
if [ -n "$(abierto51 'Texto de prueba que cita SEC-020 como medido.')" ]; then
  v51 PASS "REQ-036 B4 CA-05 (i) fixture: un bloque que cita SEC-020 (abierto) se detiene"
else v51 FAIL "REQ-036 B4 CA-05 (i) fixture: un bloque que cita SEC-020 (abierto) NO se detuvo"; fi
# B5 CA-20, fail-before del TECHO: la candidata con la definición del analista rellenada hasta que el modo proyecto
# mida 75 280 B (pasa) y luego 1 B más (falla con la cifra y el techo); y sin generador el guion no mide (falla).
V51="$FX51/b5v"; mkdir -p "$V51/agents" "$V51/tools"; cp -R "$CAND51/templates" "$V51/"; cp "$CAND51/tools/arnes-lectura-rol.sh" "$V51/tools/"
cp "$CAND51/agents/analista-requerimientos.md" "$V51/agents/"; MOT51=''; ARB51="$V51"; T51=''; b5_51; T51="${MOT51#proyecto }"; T51="${T51%% B*}"
if [ -n "$T51" ] && [ "$T51" -eq "$T51" ] 2>/dev/null && [ "$T51" -le 75280 ]; then
  printf '%*s' "$((75280 - T51))" '' >> "$V51/agents/analista-requerimientos.md"; MOT51=''
  if ! b5_51; then v51 FAIL "REQ-036 B5 CA-20 fixture: con 75 280 B exactos NO pasa ($MOT51)"
  else printf ' ' >> "$V51/agents/analista-requerimientos.md"; MOT51=''
    if b5_51; then v51 FAIL "REQ-036 B5 CA-20 fixture: con 75 281 B PASA ($MOT51)"
    else case "$MOT51" in *'medido 75281 B > 75 280 B'*'P-137-AA'*'75 000 B'*) v51 PASS "REQ-036 B5 CA-20 fixture: 75 280 B pasa y 75 281 B falla ($MOT51)" ;;
           *) v51 FAIL "REQ-036 B5 CA-20 fixture: 75 281 B falla sin la cifra o el techo en el motivo ($MOT51)" ;; esac; fi; fi
else v51 FAIL "REQ-036 B5 CA-20 fixture: la candidata no da una medida <= 75 280 B sobre la que sumar 1 B ($MOT51)"; fi
rm -f "$V51/tools/arnes-lectura-rol.sh"; MOT51=''; if b5_51; then v51 FAIL "REQ-036 B5 CA-20 fixture: sin generador el guion no mide y el caso PASA ($MOT51)"
else case "$MOT51" in 'el guion no midió'*) v51 PASS "REQ-036 B5 CA-20 fixture: sin generador el guion no mide y el caso falla ($MOT51)" ;;
       *) v51 FAIL "REQ-036 B5 CA-20 fixture: sin generador falla por otro motivo ($MOT51)" ;; esac; fi
# B6 CA-06: tools/ sólo con el archivo nuevo de CA-18 (todo lo existente sin diff) y hooks/ sólo con lo de CA-17 y
# CA-18 (hooks.json e inicio-sesion.sh; el registro lo mide B10), contra la línea base, árbol de trabajo incluido; y
# ningún archivo nuevo sin versionar fuera de esos dos. `arnes-lectura-rol.sh` no existía en 081cb10: es nuevo.
if git -C "$REPO51" diff --quiet "$REF51" -- tools hooks ':(exclude)hooks/hooks.json' ':(exclude)hooks/inicio-sesion.sh' \
     ':(exclude)tools/arnes-lectura-rol.sh' 2>/dev/null \
   && [ -z "$(git -C "$REPO51" ls-tree --name-only "$REF51" tools/arnes-lectura-rol.sh 2>/dev/null)" ] \
   && [ -z "$(git -C "$REPO51" ls-files --others --exclude-standard -- tools hooks ':(exclude)hooks/inicio-sesion.sh' \
              ':(exclude)tools/arnes-lectura-rol.sh' 2>/dev/null)" ]; then
  v51 PASS "REQ-036 B6 CA-06: tools/ sólo con el archivo nuevo de CA-18 y hooks/ sólo con lo de CA-17 y CA-18 contra 081cb10"
else v51 FAIL "REQ-036 B6 CA-06: tools/ o hooks/ cambiaron contra 081cb10 fuera de CA-17 y CA-18"; fi
