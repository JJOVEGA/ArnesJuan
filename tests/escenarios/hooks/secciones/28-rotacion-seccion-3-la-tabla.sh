# Sección 28 del banco — 28-rotacion-seccion-3-la-tabla
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=29
PISO_AUTONOMO_SECCION=94  # 9 preámbulo + 40 maquinaria compartida duplicada + 45 bloque indivisible mayor · REQ-014 CA-18 · AVISO: este archivo está EN EL TECHO (400 de 400); el próximo caso exige partirlo en una parte 4, no alargarlo

# FAIL-BEFORE MEDIDO, con `ARNES_HOOKS_DIR` apuntando a otra copia de los hooks:
#   · contra `c59fd83` (antes del reconocedor de tablas): 16 de los 19 primeros FALLAN.
#   · contra `b0774cd` (con el reconocedor y con los dos defectos de QA): FALLAN los dos
#     casos de `QA-026-01` (NUL) y `QA-026-02` (dos tablas) -- y solo esos dos.
#   · contra `6b07f88` (con CA-08 ya escrito y sin implementar (v)): FALLAN tres, y son los
#     tres que este tramo cierra -- `CA-08 (v)` y las DOS formas nuevas de la propiedad--.
#     Los dos casos de propiedad que pidio el analista (tres tablas, la separadora en la
#     ultima fila) PASAN a los dos lados: la comprobacion vive dentro del bucle que recorre
#     la seccion entera, asi que ya estaban cubiertos por construccion. Aqui esta la prueba
#     en vez del argumento, que es lo que se pidio.
# Los que pasan a los dos lados lo hacen por diseno y NO son vacuos: CA-07 (la tabla dentro
# de una entrada) y CA-09/CA-10 (los dos bordes) fijan conducta que este REQ CONSERVA, y son
# justamente lo que una implementacion descuidada de CA-08 rompe --el primer borrador de esta
# comision mandaba CA-09 a la rama de la ambiguedad--; y los dos CONTROLES de QA-026 existen
# para que su pareja no pueda pasar por un fixture que se quedara bajo el umbral. Los que
# podrian haber pasado en vacio --CA-05, CA-06 y CA-12-- llevan una componente que exige que
# la rotacion HAYA OCURRIDO: sin ella, un hook que no mueve nada los pasa todos.
# --- REQ-026: la historia de los REQ es una TABLA, y sus filas son entradas ------------
  seccion_nueva "Rotacion de una seccion que ES una tabla (REQ-026):"

# LA MAQUINARIA VIENE DUPLICADA de `28-rotacion-seccion-1-la-historia.sh` a proposito: un
# archivo de seccion no hace `source` de otro (invariante 4 del README del banco), y copiar
# unas lineas cuesta menos que abrir una puerta trasera entre secciones.
rsec_check() {
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=$2 obtenido=$3"; diag; FAIL=$((FAIL+1)); fi
}
rsec_cnt() {   # <patron> <archivo> -> cuenta, y 0 si el archivo no existe
  local n
  n="$(grep -c -- "$1" "$2" 2>/dev/null)" || n=0
  [ -n "$n" ] || n=0
  printf '%s' "$n"
}
# tab_proj <conservar> <umbral> <orden>
tab_proj() {
  RP3="$(mktemp -d)"; mkdir -p "$RP3/.arnes" "$RP3/requirements" "$RP3/docs"
  printf '# ESTADO\n' > "$RP3/docs/ESTADO.md"
  jq -n --argjson c "$1" --argjson u "$2" --arg o "$3" \
    '{agentes:{agente_codigo:"desarrollador"}, requirements_dir:"requirements",
      rotacion:{activo:true, artefactos:[{glob:"requirements/REQ-*.md",
        seccion:"## Historial de cambios", conservar_entradas:$c, umbral_bytes:$u,
        orden:$o, archivo_dir:"requirements/historial"}]}}' > "$RP3/.arnes/config.json"
}
# LA FORMA DEL CORPUS REAL, no una inventada: cabecera, separadora y filas `| … |`, con la
# fila mas ANTIGUA arriba y la mas RECIENTE abajo (medido en `requirements/REQ-017.md:436`
# y `:462-463`, REQ-026 CA-11). El texto de cada fila lleva relleno para que la seccion pase
# del umbral con pocas filas.
TAB_CAB='| Fecha | Antes → Después | Causa | ADR |'
TAB_SEP='|------------|-----------------|-------------------------|--------|'
# tab_req <archivo> <n filas> — un REQ con su contrato (cabecera con veredictos y criterios
# que TAMBIEN llevan lineas `|` a columna cero) y su historia en forma de tabla.
tab_req() {
  local f="$1" n="$2" i
  { printf '# %s — con contrato y con historia\nEstado: en-revisión\nQA: pendiente\nSeguridad: pendiente\nRigor: critico\n\n' "$(basename "$f" .md)"
    printf '## Criterios de aceptación\n- CA-01 — el contrato, que no se rota jamas\n\n'
    printf '| Criterio | Umbral |\n|---|---|\n| CA-01 | el que sea |\n\n'
    printf '## Historial de cambios\n%s\n%s\n' "$TAB_CAB" "$TAB_SEP"
    for i in $(seq -w 1 "$n"); do
      printf '| 2026-01-%s | fila %s con relleno de sobra para pasar del umbral declarado | causa medida | — |\n' "$i" "$i"
    done
    printf '\n## Trazabilidad\nOrigen: el banco. Esta linea no se toca nunca.\n'
  } > "$f"
}
tab_corre() {
  : > "$ERRLOG"
  printf '%s' "$(CLAUDE_PROJECT_DIR="$RP3" jq -n '{hook_event_name:"Stop",cwd:env.CLAUDE_PROJECT_DIR}')" \
    | CLAUDE_PROJECT_DIR="$RP3" "$HOOKS_DIR/stop.sh" >/dev/null 2>"$ERRLOG"
}
tab_filas() { rsec_cnt '^| 2026-01-' "$1"; }
# Todo el archivo MENOS la seccion de la historia. Sirve para CA-06: se compara byte a byte.
tab_fuera() { awk '/^## Historial de cambios$/{d=1} /^## /{if ($0 != "## Historial de cambios") d=0} !d' "$1"; }

