#!/usr/bin/env bash
# P1 — La promesa PRESENTE de CA-03: ¿emite plataforma y carga en TODAS las ramas de
# emision, y NO publica la cota? Funciones REALES extraidas por rango de linea.
FILTRO=""; PASS=0; FAIL=0; MED37_MOTIVO=''
source "$(dirname "$0")/fn-reales.sh"
# Los DOS mue reales, con el par ya resuelto (linea 344 y 385 del original)
MUE_D='modo=intercalado k=20 series=3 · plataforma=linux-gnu-x86_64-bash5.3 carga=1.42'
MUE_F='modo=intercalado k=1 series=3 · plataforma=linux-gnu-x86_64-bash5.3 carga=1.42'
N='REQ-017 CA-03 caso'
ejerce() { # <etiqueta> <args...>
  local etq="$1"; shift
  local sal; sal="$( "$@" 2>&1 )"
  local ver plat carga cota
  ver="$(printf '%s' "$sal" | sed -nE 's/^  (PASS|FAIL|SKIP)  .*/\1/p')"
  case "$sal" in *'plataforma='*) plat=si ;; *) plat=NO ;; esac
  case "$sal" in *'carga='*) carga=si ;; *) carga=NO ;; esac
  case "$sal" in *'consecutiv'*|*'cota'*|*'no más de 2'*) cota=PUBLICA ;; *) cota=no ;; esac
  printf '%-42s ver=%-6s plataforma=%-3s carga=%-3s cota=%s\n' "$etq" "${ver:-<NADA>}" "$plat" "$carga" "$cota"
}
echo "--- DIRECTA (dir=no-excede, techo 2600) ---"
ejerce 'R1 falta el termino medido'   razon37 "$N" ''      100000 2600 q 210000 105000 no-excede "$MUE_D"
ejerce 'R2 falta la linea base'       razon37 "$N" 200000  ''     2600 q 210000 105000 no-excede "$MUE_D"
ejerce 'R3 bajo el suelo de 50 ms'    razon37 "$N" 40000   20000  2600 q 41000  21000  no-excede "$MUE_D"
ejerce 'R4 banda sin el maximo'       razon37 "$N" 270000  100000 2600 q ''     120000 no-excede "$MUE_D"
ejerce 'R5 direccion no reconocida'   razon37 "$N" 270000  100000 2600 q 320000 120000 al-reves  "$MUE_D"
ejerce 'R6 banda PASS (unanime)'      razon37 "$N" 200000  100000 2600 q 210000 105000 no-excede "$MUE_D"
ejerce 'R7 banda FAIL (unanime)'      razon37 "$N" 400000  100000 2600 q 410000 102000 no-excede "$MUE_D"
ejerce 'R8 techo DENTRO -> abstencion' razon37 "$N" 270000 100000 2600 q 320000 120000 no-excede "$MUE_D"
echo "--- FAIL-BEFORE (dir=excede) ---"
ejerce 'R9 banda PASS invertida'      razon37 "$N" 400000  100000 2600 q 410000 102000 excede "$MUE_F"
ejerce 'R10 banda FAIL invertida'     razon37 "$N" 200000  100000 2600 q 210000 105000 excede "$MUE_F"
ejerce 'R11 techo DENTRO invertido'   razon37 "$N" 270000  100000 2600 q 320000 120000 excede "$MUE_F"
echo "--- SIN dir (la via de CA-04, no de CA-03) ---"
ejerce 'R12 sin dir PASS'             razon37 "$N" 200000  100000 2600 q 210000 105000 '' "$MUE_D"
ejerce 'R13 sin dir FAIL'             razon37 "$N" 400000  100000 2600 q 410000 102000 '' "$MUE_D"
