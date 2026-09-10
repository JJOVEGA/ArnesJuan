# Sección 40 (4 de 4) del banco — 40-ausencia-que-abre-4-el-veredicto-de-seguridad
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-024 `CA-02` · SEC-082 / QA-024-12. «EL UNICO SITIO QUE DECIDE» ERA FALSO PARA UN CAMPO.
# La parte 1 mide `CA-02` por mutación sobre dos claves —una que `deniega` (`QA`) y una que
# `gobierna` (`Rigor`)— y las dos se mueven. `Seguridad` no estaba entre ellas, y ahí vivía el
# defecto: su entrada en `ARNES_AUSENCIA` era CÓDIGO MUERTO, porque el `[ "$seg" != "aprobado" ]`
# de la puerta resolvía la ausencia por su cuenta. Medido por el auditor y reproducido aquí:
# mutar esa entrada a `gobierna:aprobado` NO movía el veredicto, y la MISMA mutación movía 4 de 4
# en los otros campos.
#
# POR QUÉ ES UNA PARTE NUEVA Y NO TRES LÍNEAS EN LA PARTE 1: la parte 1 está en 387 líneas de un
# techo de 400 (`REQ-014 CA-18`) y la parte 2 en 400 exactas. `CA-18` manda partir, no alargar.
#
# LO QUE ESTA SECCIÓN MIDE Y LO QUE NO, dicho antes de los casos porque es la mitad del valor:
#   · SÍ: que la entrada esté VIVA —mutarla mueve el veredicto— y que el motivo NOMBRE el campo.
#   · SÍ: que la CONDUCTA no se haya movido al hacerlo. La conducta de hoy es CONDICIONAL AL
#     RIGOR (con la llave encendida, `estandar` sin `Seguridad:` cierra y `critico` no, también
#     cuando el `critico` viene del SUELO de sensibilidad), está acreditada, y lo que era falso
#     era la DECLARACIÓN incondicional, no la conducta. Un arreglo de texto que moviera la
#     conducta sería el defecto contrario, así que los dos lados van en la misma corrida.
#   · NO: la clase derivada de `CA-01` ni el radio de migración de `CA-05` (partes 1 y 2).
#
# LA MUTACIÓN SE VERIFICA POR SU EFECTO EN LA TABLA DERIVADA, NUNCA POR EL `rc` DEL `sed`, y no
# es celo: al auditor tres de cinco mutaciones no le aplicaron por un choque de delimitador y
# creyó el resultado. Aquí el delimitador es `#` —`n/a` y `gobierna:` no lo llevan—, el programa
# va en comillas SIMPLES (el fuente dice `$ARNES_CLAVE_SEG`, no la clave, así que una comilla
# doble lo expandiría y la mutación no casaría nunca), y después se CARGA la biblioteca mutada y
# se pregunta la dirección que declara. Si no tomó efecto, el caso FALLA nombrándolo: una
# mutación que no aplica devuelve el veredicto de la versión sin mutar, o sea VERDE por no medir.
CASOS_ESPERADOS_SECCION=11
PISO_AUTONOMO_SECCION=106  # 35 preámbulo con sus dos declaraciones y el titular (líneas 1-35) + 44 maquinaria compartida duplicada (`eva40d`, `chk40d` y el proyecto de prueba, que la parte 1 define como `eva24`/`chk24a`; líneas 37-80) + 27 bloque indivisible mayor (las cabeceras, `dir40d` y las dos copias mutadas, líneas 81-107: ningún caso de esta parte puede prescindir de ellos) · REQ-014 CA-18
seccion_nueva "--- 40/4 · la ausencia que abre: el veredicto de seguridad (REQ-024 CA-02, SEC-082) ---"

