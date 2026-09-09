# Sección 07 del banco — 07-bash-falsos-positivos
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=49
PISO_AUTONOMO_SECCION=74  # 8 preámbulo + 0 maquinaria compartida duplicada + 66 bloque indivisible mayor · REQ-014 CA-18

  seccion_nueva "Bash — lo que NO debe denegar (falsos positivos):"
check "coordinadora: cat de lectura -> allow"        allow guard-codigo.sh "$(emite_bash 'cat src/app.ts' "" "")"
check "coordinadora: grep recursivo -> allow"        allow guard-codigo.sh "$(emite_bash 'grep -rn foo src/ | head -20' "" "")"
check "coordinadora: sed sin -i -> allow"            allow guard-codigo.sh "$(emite_bash "sed -n '1,20p' src/app.ts" "" "")"
check "coordinadora: la ruta sólo se menciona en un mensaje -> allow" allow guard-codigo.sh "$(emite_bash 'git commit -m "arregla src/app.ts > listo"' "" "")"
check "coordinadora: lee código y escribe fuera -> allow" allow guard-codigo.sh "$(emite_bash 'cp src/app.ts /tmp/copia.ts' "" "")"
# El cuerpo de un heredoc es TEXTO que se entrega a un comando, no el comando (1.30.2).
# Medido en un proyecto real: un resumen en heredoc con `cp README.md src/...` como texto
# era denegado. Reproducido con cp, con `>` y con tee.
check "heredoc: 'cp README.md src/...' como TEXTO del cuerpo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<\'EOF\'\nresumen: cp README.md src/canario.txt ; listo\nEOF' "" "")"
check "heredoc: 'echo x > src/otro.ts' en el cuerpo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nejemplo: echo hola > src/otro.ts\nEOF' "" "")"
check "heredoc con <<- y sangria: 'tee src/otro.ts' en el cuerpo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<-EOF\n\tejemplo: tee src/otro.ts\n\tEOF' "" "")"
# --- Heredoc CITADO: el cuerpo si es literal, tambien en el shell real ---------------
# El control que da valor a los deny de arriba: con el delimitador citado o escapado bash
# NO expande nada, no se crea ningun archivo, y el hook no puede estorbar.
check "heredoc CITADO <<'EOF': el cuerpo es literal -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<\'EOF\'\n$(echo x > src/generated.ts)\nEOF' "" "")"
check 'heredoc CITADO con comillas dobles: el cuerpo es literal -> allow' allow guard-codigo.sh \
  "$(emite_bash $'cat <<"EOF"\n$(echo x > src/generated.ts)\nEOF' "" "")"
check 'heredoc ESCAPADO con barra invertida: el cuerpo es literal -> allow' allow guard-codigo.sh \
  "$(emite_bash $'cat <<\\EOF\n$(echo x > src/generated.ts)\nEOF' "" "")"
# Sin citar, pero la expansion no escribe nada: tampoco puede denegarse.
check "heredoc sin citar: una expansion inocente de fecha -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nfecha: $(date)\nEOF' "" "")"
# El falso positivo de 1.29.1, ahora tambien con el delimitador SIN citar: texto es texto.
check "heredoc sin citar: 'cp README.md src/...' como TEXTO del cuerpo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nresumen: cp README.md src/x.ts ; listo\nEOF' "" "")"
# La restriccion es de QUIEN edita, no de la forma del comando.
check "heredoc sin citar: el desarrollador si puede escribir codigo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/generated.ts)\nEOF' "a12" "arnes-juan:desarrollador")"
# Ni la here-string ni la aritmetica son heredocs, y solas no escriben nada.
check "heredoc: una here-string sola no lo es -> allow" allow guard-codigo.sh \
  "$(emite_bash 'cat <<< "hola"' "" "")"
check "heredoc: la aritmetica \$((1<<n)) sola no lo es -> allow" allow guard-codigo.sh \
  "$(emite_bash 'echo $((1<<n))' "" "")"
