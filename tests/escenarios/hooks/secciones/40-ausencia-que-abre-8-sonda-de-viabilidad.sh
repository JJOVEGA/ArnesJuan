# Sección 40 (8 de 8) del banco — 40-ausencia-que-abre-8-sonda-de-viabilidad
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos (invariantes 3 y 4 del README del banco).
#
# ══ QUÉ ES ESTO, Y SOBRE TODO QUÉ NO ES ═════════════════════════════════════════════════
# Es una SONDA DE VIABILIDAD, temporal, de la fase 1 de la VUELTA 4 de `REQ-024 CA-07 (ii)`.
# MIDE Y PUBLICA; NO DECIDE. No dicta ningún veredicto, no toca `PASS`/`FAIL`/`SKIP`, declara
# CERO casos y por eso NO MUEVE EL CUADRE (`CASOS_ESPERADOS` sigue en 1094). Sus líneas llevan
# el prefijo `  VIAB  ` / `  VIAB-RESUMEN  `, que NO casa los tres patrones con los que el
# corredor cuenta casos (`run.sh`: `/^  PASS /`, `/^  FAIL /`, `/^  SKIP /` — dos espacios,
# palabra, espacio). Comprobado contra el texto de `run.sh`, no supuesto.
#
# ══ POR QUÉ VIAJA DENTRO DEL BANCO ══════════════════════════════════════════════════════
# La pregunta de la fase 1 es «¿la precisión que haría falta es viable EN EL RUNNER?», y está
# medido que este host y el runner NO PREDICEN LO MISMO (`docs/arnes/ci-1.34.0-no-discrimina/`):
# aquí WSL2 de 8–12 núcleos, allí 4 vCPU con `ARNES_JOBS=6`, o sea sobresuscrito. Y
# `.github/workflows/banco.yml` NO tiene `workflow_dispatch` —sólo `push` a `main` y
# `pull_request`— y `.github/` es gate humano (`AGENTS.md` §4), así que no se toca. Luego la
# ÚNICA vía de ejecutar algo en el runner es que viaje dentro de una corrida normal del PR.
#
# ══ POR QUÉ UN ARCHIVO APARTE Y NO DENTRO DE `40/7` ═════════════════════════════════════
# `40/7` es el artefacto que QA acaba de validar caso por caso; añadirle código obligaría a
# re-verificar sus cinco casos y su cuadre para medir algo que no es suyo. Esta sección SE
# BORRA CON UN `rm` cuando la fase 1 termine, sin tocar nada más y sin mover ningún número.
#
# ══ LAS CONDICIONES ESTÁN FIJADAS ANTES DE EJECUTAR, Y NO AQUÍ ══════════════════════════
# Los ajustes, las repeticiones, el orden, el tope de reloj y EL CRITERIO DE VIABILIDAD CON SU
# CIFRA están escritos —antes de ver un solo número— en
# `docs/arnes/req-024-ca-07-ii-reparacion/03-fase-1-viabilidad-en-el-runner.md`. Este archivo
# los EJECUTA; no los elige. Si los de allí y los de aquí discrepan, mandan los de allí.
CASOS_ESPERADOS_SECCION=0
PISO_AUTONOMO_SECCION=183  # 50 preámbulo (líneas 1-50: el encargo, lo que esta sonda NO hace, la comprobación de que no toca el cuadre y la vía de apagado) + 44 maquinaria compartida duplicada (líneas 51-94: la nula por dos copias independientes y el sujeto fiel con su fixture, que CUALQUIER partición de esta sonda tendría que duplicar íntegros, porque cada sección corre en su propio subshell y en `secciones/` no cabe un auxiliar — CA-04, CA-19, H-04) + 89 bloque indivisible mayor (líneas 95-183: el barrido intercalado con su tope de reloj y su resumen; partirlo por ajustes DESTRUIRÍA el intercalado, que es justo la propiedad que hace comparables entre sí los cuatro ajustes bajo una carga que baja con el tiempo) · REQ-014 CA-18 · el piso ES el archivo entero, como en `40/7` (329 de 329) y `37/2` (piso 551 de 552), y NO compra techo: 183 × 1,25 = 229 < 400, así que gobierna N y el archivo cabe con 217 líneas de holgura
seccion_nueva "--- 40/8 · SONDA DE VIABILIDAD del reloj de CA-07 (ii): mide y publica, NO dicta veredicto (TEMPORAL, vuelta 4 fase 1) ---"

