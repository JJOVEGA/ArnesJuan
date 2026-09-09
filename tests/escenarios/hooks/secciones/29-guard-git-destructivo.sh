# Sección 29 del banco — 29-guard-git-destructivo
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=111
PISO_AUTONOMO_SECCION=59  # 9 preámbulo + 0 maquinaria compartida duplicada + 50 bloque indivisible mayor · REQ-014 CA-18

# --- REQ-005: git destructivo prohibido a TODOS los agentes ---------------------------
  seccion_nueva "guard-git: ningun agente ejecuta git destructivo:"

# CA-17: sin bloque `git` en el manifiesto la puerta ya esta encendida. Es la UNICA
# novedad de 1.31.0 activa por defecto, y lo esta porque su daño es irreversible.
check "CA-01/CA-17 coordinadora: 'git clean -fd' -> deny (por defecto)" deny guard-git.sh "$(emite_bash 'git clean -fd' "" "")"
check_motivo "CA-01 el motivo dice que se pierde y como seguir" 'comitea|humano' guard-git.sh "$(emite_bash 'git clean -fd' "" "")"
# CA-02: es una regla del COMANDO, no de la identidad. Ahi esta la diferencia con
# guard-codigo, y por eso alcanza al desarrollador y a la coordinadora por igual.
check "CA-02 el MISMO comando desde el desarrollador -> deny igual" deny guard-git.sh "$(emite_bash 'git clean -fd' "d1" "desarrollador")"
check "CA-03 'git reset --hard' -> deny"            deny guard-git.sh "$(emite_bash 'git reset --hard' "" "")"
check "CA-03 'git reset --hard HEAD~1' -> deny"     deny guard-git.sh "$(emite_bash 'git reset --hard HEAD~1' "" "")"
check "CA-04 'git checkout .' -> deny"              deny guard-git.sh "$(emite_bash 'git checkout .' "" "")"
check "CA-04 'git restore .' -> deny"               deny guard-git.sh "$(emite_bash 'git restore .' "" "")"
check "CA-05 'git stash' desnudo -> deny"           deny guard-git.sh "$(emite_bash 'git stash' "" "")"
check "CA-05 'git stash push -u' -> deny"           deny guard-git.sh "$(emite_bash 'git stash push -u' "" "")"
# CA-06: el subcomando se reconoce este donde este dentro del comando.
check "CA-06 'cd sub && git clean -fd' -> deny"     deny guard-git.sh "$(emite_bash 'cd sub && git clean -fd' "" "")"
check "CA-06 'git -C proj reset --hard' -> deny"    deny guard-git.sh "$(emite_bash 'git -C proj reset --hard' "" "")"
check "CA-06 '(git reset --hard)' -> deny"          deny guard-git.sh "$(emite_bash '(git reset --hard)' "" "")"
check "CA-06 'x=\$(git stash)' -> deny"             deny guard-git.sh "$(emite_bash 'x=$(git stash)' "" "")"
check "CA-06 'git clean -fd | tee log' -> deny"     deny guard-git.sh "$(emite_bash 'git clean -fd | tee log' "" "")"
# CA-07: con el delimitador SIN CITAR bash ejecuta de verdad la sustitucion. Mismo
# descuento que el detector de escrituras, no una segunda copia de esa regla.
check "CA-07 heredoc SIN citar con \$(git clean -fd) -> deny" deny guard-git.sh \
  "$(emite_bash $'cat <<EOF\n$(git clean -fd)\nEOF' "" "")"
# La lista por defecto casa por FLAG: `clean -f` alcanza -f, -fd y -fdx, y no -n.
check "flags cortos: 'git clean -fdx' -> deny"      deny guard-git.sh "$(emite_bash 'git clean -fdx' "" "")"
check "los argumentos entrecomillados no desarman el reconocimiento" deny guard-git.sh "$(emite_bash 'git clean -fd "src"' "" "")"

