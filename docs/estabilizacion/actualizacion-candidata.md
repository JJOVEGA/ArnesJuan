# Actualización candidata: firmas y rigor

Estado: preparada localmente sobre `v1.33.0`; todavía no publicada. Las 17
regresiones nuevas pasan. El banco completo local conserva tres fallos ya
observados en la base; este documento no autoriza una liberación.

Este documento acompaña un parche no publicado sobre v1.33.0. No instala nada
ni cambia el marketplace. No usar la rama de desarrollo como plugin estable.

## Cambios que debe conocer un proyecto consumidor

- Un nivel válido con matiz parentético final conserva su nivel. Por ejemplo,
  `Rigor: critico (por suelo)` exige auditoría también sin sensibilidad declarada.
  Esto puede denegar cierres que v1.33.0 permitía al derivar `estandar`.
- Cambiar una aprobación de seguridad con una clave decorada, o reemplazando
  sólo el valor, aplica el control de QA de la guarda. Una mención en el cuerpo
  no debe confundirse con un cambio del valor de la firma.
- La ausencia de QA y los niveles realmente desconocidos mantienen su tratamiento
  anterior. Este parche no certifica que una aprobación corresponda al commit
  actual y no corrige las demás limitaciones de las guardas.

## Antes de distribuir

1. Revisar el diff y la evidencia del candidato, incluidos los fallos del banco
   completo; no interpretar las pruebas enfocadas como un CI global aprobado.
2. Revisar seguridad y compatibilidad del candidato concreto. No sustituye las
   firmas requeridas para publicar ArnesJuan.
3. Autorizar la versión y su publicación por separado. Después verificar el
   contenido instalado contra la versión publicada.
4. Llevar a los proyectos la aclaración de Nivel de rigor de
   `templates/requirements-README.md.tpl` mediante el procedimiento normal de
   actualización, preservando sus personalizaciones. No reemplazar su archivo
   completo con la plantilla.

El portado a 1.34.0 debe revisar el cambio de la guarda de ausencia de QA de esa
rama: aplicar este diff ciegamente podría eliminar comportamiento posterior.
