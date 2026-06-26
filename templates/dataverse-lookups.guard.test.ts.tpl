/**
 * Test guardián de lookups Dataverse — PLANTILLA del arnés (ArnesJuan).
 *
 * Por qué existe: los nombres de nav-property en `@odata.bind` son strings
 * literales que TypeScript NO valida. Un typo se manifiesta como
 * `0x80048d19 "Invalid property ... does not exist on type ..."` en runtime.
 * Este test cruza cada lookup que usa la app contra los esquemas generados
 * (`.power/schemas/dataverse/*.json`) y rompe el CI ante un typo.
 *
 * Cómo adaptarlo (cada proyecto):
 *   1. Copialo a la carpeta de tests del proyecto (p. ej. `src/.../__tests__/`).
 *   2. Ajustá {{SCHEMAS_GLOB}} a la ruta real de tus esquemas generados.
 *   3. Llená {{LOOKUPS_USADOS}} con los lookups que escribe tu seam de datos.
 *      Idealmente, exportá esa lista desde el seam (una sola fuente de verdad)
 *      en vez de duplicarla acá.
 *   4. Ajustá el runner: este esqueleto usa la API estilo Vitest/Jest
 *      (`describe/it/expect`). Cambialo si tu proyecto usa otro.
 *
 * Ver playbook: playbooks/power-apps-dataverse.md (regla 2).
 */
import { describe, it, expect } from '{{TEST_RUNNER}}'; // p. ej. 'vitest'
import { readFileSync } from 'node:fs';
import { globSync } from 'node:fs'; // o tu utilidad de glob

// 1) Lookups que la app realmente escribe, como [tabla, navProperty].
//    Mejor aún: importalos desde el seam de datos para no duplicar.
const LOOKUPS_USADOS: ReadonlyArray<readonly [table: string, navProperty: string]> = [
  // ['{{TABLA}}', '{{NAV_PROPERTY}}'],
  {{LOOKUPS_USADOS}}
];

// 2) Ruta a los esquemas generados por PAC.
const SCHEMAS_GLOB = '{{SCHEMAS_GLOB}}'; // p. ej. '.power/schemas/dataverse/*.json'

type DataverseSchema = {
  // Ajustá a la forma real de tus JSON generados.
  logicalName: string;
  attributes: Array<{ logicalName: string; type?: string }>;
};

function loadSchemas(): Map<string, DataverseSchema> {
  const byTable = new Map<string, DataverseSchema>();
  for (const file of globSync(SCHEMAS_GLOB)) {
    const schema = JSON.parse(readFileSync(file, 'utf8')) as DataverseSchema;
    byTable.set(schema.logicalName, schema);
  }
  return byTable;
}

describe('Dataverse lookups: cada @odata.bind apunta a un atributo real', () => {
  const schemas = loadSchemas();

  it('hay esquemas cargados (si esto falla, revisá SCHEMAS_GLOB)', () => {
    expect(schemas.size).toBeGreaterThan(0);
  });

  for (const [table, navProperty] of LOOKUPS_USADOS) {
    it(`${table}.${navProperty} existe en el esquema generado`, () => {
      const schema = schemas.get(table);
      expect(schema, `No hay esquema para la tabla '${table}'`).toBeDefined();
      const exists = schema!.attributes.some((a) => a.logicalName === navProperty);
      expect(
        exists,
        `Lookup '${navProperty}' no existe en '${table}'. ` +
          `Verificá el nombre lógico contra el modelo generado; el nombre es inmutable: ` +
          `se alinea el código, no la tabla.`,
      ).toBe(true);
    });
  }
});
