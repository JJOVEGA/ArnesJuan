# ---------- 37 (6) · EL JUEZ DE LAS SONDAS DE COSTE, SOBRE VECTORES FIJOS ----------
# REQ-030 CA-06. Las pruebas SINTÉTICAS del evaluador: vectores fijos, sin reloj, en
# milisegundos y en CUALQUIER modo del banco. Ejercen las dos funciones que DECIDEN los
# casos de 37/2 y 37/5 —`sonda_juez_duplicacion` (CA-03) y `sonda_juez_razon` (CA-08 (ii) y
# los controles de 37/7)—, que viven UNA vez en el corredor: aquí no hay copia que pueda
# pasar mientras la que decide se desvía. Las pruebas de MEDICIÓN (sujetos idénticos,
# envoltorio y demora fija) son otra clase y viven en 37/7, a demanda.
#
# UN CASO POR JUEZ, y sus PASS/FAIL internos NO suman al banco (CA-06 (a)): cada vector corre
# dentro de una sustitución de comandos y sólo se compara su línea; el banco cuenta del TEXTO
# y aquí sólo llega la línea del caso agregado.
#
# LAS LISTAS SE ESCRIBEN CON CINCO REPETICIONES LITERALES, no con `SONDA_COSTE_R`: el «de 5»
# es de contrato (REQ-030 CA-01) y un vector que se adaptara al presupuesto no vería que
# alguien lo cambió. Las razones en milésimas, con división entera, como el juez.
CASOS_ESPERADOS_SECCION=2
PISO_AUTONOMO_SECCION=78  # 18 preámbulo (líneas 1-18) + 0 maquinaria compartida duplicada (el juez vive en el corredor) + 60 bloque indivisible mayor (el comparador v46 y el caso del juez de CA-08 (ii), líneas 20-79) · REQ-014 CA-18
seccion_nueva "--- 37/6 · el juez de las sondas de coste sobre vectores fijos (REQ-030 CA-06) ---"

# v46 <etiqueta> <esperado: PASS|FAIL|INCONCLUSO> <salida del juez> — anota en MAL46 lo que no
# casa. Exige UNA línea, el nombre del caso tal cual, la marca tras el nombre en el
# inconcluso y el denominador «de 5» en TODA salida (CA-01 (a), CA-04).
MAL46=''; N46=0
v46() {
  local etq="$1" esp="$2" sal="$3" got
  case "$sal" in
    *$'\n'*)                            got='VARIAS-LINEAS' ;;
    "  PASS  caso46  "*)                got=PASS ;;
    "  FAIL  caso46  "*)                got=FAIL ;;
    "  SKIP  caso46  [INCONCLUSO] "*)   got=INCONCLUSO ;;
    *)                                  got="OTRA<${sal:0:50}>" ;;
  esac
  case "$sal" in *" de 5"[" ):"]*) ;; *) got="$got-SIN-DE-5" ;; esac
  N46=$((N46 + 1))
  [ "$got" = "$esp" ] || MAL46+="[$etq: esperado $esp, obtuvo $got] "
}
r5() { printf '%s %s %s %s %s' "$1" "$1" "$1" "$1" "$1"; }   # la misma repetición, cinco veces
x4='x:x:x:x'

