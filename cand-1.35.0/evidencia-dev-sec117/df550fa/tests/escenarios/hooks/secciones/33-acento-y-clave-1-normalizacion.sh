# Sección 33 del banco — 33-acento-y-clave-1-normalizacion
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=45
PISO_AUTONOMO_SECCION=174  # 14 preámbulo + 13 maquinaria compartida duplicada + 147 bloque indivisible mayor · REQ-014 CA-18

# --- REQ-010 (el acento no es parte del valor) + REQ-007 bloque A (la clave tambien se
# --- decora) + SEC-004 (enlace simbolico) + SEC-006 parte a (el manifiesto, en este repo)
# Las dos primeras son LAS DOS MITADES DE LA MISMA LINEA: el valor lo normaliza
# `arnes_norm_campo` y la clave `arnes_norm_clave`, y las dos comparten la misma regla.
# Por eso van en la misma seccion: si una se arregla sin la otra, el defecto reaparece en
# la mitad de al lado.
  seccion_nueva "El acento y la clave decorada (REQ-010 + REQ-007 bloque A, SEC-004):"

# Fixtures NFD escritos con ESCAPES DE BYTES EXPLICITOS, nunca copiando y pegando: un
# editor puede re-normalizar al guardar y el fixture dejaria de medir lo que dice medir.
NFD_O=$'o\xcc\x81'      # o + U+0301 COMBINING ACUTE  == "ó" en NFD
NFD_A=$'a\xcc\x81'      # a + U+0301                  == "á" en NFD
NFD_N=$'n\xcc\x83'      # n + U+0303 COMBINING TILDE  == "ñ" en NFD

# ---------- REQ-010 · informe (arnes-lectura): el mismo lector que la puerta ----------
L33="$(mktemp -d)"; mkdir -p "$L33/.arnes" "$L33/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$L33/.arnes/config.json"
LEC33="$HOOKS_DIR/../tools/arnes-lectura.sh"
# lec33 <nombre> <rc esperado> <patron> <si|no aparece>
lec33() {
  local nombre="$1" rc_esp="$2" patron="$3" debe="$4" out rc hay=no
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  out="$(: > "$ERRLOG"; bash "$LEC33" "$L33" 2>"$ERRLOG")"; rc=$?
  if [ -z "$out" ]; then
    echo "  FAIL  $nombre  el informe no imprimio NADA: no midio nada"; diag; FAIL=$((FAIL+1)); return 0
  fi
  printf '%s' "$out" | grep -Eq -- "$patron" && hay=si
  if [ "$rc" = "$rc_esp" ] && [ "$hay" = "$debe" ]; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  rc=$rc (esperado $rc_esp), patron aparece=$hay (esperado $debe)"; diag; FAIL=$((FAIL+1)); fi
}