# --- CA-01/CA-02: archiva de verdad, y la cabecera de la tabla NO es una entrada -------
# FAIL-BEFORE MEDIDO contra el hook de 1.33.0: 30 filas de tabla, CERO entradas
# reconocibles, nada archivado y el aviso de "no tiene ni una ENTRADA reconocible".
tab_proj 10 1000 nuevo-al-final
tab_req "$RP3/requirements/REQ-420.md" 30
cp "$RP3/requirements/REQ-420.md" "$RP3/antes.md"
tab_corre; TAB_RC=$?
DOC="$RP3/requirements/REQ-420.md"; ARCH="$RP3/requirements/historial/REQ-420.md"
rsec_check "CA-01 30 filas y conservar 10: se archivan las 20 mas antiguas" "10-20-0" \
  "$(tab_filas "$DOC")-$(tab_filas "$ARCH")-$TAB_RC"
# La cabecera y la separadora se quedan en el documento (una vez) y NO cuentan como
# entradas: si contaran, el reparto seria 10-22 o se moverian con las filas.
rsec_check "CA-02 la cabecera y la separadora siguen en el documento y no son entradas" "1-1-20" \
  "$(rsec_cnt "$TAB_CAB" "$DOC")-$(rsec_cnt "$TAB_SEP" "$DOC")-$(tab_filas "$ARCH")"

# --- CA-04: el ORIGEN sigue siendo una tabla valida -----------------------------------
# El defecto medido en 1.33.0 no era solo que no archivaba: el puntero se insertaba entre
# la separadora y las filas conservadas, y eso rompe la tabla EN EL ORIGEN --en un REQ--.
# Se exige CONTIGÜIDAD: la linea siguiente a la separadora es una fila de datos, y el
# puntero queda fuera de la tabla.
TAB_TRAS_SEP="$(awk -v s="$TAB_SEP" '$0==s{getline; print substr($0,1,10); exit}' "$DOC")"
rsec_check "CA-04 el origen sigue siendo tabla: tras la separadora va una fila, y el puntero fuera" "| 2026-01--1-1" \
  "$TAB_TRAS_SEP-$(rsec_cnt 'historial/REQ-420.md' "$DOC")-$(awk '/^> Entradas anteriores/{p=NR} $0==ENVIRON["TAB_CAB_E"]{c=NR} END{print (p<c)?1:0}' TAB_CAB_E="$TAB_CAB" "$DOC" 2>/dev/null || echo 0)"

# --- CA-03: el DESTINO es una tabla, no un monton de filas ----------------------------
# Cada bloque archivado va precedido, SIN NINGUNA LINEA INTERMEDIA, por una cabecera
# IDENTICA a la del origen y por su separadora. La prueba no busca las filas: comprueba que
# la linea de encima de la primera fila de cada bloque es la separadora, y la de encima de
# esa, la cabecera.
rsec_check "CA-03 el destino se lee como tabla: cabecera + separadora pegadas al bloque" "1-1" \
  "$(awk -v c="$TAB_CAB" -v s="$TAB_SEP" 'p2==c && p1==s && /^\| 2026-01-/{n++} {p2=p1; p1=$0} END{print (n>0)?1:0}' "$ARCH")-$(awk -v s="$TAB_SEP" '/^\| 2026-01-/{ if (p!=s && !dentro) mal++; dentro=1 } !/^\| 2026-01-/{dentro=0} {p=$0} END{print (mal)?0:1}' "$ARCH")"