# ---- CA-08 (ii): sonda_juez_razon, repeticiones 'mín este:2.º mín este:mín ref:2.º mín ref' (µs)
nom46="REQ-030 CA-06 el juez de CA-08 (ii) sobre vectores fijos: fronteras, no resueltas, mezclas y el ensayo local"
if [ -z "$FILTRO" ] || printf '%s' "$nom46" | grep -qi -- "$FILTRO"; then
  MAL46=''; N46=0
  j46() { sonda_juez_razon caso46 1250 "$1" "${2:-}"; }
  v46 'r=1,250 en las 5 (la igualdad cumple)'      PASS       "$(j46 "$(r5 125000:126000:100000:101000)")"
  v46 'r=1,251 en las 5'                           FAIL       "$(j46 "$(r5 125100:126000:100000:101000)")"
  v46 'techo dentro del recorrido [1,000;1,300]'   INCONCLUSO "$(j46 '100000:101000:100000:101000 110000:111000:100000:101000 130000:131000:100000:101000 120000:121000:100000:101000 126000:127000:100000:101000')"
  v46 '3 resueltas <= techo y 2 sin registro'      PASS       "$(j46 "100000:101000:100000:101000 110000:111000:100000:101000 $x4 120000:121000:100000:101000 $x4")"
  v46 '2 resueltas bajo el techo'                  INCONCLUSO "$(j46 "100000:101000:100000:101000 110000:111000:100000:101000 $x4 $x4 $x4")"
  v46 'convergencia 1,250 en 3 resuelve'           PASS       "$(j46 "100000:125000:100000:101000 100000:125000:100000:101000 100000:101000:100000:125000 $x4 $x4")"
  v46 'convergencia 1,251 (este) no resuelve'      INCONCLUSO "$(j46 "100000:125100:100000:101000 100000:125100:100000:101000 100000:125100:100000:101000 $x4 $x4")"
  v46 'convergencia 1,251 (referencia) no resuelve' INCONCLUSO "$(j46 "100000:101000:100000:125100 100000:101000:100000:125100 100000:101000:100000:125100 $x4 $x4")"
  v46 'un mínimo de 49 999 µs no resuelve'         INCONCLUSO "$(j46 "100000:101000:100000:101000 110000:111000:100000:101000 100000:101000:49999:50500 $x4 $x4")"
  v46 'un mínimo de 50 000 µs sí resuelve'         PASS       "$(j46 "100000:101000:100000:101000 110000:111000:100000:101000 50000:50500:50000:50500 $x4 $x4")"
  v46 'las 5 sin registro (0 de 5)'                INCONCLUSO "$(j46 "$(r5 "$x4")")"
  v46 'lista con 3: las ausentes cuentan (de 5)'   PASS       "$(j46 '100000:101000:100000:101000 110000:111000:100000:101000 120000:121000:100000:101000')"
  v46 'un campo de más no es una repetición'       INCONCLUSO "$(j46 "$(r5 100000:101000:100000:101000:9)")"
  v46 'mezcla: 3 > techo, 1 sin registro, 1 sin converger' FAIL "$(j46 "126000:127000:100000:101000 130000:131000:100000:102000 140000:141000:100000:100500 $x4 100000:150000:100000:100100")"
  v46 'vector de demora (todas ≈ 1,6)'             FAIL       "$(j46 '160000:162000:100000:101000 158000:160000:100000:101000 165000:166000:100000:101000 161000:163000:100000:101000 159000:161000:100000:101000')"
  v46 'sin línea base'                             INCONCLUSO "$(j46 '' 'el árbol v1.32.1 no se pudo materializar (la-referencia-no-resuelve:v1.32.1)')"
  # Los 9 vectores del ensayo local (`sondas-coste/ensayo-local/juez-sintetico.sh`, rama de
  # evidencia), con la salida que la REGLA prescribe. En su vector 4 la expectativa estaba mal
  # escrita en el ensayo (3 resueltas todas <= techo): la regla da PASS, y así se fija aquí.
  v46 'ensayo 1'  PASS       "$(j46 '100000:105000:100000:102000 110000:112000:100000:101000 120000:121000:100000:103000 100000:100500:100000:100100 125000:126000:100000:100200')"
  v46 'ensayo 2'  FAIL       "$(j46 '126000:127000:100000:101000 130000:131000:100000:102000 140000:141000:100000:100500 128000:129000:100000:101000 135000:136000:100000:100100')"
  v46 'ensayo 3'  INCONCLUSO "$(j46 '120000:121000:100000:101000 130000:131000:100000:102000 110000:111000:100000:100500 126000:127000:100000:101000 100000:101000:100000:100100')"
  v46 'ensayo 4'  PASS       "$(j46 "100000:101000:100000:101000 110000:111000:100000:102000 $x4 $x4 100000:101000:100000:100100")"
  v46 'ensayo 4b' INCONCLUSO "$(j46 "100000:101000:100000:101000 110000:111000:100000:102000 $x4 $x4 $x4")"
  v46 'ensayo 5'  PASS       "$(j46 "100000:101000:100000:101000 110000:111000:100000:102000 $x4 105000:106000:100000:100500 100000:101000:100000:100100")"
  v46 'ensayo 6'  PASS       "$(j46 '100000:101000:100000:101000 110000:111000:100000:102000 100000:140000:100000:100500 105000:106000:100000:100500 100000:101000:100000:100100')"
  v46 'ensayo 7'  INCONCLUSO "$(j46 "100000:101000:40000:41000 110000:111000:100000:102000 100000:101000:100000:100500 $x4 $x4")"
  v46 'ensayo 8'  FAIL       "$(j46 "126000:127000:100000:101000 130000:131000:100000:102000 140000:141000:100000:100500 $x4 100000:150000:100000:100100")"
  v46 'ensayo 9'  INCONCLUSO "$(j46 "126000:127000:100000:101000 130000:131000:100000:102000 $x4 $x4 100000:150000:100000:100100")"
  if [ -z "$MAL46" ] && [ "$N46" -eq 26 ]; then
    echo "  PASS  $nom46  $N46 de 26 vectores con la salida que la regla prescribe"
  else
    echo "  FAIL  $nom46  $N46 vectores corridos (se esperaban 26); no casan: ${MAL46:-ninguno}"
  fi