# ---------- MAQUINARIA COMPARTIDA, DUPLICADA de la parte 1 ----------
# `eva40d` es `eva24` con el mismo motivo: cada sección corre en su propio subshell, ninguna hace
# `source` de otra, y en `secciones/` no cabe un archivo auxiliar. Residual `AN-021-01`.
P40D="$RAIZ/p40d-$BASHPID"
mkdir -p "$P40D/.arnes" "$P40D/requirements" "$P40D/docs"
printf '# ESTADO\n' > "$P40D/docs/ESTADO.md"
printf '## Pendientes\n\n## Resueltas\n' > "$P40D/PENDING_APPROVAL.md"
J40D="$(CLAUDE_PROJECT_DIR="$P40D" jq -n --arg fp "$P40D/requirements/REQ-941.md" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"completado"}}')"
# LA EDICIÓN ES LA TRANSICIÓN A `completado` Y NO ESCRIBE `Seguridad:`, y eso hay que decirlo
# aquí: si lo escribiera, la guarda del ORDEN del ciclo (SEC-083, `13-orden-del-ciclo.sh`) sería
# la que decidiera y esta sección estaría midiendo otra puerta con el mismo nombre.
eva40d() {   # <hooks-dir> <exige:true|false> <cabecera> [clave] -> DENY[-nombra|-calla]|ALLOW
  local o
  printf '%s\n' "$MANIFIESTO_BASE" | jq ".campos.ausencia_exige = $2" > "$P40D/.arnes/config.json"
  printf '# REQ-941\nEstado: en-revisión\n%s\n' "$3" > "$P40D/requirements/REQ-941.md"
  o="$(printf '%s' "$J40D" | CLAUDE_PROJECT_DIR="$P40D" "$1/guard-completado.sh" 2>/dev/null)"
  case "$o" in
    *'"permissionDecision":"deny"'*|*'"permissionDecision": "deny"'*)
      printf 'DENY'
      if [ -n "${4:-}" ]; then
        case "$o" in
          *"NO declara el campo '$4:'"*) printf -- '-nombra' ;;
          *) printf -- '-calla' ;;
        esac
      fi ;;
    *) printf 'ALLOW' ;;
  esac
}
chk40d() {   # <nombre> <esperado> <obtenido>
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=<$2> obtenido=<$3>"; diag; FAIL=$((FAIL+1)); fi
}
# La dirección que una versión de la biblioteca DECLARA para una clave. La clave se pide por el
# nombre de su CONSTANTE y se resuelve dentro (`${!2}`): así el banco no escribe ni una clave
# literal y sigue al lector si el conjunto se muda (misma razón que en la parte 1).
dir40d() {   # <hooks-dir> <nombre de la constante ARNES_CLAVE_*> -> la dirección declarada
  bash -c '. "$1/lib.sh" >/dev/null 2>&1
    k="${!2}"; t="$ARNES_AUSENCIA"
    case "$t" in *"|$k|"*) r="${t#*"|$k|"}"; printf "%s" "${r%%|*}" ;; esac' _ "$1" "$2"
}

# ---------- LAS CABECERAS: la clave bajo prueba se OMITE, las demás deciden ----------
# `Seguridad` sólo muerde con el rigor efectivo en `critico`, así que su par necesita las dos
# formas de llegar ahí —declarado y por SUELO— y la de NO llegar (`estandar`), que es la que
# acredita que la conducta no se movió.
CAB_CRIT='QA: aprobado
Sensible a seguridad: no
Hallazgos abiertos: (ninguno)
Rigor: critico'
CAB_SUELO='QA: aprobado
Sensible a seguridad: sí
Hallazgos abiertos: (ninguno)'
CAB_EST='QA: aprobado
Sensible a seguridad: no
Hallazgos abiertos: (ninguno)
Rigor: estandar'
# El CONTROL POSITIVO de la técnica: un campo cuya entrada ya estaba viva antes de este arreglo.
CAB_SINQA='Seguridad: aprobado
Sensible a seguridad: no
Hallazgos abiertos: (ninguno)
Rigor: estandar'

# ---------- LAS DOS COPIAS MUTADAS, cada una con UNA entrada cambiada ----------
MUTS40="$RAIZ/mut40d-seg-$BASHPID"; MUTQ40="$RAIZ/mut40d-qa-$BASHPID"
mkdir -p "$MUTS40" "$MUTQ40"; cp -r "$HOOKS_DIR" "$MUTS40/hooks"; cp -r "$HOOKS_DIR" "$MUTQ40/hooks"
sed -i 's#$ARNES_CLAVE_SEG|deniega|#$ARNES_CLAVE_SEG|gobierna:aprobado|#' "$MUTS40/hooks/lib.sh"
sed -i 's#|$ARNES_CLAVE_QA|deniega|#|$ARNES_CLAVE_QA|gobierna:aprobado|#' "$MUTQ40/hooks/lib.sh"

# (1) y (2) EL INSTRUMENTO ANTES DEL RESULTADO: las dos mutaciones TOMARON EFECTO.
chk40d "REQ-024 CA-02 (SEC-082) la mutacion de la entrada de SEGURIDAD tomo efecto en la tabla derivada" \
  "gobierna:aprobado" "$(dir40d "$MUTS40/hooks" ARNES_CLAVE_SEG)"
chk40d "REQ-024 CA-02 (SEC-082) la mutacion de control (QA) tomo efecto en la tabla derivada" \
  "gobierna:aprobado" "$(dir40d "$MUTQ40/hooks" ARNES_CLAVE_QA)"

# (3) LA BASE DEL PAR: sin mutar, con la llave encendida, un `critico` que no declara el campo
# no cierra, y el motivo lo NOMBRA —`deniega` es media dirección; la otra mitad es nombrar—.
chk40d "REQ-024 CA-02 (SEC-082) sin mutar: critico sin el campo -> DENY y el motivo lo NOMBRA" \
  "DENY-nombra" "$(eva40d "$HOOKS_DIR" true "$CAB_CRIT" Seguridad)"
# (4) EL RESULTADO: mutada SÓLO esa entrada de la tabla, el veredicto SE MUEVE. Es la definición
# operativa de «la decisión está en un solo sitio»: si la puerta conservara la suya, no se movería
# —y hasta 1.34.0 no se movía, que es el hallazgo—.
chk40d "REQ-024 CA-02 (SEC-082) mutada SOLO la tabla, el veredicto de SEGURIDAD se mueve" \
  "ALLOW" "$(eva40d "$MUTS40/hooks" true "$CAB_CRIT")"
