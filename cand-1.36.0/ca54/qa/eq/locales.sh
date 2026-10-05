#!/usr/bin/env bash
# Construye en_US.UTF-8 y tr_TR.UTF-8 (y tr_TR.ISO-8859-9) sin root, con localedef, en un directorio propio.
# Uso posterior: LOCPATH=<dir> LC_ALL=<locale>.
set -u
L=/home/juan/dev/ArnesJuan-evidencia/cand-1.36.0/ca54/qa/eq/loc   # NO se versiona (binario); se reconstruye con este script
mkdir -p "$L"
localedef -i en_US -f UTF-8 "$L/en_US.UTF-8"; echo "en_US.UTF-8 rc=$?"
localedef -i tr_TR -f UTF-8 "$L/tr_TR.UTF-8"; echo "tr_TR.UTF-8 rc=$?"
localedef -i tr_TR -f ISO-8859-9 "$L/tr_TR.ISO-8859-9"; echo "tr_TR.ISO-8859-9 rc=$?"
for l in en_US.UTF-8 tr_TR.UTF-8 tr_TR.ISO-8859-9; do
  printf '%s: charmap=%s ' "$l" "$(LOCPATH=$L LC_ALL=$l locale charmap 2>&1)"
  printf 'bash ${x^^} de "i"=%s ' "$(LOCPATH=$L LC_ALL=$l bash -c 'x=i; echo "${x^^}"' 2>&1 | od -An -c | tr -s ' ')"
  printf 'bash ${x,,} de "I"=%s ' "$(LOCPATH=$L LC_ALL=$l bash -c 'x=I; echo "${x,,}"' 2>&1 | od -An -c | tr -s ' ')"
  printf 'grep -i i ~ I: %s ' "$(echo I | LOCPATH=$L LC_ALL=$l grep -ci i)"
  printf 'grep -i I ~ i: %s\n' "$(echo i | LOCPATH=$L LC_ALL=$l grep -ci I)"
done