# CA-01: EL CASO MEDIDO. `estados.todos` por defecto trae `en-revisión`; el REQ lo escribe
# sin tilde. Contra v1.30.3 esto sale como «ninguna puerta lo reconoce» y el informe sale 1.
printf '# REQ-800\nEstado: en-revision\nQA: aprobado\nSeguridad: n/a\n' > "$L33/requirements/REQ-800.md"
lec33 "REQ-010 CA-01 'Estado: en-revision' SIN tilde no es anomalia (sale 0)" 0 'REQ-800' no
# CA-03: la misma cabecera en NFD (bytes explicitos) tampoco lo es.
printf '# REQ-801\nEstado: en-revisi%sn\nQA: aprobado\nSeguridad: n/a\n' "$NFD_O" > "$L33/requirements/REQ-801.md"
lec33 "REQ-010 CA-03 'en-revisión' en NFD (o+U+0301) no es anomalia (sale 0)" 0 'REQ-801' no
# CA-04: `estándar` no se reconocia porque `á` no estaba en la unica pareja que se plegaba.
printf '# REQ-802\nEstado: en-revision\nQA: aprobado\nSeguridad: n/a\nRigor: est%sndar\n' 'á' > "$L33/requirements/REQ-802.md"
lec33 "REQ-010 CA-04 'Rigor: estándar' se reconoce (sale 0)" 0 'REQ-802' no
printf '# REQ-803\nEstado: en-revision\nQA: aprobado\nSeguridad: n/a\nRigor: cr%stico\n' 'í' > "$L33/requirements/REQ-803.md"
lec33 "REQ-010 CA-04 no-regresion: 'Rigor: crítico' se sigue reconociendo" 0 'REQ-803' no
# CA-11/CA-12: lo que YA se normalizaba no se pierde.
printf '# REQ-804\nEstado: En-Revisi%sn\nQA: **pendiente**\nSeguridad: n/a\n' 'ó' > "$L33/requirements/REQ-804.md"
printf '# REQ-805\nEstado: en-revisi%sn (2026-08-25, tras la ronda 3)\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$L33/requirements/REQ-805.md"
lec33 "REQ-010 CA-11 mayusculas, enfasis y parentesis de evidencia siguen sin marcarse" 0 'REQ-80[45]' no
rm -f "$L33/requirements/REQ-80"[0-5]".md"
# CA-12: un asterisco SUELTO no es enfasis y sigue sin leerse como veredicto.
printf '# REQ-806\nEstado: en-revision\nQA: aprobado*\nSeguridad: n/a\n' > "$L33/requirements/REQ-806.md"
lec33 "REQ-010 CA-12 'QA: aprobado*' (nota al pie) sigue siendo anomalia (sale 1)" 1 'REQ-806' si
rm -f "$L33/requirements/REQ-806.md"
# CA-08: LO QUE NO SE ENSANCHA. Esto pliega ortografia, no separadores ni palabras.
printf '# REQ-807\nEstado: en revision\nQA: aprobado\nSeguridad: n/a\n' > "$L33/requirements/REQ-807.md"
printf '# REQ-808\nEstado: enrevision\nQA: aprobado\nSeguridad: n/a\n' > "$L33/requirements/REQ-808.md"
printf '# REQ-809\nEstado: revisi%sn\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$L33/requirements/REQ-809.md"
lec33 "REQ-010 CA-08 'en revision', 'enrevision' y 'revisión' siguen siendo anomalia" 1 'REQ-80[789]' si
rm -f "$L33/requirements/REQ-80"[789]".md"
# CA-09: la pertenencia al vocabulario sigue siendo EXACTA, no por prefijo (REQ-003 CA-18).
printf '# REQ-810\nEstado: en-revision-parcial\nQA: aprobado\nSeguridad: n/a\n' > "$L33/requirements/REQ-810.md"
lec33 "REQ-010 CA-09 'en-revision-parcial' sigue siendo anomalia (sale 1)" 1 'REQ-810' si
# CA-13: el aviso ensena el valor CRUDO ademas del normalizado. Quien lee el aviso tiene
# que poder ENCONTRAR el texto en su editor; si solo viera el plegado, buscaria en vano.
printf '# REQ-811\nEstado: revisi%sn\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$L33/requirements/REQ-811.md"
lec33 "REQ-010 CA-13 el aviso ensena el valor CRUDO con su tilde" 1 'escrito:  «revisión»' si
lec33 "REQ-010 CA-13 ...y al lado el normalizado que lee la maquina" 1 'se lee:   <revision>' si
rm -f "$L33/requirements/REQ-810.md" "$L33/requirements/REQ-811.md"
# CA-02: LA DIRECCION INVERSA. El manifiesto declara el estado SIN tilde y el REQ lo
# escribe CON tilde: la normalizacion se aplica a los DOS lados de la comparacion.
python3 - "$L33/.arnes/config.json" <<'PY' 2>/dev/null || jq '.estados.todos = ["borrador","en-revision","completado"]' "$L33/.arnes/config.json" > "$L33/.arnes/c2" && mv "$L33/.arnes/c2" "$L33/.arnes/config.json"
import json,sys
p=sys.argv[1]; d=json.load(open(p)); d["estados"]["todos"]=["borrador","en-revision","completado"]
json.dump(d,open(p,"w"))
PY
printf '# REQ-812\nEstado: en-revisi%sn\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$L33/requirements/REQ-812.md"
lec33 "REQ-010 CA-02 manifiesto SIN tilde + REQ CON tilde: tampoco es anomalia" 0 'REQ-812' no
# CA-10: LA FRONTERA. La `ñ` NO es una `n` con adorno: plegarla haria iguales dos palabras
# distintas. Con un vocabulario que declara `año`, el valor `ano` NO casa.
jq '.estados.todos = ["borrador","año","completado"]' "$L33/.arnes/config.json" > "$L33/.arnes/c3" && mv "$L33/.arnes/c3" "$L33/.arnes/config.json"
rm -f "$L33/requirements/REQ-812.md"
printf '# REQ-813\nEstado: ano\nQA: aprobado\nSeguridad: n/a\n' > "$L33/requirements/REQ-813.md"
lec33 "REQ-010 CA-10 la ñ no se pliega: 'ano' no casa con 'año' (sigue anomalia)" 1 'REQ-813' si
printf '# REQ-814\nEstado: a%so\nQA: aprobado\nSeguridad: n/a\n' 'ñ' > "$L33/requirements/REQ-814.md"
rm -f "$L33/requirements/REQ-813.md"
lec33 "REQ-010 CA-10 control: 'año' con ñ SI casa con 'año'" 0 'REQ-814' no
# CA-10 en NFD: `n`+U+0303 tampoco se pliega, porque el diacritico solo se retira tras VOCAL.
printf '# REQ-815\nEstado: a%so\nQA: aprobado\nSeguridad: n/a\n' "$NFD_N" > "$L33/requirements/REQ-815.md"
rm -f "$L33/requirements/REQ-814.md"
lec33 "REQ-010 CA-10 la ñ tampoco se pliega en NFD (n+U+0303 no es 'n')" 1 'REQ-815' si
rm -rf "$L33"

