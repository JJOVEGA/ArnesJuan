QA7_OLD = "QA-114, QA-116, QA-117 y QA-023-10 contrato abiertos); docs/qa/REQ-023.md)"
QA7_NEW = ("QA-114, QA-116, QA-117 y QA-023-10 contrato abiertos); 2026-10-02, re-verificación de la pasada correctiva de la octava autorización, árbol 5669a2c (código befc17a): "
 "QA-023-16, QA-023-17 y P-122-A (1) CERRADOS por los casos propios de QA —git stash<CR>, git reset --hard<CR>, git checkout .<CR> y sus tres variantes y el CR en medio de una orden (git clean<CR> -f, git sta<CR>sh) deniegan con motivo; "
 "src/log, requirements/log y cuatro variantes más de un enlace hacia un descriptor dentro del ámbito deniegan, y lo legítimo bajo /dev sigue pasando—; "
 "en las baterías de r8 re-ejecutadas cambian 16 filas, todas de allow a deny y todas de las formas reparadas o del CR en medio declarado; ningún deny a allow frente a 9596e39 y 1.33.2 fuera de las seis clases del 2026-09-30 y la de K6; "
 "falsos positivos (lecturas de git con CR) no hay; sin regresión en SEC-122, QA-023-14 (lectura byte a byte igual a 9220c71), QA-023-15, QA-023-09 y QA-023-13; "
 "coste de la copia sin CR de guard-git lineal (procedimiento registrado antes de medir, con adenda previa: 2,4 s frente a 1,5 s de 9220c71 a 131072 bytes de órdenes git con CR); "
 "sección 45 206 PASS y con los hooks de 9220c71 18 FAIL, todos del bloque C; banco completo 1776 PASS, 0 FAIL, 11 SKIP, cuadre 1787; autoprueba 117/0; gates rc 0; contrato fiel; "
 "VEREDICTO FAVORABLE para la pasada correctiva y para el delta de la octava autorización; QA pendiente se mantiene por lo ajeno al delta (bloques B y C sin rendir; QA-114, QA-116, QA-117 y QA-023-10 contrato abiertos); docs/qa/REQ-023.md)")
COB = "; 2026-10-02, re-verificación de la pasada correctiva de la octava autorización, árbol 5669a2c (código befc17a): se mantiene, sin regresión —secciones 41 a 45 en verde, banco completo 1776 PASS, 0 FAIL, 11 SKIP, cuadre 1787—; docs/qa/REQ-023.md)"
T23_OLD = "no cubre QA-023-14 ni QA-023-15, instrumento y registrados en REQ-007, que no tocan CA-13; docs/qa/REQ-023.md)"
T23_NEW = "no cubre QA-023-14 ni QA-023-15, instrumento y registrados en REQ-007, que no tocan CA-13" + COB
T31_OLD = "QA-023-14, registrado en REQ-007, es una instancia nueva de la clase de SEC-115 introducida por 3bc7d3c; docs/qa/REQ-023.md)"
T31_NEW = "QA-023-14, registrado en REQ-007, es una instancia nueva de la clase de SEC-115 introducida por 3bc7d3c" + COB.replace("se mantiene, sin regresión", "se mantiene, sin regresión, y QA-023-14 queda cerrado en REQ-007")
T01_OLD = "sin regresión frente a cd6afa6—; QA-023-13 cerrado; docs/qa/REQ-023.md)"
T01_NEW = "sin regresión frente a cd6afa6—; QA-023-13 cerrado" + COB
