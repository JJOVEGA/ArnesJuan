#!/usr/bin/env bash
# medir.sh — el instrumento del diagnóstico de REQ-024 CA-07 (ii). NO es parte del banco.
# Reproduce EXACTAMENTE el sujeto y el fixture del caso, y añade las dos condiciones NULAS.
set -uo pipefail
FASE="${1:-fase1}"; N="${2:-25}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
UTIL="$REPO/tests/util"
OUT="$(dirname "${BASH_SOURCE[0]}")/corridas"; mkdir -p "$OUT"
TRAB="$(mktemp -d)"; trap 'rm -rf "$TRAB"' EXIT

mat() {   # <ref> <destino>
  local ref="$1" dst="$2" l modo tipo oid ruta
  git -C "$REPO" rev-parse -q --verify "$ref^{tree}" >/dev/null || return 1
  while IFS= read -r l; do
    modo="${l%% *}"; l="${l#* }"; tipo="${l%% *}"; l="${l#* }"
    oid="${l%%$'\t'*}"; ruta="${l#*$'\t'}"
    [ "$tipo" = blob ] || continue
    mkdir -p "$dst/${ruta%/*}"
    git -C "$REPO" show "$ref:$ruta" > "$dst/$ruta" || return 1
    case "$modo" in *755) chmod +x "$dst/$ruta" ;; esac
  done < <(git -C "$REPO" ls-tree -r "$ref" -- hooks tools)
  return 0
}
A1="$TRAB/a1"; A2="$TRAB/a2"; B1="$TRAB/b1"; B2="$TRAB/b2"
REFA="$(git -C "$REPO" rev-parse HEAD)"
mat "$REFA" "$A1" || { echo "no se pudo materializar A1" >&2; exit 1; }
mat "$REFA" "$A2" || exit 1
mat v1.33.0 "$B1" || exit 1
mat v1.33.0 "$B2" || exit 1

# El proyecto de prueba y el fixture, calcados de `40/2`.
P="$TRAB/proj"; mkdir -p "$P/.arnes" "$P/requirements" "$P/docs"
cat > "$P/.arnes/config.json" <<'JSON'
{
  "agentes": { "agente_codigo": "desarrollador",
               "conocidos": ["analista-requerimientos","desarrollador","qa-tester","auditor-seguridad"] },
  "codigo_app": { "globs": ["src/*", "app/*"] },
  "quality_gates": ["true"],
  "estados": { "completado": "completado" },
  "requirements_dir": "requirements",
  "pending_approval": "PENDING_APPROVAL.md"
}
JSON
printf '# ESTADO\n' > "$P/docs/ESTADO.md"
printf '## Pendientes\n\n## Resueltas\n' > "$P/PENDING_APPROVAL.md"
# El corpus real y los cuatro fixtures de la clase, como en `40/2`: el sujeto tiene que ver
# el MISMO disco que ve el caso.
cp "$REPO"/requirements/REQ-*.md "$P/requirements/" 2>/dev/null || :
i=0
while IFS= read -r k; do
  [ -n "$k" ] || continue
  i=$((i + 1))
  { printf '# REQ-95%s \xe2\x80\x94 sin %s\nEstado: en-revisi\xc3\xb3n\nSeguridad: n/a\n' "$i" "$k"
    [ "$k" = 'QA' ]                   || printf 'QA: aprobado\n'
    [ "$k" = 'Sensible a seguridad' ] || printf 'Sensible a seguridad: no\n'
    [ "$k" = 'Hallazgos abiertos' ]   || printf 'Hallazgos abiertos: (ninguno)\n'
    [ "$k" = 'Rigor' ]                || printf 'Rigor: estandar\n'
    printf '\n## Historia\nFixture de REQ-024 CA-05.\n'; } > "$P/requirements/REQ-95$i.md"
done <<< $'QA\nSensible a seguridad\nHallazgos abiertos\nRigor'
ENT="$TRAB/ent.json"
CLAUDE_PROJECT_DIR="$P" jq -n --arg fp "$P/requirements/REQ-951.md" --arg c '# REQ-951
Estado: completado
Sensible a seguridad: sí
QA: aprobado
Seguridad: aprobado
Hallazgos abiertos: (ninguno)
Rigor: critico' '{hook_event_name:"PreToolUse",tool_name:"Write",cwd:env.CLAUDE_PROJECT_DIR,
                  tool_input:{file_path:$fp,content:$c}}' > "$ENT"

