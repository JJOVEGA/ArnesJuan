# Sección 40 (5 de 5) del banco — 40-ausencia-que-abre-5-el-radio-por-acto
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-024 `CA-05` · SEC-083 · `D12`. EL RADIO DE MIGRACIÓN, **POR ACTO**. `CA-05` fue reenunciado
# por acto el 2026-09-10 (`ADR-011`) y contrata DOS cosas a la vez: (1) que el acto de CIERRE
# decida IDÉNTICO sobre un proyecto SIN MIGRAR, y (2) que el otro acto que SÍ diverge esté
# DECLARADO —dirección restrictiva, dentro del criterio, y donde lo ve quien migra—. La parte 2
# mide (1) sobre el corpus REAL de `requirements/`; ésta mide LAS DOS MITADES sobre una MATRIZ
# de formas de cabecera × actos × estados de la llave.
#
# NO ES UNA SEGUNDA TRANSCRIPCIÓN DE LA PARTE 2, y su motivo es lo único difícil de este archivo.
# Un caso que sólo comprobara «todas las celdas del cierre, iguales» saldría VERDE también si el
# materializador de la línea base fallara y estuviera comparando el árbol CONTRA SÍ MISMO: una
# equivalencia que se cumple porque nada se mide es el fail-open de un instrumento, la familia
# que `REQ-020` existe para cazar. Así que está CONDICIONADA a dos cosas medidas EN LA MISMA
# CORRIDA: que la línea base sea OTRO árbol (caso 1) y que el diferencial DETECTE al menos una
# divergencia en el otro acto (caso 3, a la vez CONTROL POSITIVO del instrumento y mitad (2) del
# criterio). Si el control desaparece, el cierre ABSTIENE en vez de acreditar y el caso 3 FALLA
# diciendo qué se movió: o el código dejó de denegar, o la base dejó de ser la base.
#
# LAS CIFRAS DEL INFORME NO SE RE-DERIVAN NI SE TRANSCRIBEN. El diferencial fechado del
# `desarrollador` (2026-09-10) partió su matriz de otra forma —34 celdas, 28 idénticas y 6
# divergentes, con las 24 del cierre idénticas; sede en `CHANGELOG.md` y `D12`—. Este caso
# publica SU PROPIO denominador en cada corrida: una medición fechada no es umbral de nada y una
# segunda transcripción se desfasa de la primera. Se comparte la PROPIEDAD, no el número.
#
# LOS FAIL-BEFORE, uno por exigencia; con cualquiera puesta la vuelta NO acredita el árbol:
#   ARNES_CA05_BASE=<ref>       la línea base (por defecto `v1.33.0`); con una ref que YA lleve
#                               el arreglo de `SEC-083`, la divergencia desaparece o cambia de
#                               sentido: fail-before de las dos exigencias (i).
#   ARNES_REQ_024=<arch>        el texto del REQ: (ii). Y `ARNES_SKILL_UPGRADE` (la skill, misma
#                               variable y motivo que la parte 3) y `ARNES_PENDING_024` (la cola
#                               de aprobaciones): las dos mitades de (iii).
#
# LO QUE ESTA PARTE **NO** ES: la lista EXHAUSTIVA de actos. Ésa la decide el código y vive en
# las ramas de denegación de `hooks/guard-completado.sh` (`CA-12`, `ADR-011`); aquí se ejercitan
# los DOS que el criterio nombra, y de un acto que no ejercite no dice nada. Fail-closed va la
# otra dirección: un acto que MIDA divergencia y no tenga huella de declaración FALLA nombrado.
CASOS_ESPERADOS_SECCION=7
PISO_AUTONOMO_SECCION=252  # 43 preámbulo con sus tres declaraciones y el titular (líneas 1-43) + 44 maquinaria compartida duplicada (`mat05`, copia reducida del materializador de línea base de la parte 2, con su comentario; líneas 45-88) + 165 bloque indivisible mayor (la línea base materializada, el proyecto sin migrar, el dominio derivado, las formas, los dos actos, la matriz con su reparto y la clase derivada; líneas 89-253: ningún caso de CA-05 puede prescindir de ellos) · REQ-014 CA-18
seccion_nueva "--- 40/5 · la ausencia que abre: el radio de migración POR ACTO (REQ-024 CA-05) ---"

