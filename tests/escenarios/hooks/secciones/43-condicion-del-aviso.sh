# Sección 43 del banco — 43-condicion-del-aviso
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna
# otra sección (invariantes 3 y 4 del README del banco).
#
# QUÉ MIDE Y POR QUÉ NO ESTÁ EN LA 42. La 42 fija QUÉ FORMAS disparan cada aviso; aquí se
# fija QUÉ PROMETE su texto. Son dos propiedades distintas y la segunda estaba medida
# falsa: los dos avisos del lado `QA:` anunciaban la consecuencia sobre el CIERRE «asi
# este REQ no podra cerrarse», sin condición, y la condición existe (QA-024-35, `contrato`).
#
# LA PROPIEDAD, Y POR ESO LOS CASOS SON UNA MATRIZ Y NO CUATRO CADENAS: un aviso anuncia
# una consecuencia del cierre, y el cierre la resuelve por un EJE que NO es el mismo para
# las dos claves. Medido con el hook real, celda por celda:
#
#                                | ligero | estandar | critico | eje real
#   valor FUERA de vocabulario -------------------------------------------------------
#     QA:                        | ALLOW  |  DENY    |  DENY   | el RIGOR
#     Seguridad:                 | ALLOW  |  ALLOW   |  DENY   | el RIGOR
#   campo AUSENTE para el lector -----------------------------------------------------
#     QA:   `ausencia_exige` off | ALLOW  |  ALLOW   |  ALLOW  | la LLAVE
#     QA:   `ausencia_exige` on  |  DENY  |  DENY    |  DENY   | `campos.ausencia_exige`
#     Seguridad:  los DOS estados| ALLOW  |  ALLOW   |  DENY   | el RIGOR
#
# De ahí los dos bordes de la matriz: los DOS estados de la llave por los TRES niveles de
# rigor, para las DOS claves. Los seis casos de cada bloque `QA:` fallan contra el código
# anterior (`ARNES_HOOKS_DIR` apuntando a los hooks de `929043d`); los doce de `Seguridad:`
# son el CONTROL de la asimetría —su texto ya llevaba su condición y no se tocó—, y los
# veinticuatro del bloque E son el control de que este arreglo de TEXTO no movió ninguna
# decisión ni ningún código de salida.
CASOS_ESPERADOS_SECCION=52
PISO_AUTONOMO_SECCION=92  # 33 preámbulo (líneas 1-33, la declaración de casos y el `seccion_nueva` incluidos) + 19 maquinaria propia (el comentario y `check_rc`, líneas 35-53: ningún ayudante compartido del corredor juzga el código de salida) + 40 bloque indivisible mayor (el bloque E, líneas 119-158: los cuatro cierres de la matriz y su control positivo, que no se leen sueltos) · REQ-014 CA-18 · REGLA para re-derivar los tres términos sin preguntar: «preámbulo» son las líneas previas a la maquinaria; un «bloque» es un grupo de líneas consecutivas sin blanca en medio, y el mayor es el E; «maquinaria» es la que esta sección define porque el corredor no la tiene, no una copia de otra parte

seccion_nueva "Cada aviso lleva SU condicion, y no es la misma (QA-024-35):"

# --- MAQUINARIA PROPIA, la única de esta sección, y va con su motivo ---------------
# `check` juzga la DECISIÓN y no el código de salida, y el criterio de esta vuelta pide los
# DOS en la misma celda: el arreglo mete una sustitución de comando DENTRO del texto de un
# aviso, y eso es justo lo que podría mover un `rc` o ensuciar la salida sin cambiar ni un
# veredicto. Ningún ayudante compartido juzga el `rc`, así que éste es propio (README del
# banco, «Los ayudantes compartidos»: se define porque NO lo hay, no por comodidad). Lleva
# la guarda de la invariante 1 por `json_no_vacio`, como todo el que dicta PASS/FAIL.
check_rc() {   # <nombre> <deny|allow> <rc esperado> <json>
  local nombre="$1" esperado="$2" rc_esp="$3" json="$4" out rc got=allow
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  json_no_vacio "$nombre" "$json" || { FAIL=$((FAIL+1)); return 0; }
  out="$(corre guard-completado.sh "$json")"; rc=$?
  printf '%s' "$out" | grep -Eq '"permissionDecision": *"deny"' && got=deny
  if [ "$got" = "$esperado" ] && [ "$rc" = "$rc_esp" ]; then
    echo "  PASS  $nombre  ($got, rc=$rc)"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nombre  esperado=$esperado/rc=$rc_esp  got=$got/rc=$rc"; diag; FAIL=$((FAIL+1))
  fi
}

