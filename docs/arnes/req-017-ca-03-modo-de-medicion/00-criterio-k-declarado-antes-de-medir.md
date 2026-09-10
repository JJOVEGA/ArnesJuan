# Criterio de elección de k para el fail-before de REQ-017 CA-03
Declarado 2026-09-09 ANTES de tomar ninguna medida. Sujeto: v1.32.1 (inmutable).

CA-03 constriñe k así: «k tal que el MÍNIMO de cada serie supere 50 ms», y fija el
estadístico en el MÍNIMO «porque la carga sólo puede subir los dos términos».

## Variable de decisión
La variable de decisión es la DISPERSIÓN y el SUELO. NO es el cociente resultante.
El cociente (techo 2,600×) no entra en la elección: se observa después, y si con la
k elegida por este criterio el fail-before no discrimina, eso es el HALLAZGO.

## Escalera de candidatos (fija, en orden; se recorre hasta el primero que cumpla)
k ∈ {1, 2, 3, 5, 8, 12, 20}

## Condiciones que debe cumplir la k elegida (las dos, en N corridas independientes)
- (A) SUELO CON HOLGURA: min de CADA serie ≥ 5 × 50 ms = 250 000 µs en las N corridas.
- (B) REPRODUCIBILIDAD:
  (B1) dispersión intra-invocación (max−min)/min de la sonda ≤ 10 % en los dos términos;
  (B2) dispersión inter-corrida del cociente ≤ 10 % relativo: (max q − min q)/min q ≤ 0,10
       sobre las N corridas.
N = 5 corridas independientes por cada k candidata.

## Techo de coste que se acepta
El propietario aceptó ~30 s adicionales de CI para este caso. Si ninguna k de la escalera
cumple (B) dentro de ese presupuesto, se elige la mayor k que quepa en el presupuesto,
se DECLARA que (B) no se alcanzó y se publica la dispersión: eso sería el hallazgo.

## Lo que se publica en la línea del veredicto (exigido por la comisión)
k, los dos términos en µs, y min/max de cada serie (dispersión), tanto en PASS como en FAIL.