# ---------- LA LÍNEA BASE. Copia REDUCIDA del materializador de la parte 2 (`mat40`), y la
# reducción va dicha: sólo materializa `hooks/` y no audita el BIT DE EJECUCIÓN, porque el
# veredicto se toma con `bash <ruta>`. Lo que NO se reduce es la verificación del CONTENIDO por
# hash: dejar un archivo a medias produce un ALLOW silencioso en la base, o sea el fail-open de
# este instrumento. Duplicado por el residual `AN-021-01`.
REPO05="${SEC_DIR%/}/../../../.."   # sin `cd`+`pwd`: `git -C` acepta la ruta con `..`
MAT05_MOT='-'
mat05() {   # <referencia> <destino> -> 0 si el árbol heredado quedó materializado ENTERO
  local ref="$1" dst="$2" lista l tipo oid ruta n=0 i=0 calc obtenido
  local dirs='' paths=''
  local -a oids=() rutas=()
  MAT05_MOT='-'
  [ -e "$REPO05/.git" ] || { MAT05_MOT='no-hay-.git-en-el-repositorio'; return 1; }
  git -C "$REPO05" rev-parse -q --verify "$ref^{tree}" >/dev/null 2>&1 \
    || { MAT05_MOT="la-referencia-no-resuelve:$ref"; return 1; }
  lista="$(git -C "$REPO05" ls-tree -r "$ref" -- hooks 2>/dev/null)"
  [ -n "$lista" ] || { MAT05_MOT="la-referencia-no-tiene-hooks/:$ref"; return 1; }
  while IFS= read -r l || [ -n "$l" ]; do
    [ -n "$l" ] || continue
    l="${l#* }"; tipo="${l%% *}"; l="${l#* }"
    oid="${l%%$'\t'*}"; ruta="${l#*$'\t'}"
    [ "$tipo" = blob ] || continue
    n=$((n + 1)); dirs="$dirs $dst/${ruta%/*}"; paths="$paths$dst/$ruta"$'\n'
    oids+=("$oid"); rutas+=("$dst/$ruta")
  done <<< "$lista"
  [ "$n" -ge 1 ] || { MAT05_MOT='la-referencia-no-materializa-ningun-archivo'; return 1; }
  mkdir -p $dirs 2>/dev/null || { MAT05_MOT='no-se-pudo-crear-el-destino'; return 1; }
  while IFS= read -r ruta || [ -n "$ruta" ]; do
    [ -n "$ruta" ] || continue
    git -C "$REPO05" show "$ref:${ruta#"$dst"/}" > "$ruta" 2>/dev/null \
      || { MAT05_MOT="no-se-pudo-materializar:${ruta#"$dst"/}"; return 1; }
  done <<< "$paths"
  calc="$(git -C "$REPO05" hash-object --stdin-paths <<< "${paths%$'\n'}" 2>/dev/null)"
  [ -n "$calc" ] || { MAT05_MOT='no-se-pudo-verificar-el-contenido'; return 1; }
  while IFS= read -r obtenido || [ -n "$obtenido" ]; do
    [ -n "$obtenido" ] || continue
    [ "$i" -lt "$n" ] || { MAT05_MOT='la-verificacion-devolvio-mas-lineas-que-archivos'; return 1; }
    [ "${oids[i]}" = "$obtenido" ] || { MAT05_MOT="el-contenido-no-coincide-en:${rutas[i]##*/}"; return 1; }
    i=$((i + 1))
  done <<< "$calc"
  [ "$i" -eq "$n" ] || { MAT05_MOT="se-verificaron-$i-de-$n-archivos"; return 1; }
  MAT05_MOT="ok:$n-archivos"
  return 0
}
BASE05="${ARNES_CA05_BASE:-v1.33.0}"
HER05="$RAIZ/her05-$BASHPID"; HER05_OK=no
mat05 "$BASE05" "$HER05" && HER05_OK=si
REG05="$MAT05_MOT"

# ---------- EL PROYECTO DE PRUEBA **SIN MIGRAR**: ninguna llave nueva en su manifiesto -------
P05="$RAIZ/p05-$BASHPID"; REQ05="$P05/requirements/REQ-905.md"
mkdir -p "$P05/.arnes" "$P05/requirements" "$P05/docs"
printf '# ESTADO\n' > "$P05/docs/ESTADO.md"
printf '## Pendientes\n\n## Resueltas\n' > "$P05/PENDING_APPROVAL.md"
# Los dos manifiestos se escriben UNA vez y se copian: un `jq` por celda son 40 forks de más.
for k05 in false true; do
  printf '%s\n' "$MANIFIESTO_BASE" | jq ".campos.ausencia_exige = $k05" > "$P05/.arnes/conf-$k05.json"
done
# ---------- EL DOMINIO, DEL SITIO DONDE EL LECTOR DECLARA LA DIRECCIÓN DE LA AUSENCIA --------
# Ni una clave escrita aquí (`CA-01`): se carga la biblioteca en un subshell y se parte
# `ARNES_AUSENCIA` por su delimitador. Las `n/a` quedan fuera POR DECLARACIÓN, no por excepción.
DOM05=(); QA05=''
mapfile -t PARES05 < <(bash -c '. "$1/lib.sh" >/dev/null 2>&1
  printf "%s\n" "$ARNES_CLAVE_QA"
  t="${ARNES_AUSENCIA#|}"; t="${t%|}"; IFS="|" read -r -a a <<< "$t"
  i=0; while [ "$i" -lt "${#a[@]}" ]; do printf "%s\t%s\n" "${a[i]}" "${a[i+1]}"; i=$((i + 2)); done' _ "$HOOKS_DIR")
for p05 in ${PARES05[@]+"${PARES05[@]}"}; do
  case "$p05" in
    *$'\t'*) case "${p05#*$'\t'}" in 'n/a') ;; *) DOM05+=("${p05%%$'\t'*}") ;; esac ;;
    *) [ -n "$QA05" ] || QA05="$p05" ;;
  esac
done
# Por clave, `<valor que PERMITE>|<valor que MÁS restringe>`; el segundo sólo sirve para derivar
# la CLASE. Una clave nueva sin entrada aquí queda fuera de esa derivación, y el denominador lo
# publica.
declare -A VAL05=()
VAL05['QA']='aprobado|pendiente'
VAL05['Seguridad']='aprobado|pendiente'
VAL05['Sensible a seguridad']='no|sí'
VAL05['Hallazgos abiertos']='(ninguno)|SEC-1 (contrato)'
VAL05['Rigor']='estandar|critico'
# ---------- LAS FORMAS DE CABECERA: derivadas del dominio + las del rigor + el control -------
NOM05=(); CAB05=()
for k05 in ${DOM05[@]+"${DOM05[@]}"}; do
  c05=''
  for j05 in ${DOM05[@]+"${DOM05[@]}"}; do
    [ "$j05" = "$k05" ] && continue
    v05="${VAL05[$j05]:-aprobado|pendiente}"; c05="$c05$j05: ${v05%%|*}"$'\n'
  done
  NOM05+=("omite-${k05// /_}"); CAB05+=("${c05%$'\n'}")
done
# Las formas del rigor que el diferencial nombra, todas omitiendo el veredicto de QA, que es
# donde muerde el acto que diverge. No son adorno: `ligero`, el `critico` declarado y el
# `critico` por SUELO llegan al rigor efectivo por caminos distintos.
for f05 in 'critico|Rigor: critico' 'critico-por-suelo|Sensible a seguridad: sí' \
           'ligero|Rigor: ligero' 'sensibilidad-dudosa|Sensible a seguridad: tal vez'; do
  NOM05+=("sinQA-${f05%%|*}"); CAB05+=("Seguridad: pendiente
Hallazgos abiertos: (ninguno)
${f05#*|}")
done
NOM05+=('completa-control'); CAB05+=("QA: aprobado
Seguridad: aprobado
Sensible a seguridad: no
Hallazgos abiertos: (ninguno)
Rigor: estandar")
# Qué campos del dominio NO declara una cabecera. Anclado al arranque de línea (`\n<clave>:`) y
# no a la subcadena: `Seguridad:` vive dentro de `Sensible a seguridad:`, y un `case` sin ancla
# contaría como declarado lo que nadie escribió.
omite05() {   # <cabecera> -> las claves del dominio que la cabecera no declara, entre barras
  local c=$'\n'"$1" k faltan=''
  for k in ${DOM05[@]+"${DOM05[@]}"}; do
    case "$c" in *$'\n'"$k:"*) ;; *) faltan="$faltan$k|" ;; esac
  done
  printf '%s' "${faltan:+|$faltan}"
}
OMI05=(); for i05 in "${!NOM05[@]}"; do OMI05+=("$(omite05 "${CAB05[i05]}")"); done
# ---------- LOS DOS ACTOS, y el veredicto de UNA versión sobre UNA cabecera -------------------
# El acto se distingue por la EDICIÓN: el cierre transiciona el estado; la firma escribe el
# veredicto de seguridad SIN tocarlo.
JC05="$(CLAUDE_PROJECT_DIR="$P05" jq -n --arg fp "$REQ05" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"completado"}}')"
JF05="$(CLAUDE_PROJECT_DIR="$P05" jq -n --arg fp "$REQ05" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"x",new_string:"Seguridad: aprobado"}}')"
# `bash <ruta>`: así el veredicto no depende del bit de ejecución del árbol materializado —un
# `126` silencioso se leería como ALLOW—.
ver05() {   # <hooks-dir> <json de la edición> -> DENY|ALLOW
  local o
  o="$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$P05" bash "$1/guard-completado.sh" 2>/dev/null)"
  # LAS DOS FORMAS DEL JSON: `jq` no pone espacio tras el `:`, y un glob con el espacio dentro
  # daría ALLOW a TODA denegación —verde a los dos lados del par—.
  case "$o" in
    *'"permissionDecision":"deny"'*|*'"permissionDecision": "deny"'*) printf DENY ;;
    *) printf ALLOW ;;
  esac
}
pon05() { printf '# REQ-905 — %s\nEstado: en-revisión\n%s\n' "$1" "$2" > "$REQ05"; }
# ---------- LA MATRIZ, y el REPARTO POR ACTO en la misma pasada ------------------------------
TOT05=0; IDEM05=0; DIV05=0; PROH05=''; RESU05=''
CIER05=0; CIERDIV05=0; CIER1=''       # el CIERRE con la llave apagada = un proyecto sin migrar
OTRO05=0; OTRODIV05=0; OTROQA05=''; DIVACT05=()
declare -A RN05=() RD05=()
if [ "$HER05_OK" = si ]; then
  for i05 in "${!NOM05[@]}"; do
    pon05 "${NOM05[i05]}" "${CAB05[i05]}"
    for k05 in false true; do
      cp "$P05/.arnes/conf-$k05.json" "$P05/.arnes/config.json"
      for a05 in cierre firma-seguridad; do
        case "$a05" in cierre) j05="$JC05" ;; *) j05="$JF05" ;; esac
        x05="$(ver05 "$HOOKS_DIR" "$j05")"; y05="$(ver05 "$HER05/hooks" "$j05")"
        TOT05=$((TOT05 + 1)); RN05[$a05/$k05]=$(( ${RN05[$a05/$k05]:-0} + 1 ))
        if [ "$x05" = "$y05" ]; then IDEM05=$((IDEM05 + 1)); else
          DIV05=$((DIV05 + 1)); RD05[$a05/$k05]=$(( ${RD05[$a05/$k05]:-0} + 1 ))
          [ "$y05" = DENY ] && [ "$x05" = ALLOW ] && PROH05="$PROH05 $a05/llave=$k05/${NOM05[i05]}(DENY→ALLOW)"
          if [ "$k05" = false ]; then
            case " ${DIVACT05[*]-} " in *" $a05 "*) ;; *) DIVACT05+=("$a05") ;; esac
          fi
        fi
        if [ "$a05" = cierre ] && [ "$k05" = false ]; then
          CIER05=$((CIER05 + 1))
          [ "$x05" = "$y05" ] || { CIERDIV05=$((CIERDIV05 + 1)); [ -n "$CIER1" ] || CIER1="${NOM05[i05]}($y05→$x05)"; }
        fi
        if [ "$a05" != cierre ]; then
          [ "$k05" = false ] && OTRO05=$((OTRO05 + 1))
          if [ "$x05" != "$y05" ]; then
            OTRODIV05=$((OTRODIV05 + 1))
            # Afirmación medida del informe: las divergentes del otro acto son EXACTAMENTE la
            # firma sobre un REQ SIN QA. La clave se pregunta al lector, no se escribe aquí.
            case "${OMI05[i05]}" in *"|$QA05|"*) ;; *) OTROQA05="$OTROQA05 $a05/llave=$k05/${NOM05[i05]}" ;; esac
          fi
        fi
      done
    done
  done
  for a05 in cierre firma-seguridad; do for k05 in false true; do
    RESU05="$RESU05 $a05/llave=$k05: ${RN05[$a05/$k05]:-0} celdas y ${RD05[$a05/$k05]:-0} divergentes;"
  done; done
fi
# ---------- LA CLASE, derivada MIDIENDO y por COTA INFERIOR (fail-closed) ---------------------
# Procedimiento de `REQ-023 CA-02` aplicado sobre la BASE y sobre las formas de este archivo: la
# clave pertenece a la clase si el veredicto con la clave AUSENTE **abre** respecto al de la
# misma cabecera con la clave en su valor MÁS restrictivo. Con un fixture UNIFORME sale una COTA
# INFERIOR —la parte 1 la deriva entera, con un fixture por clave—, y ésa es la dirección
# correcta: hace el suelo de anti-vacuidad MÁS difícil de cumplir, nunca más fácil.
CLASE05=''; NCLASE05=0; FCLASE05=0; FORMAS05="${#NOM05[@]}"
if [ "$HER05_OK" = si ]; then
  cp "$P05/.arnes/conf-false.json" "$P05/.arnes/config.json"
  for i05 in "${!NOM05[@]}"; do
    k05="${OMI05[i05]}"; k05="${k05#|}"; k05="${k05%|}"
    case "$k05" in ''|*'|'*) continue ;; esac      # sólo las formas que omiten UNA clave
    [ -n "${VAL05[$k05]:-}" ] || continue
    pon05 "${NOM05[i05]}" "${CAB05[i05]}"; a05="$(ver05 "$HER05/hooks" "$JC05")"
    v05="${VAL05[$k05]#*|}"
    pon05 "${NOM05[i05]}" "${CAB05[i05]}
$k05: $v05"
    b05="$(ver05 "$HER05/hooks" "$JC05")"
    [ "$a05" = ALLOW ] && [ "$b05" = DENY ] && { CLASE05="$CLASE05$k05|"; NCLASE05=$((NCLASE05 + 1)); }
  done
  CLASE05="${CLASE05:+|$CLASE05}"
  # Cuántas formas omiten un campo DE LA CLASE: el denominador de anti-vacuidad de `CA-05`.
  for i05 in "${!NOM05[@]}"; do
    f05="${OMI05[i05]#|}"
    while [ -n "$f05" ]; do
      case "$CLASE05" in *"|${f05%%|*}|"*) FCLASE05=$((FCLASE05 + 1)); break ;; esac
      f05="${f05#*|}"
    done
  done
fi
# ---------- LOS TRES DOCUMENTOS, aplanados en REGISTROS ---------------------------------------
# APLANADOS a propósito: una prueba que casa un renglón concreto se pone roja el día que alguien
# reajusta el ancho del párrafo, y ese rojo enseña a desactivar el control. Cada registro es un
# bloque —el criterio, una viñeta, un párrafo— y los patrones de un grupo casan EL MISMO.
DCRI05="$RAIZ/d05-cri-$BASHPID.txt"; DMIG05="$RAIZ/d05-mig-$BASHPID.txt"; DGAT05="$RAIZ/d05-gat-$BASHPID.txt"
: > "$DCRI05"; : > "$DMIG05"; : > "$DGAT05"
FCRI05="${ARNES_REQ_024:-$REPO05/requirements/REQ-024.md}"
FMIG05="${ARNES_SKILL_UPGRADE:-$REPO05/skills/arnes-upgrade/SKILL.md}"
FGAT05="${ARNES_PENDING_024:-$REPO05/PENDING_APPROVAL.md}"
[ -f "$FCRI05" ] && awk '/^- \*\*CA-05 /{d = 1} d && /^- \*\*CA-06 /{exit}
  d {s = $0; sub(/^[ \t]+/, "", s); rec = (rec == "" ? s : rec " " s)}
  END {if (rec != "") print rec}' "$FCRI05" > "$DCRI05"
