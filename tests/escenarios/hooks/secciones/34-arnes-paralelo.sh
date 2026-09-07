# Sección 34 del banco — 34-arnes-paralelo (REQ-013)
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
#
# QUÉ ACREDITA: `tools/arnes-paralelo.sh` responde `disjunto`/`colisiona` sobre el campo
# `Archivos:` de la cabecera de los REQ, con la MISMA normalización que leen las puertas,
# y falla cerrado cuando no puede medir. Y el control que separa esta herramienta de una
# novena puerta: el campo nuevo NO cambia ningún veredicto de `guard-completado`.
#
# FAIL-BEFORE: con `ARNES_HOOKS_DIR` apuntando a los hooks de v1.31.0 la herramienta no
# existe (`$HOOKS_DIR/../tools/arnes-paralelo.sh`) y los casos que la ejecutan fallan.
CASOS_ESPERADOS_SECCION=33

seccion_nueva "tools/arnes-paralelo.sh (REQ-013): qué dos comisiones NO colisionan:"

PARA="$HOOKS_DIR/../tools/arnes-paralelo.sh"

# El árbol contra el que se expanden los globs. La intersección se resuelve expandiendo
# CONTRA EL ÁRBOL REAL, así que el árbol es parte del caso.
mkdir -p "$PROJ/hooks" "$PROJ/templates" "$PROJ/docs/qa" "$PROJ/docs/gobernanza" \
         "$PROJ/skills/arnes-panel" "$PROJ/tests/escenarios/hooks" "$PROJ/tools"
for a in hooks/lib.sh hooks/guard-codigo.sh hooks/guard-completado.sh hooks/guard-git.sh \
         hooks/hooks.json templates/AGENTS.md.tpl templates/requirements-README.md.tpl \
         docs/qa/1.32.0.md docs/gobernanza/x.md skills/arnes-panel/SKILL.md \
         tests/escenarios/hooks/run.sh tools/arnes-lectura.sh; do
  : > "$PROJ/$a"
done

# pr <id> <valor del campo Archivos:> — un REQ abierto con su mapa declarado.
pr() { printf '# %s\nEstado: pendiente\nArchivos: %s\n\n## Historia\ncuerpo\n' "$1" "$2" \
         > "$PROJ/requirements/$1.md"; }

# par_check <nombre> <rc esperado> <regex que debe casar> <argumentos de la herramienta...>
# GUARDA DE SALIDA VACÍA (invariante 1 del banco): una herramienta muda no es un caso que
# pasa, es un caso que no se ejecutó. Los modos degradados hablan por stderr, así que se
# mira también ahí antes de declarar el silencio.
par_check() {
  local nombre="$1" rc_esp="$2" patron="$3"; shift 3
  local out rc
  if [ -n "$FILTRO" ] && ! printf '%s' "$nombre" | grep -qi -- "$FILTRO"; then return 0; fi
  : > "$ERRLOG"
  out="$(bash "$PARA" --proyecto "$PROJ" "$@" 2>"$ERRLOG")"; rc=$?
  [ -n "$out" ] || out="$(cat "$ERRLOG")"
  if [ -z "$out" ]; then
    echo "  FAIL  $nombre  la herramienta no imprimio NADA: el caso no midio nada"
    FAIL=$((FAIL+1)); return 0
  fi
  if [ "$rc" != "$rc_esp" ]; then
    echo "  FAIL  $nombre  rc=$rc (esperado $rc_esp)"; diag
    printf '%s\n' "$out" | head -8 | sed 's/^/          salida| /'; FAIL=$((FAIL+1)); return 0
  fi
  if ! printf '%s' "$out" | grep -Eq -- "$patron"; then
    echo "  FAIL  $nombre  la salida no casa /$patron/"
    printf '%s\n' "$out" | head -8 | sed 's/^/          salida| /'; FAIL=$((FAIL+1)); return 0
  fi
  echo "  PASS  $nombre"; PASS=$((PASS+1))
}