# --- Controles positivos: lo que NO deniega ---
check "CA-08 'git stash list' -> allow"             allow guard-git.sh "$(emite_bash 'git stash list' "" "")"
check "CA-08 'git stash show' -> allow"             allow guard-git.sh "$(emite_bash 'git stash show' "" "")"
check "CA-09 'git restore --staged archivo.ts' -> allow" allow guard-git.sh "$(emite_bash 'git restore --staged archivo.ts' "" "")"
check "CA-10 'git clean -n' -> allow"               allow guard-git.sh "$(emite_bash 'git clean -n' "" "")"
check "CA-10 'git clean --dry-run' -> allow"        allow guard-git.sh "$(emite_bash 'git clean --dry-run' "" "")"
check "CA-11 'git reset --soft HEAD~1' -> allow"    allow guard-git.sh "$(emite_bash 'git reset --soft HEAD~1' "" "")"
check "CA-11 'git reset archivo.ts' -> allow"       allow guard-git.sh "$(emite_bash 'git reset archivo.ts' "" "")"
check "CA-12 'git checkout rama' -> allow"          allow guard-git.sh "$(emite_bash 'git checkout rama' "" "")"
check "CA-12 'git checkout -b rama' -> allow"       allow guard-git.sh "$(emite_bash 'git checkout -b rama' "" "")"
check "CA-12 'git restore --source=HEAD~1 x.ts' -> allow" allow guard-git.sh "$(emite_bash 'git restore --source=HEAD~1 x.ts' "" "")"
# CA-13: lo entrecomillado y el cuerpo literal de un heredoc no son el comando.
check "CA-13 'git commit -m \"no uses git clean\"' -> allow" allow guard-git.sh "$(emite_bash 'git commit -m "no uses git clean"' "" "")"
check "CA-13 heredoc CITADO cuyo cuerpo dice git clean -fd -> allow" allow guard-git.sh \
  "$(emite_bash $'cat <<\'EOF\'\ngit clean -fd\nEOF' "" "")"
# CA-14: `git` es un TOKEN de comando, no una subcadena.
# QA 1.31.0: HALLAZGO QA-101 — la regla casa el flag CORTO por letras, pero la forma
# LARGA equivalente y el alias del subcomando escapan. `git clean --force` borra lo mismo
# que `git clean -f`, y `git stash save` es el alias historico de `git stash push`. Los
# tres son la conducta que REQ-005 existe para impedir. Controles positivos justo debajo.
check "QA-101 'git clean --force' -> deny"          deny  guard-git.sh "$(emite_bash 'git clean --force' "" "")"
check "QA-101 'git clean --force -d' -> deny"       deny  guard-git.sh "$(emite_bash 'git clean --force -d' "" "")"
check "QA-101 'git stash save \"wip\"' -> deny"      deny  guard-git.sh "$(emite_bash 'git stash save "wip"' "" "")"
check "QA-101 control: 'git clean --dry-run' sigue allow" allow guard-git.sh "$(emite_bash 'git clean --dry-run' "" "")"
check "QA-101 control: 'git stash list' sigue allow" allow guard-git.sh "$(emite_bash 'git stash list' "" "")"
# DEV 1.31.0 v2: la equivalencia es SIMETRICA y vive en el motor, no en la lista. La forma
# larga se traduce a su letra corta antes de comparar, en los DOS lados; asi una regla
# escrita con una ortografia alcanza tambien la otra, y ninguna lista tiene que enumerar
# variantes. Con el `=` pegado (`--force=x`) la opcion sigue siendo la misma.
check "DEV 1.31.0 v2: QA-101 'git clean -d --force' (larga al final) -> deny" deny guard-git.sh \
  "$(emite_bash 'git clean -d --force' "" "")"
check "DEV 1.31.0 v2: QA-101 'git stash save' sin mensaje -> deny" deny guard-git.sh \
  "$(emite_bash 'git stash save' "" "")"
check "DEV 1.31.0 v2: QA-101 'git clean --force=si' -> deny" deny guard-git.sh \
  "$(emite_bash 'git clean --force=si' "" "")"
# FIN DE OPCIONES: detras de `--` lo que hay son pathspecs. `--force` ahi es el NOMBRE DE
# UN ARCHIVO, no el flag, y denegarlo seria el falso positivo que estorba a todo el mundo.
check "DEV 1.31.0 v2: QA-101 control fin de opciones: 'git clean -- --force' -> allow" allow guard-git.sh \
  "$(emite_bash 'git clean -- --force' "" "")"