[ -f "$FMIG05" ] && awk '!d && /^### Hacia 1\.34\.0[ \t]*$/{d = 1; next}
  d && (/^## / || /^### / || /^\*\(/){exit}
  d {if ($0 ~ /^- /) {if (rec != "") print rec; rec = $0}
     else {s = $0; sub(/^[ \t]+/, "", s); if (rec != "") rec = rec " " s}}
  END {if (rec != "") print rec}' "$FMIG05" > "$DMIG05"
[ -f "$FGAT05" ] && awk '{if ($0 ~ /^[ \t]*$/) {if (rec != "") {print rec; rec = ""}}
     else {s = $0; sub(/^[ \t]+/, "", s); rec = (rec == "" ? s : rec " " s)}}
  END {if (rec != "") print rec}' "$FGAT05" > "$DGAT05"
# LA HUELLA DE DECLARACIÓN, por acto y por documento — lo único que este archivo escribe a mano,
# y con su residual dicho: reconoce por CADENA LITERAL, así que una redacción distinta que dijera
# lo mismo lo pondría rojo (clase de `QA-024-05`). La vía conforme es añadirla, no retirar nada.
declare -A HUE05=()
HUE05['firma-seguridad|criterio']='Seguridad: aprobado
no declara.*QA:
de [*_]*ALLOW[*_]* a [*_]*DENY[*_]*
en los dos estados de la llave
[0-9]{4}-[0-9]{2}-[0-9]{2}
celdas'
HUE05['firma-seguridad|migracion']='Seguridad: aprobado
no declara .?QA:
deneg
llave apagada'
HUE05['firma-seguridad|gate']='Seguridad: aprobado
no declara .?QA:
deniega
ausencia_exige.? apagada'
casa05() {   # <archivo de registros> <patrones, uno por línea> -> «<nº que casan>|<patrón que falló>»
  local out p
  out="$(cat "$1")"
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    out="$(printf '%s\n' "$out" | grep -Ei -- "$p" || true)"
    [ -n "$out" ] || { printf '0|%s' "$p"; return 0; }
  done <<< "$2"
  printf '%s|-' "$(printf '%s\n' "$out" | grep -c .)"
}
decl05() {   # <nombre> <clave de documento> <archivo de registros> <descripción> <ruta>
  local nom="$1" doc="$2" arch="$3" desc="$4" ruta="$5" a r n falta faltan='' vistos=0
  if [ -n "$FILTRO" ] && ! printf '%s' "$nom" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$HER05_OK" != si ]; then echo "  SKIP  $nom  no hay línea base $BASE05 ($REG05)"; return 0; fi
  if [ "${#DIVACT05[@]}" -eq 0 ]; then
    echo "  SKIP  $nom  el diferencial no midió NINGÚN acto divergente sobre un proyecto sin migrar, así que «va declarada» sería cierto por vacío; quien lo dice en rojo es el caso (i) de la existencia"; return 0
  fi
  if [ ! -s "$arch" ]; then
    echo "  FAIL  $nom  $desc no dejó ni un registro que leer ($ruta): sin texto, la declaración no se puede medir"; FAIL=$((FAIL+1)); return 0
  fi
  for a in "${DIVACT05[@]}"; do
    vistos=$((vistos + 1))
    if [ -z "${HUE05[$a|$doc]:-}" ]; then
      faltan="$faltan «$a»(este archivo no sabe qué buscar para ese acto: huella sin declarar)"; continue
    fi
    r="$(casa05 "$arch" "${HUE05[$a|$doc]}")"; n="${r%%|*}"; falta="${r#*|}"
    [ "$n" -ge 1 ] || faltan="$faltan «$a»(ningún registro casa TODOS los patrones; el primero que falla: /$falta/)"
  done
  if [ -z "$faltan" ]; then
    echo "  PASS  $nom  los $vistos acto(s) divergente(s) MEDIDO(s) van declarados en $desc ($(grep -c . "$arch") registros de ${ruta##*/})"; PASS=$((PASS+1))
  else
    echo "  FAIL  $nom  $desc no lo declara:$faltan. Una divergencia que sólo vive en el código, en un log de QA o en el registro de seguridad es DERIVA (AGENTS.md §9, CA-05 (ii))"; FAIL=$((FAIL+1))
  fi
}
uno05() { [ -z "$FILTRO" ] || printf '%s' "$1" | grep -qi -- "$FILTRO"; }
# ---------- (1) EL INSTRUMENTO ANTES DEL RESULTADO: la base es OTRO árbol ----------
N05="REQ-024 CA-05 instrumento: la linea base materializada es OTRO arbol, no el de trabajo"
if uno05 "$N05"; then
  if [ "$HER05_OK" != si ]; then
    echo "  SKIP  $N05  no hay línea base $BASE05 ($REG05)"
  else
    d05=0; t05=0; c05=''
    for f05 in "$HER05"/hooks/*; do
      [ -f "$f05" ] || continue
      t05=$((t05 + 1))
      cmp -s "$f05" "$HOOKS_DIR/${f05##*/}" || { d05=$((d05 + 1)); c05="$c05 ${f05##*/}"; }
    done
    if [ "$d05" -ge 1 ]; then
      echo "  PASS  $N05: $d05 de $t05 archivos difieren de $BASE05 —$c05—, así que el diferencial compara DOS árboles ($REG05)"; PASS=$((PASS+1))
    else
      echo "  FAIL  $N05: los $t05 archivos de $BASE05 son idénticos a los de $HOOKS_DIR, así que el diferencial se toma contra sí mismo y su «idéntico» no acredita NADA"; FAIL=$((FAIL+1))
    fi
  fi
fi
# ---------- (2) LA MITAD (1) DEL CRITERIO: el acto de CIERRE decide IDÉNTICO ----------
N05="REQ-024 CA-05 el acto de CIERRE decide identico sobre un proyecto SIN MIGRAR, con su denominador"
if uno05 "$N05"; then
  if [ "$HER05_OK" != si ]; then
    echo "  SKIP  $N05  no hay línea base $BASE05 ($REG05)"
  elif [ "$CIER05" -lt 1 ]; then
    echo "  SKIP  $N05  la matriz no dejó ni una celda del acto de cierre con la llave apagada: no hay nada que comparar"
  elif [ "$NCLASE05" -lt 1 ] || [ "$FCLASE05" -lt 1 ]; then
    echo "  SKIP  $N05  anti-vacuidad: la clase derivada por cota inferior tiene $NCLASE05 campo(s) y $FCLASE05 de las $FORMAS05 formas omiten uno. Sin una sola forma que omita un campo de la clase, la equivalencia es cierta por vacío. Vía conforme: aportar la forma, nunca rebajar el suelo"
  elif [ "$OTRODIV05" -lt 1 ]; then
    echo "  SKIP  $N05  el CONTROL POSITIVO no distingue: el diferencial no detecta ni una divergencia en ningún otro acto, así que un «idéntico» del cierre no separa la equivalencia real de un instrumento que no mide. Quien lo dice en rojo es el caso (i) de la existencia"
  elif [ "$CIERDIV05" -eq 0 ]; then
    echo "  PASS  $N05: $CIER05 de $CIER05 celdas del CIERRE deciden idéntico contra $BASE05 ($FORMAS05 formas, $FCLASE05 de ellas omiten uno de los $NCLASE05 campos de la clase derivada; control positivo: $OTRODIV05 divergencias en otro acto). Reparto:$RESU05"; PASS=$((PASS+1))
  else
    echo "  FAIL  $N05: $CIERDIV05 de $CIER05 celdas del CIERRE deciden DISTINTO sin haber activado nada (la primera, $CIER1). Un proyecto que no hace nada tiene que CERRAR como cerraba. Reparto:$RESU05"; FAIL=$((FAIL+1))
  fi
fi
# ---------- (3) LA MITAD (2): la divergencia del OTRO acto EXISTE ----------
# FALLA —no abstiene— si desaparece: el criterio la DECLARA, así que su ausencia es o una
# regresión de `SEC-083` o una base que dejó de serlo. Es el control positivo del caso (2).
N05="REQ-024 CA-05 (i) la divergencia del OTRO acto EXISTE y toda ella es sobre una cabecera sin el campo de QA"
if uno05 "$N05"; then
  if [ "$HER05_OK" != si ]; then
    echo "  SKIP  $N05  no hay línea base $BASE05 ($REG05)"
  elif [ "$OTRO05" -lt 1 ]; then
    echo "  SKIP  $N05  la matriz no dejó ni una celda de un acto que no sea el cierre: no hay nada que medir"
  elif [ "$OTRODIV05" -lt 1 ]; then
    echo "  FAIL  $N05: 0 divergencias, con $OTRO05 celdas del otro acto medidas con la llave apagada. El criterio DECLARA que la firma de seguridad sobre un REQ sin QA pasa de ALLOW a DENY: o el código dejó de denegar, o $BASE05 ya no es la versión heredada. Mientras no se resuelva, la equivalencia del cierre no tiene control positivo"; FAIL=$((FAIL+1))
  elif [ -n "$OTROQA05" ]; then
    echo "  FAIL  $N05: hay $OTRODIV05 divergencias, pero éstas NO omiten «$QA05:» —$OTROQA05—, así que la divergencia declarada en el criterio no es la que mide el árbol"; FAIL=$((FAIL+1))
  else
    echo "  PASS  $N05: $OTRODIV05 celdas divergentes en el acto de firmar, TODAS sobre cabeceras que no declaran «$QA05:» ($OTRO05 celdas del acto medidas con la llave APAGADA, que es como nace todo proyecto). Actos divergentes sin migrar: ${DIVACT05[*]}"; PASS=$((PASS+1))
  fi
fi
# ---------- (4) LA DIRECCIÓN: restrictiva, y en NINGÚN acto la contraria ----------
N05="REQ-024 CA-05 (i) ninguna celda pasa de DENY a ALLOW: la divergencia va en direccion RESTRICTIVA"
if uno05 "$N05"; then
  if [ "$HER05_OK" != si ]; then
    echo "  SKIP  $N05  no hay línea base $BASE05 ($REG05)"
  elif [ "$DIV05" -lt 1 ]; then
    echo "  SKIP  $N05  las $TOT05 celdas deciden idéntico: sin una sola divergencia, «va en dirección restrictiva» es cierto por vacío"
  elif [ -z "$PROH05" ]; then
    echo "  PASS  $N05: $TOT05 celdas, $IDEM05 idénticas y $DIV05 divergentes, y las $DIV05 van de ALLOW a DENY. Reparto:$RESU05"; PASS=$((PASS+1))
  else
    echo "  FAIL  $N05: hay celdas que ABREN lo que la versión heredada cerraba —$PROH05—. Un acto que pase de DENY a ALLOW incumple CA-05 en CUALQUIER acto, incluido el cierre, y no se acota para que encaje"; FAIL=$((FAIL+1))
  fi
fi
# ---------- (5) (6) (7) LAS OTRAS DOS EXIGENCIAS: declarada, y donde la ve quien migra --------
decl05 "REQ-024 CA-05 (ii) cada acto divergente MEDIDO va DECLARADO en el criterio, con su direccion y su medicion fechada" \
  criterio "$DCRI05" "el criterio CA-05" "$FCRI05"
decl05 "REQ-024 CA-05 (iii) ...y en la nota de migracion, que es donde lo ve quien migra" \
  migracion "$DMIG05" "el apartado de migración de la skill" "$FMIG05"
decl05 "REQ-024 CA-05 (iii) ...y en la entrada del gate humano, la otra sede que el criterio nombra" \
  gate "$DGAT05" "la cola de aprobaciones" "$FGAT05"
rm -rf "$HER05" "$P05" "$DCRI05" "$DMIG05" "$DGAT05"
