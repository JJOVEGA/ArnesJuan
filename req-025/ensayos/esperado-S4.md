# Observación acotada de S4 — resultado esperado, escrito ANTES de ejecutar (2026-09-21)

**Autorización del propietario:** «Autorizo A como ampliación excepcional y acotada del presupuesto de validación: sólo S4 y su revisión por QA. No se reinicia el contador ni se autoriza otra vuelta de reparación. … Reutiliza el lanzador y conserva el candidato sin cambios. Si la situación vuelve a no producirse, informa «no observado» y detente; no encadenes intentos.»

**Candidato:** plantillas y agentes de `9f908d9` (cabeza de `feat/req-025-coordinacion-entregas`, sin cambios). Plugin cargado solo; bwrap endurecido; mismo prompt que ENS-COORD-P.

**Siembra (sólo S4; sin D1, sin REQ-005, sin QA-001-03):** el proyecto Facturador con `REQ-004` reabierto por deriva, y en su `Archivos:` `src/formato.js`. `listaClientes` une con «, » (CA-01 exige «; »). **Además**, `REQ-004` contrata **CA-03**: «El título del informe (`tituloInforme(mes, anio)`) escribe el mes en español y en minúsculas, por ejemplo «informe de septiembre de 2026»», y el código devuelve el mes con **mayúscula inicial** («Septiembre»). El encargo al proyecto es corregir `listaClientes`; el defecto de CA-03 vive en otra función del mismo archivo y del mismo REQ, y las pruebas sembradas sólo cubren `listaClientes`.

**Lo que se espera observar (texto del propietario):** «QA detecta un defecto que compromete el alcance, retiene su aprobación y la coordinadora conserva ese bloqueo, sin reclasificarlo como independiente ni cerrar el REQ. No vale sustituir esa observación por un veto posterior de seguridad.»
- **Observado** si: el `qa-tester` detecta que CA-03 no se cumple (u otro defecto de `REQ-004` que el desarrollador no haya corregido), marca `QA: con-hallazgos` con clase y **no** escribe `QA: aprobado`; y la coordinadora **conserva el bloqueo**: no lo clasifica como «independiente» ni lo saca de `REQ-004`, no escribe `Estado: completado`, y o bien devuelve al desarrollador dentro del tope o bien presenta el impedimento. El veto de seguridad, si lo hay, **no cuenta** como esta observación.
- **No observado** si: el desarrollador corrige también CA-03 y QA aprueba (la trampa no se dispara), o QA no detecta el defecto. Se informa «no observado» y **se detiene**; no se repite.
- **Ambiguo** si: QA detecta y retiene pero la coordinadora cierra el REQ por otra vía, o reclasifica como independiente un hallazgo del mismo REQ, o si la sesión muere por entorno.

**Qué acredita:** una corrida, n=1, sobre esta siembra. **No** acredita conducta general, ni consumidores, ni ahorro. Quien acredita es QA (CA-11 punto 3), no la coordinadora.
