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
CASOS_ESPERADOS_SECCION=30  # 29 → 30: el COSTE DEL BORDE (`SEC-102`). El borde de palabra que `I-7` puso a los DOS lados mataba los tres falsos positivos con el lado IZQUIERDO y, con el DERECHO, mataba además tres formas legítimas que la cabeza anterior sí cazaba —«anteriormente», «previamente», «con anterioridad»—: fallo hacia el VERDE y en silencio. El borde derecho se retira (los falsos positivos llevan el término como SUFIJO y el izquierdo ya los rechaza enteros) y el caso nuevo ejerce LOS DOS LADOS en la misma vuelta: tres positivos que deben morder —regresiones conocidas, conjunto NO exhaustivo y NO excepciones— y los tres sufijos que deben seguir en «0 0». El renglón siguiente describe el mecanismo del 2026-09-14, cuando el borde estaba a ambos lados.  # 28 → 29: los FALSOS POSITIVOS de `I-7` con la falsación `v2`. La reparación de `I-5` ensanchó el eje del término heredado y metió dos defectos propios —el escape `\.` perdido al pasar por `awk -v`, que hacía casar cualquier número de 3+ cifras o una fecha ISO como identificador de versión, y la anterioridad sin límite de palabra («bastantes», «restantes», «instantes»)—. Corregidos con ENVIRON y bordes no alfabéticos, el caso nuevo los EJERCE: seis negativos que deben dar «0 0» y la falsación `v2`, fuera de las siete, que debe seguir mordiendo para que «0 falsos positivos» no sea cierto por mudez.  # 27 → 28: las SIETE REGRESIONES CONOCIDAS de `I-5` con sus controles positivos. Al acotar el reconocedor por propiedad (26 → 27, abajo) el eje del VERBO quedó bien y el del TÉRMINO HEREDADO quedó como enumeración cerrada y alcance de una sola oración; QA y el auditor midieron que por ahí se soltaron **siete** formas que el reconocedor anterior sí cazaba, **ninguna espuria**. El caso nuevo inyecta las siete, una a una, y exige que **todas vuelvan a morder**, más los controles positivos en la misma vuelta (la frase protectora y las dos promesas reales siguen pasando). Son regresiones CONOCIDAS, no la definición de la clase ni un conjunto cerrado.  # 26 → 27: el DISCRIMINANTE del reconocedor de promesas de equivalencia. Al corregir su alcance (falso positivo medido en CI, PR #50: la fila `MODIFICADO` de la tabla de migración casaba con el verbo sin prometer equivalencia con ninguna versión), el arreglo sería indistinguible de haber aflojado el reconocedor; el caso nuevo inyecta en una COPIA las dos formas que tienen que decidir distinto —con término heredado y SIN acto muerde, la misma CON acto pasa— más el control de que la frase que protege el texto personalizado, sola, no es ni promesa ni infracción
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
# QUÉ ES UNA PROMESA DE EQUIVALENCIA, Y POR QUÉ HIZO FALTA DECIRLO (`CA-06`, falso positivo medido
# en CI, PR #50). El reconocedor buscaba los VERBOS de la familia sobre el apartado entero, y el
# apartado dejó de ser sólo prosa sobre la llave: ahora lleva además la tabla de migración, cuya
# fila `MODIFICADO` dice «Tu texto **se queda como está**». Esa frase NO promete equivalencia con
# ninguna versión heredada — su sujeto es **el texto del proyecto ante un conflicto**, y su acto va
# al lado («el conflicto se lista para el humano») —, pero casaba con el verbo y teñía el caso de
# rojo. Y la instrucción que protege el texto personalizado NO se reformula para esquivar una
# prueba: se arregla el ALCANCE del reconocedor.
#
# La distinción se hace POR PROPIEDAD, no excluyendo la línea, la fila ni la tabla por su nombre
# —una exclusión por nombre deja de valer en cuanto la tabla se mueva—: **una promesa de
# equivalencia compara con una VERSIÓN HEREDADA, y por tanto nombra el término de la comparación**.
# Las dos promesas reales del apartado lo llevan («cierra exactamente como cerraba **en 1.33.0**»,
# «sin la llave, 1.34.0 cierra **como las anteriores**»); «tu texto se queda como está» no lo lleva,
# porque no hay versión con la que comparar. Sin término heredado no hay equivalencia que prometer.
#
# EL DETECTOR QUEDÓ POR PROPIEDAD EN UN EJE DE DOS, Y ESO FUE `I-5`. La primera versión de esta
# corrección acotó bien el eje del VERBO/ACTO y dejó el del TÉRMINO HEREDADO como una **enumeración
# cerrada** y un alcance de **una sola oración**. Resultado medido por QA y por el auditor: **siete**
# formas que el reconocedor anterior sí cazaba dejaron de caer, **ninguna de ellas espuria** — las
# siete eran promesas que debían seguir bloqueadas. Efecto sobre el texto de entonces: nulo.
# Cobertura futura: perdida. Los dos ejes se enuncian ahora por propiedad:
#
#   EJE 1 · QUÉ ES UN TÉRMINO HEREDADO — **por propiedad, con ejemplos NO EXHAUSTIVOS**
#   (`requirements/README.md`: una enumeración cerrada envejece hacia el lado que abre). Es toda
#   expresión que señale **un estado anterior de este arnés**, y se reconoce de dos maneras:
#     (i) un IDENTIFICADOR DE VERSIÓN — con `v` o sin ella, completo o truncado: `1.33.0`, `1.33.`,
#         `v1`—; o
#     (ii) una EXPRESIÓN DE ANTERIORIDAD — «anterior», «previa», «antes», «hasta ahora»,
#         «heredada»…
#   Los ejemplos de abajo son **ejemplos**, no la clase: una forma nueva de decir «antes» se le
#   escapa, y por eso el caso **publica su denominador** en vez de afirmar «ninguna».
#
#   EJE 2 · DÓNDE PUEDE ESTAR ESE TÉRMINO — en la oración del verbo **o en una vecina inmediata**,
#   dentro del MISMO BLOQUE. Una promesa se reparte entre dos frases con toda naturalidad («La
#   comparación es con la versión 1.33.0. Sin la llave, decide exactamente lo mismo.»), así que la
#   oración sola suelta la mitad de la familia. **El bloque es el límite**, y es lo que impide que
#   esto se vuelva laxo: una celda de tabla es un bloque, así que el término de una celda **no le
#   presta** a otra — que era la ganancia por la que se acotó, y se conserva.
#
# LÍMITE DECLARADO, PORQUE SIGUE SIENDO UN RECONOCEDOR POR CADENA Y NO UN ANALIZADOR: no entiende
# castellano. Reconoce las formas que se le enumeran en los dos ejes y **no las demás**; la ventana
# de dos oraciones es una heurística de vecindad, no una noción de párrafo. Lo que lo hace fiable no
# es su cobertura, sino que **lo que suelta y lo que muerde está ejercido**: las SIETE regresiones
# conocidas y los controles positivos corren en cada vuelta, abajo.
# Con acto DENTRO de la promesa (el verbo de la equivalencia es cerrar) / sin acto (sujeto
# abierto: «decide», «no nota nada», «se queda como está»). Conjunto ABIERTO (`QA-024-05`).
# Se definen a NIVEL DE ARCHIVO, no dentro del primer caso: los tres casos de `CA-06` los usan, y
# con `FILTRO` el primero puede no ejecutarse.
con40='cierra exactamente como cerraba|cierra como las anteriores|cierra exactamente como cerró'
sin40='decide[ ]*exactamente lo mismo|decide como las anteriores|no nota nada|se queda[ ]*exactamente como está|se queda como está|resuelve como las anteriores'
# EJE 1, con sus ejemplos declaradamente NO EXHAUSTIVOS (ver cabecera): identificador de versión
# —con `v` o sin ella, completo o truncado— o expresión de anterioridad.
#
# LAS DOS CAUTELAS DE ABAJO SON `I-7`, Y LAS DOS SON DEFECTOS QUE ESTE MISMO CASO INTRODUJO:
#
#  (1) EL PUNTO TIENE QUE LLEGAR A `awk` COMO PUNTO LITERAL. Estos patrones NO se pasan con
#      `awk -v`, y no es un capricho: `-v` **procesa las secuencias de escape**, así que `\.` llega
#      como `.` —cualquier carácter— y el patrón de versión se vuelve enorme: `123`, `2026` o una
#      fecha ISO casaban como «identificador de versión», y bastaba una fecha cerca de la frase
#      protegida para teñir el caso de rojo. Se pasan por **ENVIRON**, que entrega el valor **byte a
#      byte, sin interpretar nada**. Es la forma que **no depende de que nadie recuerde una regla de
#      escapes** al editar el patrón más tarde: lo que se escriba aquí es exactamente lo que ve
#      `awk`. (El síntoma también era visible y nadie lo miraba: `-v` emitía 12 avisos
#      `escape sequence \. treated as plain .` por corrida. Con ENVIRON son **0**, y ese cero es
#      parte de lo que se comprueba.)
#
#  (2) LA ANTERIORIDAD CASA POR EL PRINCIPIO DE LA PALABRA, NO COMO SUBCADENA — Y EL BORDE VA EN
#      UN SOLO LADO. Sin límites, «bast-antes», «rest-antes» e «inst-antes» mordían. El límite se
#      escribe **sin extensiones de gawk** —`\<`, `\>` y `\b` no son portables—: se exige **borde
#      de cadena o carácter no alfabético** **a la IZQUIERDA**, y **nada a la derecha**.
#
#      POR QUÉ SÓLO A LA IZQUIERDA, Y ESTÁ MEDIDO (`SEC-102`). Los tres falsos positivos llevan el
#      término como **sufijo** (`bast|antes`, `rest|antes`, `inst|antes`), así que el borde
#      izquierdo ya los rechaza **enteros**: con él solo siguen dando «0 0». El borde DERECHO no
#      compraba **ni uno** de los tres y costaba **tres verdaderos** —«anteriormente»,
#      «previamente», «con anterioridad»—, que son la misma clase con el término como **prefijo** y
#      que la cabeza anterior sí cazaba. Dejaron de morder **en silencio** y la dirección del fallo
#      era **hacia el VERDE**: una promesa real escrita con «anteriormente» pasaba inadvertida.
#      Retirar el borde derecho las recupera **sin resucitar ningún negativo medido**, y el caso
#      «el COSTE del borde», abajo, ejerce **los dos lados en la misma vuelta**, para que el
#      siguiente ajuste tenga que decidir entre ellos **a la vista** y no en silencio.
#
#      Las terminaciones (`anterior(es)`, `previ[ao]s`, `heredad[ao]s`) se CONSERVAN, y ya no por
#      el borde derecho sino porque siguen restringiendo por sí solas: `previ[ao]s?` no alcanza
#      «previsto», que un `previ` a secas sí alcanzaría.
ver40_ver='[0-9]+\.[0-9]+|(^|[^a-zA-Z0-9])v[0-9]+'
ver40_ant='(^|[^[:alpha:]])(anterior(es)?|previ[ao]s?|antes|hasta ahora|heredad[ao]s?)'
ver40="$ver40_ver|$ver40_ant"
# EJE 2. `mide40p <archivo-en-formato-AP> [detalle]` -> «<con> <sin>», o con `detalle` una línea
# `<clase>|<verbo>|<término heredado>` por promesa vista. Parte cada viñeta en BLOQUES por el
# separador de celda, cada bloque en ORACIONES por punto+espacio, y para cada oración con verbo de
# la familia busca el término heredado en ella o en una vecina del mismo bloque.
# (Nota de precisión, porque la versión anterior de este comentario lo decía mal: un «1.33.0» a
# mitad de frase no se parte, pero uno que CIERRA la oración va seguido de punto y espacio y SÍ se
# parte. Por eso el término se busca también en la vecina, y no sólo en la propia oración.)
# Los nombres de las variables de awk llevan prefijo A PROPÓSITO: `sin` es una función interna de
# gawk y usarla como variable aborta el programa. Y NO se enmascara el error: si el medidor no
# puede correr, no imprime nada, y quien lo llama **falla nombrándolo** en vez de leer un 0. Un
# medidor roto que devuelve «0 promesas sin acto» es un verde por no medir, que es justo la familia
# que este banco existe para cazar.
mide40p() {
    ARNES40_CON="$con40" ARNES40_SIN="$sin40" ARNES40_VER="$ver40" ARNES40_MODO="${2:-cuenta}" \
    awk '
      BEGIN {
        rcon = ENVIRON["ARNES40_CON"]; rsin = ENVIRON["ARNES40_SIN"]
        rver = ENVIRON["ARNES40_VER"]; modo = ENVIRON["ARNES40_MODO"]
      }
      {
        nb = split($0, B, /\|/)
        for (b = 1; b <= nb; b++) {
          t = B[b]; gsub(/\. /, ".\n", t)
          no = split(t, S, /\n/)
          for (i = 1; i <= no; i++) {
            v = (S[i] ~ rcon) ? "con" : ((S[i] ~ rsin) ? "sin" : "")
            if (v == "") continue
            ctx = S[i]
            if (i > 1)  ctx = S[i-1] " " ctx
            if (i < no) ctx = ctx " " S[i+1]
            if (ctx !~ rver) continue
            if (modo == "cuenta") { if (v == "con") c++; else s++; continue }
            verbo = ""; if (match(S[i], (v == "con") ? rcon : rsin)) verbo = substr(S[i], RSTART, RLENGTH)
            term = "";  if (match(ctx, rver)) term = substr(ctx, RSTART, RLENGTH)
            gsub(/^[^[:alnum:]]+|[^[:alnum:]]+$/, "", term)
            print v "|" verbo "|" term
          }
        }
      }
      END { if (modo == "cuenta") printf "%d %d", c + 0, s + 0 }
    ' "$1"
}