# ---------- REQ-010 · LA PUERTA: el fallo EN ABIERTO que esto cierra ----------
# Un proyecto cuyo `estados.completado` lleva acento —el manifiesto lo declara cada
# proyecto: es mapeo, no mecanismo— y un REQ critico con la auditoria pendiente. Escribir
# el estado SIN tilde hacia que la puerta NO VIERA la transicion: allow, y un REQ critico
# cerrado sin veredicto de seguridad. Falla en abierto y en silencio.
P810="$RAIZ/p810-$BASHPID"; mkdir -p "$P810/.arnes" "$P810/requirements" "$P810/src"
jq '.estados = {"completado":"aprobación","todos":["en-revisión","aprobación"]}' <<< "$MANIFIESTO_BASE" > "$P810/.arnes/config.json"
printf '## Pendientes\n\n## Resueltas\n' > "$P810/PENDING_APPROVAL.md"
printf '# REQ-820\nEstado: en-revisi%sn\nSensible a seguridad: s%s\nQA: aprobado\nSeguridad: pendiente\n' 'ó' 'í' > "$P810/requirements/REQ-820.md"
CLAUDE_PROJECT_DIR="$P810" check "REQ-010 CA-05 estado terminal acentuado escrito SIN tilde -> deny (era ALLOW)" deny \
  guard-completado.sh "$(CLAUDE_PROJECT_DIR="$P810" jq -n --arg fp "$P810/requirements/REQ-820.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$fp|sub("/requirements/.*";""),
      tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"aprobacion"}}')"
CLAUDE_PROJECT_DIR="$P810" check "REQ-010 CA-05 control: el mismo cierre CON tilde ya denegaba" deny \
  guard-completado.sh "$(CLAUDE_PROJECT_DIR="$P810" jq -n --arg fp "$P810/requirements/REQ-820.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$fp|sub("/requirements/.*";""),
      tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"aprobación"}}')"
# CA-06: la direccion contraria. El REQ YA estaba en el estado terminal acentuado y la
# edicion solo cambia la ORTOGRAFIA: no hay transicion nueva que inventar.
printf '# REQ-821\nEstado: aprobaci%sn\nSensible a seguridad: no\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$P810/requirements/REQ-821.md"
CLAUDE_PROJECT_DIR="$P810" check "REQ-010 CA-06 reescribir 'aprobación' como 'aprobacion' no cambia el veredicto" allow \
  guard-completado.sh "$(CLAUDE_PROJECT_DIR="$P810" jq -n --arg fp "$P810/requirements/REQ-821.md" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$fp|sub("/requirements/.*";""),
      tool_input:{file_path:$fp,old_string:"aprobación",new_string:"aprobacion"}}')"
# CA-22: EL VEREDICTO NO PUEDE DEPENDER DEL LOCALE del entorno en que arranca el hook,
# porque ese entorno no lo elige el arnes. Se mide el MISMO caso bajo tres locales.
J820="$(CLAUDE_PROJECT_DIR="$P810" jq -n --arg fp "$P810/requirements/REQ-820.md" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:$fp|sub("/requirements/.*";""),
    tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"aprobacion"}}')"
