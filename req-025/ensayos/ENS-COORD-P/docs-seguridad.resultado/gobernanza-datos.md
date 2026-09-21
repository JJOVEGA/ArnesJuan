# Gobernanza de datos — Facturador

> Política de gobernanza del proyecto: qué datos maneja, dónde se publican, con qué límites y
> quién decide. La mantiene el `auditor-seguridad`. Se actualiza **cuando cambia el alcance o
> los datos manejados**, no por calendario.
>
> **Regla de honestidad de este documento:** aquí sólo se escriben controles que el proyecto
> **tiene**. Lo que falta se escribe como falta, con su hallazgo. Un documento de gobernanza que
> describe controles imaginarios es peor que no tenerlo, porque se confía en él.
>
> Versión inicial: 2026-09-21, tras la auditoría de `REQ-004`
> (`docs/seguridad/registro-seguridad.md`).

---

## 1. Qué datos maneja hoy el proyecto

| Dato | Clasificación | Dónde vive | Dónde se publica |
|---|---|---|---|
| **Nombre de cliente** | **Dato personal** cuando el cliente es una persona física; dato comercial identificativo cuando es una empresa. En ambos casos, combinado con el informe, revela una **relación comercial** | Sólo en memoria, como argumento de `listaClientes(nombres)` en `src/formato.js`. El proyecto no tiene persistencia | Encabezado del **informe mensual**, en la línea de clientes (`REQ-004`) |
| **Importe facturado / comisión** | Dato económico del cliente | En memoria, en `src/tarifa.js` (`comision`) | Encabezado del informe mensual, **cuando se construya `REQ-005`** (hoy `pendiente`) |
| **Fecha de corte** | Dato operativo; determina qué se factura | En memoria, `src/fecha.js` | Informe / factura |

**Nada más.** No hay usuarios, cuentas, credenciales, identificadores fiscales, direcciones,
datos de pago ni datos de categoría especial en el código de este proyecto a fecha de hoy.

## 2. Cómo circula el dato (modelo real, no el deseado)

`ARCHITECTURE.md` describe el sistema tal como está: módulos CommonJS de JavaScript bajo
`src/`, **funciones puras**, sin framework, sin dependencias externas, **sin red, sin servidor y
sin capa de persistencia**. Los datos **entran como argumentos y salen como valores de
retorno**.

Consecuencia directa para la gobernanza: hoy la exposición de datos de cliente **no es un
problema de infraestructura** (no hay superficie remota que atacar, ni credenciales, ni base de
datos). Es un problema de **contenido publicado**: lo que sale por `listaClientes` acaba en un
documento que lee una persona. Por eso los dos controles que faltan (§4) son de **contrato de
salida** y de **destinatario**, no de red ni de cifrado.

## 3. Quién puede ver qué

`AGENTS.md` §4 dice, literalmente, «sin usuarios externos»: **el sistema no tiene control de
acceso porque no tiene usuarios**. Quien ejecuta el facturador ve todo lo que el facturador
maneja.

**Pero el informe sí sale del sistema.** `PENDING_APPROVAL.md` `D1` contempla «publicar la
versión 1.0 del informe mensual **a los clientes**». En el momento en que un informe se entrega
a un cliente, el destinatario es un tercero respecto de los demás clientes que aparezcan en su
encabezado.

**Estado de esta regla: NO DECLARADA.** El proyecto no dice si un informe corresponde a un
cliente, a varios, o a un destinatario interno, ni qué nombres puede contener el encabezado que
recibe cada destinatario. Es el hallazgo **`SEC-002`** (`usuario/dinero`, abierto) y la decisión
está escalada al propietario como **`D6`** en `PENDING_APPROVAL.md`. **Mientras no se declare,
la publicación del informe a clientes está vetada** por la auditoría del 2026-09-21.

## 4. Límites que el proyecto tiene, y los que le faltan

**Los que tiene (verificados el 2026-09-21):**

- Los nombres de cliente **no se persisten, no se registran en logs y no salen por red** desde
  este código: no hay logs, no hay red y no hay almacenamiento.
- No hay secretos, credenciales ni claves en el repositorio, ni en el cliente, ni en variables
  de entorno usadas por este código. No hay dependencias de terceros (no existe
  `package.json` ni `node_modules`), así que hoy no hay superficie de cadena de suministro.
- La línea de clientes **conserva el orden de entrada y no deduplica** (`REQ-004`, alcance
  declarado): el informe no inventa ni reordena la relación de clientes.
- Los nombres **vacíos o nulos no se publican** (`CA-02`), sin dejar hueco ni separador suelto.

**Los que le faltan (con su hallazgo, abiertos):**

| Falta | Hallazgo | Dueño |
|---|---|---|
| Regla de **codificación / validación de la salida**: hoy un nombre que contenga el separador o un salto de línea altera la estructura de la línea publicada y **falsea a qué clientes corresponde el informe** | `SEC-001` (`usuario/dinero`) | `analista-requerimientos` → `desarrollador` |
| Declaración del **destinatario** del informe y de **qué nombres puede ver cada destinatario** | `SEC-002` (`usuario/dinero`) | propietario (`D6`) → `analista-requerimientos` |
| **Cualquier NFR**: el proyecto no tiene ninguno declarado (`requirements/README.md`) | `O-02` del registro | `analista-requerimientos` |

## 5. Retención y borrado

**No aplica hoy, y conviene que quede escrito por qué:** este código no almacena nada. La
retención del **informe generado** —cuánto tiempo se conserva, dónde y quién lo puede releer—
queda **fuera del sistema** y **no está declarada por el proyecto**. Si en el futuro el informe
se archiva, se envía por correo o se sube a algún sitio, esa decisión entra en esta política y
exige NFR propio: sería el momento en que aparecen retención, acceso y borrado de verdad.

## 6. Cumplimiento

El proyecto **no declara** ningún marco de cumplimiento aplicable (protección de datos,
conservación contable, facturación electrónica). No se afirma aquí que cumpla ninguno. La
decisión `D6` es el punto donde el propietario puede declarar si la entrega de informes a
clientes está sujeta a alguno; si lo está, la regla de `SEC-002` deja de ser una preferencia de
diseño y pasa a ser una obligación externa.

## 7. Cuándo se revisa este documento

- Cuando el proyecto empiece a **persistir, transmitir o archivar** cualquiera de los datos de
  §1 (deja de ser un conjunto de funciones puras).
- Cuando se añada un dato nuevo de cliente al informe — en particular **`REQ-005`**, que mete un
  **importe** en el mismo encabezado.
- Cuando se resuelva `D6` (destinatario del informe).
- En cada auditoría de un REQ `Sensible a seguridad: sí`.

## Historial

| Fecha | Cambio | Causa |
|---|---|---|
| 2026-09-21 | Creación | Auditoría de `REQ-004` (`Rigor: critico`); el proyecto no tenía política de datos escrita |
