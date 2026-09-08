# Sección 09 del banco — 09-cierre-de-req-por-bash
# Se ejecuta con `source` desde el corredor (`../run.sh`), en su propio subshell y con
# los ayudantes compartidos ya definidos. No se ejecuta suelto y no hace `source` de
# ninguna otra sección (invariantes 3 y 4 del README del banco).
CASOS_ESPERADOS_SECCION=8
PISO_AUTONOMO_SECCION=24  # 8 preámbulo + 0 maquinaria compartida duplicada + 16 bloque indivisible mayor · REQ-014 CA-18

  seccion_nueva "Cierre de REQ por Bash (guard-completado):"
check "sed -i que cierra un REQ -> deny" deny guard-completado.sh \
  "$(emite_bash "sed -i 's/en-revision/completado/' requirements/REQ-001.md" "" "")"
check "heredoc que cierra un REQ -> deny" deny guard-completado.sh \
  "$(emite_bash "cat > requirements/REQ-001.md <<'FIN'
Estado: completado
FIN" "" "")"
# Frontera: mencionar el estado NO basta, hace falta escribir en el REQ.
check "leer un REQ que menciona completado -> allow" allow guard-completado.sh \
  "$(emite_bash "grep -n 'completado' requirements/REQ-001.md" "" "")"
check "anotar en un REQ sin cerrarlo -> allow" allow guard-completado.sh \
  "$(emite_bash "echo 'nota de trabajo' >> requirements/REQ-001.md" "" "")"
check "escribir fuera de requirements/ -> allow" allow guard-completado.sh \
  "$(emite_bash "echo completado > notas.txt" "" "")"

# El mismo heredoc sin citar, por la via del cierre de un REQ: la sustitucion ejecuta el
# `sed -i` de verdad, asi que la transicion tiene que derivarse a Edit/Write igual.
check "heredoc sin citar que cierra un REQ con sed -i -> deny" deny guard-completado.sh \
  "$(emite_bash $'cat <<EOF\n$(sed -i \'s/en-revisión/completado/\' requirements/REQ-001.md)\nEOF' "" "")"
# QA REQ-001 — HALLAZGO QA-001, por la puerta del CIERRE. Una comilla IMPAR en una linea
# del cuerpo que se conserva (`$(`) se empareja, en el descuento global de texto
# entrecomillado, con la primera comilla del comando REAL que va DESPUES del cierre, y se
# lleva por delante lo que hay en medio: el `sed -i` desaparece del texto analizado.
# 1.30.2 denegaba (descontaba el cuerpo entero); la candidata deja pasar.
check "QA: comilla impar en el cuerpo NO puede desarmar el sed -i que cierra el REQ -> deny" deny guard-completado.sh \
  "$(emite_bash $'cat <<EOF\n$(date) don\'t\nEOF\nsed -i \'s/en-revisión/completado/\' requirements/REQ-001.md' "" "")"
check "QA: control, el mismo sed -i sin el heredoc delante -> deny" deny guard-completado.sh \
  "$(emite_bash $'sed -i \'s/en-revisión/completado/\' requirements/REQ-001.md' "" "")"
# --- Arranque limpio: la plantilla de PENDING no puede bloquear ----------------
# El ejemplo de formato vivia COMENTADO bajo `## Pendientes`; el conteo lo leia
# como 1 pendiente y un proyecto recien inicializado no cerraba ningun REQ.