# (5) EL CONTROL POSITIVO de la técnica, en la MISMA corrida: la misma mutación sobre una entrada
# que ya estaba viva mueve igual. Sin él, un «se mueve» no distingue el arreglo de un instrumento
# que mueve cualquier cosa.
chk40d "REQ-024 CA-02 (SEC-082) control positivo: la MISMA mutacion mueve tambien el campo QA" \
  "DENY|ALLOW" "$(eva40d "$HOOKS_DIR" true "$CAB_SINQA")|$(eva40d "$MUTQ40/hooks" true "$CAB_SINQA")"

# ---------- LA CONDUCTA NO SE MOVIÓ: condicional al rigor, en los dos estados de la llave ----------
# (6) Con la llave ENCENDIDA, `estandar` sin el campo CIERRA. Es la celda que el auditor acreditó
# y la que un arreglo mal hecho —preguntar la ausencia fuera de la rama del rigor— habría movido.
chk40d "SEC-082 conducta: llave encendida, 'estandar' sin el campo de seguridad -> ALLOW" \
  "ALLOW" "$(eva40d "$HOOKS_DIR" true "$CAB_EST")"
# (7) Y el `critico` que viene del SUELO de sensibilidad deniega igual que el declarado: el suelo
# manda, y por eso el par de arriba no basta sin esta forma.
chk40d "SEC-082 conducta: llave encendida, 'critico' por SUELO sin el campo -> DENY" \
  "DENY" "$(eva40d "$HOOKS_DIR" true "$CAB_SUELO")"
# (8) y (9) Con la llave APAGADA —el estado de fábrica— las tres formas deciden lo que decidían
# antes de que existiera la tabla: el radio de migración de `CA-05` no se toca por enrutar esto.
chk40d "SEC-082 conducta: llave APAGADA, critico (declarado y por suelo) -> DENY" \
  "DENY|DENY" "$(eva40d "$HOOKS_DIR" false "$CAB_CRIT")|$(eva40d "$HOOKS_DIR" false "$CAB_SUELO")"
chk40d "SEC-082 conducta: llave APAGADA, 'estandar' sin el campo -> ALLOW" \
  "ALLOW" "$(eva40d "$HOOKS_DIR" false "$CAB_EST")"
# (10) Y con la llave apagada el `DENY` del `critico` NO nombra el campo, porque no hay exigencia
# de declararlo: lo que falta ahí es el VEREDICTO, y el motivo tiene que seguir hablando de eso.
chk40d "SEC-082 conducta: llave APAGADA, el motivo habla del VEREDICTO y no de la declaracion" \
  "DENY-calla" "$(eva40d "$HOOKS_DIR" false "$CAB_CRIT" Seguridad)"

# ---------- SEC-083 · EL MISMO SITIO ÚNICO EN EL ACTO DE FIRMAR (REQ-024 CA-12) ----------
# El acto es OTRO —escribir `Seguridad: aprobado`, en cualquier edición y sin transición al
# estado terminal—, y por eso está aquí y no basta con los casos de `13-orden-del-ciclo.sh`:
# aquéllos miden la CONDUCTA (la ausencia deniega, la edición ajena pasa) y éste mide DE DÓNDE
# SALE LA DECISIÓN. Una comprobación LOCAL del tipo «el campo está» daría la misma conducta y
# NO se movería al mutar la tabla; ésta se mueve, y es lo único que distingue las dos.
# Se mide con la llave APAGADA a propósito: la salida (b) de `CA-12` es independiente de ella,
# así que si el `ALLOW` mutado apareciera sólo con la llave encendida, quien decidiría sería la
# llave y no la tabla.
J40F="$(CLAUDE_PROJECT_DIR="$P40D" jq -n --arg fp "$P40D/requirements/REQ-941.md" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"x",new_string:"Seguridad: aprobado"}}')"
fir40d() {   # <hooks-dir> <exige:true|false> <cabecera> -> DENY|ALLOW  (acto: FIRMAR)
  local o
  printf '%s\n' "$MANIFIESTO_BASE" | jq ".campos.ausencia_exige = $2" > "$P40D/.arnes/config.json"
  printf '# REQ-941\nEstado: en-revisión\n%s\n' "$3" > "$P40D/requirements/REQ-941.md"
  o="$(printf '%s' "$J40F" | CLAUDE_PROJECT_DIR="$P40D" "$1/guard-completado.sh" 2>/dev/null)"
  case "$o" in
    *'"permissionDecision":"deny"'*|*'"permissionDecision": "deny"'*) printf DENY ;;
    *) printf ALLOW ;;
  esac
}
CAB_FIRMA='Sensible a seguridad: no
Seguridad: pendiente
Hallazgos abiertos: (ninguno)
Rigor: estandar'
chk40d "REQ-024 CA-12 (SEC-083) el acto de FIRMAR resuelve por la tabla: sin mutar DENIEGA y mutada la entrada de QA se mueve" \
  "DENY|ALLOW" "$(fir40d "$HOOKS_DIR" false "$CAB_FIRMA")|$(fir40d "$MUTQ40/hooks" false "$CAB_FIRMA")"