# UNO A UNO, como en `40/7`: concatenado, un valor VACÍO desaparece entre los dígitos del vecino.
viab_num() { case "${1:-}" in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# Vía de apagado para vueltas LOCALES del banco entero, que es donde estos ~4 min estorban.
# Viene ENCENDIDA porque en el runner no hay forma de poner un env (ver preámbulo): apagarla
# por defecto sería escribir una sonda que nunca corre donde tiene que correr.
VIAB_CORRE=si
VIAB_NOMBRE="REQ-024 CA-07 (ii) sonda de viabilidad del reloj en el runner"
if [ -n "$FILTRO" ] && ! printf '%s' "$VIAB_NOMBRE" | grep -qi -- "$FILTRO"; then
  VIAB_CORRE=no
elif [ "${ARNES_SONDA_VIABILIDAD:-1}" != 1 ]; then
  VIAB_CORRE=no
  echo "  VIAB  apagada por ARNES_SONDA_VIABILIDAD=${ARNES_SONDA_VIABILIDAD:-1} (viene encendida; el runner no puede poner env)"
fi

if [ "$VIAB_CORRE" = si ]; then

# ---------- LA NULA: DOS COPIAS INDEPENDIENTES DEL MISMO ORIGEN ----------
# Razón verdadera = 1,000× POR CONSTRUCCIÓN, así que lo que se mida es ε, el ruido
# multiplicativo del instrumento, y nada más. DOS DIRECTORIOS DISTINTOS y no un brazo contra
# sí mismo: si el efecto fuera de ruta, de inodo o de caché de página, un brazo contra sí
# mismo NO lo vería. Misma construcción que las nulas `AA`/`BB` de la vuelta 3, para que las
# cifras sean comparables con ellas. Las dos copias salen del MISMO origen (no una de la
# otra), así que ninguna hereda un sesgo de la anterior.
# NO hace falta materializar `v1.33.0`: la nula no compara versiones, compara el instrumento
# consigo mismo — y así esta sección tampoco duplica `mat07` (el residual AN-021-01 no crece).
# EL ORIGEN ES `$HOOKS_DIR`, NO UNA RUTA DERIVADA DE `$SEC_DIR`: `$HOOKS_DIR` es EXACTAMENTE
# el árbol que el brazo «este» del caso real mide, y el corredor ya lo resuelve (respetando
# `ARNES_HOOKS_DIR`). Derivarlo del directorio de secciones haría que la sonda apuntara a otro
# sitio en cuanto alguien use `ARNES_SECCIONES_DIR` — medido al probarla.
VIAB_REPO="${HOOKS_DIR%/}/.."
VIAB_A="$RAIZ/viab-a-$BASHPID"; VIAB_B="$RAIZ/viab-b-$BASHPID"
VIAB_LISTA=no
if mkdir -p "$VIAB_A" "$VIAB_B" 2>/dev/null \
   && cp -a "$HOOKS_DIR" "$VIAB_A/hooks" 2>/dev/null && cp -a "$VIAB_REPO/tools" "$VIAB_A/tools" 2>/dev/null \
   && cp -a "$HOOKS_DIR" "$VIAB_B/hooks" 2>/dev/null && cp -a "$VIAB_REPO/tools" "$VIAB_B/tools" 2>/dev/null \
   && [ -x "$VIAB_A/hooks/guard-completado.sh" ] && [ -x "$VIAB_B/hooks/guard-completado.sh" ]; then
  VIAB_LISTA=si
fi

# ---------- EL SUJETO: EL FIEL, el mismo que mide el caso real ----------
# Copiado de `40/7:97-110` a propósito y con su motivo: dentro del banco `seccion_nueva`
# EXPORTA `CLAUDE_PROJECT_DIR` al proyecto VACÍO de la sección, y `hooks/lib.sh` lo prioriza
# sobre el `cwd` del JSON — por no verlo, las fases 1 y 2 de la vuelta 3 midieron un sujeto
# 2,8× más pesado que el real (adenda de `00-metodo-y-plan.md`). Medir OTRO sujeto haría la
# dispersión no transferible, que es justo lo que esta sonda existe para no repetir.
VIAB_P="$RAIZ/viab-p-$BASHPID"
mkdir -p "$VIAB_P/.arnes" "$VIAB_P/requirements" "$VIAB_P/docs"
printf '%s\n' "$MANIFIESTO_BASE" > "$VIAB_P/.arnes/config.json"
printf '# ESTADO\n' > "$VIAB_P/docs/ESTADO.md"
printf '## Pendientes\n\n## Resueltas\n' > "$VIAB_P/PENDING_APPROVAL.md"
cp "$VIAB_REPO"/requirements/REQ-*.md "$VIAB_P/requirements/" 2>/dev/null || :
VIAB_ENT="$RAIZ/viab-ent-$BASHPID.json"
CLAUDE_PROJECT_DIR="$VIAB_P" emite_write "$VIAB_P/requirements/REQ-951.md" '# REQ-951
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Hallazgos abiertos: (ninguno)
Rigor: critico' > "$VIAB_ENT"

# ---------- EL BARRIDO: CUATRO AJUSTES, INTERCALADOS, CON TOPE DE RELOJ ----------
# `k` es la palanca del SUELO de 50 ms (QA-024-23: en reposo la serie del brazo heredado cae
# a 46-48 ms con k=4 y la sonda dice `estado=suelo` sin medir nada) y `r` la de la DISPERSIÓN
# (el estadístico es el mínimo sobre r series). V0 conserva k=4 PARA OBSERVAR si el suelo
# dispara en el runner, que es lo que nadie ha medido allí.
VIAB_ID=(V0 V1 V2 V3); VIAB_K=(4 8 8 8); VIAB_R=(6 15 30 60); VIAB_M=(12 10 8 4)
VIAB_RONDAS=12
VIAB_TOPE_US=420000000   # 7 min. `timeout-minutes: 20` y el banco tarda ~2 min: deja 11 de
                         # margen. Un experimento que tumba la puerta no devuelve ningún dato.
VIAB_RAZONES=('' '' '' ''); VIAB_NOOK=(0 0 0 0); VIAB_US=(0 0 0 0); VIAB_N=(0 0 0 0)
VIAB_CARGA=desconocida; [ -r /proc/loadavg ] && read -r VIAB_CARGA _ < /proc/loadavg
VIAB_NUCLEOS=0
if [ -r /proc/cpuinfo ]; then
  while IFS= read -r vi_l; do case "$vi_l" in processor*) VIAB_NUCLEOS=$((VIAB_NUCLEOS + 1)) ;; esac; done < /proc/cpuinfo