# --- A. `QA:` AUSENTE PARA EL LECTOR: el eje es la LLAVE, y el aviso lo dice -------
# `qa: aprobado` en minúscula deja el campo sin declarar. Lo que el cierre haga con esa
# ausencia lo decide `campos.ausencia_exige`, NO el rigor: apagada —como nace, y como está
# en casi todo proyecto instalado— el REQ CIERRA, y el aviso anterior prometía lo contrario
# en la dirección que TRANQUILIZA (familia de SEC-079). El aviso resuelve además el estado
# REAL de la llave: declarar los dos estados no sirve si quien lee no sabe en cuál está.
setcfg '.campos.ausencia_exige = false'
for r in ligero estandar critico; do
  mkreq_r "REQ-960" "no" "" "aprobado" "$r"
  check_aviso "43/A QA-024-35 llave APAGADA y rigor $r: el aviso dice que SI cerrara" si \
    'APAGADA, asi que el REQ SI podra cerrarse sin veredicto de QA' guard-completado.sh \
    "$(emite_edit "$PROJ/requirements/REQ-960.md" "" "" 'qa: aprobado')"
done
setcfg '.campos.ausencia_exige = true'
for r in ligero estandar critico; do
  mkreq_r "REQ-961" "no" "" "aprobado" "$r"
  check_aviso "43/A QA-024-35 llave ENCENDIDA y rigor $r: el aviso dice que NO cerrara" si \
    'ENCENDIDA, asi que el REQ no podra cerrarse' guard-completado.sh \
    "$(emite_edit "$PROJ/requirements/REQ-961.md" "" "" 'qa: aprobado')"
done

# --- B. `QA:` CON VALOR FUERA DE VOCABULARIO: el eje es el RIGOR -------------------
# Aquí el campo SÍ está declarado, así que la llave no interviene en ningún estado —y por
# eso los seis casos exigen el MISMO texto—. Lo que decide es el rigor: `ligero` no pide
# veredicto de QA y el valor no se juzga, así que el REQ cierra con un valor que no es
# ninguno de los tres. El aviso prometía la denegación sin esa salvedad.
for llave in false true; do
  setcfg ".campos.ausencia_exige = $llave"
  for r in ligero estandar critico; do
    mkreq_r "REQ-962" "no" "pendiente" "aprobado" "$r"
    check_aviso "43/B QA-024-35 valor fuera de vocabulario, llave $llave y rigor $r: el aviso nombra 'ligero'" si \
      "Si el rigor efectivo NO es .ligero." guard-completado.sh \
      "$(emite_edit "$PROJ/requirements/REQ-962.md" "" "" 'QA: aprobadisimo')"
  done
done

# --- C y D. LOS DOS DE `Seguridad:` SON EL CONTROL DE LA ASIMETRÍA ----------------
# No se tocaron, y estos doce casos son la razón por la que no había que tocarlos: su
# condición es el rigor, su texto ya la llevaba, y la llave NO mueve su veredicto en
# ninguno de los tres niveles. Sin ellos, «los ejes son distintos» sería una afirmación
# del informe y no una propiedad medida — y copiar el texto de una clave a la otra habría
# pasado por arreglo.
for llave in false true; do
  setcfg ".campos.ausencia_exige = $llave"
  for r in ligero estandar critico; do
    mkreq_r "REQ-963" "no" "aprobado" "pendiente" "$r"
    check_aviso "43/C ausencia de Seguridad:, llave $llave y rigor $r: la condicion sigue siendo el rigor" si \
      'si el rigor efectivo es critico, el REQ no podra cerrarse por ausencia de veredicto de seguridad' \
      guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-963.md" "" "" 'seguridad: aprobado')"
    check_aviso "43/D Seguridad: fuera de vocabulario, llave $llave y rigor $r: la condicion sigue siendo el rigor" si \
      'Si el rigor efectivo es critico, asi este REQ no podra cerrarse' \
      guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-963.md" "" "" 'Seguridad: aprobado-ish')"
  done
done

