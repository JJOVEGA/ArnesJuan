# Sección 25 del banco — 25-presupuesto-de-analisis
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=42

  seccion_nueva "DEV REQ-001 v3: presupuesto de analisis y coste lineal (QA-007):"
# ============================================================================
# DEV REQ-001 v3 — el eje que quedaba de QA-007 y el presupuesto que lo tapa.
#
# QA-007 midio que el coste seguia siendo CUADRATICO en el tamano de UNA linea del
# cuerpo: 4.000 expansiones 5,1 s (rompe CA-40/CA-48), 8.000 18,0 s, 16.000 NO RESPONDE
# en 60 s -> el hook muere, `guard.sh` recibe salida vacia y PERMITE. La causa medida:
# avanzar con `${r#*...}` COPIA el resto de la cadena en cada paso.
#
# Arreglo: el texto se PARTE UNA VEZ (troceado por IFS, dentro de bash, sin procesos) y
# los trozos se unen UNA vez. Nada se copia por paso. MEDIDO en Linux/WSL2 2026-09-05,
# de punta a punta con `guard-codigo.sh`, una linea de N expansiones + escritura real:
#   N     antes (vuelta 1)        ahora
#   500   210 ms                  212 ms
#   2.000 1.313 ms                212 ms
#   4.000 5.118 ms                410 ms
#   8.000 18.037 ms               814 ms
#  16.000 >60 s -> ALLOW          212 ms (deny por presupuesto)
#
# Y ADEMAS EL PRESUPUESTO. Un algoritmo lineal tambien tiene acantilado: basta una
# entrada 100 veces mayor. Por eso, por encima de `ARNES_BASH_MAX_ANALISIS` (64 KiB de
# MATERIAL ANALIZADO, ver lib.sh) el hook no analiza y DENIEGA diciendo como salir.
# Falla cerrado y a tiempo, en vez de abierto y por agotamiento.
# ============================================================================

# --- 1) El eje de QA-007, en el tamano que antes mataba al hook ---------------
# 16.000 expansiones en UNA linea. Antes: sin respuesta en 60 s -> salida vacia -> allow
# -> el shell creaba `src/qa7.ts` (verificado en sandbox por QA). Ahora: deny inmediato.
cronometra_bash "DEV v3: UNA linea con 16.000 expansiones + escritura real -> deny" deny 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(yes '$(date)' | head -16000 | tr -d '\n')")" "" "")"
# Control obligatorio: sin el, un deny rapido no distingue "el arreglo funciona" de
# "la sonda no llego a construir el caso".
cronometra_bash "DEV v3: control, la misma escritura sin el cuerpo -> deny" deny 5000 \
  "$(emite_bash 'echo x > src/qa7.ts' "" "")"

# --- 2) La frontera del presupuesto, medida al byte ---------------------------
# El presupuesto cuenta (a) los bytes de las lineas del cuerpo SIN CITAR que llevan
# expansion y (b) los bytes del comando fuera de los cuerpos. Aqui (b) son 29 bytes
# (`cat <<EOF` + `echo x > src/qa7.ts`; la linea del delimitador de cierre no cuenta),
# asi que la frontera exacta esta en una linea de cuerpo de 65.507 bytes. MEDIDO: 65.507
# se analiza, 65.508 se deniega por tamano. Los dos casos DENIEGAN — lo que se comprueba
# es POR QUE, que es justo lo que un `deny` a secas no distingue.
cuerpo_de() {   # <bytes> -> una linea de cuerpo de exactamente ese tamano, densa en `$(date)`
  local n="$1" u='$(date)' s r
  s="$(yes "$u" | head -$(( n / ${#u} )) | tr -d '\n')"
  r=$(( n - ${#s} ))
  printf '%s%s' "$s" "$(printf '%*s' "$r" '' | tr ' ' 'a')"
}
check_motivo "DEV v3: 1 byte POR DEBAJO del presupuesto -> analiza y nombra la ruta" \
  "escribe en 'src/qa7\.ts'" guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 65507)")" "" "")"
check_motivo "DEV v3: 1 byte POR ENCIMA del presupuesto -> deny por tamano, con salida" \
  "demasiado grande para analizarlo con garantia.*heredoc CITADO" guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 65508)")" "" "")"