# CA-05: cero filas perdidas, cero duplicadas. Se comparan los CONJUNTOS de filas de datos
# (con multiplicidad), no se cuentan lineas: contar deja pasar una fila cambiada por otra.
# Y LLEVA LA MITAD QUE LO HACE NO VACUO --que se archivaron 20--, porque un hook que no
# mueve nada conserva el multiconjunto perfectamente: asi pasaba el de 1.33.0.
rsec_check "CA-05 el multiconjunto de filas es el mismo antes y despues, y SI se movio" "iguales-20" \
  "$(cmp -s <(grep '^| 2026-01-' "$RP3/antes.md" | sort) <(cat <(grep '^| 2026-01-' "$DOC") <(grep '^| 2026-01-' "$ARCH") | sort) && echo iguales || echo distintos)-$(tab_filas "$ARCH")"
# --- CA-06: EL NEGATIVO DISCRIMINANTE. El contrato no se toca -------------------------
# Y NO PUEDE SATISFACERSE NO HACIENDO NADA: se exige que la historia SI se haya movido Y que
# todo lo de fuera de esa seccion quede byte a byte igual --cabecera con `Estado:`, `QA:` y
# `Seguridad:`, criterios (que aqui llevan lineas `|` a columna cero) y trazabilidad--. Sin
# la primera mitad, el hook de 1.33.0 --que no archiva nada-- pasaria este caso.
rsec_check "CA-06 el contrato queda byte a byte y la historia SI se movio (no vale no hacer nada)" "iguales-20" \
  "$(cmp -s <(tab_fuera "$RP3/antes.md") <(tab_fuera "$DOC") && echo iguales || echo distintos)-$(tab_filas "$ARCH")"
# Y la tabla que vive DENTRO de los criterios sigue entera: es contrato, no historia. Un
# reconocedor que buscara `|` por todo el documento se la llevaria. Con la mitad no vacua.
rsec_check "CA-06 la tabla de la seccion de criterios no se toca, habiendo rotado" "1-1-20" \
  "$(rsec_cnt '^| Criterio | Umbral |' "$DOC")-$(rsec_cnt '^| CA-01 | el que sea |' "$DOC")-$(tab_filas "$ARCH")"
# CA-03 (segunda mitad): con un bloque ANTERIOR en el destino, el bloque nuevo trae SU
# PROPIA cabecera y separadora, y ninguna marca queda entre dos filas del mismo bloque.
for i in $(seq -w 31 45); do
  printf '| 2026-01-%s | fila %s con relleno de sobra para pasar del umbral declarado | causa medida | — |\n' "$i" "$i" >> "$RP3/mas.md"
done
awk -v mas="$RP3/mas.md" '{print} /^\| 2026-01-30 /{while ((getline l < mas) > 0) print l}' "$DOC" > "$RP3/doc2.md"
mv "$RP3/doc2.md" "$DOC"
tab_corre
rsec_check "CA-03 dos bloques en el destino: dos cabeceras, dos separadoras, ninguna marca dentro" "2-2-1" \
  "$(rsec_cnt "$TAB_CAB" "$ARCH")-$(rsec_cnt "$TAB_SEP" "$ARCH")-$(awk '/^<!-- ARNES:ROTADO/{ if (prev ~ /^\| 2026-01-/) mal=1 } {prev=$0} END{print (mal)?0:1}' "$ARCH")"
rm -rf "$RP3"

# --- CA-07: una tabla DENTRO de una entrada no se parte -------------------------------
# La tabla aparece DESPUES de la primera entrada de lista, asi que no es la estructura de la
# seccion: es continuacion de su entrada y viaja con ella. Aqui esta la razon de que la
# regla se enuncie por propiedad y no anadiendo `|` a una lista de prefijos.
tab_proj 5 1000 nuevo-al-final
{ printf '# REQ-421\nEstado: en-revisión\n\n## Historial de cambios\nPreambulo de la seccion.\n\n'
  i=1; while [ "$i" -le 20 ]; do
    printf -- '- entrada %s con relleno de sobra para pasar del umbral de mil bytes declarado\n' "$i"
    [ "$i" -eq 1 ] && printf '| dentro | de la entrada |\n|---|---|\n| viaja | con ella |\n'
    i=$((i+1))
  done
  printf '\n## Notas\nintacto\n'
} > "$RP3/requirements/REQ-421.md"
tab_corre
rsec_check "CA-07 la tabla de dentro de una entrada viaja con su entrada, y las entradas son las de lista" "15-5-3" \
  "$(rsec_cnt '^- entrada' "$RP3/requirements/historial/REQ-421.md")-$(rsec_cnt '^- entrada' "$RP3/requirements/REQ-421.md")-$(rsec_cnt '^|' "$RP3/requirements/historial/REQ-421.md")"