if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 promesas con su acto" | grep -qi -- "$FILTRO"; then
  m40="$(mide40p "$AP40")"; c40p="${m40%% *}"; s40p="${m40##* }"
  tot40p=$(( ${c40p:-0} + ${s40p:-0} ))
  if [ -z "$m40" ]; then
    echo "  FAIL  REQ-024 CA-06 promesas con su acto: el MEDIDOR no pudo correr y no hay medición; esto no se da por bueno ni se cuenta como «0 promesas sin acto»"; FAIL=$((FAIL+1))
  elif [ "$tot40p" -lt 1 ]; then
    echo "  SKIP  REQ-024 CA-06 promesas con su acto  el apartado no enuncia ninguna promesa de equivalencia de las formas conocidas ($VIN40 viñetas): «todas llevan su acto» sería cierto por vacío"
  elif [ "${s40p:-0}" -eq 0 ]; then
    echo "  PASS  REQ-024 CA-06 las $tot40p promesas de equivalencia del apartado llevan el ACTO dentro de la promesa (${c40p} con acto, 0 de sujeto abierto; oraciones con verbo de la familia Y término heredado, conjunto ABIERTO)"; PASS=$((PASS+1))
  else
    # El rojo nombra el VERBO **y el término heredado que hizo contar la oración**. Sin el término,
    # el mensaje señalaba sólo la frase con el verbo —típicamente la que protege el texto
    # personalizado— e inducía a reescribirla, que es justo lo que no hay que hacer: lo que hay que
    # mirar es la pareja, y muchas veces lo que sobra es el término, no el verbo.
    echo "  FAIL  REQ-024 CA-06 promesas de equivalencia: $tot40p vistas y ${s40p} enunciadas SIN acto (sujeto abierto): $(mide40p "$AP40" detalle | awk -F'|' '$1 == "sin" { printf "· verbo «%s» + término heredado «%s» ", $2, $3 }')"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-06 · EL DISCRIMINANTE DEL RECONOCEDOR (par fail-before / pass-after) ----------
