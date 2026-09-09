# Sección 26 del banco — 26-veredicto-fechado
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=23
PISO_AUTONOMO_SECCION=61  # 12 preámbulo + 23 maquinaria compartida duplicada + 26 bloque indivisible mayor · REQ-014 CA-18

# --- REQ-002: un veredicto lleva fecha y caduca con el codigo ------------------------
# Medido en un proyecto real: cuatro REQ se habrian cerrado con un `QA: aprobado` emitido
# contra codigo que cambio DESPUES de la firma. Las dos claves nacen APAGADAS: los casos
# de control comprueban primero que sin opt-in no cambia nada.
  seccion_nueva "Veredicto fechado y no caduco (veredictos.*, opt-in):"

# ver_proj <exigir_fecha> <caducan> [fecha del commit del codigo] [globs-json]
ver_proj() {
  VP="$(mktemp -d)"; mkdir -p "$VP/.arnes" "$VP/requirements" "$VP/src"
  jq -n --argjson f "$1" --argjson c "$2" --argjson g "${4:-[\"src/*\"]}" \
    '{agentes:{agente_codigo:"desarrollador"}, codigo_app:{globs:$g},
      quality_gates:["true"], estados:{completado:"completado"},
      requirements_dir:"requirements", pending_approval:"PENDING_APPROVAL.md",
      veredictos:{exigir_fecha:$f, caducan_con_codigo:$c}}' > "$VP/.arnes/config.json"
  printf '## Pendientes\n\n## Resueltas\n' > "$VP/PENDING_APPROVAL.md"
  if [ -n "${3:-}" ]; then
    printf 'codigo\n' > "$VP/src/app.ts"
    git -C "$VP" init -q >/dev/null 2>&1
    git -C "$VP" config user.email banco@arnes.local >/dev/null 2>&1
    git -C "$VP" config user.name banco >/dev/null 2>&1
    git -C "$VP" add -A >/dev/null 2>&1
    GIT_AUTHOR_DATE="$3T10:00:00 +0000" GIT_COMMITTER_DATE="$3T10:00:00 +0000" \
      git -C "$VP" commit -qm codigo >/dev/null 2>&1
  fi
}
# ver_req <archivo> <qa> <seguridad> <rigor>
ver_req() {
  printf '# %s\nEstado: en-revisión\nSensible a seguridad: no\nQA: %s\nSeguridad: %s\nRigor: %s\n' \
    "$(basename "$1" .md)" "$2" "$3" "$4" > "$1"
}
ver_cierra() { emite_edit "$1" "" "" 'Estado: completado'; }

# --- Bloque A: el interruptor y la forma de la fecha ---
# CA-01: sin opt-in, byte a byte lo de 1.30.3. Es el control que protege a todo proyecto
# que no pida nada: una novedad que cambia el juicio sin que nadie la encienda es una
# regresion, por muy correcta que sea.
ver_proj false false; VP1="$VP"
ver_req "$VP1/requirements/REQ-100.md" "aprobado" "aprobado" "critico"
ver_check "CA-01 sin opt-in: veredictos SIN fecha -> allow" allow "$VP1" "$(ver_cierra "$VP1/requirements/REQ-100.md")"
rm -rf "$VP1"

ver_proj true false; VP2="$VP"
ver_req "$VP2/requirements/REQ-101.md" "aprobado" "n/a" "estandar"
ver_check "CA-02 exigir_fecha: 'aprobado' sin parentesis -> deny" deny "$VP2" \
  "$(ver_cierra "$VP2/requirements/REQ-101.md")" 'QA:.*AAAA-MM-DD|AAAA-MM-DD.*QA:'
ver_req "$VP2/requirements/REQ-102.md" "aprobado (R-045)" "n/a" "estandar"
ver_check "CA-03 parentesis SIN fecha -> deny" deny "$VP2" "$(ver_cierra "$VP2/requirements/REQ-102.md")" 'AAAA-MM-DD'
ver_req "$VP2/requirements/REQ-103.md" "aprobado (R-045, 2026-09-01)" "n/a" "estandar"
ver_check "CA-04 fecha en cualquier posicion del parentesis -> allow" allow "$VP2" "$(ver_cierra "$VP2/requirements/REQ-103.md")"
# CA-05: solo AAAA-MM-DD con mes 01-12 y dia 01-31. Lo que no case NO es "fecha rara":
# es "sin fecha", y sin fecha no se cierra. Aceptar `2026-13-05` la volveria
# incomparable contra la del codigo, que es justo para lo que se lee.
for f in '01/09/2026' '2026-9-1' '20260901' '2026-13-05'; do
  ver_req "$VP2/requirements/REQ-104.md" "aprobado ($f)" "n/a" "estandar"
  ver_check "CA-05 '$f' no es una fecha -> deny" deny "$VP2" "$(ver_cierra "$VP2/requirements/REQ-104.md")" 'AAAA-MM-DD'
