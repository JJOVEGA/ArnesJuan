#!/usr/bin/env bash
# Corridas 2-5. El hook pre-commit del repositorio exige CHANGELOG.md en cada commit, así que un commit
# VACÍO no se puede crear: cada corrida añade UNA línea a CHANGELOG.md (el árbol de tests/ queda idéntico;
# se verifica por hash). Mismo presupuesto y límite que el preregistro (60 min desde inicio.txt).
set -u
T=/home/juan/dev/ArnesJuan-ensayo-sondas; O=/home/juan/dev/ArnesJuan-evidencia/sondas-coste/ensayo-ci/corridas
T0=$(date -u -d "$(cat "$O/inicio.txt")" +%s); LIM=$((60*60)); cd "$T"
guardar() { local n=$1 sha=$2 id
  for i in $(seq 1 60); do id=$(gh run list --branch ensayo/sondas-r5 --json databaseId,headSha -q ".[] | select(.headSha==\"$sha\") | .databaseId" | head -1); [ -n "$id" ] && break; sleep 10; done
  [ -n "$id" ] || { echo "corrida $n: no apareció run para $sha en 10 min" >> "$O/incidencias.txt"; return 1; }
  echo "corrida=$n sha=$sha run=$id inicio=$(date -u +%FT%TZ) tests_tree=$(git rev-parse "$sha:tests")" > "$O/run-$n.meta"
  gh run watch "$id" --exit-status >/dev/null 2>&1
  gh run view "$id" --json status,conclusion,createdAt,updatedAt,jobs -q '"status=\(.status) conclusion=\(.conclusion) created=\(.createdAt) updated=\(.updatedAt) job=\(.jobs[0].conclusion) job_start=\(.jobs[0].startedAt) job_end=\(.jobs[0].completedAt)"' >> "$O/run-$n.meta"
  gh run view "$id" --log > "$O/run-$n.txt" 2>"$O/run-$n.err"; echo "fin=$(date -u +%FT%TZ)" >> "$O/run-$n.meta"; }
for n in 2 3 4 5; do
  el=$(( $(date +%s) - T0 )); if [ "$el" -gt "$LIM" ]; then echo "corrida $n: NO LANZADA (límite de 60 min agotado a los $el s)" >> "$O/limite.txt"; continue; fi
  printf '\n<!-- ENSAYO corrida %s de 5 (%s): solo esta linea cambia; tests/ identico a 83f1e9c -->\n' "$n" "$(date -u +%FT%TZ)" >> CHANGELOG.md
  git add CHANGELOG.md && git commit -q -m "ENSAYO corrida $n de 5 (solo CHANGELOG; tests/ identico a 83f1e9c)" && git push -q origin ensayo/sondas-r5 || { echo "corrida $n: commit/push falló" >> "$O/incidencias.txt"; break; }
  guardar "$n" "$(git rev-parse HEAD)"
done
date -u +%FT%TZ > "$O/fin.txt"