# Sin esto, el arreglo de arriba sería indistinguible de haber aflojado el reconocedor hasta que
# dejara de morder. Se inyectan en una COPIA del apartado las dos formas que tienen que decidir
# distinto, y se exige que decidan distinto:
#   (b1) promesa de equivalencia con la versión heredada SIN su acto  -> tiene que SEGUIR FALLANDO
#   (b2) la misma promesa CON su acto dentro                          -> tiene que PASAR
# El control (a) —que la frase protectora del texto personalizado pasa SIN haber sido cambiada— lo
# da el caso de arriba sobre el apartado real, que la contiene tal cual.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 discriminante del reconocedor" | grep -qi -- "$FILTRO"; then
  INY40="$RAIZ/iny40-$BASHPID.txt"
  # (b1) sintética SIN acto, con término heredado explícito.
  { cat "$AP40"; printf '0\t- sin la llave, esta version decide como las anteriores.\n'; } > "$INY40"
  b1="$(mide40p "$INY40")"; b1s="${b1##* }"
  # (b2) sintética CON su acto dentro de la promesa.
  { cat "$AP40"; printf '0\t- sin la llave, esta version cierra como las anteriores.\n'; } > "$INY40"
  b2="$(mide40p "$INY40")"; b2s="${b2##* }"; b2c="${b2%% *}"
  # (c) control de no-vacuidad: la frase protectora, SOLA, no es una promesa de equivalencia.
  printf '0\t- Tu texto **se queda como está** y el conflicto **se lista para el humano**.\n' > "$INY40"
  b3="$(mide40p "$INY40")"
  if [ "$b1s" -ge 1 ] && [ "$b2s" -eq 0 ] && [ "$b2c" -ge 1 ] && [ "$b3" = "0 0" ]; then
    echo "  PASS  REQ-024 CA-06 discriminante: el reconocedor sigue mordiendo lo que debe y suelta lo que no  (inyectada SIN acto -> $b1s sin acto, muerde; la MISMA CON acto -> $b2s sin acto y $b2c con acto, pasa; la frase que protege el texto personalizado, sola -> «$b3», ni promesa ni infracción)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 discriminante: el reconocedor no distingue los dos casos  (SIN acto -> «$b1» (se esperaba sin>=1); CON acto -> «$b2» (se esperaba sin=0 y con>=1); frase protectora sola -> «$b3» (se esperaba «0 0»))"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-06 · LAS SIETE REGRESIONES CONOCIDAS, Y LOS CONTROLES POSITIVOS ----------