# Y la otra mitad del control: `--staged` en su forma corta tampoco toca el arbol.
check "DEV 1.31.0 v2: QA-101 control: 'git restore -S .' (forma corta de --staged) -> allow" allow guard-git.sh \
  "$(emite_bash 'git restore -S .' "" "")"

# QA 1.31.0 v2: el FIN DE OPCIONES (`--`) que 1.31.0 introduce mueve TRES veredictos de
# DENY a ALLOW respecto de `40312c6`, y esa direccion se declara, no se descubre. Los tres
# son correctos —medido en un repositorio desechable: `git reset -- --hard` no toca ni el
# arbol ni el indice, y `git clean -- -f` solo alcanza a un archivo llamado `-f`, y solo
# si el proyecto puso `clean.requireForce=false`—, pero ningun criterio los describia.
# Se fijan aqui para que un cambio futuro en el detector no los mueva sin que nadie lo vea.
check "QA 1.31.0 v2: fin de opciones 'git clean -- -f' -> allow (era deny en 40312c6)" allow guard-git.sh \
  "$(emite_bash 'git clean -- -f' "" "")"
check "QA 1.31.0 v2: fin de opciones 'git reset -- --hard' -> allow (era deny en 40312c6)" allow guard-git.sh \
  "$(emite_bash 'git reset -- --hard' "" "")"
# CONTROL, y es el que sostiene la regla: detras de `--` deja de buscarse una OPCION, pero
# un token LITERAL se sigue buscando en todo el segmento, porque ahi si puede ser un
# pathspec — y `git checkout -- .` arrasa el arbol igual.
check "QA 1.31.0 v2: control fin de opciones: 'git checkout -- .' sigue deny" deny guard-git.sh \
  "$(emite_bash 'git checkout -- .' "" "")"
check "DEV 1.31.0 v2: QA-101 'git restore -W .' (forma corta de --worktree) -> deny" deny guard-git.sh \
  "$(emite_bash 'git restore -W .' "" "")"

# QA 1.31.0 v3: HALLAZGO QA-113 — un token ENTRECOMILLADO desaparece del analisis, y con
# el la regla. `git clean "-f"` es, para bash, exactamente `git clean -f`: borra lo mismo.
# La puerta no lo ve porque el descuento de comillas —COMPARTIDO con el detector de
# escrituras (CA-07, CA-13)— borra lo entrecomillado antes de mirar el comando. No es una
# regresion: en v1.30.3 publicada el mismo descuento deja pasar `echo x > "src/a.ts"`, y
# su arreglo esta declarado y asignado a REQ-007 Bloque C (CA-14…CA-18), ventana 1.32.0.
# Estos casos fijan la conducta MEDIDA HOY para que el cambio se vea cuando aterrice: al
# arreglar el Bloque C estos dos `allow` pasaran a `deny` y el banco lo dira en voz alta.
check "QA 1.31.0 v3: QA-113 'git clean \"-f\"' -> allow (hoy; cambia con REQ-007 Bloque C)" allow guard-git.sh \
  "$(emite_bash 'git clean "-f"' "" "")"
check "QA 1.31.0 v3: QA-113 'git checkout \".\"' -> allow (hoy; cambia con REQ-007 Bloque C)" allow guard-git.sh \
  "$(emite_bash 'git checkout "."' "" "")"
# CONTROL, y es el que hace legible al hallazgo: el MISMO comando sin comillas si se deniega.
check "QA 1.31.0 v3: QA-113 control: 'git clean -f' desnudo sigue deny" deny guard-git.sh \
  "$(emite_bash 'git clean -f' "" "")"

# QA 1.31.0 v3: los bordes del FIN DE OPCIONES que CA-21.4 no enumera, medidos uno a uno.
# Detras de `--` no hay opciones: tampoco con el valor pegado, tampoco si el `--` se
# repite. Y la mitad que sostiene la regla: la opcion escrita ANTES del `--` sigue casando.
check "QA 1.31.0 v3: valor pegado tras '--': 'git clean -- --force=x' -> allow" allow guard-git.sh \
  "$(emite_bash 'git clean -- --force=x' "" "")"
check "QA 1.31.0 v3: '--' repetido: 'git clean -- -- -f' -> allow" allow guard-git.sh \
  "$(emite_bash 'git clean -- -- -f' "" "")"
