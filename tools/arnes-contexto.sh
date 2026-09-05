#!/usr/bin/env bash
# arnes-contexto.sh <REQ-ID> [ruta-del-proyecto] — emite un Context Pack DERIVADO para un REQ.
#
# EXPERIMENTO, NO FEATURE. Existe para medir una hipotesis: que un agente resuelve un REQ
# leyendo menos proyecto si alguien le dice DONDE mirar. No sustituye la lectura del
# codigo; dice por donde empezar. Si el experimento no gana, este archivo se borra.
#
# TODO LO QUE EMITE ES DERIVADO Y DICE DE DONDE SALE:
#   implementa  <- commits cuyo mensaje nombra el REQ (git log --grep). Es un hecho de la
#                  HISTORIA, no una afirmacion semantica: se etiqueta asi.
#   importa     <- SOLO si el proyecto declara como obtener sus dependencias, en el manifiesto:
#                  "contexto": { "dependencias": "npx madge --json src" }. El arnes no trae
#                  parser: mecanismo aqui, mapeo en el proyecto, igual que las quality gates.
#   prueba      <- archivos de test (glob declarado por el proyecto) que importan los de arriba.
#   rigor/NFR   <- se LEEN del propio REQ, no se re-derivan.
#
# LO QUE NO ES: no infiere "depende conceptualmente de". No tiene nodos "module". No avisa
# ni bloquea. Y declara sus puntos ciegos, que el proyecto escribe en el manifiesto.
set -uo pipefail
DIR="${BASH_SOURCE[0]%/*}"; [ "$DIR" = "${BASH_SOURCE[0]}" ] && DIR=.
# shellcheck source=/dev/null
. "$DIR/../hooks/lib.sh"

REQ="${1:?uso: arnes-contexto.sh REQ-NNN [proyecto]}"
PROY="${2:-$PWD}"
MAN="$PROY/.arnes/config.json"
[ -f "$MAN" ] || { printf 'No hay .arnes/config.json en %s\n' "$PROY" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { printf 'Hace falta jq.\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'Hace falta git.\n' >&2; exit 2; }

ARNES_MANIFEST="$MAN"
arnes_jq_file "$MAN" -r '[(.requirements_dir // "requirements"),
                          (.contexto.dependencias // ""),
                          (.contexto.tests_glob // ""),
                          ((.contexto.ciego_a // []) | join(", "))] | .[]'
REQ_DIR=''; DEP_CMD=''; TESTS_GLOB=''; CIEGO=''
{ IFS= read -r REQ_DIR; IFS= read -r DEP_CMD; IFS= read -r TESTS_GLOB; IFS= read -r CIEGO; } <<< "$ARNES_JQ"

sha="$(git -C "$PROY" rev-parse --short HEAD 2>/dev/null || echo '?')"
if git -C "$PROY" diff --quiet 2>/dev/null && git -C "$PROY" diff --cached --quiet 2>/dev/null; then arbol='limpio'; else arbol="CON CAMBIOS SIN COMITEAR ($(git -C "$PROY" status --porcelain 2>/dev/null | wc -l | tr -d ' ') archivos)"; fi

# --- implementa: la historia, no la semantica ---------------------------------
ncommits="$(git -C "$PROY" log --oneline --grep="$REQ" 2>/dev/null | wc -l | tr -d ' ')"
# El propio REQ, el manifiesto y la bitacora no son implementacion: van en los mismos
# commits pero listarlos aqui es ruido que el agente tendria que descartar a mano.
archivos="$(git -C "$PROY" log --name-only --pretty=format: --grep="$REQ" 2>/dev/null   | grep -v '^$' | grep -v "^$REQ_DIR/" | grep -v '^\.arnes/' | grep -v '^CHANGELOG\.md$'   | sort | uniq -c | sort -rn | awk '{print $2 " (" $1 ")"}')"

# --- rigor / NFR / ADR: se leen del REQ -------------------------------------------
reqf="$PROY/$REQ_DIR/$REQ.md"
rigor='—'; sens='—'; nfr='—'; adr='—'; titulo='—'
if [ -f "$reqf" ]; then
  texto=''; IFS= read -r -d '' texto < "$reqf"
  titulo="$(printf '%s' "$texto" | head -1 | sed 's/^# *//')"
  arnes_campos_req "$texto" ''
  rigor="$ARNES_RIGOR"; sens="$ARNES_SENS"
  nfr="$(printf '%s' "$texto" | grep -oE 'NFR-[A-Z0-9-]+' | sort -u | tr '\n' ' ')"; nfr="${nfr:-—}"
  adr="$(printf '%s' "$texto" | grep -oE 'ADR-[0-9]+' | sort -u | tr '\n' ' ')"; adr="${adr:-—}"
fi

printf '# Contexto derivado — %s\n\n' "$REQ"
printf '> **Derivado, no redactado.** Dice dónde mirar; no sustituye leer el código. Expande cuando\n'
printf '> encuentres evidencia de que falta algo — y anota qué faltó, que es el dato del experimento.\n\n'
printf 'generado_de: `%s` · árbol: %s · fecha: %s\n' "$sha" "$arbol" "$(date '+%Y-%m-%d %H:%M')"
[ -n "$CIEGO" ] && printf 'ciego_a (declarado por el proyecto): %s\n' "$CIEGO"
printf '\n## REQ\n%s\nrigor efectivo: `%s` · sensible: `%s` · NFR: %s · ADR: %s\n' "$titulo" "$rigor" "$sens" "$nfr" "$adr"

printf '\n## implementa — según %s commit(s) que nombran %s (historia, no semántica)\n' "$ncommits" "$REQ"
if [ -n "$archivos" ]; then printf '%s\n' "$archivos" | sed 's/^/- /'
else printf -- '- (ningún commit nombra este REQ: la arista está vacía. Hacia adelante se impone con el pre-commit.)\n'; fi

printf '\n## importa\n'
if [ -n "$DEP_CMD" ]; then
  printf -- '- (el proyecto declara `%s`; la normalización de su salida es el siguiente paso del experimento)\n' "$DEP_CMD"
else
  printf -- '- DESCONOCIDO: el proyecto no declara `contexto.dependencias`. Sin herramienta declarada no hay grafo de imports, y no se inventa.\n'
fi
printf '\n## prueba\n'
if [ -n "$TESTS_GLOB" ]; then printf -- '- (glob declarado: `%s`; se cruza con importa cuando exista)\n' "$TESTS_GLOB"
else printf -- '- DESCONOCIDO: el proyecto no declara `contexto.tests_glob`.\n'; fi