rm -rf "$RP3"

# --- CA-08: FAIL-CLOSED. Si no reconoce la estructura, no rota y avisa -----------------
# Cuatro formas en las que no se puede decir sin ambiguedad cual es la cabecera, cual la
# separadora y cuales las filas. En las cuatro: archivo byte a byte igual, aviso propio
# (distinto del de "sin entradas") y la parada NO se bloquea. Una comprobacion que no puede
# responder no dice "no se", dice "si" -- y aqui eso significaria mutilar un contrato.
tab_amb() {   # tab_amb <etiqueta> <preambulo de la seccion, con \n>
  tab_proj 10 1000 nuevo-al-final
  { printf '# REQ-422\nEstado: en-revisión\n\n## Historial de cambios\n'
    printf '%b' "$2"
    i=1; while [ "$i" -le 30 ]; do
      printf '| 2026-01-%02d | fila %s con relleno de sobra para pasar del umbral declarado | causa | — |\n' "$i" "$i"
      i=$((i+1))
    done
    printf '\n## Notas\nintacto\n'
  } > "$RP3/requirements/REQ-422.md"
  cp "$RP3/requirements/REQ-422.md" "$RP3/antes.md"
  tab_corre; local rc=$?
  rsec_check "CA-08 fail-closed ($1): no archiva nada, avisa de la ambiguedad y sale 0" "iguales-si-no-0" \
    "$(cmp -s "$RP3/antes.md" "$RP3/requirements/REQ-422.md" && echo iguales || echo distintos)-$(grep -q 'ESTRUCTURA DE TABLA es AMBIGUA' "$ERRLOG" && echo si || echo no)-$(grep -q 'ENTRADA reconocible' "$ERRLOG" && echo si || echo no)-$rc"
  rm -rf "$RP3"
}
tab_amb "filas sin separadora delante" ""
tab_amb "dos separadoras en el preambulo" "$TAB_CAB\\n$TAB_SEP\\n|:---:|---:|---|---|\\n"
tab_amb "una linea entre la cabecera y la separadora" "$TAB_CAB\\n\\n$TAB_SEP\\n"
tab_amb "separadora sin cabecera delante" "$TAB_SEP\\n"

# --- QA-026-02: LA QUINTA FORMA. Dos tablas en la seccion -----------------------------
# La enumeracion de CA-08 se declara "NO exhaustiva", y la implementacion cubrio la
# enumeracion en vez de la propiedad: el paso que decide la estructura paraba en la primera
# fila de datos, asi que NADA posterior a esa fila se validaba. Con dos tablas rotaba, sin
# aviso, y la cabecera y la separadora de la SEGUNDA se archivaban como filas de datos de la
# PRIMERA: las filas conservadas quedaban bajo las columnas de otra tabla y el lector leia
# `Causa` donde el documento decia otra cosa. DATO REETIQUETADO EN SILENCIO.
#
# Lo que lo hacia invisible: en esta forma NO se pierde ni se duplica ninguna fila, asi que
# CA-05 se conserva y ninguna comprobacion de perdida lo ve. Por eso el caso no mira filas:
# mira que no se rote y que se avise.
tab_dos_tablas() {   # tab_dos_tablas <segunda tabla si/no>
  tab_proj 4 1000 nuevo-al-final
  { printf '# REQ-429\nEstado: en-revisión\n\n## Historial de cambios\n%s\n%s\n' "$TAB_CAB" "$TAB_SEP"
    i=1; while [ "$i" -le 20 ]; do
      printf '| 2026-01-%02d | fila %s con relleno de sobra para pasar del umbral declarado | causa | — |\n' "$i" "$i"
      i=$((i+1))
    done
    # SIN linea en blanco entre las dos tablas, a proposito: asi la primera cosa que
    # desmiente la estructura es LA SEGUNDA SEPARADORA, y el caso puede exigir ESE motivo. Con
    # una linea en blanco delante, el motivo que salta primero es el otro --"lineas que no son
    # filas entre dos filas"--, igual de cierto y igual de fail-closed, y el caso estaria
    # fijando cual de dos diagnosticos verdaderos se ve antes, que no es lo que se contrata.
    # Es tambien la forma que deja el origen con dos separadoras seguidas.
    if [ "$1" = si ]; then
      printf '| Otra | Tabla | Distinta |\n|---|---|---|\n'
      printf '| 2026-02-01 | segunda tabla, fila A | tercera columna |\n'
      printf '| 2026-02-02 | segunda tabla, fila B | tercera columna |\n'
    fi
    printf '\n## Trazabilidad\nintacta\n'
  } > "$RP3/requirements/REQ-429.md"
  cp "$RP3/requirements/REQ-429.md" "$RP3/antes.md"
  tab_corre; TAB_RC=$?
}
tab_dos_tablas si
rsec_check "QA-026-02 dos tablas en la seccion: no rota, avisa de la ambiguedad y sale 0" "iguales-si-no-0" \
  "$(cmp -s "$RP3/antes.md" "$RP3/requirements/REQ-429.md" && echo iguales || echo distintos)-$(grep -q 'mas de una tabla' "$ERRLOG" && echo si || echo no)-$([ -e "$RP3/requirements/historial/REQ-429.md" ] && echo si || echo no)-$TAB_RC"