# --- 3) El presupuesto NO toca el camino legitimo -----------------------------
# Escribir un archivo grande con un heredoc CITADO es la forma normal de hacerlo y la
# usan todos los agentes: el cuerpo se descuenta entero sin analizarse. 300 KB tienen
# que seguir siendo `allow` y seguir siendo baratos. Si el presupuesto se hubiera puesto
# sobre el TAMANO DEL COMANDO, este caso se habria vuelto rojo — y con el, el trabajo
# normal de todo el mundo.
GRANDE_CITADO="$(yes 'texto de relleno de cien bytes para llegar a trescientos kilobytes sin ninguna expansion aqu' | head -3000)"
cronometra_bash "DEV v3: heredoc CITADO de ~300 KB -> allow y barato" allow 1000 \
  "$(emite_bash "$(printf "cat > docs/x.md <<'EOF'\n%s\nEOF" "$GRANDE_CITADO")" "" "")"
# CA-28 en grande: sin citar pero SIN expansiones, el cuerpo tambien se descuenta entero.
cronometra_bash "DEV v3: heredoc SIN citar de ~300 KB SIN expansiones -> allow" allow 5000 \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF' "$GRANDE_CITADO")" "" "")"
# CONTROL POSITIVO de los dos de arriba: un `allow` sobre una entrada de 300 KB tambien
# lo produce un hook que murio. Con la MISMA entrada mas una escritura real fuera del
# heredoc, el hook tiene que seguir denegando.
check "DEV v3: control, los mismos 300 KB citados + escritura real -> deny" deny guard-codigo.sh \
  "$(emite_bash "$(printf "cat > docs/x.md <<'EOF'\n%s\nEOF\necho x > src/grande.ts" "$GRANDE_CITADO")" "" "")"

# DEV 1.31.0 v3 (QA-111): LO QUE EL CASO DE ARRIBA QUERIA ACREDITAR, SIN RELOJ.
# «El heredoc citado se descuenta ENTERO y no entra en el presupuesto de analisis» es una
# propiedad DISCRETA, y hasta v3 se comprobaba de la peor forma posible: cronometrando.
# Se comprueba directamente, y por el MOTIVO, que es donde el hook dice por que decidio:
#   - si los 300 KB citados hubieran entrado en el presupuesto (64 KiB), la respuesta
#     seria el deny POR TAMANO, no el deny por la ruta;
#   - que el motivo NOMBRE la ruta prueba ademas que el analisis SI corrio y SI vio la
#     escritura de fuera del heredoc — un hook muerto no nombra ninguna ruta.
# Los dos hechos juntos son exactamente la propiedad, y ninguno depende de la carga de
# la maquina. El caso cronometrado de arriba se queda como MEDICION del coste.
check_motivo "DEV 1.31.0 v3: QA-111 los 300 KB CITADOS se descuentan enteros: deny POR LA RUTA" \
  "escribe en 'src/grande\.ts'" guard-codigo.sh \
  "$(emite_bash "$(printf "cat > docs/x.md <<'EOF'\n%s\nEOF\necho x > src/grande.ts" "$GRANDE_CITADO")" "" "")"
# La otra mitad, explicita: el motivo NO puede ser el del presupuesto. Sin este control,
# un dia en que el descuento se rompa el caso de arriba seguiria en rojo pero nadie
# sabria si es por tamano o por otra cosa; y si ademas cambiara el orden de las puertas,
# un deny por tamano podria colarse como acierto.
MOT_CIT="$(corre guard-codigo.sh "$(emite_bash "$(printf "cat > docs/x.md <<'EOF'\n%s\nEOF\necho x > src/grande.ts" "$GRANDE_CITADO")" "" "")" | jq -r '.hookSpecificOutput.permissionDecisionReason // empty' 2>/dev/null)"
if printf '%s' "$MOT_CIT" | grep -q 'demasiado grande para analizarlo'; then
  echo "  FAIL  DEV 1.31.0 v3: QA-111 ...y NO por el presupuesto de analisis  motivo=<${MOT_CIT:0:120}>"; diag; FAIL=$((FAIL+1))
