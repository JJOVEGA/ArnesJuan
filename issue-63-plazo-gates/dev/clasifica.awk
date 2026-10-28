# clasifica.awk — lee la salida de `grep -rnE '60 ?s' .` (ruta:línea:texto) y antepone a cada resultado su grupo de
# REQ-037 CA-07. Las reglas por línea van primero; las de archivo, después. Lo que no casa con nada sale SIN-CLASIFICAR.
function sal(g) { printf "%-34s %s\n", g, $0; n[g]++; hecho = 1 }
{
  hecho = 0; split($0, c, ":"); f = c[1]; l = c[2] + 0
  sub(/^\.\//, "", f)
  # --- Código del hook (corregido en esta entrega) ---
  if (f == "hooks/lib.sh" && l == 443) sal("A-corregido-historia-en-el-propio-comentario")
  else if (f == "hooks/lib.sh" && $0 ~ /no respondía en 60 s/) sal("D-medicion-timeout-del-banco")
  else if (f == "hooks/lib.sh" && $0 ~ /60 s del `timeout` del banco/) sal("D-medicion-timeout-del-banco")
  # --- Textos vivos que el REQ asigna al write-back del analista (no editados por el desarrollador) ---
  else if (f == "AGENTS.md" && (l == 595 || l == 730)) sal("B-a-corregir-writeback-analista")
  else if (f == "AGENTS.md" && l == 698) sal("D-medicion-timeout-del-banco")
  else if ((f == "requirements/README.md" || f == "templates/requirements-README.md.tpl") && (l == 252 || l == 257)) sal("B-a-corregir-writeback-analista")
  else if ((f == "requirements/README.md" || f == "templates/requirements-README.md.tpl") && l == 221) sal("D-medicion-timeout-del-banco")
  else if (f == "requirements/README.md" && l == 673) sal("F-indice-de-REQ-007-historia")
  else if (f == "requirements/README.md" && l == 698) sal("G-REQ-037-el-contrato-de-la-correccion")
  else if (f == "templates/AGENTS.md.tpl" && l == 694) sal("C-a-corregir-SITIO-NUEVO-fuera-de-Archivos")
  else if (f == "templates/AGENTS.md.tpl" && l == 662) sal("D-medicion-timeout-del-banco")
  else if (f == "skills/arnes-upgrade/SKILL.md" && (l == 1426 || l == 1518)) sal("D-medicion-timeout-del-banco")
  else if (f == "skills/arnes-upgrade/SKILL.md") sal("B2-a-corregir-SKILL-no-encargado-en-esta-fase")
  else if (f == "docs/gobernanza/autoalojamiento.md") sal("B2-a-corregir-autoalojamiento-no-encargado")
  else if (f == "requirements/REQ-007.md" && l >= 2349 && l < 3139) sal("B-REQ-007-CA-68-writeback-analista")
  else if (f == "requirements/REQ-007.md") sal("E-REQ-007-fuera-de-CA-68-historia-u-otro-criterio")
  else if (f == "docs/seguridad/registro-seguridad.md") sal("E-historia-registro-SEC-132a-del-auditor")
  # --- Banco ---
  else if (f ~ /^tests\/escenarios\/hooks\/secciones\/(07|08|25|30|32|37|47)-/) sal("D-banco-seccion-existente-se-queda")
  else if (f ~ /^tests\/escenarios\/hooks\/secciones\/53-/ && (l == 109 || l == 181)) sal("D-medicion-timeout-del-banco")
  else if (f ~ /^tests\/escenarios\/hooks\/secciones\/53-/) sal("G-banco-53-la-comprobacion-de-CA-07")
  else if (f == "tests/escenarios/hooks/README.md" && $0 ~ /Presupuesto de las gates \(53\)/) sal("G-banco-53-la-comprobacion-de-CA-07")
  else if (f == "tests/escenarios/hooks/README.md") sal("D-medicion-timeout-del-banco")
  else if (f == "tests/escenarios/hooks/run.sh") sal("D-medicion-timeout-del-banco")
  else if (f == "tests/escenarios/hooks/autoprueba-corredor.sh") sal("H-falso-positivo-cifra-9,60-s")
  else if (f ~ /^docs\/qa\/1\.33\.2-/) sal("E-historia-salida-de-banco-archivada")
  # --- Historia fechada, otros REQ, el propio REQ y su ADR ---
  else if (f == "CHANGELOG.md") sal("E-historia-CHANGELOG-o-notas-1.36.3")
  else if (f == "PENDING_APPROVAL.md" || f == "docs/PENDIENTES.md" || f ~ /^docs\/qa\// || f ~ /^docs\/arnes\//) sal("E-historia-fechada")
  else if (f ~ /^docs\/decisions\/ADR-018/) sal("G-ADR-018-la-correccion-misma")
  else if (f ~ /^docs\/decisions\/ADR-0(04|13|17)/) sal("E-historia-ADR-anterior")
  else if (f == "requirements/REQ-037.md") sal("G-REQ-037-el-contrato-de-la-correccion")
  else if (f ~ /^requirements\/REQ-0(01|02|14|17|21|23|31)\.md$/) sal("F-otro-REQ-no-se-reabre")
  if (!hecho) sal("SIN-CLASIFICAR")
}
END { print ""; for (g in n) printf "%5d  %s\n", n[g], g | "sort -k2"; }