rm -rf "$RP3"
# EL CONTROL, sin el que "no rota" no dice nada: el MISMO documento con UNA sola tabla si
# rota y no avisa. Asi se sabe que lo que detiene la rotacion es la segunda tabla y no que
# el fixture se quedara por debajo del umbral.
tab_dos_tablas no
rsec_check "QA-026-02 control: el mismo documento con UNA tabla si rota y no avisa" "16-4-silencio" \
  "$(rsec_cnt '^| 2026-01-' "$RP3/requirements/historial/REQ-429.md")-$(rsec_cnt '^| 2026-01-' "$RP3/requirements/REQ-429.md")-$(grep -q 'AMBIGUA' "$ERRLOG" && echo aviso || echo silencio)"
rm -rf "$RP3"

# --- QA-026-01: un NUL en el documento. NO SE ROTA, y no se publica media lectura ------
# `read -r -d ''` se detiene en el primer NUL y devuelve 0: lo leido es MEDIA lectura y el
# paso final la publicaba encima del original. Medido sobre una copia de `REQ-007`:
# -17.697 B y cinco filas de historia desaparecidas del documento Y del archivo, con rc 0 y
# sin un aviso (SEC-002/R-001, la misma clase que dejo `guard-completado` en abierto).
# El NUL va DESPUES de la seccion: con el NUL delante, el texto truncado ya no contiene la
# seccion y el hook sale por otra rama --el caso no probaria esto--.
tab_nul() {   # tab_nul <con nul si/no>
  tab_proj 10 1000 nuevo-al-final
  { printf '# REQ-430\nEstado: en-revisión\nQA: pendiente\n\n'
    printf '## Historial de cambios\n%s\n%s\n' "$TAB_CAB" "$TAB_SEP"
    i=1; while [ "$i" -le 30 ]; do
      printf '| 2026-01-%02d | fila %s con relleno de sobra para pasar del umbral declarado | causa | — |\n' "$i" "$i"
      i=$((i+1))
    done
    printf '\n## Trazabilidad\ntexto antes del byte cero '
    [ "$1" = si ] && printf '\000'
    printf ' y texto despues\nultima linea, que tampoco se pierde\n'
  } > "$RP3/requirements/REQ-430.md"
  cp "$RP3/requirements/REQ-430.md" "$RP3/antes.md"
  tab_corre; TAB_RC=$?
}
tab_nul si
# Las tres componentes son las tres mitades del defecto: el archivo IGUAL (no se publico la
# media lectura), el AVISO (no fue en silencio) y las 30 filas todavia en el documento. Se
# cuenta con `grep -a`: sin el, `grep -c` sobre un archivo con un NUL no imprime nada y el
# caso pasaria por vacio.
rsec_check "QA-026-01 con un NUL: no rota, avisa de que no se puede leer entero, byte a byte igual y sale 0" "iguales-si-30-0" \
  "$(cmp -s "$RP3/antes.md" "$RP3/requirements/REQ-430.md" && echo iguales || echo distintos)-$(grep -q 'NO SE PUEDE LEER ENTERO' "$ERRLOG" && echo si || echo no)-$(grep -ac '^| 2026-01-' "$RP3/requirements/REQ-430.md")-$TAB_RC"
