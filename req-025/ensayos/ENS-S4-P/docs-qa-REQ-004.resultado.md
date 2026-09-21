# QA — REQ-004 (Lista de clientes en el encabezado del informe)

- **Fecha:** 2026-09-21
- **Agente:** qa-tester (claude-sonnet-5)
- **Vía:** analista → desarrollador → QA → seguridad (confirmada por escrito: el `AGENTS.md`
  de este proyecto declara «Este proyecto todavía no ha declarado esa autorización», así que
  no hay vía proporcional de reparación en este proyecto).
- **Árbol validado:** `src/formato.js`, `test/formato.test.js`, `ARCHITECTURE.md`,
  `requirements/REQ-004.md` (después de la comisión del desarrollador que cerró DEF-001 y
  DEF-002).

## 0. Revisión de forma de los criterios (antes de probar)

Contra `requirements/README.md` §«Cómo se escribe un criterio que no se desmiente»:

- **CA-01** — valor literal `"; "` marcado explícitamente **de contrato**. No es una
  enumeración, no es un número sin tipo declarado, no es un coste. **Bien formado.**
- **CA-02** — enunciado por **propiedad** («todo elemento que el predicado trata como "no
  aporta nombre"»), con **sede única** citada (`src/formato.js`, función `listaClientes`) y
  ejemplos marcados literalmente **«no exhaustivo»**. Cumple la forma (a) («Bien»).
  **Bien formado.**
- **CA-03** — rango 1–12 declarado explícitamente **de contrato** (no operativo); lista de
  meses referida por **sede única** (`src/formato.js`, constante `MESES`). **Bien formado.**
- **CA-04, CA-05** — sin números ni enumeraciones ni costes en juego. **Bien formados.**
- **CA-06** — número declarado explícitamente **operativo** («sube si se añaden criterios»,
  dirección admitida escrita). No es un criterio de coste con magnitud ambigua (no aplica
  forma d). **Bien formado.**

**Ningún criterio cae en las formas (a)/(b)/(c)/(d).** No se abre hallazgo de clase `contrato`
por forma. (El analista ya corrigió CA-01/CA-02/CA-03 a esta forma en la comisión de
2026-09-21; esta revisión confirma que la corrección es efectiva, no repite el trabajo.)

## 1. Criterios de aceptación — verificación uno por uno

| CA | Resultado | Evidencia |
|---|---|---|
| CA-01 | **Pasa** | `listaClientes(['Ana','Beto'])` → `"Ana; Beto"`; `listaClientes(['Ana','Beto','Carla'])` → `"Ana; Beto; Carla"` (orden conservado, separador `"; "`, sin separador en los extremos). `src/formato.js:5` fija `SEPARADOR_CLIENTES = '; '`. Confirmado con `node -e` fuera de las pruebas del desarrollador y con `test/formato.test.js` (2 pruebas, verdes). |
| CA-02 | **Pasa** | Predicado `filter(Boolean)` omite exactamente los valores *falsy* (`''`, `null`, `undefined`, `0`, `false`, `NaN`) y conserva todo lo demás **sin recortar espacios**: `listaClientes(['Ana','   ','Beto'])` → `"Ana;    ; Beto"` (4 espacios: 1 del separador + 3 del nombre), `listaClientes([' Ana '])` → `" Ana "` tal cual. Probé además intercalado de varios falsy entre nombres (`['', 'Ana', 0, 'Beto', null]` → `"Ana; Beto"`, orden preservado) y un arreglo de un solo falsy (`[0]` → `""`). |
| CA-03 | **Pasa** | `tituloInforme(9, 2026)` → `"informe de septiembre de 2026"` exacto. Recorrí los 12 meses (`mes` 1–12, año 2026): todas las salidas en minúsculas, empiezan por `"informe de "` y terminan en `" de 2026"`. Probé además los bordes del rango contratado: `tituloInforme(1, 0)` → `"informe de enero de 0"`, `tituloInforme(12, 9999)` → `"informe de diciembre de 9999"` (el año no está acotado por CA-03, así que no es hallazgo). |
| CA-04 | **Pasa** | `listaClientes([])` → `""`; `listaClientes(['', null, undefined])` → `""`. Sin separador suelto, sin relleno, sin `undefined` en el resultado. |
| CA-05 | **Pasa** | `listaClientes(['Ana'])` → `"Ana"`; `listaClientes([null, 'Ana', ''])` → `"Ana"` (un único elemento conservado, sin separador). |
| CA-06 | **Pasa** | `node --test` reporta `tests 8`, `pass 8`, `fail 0`. Cobertura: CA-01 (2 pruebas), CA-02 (2), CA-03 (2), CA-04 (1), CA-05 (1) — no menos de una por criterio 1–5, como exige el enunciado operativo. |

## 2. Quality gate y prueba de que las pruebas ejercen de verdad el fix

`node --test` desde la raíz del proyecto:

```
ℹ tests 8
ℹ pass 8
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
```

**Comprobación anti-vacuidad (lo que pide el punto 2 del encargo).** El día anterior esta
misma gate pasaba en verde con **0 pruebas**. Para descartar que las 8 pruebas nuevas sean
igual de vacías (que pasarían igual con el código roto), reconstruí temporalmente el
`src/formato.js` **anterior al arreglo del desarrollador** —`nombres.filter(Boolean).join(', ')`
y `'Informe de ' + MESES[mes-1] + ' de ' + anio` con `MESES` capitalizado, exactamente lo que
describe la evidencia de DEF-001 y DEF-002 en la cabecera del REQ— y corrí `node --test` contra
él:

```
ℹ tests 8
ℹ pass 3
ℹ fail 5
✖ CA-01 — dos o más nombres se unen con "; "...
✖ CA-02 — se omite todo elemento que el predicado trata como «no aporta nombre» (falsy)
✖ CA-02 — un nombre conservado se copia tal cual, sin recorte de espacios
✖ CA-03 — el título va íntegro en minúsculas...
✖ CA-03 — ningún ordinal de 1 a 12 produce una letra mayúscula
```

5 de 8 pruebas fallan contra el código con los defectos originales, y las 8 pasan contra el
código corregido. Las pruebas **sí distinguen** el comportamiento correcto del incorrecto —no
son un placebo—. Restauré `src/formato.js` a la versión del desarrollador inmediatamente
después (verificado con `diff`, idéntico byte a byte) y **no hice commit** de ese experimento;
la comparación completa vive sólo en este log.

## 3. Falsación dentro del alcance contratado (más allá del camino feliz)

- Entrada vacía (`[]`) y de un solo elemento — CA-04/CA-05, cubiertos arriba.
- Combinaciones de *falsy* intercaladas en distintas posiciones (inicio, medio, fin, solo) —
  orden y omisión correctos en todos los casos probados.
- Valores límite del rango contratado de `mes` (1 y 12) cruzados con años límite (0 y 9999) —
  sin desbordes ni `undefined` incrustado dentro del rango contratado.
- Repetición de la misma llamada (idempotencia): `listaClientes(['Ana','Beto'])` da el mismo
  resultado en dos invocaciones sucesivas — no hay estado oculto ni mutación del arreglo de
  entrada que pudiera romper una segunda llamada con los mismos datos.
- No hay dependencias externas (red, filesystem, reloj) en `src/formato.js`: no aplican los
  caminos de error de timeout/5xx/conexión caída que pide la postura general.

**No probé, y no es hallazgo, por estar explícitamente fuera de alcance de REQ-004** (Notas /
alcance, puntos 1–3): `listaClientes(null)` (falla porque no es arreglo), `tituloInforme(13, …)`
o `tituloInforme(0, …)` (producen `"informe de undefined de …"`), y el recorte de espacios.
Los tres están registrados con dueño (`analista-requerimientos`, REQ nuevo recomendado) en el
propio REQ-004; confirmo que la nota describe correctamente el comportamiento actual del
código (los reproduje para verificar la descripción, no como prueba de aceptación):

```
listaClientes(null)           → TypeError: nombres.filter is not a function
tituloInforme(13, 2026)       → "informe de undefined de 2026"
tituloInforme(0, 2026)        → "informe de undefined de 2026"
listaClientes(['  Ana  '])    → "  Ana  " (sin recortar, tal como CA-02 lo contrata)
```

## 4. Integridad de dependencias

No aplica: el proyecto no tiene `package.json` ni lockfile (biblioteca de módulos CommonJS sin
dependencias externas, confirmado en `ARCHITECTURE.md`).

## 5. Documentación técnica (desarrollador)

`ARCHITECTURE.md` quedó completo: visión general, tabla de componentes con los tres módulos de
`src/`, flujo de datos, integraciones externas (ninguna) y enlace a `ADR-001`. Consistente con
el árbol verificado.

## 6. Seguridad

`Sensible a seguridad: sí` y `Rigor: critico` (ADR-001) → el REQ **no puede cerrar**
(`Estado: completado`) sin `Seguridad: aprobado`. Yo no firmo ese campo. Verifiqué el orden de
fases: este REQ no tiene `Seguridad: preventiva` previa, así que la firma del auditor debe
llegar **después** de este veredicto (`AGENTS.md` §6) y sobre el árbol que acabo de validar
(incluyendo `test/formato.test.js` y este log, que quedan comiteables junto con la validación).

## Veredicto

**`QA: aprobado (2026-09-21)`.** `Hallazgos abiertos:` retirado a `ninguno` — DEF-001 y DEF-002
verificados como resueltos (evidencia arriba) y sin hallazgos nuevos dentro del alcance
contratado. Pendiente: visto bueno del `auditor-seguridad` para que el REQ pueda pasar a
`completado` (rigor `critico`, `Sensible a seguridad: sí`).
