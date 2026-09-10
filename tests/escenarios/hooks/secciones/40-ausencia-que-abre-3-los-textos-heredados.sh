# Sección 40 (3 de 4) del banco — 40-ausencia-que-abre-3-los-textos-heredados
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-024 · SEC-047 (mitad 2), SEC-050, SEC-051. LOS TEXTOS QUE UN PROYECTO HEREDA: `CA-06` (la
# nota de migración dice qué pudo pasar y pregunta por ESTADO, no por vía) y el `_doc` de la
# llave `campos.ausencia_exige` en sus DOS sedes (`QA-024-01`, mitad de texto: el `_doc` prometía
# sin condición que todo REQ que omitiera uno de los cuatro campos dejaba de cerrar, y eso es
# medidamente falso para los dos que GOBIERNAN). La clase derivada y
# el sitio único están en la parte 1, la migración y el coste en la parte 2, y la conducta de la
# cola en `31-cola-una-sola-regla.sh`.
#
# ESTA PARTE ES SOBRE TEXTO, y por eso no usa `$HOOKS_DIR`: la ruta del documento se deriva de
# `$SEC_DIR`, igual que los casos de `REQ-016 CA-09/CA-10` en `36-…-4-el-informe-y-los-textos.sh`.
# Apuntar el banco a una instalación anterior (`ARNES_HOOKS_DIR`) tiene que seguir midiendo los
# hooks viejos contra los textos de HOY, que es justo lo que hay que poder distinguir.
#
# EL FAIL-BEFORE DE UN CASO SOBRE TEXTO NECESITA EL TEXTO DE ANTES, y `ARNES_HOOKS_DIR` no lo
# da. Por eso el documento se lee de `ARNES_SKILL_UPGRADE` si está puesta —la misma técnica y
# el mismo motivo que `ARNES_README_BANCO` en `autoprueba-corredor.sh`—:
#   ARNES_SKILL_UPGRADE=<skill de antes> bash tests/escenarios/hooks/run.sh secciones/40-*-3-*.sh
# tiene que FALLAR, y sin la variable tiene que pasar. Con la variable puesta la vuelta NO
# acredita el árbol: mide otro archivo, y lo dice el nombre de la variable.
#
# LOS CASOS SE MIDEN SOBRE EL APARTADO APLANADO, un registro por viñeta, y no línea a línea:
# una prueba de texto que casa un renglón concreto falla el día que alguien reajusta el ancho
# del párrafo sin cambiar ni una palabra, y ese rojo enseña a desactivar el control (H-11). Al
# aplanar se conserva el NÚMERO DE LÍNEA de arranque de cada viñeta, que es lo que permite medir
# el ORDEN que `CA-06 (ii)` contrata —la propiedad ANTES de cualquier comando— sin volver a
# recorrer el archivo.
CASOS_ESPERADOS_SECCION=26
PISO_AUTONOMO_SECCION=78  # 31 preámbulo con sus dos declaraciones y el titular (líneas 1-31) + 16 maquinaria compartida duplicada (`mira40c`, el mismo ayudante que `36-…-4-el-informe-y-los-textos.sh` define, duplicado porque en `secciones/` no cabe un auxiliar; líneas 61-76) + 31 bloque indivisible mayor (el aplanado del apartado, el sub-bloque anclado por su titular y `idx40`, líneas 33-59 y 77-80: ningún caso de CA-06 puede prescindir de ellos) · REQ-014 CA-18
seccion_nueva "--- 40/3 · la ausencia que abre: los textos que un proyecto hereda (REQ-024 CA-06) ---"

REPO40C="${SEC_DIR%/}/../../../.."
SK40="${ARNES_SKILL_UPGRADE:-$REPO40C/skills/arnes-upgrade/SKILL.md}"
AP40="$RAIZ/ap40-$BASHPID.txt"
# El apartado de migración de ESTA versión, aplanado: `<línea de arranque><TAB><viñeta entera>`.
# Empieza en su encabezado, termina en el siguiente encabezado o en la nota de cierre de la
# lista de migraciones, y cada viñeta a columna cero abre un registro nuevo.
if [ -f "$SK40" ]; then
  awk '
    !d && /^### Hacia 1\.34\.0[ \t]*$/ { d = 1; next }
    d && (/^## / || /^### / || /^\*\(/) { exit }
    d {
      if ($0 ~ /^- /) { if (rec != "") print n "\t" rec; n = FNR; rec = $0 }
      else { s = $0; sub(/^[ \t]+/, "", s); if (rec != "") rec = rec " " s }
    }
    END { if (rec != "") print n "\t" rec }
  ' "$SK40" > "$AP40"
else
  : > "$AP40"
fi
VIN40="$(awk 'END { print NR + 0 }' "$AP40")"
# El sub-bloque de ESTA vía dentro del apartado: desde la viñeta que la abre hasta el final.
# Se ancla por su titular y no por un número de viñeta: un bullet nuevo entre medias no puede
# mover el ancla, y si el titular desaparece el sub-bloque queda VACÍO y todo lo que dependa de
# él falla nombrándolo — que es la dirección correcta de la duda.
SUB40="$RAIZ/sub40-$BASHPID.txt"
awk -F'\t' 'index($2, "LA LÍNEA QUE NO ESTÁ") { d = 1 } d' "$AP40" > "$SUB40"
SUBN40="$(awk 'END { print NR + 0 }' "$SUB40")"

mira40c() {   # <nombre> <archivo-aplanado> <regex> — alguna viñeta tiene que decirlo
  local nombre="$1" archivo="$2" patron="$3" hay
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ ! -f "$SK40" ]; then
    echo "  FAIL  $nombre  no existe $SK40"; FAIL=$((FAIL+1)); return 0
  fi
  if [ "$VIN40" -lt 1 ]; then
    echo "  FAIL  $nombre  el apartado «Hacia 1.34.0» de ${SK40##*/} no tiene ni una viñeta: nada que medir"
    FAIL=$((FAIL+1)); return 0
  fi
  hay="$(grep -c -E -- "$patron" "$archivo" 2>/dev/null || true)"; hay="${hay:-0}"
  if [ "$hay" -gt 0 ]; then echo "  PASS  $nombre"; PASS=$((PASS+1))
  else echo "  FAIL  $nombre  ninguna de las $VIN40 viñetas del apartado casa /$patron/ (sub-bloque: $SUBN40)"; FAIL=$((FAIL+1)); fi
}
# El ÍNDICE de la primera viñeta que casa un patrón, o 0. El orden se mide por índice de viñeta
# y no por número de línea: son monótonos entre sí y el índice sobrevive a un reajuste de ancho.
idx40() {   # <archivo-aplanado> <regex> -> imprime el índice (1..N) o 0
  awk -v p="$2" '$0 ~ p { print NR; hallado = 1; exit } END { if (!hallado) print 0 }' "$1"
}

# ---------- CA-06 (i) · QUÉ PUDO PASAR, SIN EUFEMISMO Y POR CUALQUIER VÍA ----------
# La frase entera y no una insinuación: el criterio pide que diga que se pudo CERRAR un REQ
# `critico` SIN validación NI auditoría, y que la vía es indiferente. Un texto que dijera «una
# cabecera incompleta podía dar problemas» cumpliría la letra de «lo menciona» y no serviría
# para que nadie audite nada.
mira40c "REQ-024 CA-06 (i) la migración lo dice sin eufemismo: se pudo cerrar un critico sin validación NI auditoría" \
  "$SUB40" 'pudiste cerrar un REQ .critico. sin validación de QA y sin auditoría de seguridad aprobada'
mira40c "REQ-024 CA-06 (i) ...haciendo desaparecer una línea de la cabecera POR CUALQUIER VÍA" \
  "$SUB40" 'haciendo desaparecer una línea de la cabecera, POR CUALQUIER VÍA'
mira40c "REQ-024 CA-06 (i) ...con las tres vías nombradas una por una (comentarla, borrarla, no haberla escrito)" \
  "$SUB40" 'comentarla, borrarla o no haberla escrito nunca'
mira40c "REQ-024 CA-06 (i) ...y la propiedad que las une: la puerta no mide la vía, mide la ausencia" \
  "$SUB40" 'no mide la vía, mide la ausencia'

# ---------- CA-06 (ii) · LA PREGUNTA ES DE ESTADO, Y VA ANTES DE CUALQUIER COMANDO ----------
mira40c "REQ-024 CA-06 (ii) la pregunta se enuncia por ESTADO: «REQ en estado terminal que NO cerrarían hoy»" \
  "$SUB40" 'en estado terminal NO cerrarían hoy'
mira40c "REQ-024 CA-06 (ii) ...y dice que ningún comando del apartado la responde, con dueño y ventana" \
  "$SUB40" 'Ningún comando de este apartado la responde'
# EL ORDEN ES PARTE DEL CRITERIO, no una preferencia de redacción: una guía que enseña el
# comando primero se lee hasta el comando. Un `grep` de presencia no mide orden; esto sí. Se
# mide DOS veces —en el apartado entero y en el sub-bloque de esta vía— porque las dos cosas
# pueden ser ciertas por separado y falsas juntas: un sub-bloque que ofrece su comando antes de
# su pregunta cumple el apartado (la pregunta de la vía anterior va delante) y no cumple nada.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 (ii) orden en el apartado" | grep -qi -- "$FILTRO"; then
  p40="$(idx40 "$AP40" 'en estado terminal NO cerrarían hoy')"
  c40="$(idx40 "$AP40" '```')"
  if [ "$p40" -gt 0 ] && [ "$c40" -gt 0 ] && [ "$p40" -lt "$c40" ]; then
    echo "  PASS  REQ-024 CA-06 (ii) orden en el apartado: la propiedad (viñeta $p40) va ANTES del primer comando (viñeta $c40)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 (ii) orden en el apartado: propiedad en la viñeta $p40, primer comando en la $c40 (de $VIN40)"; FAIL=$((FAIL+1))
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 (ii) orden en el bloque" | grep -qi -- "$FILTRO"; then
  p40b="$(idx40 "$SUB40" 'en estado terminal NO cerrarían hoy')"
  c40b="$(idx40 "$SUB40" '```')"
  if [ "$p40b" -gt 0 ] && [ "$c40b" -gt 0 ] && [ "$p40b" -lt "$c40b" ]; then
    echo "  PASS  REQ-024 CA-06 (ii) orden en el bloque de esta vía: la propiedad (viñeta $p40b) va ANTES del primer comando (viñeta $c40b)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 (ii) orden en el bloque de esta vía: propiedad en la viñeta $p40b, primer comando en la $c40b (de $SUBN40 del sub-bloque)"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-06 (iii) · CADA BARRIDO POR VÍA, CON SUS TRES DECLARACIONES ----------
# Derivado y con denominador: no se cuenta «el barrido nuevo», se cuentan TODOS los barridos por
# vía del apartado y se exige que cada uno lleve las tres declaraciones de `REQ-016 CA-09 (ii)`
# —interroga una vía y no la propiedad, nombra las vías conocidas que no encuentra con su sitio
# único, y su silencio no acredita nada—. Con 0 barridos el caso ABSTIENE: «todos cumplen» es
# cierto por vacío cuando no hay ninguno, y un instrumento que ante la ausencia de datos
# responde verde es la familia que REQ-020 existe para cazar.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 (iii) los barridos por vía" | grep -qi -- "$FILTRO"; then
  nb40=0; mal40=''
  while IFS= read -r v40; do
    [ -n "$v40" ] || continue
    nb40=$((nb40 + 1))
    f40=''
    case "$v40" in *'interroga una VÍA, no la propiedad'*) ;; *) f40="$f40 no-dice-que-interroga-una-vía" ;; esac
    case "$v40" in *'NO acredita ausencia de exposición'*) ;; *) f40="$f40 no-dice-que-su-silencio-no-acredita" ;; esac
    case "$v40" in *'docs/seguridad/registro-seguridad.md'*) ;; *) f40="$f40 no-cita-el-sitio-único-de-las-vías" ;; esac
    case "$v40" in *'no exhaustiv'*) ;; *) f40="$f40 no-marca-sus-ejemplos-como-no-exhaustivos" ;; esac
    [ -z "$f40" ] || mal40="$mal40 viñeta-${v40%%$'\t'*}:$f40"
  done < <(grep -E -- 'Barrido POR VÍA|barrido POR VÍA' "$AP40" 2>/dev/null)
  if [ "$nb40" -lt 1 ]; then
    echo "  SKIP  REQ-024 CA-06 (iii) los barridos por vía  el apartado no tiene ningún barrido POR VÍA ($VIN40 viñetas): «todos declaran» sería cierto por vacío"
  elif [ -n "$mal40" ]; then
    echo "  FAIL  REQ-024 CA-06 (iii) los barridos por vía: $nb40 medidos y falta algo en$mal40"; FAIL=$((FAIL+1))
  else
    echo "  PASS  REQ-024 CA-06 (iii) los $nb40 barridos POR VÍA del apartado declaran las tres cosas y marcan sus ejemplos no exhaustivos"; PASS=$((PASS+1))
  fi