fi
echo "  VIAB-CONTEXTO  nucleos=$VIAB_NUCLEOS jobs=${ARNES_JOBS:-6} carga_al_empezar=$VIAB_CARGA nula_lista=$VIAB_LISTA corrida=${ARNES_CORRIDA:-desconocida} criterio=docs/arnes/req-024-ca-07-ii-reparacion/03-fase-1-viabilidad-en-el-runner.md"

VIAB_AGOTADO=no
if [ "$VIAB_LISTA" != si ]; then
  echo "  VIAB  NO SE PUDO MEDIR: no se montaron las dos copias de la nula bajo $RAIZ; sin nula no hay ε y no hay respuesta"
else
  VIAB_T0=${EPOCHREALTIME/./}
  # INTERCALADO Y NO POR BLOQUES: en el banco la contención BAJA con el tiempo (las otras 64
  # secciones van terminando), así que correr todo V0 primero y todo V3 después mediría
  # ajustes distintos bajo CARGAS distintas y confundiría las dos cosas. El reparto uniforme
  # `⌊n·M/12⌋ > ⌊(n-1)·M/12⌋` esparce las M repeticiones de cada ajuste por las 12 rondas.
  for ((vi_ronda = 1; vi_ronda <= VIAB_RONDAS; vi_ronda++)); do
    for ((vi_s = 0; vi_s < 4; vi_s++)); do
      vi_m=${VIAB_M[vi_s]}
      [ $(( vi_ronda * vi_m / VIAB_RONDAS )) -gt $(( (vi_ronda - 1) * vi_m / VIAB_RONDAS )) ] || continue
      if [ $(( ${EPOCHREALTIME/./} - VIAB_T0 )) -ge "$VIAB_TOPE_US" ]; then VIAB_AGOTADO=si; break 2; fi
      vi_k=${VIAB_K[vi_s]}; vi_r=${VIAB_R[vi_s]}; vi_id=${VIAB_ID[vi_s]}
      VIAB_N[vi_s]=$(( VIAB_N[vi_s] + 1 ))
      vi_reg="$("$UTIL_DIR/sonda-reloj.sh" --k "$vi_k" --r "$vi_r" --etiqueta "viab-$vi_id-n${VIAB_N[vi_s]}" \
        --sujeto-a "bash '$VIAB_A/hooks/guard-completado.sh' < '$VIAB_ENT' >/dev/null 2>&1" \
        --sujeto-b "bash '$VIAB_B/hooks/guard-completado.sh' < '$VIAB_ENT' >/dev/null 2>&1" 2>/dev/null)"
      vi_raz=-
      if sonda_lee "$vi_reg" && [ "${SONDA[estado]:-}" = ok ]; then
        vi_a="${SONDA[min_a]:-}"; vi_b="${SONDA[min_b]:-}"
        if viab_num "$vi_a" && viab_num "$vi_b" && [ "$vi_b" -gt 0 ]; then
          vi_raz=$(( vi_a * 1000 / vi_b ))
          VIAB_RAZONES[vi_s]="${VIAB_RAZONES[vi_s]} $vi_raz"
        fi
      fi
      # Una repetición sin razón NO se descarta en silencio: se cuenta, porque el criterio
      # real convierte UNA SOLA en `SKIP` del conjunto (`40/7:150-153`).
      [ "$vi_raz" != - ] || VIAB_NOOK[vi_s]=$(( VIAB_NOOK[vi_s] + 1 ))
      viab_num "${SONDA[us]:-}" && VIAB_US[vi_s]=$(( VIAB_US[vi_s] + ${SONDA[us]} ))
      # EL REGISTRO ÍNTEGRO, a propósito: trae `estado`, `motivo`, `carga`, `jobs`, `us`, el
      # suelo y los min/min2 de los dos brazos, así que cualquiera re-deriva TODAS las cifras
      # del informe sin volver a correr nada (`AGENTS.md` §14.B.7).
      echo "  VIAB  $vi_id k=$vi_k r=$vi_r n=${VIAB_N[vi_s]} razon_milesimas=$vi_raz | $vi_reg"
    done
  done
  VIAB_TOTAL_US=$(( ${EPOCHREALTIME/./} - VIAB_T0 ))
  [ "$VIAB_AGOTADO" = no ] || echo "  VIAB  PRESUPUESTO AGOTADO a los $VIAB_TOPE_US µs: el barrido para aquí y publica lo medido; lo que falte NO se rellena ni se estima"

  # ---------- EL RESUMEN: estadísticos, NO veredictos ----------
  # C1 del criterio mira el MENOR mínimo de cualquier ventana de 4, que es exactamente el
  # mínimo global de la muestra — por eso `min_milesimas` ES el estadístico de C1 y se publica
  # como tal. El peor recorrido de ventana 4 va al lado porque es lo que separa un `FAIL`
  # unánime de un `SKIP`, y `us_por_invocacion` es el lado MEDIDO del presupuesto de coste.
  for ((vi_s = 0; vi_s < 4; vi_s++)); do
    vi_arr=(${VIAB_RAZONES[vi_s]})   # SIN comillas a propósito: una palabra por razón
    vi_min=''; vi_max=''; vi_peor=0
    for vi_x in "${vi_arr[@]}"; do
      { [ -n "$vi_min" ] && [ "$vi_x" -ge "$vi_min" ]; } || vi_min="$vi_x"
      { [ -n "$vi_max" ] && [ "$vi_x" -le "$vi_max" ]; } || vi_max="$vi_x"
    done
    for ((vi_j = 0; vi_j + 4 <= ${#vi_arr[@]}; vi_j++)); do
      vi_wmin=${vi_arr[vi_j]}; vi_wmax=${vi_arr[vi_j]}
      for ((vi_q = vi_j + 1; vi_q < vi_j + 4; vi_q++)); do
        [ "${vi_arr[vi_q]}" -ge "$vi_wmin" ] || vi_wmin=${vi_arr[vi_q]}
        [ "${vi_arr[vi_q]}" -le "$vi_wmax" ] || vi_wmax=${vi_arr[vi_q]}
      done
      vi_rec=$(( vi_wmax * 1000 / vi_wmin ))
      [ "$vi_rec" -le "$vi_peor" ] || vi_peor=$vi_rec
    done
    vi_inv=$(( 2 * VIAB_K[vi_s] * VIAB_R[vi_s] ))
    vi_cinv=0; [ "${VIAB_N[vi_s]}" -eq 0 ] || vi_cinv=$(( VIAB_US[vi_s] / (VIAB_N[vi_s] * vi_inv) ))
    echo "  VIAB-RESUMEN  ${VIAB_ID[vi_s]} k=${VIAB_K[vi_s]} r=${VIAB_R[vi_s]} pedidas=${VIAB_M[vi_s]} hechas=${VIAB_N[vi_s]} con_razon=${#vi_arr[@]} sin_razon=${VIAB_NOOK[vi_s]} min_milesimas=${vi_min:-n/a} max_milesimas=${vi_max:-n/a} peor_ventana4_milesimas=$vi_peor us_total=${VIAB_US[vi_s]} us_por_invocacion=$vi_cinv razones=[${VIAB_RAZONES[vi_s]# }]"
  done
  echo "  VIAB-RESUMEN  TOTAL us_de_pared_del_barrido=$VIAB_TOTAL_US presupuesto_agotado=$VIAB_AGOTADO carga_al_terminar=$( [ -r /proc/loadavg ] && { read -r vi_c _ < /proc/loadavg; printf '%s' "$vi_c"; } || printf 'desconocida' )"
fi

rm -rf "$VIAB_A" "$VIAB_B" "$VIAB_P" "$VIAB_ENT"
fi
:
