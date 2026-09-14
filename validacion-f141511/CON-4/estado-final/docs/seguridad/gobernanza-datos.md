# Gobernanza de datos — Facturador

> Dueño: `auditor-seguridad`. Se actualiza cuando cambia el alcance o los datos manejados.
> Última revisión: **2026-09-14** (con motivo de la auditoría de REQ-004, `docs/seguridad/registro-seguridad.md` §R-004).

## 1. Alcance del sistema
Facturación mensual de clientes. Stack: JavaScript sin framework, ejecución **local**, sin
autenticación, sin hosting remoto y **sin usuarios externos** (AGENTS.md §2 y §4).
Principio rector: «cobrar lo decidido, ni más ni menos».

## 2. Clasificación de los datos manejados

| Dato | Clasificación | Dónde vive hoy | Notas |
|---|---|---|---|
| **Nombre de cliente** | **Dato personal** (identifica a una persona física cuando el cliente lo es) | Sólo en memoria del proceso, como argumento de `listaClientes` (`src/formato.js`) | No se almacena, no se transmite, no se registra en log. Aparece en el **encabezado del informe de facturación**, que es un documento con efecto económico |
| Importes, comisiones y fechas de corte | **Dinero** — crítico en este proyecto (AGENTS.md §6) | REQ-001, REQ-002 | Fuera del alcance auditado hoy; ver OBS-001 en el registro de seguridad |
| Credenciales / secretos | **No existen en este proyecto** | — | Si alguna vez existieran: sólo en variables de entorno del lado servidor, nunca en código ni en cliente (AGENTS.md §10) |

## 3. Reglas vigentes
1. **Ningún dato personal en mensajes de error ni en logs.** Los errores de `listaClientes`
   identifican la entrada por **posición**, nunca por contenido. Es un control **aprobado** y
   su pérdida en una iteración futura es hallazgo de regresión.
2. **Integridad de la representación.** Un dato de cliente que llega a un documento de
   facturación no puede alterar la **estructura** de ese documento (separadores, líneas,
   fórmulas). Regla abierta hoy: SEC-001 y SEC-002.
3. **Fallo ruidoso sobre degradación silenciosa.** Ante entrada malformada se lanza error
   diagnosticable; nunca un documento plausible que oculte datos perdidos (ADR-003 §2).
4. **Retención:** el sistema no persiste datos personales por sí mismo. Si un REQ futuro los
   persista o los exporte, exige NFR de retención, cifrado en reposo y audit log **antes** de
   implementarse, y `Sensible a seguridad: sí`.
5. **Sin terceros.** No se envían datos de cliente a ningún servicio externo.

## 4. Condiciones que obligan a revisar este documento
- `listaClientes` (o cualquier módulo) pasa a recibir entrada de **origen externo**.
- La salida se **persiste**, se exporta (CSV/XLSX/PDF) o se transmite fuera del proceso.
- Aparece autenticación, multi-usuario o hosting remoto.
Cualquiera de las tres reclasifica los REQ afectados a `Sensible a seguridad: sí` y reabre
SEC-003.