fi
# Y el barrido de ESTA vía nombra la que pierde ENTERA, que es precisamente la de `SEC-047`: un
# campo dentro de un rango de comentario. El barrido VE la clave y calla mientras el lector la
# trata como no declarada, así que su silencio es exactamente lo contrario de una acreditación.
mira40c "REQ-024 CA-06 (iii) el barrido nuevo nombra la vía que pierde entera: el campo dentro de un rango" \
  "$SUB40" 'el campo dentro de un rango .<!-- … -->. de la cabecera'

# ---------- CA-06 (iv) · CÓMO SE ACTIVA, QUÉ CUESTA, Y QUÉ PASA SI NO SE ACTIVA ----------
mira40c "REQ-024 CA-06 (iv) dice cómo se activa: la llave del manifiesto, por su nombre" \
  "$SUB40" 'campos\.ausencia_exige'
# «Qué cuesta» se responde con la pregunta de (ii) y NUNCA con una cifra escrita en el texto: una
# cifra de REQ afectados envejece hacia el lado que tranquiliza, porque depende del corpus del
# proyecto que lee. Es un caso NEGATIVO —el único de esta sección— y su patrón se acota al
# sub-bloque: el apartado de la vía anterior publica legítimamente el ruido medido de su barrido.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 (iv) qué cuesta" | grep -qi -- "$FILTRO"; then
  rem40="$(grep -c -E -- 'cuáles de mis REQ en estado terminal no cerrarían hoy' "$SUB40" 2>/dev/null || true)"
  cif40="$(grep -o -E -- '[0-9]+ (\*\*)?(de (tus|los|sus) )?REQ' "$SUB40" 2>/dev/null | tr '\n' ' ' || true)"
  if [ "${rem40:-0}" -gt 0 ] && [ -z "$cif40" ]; then
    echo "  PASS  REQ-024 CA-06 (iv) qué cuesta: se remite a la pregunta de (ii) y el sub-bloque no escribe ninguna cifra de REQ afectados"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 (iv) qué cuesta: remisión=${rem40:-0}, cifras de REQ en el texto='${cif40}'"; FAIL=$((FAIL+1))
  fi
