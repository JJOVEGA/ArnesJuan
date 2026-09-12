#!/usr/bin/env bash
# Aplica LITERALMENTE la tabla de skills/arnes-upgrade/SKILL.md sobre un proyecto y su base.
proy="$1"; base="$2"
declare -a NOM=('fila del cierre' 'fila del orden' 'parrafo del aviso')
declare -a AO=('No completar sin `QA: aprobado` ' 'Seguridad no firma lo que QA no ha validado (salvo' '**no deniega** la edición: ese REQ no podrá cerrarse')
declare -a AD=('El CIERRE juzga DOS cosas distintas' 'tampoco cuando la línea `QA:` no llega a declararse' 'el aviso lleva su condición')
for i in 0 1 2; do
  o=$(grep -cF "${AO[$i]}" "$proy"); d=$(grep -cF "${AD[$i]}" "$proy")
  ob=$(grep -cF "${AO[$i]}" "$base")
  if [ "$o" = 1 ] && [ "$d" = 0 ]; then
    if [ "$ob" = 0 ]; then est="MODIFICADO (el bloque NO EXISTE en la base: 'difiere' se cumple por vacuidad)"; acc="CONFLICTO: conservar y preguntar"
    else
      # idéntico a la base?
      if diff <(grep -F "${AO[$i]}" "$proy") <(grep -F "${AO[$i]}" "$base") >/dev/null; then est="INTACTO"; acc="sustituir por el bloque destino"
      else est="MODIFICADO"; acc="CONFLICTO: conservar y preguntar"; fi
    fi
  elif [ "$o" = 0 ] && [ "$d" = 1 ]; then est="ya aplicado"; acc="no tocar"
  elif [ "$o" = 0 ] && [ "$d" = 0 ]; then est="ELIMINADO"; acc="CONFLICTO: preguntar, NO reponer"
  else est="UNKNOWN"; acc="detenerse y preguntar"; fi
  printf '  %-20s proy(o/d)=%s/%s base(o)=%-2s -> %-58s %s\n' "${NOM[$i]}" "$o" "$d" "$ob" "$est" "$acc"
done