done
ver_req "$VP2/requirements/REQ-105.md" "aprobado (2026-09-01)" "aprobado" "critico"
ver_check "CA-07 critico: la fecha se exige tambien a Seguridad -> deny" deny "$VP2" \
  "$(ver_cierra "$VP2/requirements/REQ-105.md")" 'Seguridad:'
ver_req "$VP2/requirements/REQ-106.md" "aprobado" "n/a" "ligero"
ver_check "CA-08 ligero no pide veredictos ni sus fechas -> allow" allow "$VP2" "$(ver_cierra "$VP2/requirements/REQ-106.md")"
ver_req "$VP2/requirements/REQ-107.md" "pendiente" "n/a" "estandar"
ver_check "CA-09 QA pendiente: deniega el VEREDICTO, no la fecha" deny "$VP2" \
  "$(ver_cierra "$VP2/requirements/REQ-107.md")" 'veredicto de QA'
rm -rf "$VP2"

# --- Bloque B: caducidad frente al codigo ---
ver_proj false true 2026-08-30; VP3="$VP"
ver_req "$VP3/requirements/REQ-110.md" "aprobado (2026-09-01)" "n/a" "estandar"
ver_check "CA-10 veredicto POSTERIOR al commit, arbol limpio -> allow" allow "$VP3" "$(ver_cierra "$VP3/requirements/REQ-110.md")"
ver_req "$VP3/requirements/REQ-111.md" "aprobado (2026-08-29)" "n/a" "estandar"
ver_check "CA-11 veredicto ANTERIOR al commit -> deny con las dos fechas y el sha" deny "$VP3" \
  "$(ver_cierra "$VP3/requirements/REQ-111.md")" '2026-08-29.*2026-08-30'
# CA-12: `%cs` tiene resolucion de DIA, asi que el empate NO caduca. Es una asimetria
# declarada, no un descuido: la alternativa seria caducar por el reloj de la maquina.
ver_req "$VP3/requirements/REQ-112.md" "aprobado (2026-08-30)" "n/a" "estandar"
ver_check "CA-12 mismo dia que el commit -> allow (el empate no caduca)" allow "$VP3" "$(ver_cierra "$VP3/requirements/REQ-112.md")"
# CA-19: sin fecha no hay nada que comparar, aunque `exigir_fecha` este apagado.
ver_req "$VP3/requirements/REQ-113.md" "aprobado" "n/a" "estandar"
ver_check "CA-19 caducan sin exigir_fecha: 'aprobado' sin fecha -> deny" deny "$VP3" \
  "$(ver_cierra "$VP3/requirements/REQ-113.md")" 'no lleva fecha'
ver_req "$VP3/requirements/REQ-114.md" "aprobado (2026-09-01)" "aprobado (2026-08-29)" "critico"
ver_check "CA-21 la caducidad alcanza a Seguridad, no solo a QA -> deny" deny "$VP3" \
  "$(ver_cierra "$VP3/requirements/REQ-114.md")" 'Seguridad:'
# CA-14: solo cuenta el codigo DECLARADO. Un README sucio no caduca ningun veredicto.
printf 'ruido\n' > "$VP3/README.md"
ver_check "CA-14 sucio FUERA de los globs -> allow" allow "$VP3" "$(ver_cierra "$VP3/requirements/REQ-110.md")"
# CA-13: sucio DENTRO de los globs -> deny, y el motivo nombra el archivo.
printf 'cambio sin comitear\n' >> "$VP3/src/app.ts"
ver_check "CA-13 cambio sin comitear en el codigo -> deny nombrando el archivo" deny "$VP3" \
  "$(ver_cierra "$VP3/requirements/REQ-110.md")" 'src/app.ts'