fi
# «Sin activarla el proyecto se queda como está» tiene que ser VERDADERA LEÍDA SOLA, y por sí
# sola NO lo es en 1.34.0: el bloque B cambia la cola de aprobaciones SIN llave y para todos, y
# la firma de seguridad sobre un REQ sin `QA:` DENIEGA también con la llave apagada (`SEC-083`).
# Así que el criterio se cumple con el sujeto ACOTADO por DOS lados —la llave y el ACTO— más las
# frases que dicen qué sí cambia sin llave. Es la lección de `SEC-079` aplicada aquí: no se
# arregla colgando una coletilla a una promesa absoluta.
#
# EL SUJETO ACOTADO ES EL ACTO DE CIERRE Y NO «la resolución de la ausencia de un campo», que es
# lo que este caso exigía hasta el write-back de `CA-05`: esa formulación quedó MEDIDA FALSA —las
# celdas que divergen son exactamente resoluciones de la ausencia de `QA:`, sólo que en otro
# acto—, así que el patrón pide ahora el acto que `CA-06 (iv)` nombra.
mira40c "REQ-024 CA-06 (iv) la promesa de compatibilidad está ACOTADA a la llave y al ACTO de cierre, y es verdadera leída sola" \
  "$SUB40" 'en el acto de CIERRE tu proyecto cierra exactamente como cerraba[ ]*en 1\.33\.0'
