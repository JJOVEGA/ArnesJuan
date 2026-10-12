# REQ-007 — historia: notas de versionados rendidos dentro de CA-54, CA-58 y CA-60 (1.35.0)

> **Movido desde `requirements/REQ-007.md` el 2026-10-12** por la undécima autorización del propietario
> (ficha **F-136-17**), cabeza de origen **`cecf9b6`**, líneas **1232–1261, 1429–1434 y 1465–1486** (58 líneas, 5 873 bytes medidos).
> **Copia verbatim: no se resumió, no se reordenó y no se corrigió nada.**
> Índice: `docs/historia/REQ-007/README.md`. Contrato: `docs/arnes/v1.37.0-f136-17-fase1.md`.
> Comprobación de que no se perdió ninguna línea: ese contrato, §5, y el índice.

    - **Qué mide la evidencia de arriba:** una sola forma —expansión repetida y **una** escritura al final—.
      No es el peor caso analizable, que es un comando con **muchos destinos**: desde ADR-016 cada destino se
      identifica (CA-47), y ese trabajo crece con su número.
    - **Lo medido en el máximo, 131 072 bytes** (Linux/WSL2; la sonda de QA, con tres formas de destino: A, un
      archivo por destino en el `cwd`; B, un directorio inexistente por destino; C, con `..`):
      - QA, 2026-09-30, cinco corridas alternadas por árbol y forma (`docs/qa/REQ-023.md` § «Vuelta
        excepcional de la quinta autorización», §6, anexo `30-ca54-coste.txt`), con 5 506 a 8 258 destinos:
        `9596e39` de 2,9 a 6,9 s; `43b948a` de 9,5 a 12,1 s.
      - El desarrollador, 2026-10-01, con la sonda de QA sin otro cambio que los árboles y la carpeta (rama
        local de evidencia, `cand-1.35.0/evidencia-dev-r6/`, commit `3b947a1`: `16-sonda-ca54-oficial.txt` y
        `14-sonda-ca54-diff-frente-a-qa.txt`): `9596e39` de 3,1 a 7,2 s; `43b948a` de 9,1 a 13,8 s; el árbol
        con la optimización intentada en esta vuelta, de 6,5 a 9,5 s, **las quince corridas por encima de
        5 s**. Decisión `allow` en todas, idéntica en los tres árboles.
      - En el valor por defecto, 65 536 bytes, también se supera: QA, `9596e39` de 1,3 a 5,7 s y `43b948a`
        de 3,9 a 13,7 s; el desarrollador, `9596e39` de 1,3 a 2,2 s, `43b948a` de 4,2 a 5,7 s y el árbol
        optimizado de 3,3 a 5,0 s.
      - La forma de la evidencia de arriba, en el máximo: de 1,9 a 3,9 s en los tres árboles, decisión `deny`
        en todos (`17-ca54-forma-original-y-controles.txt`). Por eso aquella cifra no veía el incumplimiento.
      - No hay fallo en abierto medido: la corrida más lenta queda a más de cuatro veces de los 60 s en que
        muere un hook. Windows/MSYS, sin medir.
    - **La reparación se detuvo por instrucción del propietario** («Si la optimización no consigue cumplir
      dentro de esta vuelta, detén esa reparación y presenta las cifras y el impedimento concreto»). El intento
      **queda fuera del candidato**, conservado como parche en la evidencia
      (`r6-arbol-completo-con-optimizacion.patch`), y la identificación por destino del candidato sigue siendo
      la de `43b948a`, cuyas cifras son las de arriba. Aquí no se cita ninguna medición del árbol final.
    - **La regla «el máximo baja hasta que cumpla» no se aplica en esta vuelta:** la sexta autorización manda
      conservar el máximo y el defecto; y bajar el máximo hasta cumplir lo llevaría por debajo del defecto,
      que tampoco cumple, y cambiaría lo que se deniega por presupuesto en todos los proyectos.
    - **QA-023-10 sigue abierto** —el campo `Hallazgos abiertos:` no se toca— y es un **impedimento que
      decide el propietario**.
  - **Nota del 2026-09-30 (ADR-016; quinta autorización).** El control de raíz que este criterio cuenta como
    no regresión —«enlace situado fuera de la raíz → ALLOW»— queda **acotado** a un enlace de fuera cuyo
    destino también está fuera (CA-50 (c), versionado). Lo que se escribe **dentro** del proyecto a través de
    un enlace de fuera pasa a juzgarse: el arnés sigue sin juzgar lo que se escribe fuera de su proyecto, que
    es lo que este criterio protege. La evidencia de lo versionado ese día es **CA-66**, con su fail-before
    contra `9596e39`; la de arriba sigue siendo la de 1.31.0.
  - **Nota del 2026-10-01 (sexta autorización; CA-47, puntos 12 y 13).** Un `file_path` con un salto de línea
    es no determinable, y un destino no determinable **no** es el manifiesto: con el manifiesto ilegible, un
    `Write` a `<raíz>/.arnes/config.json␊`, o a `<raíz>/.arnes/config.json␊<raíz>/.arnes/config.json`, ya no
    pasa como la reparación. Tampoco una llamada cuyo `tool_name` lleva un salto (`Write␊` al manifiesto), que
    no identifica ninguna herramienta. Hasta `9596e39` y en 1.33.2 pasaban como la reparación, porque el
    destino se comparaba línea a línea y el nombre de la herramienta se leía por su primera línea. Son
    movimientos de `allow` a `deny`, declarados en CA-66 (versionado del 2026-10-01, punto 5). Medidos por el
    desarrollador a nivel de hook en su batería (`evidencia-dev-r6/32-bateria-bordes-arbol-final.txt`, filas
    M1 a M5, con el control M3: el `Write` al manifiesto sin salto sigue permitido); no son casos del banco.
    La excepción y sus tres condiciones no cambian.
  - **Nota del 2026-10-02 (séptima autorización; CA-47, puntos 11 a 13, para el retorno de carro).** Con el
    manifiesto ilegible tampoco pasan como la reparación: un `Write` a `<raíz>/.arnes/config.json␍` —de la
    coordinadora o del `desarrollador`—, porque un `file_path` con un retorno de carro es no determinable; un
    `Write␍` al manifiesto, que no identifica ninguna herramienta; ni `printf {} > .arnes/config.json` desde un
    `cwd` con un retorno de carro que enlaza a la raíz, porque la ruta relativa no se ancla (la salida es la
    ruta absoluta). Hasta `9596e39` y en 1.33.2 pasaban los cuatro: los tres primeros porque el transporte
    retiraba el retorno de carro final, y el cuarto porque la relativa se leía desde la raíz. Son movimientos
    de `allow` a `deny`, declarados en CA-66 (versionado del 2026-10-02, punto 5). Medidos por el desarrollador
    a nivel de hook en su batería (`evidencia-dev-r7/13-bateria-manifiesto-arbol-final.txt`, filas M2 a M5),
    con los controles M1 —el `Write` al manifiesto sin retorno de carro— y M6 —el `printf` desde la raíz—, que
    siguen permitidos; no son casos del banco. La numeración M de esa batería no es la de `evidencia-dev-r6`,
    citada en la nota anterior. La excepción y sus tres condiciones no cambian.