fi

# ---- CA-03: sonda_juez_duplicacion, pares 'µs de S:µs de 2S' de este árbol y de v1.32.1
nom46="REQ-030 CA-06 el juez de CA-03 sobre vectores fijos: la calibración como precondición, fronteras y sin línea base"
if [ -z "$FILTRO" ] || printf '%s' "$nom46" | grep -qi -- "$FILTRO"; then
  MAL46=''; N46=0
  d46() { sonda_juez_duplicacion caso46 2600 "$1" "$2" "${3:-}"; }
  ok46="$(r5 100000:200000)"         # este árbol lineal: 2,000× en las 5
  cal46="$(r5 100000:350000)"        # calibración holgada: 3,500× en las 5
  v46 'calibración con 2 medidas, las dos > techo'  INCONCLUSO "$(d46 "$ok46" '100000:300000 100000:300000 x x x')"
  v46 'calibración con 3 medidas > techo: resuelve' PASS       "$(d46 "$ok46" '100000:300000 100000:300000 100000:300000 x x')"
  v46 'mín(heredada) = 2,600 no resuelve'           INCONCLUSO "$(d46 "$ok46" '100000:260000 100000:300000 100000:300000 100000:300000 100000:300000')"
  v46 'mín(heredada) = 2,601 resuelve'              PASS       "$(d46 "$ok46" '100000:260100 100000:300000 100000:300000 100000:300000 100000:300000')"
  v46 'calibración NO resuelta con este bajo el techo: nunca PASS' INCONCLUSO "$(d46 "$ok46" "$(r5 100000:200000)")"
  v46 'calibración NO resuelta con este sobre el techo: nunca FAIL' INCONCLUSO "$(d46 "$(r5 100000:400000)" "$(r5 100000:200000)")"
  v46 'calibración resuelta y este entero por encima' FAIL      "$(d46 "$(r5 100000:300000)" "$cal46")"
  v46 'máx(este) = 2,600 con calibración resuelta'  PASS       "$(d46 '100000:200000 100000:210000 100000:220000 100000:250000 100000:260000' "$cal46")"
  v46 'mín(este) = 2,601: FAIL por la mínima'      FAIL       "$(d46 "$(r5 100000:260100)" "$cal46")"
  v46 'techo dentro del recorrido de este árbol'    INCONCLUSO "$(d46 '100000:200000 100000:210000 100000:270000 100000:250000 100000:220000' "$cal46")"
  v46 'este con 2 resueltas (3 bajo el suelo)'      INCONCLUSO "$(d46 '100000:200000 100000:200000 40000:80000 40000:80000 40000:80000' "$cal46")"
  v46 'serie corta de 49 999 µs no resuelve'        INCONCLUSO "$(d46 '100000:200000 100000:200000 49999:99998 x x' "$cal46")"
  v46 'serie corta de 50 000 µs sí resuelve'        PASS       "$(d46 '100000:200000 100000:200000 50000:100000 x x' "$cal46")"
  v46 'sin línea base'                              INCONCLUSO "$(d46 "$ok46" '' 'la-referencia-no-resuelve:v1.32.1')"
  # EL FAIL-BEFORE DE REQ-030: la corrida 5 del ensayo en CI (`sondas-coste/ensayo-ci/resultados.md`
  # §2). Este árbol recorrió [1,980; 2,693] y la calibración [2,699; 3,919]; los tres valores
  # intermedios de cada lado no se publicaron y se ponen DENTRO del recorrido —el veredicto
  # sólo depende de los extremos—. El procedimiento de `cfb1106`, con una lectura, dio FAIL
  # 2,693× sobre ese árbol; éste tiene que abstenerse.
  v46 'corrida 5 del ensayo en CI'                  INCONCLUSO "$(d46 '100000:198000 100000:210000 100000:230000 100000:250000 100000:269300' '100000:269900 100000:300000 100000:350000 100000:380000 100000:391900')"
  if [ -z "$MAL46" ] && [ "$N46" -eq 15 ]; then
    echo "  PASS  $nom46  $N46 de 15 vectores con la salida que la regla prescribe"
  else
    echo "  FAIL  $nom46  $N46 vectores corridos (se esperaban 15); no casan: ${MAL46:-ninguno}"
  fi
fi