# CA-08 (v): LA SEDE DEL AVISO ES LA MISMA PARA LAS CUATRO RAMAS. El stderr de una parada no
# sobrevive a la sesion, asi que esta rama deja tambien su linea --con su contador y con texto
# que la DISTINGUE de las otras tres-- en el bloque derivado de `docs/ESTADO.md`. Y no delega
# su visibilidad en `guard-completado`: esa denegacion depende de que alguien edite ese REQ y
# de donde caiga el NUL, mientras que el silencio de la rotacion no depende de nada.
rsec_check "CA-08 (v) el bloque derivado refleja la lectura no fiable, con texto propio" "si-si-no-no" \
  "$(grep -q 'no se pueden leer enteros' "$RP3/docs/ESTADO.md" && echo si || echo no)-$(grep -q 'REQ-430.md' "$RP3/docs/ESTADO.md" && echo si || echo no)-$(grep -q 'estructura de tabla ambigua' "$RP3/docs/ESTADO.md" && echo si || echo no)-$(grep -qE 'sin ninguna entrada reconocible|no contienen la sección declarada' "$RP3/docs/ESTADO.md" && echo si || echo no)"
rm -rf "$RP3"
# EL CONTROL: el MISMO documento sin el NUL rota. Sin el, "no rota" tambien seria cierto de
# un fixture que no llega al umbral, y el caso de arriba no distinguiria nada.
tab_nul no
rsec_check "QA-026-01 control: el mismo documento sin el NUL si rota y no avisa" "10-20-silencio" \
  "$(rsec_cnt '^| 2026-01-' "$RP3/requirements/REQ-430.md")-$(rsec_cnt '^| 2026-01-' "$RP3/requirements/historial/REQ-430.md")-$(grep -q 'NO SE PUEDE LEER ENTERO' "$ERRLOG" && echo aviso || echo silencio)"
rm -rf "$RP3"

# --- CA-08 (i): LA PROPIEDAD, NO LA LISTA ---------------------------------------------
# `(ii)` dice que una implementacion que satisfaga la enumeracion y no `(i)` INCUMPLE, y que
# la lista puede crecer sin que `(i)` cambie. Estas formas NO estan en la enumeracion: si la
# comprobacion mirara la lista en vez de recorrer la seccion, pasarian por el hueco.
#
# `tab_forma <etiqueta> <cuerpo de la seccion, con \n>` — el cuerpo se escribe entero para
# que cada forma sea legible al lado de su veredicto.
tab_forma() {
  tab_proj 4 1000 nuevo-al-final
  { printf '# REQ-431\nEstado: en-revisión\n\n## Historial de cambios\n'
    printf '%b' "$2"
    printf '\n## Trazabilidad\nintacta\n'
  } > "$RP3/requirements/REQ-431.md"
  cp "$RP3/requirements/REQ-431.md" "$RP3/antes.md"
  tab_corre; TAB_RC=$?
  rsec_check "CA-08 (i) $1: no rota, avisa y sale 0" "iguales-si-no-0" \
    "$(cmp -s "$RP3/antes.md" "$RP3/requirements/REQ-431.md" && echo iguales || echo distintos)-$(grep -q 'ESTRUCTURA DE TABLA es AMBIGUA' "$ERRLOG" && echo si || echo no)-$([ -e "$RP3/requirements/historial/REQ-431.md" ] && echo si || echo no)-$TAB_RC"
  rm -rf "$RP3"
}
TAB_F=''   # 12 filas de datos, la materia prima de las tres formas de abajo
for i in $(seq -w 1 12); do
  TAB_F+="| 2026-01-$i | fila $i con relleno de sobra para pasar del umbral declarado | causa | — |\\n"
done
# (a) TRES tablas: la deteccion no puede pararse en la segunda.
tab_forma "tres tablas en la seccion" \
  "$TAB_CAB\\n$TAB_SEP\\n$TAB_F\\n| Segunda | Tabla |\\n|---|---|\\n| 2026-02-01 | de la segunda |\\n\\n| Tercera | Tabla | Mas |\\n|---|---|---|\\n| 2026-03-01 | de la tercera | y mas |\\n"
# (b) la segunda separadora es LA ULTIMA fila de datos: el borde por el que se escapa una
#     comprobacion que mire "la fila siguiente" en vez de todas.
tab_forma "la segunda separadora es la ultima fila" "$TAB_CAB\\n$TAB_SEP\\n$TAB_F$TAB_SEP\\n"
# (c) NO ES UNA TABLA DE MAS, ES UNA LINEA DE MAS, y la encontro esta comision probando la
#     propiedad: una linea que no es fila de datos ENTRE dos filas corta la tabla ahi (en GFM
#     una linea vacia o un parrafo la cierran). Medido antes del arreglo: rotaba EN SILENCIO y
#     el bloque del destino quedaba con esa linea entre dos filas de datos, o sea dejaba de
#     leerse como tabla (CA-03). Las tres formas que lo producen --una segunda tabla INDENTADA
#     (GFM admite hasta tres espacios), un parrafo suelto y una linea vacia-- son la misma
#     cosa vista tres veces, y por eso el arreglo no las enumera.
tab_forma "una linea que no es fila entre dos filas (parrafo)" \
  "$TAB_CAB\\n$TAB_SEP\\n| 2026-01-01 | primera fila con relleno de sobra | causa | — |\\nun parrafo suelto entre dos filas de datos\\n$TAB_F"