# RENDIMIENTO (CA-28): un cuerpo de 10.000 lineas se analiza con expansion de parametros,
# sin un proceso por linea. Umbral 5 s: un hook PreToolUse muere a los 60 s y un hook
# muerto no deniega, asi que el margen tiene que ser amplio, no justo.
# CA-28: cuerpo de 10.000 lineas SIN expansiones. Es el camino BARATO —el cuerpo entero
# se descuenta—, asi que este caso NO acredita el coste del camino caro: ver el de abajo.
cronometra_bash "heredoc sin citar: 10.000 lineas de cuerpo SIN expansiones -> allow" allow 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF' "$(yes 'linea de texto sin expansiones' | head -10000)")" "" "")"
# QA REQ-001 — HALLAZGO QA-003 (coste cuadratico del cuerpo CONSERVADO).
# Las lineas con `$(` ya no se descuentan: entran en el texto que analiza el detector, y
# el descuento de comillas es un bucle que RECONSTRUYE la cadena entera por cada par. Con
# 1.500 lineas de cuerpo (28 KB de comando) el hook no responde en 65 s. MEDIDO en Linux,
# WSL2, 2026-09-05: 1.30.2 respondia `deny` en 210 ms; la candidata no responde.
# Un hook PreToolUse muere a los 60 s, y UN HOOK MUERTO NO DENIEGA: el comando de este
# caso escribe de verdad en `src/robado.ts`. Es fallo en abierto por agotamiento.
#   500 lineas -> 5,5 s (1.30.2: 0,11 s) · 1.000 -> 40 s · 1.500 -> >65 s
cronometra_bash "heredoc sin citar: 1.500 lineas con expansion y comillas + escritura real -> deny" deny 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/robado.ts' "$(yes "\$(date) 'x' \"y\"" | head -1500)")" "" "")"
# DEV REQ-001 v2: el mismo camino caro, con el TRIPLE de cuerpo. Un umbral que solo se
# cumple en el tamano exacto que denuncio el defecto no acredita que el coste dejo de ser
# cuadratico: acredita que se movio el punto de ruptura. Con el descuento por fragmento
# el coste es lineal — medido en Linux/WSL2 2026-09-05: 500 lineas 110 ms, 1.000 211 ms,
# 1.500 211 ms, 5.000 511 ms (antes: 5,5 s / 40 s / >65 s).
# DEV REQ-001 v3 (nota, no toco el caso): con el presupuesto de 64 KiB estas 5.000 lineas
# (80 KB de material analizable) se deniegan POR TAMANO, no por ver la redireccion. Sigue
# siendo `deny` y sigue siendo correcto, pero el caso ya no acredita el analisis real: eso
# lo acredita el de 4.000 lineas de la seccion DEV v3, que cabe justo bajo el techo y
# EXIGE que el motivo nombre la ruta.
cronometra_bash "heredoc sin citar: 5.000 lineas con expansion y comillas + escritura real -> deny" deny 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/robado.ts' "$(yes "\$(date) 'x' \"y\"" | head -5000)")" "" "")"

# QA REQ-001 — HALLAZGO QA-001 (falso NEGATIVO nuevo, medido 2026-09-05).
# Conservar las lineas del cuerpo con `$(` mete SUS COMILLAS en el texto que analiza el
# detector, y el descuento de entrecomillado empareja por pares SOBRE TODO EL COMANDO. Una
# comilla impar en el cuerpo se empareja con la primera comilla del comando REAL que va
# despues del cierre y borra lo que queda en medio: la redireccion se evapora.
# Reproduccion: el shell CREA `src/robado.ts` (verificado ejecutandolo en un sandbox).
# 1.30.2: deny. Candidata: allow. Es la misma familia que este REQ vino a cerrar.
check "QA: comilla impar en el cuerpo NO puede desarmar la redireccion posterior -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(date) don\'t\nEOF\necho x > src/robado.ts && echo \'listo\'' "" "")"
check "QA: control, el mismo comando sin el heredoc delante -> deny" deny guard-codigo.sh \
  "$(emite_bash $'echo x > src/robado.ts && echo \'listo\'' "" "")"
check "QA: la misma comilla impar con acento grave en el cuerpo -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n`date` don\'t\nEOF\ncp README.md src/a.ts && echo \'ok\'' "" "")"
check "QA: control, cuerpo con expansion y comillas PARES -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(date) \'hoy\'\nEOF\necho x > src/robado.ts && echo \'listo\'' "" "")"
# QA REQ-001 — HALLAZGO QA-004 (falso POSITIVO nuevo). La linea entera se analiza como
# comando por llevar UNA expansion, asi que el TEXTO que la acompana vuelve a leerse como
# orden: es el falso positivo de 1.29.1 otra vez, ahora con `$(` en la linea. En el shell
# real solo se expande `$(date)`; no se copia nada. 1.30.2: allow. Candidata: deny.
check "QA: cuerpo con \$(date) y una mencion TEXTUAL de cp no es una escritura -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nver $(date) y luego cp README.md src/x.ts\nEOF' "" "")"
check "QA: control, cuerpo con \$(date) y sin rutas -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nver $(date) y nada mas\nEOF' "" "")"