mira40c "REQ-024 CA-06 (iv) ...y dice qué SÍ cambia sin llave: la cola de aprobaciones, para todos" \
  "$SUB40" 'LA COLA DE APROBACIONES CAMBIA SIN LLAVE, para todos'
mira40c "REQ-024 CA-06 (iv) ...y no maquilla el residual: con la llave apagada el proyecto sigue expuesto" \
  "$SUB40" 'con la llave apagada tu proyecto \*\*sigue expuesto\*\*'

# ---------- CA-06 (v) · EL ACTO QUE CAMBIA SIN QUE EL PROYECTO ACTIVE NADA ----------
# Un apartado que sólo dijera «sin la llave no cambia nada» promete de más, y la sorpresa la
# descubriría el consumidor en producción: la firma de seguridad sobre un REQ que no declara
# `QA:` pasa a DENEGAR en los DOS estados de la llave (`SEC-083`, salida (b) de `CA-12`). Los
# cuatro casos siguientes miden las cuatro cosas que `CA-06 (v)` exige de esa viñeta —el acto,
# su dirección con el estado de la llave, las dos salidas, y que la LISTA de actos la fije
# `CA-05` y este apartado sólo la CITE—.
#
# TODOS RECONOCEN POR CADENA LITERAL, Y SE DICE AQUÍ (`QA-024-05`): miden que el sub-bloque DIGA
# estas cosas, no que la puerta las haga. Quien mide la conducta es `13-orden-del-ciclo.sh`, y
# quien mide la equivalencia del acto de cierre es la parte 2. El denominador de estos cuatro es
# el sub-bloque entero (`$SUBN40` viñetas de las `$VIN40` del apartado), que `mira40c` publica en
# cada FAIL: una viñeta nueva que dijera lo mismo con otras palabras los pondría rojos, y eso es
# el residuo conocido de reconocer texto por cadena.
mira40c "REQ-024 CA-06 (v) nombra el ACTO que cambia sin activar nada: firmar seguridad sobre un REQ sin QA:" \
  "$SUB40" 'escribir .Seguridad: aprobado. sobre un REQ cuya cabecera NO declara .QA:.'