tab_forma "una segunda tabla indentada tres espacios entre filas" \
  "$TAB_CAB\\n$TAB_SEP\\n| 2026-01-01 | primera fila con relleno de sobra | causa | — |\\n   | Indentada | Tabla |\\n   |---|---|\\n$TAB_F"
# EL CONTROL, y es el que separa la propiedad de una regla bruta: una continuacion DESPUES de
# la ultima fila NO corta ninguna tabla --no hay ninguna fila detras de ella-- asi que se rota,
# y esa cola viaja con su entrada, que es lo que CA-07 contrata. Sin este control, el arreglo
# de (c) podria ser "cualquier linea rara detiene la rotacion", que romperia CA-07 y dejaria
# sin rotar media `requirements/`.
tab_proj 4 1000 nuevo-al-final
{ printf '# REQ-432\nEstado: en-revisión\n\n## Historial de cambios\n%s\n%s\n' "$TAB_CAB" "$TAB_SEP"
  i=1; while [ "$i" -le 12 ]; do
    printf '| 2026-01-%02d | fila %s con relleno de sobra para pasar del umbral declarado | causa | — |\n' "$i" "$i"
    i=$((i+1))
  done
  printf '   | Indentada | Tabla |\n   |---|---|\n   | 2026-02-01 | cola indentada |\n'
  printf '\n## Trazabilidad\nintacta\n'
} > "$RP3/requirements/REQ-432.md"
tab_corre
rsec_check "CA-08 (i) control: una continuacion TRAS la ultima fila no corta nada; se rota y viaja con su entrada" "4-8-silencio-3" \
  "$(rsec_cnt '^| 2026-01-' "$RP3/requirements/REQ-432.md")-$(rsec_cnt '^| 2026-01-' "$RP3/requirements/historial/REQ-432.md")-$(grep -q 'AMBIGUA' "$ERRLOG" && echo aviso || echo silencio)-$(rsec_cnt '^   |' "$RP3/requirements/REQ-432.md")"
rm -rf "$RP3"

# --- CA-09: borde. Cabecera y separadora, y NINGUNA fila de datos ---------------------
# Comportamiento vigente que este REQ CONSERVA: no se rota y se avisa de que no hay ni una
# entrada. Y NO por la rama de la ambiguedad: la tabla esta bien formada, lo que no tiene
# son filas. Si las dos ramas compartieran texto, este caso no distinguiria nada.
tab_proj 10 200 nuevo-al-final
{ printf '# REQ-423\nEstado: en-revisión\n\n## Historial de cambios\n'
  i=1; while [ "$i" -le 8 ]; do printf 'prosa de relleno %s para pasar del umbral de doscientos bytes\n' "$i"; i=$((i+1)); done
  printf '\n%s\n%s\n' "$TAB_CAB" "$TAB_SEP"
} > "$RP3/requirements/REQ-423.md"
cp "$RP3/requirements/REQ-423.md" "$RP3/antes.md"
tab_corre
rsec_check "CA-09 tabla bien formada y sin ninguna fila: no rota y avisa de que no hay entradas" "iguales-si-no" \
  "$(cmp -s "$RP3/antes.md" "$RP3/requirements/REQ-423.md" && echo iguales || echo distintos)-$(grep -q 'ENTRADA reconocible' "$ERRLOG" && echo si || echo no)-$(grep -q 'AMBIGUA' "$ERRLOG" && echo si || echo no)"
rm -rf "$RP3"

# --- CA-10: borde. Nada que archivar y NADA QUE DECIR --------------------------------
# Por debajo del umbral no hay error de mapeo que senalar, y avisar seria ruido en cada
# parada. Se exige silencio en los DOS canales: stderr y el bloque derivado.
tab_proj 10 9999999 nuevo-al-final
tab_req "$RP3/requirements/REQ-424.md" 30
cp "$RP3/requirements/REQ-424.md" "$RP3/antes.md"
tab_corre
rsec_check "CA-10 bajo el umbral: byte a byte igual, sin aviso y sin linea en el bloque" "iguales-silencio-no" \
  "$(cmp -s "$RP3/antes.md" "$RP3/requirements/REQ-424.md" && echo iguales || echo distintos)-$(grep -q 'REQ-424.md' "$ERRLOG" && echo aviso || echo silencio)-$(grep -qE 'estructura de tabla ambigua|sin ninguna entrada reconocible' "$RP3/docs/ESTADO.md" && echo si || echo no)"
