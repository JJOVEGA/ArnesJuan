#!/usr/bin/env bash
# Vuelta 3: la propiedad escrita («deniega sii ambigua ∧ alguna Estado terminal ∧ la que gobierna en disco no lo decía»)
# frente a la puerta real, por Edit literal, MultiEdit y Write; y la vía (g).
. "$(dirname "$0")/qa-lib.sh"
T='Sensible a seguridad: sí'; Q='QA: aprobado'; G='Seguridad: aprobado'; H='Hallazgos abiertos: (ninguno)'; R0='Rigor: critico'
BS=$(printf '\\')
# fila <id> <prediccion> <via E|M|W> <old> <new> ; DOC = disco. Veredictos en verde: si la regla no deniega, se permite (salvo cierre normal con veredictos rojos)
TOT3=0; MAL3=0
fila() { local id="$1" pred="$2" via="$3" o="$4" n="$5" j res
  printf '%s' "$DOC" > "$F"
  case "$via" in E) j="$(jedit "$o" "$n")";; M) j="$(jmulti "$o" "$n")";; W) res="${DOC/"$o"/"$n"}"; j="$(jwrite "$res")";; esac
  juzga "$CAND" "$j"; local c=$DEC m="${MOT:0:70}"
  case "$m" in *AMBIGUA*) m="AMBIGUA";; esac
  TOT3=$((TOT3+1)); local mk=''; [ "$pred" = "$c" ] || { mk='  <<< CONTRADICE EL TEXTO'; MAL3=$((MAL3+1)); }
  printf '%-58s %s pred=%-5s cand=%-5s | %s%s\n' "$id" "$via" "$pred" "$c" "$m" "$mk"; }
echo "## A. Propiedad (Edit literal, MultiEdit, Write): disco -> edición de otra línea (Rigor) o del estado"
for v in E M W; do
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'ESTADO: completado';           fila "A1 gob no-terminal + variante terminal, editar Rigor" deny $v "$R0" "$R0 "
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'Estado: completado';           fila "A2 gob no-terminal + exacta repetida terminal (X1)" deny $v "$R0" "$R0 "
doc 'ESTADO: completado' "$T" "$Q" "$G" "$H" "$R0";                                 fila "A3 sin exacta + variante terminal (X2)" deny $v "$R0" "$R0 "
doc 'Estado: completado' "$T" "$Q" "$G" "$H" "$R0" 'ESTADO: completado';            fila "A4 gob TERMINAL + variante terminal (cerrado)" allow $v "$R0" "$R0 "
doc 'Estado: completado' "$T" "$Q" "$G" "$H" "$R0" 'qa: x';                          fila "A5 gob terminal + otra ambigüedad (cerrado)" allow $v "$R0" "$R0 "
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'estado: en-progreso';          fila "A6 ambigua, ninguna Estado terminal" allow $v "$R0" "$R0 "
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'qa: aprobado';                 fila "A7 ambigua (QA), cierre del Estado exacto" deny $v 'Estado: en-revisión' 'Estado: completado'
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0";                                fila "A8 no ambigua, cierre normal (verde)" allow $v 'Estado: en-revisión' 'Estado: completado'
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'ESTADO: completado';           fila "A9 retirar la variante terminal" allow $v $'\nESTADO: completado' ''
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'Estado: completado';           fila "A10 X1: retirar la 1a (queda cierre normal, verde)" allow $v $'Estado: en-revisión\n' ''
doc 'Estado: en-revisión' "$T" 'QA: pendiente' "$G" "$H" "$R0" 'Estado: completado'; fila "A11 X1: retirar la 1a con QA pendiente (puerta de siempre)" deny $v $'Estado: en-revisión\n' ''
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'ESTADO: completado' 'qa: x'; fila "A12 variante terminal + otra ambig.; quitar sólo la otra" deny $v $'\nqa: x' ''
done
rm -f "$F"; doc 'Estado: completado' "$T" "$Q" "$G" "$H" "$R0" 'qa: x'; juzga "$CAND" "$(jwrite "$DOC")"; TOT3=$((TOT3+1)); echo "A13 archivo nuevo (sin disco) ambiguo con terminal, Write          W pred=deny  cand=$DEC"; [ "$DEC" = deny ] || MAL3=$((MAL3+1))
echo; echo "## B. Frontera (g): Edit/MultiEdit cuyo old_string no está literal pero el CLI 2.1.284 sí lo encuentra (\\uXXXX)"
doc 'Estado: en-revisión' "$T" 'qa: pendiente' "$G" "$H" "$R0"
fila "B1 cierre con variante qa: pendiente, old LITERAL (control)" deny E 'Estado: en-revisión' 'Estado: completado'
fila "B2 idem, old 'Estado: en-revisi\\u00f3n' + línea Estado entera" deny E "Estado: en-revisi${BS}u00f3n" 'Estado: completado'
fila "B3 idem por MultiEdit" deny M "Estado: en-revisi${BS}u00f3n" 'Estado: completado'
doc 'Estado: en-revisión' "$T" "$Q" "$G" "$H" "$R0" 'ESTADO: completado'
fila "B4 X0: editar Rigor con old 'Rigor: critic\\u006f'" deny E "Rigor: critic${BS}u006f" "$R0 "
doc 'Estado: en-revisión' 'Sensible a seguridad'$'\xc2\xa0'': sí' 'QA: pendiente' 'Seguridad: pendiente' "$H" 'Rigor: ligero'
fila "B5 R8-like (NBSP en Sensible, ligero), literal (control)" deny E 'Estado: en-revisión' 'Estado: completado'
fila "B6 idem con old escapado + línea Estado entera" deny E "Estado: en-revisi${BS}u00f3n" 'Estado: completado'
echo "TOTAL=$TOT3 CONTRADICEN_EL_TEXTO=$MAL3"