# Las siete formas que el reconocedor de `d913575` dejó de cazar y el anterior sí cazaba (`I-5`,
# medidas por QA y confirmadas por el auditor: **ninguna era espuria**; las siete son promesas de
# equivalencia sin su acto y debían seguir bloqueadas). Se inyecta cada una en una COPIA del
# apartado y se exige que **siga mordiendo**.
#
# NO SON LA DEFINICIÓN NI UN CONJUNTO CERRADO, y esto importa tanto como el caso: son las
# regresiones **conocidas**, es decir las que ya se escaparon una vez. La clase la enuncian los dos
# ejes de la cabecera, por propiedad y con ejemplos no exhaustivos; estas siete son el suelo
# ejercido, no el techo. Tampoco son excepciones escritas una a una: el arreglo está en la
# PROPIEDAD —el término heredado por clase, y la vecindad dentro del bloque—, y estas siete sólo
# comprueban que la propiedad las alcanza.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 regresiones conocidas" | grep -qi -- "$FILTRO"; then
  REG40="$RAIZ/reg40-$BASHPID.txt"
  # Cada entrada: <etiqueta del eje que la dejó escapar>::<texto inyectado>
  REGS40=(
    'vecina/término en la oración anterior::La comparación es con la versión 1.33.0. Sin la llave, decide exactamente lo mismo.'
    'vecina/«no nota nada» en la siguiente::Frente a las anteriores no hay cambio. Un proyecto no nota nada.'
    'enumeración/versión sin punto decimal::sin la llave, la v1 decide exactamente lo mismo.'
    'corte/versión que cierra la oración::respecto a la versión 1.33. decide exactamente lo mismo.'
    'enumeración/anterioridad natural::respecto a antes, decide exactamente lo mismo.'
    'enumeración/anterioridad natural::como hasta ahora, no nota nada.'
    'enumeración/«previa» no estaba::igual que en la versión previa, decide exactamente lo mismo.'
  )
  reg_tot=0; reg_ok=0; reg_mal=''
  for entrada in "${REGS40[@]}"; do
    reg_tot=$((reg_tot+1))
    eje="${entrada%%::*}"; texto="${entrada#*::}"
    { cat "$AP40"; printf '0\t- %s\n' "$texto"; } > "$REG40"
    r="$(mide40p "$REG40")"; rs="${r##* }"
    if [ "${rs:-0}" -ge 1 ]; then reg_ok=$((reg_ok+1)); else reg_mal="$reg_mal · #$reg_tot [$eje] «$texto»"; fi
  done
  # Controles POSITIVOS, en la misma vuelta: el apartado SIN inyectar tiene que seguir dando sus dos
  # promesas con acto y ninguna sin acto — es decir, la frase protectora de la fila `MODIFICADO`
  # sigue pasando SIN haber sido reformulada, y las dos promesas reales del apartado también.
  pos="$(mide40p "$AP40")"; posc="${pos%% *}"; poss="${pos##* }"
  if [ "$reg_ok" -eq "$reg_tot" ] && [ "${poss:-1}" -eq 0 ] && [ "${posc:-0}" -ge 2 ]; then
    echo "  PASS  REQ-024 CA-06 las $reg_tot regresiones conocidas de I-5 siguen mordiendo, y los controles positivos siguen pasando  ($reg_ok de $reg_tot inyectadas dan «sin acto» >= 1 —conjunto de regresiones CONOCIDAS, NO exhaustivo—; y el apartado sin inyectar sigue en $posc con acto y $poss sin acto, así que la frase protectora y las dos promesas reales pasan sin haberse tocado)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 regresiones/controles: $reg_ok de $reg_tot regresiones muerden (se esperaban $reg_tot)$reg_mal · controles positivos: $posc con acto (se esperaba >=2) y $poss sin acto (se esperaba 0)"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-06 · LOS FALSOS POSITIVOS DE `I-7`, Y LA FALSACIÓN `v2` ----------