# --- CA-07: la colisión se decide por INTERSECCIÓN DE GLOBS, no por igualdad de cadena.
# Comparar cadenas declararía disjuntos los tres primeros pares, que es justo la forma de
# error que produce un conflicto de fusión.
pr REQ-701 'hooks/lib.sh'
pr REQ-702 'hooks/*.sh'
par_check "paralelo: hooks/lib.sh vs hooks/*.sh -> colisiona" 1 \
  'REQ-701 +vs +REQ-702 +colisiona +hooks/lib\.sh' REQ-701 REQ-702
pr REQ-703 'hooks/hooks.json'
par_check "paralelo: hooks/*.sh vs hooks/hooks.json -> disjunto" 0 \
  'REQ-702 +vs +REQ-703 +disjunto' REQ-702 REQ-703
pr REQ-704 'tests/escenarios/hooks/run.sh'
pr REQ-705 'tests/**'
par_check "paralelo: run.sh vs tests/** -> colisiona" 1 \
  'REQ-704 +vs +REQ-705 +colisiona +tests/escenarios/hooks/run\.sh' REQ-704 REQ-705
pr REQ-706 'docs/qa/1.32.0.md'
pr REQ-707 'docs/qa/*.md'
par_check "paralelo: docs/qa/1.32.0.md vs docs/qa/*.md -> colisiona" 1 \
  'REQ-706 +vs +REQ-707 +colisiona +docs/qa/1\.32\.0\.md' REQ-706 REQ-707
pr REQ-708 'templates/AGENTS.md.tpl'
pr REQ-709 'templates/requirements-README.md.tpl'
par_check "paralelo: dos plantillas distintas -> disjunto" 0 \
  'REQ-708 +vs +REQ-709 +disjunto' REQ-708 REQ-709

# --- CA-08: el mismo archivo alcanzado por DOS GLOBS DISTINTOS, y el archivo que aún no
# existe. `hooks/guard-*.sh` y `hooks/*completado*` no se parecen como cadenas.
pr REQ-710 'hooks/guard-*.sh'
pr REQ-711 'hooks/*completado*'
par_check "paralelo: dos globs distintos que alcanzan el mismo archivo -> colisiona y lo nombra" 1 \
  'REQ-710 +vs +REQ-711 +colisiona +hooks/guard-completado\.sh' REQ-710 REQ-711
pr REQ-712 'hooks/post-bash.sh'
pr REQ-713 'hooks/post-bash.sh, docs/otro.md'
par_check "paralelo: un archivo que TODAVIA NO EXISTE se compara como ruta literal" 1 \
  'REQ-712 +vs +REQ-713 +colisiona +hooks/post-bash\.sh' REQ-712 REQ-713

# --- CA-09 (control positivo) y CA-10 (`(ninguno)` es una declaración, no una omisión).
pr REQ-714 'docs/gobernanza/x.md'
pr REQ-715 'skills/arnes-panel/SKILL.md'
par_check "paralelo: control positivo, dos rutas ajenas -> disjunto y rc 0" 0 \
  'REQ-714 +vs +REQ-715 +disjunto' REQ-714 REQ-715
pr REQ-716 '(ninguno)'
par_check "paralelo: (ninguno) es disjunto con todos, no 'sin declarar'" 0 \
  'REQ-716 +vs +REQ-701 +disjunto' REQ-716 REQ-701

# --- CA-11: normalización de rutas, y fail-closed con la absoluta.
pr REQ-717 './hooks/lib.sh'
pr REQ-718 'hooks//lib.sh'
pr REQ-719 'hooks/../hooks/lib.sh'
par_check "paralelo: ./x y x//y se normalizan a la misma ruta -> colisiona" 1 \
  'REQ-717 +vs +REQ-718 +colisiona +hooks/lib\.sh' REQ-717 REQ-718
par_check "paralelo: x/../x se normaliza a la misma ruta -> colisiona" 1 \
  'REQ-719 +vs +REQ-701 +colisiona +hooks/lib\.sh' REQ-719 REQ-701
pr REQ-720 '/home/x/repo/hooks/lib.sh'
par_check "paralelo: una ruta ABSOLUTA se rechaza con motivo propio y deja el REQ sin declarar" 1 \
  'REQ-720.*SIN DECLARAR: ruta absoluta' REQ-720 REQ-701
pr REQ-721 '../fuera-del-arbol.sh'
par_check "paralelo: una ruta que SALE de la raiz se rechaza igual (fail-closed)" 1 \
  'REQ-721.*SIN DECLARAR.*sale de la ra' REQ-721 REQ-701

# --- CA-04: sin mapa no hay paralelismo. El modo por defecto es la serie.
printf '# REQ-722\nEstado: pendiente\n\n## Historia\ncuerpo\n' > "$PROJ/requirements/REQ-722.md"
par_check "paralelo: un REQ SIN el campo colisiona con todos y sale != 0" 1 \
  'REQ-722 +vs +REQ-701 +colisiona +\(sin declarar\)' REQ-722 REQ-701
pr REQ-723 ''
par_check "paralelo: un valor vacio no se interpreta: sin declarar" 1 \
  'REQ-723.*SIN DECLARAR' REQ-723 REQ-701

# --- CA-03: las mismas tolerancias que los demás campos, ni una más — y la misma frontera.
{ printf '# REQ-724\nEstado: pendiente\n'
  printf '   **Archivos:**\t `hooks/lib.sh` ,  hooks/hooks.json  \n'
  printf '\n## Historia\ncuerpo\n'; } > "$PROJ/requirements/REQ-724.md"
par_check "paralelo: clave decorada, sangrado, tabulador y acentos graves se reconocen" 1 \
  'REQ-724 +vs +REQ-703 +colisiona +hooks/hooks\.json' REQ-724 REQ-703
{ printf '# REQ-725\nEstado: pendiente\n\n## Historia\n'
  printf 'Archivos: hooks/lib.sh\n'; } > "$PROJ/requirements/REQ-725.md"
par_check "paralelo: el campo DEBAJO del primer '## ' no es una declaracion" 1 \
  'REQ-725.*SIN DECLARAR' REQ-725 REQ-701
pr REQ-726 'hooks/lib.sh, tools/arnes-lectura.sh (medido el 6/9, 2 archivos)'
par_check "paralelo: el parentesis final es EVIDENCIA, no un tercer archivo" 1 \
  'REQ-726 +pendiente +hooks/lib\.sh tools/arnes-lectura\.sh$' REQ-726 REQ-701

# --- CA-06: sin argumentos toma los REQ ABIERTOS, y `--json` da JSON válido.
if [ -z "$FILTRO" ] || printf '%s' "paralelo: json" | grep -qi -- "$FILTRO"; then
  : > "$ERRLOG"
  salida="$(bash "$PARA" --proyecto "$PROJ" --json REQ-701 REQ-702 2>"$ERRLOG")"; rc=$?
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: json  la herramienta no imprimio NADA"; diag; FAIL=$((FAIL+1))
  elif [ "$rc" -eq 1 ] && printf '%s' "$salida" | jq -e '.resultado == "colisiona"' >/dev/null 2>&1 \
       && printf '%s' "$salida" | jq -e '.pares[0].compartido == "hooks/lib.sh"' >/dev/null 2>&1; then
    echo "  PASS  paralelo: --json es JSON valido y dice lo mismo que el texto"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: --json  rc=$rc o el JSON no dice lo mismo que el texto"
    # `head -c 300` corta por BYTES y puede dejar la última línea sin `\n`: entonces el
    # `  PASS ` siguiente se pega a ésta y el recuento por archivo pierde un caso —
    # medido en el fail-before de esta misma vuelta (43 declarados, 42 contados).
    printf '%s\n' "${salida:0:300}" | sed 's/^/          salida| /'; FAIL=$((FAIL+1))
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "paralelo: abiertos" | grep -qi -- "$FILTRO"; then
  rm -f "$PROJ"/requirements/REQ-7*.md
  pr REQ-730 'hooks/lib.sh'
  pr REQ-731 'docs/gobernanza/x.md'
  printf '# REQ-732\nEstado: completado\nArchivos: hooks/lib.sh\n\n## Historia\n' > "$PROJ/requirements/REQ-732.md"
  : > "$ERRLOG"
  salida="$(bash "$PARA" --proyecto "$PROJ" 2>"$ERRLOG")"; rc=$?
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: abiertos  la herramienta no imprimio NADA"; diag; FAIL=$((FAIL+1))
  elif [ "$rc" -eq 0 ] && printf '%s' "$salida" | grep -q '2 REQ evaluados' \
       && ! printf '%s' "$salida" | grep -q 'REQ-732'; then
    echo "  PASS  paralelo: sin argumentos toma los REQ abiertos y salta los cerrados"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: sin argumentos  rc=$rc; deberia evaluar 2 y no nombrar al cerrado"
    printf '%s\n' "$salida" | head -8 | sed 's/^/          salida| /'; FAIL=$((FAIL+1))
  fi
