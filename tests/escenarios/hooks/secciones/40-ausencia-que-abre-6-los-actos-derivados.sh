# Sección 40 (6 de 6) del banco — 40-ausencia-que-abre-6-los-actos-derivados
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con los
# ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de ninguna otra
# sección (invariantes 3 y 4 del README del banco).
#
# REQ-024 `CA-12` · `SEC-083` · `ADR-011`. EL APARATO DE ANTI-VACUIDAD DEL CRITERIO. El código
# de `CA-12` ya cumple —la guarda del orden de firmas resuelve la ausencia de `QA:` por el sitio
# único y no por un `[ -n "$qa" ]` local, y `40/4` lo mide por mutación—. Lo que faltaba es lo
# que el criterio pide ADEMÁS del cumplimiento, y sin lo cual su verde no significa nada:
#   (1) CUÁNTOS ACTOS ejerce la corrida, con suelo de NO MENOS DE 2, y la lista de actos
#       DERIVADA de las ramas de denegación de `hooks/guard-completado.sh` —nunca escrita a
#       mano—, porque ejercer sólo el cierre volvería a medir lo que `ADR-009` ya cerró;
#   (2) los TRES CONTROLES del hallazgo en los DOS ESTADOS de la llave y en la misma corrida; y
#   (3) el FAIL-BEFORE contra la versión heredada, en la misma corrida.
#
# CÓMO SE DERIVA LA LISTA DE ACTOS, escrito aquí y publicado también en el caso (2) — porque
# `ADR-011` § Consecuencias (−) declara que este extractor SE ROMPE cuando el código cambia de
# FORMA aunque no cambie de conducta, y quien lo arregle en 1.36.0 no tiene que adivinarlo:
#   · Un ACTO es el par «ZONA / CAMPO EXIGIDO» de una rama de denegación.
#   · ZONA sale de la FRONTERA DE LA TRANSICIÓN: la ÚLTIMA línea del archivo que devuelve 0
#     cuando el estado resultante no es el terminal (`return 0` en una línea que nombra
#     `done_norm` o `estado_done`). Antes de esa línea una rama puede morder SIN transición;
#     después, sólo con ella. Es la asimetría que `ADR-011` § Decisión 3 nombra.
#   · CAMPO EXIGIDO sale de la guarda de edición que DOMINA la rama: un
#     `grep -q '<clave>:' <<< "$nuevo"` cuya sangría es menor que la de la rama y entre el cual
#     y la rama no hay ninguna línea no vacía de sangría igual o menor (dominancia aproximada
#     POR SANGRÍA; en este archivo la sangría es consistente). Sin guarda que la domine, `-`.
#   · Cada rama deja además un ANCLA: su fragmento LITERAL más largo (lo que queda al partir el
#     mensaje por `$`, comilla y contrabarra). El ancla es lo que permite mapear un motivo
#     EMITIDO en tiempo de ejecución a la rama que lo emitió, y así el ACTO que una sonda
#     ejerce lo dice EL CÓDIGO y no una etiqueta escrita en este archivo.
#
# Y FALLA RUIDOSAMENTE, NUNCA EN SILENCIO —es lo único que se puede prometer de un extractor
# que va a envejecer—: si no puede derivar la frontera, si no encuentra ni una rama, si deriva
# MENOS DE 2 actos, o si el lector no le da el nombre de la clave, el caso ABSTIENE con SKIP y
# su motivo, y NUNCA da PASS. Un motivo emitido que no case con ninguna ancla —o que case con
# anclas de DOS actos— se cuenta aparte y se publica: son las dos formas en que el extractor
# deja de responder al sujeto sin que nada se ponga rojo.
#
# LO QUE ESTA PARTE NO ES. No es la lista EXHAUSTIVA de actos: lo derivado es una COTA INFERIOR
# —la zona reparte en dos y el campo exigido sólo afina lo que una guarda de edición marca—, y
# la dirección es la correcta porque hace el suelo MÁS difícil de cumplir, nunca más fácil. No
# mide la conducta condicional al rigor (`40/4`) ni el radio de migración (`40/5`).
#
# EL CUADRE DE LA ENTREGA Y EL SKIP QUE FLOTA, MEDIDO EMPAREJADO Y NO SUPUESTO (2026-09-10,
# `rel/registro-1.33.0` @ `3e6a89d`, 12 núcleos, `loadavg` 1,30-3,66). Al añadir esta parte el
# banco pasa de 1054 a 1064 casos, y en la corrida verde salieron 1058 PASS · 0 FAIL · 6 SKIP
# donde la base declaraba 7. Ese SKIP flotante NO es de aquí: método —tres pares alternados
# `con`/`sin` esta sección, vía `ARNES_SECCIONES_DIR` con dos directorios de enlaces, uno de 63
# y otro de 62— `REQ-023 CA-09 (iii)` sobre `arnes_campo_linea` abstiene 2 de 3 veces CON la
# sección y 1 de 3 SIN ella, y `REQ-017 CA-08 (ii)` flotó en el par 2 en LAS DOS ramas; los dos
# son de reloj y su residual está registrado (`SEC-080`). El brazo `sin` cuadró 1054 en las tres
# vueltas y el brazo `con` cuadró 1064 en las tres, así que esta parte añade 10 casos y no mueve
# ninguno. Los 10 dieron PASS en las 6 vueltas: 0 SKIP y 0 FAIL propios.
#
# LOS FAIL-BEFORE, uno por exigencia:
#   ARNES_CA12_BASE=<ref>   la línea base (por defecto `v1.33.0`); con una ref que YA lleve el
#                           arreglo de `SEC-083`, el caso (9) deja de ver los ALLOW heredados.
#   ARNES_HOOKS_DIR=<dir>   el código bajo prueba, como en todo el banco. Si se apunta a la
#                           heredada, los casos (7) y (8) salen rojos: es el fail-before del
#                           cumplimiento, y el (9) lo dice comparando el árbol contra sí mismo.
CASOS_ESPERADOS_SECCION=10
PISO_AUTONOMO_SECCION=266  # 64 preámbulo con la publicación del procedimiento de derivación, el cuadre medido y el titular (líneas 1-64) + 33 maquinaria compartida duplicada (`mat12`, copia REDUCIDA del materializador de línea base de `40/5`, con su reducción declarada; líneas 66-98) + 169 bloque indivisible mayor (el proyecto sin migrar, los dos manifiestos, las dos ediciones, el extractor de actos, el dominio derivado, `ver12`/`par12` y las cinco cabeceras, líneas 100-268: ningún caso de esta parte puede prescindir de ellos) · REQ-014 CA-18
seccion_nueva "--- 40/6 · la ausencia que abre: los ACTOS derivados del código (REQ-024 CA-12, ADR-011) ---"