check "QA 1.31.0 v3: la opcion ANTES del '--' casa igual: 'git clean -f -- -f' -> deny" deny guard-git.sh \
  "$(emite_bash 'git clean -f -- -f' "" "")"
# `--` como UNICO argumento: no hay opcion que casar (regla con token) y tampoco hay
# posicional que quite la forma desnuda (regla sin tokens). Los dos lados, medidos.
check "QA 1.31.0 v3: '--' unico argumento: 'git clean --' -> allow" allow guard-git.sh \
  "$(emite_bash 'git clean --' "" "")"
check "QA 1.31.0 v3: '--' unico argumento: 'git stash --' -> deny (sigue siendo la forma desnuda)" deny guard-git.sh \
  "$(emite_bash 'git stash --' "" "")"
# La excepcion de `restore` y el fin de opciones, en sus dos direcciones: con `--staged`
# como OPCION el arbol no se toca (allow); detras del `--` es una RUTA, y entonces el
# comando restaura el arbol de verdad (deny).
check "QA 1.31.0 v3: 'git restore --staged -- .' -> allow (solo rehace el indice)" allow guard-git.sh \
  "$(emite_bash 'git restore --staged -- .' "" "")"
check "QA 1.31.0 v3: 'git restore -- --staged .' -> deny (tras '--' es una ruta, no la opcion)" deny guard-git.sh \
  "$(emite_bash 'git restore -- --staged .' "" "")"
check "CA-14 'github clone x' -> allow"             allow guard-git.sh "$(emite_bash 'github clone x' "" "")"
check "CA-14 'mygit clean -f' -> allow"             allow guard-git.sh "$(emite_bash 'mygit clean -f' "" "")"
check "CA-15 'echo \"git clean -f\"' -> allow"      allow guard-git.sh "$(emite_bash 'echo "git clean -f"' "" "")"
# CA-16: no regresion. El git de todos los dias sigue pasando —y las dos consultas de
# REQ-002 (`git log`, `git status`) son lecturas y conviven con esta puerta.
check "CA-16 'git status' -> allow"                 allow guard-git.sh "$(emite_bash 'git status --porcelain' "" "")"
check "CA-16 'git log' -> allow"                    allow guard-git.sh "$(emite_bash 'git log -1 --format=%cs -- src/' "" "")"
check "CA-16 'git add .' y 'git commit' -> allow"   allow guard-git.sh "$(emite_bash 'git add . && git commit -m listo' "" "")"

# --- El manifiesto: mecanismo aqui, mapeo alli ---
setcfg '.git = {"activo": false}'
check "CA-18 git.activo:false -> allow (acto explicito del proyecto)" allow guard-git.sh "$(emite_bash 'git clean -fd' "" "")"
setcfg '.git = {"prohibidos": []}'
check "CA-20 lista vacia: una decision declarada, no un error -> allow" allow guard-git.sh "$(emite_bash 'git reset --hard' "" "")"
setcfg '.git = {"prohibidos": ["push --force"]}'
check "CA-19 lista propia: 'git clean -fd' ya no esta en ella -> allow" allow guard-git.sh "$(emite_bash 'git clean -fd' "" "")"
check "CA-19 lista propia: 'git push --force origin main' -> deny" deny guard-git.sh "$(emite_bash 'git push --force origin main' "" "")"
# DEV 1.31.0 v2: QA-101 al reves. El proyecto declaro la forma LARGA; la corta es el mismo
# flag y tiene que casar igual. Por esto la equivalencia esta en el MOTOR: si viviera en la
# lista por defecto, una lista propia como esta la perderia sin enterarse.
check "DEV 1.31.0 v2: QA-101 lista propia con la larga: 'git push -f origin main' -> deny" deny guard-git.sh \
  "$(emite_bash 'git push -f origin main' "" "")"
check "DEV 1.31.0 v2: QA-101 control: '--force-with-lease' no es '--force' -> allow" allow guard-git.sh \
  "$(emite_bash 'git push --force-with-lease origin main' "" "")"