else
  echo "  PASS  DEV 1.31.0 v3: QA-111 ...y NO por el presupuesto de analisis"; PASS=$((PASS+1))
fi

# --- 4) Lineal tambien en LINEAS, con analisis de verdad ----------------------
# 4.000 lineas de cuerpo con expansion y comillas son 64.000 bytes: caben JUSTO bajo el
# presupuesto, asi que este caso mide el analisis real y no el atajo del techo. Que el
# motivo nombre la ruta es lo que lo acredita.
check_motivo "DEV v3: 4.000 lineas de cuerpo bajo el presupuesto -> analiza y nombra la ruta" \
  "escribe en 'src/robado\.ts'" guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/robado.ts' "$(yes "\$(date) 'x' \"y\"" | head -4000)")" "" "")"

# --- 5) El presupuesto tambien cierra la puerta del CIERRE DE REQ -------------
# `guard-completado` comparte el detector. Si no mira el codigo de salida, una entrada
# sobre el techo le llega como "no escribe nada" -> allow, que es el fallo en abierto de
# siempre por otra puerta. Aqui la denegacion alcanza a TODOS los agentes, porque la
# regla que aplica este guardian tambien alcanza a todos.
check_motivo "DEV v3: sobre el presupuesto, guard-completado deniega por tamano" \
  "demasiado grande para analizarlo con garantia" guard-completado.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\nsed -i s/x/y/ requirements/REQ-001.md' "$(cuerpo_de 70000)")" "" "")"
# ...y NO alcanza al agente de codigo por la puerta de `guard-codigo`: a el ya se le
# permitia escribir, asi que el techo no le quita nada.
check "DEV v3: sobre el presupuesto, guard-codigo NO estorba al desarrollador -> allow" allow guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 70000)")" "a1" "arnes-juan:desarrollador")"
check "DEV v3: ...y al qa-tester si -> deny" deny guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 70000)")" "a2" "arnes-juan:qa-tester")"

# --- 6) La clave opcional del manifiesto --------------------------------------
# `limites.bash_max_analisis` es OPCIONAL: el defecto vive en el codigo y ningun
# proyecto tiene que declararla. Se prueba en las dos direcciones, porque una clave que
# solo se lee cuando conviene no se esta leyendo.
setcfg '.limites = {bash_max_analisis: 4194304}'
check_motivo "DEV v3: con el techo subido en el manifiesto, la misma entrada SI se analiza" \
  "escribe en 'src/qa7\.ts'" guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 70000)")" "" "")"
# ...y la clave solo puede SUBIR el techo, nunca bajarlo por debajo del que trae el
# codigo: el manifiesto se lee con `jq` y el camino comun no puede pagar un proceso por
# comando, asi que el defecto se aplica sin preguntar. Un techo de 64 bytes escrito a
# mano NO convierte en "no analizable" un comando que la puerta sabe analizar.
setcfg '.limites = {bash_max_analisis: 64}'
check_motivo "DEV v3: el manifiesto NO puede bajar el techo por debajo del defecto" \
  "escribe en 'src/qa7\.ts'" guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(date) una linea corta pero de mas de sesenta y cuatro bytes de largo\nEOF\necho x > src/qa7.ts' "" "")"
# Una errata en el manifiesto NO puede desactivar la puerta: valor no numerico -> manda
# el defecto del codigo, y una entrada normal se sigue analizando.
setcfg '.limites = {bash_max_analisis: "mucho"}'
check_motivo "DEV v3: techo con errata -> manda el defecto del codigo, no se desactiva nada" \
  "escribe en 'src/qa7\.ts'" guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/qa7.ts)\nEOF' "" "")"