# --- DISCRIMINANTE. Sin él, un aviso que se disparara SIEMPRE pasaría los veinticuatro
# de arriba: una clave limpia con un valor del vocabulario no tiene nada que avisar.
for llave in false true; do
  setcfg ".campos.ausencia_exige = $llave"
  mkreq_r "REQ-964" "no" "pendiente" "pendiente" "estandar"
  check_aviso "43/discriminante llave $llave: clave limpia y valor valido -> NO avisa" no \
    '' guard-completado.sh "$(emite_edit "$PROJ/requirements/REQ-964.md" "" "" 'QA: aprobado')"
done

# --- E. NO-REGRESIÓN: las mismas celdas deciden igual y salen con el mismo `rc` ----
# Un arreglo de TEXTO que moviera una decisión dejaría de ser un arreglo de texto, y el
# criterio lo pide explícito. Son las cuatro celdas que los avisos de arriba anuncian,
# medidas en los dos estados de la llave y en los tres rigores, con su control positivo.
# Los valores esperados son los medidos contra `929043d`, ANTES de tocar el aviso.
for llave in false true; do
  setcfg ".campos.ausencia_exige = $llave"
  for r in ligero estandar critico; do
    # (1) `QA:` ausente para el lector: lo decide la LLAVE, en los tres rigores.
    [ "$llave" = true ] && esp=deny || esp=allow
    mkreq_r "REQ-970" "no" "" "aprobado" "$r"
    printf 'Hallazgos abiertos: (ninguno)\nqa: aprobado\n' >> "$PROJ/requirements/REQ-970.md"
    check_rc "43/E cierre sin QA: legible, llave $llave y rigor $r -> $esp" "$esp" 0 \
      "$(emite_edit_real "$PROJ/requirements/REQ-970.md" 'Estado: en-revisión' 'Estado: completado')"
    # (2) `QA:` con valor fuera de vocabulario: lo decide el RIGOR, en los dos estados.
    [ "$r" = ligero ] && esp=allow || esp=deny
    mkreq_r "REQ-971" "no" "aprobadisimo" "aprobado" "$r"
    printf 'Hallazgos abiertos: (ninguno)\n' >> "$PROJ/requirements/REQ-971.md"
    check_rc "43/E cierre con QA fuera de vocabulario, llave $llave y rigor $r -> $esp" "$esp" 0 \
      "$(emite_edit_real "$PROJ/requirements/REQ-971.md" 'Estado: en-revisión' 'Estado: completado')"
    # (3) `Seguridad:` ausente para el lector: el RIGOR, y la llave NO lo mueve.
    [ "$r" = critico ] && esp=deny || esp=allow
    mkreq_r "REQ-972" "no" "aprobado" "" "$r"
    printf 'Hallazgos abiertos: (ninguno)\nseguridad: aprobado\n' >> "$PROJ/requirements/REQ-972.md"
    check_rc "43/E cierre sin Seguridad: legible, llave $llave y rigor $r -> $esp" "$esp" 0 \
      "$(emite_edit_real "$PROJ/requirements/REQ-972.md" 'Estado: en-revisión' 'Estado: completado')"
    # (4) `Seguridad:` con valor fuera de vocabulario: el RIGOR, y la llave tampoco.
    [ "$r" = critico ] && esp=deny || esp=allow
    mkreq_r "REQ-973" "no" "aprobado" "aprobado-ish" "$r"
    printf 'Hallazgos abiertos: (ninguno)\n' >> "$PROJ/requirements/REQ-973.md"
    check_rc "43/E cierre con Seguridad fuera de vocabulario, llave $llave y rigor $r -> $esp" "$esp" 0 \
      "$(emite_edit_real "$PROJ/requirements/REQ-973.md" 'Estado: en-revisión' 'Estado: completado')"
  done
  # CONTROL POSITIVO: sin él, los `deny` de arriba también los daría una puerta que
  # denegara todo cierre de estos fixtures.
  mkreq_r "REQ-974" "no" "aprobado" "aprobado" "critico"
  printf 'Hallazgos abiertos: (ninguno)\n' >> "$PROJ/requirements/REQ-974.md"
  check_rc "43/E control positivo, llave $llave: el mismo REQ con todo declarado SI cierra" allow 0 \
    "$(emite_edit_real "$PROJ/requirements/REQ-974.md" 'Estado: en-revisión' 'Estado: completado')"
done