rm -rf "$VP3"

# CA-15: una puerta que no puede medir no deja pasar.
ver_proj false true; VP4="$VP"
ver_req "$VP4/requirements/REQ-120.md" "aprobado (2026-09-01)" "n/a" "estandar"
ver_check "CA-15 sin repositorio git -> deny (no puedo medir)" deny "$VP4" \
  "$(ver_cierra "$VP4/requirements/REQ-120.md")" 'no puede medir|no pudo responder'
rm -rf "$VP4"

# CA-16: un git anterior a `%cs` devuelve el literal. Tomarlo por fecha seria dejar pasar
# por no entender la salida, que es la peor forma de permitir.
ver_proj false true 2026-08-30; VP5="$VP"
ver_req "$VP5/requirements/REQ-121.md" "aprobado (2026-09-01)" "n/a" "estandar"
FAKEBIN="$(mktemp -d)"
printf '#!/bin/sh\necho "%%cs abcdef1"\n' > "$FAKEBIN/git"; chmod +x "$FAKEBIN/git"
VER_JSON="$(ver_cierra "$VP5/requirements/REQ-121.md")"
if [ -n "$FILTRO" ] && ! printf '%s' "CA-16" | grep -qi -- "$FILTRO"; then :; else
  json_no_vacio "CA-16 git que no entiende %cs" "$VER_JSON" || FAIL=$((FAIL+1))
  VER_OUT="$(: > "$ERRLOG"; printf '%s' "$VER_JSON" | PATH="$FAKEBIN:$PATH" CLAUDE_PROJECT_DIR="$VP5" "$HOOKS_DIR/guard-completado.sh" 2>"$ERRLOG")"
  if printf '%s' "$VER_OUT" | grep -Eq '"permissionDecision": *"deny"'; then
    echo "  PASS  CA-16 git que no entiende %cs -> deny (no puedo medir)"; PASS=$((PASS+1))
  else
    echo "  FAIL  CA-16 git que no entiende %cs: permitio por no entender la salida"; diag; FAIL=$((FAIL+1))
  fi
fi
rm -rf "$FAKEBIN" "$VP5"

# CA-17: sin globs la consulta mediria el repositorio entero, que es OTRA pregunta.
ver_proj false true 2026-08-30 '[]'; VP6="$VP"
ver_req "$VP6/requirements/REQ-122.md" "aprobado (2026-09-01)" "n/a" "estandar"
ver_check "CA-17 caducan con codigo_app.globs vacio -> deny" deny "$VP6" \
  "$(ver_cierra "$VP6/requirements/REQ-122.md")" 'globs'
rm -rf "$VP6"

# CA-18: repositorio con commits pero NINGUNO que toque los globs, y el arbol limpio ahi.
# No hay codigo posterior al veredicto porque no hay codigo comiteado, y se pudo medir.
ver_proj false true; VP7="$VP"
rmdir "$VP7/src" 2>/dev/null
git -C "$VP7" init -q >/dev/null 2>&1
git -C "$VP7" config user.email banco@arnes.local >/dev/null 2>&1
git -C "$VP7" config user.name banco >/dev/null 2>&1
printf 'documento\n' > "$VP7/LEEME.md"
git -C "$VP7" add LEEME.md >/dev/null 2>&1
git -C "$VP7" commit -qm doc >/dev/null 2>&1
ver_req "$VP7/requirements/REQ-123.md" "aprobado (2026-09-01)" "n/a" "estandar"
ver_check "CA-18 ningun commit toca los globs y el arbol esta limpio -> allow" allow "$VP7" \
  "$(ver_cierra "$VP7/requirements/REQ-123.md")"
rm -rf "$VP7"

# CA-20: con las dos claves ausentes no se mide NADA, ni con el codigo cambiado despues
# ni con el arbol sucio. El control que dice que esto es opt-in de verdad.
ver_proj false false 2026-09-30; VP8="$VP"
printf 'sucio\n' >> "$VP8/src/app.ts"
ver_req "$VP8/requirements/REQ-124.md" "aprobado (2026-08-01)" "n/a" "estandar"
ver_check "CA-20 sin las claves: codigo posterior y arbol sucio -> allow" allow "$VP8" \
  "$(ver_cierra "$VP8/requirements/REQ-124.md")"
rm -rf "$VP8"