# DEV REQ-001 v2: la frontera que cierra QA-001/QA-002/QA-003 no es "el cuerpo", es CADA
# FRAGMENTO EJECUTABLE. Del cuerpo sin citar se conserva solo el interior de `$( )` y de
# los acentos graves, cada uno desentrecomillado por separado y unido con `;`. Estos casos
# fijan las tres consecuencias, para que un arreglo futuro no las deshaga en silencio.
#
# 1) Una comilla impar de UN fragmento tampoco puede desarmar a OTRO fragmento del mismo
#    cuerpo: la frontera es por fragmento, no solo entre cuerpo y comando real.
check "DEV: comilla impar en un fragmento NO desarma otro fragmento del cuerpo -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo don\'t)\n$(echo x > src/f2.ts)\nEOF' "" "")"
# 2) ...y el operando de un fragmento no se lee como destino del comando del anterior: sin
#    el separador, el `cp` seguiria buscando destino dentro del fragmento siguiente.
check "DEV: el destino de un cp no cruza al fragmento siguiente -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(cp README.md)\n$(echo src/x.ts)\nEOF' "" "")"
# 3) El falso positivo de QA-003 tampoco depende del ORDEN: la mencion textual delante de
#    la expansion sigue siendo texto.
check "DEV: mencion textual ANTES de la expansion sigue siendo texto -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\ncp README.md src/x.ts es lo que hace $(date)\nEOF' "" "")"
# 4) DENTRO de la expansion las comillas SI son sintaxis, como en el shell real: `echo` con
#    la redireccion entrecomillada imprime texto, no redirige. El par deny/allow es lo que
#    acredita que el descuento por fragmento no se volvio ciego.
check "DEV: comillas DENTRO de la expansion siguen siendo sintaxis -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \'x > src/a.ts\')\nEOF' "" "")"
check "DEV: control, la misma expansion SIN comillas -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/a.ts)\nEOF' "" "")"
# 5) La limitacion declarada tiene un borde util: una sustitucion que abre en una linea y
#    no cierra en ella aporta el resto de SU linea, asi que el comando que la abre se ve.
check "DEV: sustitucion que abre en una linea y cierra en otra -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/multi.ts\n)\nEOF' "" "")"

# QA REQ-001 v2 — RE-VALIDACION (vuelta 1 del bucle dev<->QA, 2026-09-05).
# Los tres hallazgos de la vuelta 1 se verificaron con sondas propias, no solo con el
# banco. Estos casos fijan la conducta ARREGLADA por sus BORDES, que es donde un arreglo
# futuro la deshace en silencio. Todos verdes hoy; si alguno se pone rojo, la frontera
# "cada fragmento ejecutable se desentrecomilla aislado" volvio a romperse.
#
# 1) Comillas CRUZADAS entre dos fragmentos del MISMO cuerpo: una comilla impar en el
#    primer fragmento no puede emparejarse con una del segundo y borrar la escritura.
check "QA v2: comilla simple impar cruzada entre dos fragmentos -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo a\')\n$(echo x > src/v1.ts)\nEOF' "" "")"
check "QA v2: comilla doble impar cruzada entre dos fragmentos -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo "a)\n$(echo x > src/v2.ts)\nEOF' "" "")"
# 2) Acento grave IMPAR en el cuerpo: no puede tragarse el comando real posterior.
check "QA v2: acento grave impar en el cuerpo NO desarma la escritura posterior -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nhola `date\nEOF\necho x > src/v3.ts' "" "")"
# 3) La comilla impar en el comando REAL, ANTES del heredoc: el descuento del comando
#    real sigue siendo de una pieza, y una comilla suya sin pareja no borra la escritura.
check "QA v2: comilla impar en el comando real ANTES del heredoc -> deny" deny guard-codigo.sh \
  "$(emite_bash $'echo \'abre\ncat <<EOF\n$(date)\nEOF\necho x > src/v4.ts' "" "")"