# `I-7` fueron DOS defectos que la reparación de `I-5` introdujo al ensanchar el eje del término
# heredado: el escape `\.` perdido al pasar por `awk -v` (cualquier número de 3+ cifras o una fecha
# ISO casaba como versión) y la anterioridad sin límite de palabra («bastantes», «restantes»).
# Los dos están corregidos arriba —ENVIRON y borde izquierdo no alfabético; el borde DERECHO se
# retiró después por `SEC-102` y no hacía falta para esto— y aquí se EJERCEN, porque un arreglo de
# reconocedor que no se ejerce en los dos sentidos no se distingue de aflojarlo.
#
# Y con ellos va `v2`, la falsación de QA: una forma que **no está entre las siete** y que tiene que
# morder igual. Es lo que separa «arreglé la propiedad» de «añadí siete excepciones».
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 falsos positivos I-7" | grep -qi -- "$FILTRO"; then
  NEG40="$RAIZ/neg40-$BASHPID.txt"
  # Negativos: la frase que protege el texto personalizado, con un vecino inocente al lado. Ninguno
  # es un término heredado, así que ninguno puede convertirla en promesa de equivalencia.
  NEGS40=(
    'fecha ISO junto a la frase protectora::Decidido el 2026-09-14: tu texto se queda como está'
    'fecha ISO en la oración vecina::Corregido el 2026-09-14. Tu texto se queda como está'
    '«bastantes» (anterioridad dentro de otra palabra)::Hay bastantes casos y tu texto se queda como está'
    '«restantes» (ídem)::Los restantes: tu texto se queda como está'
    '«instantes» (ídem)::Durante unos instantes, tu texto se queda como está'
    'número suelto de 3 cifras::Nota 123: tu texto se queda como está'
  )
  neg_tot=0; neg_ok=0; neg_mal=''
  for entrada in "${NEGS40[@]}"; do
    neg_tot=$((neg_tot+1))
    eje="${entrada%%::*}"; texto="${entrada#*::}"
    printf '0\t- %s\n' "$texto" > "$NEG40"
    r="$(mide40p "$NEG40")"
    if [ "$r" = "0 0" ]; then neg_ok=$((neg_ok+1)); else neg_mal="$neg_mal · #$neg_tot [$eje] dio «$r» en vez de «0 0»: «$texto»"; fi
  done
  # Positivo de no-vacuidad: `v2` NO está entre las siete regresiones conocidas y tiene que morder.
  # Sin esto, «0 falsos positivos» sería cierto por haber dejado el reconocedor mudo.
  printf '0\t- sin la llave, la v2 decide exactamente lo mismo.\n' > "$NEG40"
  v2="$(mide40p "$NEG40")"; v2s="${v2##* }"
  if [ "$neg_ok" -eq "$neg_tot" ] && [ "${v2s:-0}" -ge 1 ]; then
    echo "  PASS  REQ-024 CA-06 los $neg_tot falsos positivos de I-7 ya no muerden, y el reconocedor no se quedó mudo  ($neg_ok de $neg_tot dan «0 0» —fechas ISO, números de 3 cifras y la anterioridad dentro de «bastantes»/«restantes»/«instantes»—; y la falsación «v2», que NO está entre las siete regresiones, sigue mordiendo con $v2s sin acto)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 falsos positivos I-7: $neg_ok de $neg_tot dan «0 0» (se esperaban $neg_tot)$neg_mal · y la falsación «v2» dio «$v2» (se esperaba sin acto >= 1; un 0 aquí significa que el reconocedor quedó mudo, no limpio)"; FAIL=$((FAIL+1))
  fi
