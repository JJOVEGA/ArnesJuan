# UNA pasada de awk sobre TODOS los REQ: por archivo, los seis campos de cabecera, crudos.
# Sustituye a dos bucles `while read` en bash por archivo, que con REQ de 244 KB costaban
# ~90 s por parada (medido en un proyecto real). awk procesa 4 MB en una fraccion de segundo.
#
# SEMANTICA HEREDADA, no disenada, y se conserva byte a byte para no cambiar lo que el
# bloque decia: `Estado:` toma la PRIMERA aparicion (asi lo hacia el bucle, con break);
# los demas campos toman la ULTIMA (asi lo hace arnes_campos_req, que es lo que usa la
# puerta). Un REQ bien formado tiene una sola de cada; la asimetria solo se nota en los
# malformados, y ahi se prefiere no cambiar de opinion en silencio.
#
# Salida: una linea por archivo, campos separados por \001 (nunca aparece en un REQ):
#   ruta \001 Estado \001 QA \001 Seguridad \001 Sensible \001 Hallazgos \001 Rigor
function volcar() {
  if (f != "") printf "%s\001%s\001%s\001%s\001%s\001%s\001%s\n", f, est, qa, seg, sens, hall, rig
  est = ""; qa = ""; seg = ""; sens = ""; hall = ""; rig = ""; fin = 0
}
FNR == 1 { volcar(); f = FILENAME }
{ sub(/\r$/, "") }
# LOS CAMPOS VALEN SOLO EN LA CABECERA: antes del primer `## `. Medido: una linea
# `Seguridad: aprobado (A-009, 2026-09-02)` dentro de `## Historial de cambios` se leia
# como el veredicto y cerraba un REQ critico con la cabecera en pendiente. Regla
# estructural, la de la plantilla; no depende del nombre de ninguna seccion.
/^## / { fin = 1 }
fin    { next }
/^Estado:/               { if (est == "") est = substr($0, 8) }
/^QA:/                   { qa   = substr($0, 4) }
/^Seguridad:/            { seg  = substr($0, 11) }
/^Sensible a seguridad:/ { sens = substr($0, 22) }
/^Hallazgos abiertos:/   { hall = substr($0, 20) }
/^Rigor:/                { rig  = substr($0, 7) }
END { volcar() }
