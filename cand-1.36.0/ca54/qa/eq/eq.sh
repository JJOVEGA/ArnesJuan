#!/usr/bin/env bash
# Ataque a la equivalencia (P-136-D, punto 4) — QA, fase 3. Para cada caso, manifiesto, locale y guardian, corre
# v1.35.0 (ca54/arboles/v1.35.0/hooks, oid = tag) y el candidato (worktree en 82ceb63) A NIVEL DE HOOK y compara
# stdout, rc y stderr byte a byte. Una linea por ejecucion: IGUAL o DIFIERE(stdout|rc|stderr), con las decisiones.
# Uso: eq.sh <bloque> ; bloques: s46 estado identidad techo
set -u
QA=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa
B=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/arboles/v1.35.0/hooks
C=/home/juan/dev/ArnesJuan-v1.36/hooks
LOCD=$QA/eq/loc
W=/tmp/qa-eq-$$; rm -rf "$W"; mkdir -p "$W"   # fuera del arbol de evidencia: los proyectos efimeros
trap 'chmod -R u+rwx "$W" 2>/dev/null; rm -rf "$W"' EXIT
NL=$'\n'; CR=$'\r'; BS='\'; TAB=$'\t'
LOCALES="${LOCALES:-LANG=C LANG=POSIX LANG=C.UTF-8 LANG=en_US.UTF-8 LANG=tr_TR.UTF-8 LC_ALL=tr_TR.UTF-8 LANG=tr_TR.ISO-8859-9 LANG=xx_XX.UTF-8}"
MANIF_BASE='{"agentes":{"agente_codigo":"desarrollador","conocidos":["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"]},"codigo_app":{"globs":["src/*"]},"quality_gates":["true"],"estados":{"completado":"completado"},"requirements_dir":"requirements","pending_approval":"PENDING_APPROVAL.md"}'
mkproj() {   # <dir> <estado terminal> [techo]
  mkdir -p "$1/.arnes" "$1/requirements" "$1/src" "$1/docs"
  if [ -n "${3:-}" ]; then jq -c --arg e "$2" --argjson t "$3" '.estados.completado=$e | .limites.bash_max_analisis=$t' <<< "$MANIF_BASE"
  else jq -c --arg e "$2" '.estados.completado=$e' <<< "$MANIF_BASE"; fi > "$1/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$1/PENDING_APPROVAL.md"
  printf 'x\n' > "$1/src/a.ts"
  printf '# REQ-900\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n' > "$1/requirements/REQ-900.md"
}
js() {   # <cwd|-> <agente|-> <comando> -> JSON
  jq -cn --arg c "$1" --arg a "$2" --arg cmd "$3" \
    '{hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$cmd}} + (if $c != "-" then {cwd:$c} else {} end) + (if $a != "-" then {agent_id:"a1",agent_type:$a} else {} end)'
}
NDIF=0; NIG=0
corre() {   # <id> <proyecto> <json> [guardianes...]
  local id="$1" p="$2" json="$3" g loc ob oc eb ec rb rc db dc res; shift 3
  local gs=("$@"); [ "${#gs[@]}" -gt 0 ] || gs=(guard-completado.sh guard.sh)
  printf '%s' "$json" > "$W/in.json"
  for loc in $LOCALES; do
    for g in "${gs[@]}"; do
      env -u LC_ALL -u LANG -u LANGUAGE -u LC_CTYPE LOCPATH="$LOCD" "$loc" CLAUDE_PROJECT_DIR="$p" timeout 60 bash "$B/$g" < "$W/in.json" > "$W/ob" 2> "$W/eb"; rb=$?
      env -u LC_ALL -u LANG -u LANGUAGE -u LC_CTYPE LOCPATH="$LOCD" "$loc" CLAUDE_PROJECT_DIR="$p" timeout 60 bash "$C/$g" < "$W/in.json" > "$W/oc" 2> "$W/ec"; rc=$?
      db=allow; grep -q '"permissionDecision":"deny"' "$W/ob" && db=deny
      dc=allow; grep -q '"permissionDecision":"deny"' "$W/oc" && dc=deny
      res=''
      cmp -s "$W/ob" "$W/oc" || res+=stdout,
      [ "$rb" = "$rc" ] || res+=rc,
      cmp -s "$W/eb" "$W/ec" || res+=stderr,
      if [ -z "$res" ]; then NIG=$((NIG+1)); res=IGUAL; else NDIF=$((NDIF+1)); res="DIFIERE(${res%,})"
        { echo "### $id | $g | $loc"; echo "--- v1.35.0 rc=$rb"; cat "$W/ob"; echo; cat "$W/eb"; echo "--- candidato rc=$rc"; cat "$W/oc"; echo; cat "$W/ec"; } >> "$QA/eq/difs-${BLOQUE}${SUF:-}.txt"; fi
      printf '%-9s %-60s %-20s %-22s v1.35.0=%s/rc%s cand=%s/rc%s motivo=%s\n' "$res" "${id:0:60}" "$g" "$loc" "$db" "$rb" "$dc" "$rc" "$(jq -r '.hookSpecificOutput.permissionDecisionReason // empty' "$W/oc" 2>/dev/null | cut -c1-70)"
    done
  done
}
BLOQUE="${1:?bloque}"; : > "$QA/eq/difs-${BLOQUE}${SUF:-}.txt"
case "$BLOQUE" in
s46)
  # Las filas de la seccion 46 del banco (REQ-007 CA-66), construidas con su mismo texto, POR guard-completado
  # explicitamente (y por guard.sh), y dos variantes de cada una: con el estado terminal mencionado en una linea
  # previa (el atajo NO aplica) y sin ninguna mencion (el atajo aplica si el comando es ASCII).
  P="$W/p46"; mkproj "$P" completado
  HC1="cat <<EOF > docs/x.md$CR${NL}x${NL}EOF$CR${NL}echo y > src/a.ts${NL}EOF$NL"
  H2_46="cat > docs/x.md <<'EOF'$CR${NL}cuerpo$CR${NL}EOF$CR$NL"
  H_a="cat <<EOF ${BS}${NL}> src/a.ts${NL}x${NL}EOF${NL}"
  H_b="cat <<EOF ${BS}${NL}> requirements/REQ-900.md${NL}Estado: completado${NL}EOF${NL}"
  H_i="cat <<EOF ${BS}${NL}| true${NL}x${NL}EOF${NL}"
  H_o="cat <<EOF ${BS}${NL}> docs/x.md${NL}x${NL}EOF${NL}"
  H_g="cat <<EOF ${BS}${NL}; git clean -f${NL}x${NL}EOF${NL}"
  H_c="cat <<EOF > docs/x.md ${BS}${NL}EOF${NL}echo x > src/a.ts${NL}"
  H9="cat <<EOF ${BS}${NL}echo x > src/a.ts${NL}y${NL}EOF${NL}"
  fila() {   # <id> <agente> <comando>
    corre "$1" "$P" "$(js "$P" "$2" "$3")"
    corre "$1 +mencion" "$P" "$(js "$P" "$2" ": completado${NL}$3")"
    local sin="${3//completado/en-curso}"; [ "$sin" = "$3" ] || corre "$1 -mencion" "$P" "$(js "$P" "$2" "$sin")"
  }
  fila "HC5a dev HC1" desarrollador "$HC1"
  fila "HC9.6 dev H2_46" desarrollador "$H2_46"
  fila "LC10.1 coord H_a" - "$H_a"
  fila "LC10.2 coord H_b" - "$H_b"
  fila "LC10.3 dev H_b" desarrollador "$H_b"
  fila "LC10.4 dev H_a" desarrollador "$H_a"
  fila "LC10.5 coord H_i" - "$H_i"
  fila "LC10.6 coord H_o" - "$H_o"
  fila "LC10.7 coord H_g" - "$H_g"
  fila "LC10.8 coord H_c" - "$H_c"
  fila "LC10.9 coord H9" - "$H9"
  # Las otras dos denegaciones por forma que salen antes del atajo: presupuesto (EXCESO) y CR del delimitador
  big="$(printf 'echo x > f%d; ' $(seq 1 7000))"   # > 65536 bytes con el techo por defecto
  corre "EXCESO coord sin mencion" "$P" "$(js "$P" - "$big")"
  corre "EXCESO dev sin mencion" "$P" "$(js "$P" desarrollador "$big")"
  corre "EXCESO dev +mencion" "$P" "$(js "$P" desarrollador ": completado; $big")"
  corre "CR-delim dev sin mencion" "$P" "$(js "$P" desarrollador "cat <<EOF$CR${NL}x${NL}EOF$CR${NL}")"
  corre "CUERPO-CR dev sin mencion (HC6 por dev)" "$P" "$(js "$P" desarrollador "cat <<EOF > docs/x.md${NL}x${NL}EOF$CR${NL}true${NL}EOF$NL")"
  ;;