mira40c "REQ-024 CA-06 (v) ...con su DIRECCIÓN y el estado de la llave en la MISMA viñeta: deniega con la llave APAGADA" \
  "$SUB40" 'pasa a[ ]*DENEGAR, y DENIEGA con la llave APAGADA'
mira40c "REQ-024 CA-06 (v) ...y las DOS salidas de una línea: declarar el QA: que corresponda, o Seguridad: preventiva" \
  "$SUB40" 'declarar el .QA:. que corresponda, o .*declarar[ ]*la firma como .Seguridad: preventiva.'
mira40c "REQ-024 CA-06 (v) ...y la LISTA de actos divergentes la fija CA-05, no este apartado, que la cita" \
  "$SUB40" 'no la fija este apartado: la fija[ ]*.REQ-024 CA-05.'
mira40c "REQ-024 CA-06 (v) ...con los ejemplos marcados NO exhaustivos y los dos actos por su nombre (cierre: no cambia; firma: cambia)" \
  "$SUB40" 'Ejemplos \*\*no exhaustivos\*\* de actos: el \*\*cierre\*\*,[ ]*que no cambia, y la \*\*firma de seguridad\*\*, que cambia'

# ---------- CA-06 · NINGUNA PROMESA DE EQUIVALENCIA SE ENUNCIA SIN SU ACTO ----------
# La otra mitad de la cláusula final de `CA-06` —«ninguna frase afirma … que un proyecto que no
# activa nada no note NADA»—, medida como PROPIEDAD y no buscando una frase mala. `CA-05` dejó de
# contratar la equivalencia sobre «la puerta» y la contrata sobre el ACTO DE CIERRE (`ADR-011`),
# así que en este apartado toda promesa de equivalencia con la versión heredada tiene que llevar
# el acto DENTRO de la propia promesa. Con una coletilla al lado no vale: es exactamente la forma
# que `SEC-079` midió, y quien lee la promesa sola se queda con la promesa.
#
# LA FAMILIA PROHIBIDA SE RECONOCE POR CADENA LITERAL, Y ES UN CONJUNTO ABIERTO (`QA-024-05`):
# son las formas SIN acto medidas en este documento —dos de ellas vivían aquí hasta hoy: «la
# resolución de la ausencia de un campo de cabecera decide exactamente lo mismo que 1.33.0» y
# «sin la llave, 1.34.0 decide como las anteriores»—, no la lista de todas las maneras de
# prometer equivalencia. Una tercera forma redactada con otras palabras se le escapa, y por eso
# el caso PUBLICA su denominador —cuántas promesas ve y cuántas llevan su acto— en vez de decir
# «ninguna»: un instrumento que no puede enumerar su clase tiene que enseñar su cuenta.
# Y ABSTIENE con 0 promesas: «todas llevan su acto» es cierto por vacío cuando no hay ninguna, y
# un verde por no medir es la familia que `REQ-020` existe para cazar.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 promesas con su acto" | grep -qi -- "$FILTRO"; then
  # Con acto DENTRO de la promesa (el verbo de la equivalencia es cerrar) / sin acto (sujeto
  # abierto: «decide», «no nota nada», «se queda como está»).
  con40='cierra exactamente como cerraba|cierra como las anteriores|cierra exactamente como cerró'
  sin40='decide[ ]*exactamente lo mismo|decide como las anteriores|no nota nada|se queda[ ]*exactamente como está|se queda como está|resuelve como las anteriores'
  c40p="$(grep -o -E -- "$con40" "$AP40" 2>/dev/null | grep -c . || true)"
  s40p="$(grep -o -E -- "$sin40" "$AP40" 2>/dev/null | grep -c . || true)"
  tot40p=$(( ${c40p:-0} + ${s40p:-0} ))
  if [ "$tot40p" -lt 1 ]; then
    echo "  SKIP  REQ-024 CA-06 promesas con su acto  el apartado no enuncia ninguna promesa de equivalencia de las formas conocidas ($VIN40 viñetas): «todas llevan su acto» sería cierto por vacío"
  elif [ "${s40p:-0}" -eq 0 ]; then
    echo "  PASS  REQ-024 CA-06 las $tot40p promesas de equivalencia del apartado llevan el ACTO dentro de la promesa (${c40p} con acto, 0 de sujeto abierto; formas reconocidas por cadena, conjunto ABIERTO)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 promesas de equivalencia: $tot40p vistas y ${s40p} enunciadas SIN acto (sujeto abierto): $(grep -o -E -- "$sin40" "$AP40" | tr '\n' '|')"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-06 · NINGUNA FRASE DEL APARTADO AFIRMA COMPLETITUD SOBRE UN BARRIDO ----------
