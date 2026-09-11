# Corridas DESCARTADAS, y por qué — se conservan, no se borran

La primera vuelta de la fase 1 se lanzó en segundo plano, el proceso **sobrevivió** a la
llamada que lo lanzó y una segunda invocación de `medir.sh` corrió **encima de la primera**.
Los tres archivos de aquí contienen las dos corridas mezcladas (se ve en `rep=`: la serie
vuelve a empezar a mitad de archivo, y `fase1-AA.txt`/`fase1-BB.txt` tienen 50 registros
para 25 repeticiones).

**No se descartan por incómodas: se descartan porque el sujeto no es el declarado.** Dos
arneses de medida simultáneos son una condición de carga distinta de la del método, y eso
invalida las tres condiciones por igual —incluida la nula—, no una de ellas. Se conservan
porque la variabilidad es evidencia (memoria `variabilidad-no-desmiente-un-fail`) y porque
lo que aquí se ve —cocientes `AB` de 1,032× a 1,125× **con dos arneses encima**— es
información sobre la magnitud del ruido, aunque no sirva para el veredicto.

La vuelta válida se relanzó en primer plano tras comprobar con `pgrep` que no quedaba
ningún proceso de medición vivo.