# QA 1.31.0: HALLAZGO QA-103 — el motivo del techo imprime el NOMBRE de la variable en
# vez de su valor (`\$ARNES_BASH_MAX_MANIFIESTO` va escapado en guard-codigo.sh:88 y en
# guard-completado.sh:54). Quien lee la denegacion no sabe hasta donde puede subir el
# techo. Un deny que no se puede accionar es un deny a medias.
check_motivo "QA-103 el motivo del techo imprime el maximo en BYTES, no el nombre de la variable" \
  "hasta un maximo de 131072 bytes" guard-codigo.sh \
  "$(emite_bash "$(printf 'echo "%s" > src/qa103.ts' "$(printf 'a%.0s' $(seq 1 70000))")" "" "")"
setcfg 'del(.limites)'

# --- 7) QA-013: `\$(` escapado no es una sustitucion --------------------------
# bash imprime el texto literal y no ejecuta nada, asi que denegarlo era un falso
# positivo en un detector cuyo sesgo declarado es el contrario. Se cuenta la barra
# invertida por PARIDAD: `\$(` no ejecuta, `\\$(` SI (la primera barra escapa a la
# segunda). Los tres casos juntos son la prueba; uno solo no lo seria.
check "DEV v3: QA-013, \$( escapado en el cuerpo -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n\\$(cp README.md src/f3.ts)\nEOF' "" "")"
check "DEV v3: QA-013, barra ESCAPADA antes de \$( (bash si ejecuta) -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n\\\\$(cp README.md src/f3.ts)\nEOF' "" "")"
check "DEV v3: QA-013, control, sin barra ninguna -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(cp README.md src/f3.ts)\nEOF' "" "")"

# --- 8) QA REQ-001 v3: HALLAZGO QA-015 ---------------------------------------
# El recorte por fragmento toma el prefijo hasta el PRIMER `)` (`${p[i]%%')'*}`), sin
# mirar comillas ni anidamiento. Todo lo que venga DESPUES de ese `)` dentro de la misma
# sustitucion se pierde — incluida la redireccion. Los tres casos siguientes crean el
# archivo en un shell REAL (verificado en sandbox por QA) y hoy salen `allow`.
#
# NO es limitacion heredada: el arbol `6cb348a`, ANTERIOR al primer arreglo de este
# mismo REQ, DENIEGA los tres (alli se conservaba la LINEA entera). El comentario de
# `_arnes_expansiones` afirma del anidamiento "Es mas cobertura, nunca menos": medido,
# es menos. Ver docs/qa/REQ-001.md §8.
check "QA v3: expansion ANIDADA, la escritura va tras el ) interior -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(cat "$(ls README.md)" > src/n12.ts)\nEOF' "" "")"
check "QA v3: un ) dentro de comillas trunca el fragmento -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo "a)b" > src/n3.ts)\nEOF' "" "")"
check "QA v3: parentesis literal entrecomillado en la expansion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo "(hola)" > src/n10.ts)\nEOF' "" "")"
# Controles obligatorios: sin ellos un deny futuro no distingue "se arreglo el recorte"
# de "se volvio a analizar la linea entera", que es el falso positivo de 1.29.1.
check "QA v3: control, la misma expansion SIN ) interior -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/n9.ts)\nEOF' "" "")"
check "QA v3: control, la misma forma SIN heredoc ya se detecta -> deny" deny guard-codigo.sh \
  "$(emite_bash $'echo $(echo "a)b" > src/n3.ts)' "" "")"
check "QA v3: control, el acento grave NO trunca en el ) -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n`echo "a)b" > src/bt.ts`\nEOF' "" "")"
# Control de FALSO POSITIVO (CA-49): el texto que sigue al cierre REAL de la expansion
# sigue siendo texto y no puede volver a leerse como comando.
check "QA v3: control CA-49, texto tras el cierre real de la expansion -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\nver $(basename "$(pwd)") y luego cp README.md src/x.ts\nEOF' "" "")"