for LOC in C C.UTF-8 es_ES.UTF-8; do
  got="$(printf '%s' "$J820" | LC_ALL="$LOC" CLAUDE_PROJECT_DIR="$P810" bash "$HOOKS_DIR/guard-completado.sh" 2>/dev/null | grep -Eo '"permissionDecision": *"deny"' | head -1)"
  if [ -n "$got" ]; then echo "  PASS  REQ-010 CA-22 mismo veredicto (deny) bajo LC_ALL=$LOC"; PASS=$((PASS+1))
  else echo "  FAIL  REQ-010 CA-22 bajo LC_ALL=$LOC el veredicto cambio (no denego)"; FAIL=$((FAIL+1)); fi
done
# CA-07: el bloque derivado cuenta las TRES escrituras en la MISMA casilla.
mkdir -p "$P810/docs"; printf '# ESTADO\n\n## Fase\nx\n' > "$P810/docs/ESTADO.md"
rm -f "$P810/requirements/REQ-82"[01]".md"
printf '# REQ-830\nEstado: en-revisi%sn\nQA: aprobado\nSeguridad: n/a\n' 'ó' > "$P810/requirements/REQ-830.md"
printf '# REQ-831\nEstado: en-revision\nQA: aprobado\nSeguridad: n/a\n' > "$P810/requirements/REQ-831.md"
printf '# REQ-832\nEstado: en-revisi%sn\nQA: aprobado\nSeguridad: n/a\n' "$NFD_O" > "$P810/requirements/REQ-832.md"
printf '%s' "$(CLAUDE_PROJECT_DIR="$P810" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')" \
  | CLAUDE_PROJECT_DIR="$P810" bash "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>"$ERRLOG"
n_rev="$(grep -c '^| REQ-83[012] | en-revision |' "$P810/docs/ESTADO.md" 2>/dev/null || true)"
if [ "${n_rev:-0}" = "3" ]; then echo "  PASS  REQ-010 CA-07 las tres escrituras caen en la MISMA casilla del bloque derivado"; PASS=$((PASS+1))
else echo "  FAIL  REQ-010 CA-07 solo $n_rev de 3 cayeron en la casilla de 'en revision'"; diag; FAIL=$((FAIL+1)); fi

# ---------- REQ-010 · CA-14/CA-18: UNA sola normalizacion, y ninguna pareja a mano ----
LIBSH="$HOOKS_DIR/lib.sh"
otros=0
for f in "$HOOKS_DIR/guard-completado.sh" "$HOOKS_DIR/guard-codigo.sh" "$HOOKS_DIR/estado-derivado.sh" \
         "$HOOKS_DIR/campos-req.awk" "$HOOKS_DIR/../tools/arnes-lectura.sh"; do
  [ -f "$f" ] || continue
  grep -Eq '(//|/)[áéíóúüÁÉÍÓÚÜ]/' "$f" && otros=$((otros+1))
done
if [ "$otros" -eq 0 ]; then echo "  PASS  REQ-010 CA-14 el plegado vive SOLO en lib.sh; nadie tiene el suyo"; PASS=$((PASS+1))
else echo "  FAIL  REQ-010 CA-14 $otros archivo(s) fuera de lib.sh pliegan acentos por su cuenta"; FAIL=$((FAIL+1)); fi
# CA-18: el defecto NOMBRADO. Lo que habia era la pareja `Í`/`í` escrita a mano para el
# caso de `sí`, y ninguna mas: el sujeto del control era mas estrecho que su poblacion.
if grep -Eq '^\s*v="\$\{v//Í/i\}"; v="\$\{v//í/i\}"' "$LIBSH"; then
  echo "  FAIL  REQ-010 CA-18 sigue la pareja Í/í escrita a mano para un caso concreto"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-010 CA-18 no queda ninguna pareja de letras escrita a mano"; PASS=$((PASS+1))
fi
# CA-20: SOLO expansion de parametros. Ni un `sed`, `tr`, `iconv` o `awk` nuevo en el plegado.
if awk '/^arnes_pliega_ortografia\(\)/,/^}/' "$LIBSH" | grep -Eq '\b(sed|tr|iconv|perl|awk|python3?)\b'; then
  echo "  FAIL  REQ-010 CA-20 el plegado invoca un binario externo"; FAIL=$((FAIL+1))
else
  echo "  PASS  REQ-010 CA-20 el plegado es solo expansion de parametros (ningun binario)"; PASS=$((PASS+1))
