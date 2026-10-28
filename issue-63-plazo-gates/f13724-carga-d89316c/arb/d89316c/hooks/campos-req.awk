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
  est = ""; qa = ""; seg = ""; sens = ""; hall = ""; rig = ""; fin = 0; cita = 0
}
# LA NOCION DE CITA, transcrita de `arnes_sin_cita` (hooks/lib.sh): lo que cae dentro de un
# rango `<!--` … `-->` no declara campo. El hueco se sustituye por UN ESPACIO —nunca por
# nada— para no FABRICAR una clave pegando los dos extremos, y `cita` cruza lineas porque
# el rango tambien. Si esta mitad y la de bash divergieran, el bloque derivado leeria
# distinto de la puerta: es el defecto que este arnes existe para cazar, y el que produjo
# la regresion que esta regla cierra.
#
# LA LINEA LLEGA CRUDA, con sus retornos de carro, y el ORDEN es parte de la transcripcion:
# primero el rango, DESPUES el descuento del CR (en la normalizacion de la clave, igual que
# `arnes_norm_clave`). Retirar un caracter no puede destruir un delimitador pero SI puede
# crearlo, y las dos mitades tenian aqui su unica divergencia medida: bash descontaba TODOS
# los CR antes de escanear y este awk solo el FINAL, asi que `-\r->` era `-->` para la
# puerta y no para el bloque derivado (H-01, `docs/qa/1.32.1-hallazgos.md`). Ahora ninguna
# de las dos descuenta nada antes de escanear.
function sincita(l,   out, p, q) {
  out = ""
  if (cita) {
    q = index(l, "-->")
    if (q == 0) return ""
    l = substr(l, q + 3); cita = 0
  }
  while ((p = index(l, "<!--")) > 0) {
    out = out substr(l, 1, p - 1) " "
    l = substr(l, p + 4)
    q = index(l, "-->")
    if (q == 0) { cita = 1; return out }
    l = substr(l, q + 3)
  }
  return out l
}
FNR == 1 { volcar(); f = FILENAME }
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
  linea = sincita($0)
  gsub(/\r/, "", linea)   # el CR se descuenta AQUI, despues del rango: `arnes_norm_clave`
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
