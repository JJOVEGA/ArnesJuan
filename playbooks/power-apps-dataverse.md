# Playbook: Power Apps Code App + Dataverse

> Convenciones de **persistencia** para proyectos que usan Power Apps Code Apps con
> Dataverse. Si tu `AGENTS.md` (§2 Stack → *Playbooks de plataforma aplicables*)
> declara este playbook, los agentes **desarrollador / qa-tester / auditor-seguridad
> DEBEN leerlo y verificarlo**. Cada regla nació de un error de runtime real.

## 1. No escribir `statecode` / `statuscode` en create/update
**Síntoma:** `0x80048408 "State code is invalid..."`.
Dataverse gestiona el estado aparte. Centralizá un `stripState()` en el **único
punto de escritura** del seam de datos; cambiá el estado sólo en una operación
dedicada (`setActive`) con el par explícito:
- activo → `statecode 0` / `statuscode 1`
- inactivo → `statecode 1` / `statuscode 2`

## 2. Nombres de lookup en `@odata.bind` = nombre lógico REAL
**Síntoma:** `0x80048d19 "Invalid property 'x' does not exist on type..."`.
Los binds se escriben como strings literales que **TypeScript NO valida**.
Verificá el nombre contra el modelo generado por PAC (`src/generated/models/`).
El nombre lógico es **inmutable**: si difiere, se alinea el código, no la tabla.
→ Agregá un **test guardián** que cruce cada `bindLookup('<nav>')` contra los
atributos de `.power/schemas/dataverse/*.json` (atrapa typos en CI).
El arnés trae un punto de partida en
`templates/dataverse-lookups.guard.test.ts.tpl`.

## 3. Fuente NATIVA, no conector
`pac code add-data-source -a dataverse -t <tabla>` (queda en `databaseReferences`).
**NO** uses `-a shared_commondataserviceforapps`: el conector exige que el host
inyecte la org URL y en modo local llega `null` → `"Invalid organization URL null"`.

## 4. Identidad en 2 pasos
Dataverse no filtra por nav-property. Resolvé:
1. `systemusers` por `azureactivedirectoryobjectid` (objectId de Entra del host).
2. La entidad de usuario de la app por el `_..._value`.

Siempre **validá el id** (anti-inyección OData) antes de interpolarlo en `$filter`.

## Checklist para tabla/columna nueva
- [ ] Fuente nativa (`-a dataverse`).
- [ ] Nombres de columna/lookup verificados contra el modelo generado.
- [ ] No escribir `statecode`/`statuscode` salvo en `setActive`.
- [ ] Test guardián de lookups en verde.