fi

# CA-19: EL CAMINO COMUN NO GANA NI UN PROCESO. Se instrumentan `sed`, `tr` e `iconv` en
# el PATH: sus registros tienen que quedar VACIOS tras un `ls -la` cualquiera.
BIN33="$RAIZ/bin33-$BASHPID"; mkdir -p "$BIN33"
for b in sed tr iconv; do
  real="$(command -v "$b" 2>/dev/null || true)"
  printf '#!/bin/sh\necho "%s $*" >> "%s/registro-%s"\nexec %s "$@"\n' "$b" "$BIN33" "$b" "${real:-/bin/true}" > "$BIN33/$b"
  chmod +x "$BIN33/$b"
done
printf '%s' "$(jq -n '{hook_event_name:"PreToolUse",tool_name:"Bash",cwd:env.CLAUDE_PROJECT_DIR,tool_input:{command:"ls -la"}}')" \
  | PATH="$BIN33:$PATH" bash "$HOOKS_DIR/guard.sh" >/dev/null 2>"$ERRLOG"
huellas=0
for b in sed tr iconv; do [ -s "$BIN33/registro-$b" ] && huellas=$((huellas+1)); done
if [ "$huellas" -eq 0 ]; then echo "  PASS  REQ-010 CA-19 'ls -la' por guard.sh: registros de sed, tr e iconv VACIOS"; PASS=$((PASS+1))
else echo "  FAIL  REQ-010 CA-19 $huellas binario(s) instrumentado(s) se invocaron en el camino comun"; FAIL=$((FAIL+1)); fi

# ---------- REQ-007 bloque A: LA CLAVE DEL CAMPO TAMBIEN SE DECORA ----------
# Todos sobre un REQ con `QA: pendiente`: si la clave se lee, la puerta DENIEGA por el
# veredicto que falta; si no se lee, el campo queda vacio y la puerta deja pasar.
mk_req() { printf '%s\n' "$1" > "$PROJ/requirements/REQ-840.md"; }
cierra() { emite_write "$PROJ/requirements/REQ-840.md" "$1"; }
TAB=$'\t'
mk_req "# REQ-840"
check "REQ-007 CA-01 'Estado:<TAB>completado' con QA pendiente -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado:${TAB}completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-02 '**Estado:** completado' (clave decorada) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
**Estado:** completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-03 ' Estado: completado' (un espacio de sangrado) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
 Estado: completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-03 '  Estado: completado' (dos espacios) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
  Estado: completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-03 '<TAB>Estado: completado' -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