# DEV 1.31.0 v2: UN CASO POR ENTRADA DE LA TABLA DE EQUIVALENCIAS (CA-21.2). Una tabla del
# mecanismo cuyas filas nadie mide es una afirmacion, no un mecanismo; y el control de al
# lado es el que impide que la equivalencia se vuelva ancha: cada token casa con SUS
# ortografias, no con las del vecino.
setcfg '.git = {"prohibidos": ["clean -d"]}'
check "DEV 1.31.0 v2: QA-101 '--directory' es la larga de 'clean -d' -> deny" deny guard-git.sh \
  "$(emite_bash 'git clean --directory' "" "")"
check "DEV 1.31.0 v2: QA-101 control: '--dry-run' es la de '-n', no la de '-d' -> allow" allow guard-git.sh \
  "$(emite_bash 'git clean --dry-run' "" "")"
setcfg '.git = {"prohibidos": ["stash -u"]}'
check "DEV 1.31.0 v2: QA-101 '--include-untracked' es la larga de 'stash -u' -> deny" deny guard-git.sh \
  "$(emite_bash 'git stash --include-untracked' "" "")"
setcfg '.git = {"prohibidos": ["stash -a"]}'
check "DEV 1.31.0 v2: QA-101 '--all' es la larga de 'stash -a' -> deny" deny guard-git.sh \
  "$(emite_bash 'git stash --all' "" "")"
setcfg '.git = {"prohibidos": ["reset --hard"]}'
check "CA-21 el token en otra posicion del segmento -> deny igual" deny guard-git.sh "$(emite_bash 'git reset HEAD~1 --hard' "" "")"
setcfg 'del(.git)'

# DEV 1.31.0 v4 (SEC-009): CONSTRUCCIONES ORDINARIAS DEL SHELL. El auditor midio SIETE
# formas que atravesaban esta puerta —la unica que nace encendida— mientras `git clean -fd`
# desnudo denegaba. No son sintaxis exotica: `if [ … ]; then git clean -fd; fi` es
# exactamente como se escribe una limpieza condicional, y se pisa SIN QUERER. La causa era
# doble: la segmentacion no partia por `&` sencillo ni plegaba la continuacion de linea, y
# el bucle de prefijos descartaba el segmento entero en cuanto empezaba por una palabra
# reservada (`then`, `do`, `{`). Una forma, un caso: si manana alguien vuelve a estrechar
# el bucle, el banco lo dice en voz alta y no un auditor tres meses despues.
check "DEV 1.31.0 v4: SEC-009 'if true; then git clean -fd; fi' -> deny" deny guard-git.sh \
  "$(emite_bash 'if true; then git clean -fd; fi' "" "")"
check "DEV 1.31.0 v4: SEC-009 '{ git clean -fd; }' -> deny" deny guard-git.sh \
  "$(emite_bash '{ git clean -fd; }' "" "")"
check "DEV 1.31.0 v4: SEC-009 'for i in 1; do git clean -fd; done' -> deny" deny guard-git.sh \
  "$(emite_bash 'for i in 1; do git clean -fd; done' "" "")"
check "DEV 1.31.0 v4: SEC-009 'sleep 0 & git clean -fd' (el & sencillo separa) -> deny" deny guard-git.sh \
  "$(emite_bash 'sleep 0 & git clean -fd' "" "")"
check "DEV 1.31.0 v4: SEC-009 'nohup git clean -fd' -> deny" deny guard-git.sh \
  "$(emite_bash 'nohup git clean -fd' "" "")"
check "DEV 1.31.0 v4: SEC-009 continuacion de linea 'git clean \\<salto> -fd' -> deny" deny guard-git.sh \
  "$(emite_bash 'git clean \
 -fd' "" "")"
# Las dos que el arreglo alcanza de paso, y que valen por si solas: un envoltorio CON
# ARGUMENTO (`timeout 30`) y la negacion.
check "DEV 1.31.0 v4: SEC-009 'timeout 30 git clean -fd' (envoltorio con argumento) -> deny" deny guard-git.sh \
  "$(emite_bash 'timeout 30 git clean -fd' "" "")"
check "DEV 1.31.0 v4: SEC-009 '! git reset --hard' -> deny" deny guard-git.sh \
  "$(emite_bash '! git reset --hard' "" "")"
check "DEV 1.31.0 v4: SEC-009 'while read x; do git checkout .; done' -> deny" deny guard-git.sh \
  "$(emite_bash 'while read x; do git checkout .; done' "" "")"