# 4) Un fragmento que TERMINA en `;` no deja al detector buscando operando en el siguiente.
check "QA v2: fragmento que termina en ';' no cruza al siguiente -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo hola;)\n$(echo x > src/v5.ts)\nEOF' "" "")"
check "QA v2: control, cp sin destino + ruta en el fragmento siguiente -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(cp README.md;)\n$(echo src/v6.ts)\nEOF' "" "")"
# 5) El detector COMPLETO tiene que seguir vivo DENTRO de la expansion, no solo `>` y `cp`.
#    Sin estos, un arreglo podria recortar el fragmento y dejar mudas las otras formas.
check "QA v2: install dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(install -m 644 README.md src/v7.ts)\nEOF' "" "")"
check "QA v2: perl -pi dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(perl -pi -e s/a/b/ src/v8.ts)\nEOF' "" "")"
check "QA v2: dd of= dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(dd if=/dev/zero of=src/v9.ts)\nEOF' "" "")"
check "QA v2: mv dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(mv README.md src/v10.ts)\nEOF' "" "")"
# 6) Operadores dentro de la expansion: el fragmento se tokeniza como comando de verdad.
check "QA v2: '&&' dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(true && echo x > src/v11.ts)\nEOF' "" "")"
check "QA v2: tuberia a tee dentro de la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(cat README.md | tee src/v12.ts)\nEOF' "" "")"
# 7) La LINEA QUE ABRE el heredoc no es cuerpo: su redireccion se sigue viendo.
check "QA v2: redireccion en la linea que abre el heredoc -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF > src/v13.ts\ntexto\nEOF' "" "")"
check "QA v2: 'cat > ruta <<EOF' -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat > src/v14.ts <<EOF\ntexto\nEOF' "" "")"

# QA REQ-001 v2 — HALLAZGO QA-007 (`contrato`, BLOQUEA): el coste dejo de ser cuadratico
# en el NUMERO DE LINEAS del cuerpo, pero sigue siendolo en el TAMANO DE UNA LINEA. El
# punto de ruptura se movio de eje, no desaparecio. MEDIDO en Linux/WSL2 2026-09-05 con
# una sola linea de cuerpo y N expansiones `$(date)`, mas la escritura real FUERA del
# heredoc (`echo x > src/...`):
#   N=500 -> 210 ms · 1.000 -> 411 ms · 2.000 -> 1,3 s · 4.000 -> 5,1 s ·
#   8.000 -> 18,0 s · 12.000 -> 41,1 s · 16.000 -> NO RESPONDE en 60 s
# Contra v1.30.2 la misma entrada responde `deny` en 213 ms con N=20.000 (plana): es una
# REGRESION del arreglo, no una limitacion heredada. A los 60 s el hook muere, la salida
# sale VACIA y `guard.sh` permite: verificado en un sandbox, el shell CREA `src/qa7.ts`.
# Umbral el del REQ (CA-40/CA-48): menos de 5 s. Se usa N=8.000 —no 4.000, que cae
# JUSTO sobre el umbral (5,0 s medidos) y daria un caso flaky— para que el resultado sea
# el mismo en cada corrida: el `timeout` duro lo corta a los 10 s y el caso reporta
# `got=allow`, que es LA VERDAD del defecto (hook cortado = hook que no deniega).
# Cuando el coste sea lineal, 8.000 expansiones deben resolverse muy por debajo de 1 s.
cronometra_bash "QA v2: UNA linea de cuerpo con 8.000 expansiones + escritura real -> deny" deny 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(yes '$(date)' | head -8000 | tr -d '\n')")" "" "")"
# Control del caso de arriba: la MISMA escritura sin el cuerpo delante se resuelve al
# instante. Sin el, un `deny` lento no distingue "el cuerpo cuesta" de "la sonda es lenta".
cronometra_bash "QA v2: control, la misma escritura sin el cuerpo delante -> deny" deny 5000 \
  "$(emite_bash 'echo x > src/qa7.ts' "" "")"

check "coordinadora: redirige un log fuera de los globs -> allow" allow guard-codigo.sh "$(emite_bash 'npm run build > /tmp/build.log 2>&1' "" "")"
check "qa-tester escribe en tests/ (no es código de app) -> allow" allow guard-codigo.sh "$(emite_bash 'echo x > tests/a.test.ts' "a11" "arnes-juan:qa-tester")"

# --- Clase del hallazgo: la unica puerta que existe para DEJAR PASAR ------------
# Un defecto del propio arnes no puede impedir cerrar una funcion de negocio.