# --- 9) DEV REQ-001 v4: el cierre se decide por PROFUNDIDAD, no por el primer ) -----
# El arreglo de QA-015 no consiste en "mirar tambien las comillas": consiste en que el
# fragmento termina donde la profundidad de parentesis vuelve a cero, contando solo los
# parentesis que NO estan entrecomillados. Estos cuatro casos fijan las cuatro esquinas
# de esa regla; sin ellos, un arreglo futuro podria volver a cortar en el primer `)` y
# solo se enterarian los tres casos de QA-015.
#
# (a) El `)` INTERIOR de una sustitucion anidada no cierra la exterior, y la escritura
#     puede estar en el interior: el fragmento de fuera se la lleva igual.
check "DEV v4: anidada con la escritura DENTRO del interior -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(x $(echo y > src/w1.ts) z)\nEOF' "" "")"
# (b) Las comillas SIMPLES tapan el `)` igual que las dobles. Se prueban las dos formas
#     porque el descuento las trata por separado y una sola no acredita a la otra.
check "DEV v4: un ) entre comillas SIMPLES no cierra el fragmento -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \'a)b\' > src/w2.ts)\nEOF' "" "")"
# (c) Desbalanceado: si la profundidad NUNCA vuelve a cero, el fragmento es el resto de
#     la linea. Es fail-closed a proposito, y aqui SOBREDETECTA: verificado en un sandbox
#     real, bash NO ejecuta esta linea (la sustitucion no cierra y es un error de
#     sintaxis), asi que no crea el archivo. Se deniega igual porque el hook trabaja
#     LINEA A LINEA y una sustitucion abierta puede cerrar en la siguiente, que es la
#     limitacion declarada en `_arnes_expansiones`, y entonces su interior SI se ejecuta
#     (caso `DEV: sustitucion que abre en una linea y cierra en otra`, mas arriba). El
#     sesgo del detector es al falso negativo, y este es el sitio exacto donde no se
#     acepta pagarlo.
check "DEV v4: parentesis que nunca cierra + escritura despues -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(foo ( bar) cp README.md src/w3.ts\nEOF' "" "")"
# (d) ...y el reverso, que es el que impide "arreglarlo" analizando la linea entera: el
#     cierre REAL es el primer `)` cuando no hay nada abierto, y lo que sigue —parentesis
#     literales incluidos— es TEXTO. Sin este caso, (c) invita al falso positivo de 1.29.1.
check "DEV v4: (texto) tras el cierre real sigue siendo texto -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(date) (texto) cp README.md src/x.ts\nEOF' "" "")"
# (e) La paridad de la barra invertida vale para TODOS los caracteres con significado, no
#     solo para `$(`: un `\)` es un parentesis LITERAL y no cierra nada. Verificado en un
#     sandbox real: bash CREA `src/w4.ts`. Sin este caso, el arreglo de QA-015 dejaba
#     abierta la misma puerta por el lado del escapado. El control es obligatorio: sin la
#     barra, ese `)` SI cierra y lo de detras vuelve a ser texto.
check "DEV v4: un ) ESCAPADO no cierra el fragmento -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \\) > src/w4.ts)\nEOF' "" "")"
check "DEV v4: control, el mismo ) SIN escapar si cierra -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo ) > src/w4.ts)\nEOF' "" "")"

# --- 10) DEV REQ-001 v4: QA-016, el deny por tamano dice CUANTO ---------------------
# CA-53 pide que el motivo diga cual es el presupuesto. Decir "es demasiado grande" sin
# el numero deja a quien lo recibe partiendo el comando a ciegas. El numero sale del
# techo EFECTIVO (`arnes_techo_bash`), no de una constante escrita en el mensaje: si el
# manifiesto lo sube, el mensaje sube con el. Se comprueba en las dos puertas.
check_motivo "DEV v4: el deny por tamano dice el presupuesto en bytes (guard-codigo)" \
  "presupuesto de analisis vigente es de 65536 bytes" guard-codigo.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\necho x > src/qa7.ts' "$(cuerpo_de 65508)")" "" "")"
check_motivo "DEV v4: ...y tambien lo dice guard-completado" \
  "presupuesto de analisis vigente es de 65536 bytes" guard-completado.sh \
  "$(emite_bash "$(printf 'cat <<EOF\n%s\nEOF\nsed -i s/x/y/ requirements/REQ-001.md' "$(cuerpo_de 70000)")" "" "")"
