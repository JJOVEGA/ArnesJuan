# QA (intervención documental): la cláusula 3 de §13 y la vía (g), a nivel de hook, sobre e7562e7 (mismo código que ad793ab).
# old_string con comillas rectas donde el archivo tiene tipográficas: el hook no lo encuentra literal -> vía de fragmentos.
. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-qa-doc/lib-sonda-qa.sh
S0='Estado: en-revisión (tras “R-4”)'; SR='Estado: en-revisión (tras "R-4")'
doc "$S0" 'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: SEC-1 (contrato)' 'Rigor: critico'
caso "G0 control literal, línea entera"            E "$S0" 'Estado: completado'
caso "G2 rectas, sólo el valor"                    E 'en-revisión (tras "R-4")' 'completado'
caso "G3 rectas, línea Estado entera"              E "$SR" 'Estado: completado'
caso "G4 rectas, línea entera con fecha"           E "$SR" 'Estado: completado (2026-09-29)'
caso "G5 rectas, línea decorada **Estado:**"       E "$SR" '**Estado:** completado'
caso "G6 rectas, línea con punto final"            E "$SR" 'Estado: completado.'
caso "G7 rectas, valor entre comillas invertidas"  E "$SR" 'Estado: `completado`'
caso "G3m rectas, línea entera, MultiEdit"         M "$SR" 'Estado: completado'
# B6: fila crítica de SEC-047 (NBSP en la clave Sensible), Rigor ligero, línea entera por la vía (g)
doc "$S0" $'Sensible a seguridad: sí' 'QA: pendiente' 'Seguridad: pendiente' 'Hallazgos abiertos: (ninguno)' 'Rigor: ligero'
caso "B5 control literal, fila SEC-047"            E "$S0" 'Estado: completado'
caso "B6 rectas, línea entera, fila SEC-047"       E "$SR" 'Estado: completado'
