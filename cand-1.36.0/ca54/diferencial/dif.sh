#!/usr/bin/env bash
# dif.sh <hooks base> <hooks candidato> -> compara en todos los escenarios; imprime resumen
B="$1"; C="$2"; R="${3:-/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/dif/r}"
bash ./prepara.sh "$R"; P="$R/proy"
bash ./destinos.sh "$P" "$R/fuera" > "$R/lista"
n=0; difs=0; total=0
for tool in Bash Write; do
 for cw in "$P" "$P/" "$P/docs" "$P/src" "$P/docs/enl" "$R/fuera" "$P/noexiste" relativo - "/"; do
  for cwcr in 0 1; do
   [ "$cwcr" = 1 ] && [ "$cw" != "$P" ] && continue
   for fpcr in 0 1; do
    [ "$fpcr" = 1 ] && [ "$tool" = Bash ] && continue
    n=$((n+1))
    (cd /tmp && bash "/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/dif/corre.sh" "$B" "$P" "$cw" "$tool" "$cwcr" "$fpcr" "$R/lista") > "$R/b.$n" 2>&1
    (cd /tmp && bash "/tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-36/c663bbbc-295c-4125-8a55-fa8b37c80e91/scratchpad/dif/corre.sh" "$C" "$P" "$cw" "$tool" "$cwcr" "$fpcr" "$R/lista") > "$R/c.$n" 2>&1
    total=$((total + $(wc -l < "$R/b.$n")))
    if ! cmp -s "$R/b.$n" "$R/c.$n"; then difs=$((difs+1)); echo "DIFERENCIA escenario $n: tool=$tool cwd=$cw cwdcr=$cwcr fpcr=$fpcr"; diff "$R/b.$n" "$R/c.$n" | head -6; fi
   done
  done
 done
done
echo "escenarios=$n lineas_por_arbol=$total escenarios_con_diferencias=$difs"
