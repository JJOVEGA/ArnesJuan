# QA: antes de escribir QA:/Hallazgos abiertos: en REQ-023 y REQ-031, la puerta real sobre COPIAS.
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-doc/lib-sonda-qa.sh
for n in 023 031; do
  src=$E/cabecera/REQ-$n.md; est=$(grep -m1 '^Estado:' "$src")
  # (1) cabecera tal cual quedará
  cp "$src" "$F"; juzga "$CAND" "$(jedit "$est" 'Estado: completado')"
  printf 'REQ-%s tal cual           cierre -> %s | %s\n' $n "$DEC" "${MOT:0:230}"
  # (2) misma cabecera con QA y Seguridad aprobados: la puerta llega a leer la lista de hallazgos
  sed -e '0,/^QA:/s/^QA:.*/QA: aprobado/' -e '0,/^Seguridad:/s/^Seguridad:.*/Seguridad: aprobado/' "$src" > "$F"
  juzga "$CAND" "$(jedit "$est" 'Estado: completado')"
  printf 'REQ-%s veredictos verdes cierre -> %s | %s\n' $n "$DEC" "${MOT:0:300}"
  # (3) una edición que no cierra (reabrir/editar prosa) no se bloquea
  cp "$src" "$F"; juzga "$CAND" "$(jedit 'Prioridad: alta' 'Prioridad: alta ')"
  printf 'REQ-%s edición sin cierre -> %s | %s\n' $n "$DEC" "${MOT:0:120}"
done
# (4) el lector del arnés sobre un proyecto con las dos copias
L=$E/proy-lec; rm -rf $L; mkdir -p $L/requirements $L/.arnes; cp $P/.arnes/config.json $L/.arnes/; cp $E/cabecera/REQ-023.md $E/cabecera/REQ-031.md $L/requirements/
bash /home/juan/dev/ArnesJuan-v1.35/tools/arnes-lectura.sh $L > $E/verifica-lectura.txt 2>&1; echo "arnes-lectura rc=$?"; head -4 $E/verifica-lectura.txt