${TAB}Estado: completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-04 'Estado : completado' (espacio antes de los dos puntos) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado : completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-04 '__Estado:__ completado' -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
__Estado:__ completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-04 '*Estado:* completado' -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
*Estado:* completado
QA: pendiente
Seguridad: n/a
")"
check "REQ-007 CA-04 '\`Estado:\` completado' -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
\`Estado:\` completado
QA: pendiente
Seguridad: n/a
")"
# CA-04 (la regla, no la lista): una forma que NADIE ha escrito todavia.
check "REQ-007 CA-04 '**Estado** : completado' (forma no enumerada) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
**Estado** : completado
QA: pendiente
Seguridad: n/a
")"
# CA-05/CA-06: LA TOLERANCIA ES SOBRE COMO SE ESCRIBE LA CLAVE, NUNCA SOBRE DONDE VALE.
printf '# REQ-841\nEstado: en-revisión\nQA: aprobado\nSeguridad: n/a\n\n## Historial de cambios\nEstado: completado\n**Estado:** completado\n' > "$PROJ/requirements/REQ-841.md"
check "REQ-007 CA-05 control: 'Estado: completado' DENTRO de una seccion no cierra nada" allow \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-841.md" '# REQ-841' '# REQ-841 (nota)')"
printf '# REQ-842\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\nSeguridad: pendiente\n\n## Historial de cambios\n**Seguridad:** aprobado\n' > "$PROJ/requirements/REQ-842.md"
check "REQ-007 CA-06 control: un '**Seguridad:** aprobado' en una seccion sigue sin ser veredicto" deny \
  guard-completado.sh "$(emite_edit_real "$PROJ/requirements/REQ-842.md" 'en-revisión' 'completado')"
# CA-07: EL FALLO EN ABIERTO de este bloque. La clave decorada dejaba el campo VACIO, y un
# campo vacio significa «ningun hallazgo»: el REQ cerraba con un hallazgo bloqueante escrito.
check_motivo "REQ-007 CA-07 '**Hallazgos abiertos:** SEC-9 (usuario/dinero)' -> deny por la clase" \
  'usuario/dinero|hallazgo' guard-completado.sh "$(cierra "# REQ-840
Estado: completado
QA: aprobado
Seguridad: n/a
**Hallazgos abiertos:** SEC-9 (usuario/dinero)
")"
# CA-08: la regla vale para LOS SEIS campos, no solo para `Estado:`.
check "REQ-007 CA-08 '**Sensible a seguridad:** sí' con Seguridad pendiente -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado: completado
**Sensible a seguridad:** sí
QA: aprobado
Seguridad: pendiente
")"
check "REQ-007 CA-08 '**QA:** pendiente' -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado: completado
Sensible a seguridad: no
**QA:** pendiente
Seguridad: n/a
")"
check "REQ-007 CA-08 '**Rigor:** ligero' sobre un REQ sensible (el suelo manda) -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado: completado
Sensible a seguridad: sí
**Rigor:** ligero
QA: aprobado
Seguridad: pendiente
")"
# CA-09: LEER DE MAS CAE DEL LADO QUE CIERRA LA PUERTA. La tolerancia nunca BAJA una
# exigencia: `**Rigor:** critico` sobre un REQ no sensible se lee `critico` y exige auditoria.
check "REQ-007 CA-09 '**Rigor:** critico' en un REQ no sensible se LEE critico -> deny" deny \
  guard-completado.sh "$(cierra "# REQ-840
Estado: completado
Sensible a seguridad: no
**Rigor:** critico
QA: aprobado
Seguridad: pendiente
")"
# Control: el mismo REQ con todo en verde SI cierra. Sin esto, los deny de arriba podrian
# estar denegando por cualquier otra razon.
check "REQ-007 bloque A control: clave decorada + todo en verde -> allow" allow \
  guard-completado.sh "$(cierra "# REQ-840
**Estado:** completado
**Sensible a seguridad:** no
**QA:** aprobado
**Seguridad:** n/a
**Hallazgos abiertos:** (ninguno)
")"
# CA-22: EL INFORME LEE EXACTAMENTE LO QUE LEE LA PUERTA, tambien la clave decorada.
# Un informe que dijera «nota sin Estado» sobre un REQ que la puerta ya juzga cerrado miente.
K33="$(mktemp -d)"; mkdir -p "$K33/.arnes" "$K33/requirements"
printf '%s\n' "$MANIFIESTO_BASE" > "$K33/.arnes/config.json"
printf '# REQ-850\n**Estado:** en-revisión\n**QA:** aprobado\n**Seguridad:** n/a\n' > "$K33/requirements/REQ-850.md"
out33="$(bash "$LEC33" "$K33" 2>/dev/null)"; rc33=$?
if [ "$rc33" = "0" ] && printf '%s' "$out33" | grep -q '1 REQ leídos'; then
  echo "  PASS  REQ-007 CA-22 el informe lee la clave decorada igual que la puerta (1 REQ, 0 notas)"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-007 CA-22 el informe no leyo el REQ de clave decorada (rc=$rc33)"; FAIL=$((FAIL+1))
fi
rm -rf "$K33"
# El bloque derivado, con el MISMO documento: la tercera boca dice lo mismo que las otras dos.
printf '# REQ-851\n**Estado:** en-revisión\n**QA:** aprobado\n**Seguridad:** n/a\n' > "$P810/requirements/REQ-851.md"
rm -f "$P810/requirements/REQ-83"[012]".md"
printf '%s' "$(CLAUDE_PROJECT_DIR="$P810" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR,stop_hook_active:false}')" \
  | CLAUDE_PROJECT_DIR="$P810" bash "$HOOKS_DIR/estado-derivado.sh" >/dev/null 2>"$ERRLOG"
if grep -q '^| REQ-851 | en-revision | aprobado | n/a |' "$P810/docs/ESTADO.md" 2>/dev/null; then
  echo "  PASS  REQ-007 CA-22 el bloque derivado tambien lee la clave decorada"; PASS=$((PASS+1))
else
  echo "  FAIL  REQ-007 CA-22 el bloque derivado no leyo la clave decorada"; diag; FAIL=$((FAIL+1))
fi