fi

# --- CA-18: la herramienta responde sobre ARCHIVOS y lo dice. Sin esta línea un
# `disjunto` se lee como permiso para lanzar QA y el auditor a la vez.
par_check "paralelo: la salida advierte que NO evalua el orden de fases" 0 \
  'NO el orden de fases' REQ-730 REQ-731
if [ -z "$FILTRO" ] || printf '%s' "paralelo: advertencia json" | grep -qi -- "$FILTRO"; then
  : > "$ERRLOG"
  salida="$(bash "$PARA" --proyecto "$PROJ" --json REQ-730 REQ-731 2>"$ERRLOG")"
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: advertencia json  la herramienta no imprimio NADA"; diag; FAIL=$((FAIL+1))
  elif printf '%s' "$salida" | jq -e '.advertencia | test("orden de fases")' >/dev/null 2>&1; then
    echo "  PASS  paralelo: la advertencia del orden de fases tambien viaja en --json"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: la advertencia del orden de fases NO esta en --json"; FAIL=$((FAIL+1))
  fi
fi

# --- CA-12 y CA-19: la herramienta es de SÓLO LECTURA e informa sin decidir.
if [ -z "$FILTRO" ] || printf '%s' "paralelo: solo lectura" | grep -qi -- "$FILTRO"; then
  antes="$(find "$PROJ" -type f -printf '%p %s\n' 2>/dev/null | sort)"
  : > "$ERRLOG"
  salida="$(bash "$PARA" --proyecto "$PROJ" 2>"$ERRLOG")"
  despues="$(find "$PROJ" -type f -printf '%p %s\n' 2>/dev/null | sort)"
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: solo lectura  la herramienta no imprimio NADA"; diag; FAIL=$((FAIL+1))
  elif [ "$antes" = "$despues" ]; then
    echo "  PASS  paralelo: no escribe ni un archivo en el proyecto (ni un temporal)"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: el arbol del proyecto CAMBIO al ejecutarla"
    diff <(printf '%s\n' "$antes") <(printf '%s\n' "$despues") | head -6 | sed 's/^/          /'
    FAIL=$((FAIL+1))
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "paralelo: no despacha" | grep -qi -- "$FILTRO"; then
  # Los comentarios de cabecera SI nombran la cola —para declarar que no la tocan—, asi
  # que se miran las lineas de CODIGO: lo que cuenta es lo que la herramienta ejecuta.
  # Y primero se exige que el archivo EXISTA: un `grep` sobre un archivo ausente no
  # encuentra nada y este caso pasaria en verde contra un arbol sin la herramienta —
  # exactamente la clase de verde falso que este banco existe para no tener.
  if [ ! -f "$PARA" ]; then
    echo "  FAIL  paralelo: no existe la herramienta $PARA: el caso no midio nada"; FAIL=$((FAIL+1))
  elif grep -v '^[[:space:]]*#' "$PARA" | grep -Eq 'PENDING_APPROVAL|Task\(|subagent'; then
    echo "  FAIL  paralelo: la herramienta menciona la cola de aprobaciones o un agente: informa, no despacha"; FAIL=$((FAIL+1))
  else
    echo "  PASS  paralelo: no invoca agentes ni toca PENDING_APPROVAL.md"; PASS=$((PASS+1))
  fi
fi