# CONTROLES, y son la mitad que sostiene el arreglo: tolerar palabras reservadas ensancha
# donde la puerta MIRA, no lo que deniega. El nombre `git` tiene que seguir siendo un
# COMANDO y no un texto; si estos se volvieran deny, el arreglo habria creado el falso
# positivo que acaba con alguien apagando el guard.
check "DEV 1.31.0 v4: SEC-009 control: 'echo git clean -f' sigue allow" allow guard-git.sh \
  "$(emite_bash 'echo git clean -f' "" "")"
check "DEV 1.31.0 v4: SEC-009 control: grep de un texto que dice 'then git clean -fd' -> allow" allow guard-git.sh \
  "$(emite_bash 'grep -rn "then git clean -fd" docs/' "" "")"
check "DEV 1.31.0 v4: SEC-009 control: 'if true; then git status; fi' -> allow" allow guard-git.sh \
  "$(emite_bash 'if true; then git status; fi' "" "")"
check "DEV 1.31.0 v4: SEC-009 control: 'echo hi >&2 && git add .' -> allow" allow guard-git.sh \
  "$(emite_bash 'echo hi >&2 && git add .' "" "")"

# DEV 1.31.0 v4 (SEC-012 / QA-113 / CA-21.5): LAS SEIS FORMAS DEL TOKEN ENTRECOMILLADO O
# ESCAPADO, no dos. El criterio enumera seis y solo dos tenian caso; un criterio sin caso
# se desfasa, y las cuatro que faltaban son exactamente por donde entraria una regresion
# silenciosa. Hoy las seis son ALLOW: es el LIMITE DECLARADO LIM-10, heredado del descuento
# de comillas que esta puerta comparte a proposito con el detector de escrituras, con su
# arreglo asignado a REQ-007 Bloque C (1.32.0). Cuando el Bloque C aterrice, LAS SEIS pasan
# a DENY a la vez y este bloque cambia EN VOZ ALTA; si alguna se quedara en ALLOW, es que
# el arreglo fue parcial y el banco lo dira.
check "DEV 1.31.0 v4: CA-21.5 'git reset \"--hard\"' -> allow (LIM-10; cambia en 1.32.0)" allow guard-git.sh \
  "$(emite_bash 'git reset "--hard"' "" "")"
check "DEV 1.31.0 v4: CA-21.5 'git \"clean\" -f' (el SUBCOMANDO entrecomillado) -> allow (LIM-10)" allow guard-git.sh \
  "$(emite_bash 'git "clean" -f' "" "")"
check "DEV 1.31.0 v4: CA-21.5 'git clean \\-f' (escapado, no entrecomillado) -> allow (LIM-10)" allow guard-git.sh \
  "$(emite_bash 'git clean \-f' "" "")"
check "DEV 1.31.0 v4: CA-21.5 'git stash \"save\" wip' (alias entrecomillado) -> allow (LIM-10)" allow guard-git.sh \
  "$(emite_bash 'git stash "save" wip' "" "")"
# Y el control que hace legibles a las seis: sin comillas, las mismas ordenes deniegan.
check "DEV 1.31.0 v4: CA-21.5 control: 'git reset --hard' desnudo sigue deny" deny guard-git.sh \
  "$(emite_bash 'git reset --hard' "" "")"
check "DEV 1.31.0 v4: CA-21.5 control: 'git stash save wip' desnudo sigue deny" deny guard-git.sh \
  "$(emite_bash 'git stash save wip' "" "")"

# DEV 1.31.0 v4 (SEC-010): UN MANIFIESTO ILEGIBLE NO APAGA ESTA PUERTA.
# Medido antes del arreglo: con el JSON roto —o vacio, o un array, o `git` del tipo
# equivocado— `git clean -fd` salia ALLOW mientras el aviso del arnes afirmaba que toda
# escritura se deniega. Y en un proyecto plantilla `.arnes/config.json` no esta protegido:
# la unica puerta encendida por defecto tenia un interruptor de apagado alcanzable en UNA
# escritura, y por accidente. Ahora cae a la lista que trae el CODIGO y deniega.
for MROTO in '{"agentes":{,}' '' '[]' '{"git":"si"}'; do
  ETIQ="$(printf '%s' "${MROTO:-<vacio>}" | head -c 20)"
  printf '%s' "$MROTO" > "$PROJ/.arnes/config.json"
  check "DEV 1.31.0 v4: SEC-010 manifiesto ilegible ($ETIQ): 'git clean -fd' -> deny" deny guard-git.sh \
    "$(emite_bash 'git clean -fd' "" "")"