estado)
  # El atajo frente a grep: estados terminales de varias formas, menciones de varias formas, destino DENTRO de
  # requirements (la decision depende de grep), FUERA (allow) y NO DETERMINABLE (rc 2 de la pertenencia).
  for est in ${ESTADOS:-completado listo LISTO Fin_2-x i I terminé a.b VACIO}; do
    [ "$est" != VACIO ] || est=''
    P="$W/pe-$RANDOM"; mkproj "$P" "$est"
    lo="${est,,}"; up="${est^^}"
    ws=("$est" "$up" "$lo" "x$est" "1$est" "_$est" "-$est" "$est-" "${est//i/İ}" "${est//i/ı}" "${est//I/İ}" "${est//I/ı}" "${est//l/L}" "$est$CR" $' '"$est" $'\xff'"$est" "$est"$'\xc3' "COMPLETADO" "complet${NL}ado" "nada")
    for w in "${ws[@]}"; do
      for f in "echo x > requirements/REQ-900.md # $w" "echo x > docs/x.md # $w" \
               "echo x > nodir/../requirements/REQ-900.md; : $w" "cat <<'EOF' > requirements/REQ-900.md${NL}Estado: $w${NL}EOF"; do
        corre "est=[$est] w=[$(printf %q "$w")] $(printf %q "$f" | cut -c1-30)" "$P" "$(js "$P" - "$f")" guard-completado.sh
      done
    done
  done ;;
