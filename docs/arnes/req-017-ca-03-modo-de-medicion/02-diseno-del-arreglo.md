# Diseño del arreglo (un solo archivo: `secciones/37-coste-del-escaner-2-las-razones.sh`)

1. `mide37` gana un 5.º argumento OPCIONAL `series` (por defecto **3**) y publica además
   `MED37_MAX` y `MED37_DISP`. Por defecto 3 para que la medición directa de CA-03 y los
   cuatro casos de CA-04 queden con su comportamiento EXACTO de hoy: el único caso que
   cambia de configuración es el fail-before de CA-03.
2. El fail-before fija dos parámetros con su motivo escrito:
   - `--k` por el SUELO CON HOLGURA que pide CA-03 (no por el resultado);
   - `--r` (número de series = muestras del mínimo) por la DISPERSIÓN medida, dentro del
     presupuesto de coste declarado (~30 s de CI).
3. El caso publica en los CUATRO veredictos: `k`, `series`, y para cada término su mínimo
   y su máximo en µs. Hoy el FAIL publica sólo el cociente, así que un rojo no dice cuál de
   los dos términos se movió — que es exactamente lo que le pasó al CI.
4. El NOMBRE del caso pasa a ser el mismo en PASS, FAIL y en los dos SKIP (el que ya usaban
   los SKIP), con la evidencia detrás de DOS espacios: es la convención de `razon37` y la
   que `inventario.sh` necesita para normalizar magnitudes y no leer un PASS→FAIL como un
   caso que desaparece y otro que nace.
5. NO se toca ningún umbral (techo 2,600×), no se retira ni se hace opcional ningún caso,
   no se toca `hooks/`, `run.sh` ni la sonda.
6. `PISO_AUTONOMO_SECCION` se re-deriva si crece el bloque indivisible (REQ-014 CA-18).