# --- CA-13: modo degradado DECLARADO. Una herramienta que no midió no responde «adelante».
if [ -z "$FILTRO" ] || printf '%s' "paralelo: sin jq" | grep -qi -- "$FILTRO"; then
  vac="$RAIZ/sinjq-$BASHPID"; mkdir -p "$vac"
  salida="$(PATH="$vac" "$BASH" "$PARA" --proyecto "$PROJ" REQ-730 REQ-731 2>&1)"; rc=$?
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: sin jq  no dijo NADA: un silencio no es un modo degradado"; FAIL=$((FAIL+1))
  elif [ "$rc" -eq 2 ] && printf '%s' "$salida" | grep -q 'jq'; then
    echo "  PASS  paralelo: sin jq lo dice y sale 2, no responde 'adelante'"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: sin jq  rc=$rc (esperado 2) <${salida:0:120}>"; FAIL=$((FAIL+1))
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "paralelo: sin manifiesto" | grep -qi -- "$FILTRO"; then
  sinman="$RAIZ/sinman-$BASHPID"; mkdir -p "$sinman/requirements"
  salida="$(bash "$PARA" --proyecto "$sinman" 2>&1)"; rc=$?
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: sin manifiesto  no dijo NADA"; FAIL=$((FAIL+1))
  elif [ "$rc" -eq 2 ] && printf '%s' "$salida" | grep -q 'config.json'; then
    echo "  PASS  paralelo: sin .arnes/config.json lo dice y sale 2"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: sin manifiesto  rc=$rc (esperado 2) <${salida:0:120}>"; FAIL=$((FAIL+1))
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "paralelo: sin REQ" | grep -qi -- "$FILTRO"; then
  vacio="$RAIZ/vacio-$BASHPID"; mkdir -p "$vacio/.arnes" "$vacio/requirements"
  cp "$PROJ/.arnes/config.json" "$vacio/.arnes/config.json"
  salida="$(bash "$PARA" --proyecto "$vacio" 2>&1)"; rc=$?
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: requirements vacio  no dijo NADA"; FAIL=$((FAIL+1))
  elif [ "$rc" -eq 2 ] && printf '%s' "$salida" | grep -qi 'no hay'; then
    echo "  PASS  paralelo: un requirements/ vacio lo dice y sale 2, no dice 'todo disjunto'"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: requirements vacio  rc=$rc (esperado 2) <${salida:0:120}>"; FAIL=$((FAIL+1))
  fi
fi

# --- CA-15 y CA-30: es una herramienta de DESPACHO, no de la ruta caliente.
if [ -z "$FILTRO" ] || printf '%s' "paralelo: fuera de hooks.json" | grep -qi -- "$FILTRO"; then
  if grep -q 'arnes-paralelo' "$HOOKS_DIR/hooks.json"; then
    echo "  FAIL  paralelo: la herramienta esta registrada en hooks.json: entraria en la ruta caliente"; FAIL=$((FAIL+1))
  else
    echo "  PASS  paralelo: no esta registrada en ningun hook (0 procesos anadidos por comando)"; PASS=$((PASS+1))
  fi
fi
if [ -z "$FILTRO" ] || printf '%s' "paralelo: sintaxis" | grep -qi -- "$FILTRO"; then
  if bash -n "$PARA" 2>"$ERRLOG"; then
    echo "  PASS  paralelo: bash -n pasa sobre la herramienta"; PASS=$((PASS+1))
  else
    echo "  FAIL  paralelo: bash -n falla sobre la herramienta"; diag; FAIL=$((FAIL+1))
  fi
fi

# --- CA-05 (CONTROL): esto no es una novena puerta. El campo nuevo —ausente, vacío o mal
# escrito— no cambia NINGÚN veredicto de `guard-completado`. Si esta pareja se rompiera, el
# REQ habría añadido una regla que nadie pidió.
seccion_nueva
mkreq "$PROJ/requirements/REQ-740.md" "no" "aprobado" "n/a"
check "paralelo/CA-05: un REQ SIN Archivos: cierra igual que en v1.31.0 -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-740.md" "" "" 'Estado: completado')"
mkreq "$PROJ/requirements/REQ-741.md" "no" "aprobado" "n/a"
printf 'Archivos: /ruta/absoluta/mal, , ../fuera\n' >> "$PROJ/requirements/REQ-741.md"
check "paralelo/CA-05: un Archivos: ilegible tampoco bloquea el cierre -> allow" allow guard-completado.sh \
  "$(emite_edit "$PROJ/requirements/REQ-741.md" "" "" 'Estado: completado')"

