# Sección 06 del banco — 06-bash-escrituras-evidentes
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=19
PISO_AUTONOMO_SECCION=44  # 8 preámbulo + 0 maquinaria compartida duplicada + 36 bloque indivisible mayor · REQ-014 CA-18

  seccion_nueva "Bash — escrituras evidentes (cobertura parcial):"
check "coordinadora: redirección a código -> deny"      deny guard-codigo.sh "$(emite_bash 'cat > src/app.ts <<< "export const x = 1;"' "" "")"
check "coordinadora: >> pegado al archivo -> deny"      deny guard-codigo.sh "$(emite_bash 'echo x >>src/app.ts' "" "")"
check "coordinadora: ruta absoluta del proyecto -> deny" deny guard-codigo.sh "$(emite_bash "echo x > $PROJ/src/app.ts" "" "")"
check "coordinadora: tee sobre código -> deny"          deny guard-codigo.sh "$(emite_bash 'echo x | tee src/app.ts' "" "")"
check "coordinadora: sed -i sobre código -> deny"       deny guard-codigo.sh "$(emite_bash "sed -i 's/a/b/' src/app.ts" "" "")"
check "coordinadora: cp a directorio de código -> deny" deny guard-codigo.sh "$(emite_bash 'cp /tmp/x.ts src/' "" "")"
check "coordinadora: mv a directorio de código -> deny" deny guard-codigo.sh "$(emite_bash 'mv /tmp/x.ts src' "" "")"
check "coordinadora: escritura en la segunda orden encadenada -> deny" deny guard-codigo.sh "$(emite_bash 'npm run build && echo listo > app/gen.ts' "" "")"
# Controles positivos del descuento de heredocs (1.30.2): lo que NO es cuerpo sigue viendose.
check "heredoc: el cuerpo se descuenta, pero el cp DESPUES del cierre -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<\'EOF\'\ntexto que no escribe nada\nEOF\ncp /tmp/x.ts src/' "" "")"
check "heredoc: la redireccion en la PROPIA linea del heredoc -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF > src/gen.ts\nexport const x = 1;\nEOF' "" "")"
check "here-string (<<<) no es heredoc: el cp de detras sigue viendose -> deny" deny guard-codigo.sh \
  "$(emite_bash 'cat <<< "hola" ; cp /tmp/x.ts src/' "" "")"
check "aritmetica \$((1<<n)) no es heredoc: el cp de la linea siguiente sigue viendose -> deny" deny guard-codigo.sh \
  "$(emite_bash $'echo $((1<<n))\ncp /tmp/x.ts src/' "" "")"
# --- Heredoc SIN CITAR: el cuerpo no es solo texto (medido en 1.30.2) ---------------
# Una revision externa escribio codigo protegido con `cat <<EOF` / `$(echo x > src/...)`:
# el shell EJECUTA la sustitucion y crea el archivo, pero el detector descontaba TODO el
# cuerpo del heredoc como texto y devolvia ALLOW. Con el delimitador sin citar se
# conservan y se analizan las lineas con una sustitucion; el resto sigue siendo texto.
check "heredoc sin citar: una sustitucion escribe en codigo protegido -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/generated.ts)\nEOF' "" "")"
check_motivo "heredoc sin citar: ...y el motivo nombra el archivo que se crearia" "src/generated\.ts" \
  guard-codigo.sh "$(emite_bash $'cat <<EOF\n$(echo x > src/generated.ts)\nEOF' "" "")"
check "heredoc sin citar: acentos graves que escriben en codigo -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n`echo x > src/a.ts`\nEOF' "" "")"
check "heredoc sin citar con <<- y sangria: cp al codigo dentro de la sustitucion -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<-EOF\n\t$(cp README.md src/a.ts)\n\tEOF' "" "")"
# Sin delimitador de cierre el bucle tiene que TERMINAR igual y seguir viendo la sustitucion.
check "heredoc sin citar y sin cierre: la sustitucion se sigue viendo -> deny" deny guard-codigo.sh \
  "$(emite_bash $'cat <<EOF\n$(echo x > src/a.ts)' "" "")"
check_motivo "el deny por Bash admite que la cobertura es parcial" "parcial" \
  guard-codigo.sh "$(emite_bash 'echo x > src/app.ts' "" "")"
check "desarrollador (con prefijo) escribe por Bash -> allow" allow guard-codigo.sh "$(emite_bash 'echo x > src/app.ts' "a10" "arnes-juan:desarrollador")"