identidad)
  # Identidad y pertenencia con el estado mencionado (el recorrido de destinos SE HACE) y sin el (atajo), por
  # guard.sh, guard-codigo.sh y guard-completado.sh: enlaces, .., /proc, /dev, permisos (la premisa de `-e`
  # antes de `cd -P`), rutas largas, multibyte, CR.
  P="$W/pid"; mkproj "$P" completado
  mkdir -p "$P/d000/x" "$P/d100/x" "$P/d600" "$P/pnox/hijo" "$P/sub"; chmod 000 "$P/d000"; chmod 100 "$P/d100"; chmod 600 "$P/d600"; chmod 000 "$P/pnox"
  ln -s requirements "$P/rq"; ln -s ../requirements "$P/sub/rq"; ln -s nada "$P/roto"; ln -s bucle "$P/bucle"; ln -s "$P/src" "$P/sl"
  ln -s /proc/self/cwd "$P/pcwd"; ln -s requirements/REQ-900.md "$P/lreq"
  largo="$(printf 'a%.0s' $(seq 1 300))"; mb="$(printf 'ñ%.0s' $(seq 1 2100))"
  for d in requirements/REQ-900.md ./requirements//REQ-900.md rq/REQ-900.md sub/rq/REQ-900.md sub/../requirements/REQ-900.md \
           sl/../requirements/REQ-900.md lreq "$P/requirements/REQ-900.md" d000/x/f d000/f d100/x/f d100/f d600/f pnox/hijo/f \
           roto/f bucle/f src/a.ts/f /proc/self/cwd/requirements/REQ-900.md pcwd/requirements/REQ-900.md /dev/stdin /dev/stdin/x \
           /dev/fd/0/x /dev/stdout /dev/null "$largo/f" "requirements/$largo" "docs/$mb" "requirements/$mb" "requirements/REQ-900.md$CR" \
           "requirements/REQ-90${CR}0.md" "requirements/RÉQ.md" $'requirements/\xff.md' nodir/x/../../requirements/REQ-900.md \
           'requirements/REQ-9[0]0.md' 'requirements/*.md' '~/x' '$HOME/x' docs/x.md; do
    for m in ': completado; ' ''; do
      corre "id d=[$(printf %q "$d" | cut -c1-50)] m=[${m:+si}]" "$P" "$(js "$P" - "${m}echo x > $d")" guard-completado.sh guard.sh guard-codigo.sh
    done
    corre "id sin-cwd d=[$(printf %q "$d" | cut -c1-40)]" "$P" "$(js - - ": completado; echo x > $d")" guard-completado.sh guard.sh
  done ;;
techo)
  # El analisis compartido entre puertas (`arnes_escrituras_de`): tamanos alrededor del defecto y del maximo,
  # techos declarados validos, excesivos, con ceros y no numericos, ASCII y multibyte, coordinadora y
  # desarrollador, por guard.sh (donde se reutiliza) y por cada guardian solo.
  for t in none 100000 131072 200000 0131072 99999999999999999999; do
    P="$W/pt-$t"; if [ "$t" = none ]; then mkproj "$P" completado; else mkproj "$P" completado "$t"; fi
    for n in 60000 66000 131000 140000; do
      for u in ': xxxxxxxxxx; ' ': ñññññññññ; ' ': completado; '; do
        cmd=''; while [ "${#cmd}" -lt "$n" ]; do cmd+="$u"; done; cmd+='echo x > f'
        for a in - desarrollador; do
          corre "techo=$t n=$n u=[$u] a=$a" "$P" "$(js "$P" "$a" "$cmd")" guard.sh guard-completado.sh guard-codigo.sh
        done
      done
    done
  done
  P="$W/pt-roto"; mkproj "$P" completado; printf '{"limites":{"bash_max_analisis":"abc"}' > "$P/.arnes/config.json"
  cmd=''; while [ "${#cmd}" -lt 70000 ]; do cmd+='echo x > f; '; done
  corre "manifiesto roto n=70000" "$P" "$(js "$P" - "$cmd")" guard.sh guard-completado.sh ;;
esac
echo "RESUMEN bloque=$BLOQUE IGUAL=$NIG DIFIERE=$NDIF locales=[$LOCALES]"