# --- CA-14: el COSTE. 60 REQ y 200 archivos declarados, con los binarios instrumentados
# en el PATH para contar los procesos externos de verdad y no de memoria.
if [ -z "$FILTRO" ] || printf '%s' "paralelo: coste" | grep -qi -- "$FILTRO"; then
  gr="$RAIZ/grande-$BASHPID"; mkdir -p "$gr/.arnes" "$gr/requirements" "$gr/src"
  cp "$PROJ/.arnes/config.json" "$gr/.arnes/config.json"
  i=1; while [ "$i" -le 200 ]; do : > "$gr/src/a$i.txt"; i=$((i+1)); done
  i=1; while [ "$i" -le 60 ]; do
    a=$(( (i-1)*3 + 1 ))
    printf '# REQ-%03d\nEstado: pendiente\nArchivos: src/a%d.txt, src/a%d.txt, src/a%d.txt\n\n## Historia\n' \
      "$i" "$a" "$((a+1))" "$((a+2))" > "$gr/requirements/$(printf 'REQ-%03d' "$i").md"
    i=$((i+1))
  done
  instr="$RAIZ/instr-$BASHPID"; mkdir -p "$instr"
  proclog="$RAIZ/procs-$BASHPID.log"; : > "$proclog"
  for b in jq grep sed awk find ls sort cat tr cut head tail basename dirname realpath; do
    real="$(command -v "$b" 2>/dev/null)"
    { printf '#!/bin/sh\nprintf "%%s\\n" "%s" >> "%s"\n' "$b" "$proclog"
      if [ -n "$real" ]; then printf 'exec "%s" "$@"\n' "$real"; else printf 'exit 127\n'; fi
    } > "$instr/$b"
    chmod 755 "$instr/$b"
  done
  t0="$(date +%s%N)"
  salida="$(PATH="$instr:$PATH" bash "$PARA" --proyecto "$gr" 2>"$ERRLOG")"; rc=$?
  t1="$(date +%s%N)"
  ms=$(( (t1 - t0) / 1000000 ))
  procs="$(grep -c . "$proclog" 2>/dev/null)"; procs="${procs:-0}"
  if [ -z "$salida" ]; then
    echo "  FAIL  paralelo: coste  la herramienta no imprimio NADA con 60 REQ"; diag; FAIL=$((FAIL+1))
    echo "  FAIL  paralelo: coste  ...y por lo mismo el recuento de procesos no midio nada"; FAIL=$((FAIL+1))
  else
    # El techo del tiempo es HOLGADO a proposito: 2 000 ms es el criterio, y en esta
    # maquina se mide en decenas. Un techo pegado a lo medido produce rojos que la gente
    # aprende a relanzar, y un rojo que se relanza deja de significar algo.
    if [ "$rc" -eq 0 ] && [ "$ms" -lt 2000 ]; then
      echo "  PASS  paralelo: 60 REQ y 200 archivos en ${ms}ms (techo 2000ms)"; PASS=$((PASS+1))
    else
      echo "  FAIL  paralelo: 60 REQ y 200 archivos: rc=$rc, ${ms}ms (techo 2000ms)"; diag; FAIL=$((FAIL+1))
    fi
    if [ "$procs" -le 120 ]; then
      echo "  PASS  paralelo: $procs proceso(s) externo(s) para 60 REQ (techo 2 por REQ = 120)"; PASS=$((PASS+1))
    else
      echo "  FAIL  paralelo: $procs procesos externos para 60 REQ (techo 120)"
      sort "$proclog" | uniq -c | sed 's/^/          /'; FAIL=$((FAIL+1))
    fi
  fi
fi
