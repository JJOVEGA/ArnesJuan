#!/usr/bin/env bash
# bateria-r7-manifiesto.sh — el CR con el manifiesto ilegible (la excepción de reparación de CA-60).
set -u
. "$(dirname "$0")/lib-r7.sh"
nuevo_proyecto
printf '{ roto' > "$P/.arnes/config.json"
fila "M1 coordinadora: Write <raíz>/.arnes/config.json (control: la reparación)"      guard.sh "$(j Write "$P" - "file_path=$P/.arnes/config.json" 'content={}')"
fila "M2 coordinadora: Write <raíz>/.arnes/config.json␍ (CR final en el file_path)"  guard.sh "$(j Write "$P" - "file_path=$P/.arnes/config.json$CR" 'content={}')"
fila "M3 coordinadora: Write␍ a <raíz>/.arnes/config.json (CR en el tool_name)"      guard.sh "$(j "Write$CR" "$P" - "file_path=$P/.arnes/config.json" 'content={}')"
fila "M4 desarrollador: Write <raíz>/.arnes/config.json␍"                            guard.sh "$(j Write "$P" desarrollador "file_path=$P/.arnes/config.json$CR" 'content={}')"
mkdir -p "$F/d"; ln -s "$P" "$F/d$CR"
fila "M5 coordinadora: printf {} > .arnes/config.json desde <fuera>/d␍ (relativa, cwd con CR)" guard.sh "$(j Bash "$F/d$CR" - 'command=printf {} > .arnes/config.json')"
fila "M6 control: printf {} > .arnes/config.json desde <raíz>"                       guard.sh "$(j Bash "$P" - 'command=printf {} > .arnes/config.json')"