# ---------- LA LÍNEA BASE. Copia REDUCIDA de `mat05` (`40/5`), y la reducción va DICHA porque
# es una decisión y no un descuido: `mat05` verifica el contenido por hash para que un archivo
# a medias no produzca un ALLOW silencioso en la base. Aquí esa clase la cierra algo más fuerte
# y no más barato: el CONTROL POSITIVO DE CONDUCTA del caso (1) —la base tiene que MORDER
# cuando el campo está— más el veredicto `VACIO` de `ver12`, que un hook que no llegó a correr
# no puede pasar por ALLOW. Verificar bytes acredita la copia; morder acredita que corre.
# Duplicada, no compartida, por el residual `AN-021-01` (dueño y ventana declarados allí).
REPO12="${SEC_DIR%/}/../../../.."   # sin `cd`+`pwd`: `git -C` acepta la ruta con `..`
MAT12_MOT='-'
mat12() {   # <referencia> <destino> -> 0 si el árbol heredado quedó materializado
  local ref="$1" dst="$2" lista ruta n=0
  MAT12_MOT='-'
  [ -e "$REPO12/.git" ] || { MAT12_MOT='no-hay-.git-en-el-repositorio'; return 1; }
  git -C "$REPO12" rev-parse -q --verify "$ref^{tree}" >/dev/null 2>&1 \
    || { MAT12_MOT="la-referencia-no-resuelve:$ref"; return 1; }
  lista="$(git -C "$REPO12" ls-tree -r --name-only "$ref" -- hooks 2>/dev/null)"
  [ -n "$lista" ] || { MAT12_MOT="la-referencia-no-tiene-hooks/:$ref"; return 1; }
  mkdir -p "$dst/hooks" || { MAT12_MOT='no-se-pudo-crear-el-destino'; return 1; }
  while IFS= read -r ruta || [ -n "$ruta" ]; do
    [ -n "$ruta" ] || continue
    case "$ruta" in hooks/*/*) MAT12_MOT="la-referencia-anida-hooks/:$ruta"; return 1 ;; esac
    git -C "$REPO12" show "$ref:$ruta" > "$dst/$ruta" 2>/dev/null \
      || { MAT12_MOT="no-se-pudo-materializar:$ruta"; return 1; }
    n=$((n + 1))
  done <<< "$lista"
  [ "$n" -ge 1 ] || { MAT12_MOT='la-referencia-no-materializa-ningun-archivo'; return 1; }
  MAT12_MOT="ok:$n-archivos"
  return 0
}
BASE12="${ARNES_CA12_BASE:-v1.33.0}"
HER12="$RAIZ/her12-$BASHPID"; HER12_OK=no
mat12 "$BASE12" "$HER12" && HER12_OK=si
REG12="$MAT12_MOT"

# ---------- EL PROYECTO DE PRUEBA: sin migrar, y los dos manifiestos escritos UNA vez -------
P12="$RAIZ/p12-$BASHPID"; REQ12="$P12/requirements/REQ-912.md"
mkdir -p "$P12/.arnes" "$P12/requirements" "$P12/docs"
printf '# ESTADO\n' > "$P12/docs/ESTADO.md"
printf '## Pendientes\n\n## Resueltas\n' > "$P12/PENDING_APPROVAL.md"
for k12 in false true; do
  printf '%s\n' "$MANIFIESTO_BASE" | jq ".campos.ausencia_exige = $k12" > "$P12/.arnes/conf-$k12.json"
done
# LAS DOS EDICIONES, que es lo que distingue un ACTO de otro: el cierre transiciona el estado;
# la firma escribe el veredicto de seguridad SIN tocarlo. La del cierre NO escribe `Seguridad:`
# a propósito —si lo escribiera, decidiría la guarda del orden y esta sección estaría midiendo
# el mismo acto dos veces con dos nombres (el mismo cuidado que `40/4` declara)—.
JC12="$(CLAUDE_PROJECT_DIR="$P12" jq -n --arg fp "$REQ12" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"en-revisión",new_string:"completado"}}')"
# EL `old_string` DE LA FIRMA ES UN CENTINELA QUE NO PUEDE ESTAR EN EL DOCUMENTO, y no la `x`
# de `emite_edit`: medido al escribir esta sección, con `old_string: "x"` y un título que decía
# «fixture» la edición SÍ era reconstruible —la `x` de esa palabra—, el documento resultante
# quedaba con `Seguridad: aprobado` A MITAD DE LÍNEA, la cabecera no declaraba el campo y las
# SEIS celdas del acto de firmar salían ALLOW. Un fixture que deja de ejercer el acto no se
# pone rojo: se pone verde. El centinela hace la propiedad —«esta edición NO se reconstruye»—
# independiente de lo que digan las cabeceras de prueba.
JF12="$(CLAUDE_PROJECT_DIR="$P12" jq -n --arg fp "$REQ12" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",cwd:env.CLAUDE_PROJECT_DIR,
    tool_input:{file_path:$fp,old_string:"ZZ-no-esta-en-el-documento-ZZ",new_string:"Seguridad: aprobado"}}')"

# ---------- EL EXTRACTOR: los ACTOS, de las ramas de denegación del código ------------------
# El programa no lleva ni una comilla simple (va dentro de unas), así que el carácter se
# fabrica con `sprintf`. Las líneas de comentario del fuente se descartan: un `arnes_deny` o un
# `return 0` citados en una explicación no son una rama.
mapfile -t CRUDO12 < <(awk '
  { linea = $0
    sangria = match(linea, /[^ ]/) - 1
    if (linea ~ /^[ \t]*$/) sangria = -1
    if (linea ~ /^[ \t]*#/) next
    if (linea ~ /return 0/ && (linea ~ /done_norm/ || linea ~ /estado_done/)) fr = FNR
    q = sprintf("%c", 39)
    if (linea ~ /grep -q/ && linea ~ /nuevo/) {
      i1 = index(linea, q)
      if (i1 > 0) { resto = substr(linea, i1 + 1); i2 = index(resto, q)
        if (i2 > 1) { g = substr(resto, 1, i2 - 1)
          if (g ~ /:$/) { sub(/:$/, "", g); gk = g; gi = sangria; gl = FNR; next } } }
    }
    if (gk != "" && sangria >= 0 && sangria <= gi && FNR > gl) gk = ""
    if (linea ~ /arnes_deny "/) {
      s = linea; sub(/.*arnes_deny "/, "", s)
      gsub(/[$"\\]/, "\n", s); gsub(q, "\n", s)
      n = split(s, p, "\n"); mejor = ""
      for (i = 1; i <= n; i++)
        if (substr(p[i], 1, 1) != "{" && length(p[i]) > length(mejor)) mejor = p[i]
      nr++; lin[nr] = FNR; cam[nr] = (gk == "" ? "-" : gk); anc[nr] = mejor
    }
  }
  END { printf "FRONTERA\t%d\n", fr
    for (i = 1; i <= nr; i++)
      printf "%s\t%s\t%s\t%s\n", (lin[i] > fr ? "transicion" : "sin-transicion"), cam[i], lin[i], anc[i]
  }' "$HOOKS_DIR/guard-completado.sh")
FRON12=''; RAMAS12=()
for r12 in ${CRUDO12[@]+"${CRUDO12[@]}"}; do
  case "$r12" in
    "FRONTERA$(printf '\t')"*) FRON12="${r12#*$(printf '\t')}" ;;
    *) RAMAS12+=("$r12") ;;
  esac
done
[ "${FRON12:-0}" -ge 1 ] 2>/dev/null || FRON12=''
# La clave del campo se le pregunta AL LECTOR y no se escribe aquí (`CA-01`): así el caso sigue
# al código si el conjunto se muda, que es la misma razón que en las partes 1 y 5.
CLQA12="$(bash -c '. "$1/lib.sh" >/dev/null 2>&1; printf "%s" "${ARNES_CLAVE_QA:-}"' _ "$HOOKS_DIR")"
# LOS ACTOS DERIVADOS, con cuántas ramas trae cada uno: el denominador que se publica.
ACTD12=''; NACTD12=0; NRAM12=0; ORD12=(); declare -A CUE12=()
for r12 in ${RAMAS12[@]+"${RAMAS12[@]}"}; do
  IFS=$'\t' read -r z12 k12 l12 a12 <<< "$r12"
  NRAM12=$((NRAM12 + 1)); CUE12[$z12/$k12]=$(( ${CUE12[$z12/$k12]:-0} + 1 ))
  case "$ACTD12" in *"|$z12/$k12|"*) ;;
    *) ACTD12="$ACTD12|$z12/$k12|"; NACTD12=$((NACTD12 + 1)); ORD12+=("$z12/$k12") ;;
  esac
done
LISTA12=''
for a12 in ${ORD12[@]+"${ORD12[@]}"}; do LISTA12="$LISTA12 «$a12»(${CUE12[$a12]} ramas)"; done
# EL MOTIVO DE ABSTENCIÓN, uno y publicado: cualquiera de estas cuatro cosas deja al aparato
# sin sujeto, y entonces no hay PASS que dar.
MOT12=''
[ -n "$FRON12" ] || MOT12="no se pudo DERIVAR la frontera de la transición en $HOOKS_DIR/guard-completado.sh: ninguna línea devuelve 0 nombrando el estado terminal. El extractor dejó de responder al sujeto (ADR-011, consecuencia (−)); la vía conforme es arreglarlo, no bajar el suelo"
[ -n "$MOT12" ] || [ "$NRAM12" -ge 1 ] || MOT12="la extracción no encontró ni una rama de denegación (frontera $FRON12): el código cambió de forma y el extractor no lo sigue"
[ -n "$MOT12" ] || [ "$NACTD12" -ge 2 ] || MOT12="la extracción derivó $NACTD12 acto(s) de $NRAM12 rama(s) —$LISTA12— y el suelo de CA-12 es NO MENOS DE 2: con un solo acto se volvería a medir lo que ADR-009 ya cerró"
[ -n "$MOT12" ] || [ -n "$CLQA12" ] || MOT12="el lector no declara ARNES_CLAVE_QA, así que no se puede comprobar que el motivo NOMBRE el campo que falta sin escribir la clave a mano (CA-01)"

# ---------- UN VEREDICTO, Y EL ACTO QUE LO EMITIÓ SEGÚN EL CÓDIGO ---------------------------
V12_DEC=''; V12_OUT=''; V12_ACTO=''; V12_LIN=''
ACT12=''; NACT12=0; SIN12=0; AMB12=0
ver12() {   # <hooks-dir> <llave true|false> <cabecera> <json de la edición>
  local o rc m r z k l a
  cp "$P12/.arnes/conf-$2.json" "$P12/.arnes/config.json"
  printf '# REQ-912 — fixture de CA-12\nEstado: en-revisión\n%s\n' "$3" > "$REQ12"
  # `bash <ruta>`: así el veredicto no depende del bit de ejecución del árbol materializado
  # —`git show` no lo preserva y un 126 silencioso se leería como ALLOW—.
  o="$(printf '%s' "$4" | CLAUDE_PROJECT_DIR="$P12" bash "$1/guard-completado.sh" 2>/dev/null)"; rc=$?
  V12_OUT="$o"; V12_ACTO=''; V12_LIN=''
  # LA GUARDA DE ESTE HOOK (invariante 1 del banco) NO ES LA SALIDA VACÍA, y decirlo importa:
  # este guardián dice ALLOW **callando**, así que «sin salida» es un veredicto legítimo y una
  # guarda por vacío daría NO-CORRIO a la mitad de las celdas. Quien delata a un hook que no
  # llegó a correr es el CÓDIGO DE SALIDA —127 con la ruta mala, 126 sin bit de ejecución, 2
  # con un `lib.sh` a medias—, y a un deny sin motivo, su motivo vacío. Los dos se miran.
  if [ "$rc" -ne 0 ]; then V12_DEC="NO-CORRIO(rc=$rc)"; return 0; fi
  # LAS DOS FORMAS DEL JSON: `jq` no pone espacio tras el `:`, y un glob con el espacio dentro
  # daría ALLOW a TODA denegación.
  case "$o" in
    *'"permissionDecision":"deny"'*|*'"permissionDecision": "deny"'*) V12_DEC=DENY ;;
    *) V12_DEC=ALLOW ;;
  esac
  [ "$V12_DEC" = DENY ] || return 0
  m="${o#*permissionDecisionReason\":\"}"; m="${m%%\"*}"
  [ -n "$m" ] || { V12_DEC=DENY-SIN-MOTIVO; return 0; }
  for r in ${RAMAS12[@]+"${RAMAS12[@]}"}; do
    IFS=$'\t' read -r z k l a <<< "$r"
    [ "${#a}" -ge 25 ] || continue      # un ancla corta casaría cualquier cosa
    case "$o" in *"$a"*) ;; *) continue ;; esac
    V12_LIN="$V12_LIN$l "
    case "$V12_ACTO" in *"|$z/$k|"*) ;; *) V12_ACTO="$V12_ACTO|$z/$k|" ;; esac
  done
  # Sólo cuenta como acto EJERCIDO lo que se ejerce sobre el árbol bajo prueba: las anclas
  # salen de SU código, y un DENY de la línea base no dice nada de los actos de esta versión.
  [ "$1" = "$HOOKS_DIR" ] || return 0
  case "$V12_ACTO" in
    '') SIN12=$((SIN12 + 1)); return 0 ;;
    *'||'*) AMB12=$((AMB12 + 1)); return 0 ;;
  esac
  case "$ACT12" in *"$V12_ACTO"*) ;; *) ACT12="$ACT12$V12_ACTO"; NACT12=$((NACT12 + 1)) ;; esac
  return 0
}
PAR12=''; PAR12_LIN=''
par12() {   # <hooks-dir> <cabecera> <json> [texto que el motivo debe NOMBRAR] -> los DOS estados
  local s='' k l
  PAR12_LIN=''
  for k in false true; do
    ver12 "$1" "$k" "$2" "$3"
    s="$s${s:+|}$V12_DEC"
    for l in $V12_LIN; do case " $PAR12_LIN " in *" $l "*) ;; *) PAR12_LIN="$PAR12_LIN$l " ;; esac; done
    if [ "$V12_DEC" = DENY ] && [ -n "${4:-}" ]; then
      case "$V12_OUT" in *"$4"*) s="$s-nombra" ;; *) s="$s-calla" ;; esac
    fi
  done
  PAR12="$s"
}
chk12() {   # <nombre> <esperado> <obtenido>
  if [ -n "$FILTRO" ] && ! printf '%s' "$1" | grep -qi -- "$FILTRO"; then return 0; fi
  if [ "$2" = "$3" ]; then echo "  PASS  $1  [$3]"; PASS=$((PASS+1))
  else echo "  FAIL  $1  esperado=<$2> obtenido=<$3>"; diag; FAIL=$((FAIL+1)); fi
}
uno12() { [ -z "$FILTRO" ] || printf '%s' "$1" | grep -qi -- "$FILTRO"; }

# ---------- LAS CINCO CABECERAS: el mismo REQ con las cinco formas del campo de QA ----------
# Todas con `Rigor: estandar` y sin sensibilidad dudosa: lo que se mide aquí es el ACTO DE
# FIRMAR, y el rigor sólo gobierna el acto de cierre (eso lo mide `40/4`).
CAB_PEND12='QA: pendiente
Seguridad: pendiente
Sensible a seguridad: no
Hallazgos abiertos: (ninguno)
Rigor: estandar'
CAB_HALL12="${CAB_PEND12/QA: pendiente/QA: con-hallazgos}"
CAB_APRO12="${CAB_PEND12/QA: pendiente/QA: aprobado}"
# La AUSENCIA y la línea COMENTADA son la MISMA propiedad por dos vías (REQ-024 § Historia): un
# rango `<!-- … -->` cerrado dentro de la cabecera no declara campo.
CAB_AUS12='Seguridad: pendiente
Sensible a seguridad: no
Hallazgos abiertos: (ninguno)
Rigor: estandar'
CAB_COM12="<!-- QA: aprobado -->
$CAB_AUS12"

# ---------- (1) EL INSTRUMENTO ANTES DEL RESULTADO: la base es otro árbol Y MUERDE ----------
N12="REQ-024 CA-12 instrumento: la linea base es OTRO arbol y MUERDE cuando el campo esta"
if uno12 "$N12"; then
  if [ "$HER12_OK" != si ]; then
    echo "  SKIP  $N12  no hay línea base $BASE12 ($REG12)"
  else
    d12=0; t12=0; c12=''
    for f12 in "$HER12"/hooks/*; do
      [ -f "$f12" ] || continue
      t12=$((t12 + 1))
      if [ ! -f "$HOOKS_DIR/${f12##*/}" ]; then d12=$((d12 + 1)); c12="$c12 ${f12##*/}(no-esta-hoy)"
      elif [ "$(<"$f12")" != "$(<"$HOOKS_DIR/${f12##*/}")" ]; then d12=$((d12 + 1)); c12="$c12 ${f12##*/}"; fi
    done
    par12 "$HER12/hooks" "$CAB_PEND12" "$JF12" pendiente
    if [ "$d12" -lt 1 ]; then
      echo "  FAIL  $N12: los $t12 archivos de $BASE12 son idénticos a los de $HOOKS_DIR, así que el fail-before se toma contra sí mismo y sus ALLOW no acreditan NADA"; FAIL=$((FAIL+1))
    elif [ "$PAR12" != "DENY-nombra|DENY-nombra" ]; then
      echo "  FAIL  $N12: la base $BASE12 responde <$PAR12> donde tiene que DENEGAR nombrando el veredicto declarado. Un NO-CORRIO es un hook que no arrancó y un ALLOW aquí es la guarda del orden ausente: en los dos casos los ALLOW del caso (9) medirían la nada ($REG12)"; FAIL=$((FAIL+1))
    else
      echo "  PASS  $N12: $d12 de $t12 archivos difieren de $BASE12 —$c12— y la base DENIEGA con el campo declarado en los dos estados de la llave, así que corre y muerde ($REG12)"; PASS=$((PASS+1))
    fi
  fi
fi
# ---------- (2) LOS ACTOS DERIVADOS DEL CÓDIGO, con su suelo de 2 ---------------------------
N12="REQ-024 CA-12 (ADR-011) los ACTOS se DERIVAN de las ramas de denegacion, con suelo de 2"
if uno12 "$N12"; then
  if [ -n "$MOT12" ]; then
    echo "  SKIP  $N12  $MOT12"
  else
    echo "  PASS  $N12: $NACTD12 actos de $NRAM12 ramas —$LISTA12—. Derivación (se publica para quien la arregle cuando el código cambie de forma): ACTO = «zona/campo exigido»; la zona la fija la FRONTERA de la transición, línea $FRON12 de guard-completado.sh, la última que devuelve 0 cuando el estado resultante no es el terminal; el campo exigido, la guarda «grep -q '<clave>:' <<< \$nuevo» que domina la rama por sangría. Es una COTA INFERIOR: derivar MÁS actos es conforme y no es hallazgo"; PASS=$((PASS+1))
  fi
fi
# ---------- (3) Y LOS ACTOS EJERCIDOS EN ESTA CORRIDA, no menos de 2 ------------------------
# Va DESPUÉS de todo lo que ejerce la puerta, al final del archivo, porque cuenta lo que las
# sondas de arriba ejercieron. Aquí sólo se anuncia el orden; el caso está al final.
# ---------- (4) (5) (6) LOS TRES CONTROLES, EN LOS DOS ESTADOS DE LA LLAVE ------------------
# El negativo: la guarda MUERDE cuando el campo está y el veredicto no aprueba. «Nombra el
# cruce» se comprueba contra el VALOR de la cabecera —dato del fixture, no texto del código—.
par12 "$HOOKS_DIR" "$CAB_PEND12" "$JF12" pendiente
chk12 "REQ-024 CA-12 control negativo (i): con 'QA: pendiente' la firma DENIEGA nombrando el cruce, en los DOS estados de la llave" \
  "DENY-nombra|DENY-nombra" "$PAR12"
LINPEND12="$PAR12_LIN"
par12 "$HOOKS_DIR" "$CAB_HALL12" "$JF12" con-hallazgos
chk12 "REQ-024 CA-12 control negativo (ii): con 'QA: con-hallazgos' la firma DENIEGA nombrando el cruce, en los DOS estados" \
  "DENY-nombra|DENY-nombra" "$PAR12"
# El positivo, sin el cual un DENY no distingue la guarda de una comprobación que falla siempre.
par12 "$HOOKS_DIR" "$CAB_APRO12" "$JF12"
chk12 "REQ-024 CA-12 control positivo: con 'QA: aprobado' la firma PASA en los dos estados (la guarda no deniega siempre)" \
  "ALLOW|ALLOW" "$PAR12"
# ---------- (7) (8) LA SALIDA (b): la ausencia DENIEGA en los DOS estados y NOMBRA el campo --
par12 "$HOOKS_DIR" "$CAB_AUS12" "$JF12" "$CLQA12:"
N12="REQ-024 CA-12 salida (b): con la linea de QA AUSENTE la firma DENIEGA en los dos estados y el motivo NOMBRA el campo"
if [ -n "$MOT12" ]; then uno12 "$N12" && echo "  SKIP  $N12  $MOT12"
else chk12 "$N12" "DENY-nombra|DENY-nombra" "$PAR12"; fi
LINAUS12="$PAR12_LIN"
par12 "$HOOKS_DIR" "$CAB_COM12" "$JF12" "$CLQA12:"
N12="REQ-024 CA-12 salida (b): con la linea de QA COMENTADA lo mismo, y por una rama DISTINTA de la del veredicto equivocado"
if uno12 "$N12"; then
  if [ -n "$MOT12" ]; then
    echo "  SKIP  $N12  $MOT12"
  else
    dis12=si
    for l12 in $PAR12_LIN; do case " $LINPEND12 " in *" $l12 "*) dis12=no ;; esac; done
    if [ "$PAR12" != "DENY-nombra|DENY-nombra" ]; then
      echo "  FAIL  $N12: el par comentado responde <$PAR12>. Comentar una línea es una VÍA de la misma ausencia, no otra propiedad"; diag; FAIL=$((FAIL+1))
    elif [ "$dis12" != si ] || [ -z "$PAR12_LIN" ]; then
      echo "  FAIL  $N12: la ausencia se deniega por la MISMA rama que el veredicto equivocado (ausente/comentada: «$PAR12_LIN», declarado: «$LINPEND12»). Un motivo que dice «su QA: es ''» deja a la persona buscando un valor que no existe"; FAIL=$((FAIL+1))
    else
      echo "  PASS  $N12: DENY en los dos estados nombrando «$CLQA12:», por la rama $PAR12_LIN de guard-completado.sh —la del veredicto declarado es $LINPEND12, y son distintas—; el par AUSENTE decidió por $LINAUS12"; PASS=$((PASS+1))
    fi
  fi
fi
# ---------- (9) EL FAIL-BEFORE, EN LA MISMA CORRIDA -----------------------------------------
N12="REQ-024 CA-12 fail-before: el MISMO par (ausente, comentada) da ALLOW en los dos estados contra la heredada"
if uno12 "$N12"; then
  if [ "$HER12_OK" != si ]; then
    echo "  SKIP  $N12  no hay línea base $BASE12 ($REG12)"
  else
    par12 "$HER12/hooks" "$CAB_AUS12" "$JF12"; b12="$PAR12"
    par12 "$HER12/hooks" "$CAB_COM12" "$JF12"; c12="$PAR12"
    if [ "$b12|$c12" = "ALLOW|ALLOW|ALLOW|ALLOW" ]; then
      echo "  PASS  $N12: contra $BASE12 las cuatro celdas son ALLOW (ausente <$b12>, comentada <$c12>), así que los DENY de los casos (7) y (8) son del arreglo de SEC-083 y no de un fixture que denegaría siempre"; PASS=$((PASS+1))
    else
      echo "  FAIL  $N12: contra $BASE12 se obtiene ausente <$b12> y comentada <$c12> donde se esperaban cuatro ALLOW. O $BASE12 ya lleva el arreglo —y entonces no es la versión heredada—, o el hook no arrancó (NO-CORRIO). Sin este par, el verde de (7) y (8) no significa nada"; FAIL=$((FAIL+1))
    fi
  fi
fi
# ---------- (10) LA ASIMETRÍA POR ACTO, SOBRE EL MISMO ESTADO Y LA MISMA LLAVE --------------
# Es lo que hace que el suelo de 2 actos no sea decoración: con la llave APAGADA —como nace
# todo proyecto— y la MISMA cabecera sin `QA:`, el CIERRE permite y la FIRMA deniega. `ADR-009`
# enunció su alcance sobre el acto de cierre; si los dos actos decidieran igual, no habría nada
# que `ADR-011` tuviera que extender.
# Los DOS actos NO se comparan contra una etiqueta escrita aquí —eso volvería a enumerar sedes,
# que es lo que `ADR-011` § Alternativas descarta—: se exige que sean DISTINTOS, y quién es cada
# uno lo dice el ancla de la rama que denegó. El cierre se ejerce en los dos estados de la llave
# porque con la apagada PERMITE (y un ALLOW no mapea ningún acto: no hay motivo que anclar).
ver12 "$HOOKS_DIR" true "$CAB_AUS12" "$JC12";  ac12="$V12_ACTO"
ver12 "$HOOKS_DIR" false "$CAB_AUS12" "$JC12"; dc12="$V12_DEC"
ver12 "$HOOKS_DIR" false "$CAB_AUS12" "$JF12"; af12="$V12_ACTO"; df12="$V12_DEC"
N12="REQ-024 CA-12 (ADR-011) asimetria POR ACTO sobre el mismo estado y la llave apagada: el cierre PERMITE donde la firma DENIEGA"
if uno12 "$N12"; then
  if [ -n "$MOT12" ]; then
    echo "  SKIP  $N12  $MOT12"
  elif [ "$dc12/$df12" != "ALLOW/DENY" ]; then
    echo "  FAIL  $N12: con la MISMA cabecera sin «$CLQA12:» y la llave APAGADA el cierre responde <$dc12> y la firma <$df12>, donde se esperaba ALLOW y DENY. Sin esa asimetría no habría nada que ADR-011 tuviera que extender: ADR-009 ya cubría el acto de cierre"; diag; FAIL=$((FAIL+1))
  elif [ -z "$ac12" ] || [ -z "$af12" ] || [ "$ac12" = "$af12" ]; then
    echo "  FAIL  $N12: los dos actos no salen DISTINTOS del código —cierre «$ac12», firma «$af12»—, así que el par mide una sola vez el mismo acto con dos nombres"; FAIL=$((FAIL+1))
  else
    echo "  PASS  $N12: misma cabecera y misma llave (apagada), cierre <$dc12> y firma <$df12>; y los dos actos son DISTINTOS según las ramas que denegaron —cierre «$ac12», firma «$af12»—, que es la asimetría que hace que el suelo de 2 no sea decoración"; PASS=$((PASS+1))
  fi
fi
# ---------- (3) LOS ACTOS EJERCIDOS: el suelo de CA-12, contado por el código ---------------
N12="REQ-024 CA-12 los actos EJERCIDOS en esta corrida no son menos de 2, identificados por el codigo"
if uno12 "$N12"; then
  if [ -n "$MOT12" ]; then
    echo "  SKIP  $N12  $MOT12"
  elif [ "$NACT12" -lt 2 ]; then
    echo "  SKIP  $N12  esta corrida ejerció $NACT12 acto(s) —$ACT12— con suelo de 2: $SIN12 denegación(es) no casaron con ninguna ancla y $AMB12 casaron con anclas de DOS actos, así que el extractor dejó de identificar lo que la puerta emite (ADR-011, consecuencia (−)). No hay PASS que dar: ejercer sólo un acto es volver a medir lo que ADR-009 ya cerró"
  else
    echo "  PASS  $N12: $NACT12 actos EJERCIDOS de los $NACTD12 derivados —$ACT12—, cada uno identificado por el ancla de la rama que lo emitió y no por una etiqueta de este archivo ($SIN12 denegaciones sin mapear, $AMB12 ambiguas). Suelo de CA-12: no menos de 2"; PASS=$((PASS+1))
  fi
fi
rm -rf "$HER12" "$P12"