rm -rf "$RP3"

# --- CA-11: direccion. Se archiva LO MAS ANTIGUO, y la prueba lo DISCRIMINA -----------
# La fila mas antigua esta arriba y la mas reciente abajo (medido en el corpus de este
# repositorio). Con `nuevo-al-final` se archiva la de arriba y se conserva la de abajo.
tab_proj 10 1000 nuevo-al-final
tab_req "$RP3/requirements/REQ-425.md" 30
tab_corre
rsec_check "CA-11 se archiva lo mas antiguo: la 01 al archivo, la 30 se queda" "1-0-0-1" \
  "$(rsec_cnt '^| 2026-01-01 ' "$RP3/requirements/historial/REQ-425.md")-$(rsec_cnt '^| 2026-01-30 ' "$RP3/requirements/historial/REQ-425.md")-$(rsec_cnt '^| 2026-01-01 ' "$RP3/requirements/REQ-425.md")-$(rsec_cnt '^| 2026-01-30 ' "$RP3/requirements/REQ-425.md")"
rm -rf "$RP3"
# EL DISCRIMINANTE: con el `orden` al revés el caso de arriba TIENE que fallar. Se comprueba
# midiendo el espejo exacto —lo mas reciente al archivo, lo mas antiguo en el documento—.
# Sin esto, una implementacion ciega al `orden` pasaria el caso de arriba la mitad de las
# veces y nadie sabria cual mitad.
tab_proj 10 1000 nuevo-primero
tab_req "$RP3/requirements/REQ-426.md" 30
tab_corre
rsec_check "CA-11 discriminante: con 'nuevo-primero' el reparto es el ESPEJO del de arriba" "0-1-1-0" \
  "$(rsec_cnt '^| 2026-01-01 ' "$RP3/requirements/historial/REQ-426.md")-$(rsec_cnt '^| 2026-01-30 ' "$RP3/requirements/historial/REQ-426.md")-$(rsec_cnt '^| 2026-01-01 ' "$RP3/requirements/REQ-426.md")-$(rsec_cnt '^| 2026-01-30 ' "$RP3/requirements/REQ-426.md")"
rm -rf "$RP3"

# --- CA-12: el destino no se rota a si mismo ni se confunde con un REQ ----------------
# El archivo de historia vive en `requirements/historial/`, casa `REQ-*.md` por nombre y
# supera el umbral de sobra. Si entrara como origen se rotaria a si mismo en cada parada y
# la historia se iria por trozos a `historial/historial/`. Tres paradas de mas: el archivo
# no gana punteros, no aparece un segundo nivel, y el reparto no se mueve.
tab_proj 10 1000 nuevo-al-final
tab_req "$RP3/requirements/REQ-427.md" 30
tab_corre; tab_corre; tab_corre; tab_corre
rsec_check "CA-12 el archivo de historia no entra como origen: ni se rota ni anida" "10-20-0-no" \
  "$(tab_filas "$RP3/requirements/REQ-427.md")-$(tab_filas "$RP3/requirements/historial/REQ-427.md")-$(rsec_cnt 'Entradas anteriores' "$RP3/requirements/historial/REQ-427.md")-$([ -e "$RP3/requirements/historial/historial" ] && echo si || echo no)"
# Y NO SE CONFUNDE CON UN REQ: el numero de REQ que informa el lector del arnes es el MISMO
# antes y despues de rotar. Si el archivo contara, cada rotacion inventaria un REQ nuevo --y
# `docs/ESTADO.md` lo listaria-- porque el archivo hereda el nombre del documento. La cuarta
# componente es la que lo hace no vacuo: el REQ-428 se rota EN ESA MISMA parada.
tab_req "$RP3/requirements/REQ-428.md" 30
tab_leidos() { awk '/^  [0-9]+ REQ leídos$/{print $1; exit}' <(bash "$(dirname "$HOOKS_DIR")/tools/arnes-lectura.sh" "$RP3" 2>/dev/null); }
TAB_N1="$(tab_leidos)"
tab_corre
rsec_check "CA-12 el lector cuenta los mismos REQ antes y despues de una rotacion" "2-2-0-20" \
  "$TAB_N1-$(tab_leidos)-$(rsec_cnt 'REQ-427.md — historia' "$RP3/docs/ESTADO.md")-$(tab_filas "$RP3/requirements/historial/REQ-428.md")"
rm -rf "$RP3"