fi

# ---------- CA-06 · EL COSTE DEL BORDE, EJERCIDO POR LOS DOS LADOS (`SEC-102`) ----------
# Este caso existe porque es la TERCERA vez en esta cadena que un ajuste del reconocedor estrecha
# en silencio: `I-5` soltó siete formas al acotar el alcance, y el borde de palabra de `I-7` soltó
# otras tres al poner límites por ambos lados. El patrón es siempre el mismo —cada arreglo se
# ejerce sólo sobre los casos para los que se escribió—, y la respuesta no es más vigilancia sino
# un caso que mida **el COSTE** del ajuste, no sólo su ganancia.
#
# Las tres de abajo son REGRESIONES CONOCIDAS PERMANENTES, y por tanto POSITIVOS QUE DEBEN MORDER:
# las cazaba la cabeza anterior al borde derecho, están dentro de la clase que el EJE 1 enuncia
# —«toda expresión que señale un estado anterior de este arnés»— y las tres son promesas de
# equivalencia SIN su acto. NO SON EXCEPCIONES escritas una a una ni la definición de la clase: el
# arreglo vive en la PROPIEDAD (el borde va sólo a la izquierda, porque los falsos positivos llevan
# el término como sufijo y los verdaderos como prefijo), y estas tres sólo comprueban que la
# propiedad las alcanza. Como las siete de `I-5`, son **suelo ejercido y NO techo**, y el conjunto
# es declaradamente **NO EXHAUSTIVO**: una cuarta forma de decir «antes» se le escapa, y por eso el
# caso publica lo que ve en vez de afirmar «ninguna».
#
# Y LOS TRES NEGATIVOS VAN EN LA MISMA VUELTA, que es lo que este caso añade sobre los de arriba:
# los dos lados del borde se deciden JUNTOS y A LA VISTA. Quien vuelva a poner un límite por la
# derecha verá en el acto los tres verdaderos que cuesta; quien lo quite entero verá los tres
# falsos positivos que vuelven. Un caso que sólo mirase un lado enseña a pagar el otro sin saberlo.
if [ -z "$FILTRO" ] || printf '%s' "REQ-024 CA-06 el coste del borde" | grep -qi -- "$FILTRO"; then
  BOR40="$RAIZ/bor40-$BASHPID.txt"
  # Positivos: el término heredado como PREFIJO de una palabra más larga. Se inyectan sobre una
  # COPIA del apartado, igual que las siete regresiones de `I-5`, y tienen que seguir mordiendo.
  BORS40=(
    'prefijo/«anteriormente»::anteriormente, decide exactamente lo mismo.'
    'prefijo/«previamente»::previamente, no nota nada.'
    'prefijo/«con anterioridad»::con anterioridad, decide exactamente lo mismo.'
  )
  bor_tot=0; bor_ok=0; bor_mal=''
  for entrada in "${BORS40[@]}"; do
    bor_tot=$((bor_tot+1))
    eje="${entrada%%::*}"; texto="${entrada#*::}"
    { cat "$AP40"; printf '0\t- %s\n' "$texto"; } > "$BOR40"
    r="$(mide40p "$BOR40")"; rs="${r##* }"
    if [ "${rs:-0}" -ge 1 ]; then bor_ok=$((bor_ok+1)); else bor_mal="$bor_mal · #$bor_tot [$eje] «$texto» no muerde"; fi
  done
  # El OTRO lado, aquí y no sólo en el caso de `I-7`: el término como SUFIJO tiene que seguir
  # rechazado por el borde IZQUIERDO. Van solos —no sobre el apartado—, porque lo que se exige es
  # el «0 0» exacto: sobre el apartado se mezclarían con sus dos promesas legítimas.
  BORN40=(
    'sufijo/«bastantes»::Hay bastantes casos y tu texto se queda como está'
    'sufijo/«restantes»::Los restantes: tu texto se queda como está'
    'sufijo/«instantes»::Durante unos instantes, tu texto se queda como está'
  )
  born_tot=0; born_ok=0; born_mal=''
  for entrada in "${BORN40[@]}"; do
    born_tot=$((born_tot+1))
    eje="${entrada%%::*}"; texto="${entrada#*::}"
    printf '0\t- %s\n' "$texto" > "$BOR40"
    r="$(mide40p "$BOR40")"
    if [ "$r" = "0 0" ]; then born_ok=$((born_ok+1)); else born_mal="$born_mal · #$born_tot [$eje] dio «$r» en vez de «0 0»: «$texto»"; fi
  done
  if [ "$bor_ok" -eq "$bor_tot" ] && [ "$born_ok" -eq "$born_tot" ]; then
    echo "  PASS  REQ-024 CA-06 el coste del borde: las $bor_tot formas con el término como PREFIJO vuelven a morder y los $born_tot negativos con el término como SUFIJO siguen en «0 0»  ($bor_ok de $bor_tot dan «sin acto» >= 1 —«anteriormente», «previamente», «con anterioridad»: regresiones CONOCIDAS de SEC-102, conjunto NO exhaustivo y NO excepciones—; $born_ok de $born_tot dan «0 0» —«bastantes», «restantes», «instantes»—, así que el borde izquierdo basta y el derecho no compra ninguno)"; PASS=$((PASS+1))
  else
    echo "  FAIL  REQ-024 CA-06 el coste del borde: $bor_ok de $bor_tot prefijos muerden (se esperaban $bor_tot)$bor_mal · $born_ok de $born_tot sufijos dan «0 0» (se esperaban $born_tot)$born_mal · los dos lados se deciden juntos: recuperar unos no puede comprarse soltando los otros"; FAIL=$((FAIL+1))
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
