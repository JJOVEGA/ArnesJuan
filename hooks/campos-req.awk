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
# LA CLAVE SE LEE CON UNA REGLA, NO CON UN LITERAL. Es la transcripcion en awk de
# `arnes_norm_clave` (hooks/lib.sh), y tiene que decir EXACTAMENTE lo mismo: se retira el
# espacio en blanco de los extremos y el enfasis de Markdown que envuelve la clave, y si
# ese enfasis cruzaba los dos puntos (`**Estado:**`) se retira tambien su cierre del
# principio del valor. Si esta mitad y la de bash divergieran, el bloque derivado leeria
# distinto de la puerta — que es el defecto que este arnes existe para cazar; por eso el
# banco alimenta las MISMAS lineas decoradas a los dos lectores y compara.
{
  linea = $0
  p = index(linea, ":")
  if (p == 0) next
  sub(/^[ \t]+/, "", linea); sub(/[ \t]+$/, "", linea)
  p = index(linea, ":")
  if (p == 0) next
  k = substr(linea, 1, p - 1)
  val = substr(linea, p + 1)
  if (k ~ /^[*_`]/) sub(/^[*_`]+/, "", val)   # el cierre del par quedo en el valor
  gsub(/[*_`]/, "", k)
  sub(/^[ \t]+/, "", k); sub(/[ \t]+$/, "", k)
  # `Estado:` toma la PRIMERA aparicion; los demas la ULTIMA (semantica heredada, arriba).
  if      (k == "Estado")               { if (est == "") est = val }
  else if (k == "QA")                   { qa   = val }
  else if (k == "Seguridad")            { seg  = val }
  else if (k == "Sensible a seguridad") { sens = val }
  else if (k == "Hallazgos abiertos")   { hall = val }
  else if (k == "Rigor")                { rig  = val }
}
END { volcar() }