done
printf '%s' '{"agentes":{,}' > "$PROJ/.arnes/config.json"
check_motivo "DEV 1.31.0 v4: SEC-010 el motivo dice MODO DEGRADADO y como salir" 'MODO DEGRADADO.*jq -e' guard-git.sh \
  "$(emite_bash 'git clean -fd' "" "")"
# CONTROL: la averia no convierte esta puerta en un deny universal. Lo que no esta en la
# lista por defecto sigue pasando; si no, el arreglo seria un bloqueo, no una puerta.
check "DEV 1.31.0 v4: SEC-010 control: con el manifiesto roto 'git status' sigue allow" allow guard-git.sh \
  "$(emite_bash 'git status --porcelain' "" "")"
# EL BORDE, declarado a proposito: un proyecto que tenia la puerta APAGADA y se le rompe el
# manifiesto pasa a DENEGAR. Es la direccion segura —apagar es un acto explicito y una coma
# de mas no lo es— y la salida es reparar el JSON, que la excepcion de reparacion permite.
printf '%s' '{"git":{"activo":false},}' > "$PROJ/.arnes/config.json"
check "DEV 1.31.0 v4: SEC-010 borde: 'git.activo:false' + JSON roto -> deny (direccion segura)" deny guard-git.sh \
  "$(emite_bash 'git clean -fd' "" "")"
printf '%s\n' "$MANIFIESTO_BASE" > "$PROJ/.arnes/config.json"
# Y el control que cierra el borde: con el manifiesto SANO, `activo:false` sigue apagando.
setcfg '.git = {"activo": false}'
check "DEV 1.31.0 v4: SEC-010 control: con el manifiesto SANO 'activo:false' sigue apagando" allow guard-git.sh \
  "$(emite_bash 'git clean -fd' "" "")"
setcfg 'del(.git)'

# QA 1.31.0 v4 (SEC-009): LA FRONTERA DE LA BARRA INVERTIDA, LEIDA JUNTO A SU VECINA.
# CA-41 lo pide expresamente porque las dos formas se parecen y una de ellas es un LIMITE
# DECLARADO (LIM-10, ventana 1.32.0): plegar la continuacion de linea no puede cerrar de
# rebote el `git clean \-f` escapado. El caso de arriba mide el lado DENY; estos dos miden
# el lado ALLOW por sus dos vecinos exactos, que es donde un plegado descuidado se nota:
# `\` + ESPACIO + salto NO es una continuacion en bash (la barra escapa el espacio), y un
# salto SIN barra son dos ordenes de verdad. Si alguno pasara a deny, el plegado se comio
# mas de lo que el criterio le concede.
check "QA 1.31.0 v4: SEC-009 frontera '\\'+ESPACIO+salto NO es continuacion -> allow" allow guard-git.sh \
  "$(emite_bash 'git clean \ 
-fd' "" "")"
check "QA 1.31.0 v4: SEC-009 frontera salto SIN barra son dos ordenes -> allow" allow guard-git.sh \
  "$(emite_bash 'git
clean -fd' "" "")"
# NO ENSANCHAMIENTO DE LAS PALABRAS RESERVADAS NUEVAS. El bucle de prefijos tolera ahora
# `for`, `case`, `in`, `function`, `{`… y ninguna de ellas puede convertir en comando un
# `git` que es ARGUMENTO. Tres formas ordinarias en que `git` aparece detras de una
# reservada sin ser el comando: si alguna denegara, el arreglo de SEC-009 seria un falso
# positivo sobre codigo legitimo, y un guardian que muerde a quien no toca acaba apagado.
check "QA 1.31.0 v4: SEC-009 control 'for f in git; do echo \$f; done' -> allow" allow guard-git.sh \
  "$(emite_bash 'for f in git; do echo $f; done' "" "")"