case "$FASE" in
  fase1)  K=4;  R=6  ;;
  fase1c) K=4;  R=6  ;;   # los MISMOS parámetros del caso, bajo contención
  fase2)  K=8;  R=30 ;;
  fase3)  K=4;  R=6  ;;   # el sujeto FIEL al banco (ver abajo), en reposo
  fase3c) K=4;  R=6  ;;   # el sujeto FIEL al banco, bajo contención
  fase4)  K=8;  R=30 ;;   # el sujeto FIEL, alta precisión: es la ACREDITACIÓN
  *) echo "fase desconocida: $FASE" >&2; exit 2 ;;
esac

# --- EL SUJETO FIEL AL BANCO ------------------------------------------------------------
# `hooks/lib.sh` resuelve la raíz del proyecto PRIORIZANDO `$CLAUDE_PROJECT_DIR` sobre el
# campo `cwd` del input. Dentro del banco, `seccion_nueva` EXPORTA `CLAUDE_PROJECT_DIR` al
# proyecto limpio de la sección, así que el sujeto que el caso mide NO trabaja sobre el
# proyecto del `cwd` del JSON —que lleva el corpus de 31 REQ— sino sobre uno VACÍO. Eso
# divide el coste por ~2,8 y deja la serie pegada al suelo de 50 ms. Las fases 1 y 2 midieron
# el sujeto pesado; las 3 y 4 miden EL DEL BANCO.
PV="$TRAB/proj-vacio"; mkdir -p "$PV/.arnes" "$PV/requirements" "$PV/docs"
cp "$P/.arnes/config.json" "$PV/.arnes/config.json"
printf '# ESTADO\n' > "$PV/docs/ESTADO.md"
printf '## Pendientes\n\n## Resueltas\n' > "$PV/PENDING_APPROVAL.md"
PREF=''
case "$FASE" in fase3|fase3c|fase4) PREF="CLAUDE_PROJECT_DIR='$PV' " ;; esac

# --- La CONTENCIÓN, que reproduce la FORMA del runner de la puerta requerida ------------
# El runner de `hooks-en-linux` tiene 4 vCPU y el banco corre con `ARNES_JOBS=6`: hay más
# trabajo listo que CPU, y eso es lo que ensancha la dispersión. Aquí se reproduce con
# `taskset` sobre 4 de los 8 núcleos y 6 vecinos ocupando esos mismos 4. No pretende
# IGUALAR el runner —está medido que no predicen lo mismo, `docs/arnes/ci-1.34.0-no-discrimina/`—
# sino exhibir la FORMA: más procesos listos que CPU disponibles.
CPUS=0-3; VECINOS=6
ESTORBO=()
contencion_arranca() {
  local i
  for ((i = 0; i < VECINOS; i++)); do
    taskset -c "$CPUS" bash -c 'while :; do :; done' >/dev/null 2>&1 &
    ESTORBO+=( $! )
  done
  sleep 1
}
contencion_para() {
  local p
  for p in "${ESTORBO[@]:-}"; do [ -n "$p" ] && kill -9 "$p" 2>/dev/null || :; done
  ESTORBO=()
}

SONDA=("$UTIL/sonda-reloj.sh")
case "$FASE" in fase1c|fase3c) SONDA=(taskset -c "$CPUS" "$UTIL/sonda-reloj.sh") ;; esac
corre() {   # <condicion> <dir-a> <dir-b>
  local cond="$1" da="$2" db="$3" i reg
  local f="$OUT/$FASE-$cond.txt"
  for ((i = 1; i <= N; i++)); do
    reg="$("${SONDA[@]}" --k "$K" --r "$R" --etiqueta "$FASE-$cond-$i" \
      --sujeto-a "${PREF}bash '$da/hooks/guard-completado.sh' < '$ENT' >/dev/null 2>&1" \
      --sujeto-b "${PREF}bash '$db/hooks/guard-completado.sh' < '$ENT' >/dev/null 2>&1" 2>/dev/null)"
    printf 'rep=%s %s\n' "$i" "$reg" >> "$f"
    printf '.' >&2
  done
  printf ' %s listo\n' "$cond" >&2
}
case "$FASE" in fase1c|fase3c) contencion_arranca; trap 'contencion_para; rm -rf "$TRAB"' EXIT ;; esac
case "$FASE" in
  fase1|fase1c|fase3|fase3c) corre AB "$A1" "$B1"; corre AA "$A1" "$A2"; corre BB "$B1" "$B2" ;;
  fase2|fase4)               corre AB "$A1" "$B1"; corre AA "$A1" "$A2" ;;
esac
case "$FASE" in fase1c|fase3c) contencion_para ;; esac
:
