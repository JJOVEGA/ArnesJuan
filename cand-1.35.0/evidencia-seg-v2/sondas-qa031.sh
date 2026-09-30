. /tmp/claude-1000/-home-juan-dev-ArnesJuan-v1-35/498ed6ee-03a0-4ce1-b63b-6612ed12e677/scratchpad/evidencia-seg-v2/lib-sonda.sh
S0='Estado: en-revisión'
doc "$S0" 'Sensible a seguridad: sí' 'QA: aprobado' 'Seguridad: aprobado' 'Hallazgos abiertos: QA-2 (instrumento)' 'HALLAZGOS ABIERTOS: SEC-1 (contrato)' 'Rigor: critico'
caso "QA-031-01 (R2): canonica instrumento + HALLAZGOS ABIERTOS contrato, Edit" jedit "$S0" 'Estado: completado'
caso "QA-031-01 (R2), Write" jwrite "${DOC/"$S0"/Estado: completado}"
