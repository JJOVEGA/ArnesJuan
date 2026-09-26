#!/usr/bin/env bash
# Ejecuta el ensayo en CI: abre el PR en borrador (corrida 1) y encadena 4 commits vacíos EN SECUENCIA,
# esperando a que cada corrida termine. Presupuesto: 5 ejecuciones, 60 min de pared. Sin reintentos.
set -u
T=/home/juan/dev/ArnesJuan-ensayo-sondas; O=/home/juan/dev/ArnesJuan-evidencia/sondas-coste/ensayo-ci/corridas
LIM=$((60*60)); T0=$(date +%s); date -u +%FT%TZ > "$O/inicio.txt"
cd "$T"
guardar() {  # <n> <sha>
  local n=$1 sha=$2 id
  for i in $(seq 1 60); do id=$(gh run list --branch ensayo/sondas-r5 --json databaseId,headSha -q ".[] | select(.headSha==\"$sha\") | .databaseId" | head -1); [ -n "$id" ] && break; sleep 10; done
  [ -n "$id" ] || { echo "corrida $n: no apareció run para $sha en 10 min" >> "$O/incidencias.txt"; return 1; }
  echo "corrida=$n sha=$sha run=$id inicio=$(date -u +%FT%TZ)" > "$O/run-$n.meta"
  gh run watch "$id" --exit-status >/dev/null 2>&1
  gh run view "$id" --json status,conclusion,createdAt,updatedAt,jobs -q '"status=\(.status) conclusion=\(.conclusion) created=\(.createdAt) updated=\(.updatedAt) job=\(.jobs[0].conclusion) job_start=\(.jobs[0].startedAt) job_end=\(.jobs[0].completedAt)"' >> "$O/run-$n.meta"
  gh run view "$id" --log > "$O/run-$n.txt" 2>"$O/run-$n.err"
  echo "fin=$(date -u +%FT%TZ)" >> "$O/run-$n.meta"
}
git push -q -u origin ensayo/sondas-r5 || { echo "push falló" >> "$O/incidencias.txt"; exit 1; }
gh pr create --draft --base main --head ensayo/sondas-r5 --title "ENSAYO (no fusionar): comprobación acotada en CI del procedimiento propuesto para las sondas de REQ-017 — 5 ejecuciones" --body "Rama de ensayo. NUNCA se fusiona. Preregistro y resultados: rama de evidencia, sondas-coste/ensayo-ci/. El check saldrá ROJO a propósito (control WD con demora añadida). Autorizado por el propietario el 2026-09-25: máximo 5 ejecuciones, 60 min." > "$O/pr.txt" 2>&1
guardar 1 "$(git rev-parse HEAD)"
for n in 2 3 4 5; do
  el=$(( $(date +%s) - T0 )); if [ "$el" -gt "$LIM" ]; then echo "corrida $n: NO LANZADA (límite de 60 min agotado a los $el s)" >> "$O/limite.txt"; continue; fi
  git commit -q --allow-empty -m "ENSAYO corrida $n de 5 (commit vacio; arbol identico a 83f1e9c)" && git push -q origin ensayo/sondas-r5 || { echo "corrida $n: push falló" >> "$O/incidencias.txt"; break; }
  guardar "$n" "$(git rev-parse HEAD)"
done
date -u +%FT%TZ > "$O/fin.txt"