# No se busca una frase mala —esa lista envejece—: se comprueba la PROPIEDAD sobre las dos
# palabras con las que la completitud se cuela en este documento. Toda aparición de `exhaustiv`
# tiene que ir NEGADA, y toda aparición de «acredita ausencia de exposición» tiene que llevar su
# `NO`. Es la forma que `SEC-079` midió: una promesa absoluta con una coletilla al lado sigue
# siendo absoluta, y quien la lee sola se queda con la promesa.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 completitud" | grep -qi -- "$FILTRO"; then
  ex40="$(grep -o -E -- 'exhaustiv' "$AP40" 2>/dev/null | grep -c . || true)"
  exn40="$(grep -o -E -- 'no[ ]+exhaustiv' "$AP40" 2>/dev/null | grep -c . || true)"
  ac40="$(grep -o -E -- 'acredita ausencia de exposición' "$AP40" 2>/dev/null | grep -c . || true)"
  acn40="$(grep -o -E -- 'NO acredita ausencia de exposición' "$AP40" 2>/dev/null | grep -c . || true)"
  if [ "$VIN40" -lt 1 ]; then
    echo "  FAIL  REQ-024 CA-06 completitud: el apartado no tiene ni una viñeta, no hay nada que medir"; FAIL=$((FAIL+1))
  elif [ "${ex40:-0}" -eq "${exn40:-0}" ] && [ "${ac40:-0}" -eq "${acn40:-0}" ] && [ "${ac40:-0}" -gt 0 ]; then
    echo "  PASS  REQ-024 CA-06 ninguna frase del apartado afirma completitud: ${ex40} de ${ex40} «exhaustiv» negadas y ${acn40} de ${ac40} «acredita ausencia de exposición» con su NO"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 completitud: «exhaustiv» ${exn40:-0} negadas de ${ex40:-0}, «acredita ausencia de exposición» ${acn40:-0} con NO de ${ac40:-0}"; FAIL=$((FAIL+1))
  fi
fi