check "QA 1.31.0 v4: SEC-009 control 'case git in *) echo x;; esac' -> allow" allow guard-git.sh \
  "$(emite_bash 'case git in *) echo x;; esac' "" "")"
check "QA 1.31.0 v4: SEC-009 control 'function git_helper { git status; }' -> allow" allow guard-git.sh \
  "$(emite_bash 'function git_helper { git status; }' "" "")"
# CA-41(b): el COMENTARIO. Una palabra reservada nueva no puede convertir en comando lo
# que va detras de un `#`.
check "QA 1.31.0 v4: SEC-009 control CA-41(b) 'echo hola # git clean -fd' -> allow" allow guard-git.sh \
  "$(emite_bash 'echo hola # git clean -fd' "" "")"
# QA 1.31.0 v4 (QA-115): LO QUE EL REQ DECLARA FUERA DE ALCANCE Y EL CODIGO SI VE.
# «Fuera de alcance» de REQ-005 dice, por escrito, que `xargs git clean -fd` NO se ve
# porque el comando viaja como argumento de otro programa. El codigo tolera `xargs` como
# envoltorio, asi que DENIEGA. La direccion es segura y el caso se deja en verde midiendo
# la REALIDAD, no la frase: es el guardian de que el desfase no se olvide. Cuando el
# write-back de QA-115 aterrice —el REQ retira `xargs` de la lista, o el codigo lo retira
# del bucle— este caso cambia EN VOZ ALTA, que es justo lo que se quiere.
check "QA 1.31.0 v4: QA-115 'xargs git clean -fd' -> deny (el REQ lo declara fuera de alcance)" deny guard-git.sh \
  "$(emite_bash 'xargs git clean -fd' "" "")"
# Y el control del mismo envoltorio sobre un subcomando inocuo: no deniega por `xargs`,
# deniega por el subcomando.
check "QA 1.31.0 v4: QA-115 control 'xargs -n1 git status' -> allow" allow guard-git.sh \
  "$(emite_bash 'xargs -n1 git status' "" "")"
# SEC-010: el modo degradado deniega LA LISTA POR DEFECTO, no todo git. `git push --force`
# destruye historia remota y NO esta en la lista por defecto: sigue pasando, igual que con
# el manifiesto sano. El control de `git status` mide lecturas; este mide una escritura
# peligrosa que el mapeo por defecto no reclama, que es el borde util.
printf '%s' '{"agentes":{,}' > "$PROJ/.arnes/config.json"
check "QA 1.31.0 v4: SEC-010 control degradado 'git push --force origin main' -> allow" allow guard-git.sh \
  "$(emite_bash 'git push --force origin main' "" "")"
printf '%s\n' "$MANIFIESTO_BASE" > "$PROJ/.arnes/config.json"

# --- Integracion y orden: guard.sh ---
# CA-24: cuando un comando es a la vez git destructivo y escritura sobre codigo
# protegido, el motivo es el de GIT: la denegacion es final y los demas no corren.
check_motivo "CA-23/CA-24 en guard.sh manda el motivo de git" 'git.prohibidos' guard.sh \
  "$(emite_bash 'git clean -fd && echo x > src/generado.ts' "" "")"
# CA-25: interponer el guardian nuevo no apaga a los que ya estaban.
check_motivo "CA-25 lo que guard-git permite lo sigue juzgando guard-codigo" 'código de la app|codigo de la app|protegid' guard.sh \
  "$(emite_bash 'echo x > src/generado.ts' "" "")"
check "CA-26 un comando sin el token git sigue pasando por guard.sh -> allow" allow guard.sh "$(emite_bash 'ls -la' "" "")"
# CA-28: ejecutado por su cuenta decide igual que dentro de guard.sh.
check "CA-28 guard-git.sh por su cuenta decide igual" deny guard-git.sh "$(emite_bash 'git checkout .' "" "")"
# CA-29: el bit de ejecucion es parte del contrato del punto de entrada.
if [ -x "$HOOKS_DIR/guard-git.sh" ]; then
  echo "  PASS  CA-29 guard-git.sh es ejecutable"; PASS=$((PASS+1))
else
  echo "  FAIL  CA-29 guard-git.sh no tiene bit de ejecucion"; FAIL=$((FAIL+1))
fi