# --- 11) QA REQ-001 v4: la familia de QA-015, contrastada con el shell REAL ---------
# Re-validacion, vuelta 3 (docs/qa/REQ-001.md §9). Cada uno de estos casos se comparo
# en un sandbox con lo que bash hace DE VERDAD (crea o no crea el archivo), y el
# veredicto exigido es el que coincide con esa medida — salvo donde la sobredeteccion
# se declara a proposito. Sin ese contraste, un `deny` solo prueba que la sonda dispara.
#
# (a) Un `)` Y un `$(` dentro de comillas SIMPLES. Bash no ejecuta lo entrecomillado
#     pero SI la redireccion de fuera: medido, CREA `src/v1.ts`. Es la union de las dos
#     esquinas que el arreglo trata por separado (comillas y profundidad).
check "QA v4: \$( y ) entre comillas simples, la escritura fuera -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \'$(cp README.md src/z1.ts)\' > src/v1.ts)\nEOF' "" "")"
# (b) Aritmetica DENTRO de la sustitucion: `$((` aporta DOS aperturas y `))` dos cierres.
#     Si la cuenta de profundidad se descuadrara aqui, el fragmento cerraria antes de la
#     redireccion. Medido: bash CREA `src/v3.ts`.
check "QA v4: aritmetica \$(( )) dentro de la sustitucion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo $((1+2)) > src/v3.ts)\nEOF' "" "")"
# (c) Dos sustituciones en la MISMA linea: la primera cierra limpia y la segunda escribe.
#     Comprueba que cerrar un fragmento no deja de mirar lo que viene detras.
check "QA v4: dos sustituciones, la primera cierra y la segunda escribe -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(date) y $(cp README.md src/v4.ts)\nEOF' "" "")"
# (d) El `)` entre comillas simples en su forma minima, `\')\'`. Medido: CREA `src/v5.ts`.
check "QA v4: un ) solo entre comillas simples no cierra -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \')\' > src/v5.ts)\nEOF' "" "")"
# (e) EL OTRO LADO DE LA PARIDAD del caso `DEV v4: un ) ESCAPADO no cierra`: con DOS
#     barras la primera escapa a la segunda, el `)` es REAL y cierra. Medido: bash no
#     crea nada, y `> src/v6.ts` queda fuera de la sustitucion, como texto del cuerpo.
#     Un arreglo que "denegara por si acaso" ante cualquier barra pondria esto en rojo.
check "QA v4: con \\\\) la barra se escapa a si misma y el ) SI cierra -> allow" allow guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo \\\\) > src/v6.ts)\nEOF' "" "")"
# (f) Comilla IMPAR dentro de la sustitucion: no se puede descontar sin inventarse un
#     cierre, asi que el fragmento se lleva el resto de la linea y la redireccion cae
#     dentro. SOBREDETECTA a proposito (bash da error de sintaxis y no crea nada): es la
#     direccion obligatoria, la misma de `DEV v4: parentesis que nunca cierra`.
check "QA v4: comilla impar dentro de la expansion -> deny (fail-closed)" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo "a > src/v2.ts)\nEOF' "" "")"
# (g) LIMITACION DECLARADA, no defecto de esta version: una sustitucion ANIDADA dentro de
#     COMILLAS DOBLES se descuenta con las comillas y no se ve. Bash SI ejecuta el `cp`
#     (medido: crea `src/g2.ts`), y ni siquiera hace falta un heredoc. Es la familia de
#     QA-006 —lo entrecomillado se descuenta antes de analizar—, medida `allow` en la
#     candidata Y en v1.30.2: preexistente, no regresion, y su trabajo vive en REQ-007.
#     El caso esta aqui para que el hueco sea VISIBLE y para que el dia que REQ-007 lo
#     cierre alguien tenga que venir a cambiarlo a `deny` a mano, en vez de descubrirlo.
check "QA v4: LIMITACION QA-006/REQ-007, sustitucion dentro de comillas dobles -> allow" allow guard-codigo.sh \
  "$(emite_bash $'echo "$(cp README.md src/g2.ts)"' "" "")"