# ---------- QA-024-01 (mitad de texto) · EL `_doc` DE LA LLAVE, EN SUS DOS SEDES ----------
# El `_doc` viaja en el template, así que es superficie HEREDADA: un propietario lo lee para
# decidir si enciende la llave. Prometía dos cosas sin condición y las dos eran falsas medidas:
# «los VEREDICTOS … DENIEGAN nombrando el campo que falta» (falso para `Seguridad:` por debajo
# de `critico`, donde su veredicto no se lee) y «Todo REQ heredado que omita uno de esos cuatro
# campos deja de cerrar» (falso para los dos que GOBIERNAN: un REQ que omite `Sensible a
# seguridad:` y `Rigor:` y ya lleva `Seguridad: aprobado` CIERRA, con rigor efectivo `critico`).
#
# LAS PROPIEDADES QUE SE COMPRUEBAN SON EJEMPLOS NO EXHAUSTIVOS de la forma de `SEC-079`, y se
# dice aquí para no cometer en la prueba el defecto que la prueba vigila: son las CUATRO formas
# MEDIDAS falsas o medidas ausentes en este texto, no la lista de todas las maneras de prometer
# de más. El sitio único de las vías conocidas de la clase es
# `docs/seguridad/registro-seguridad.md`. Y por eso el caso no vale sin su INYECCIÓN: cada
# propiedad se rompe a propósito en la misma corrida y la comprobación tiene que fallar
# NOMBRÁNDOLA — un verde sobre un texto que nadie rompió también lo da un `grep` mal escrito.
MAN40="$REPO40C/.arnes/config.json"
TPLM40="$REPO40C/templates/arnes-config.json.tpl"
doc40() {   # <archivo> -> la línea `_doc` del bloque `campos`, entera
  awk '/^  "campos": \{/ { c = 1 } c && /"_doc"/ { print; exit }' "$1" 2>/dev/null
}
DOC40="$(doc40 "$MAN40")"; DOCT40="$(doc40 "$TPLM40")"
mal40d() {   # <texto> -> imprime las propiedades incumplidas, o nada
  local t="$1"
  case "$t" in *"Todo REQ"*"deja de cerrar"*) printf ' promesa-absoluta-de-cierre' ;; esac
  case "$t" in *"los VEREDICTOS"*DENIEGAN*) printf ' veredictos-sin-condicion' ;; esac
  case "$t" in
    *"Comentarlo, borrarlo"*)
      case "$t" in *"NO EXHAUSTIVOS"*) ;; *) printf ' vias-enumeradas-sin-marca' ;; esac
      case "$t" in *"docs/seguridad/registro-seguridad.md"*) ;; *) printf ' vias-sin-sitio-unico' ;; esac ;;
  esac
}
if [ -z "$FILTRO" ] || printf '%s' "QA-024-01 el _doc de la llave" | grep -qi -- "$FILTRO"; then
  if [ -z "$DOC40" ] || [ -z "$DOCT40" ]; then
    echo "  SKIP  QA-024-01 el _doc de la llave  no se pudo extraer el bloque \`campos\` de una de las dos sedes (${#DOC40} caracteres en .arnes/config.json, ${#DOCT40} caracteres en templates/): no hay texto que medir"
  elif [ "$DOC40" != "$DOCT40" ]; then
    echo "  FAIL  QA-024-01 las dos sedes del _doc DIVERGEN (${#DOC40} caracteres contra ${#DOCT40} caracteres): el proyecto y lo que heredan los demás prometen cosas distintas"; FAIL=$((FAIL+1))
  else
    echo "  PASS  QA-024-01 las dos sedes del _doc son IDÉNTICAS (${#DOC40} caracteres en .arnes/config.json y en templates/arnes-config.json.tpl)"; PASS=$((PASS+1))
  fi
fi
chk40d() {   # <nombre> <esperado> <obtenido>
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=<$2> obtenido=<$3>"; FAIL=$((FAIL+1)); fi
}
chk40d "QA-024-01 el _doc no incumple ninguna de las 4 propiedades medidas (ejemplos NO exhaustivos)" \
  "" "$(mal40d "$DOC40")"
chk40d "QA-024-01 inyección (a): devuelta la promesa absoluta de cierre, la comprobación FALLA nombrándola" \
  " promesa-absoluta-de-cierre" "$(mal40d "$DOC40 Todo REQ heredado que omita uno de esos cuatro campos deja de cerrar hasta que lo declare.")"
chk40d "QA-024-01 inyección (b): retirada la marca «NO EXHAUSTIVOS» de la enumeración de vías, FALLA nombrándola" \
  " vias-enumeradas-sin-marca" "$(mal40d "${DOC40//NO EXHAUSTIVOS/de la misma clase}")"

rm -f "$AP40" "$SUB40"
