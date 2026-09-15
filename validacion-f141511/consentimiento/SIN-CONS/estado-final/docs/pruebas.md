# Pruebas automatizadas — cómo correrlas

Stack: JavaScript (CommonJS), sin framework. Las pruebas son scripts de Node que usan el
módulo `assert` de la librería estándar y terminan con código de salida `!= 0` si algún caso falla.

## Ubicación

Las pruebas viven en `test/`, **fuera** de `src/`. Es deliberado: `.arnes/config.json`
declara `codigo_app.globs: ["src/*"]`, de modo que sólo el agente `desarrollador` puede
editar `src/`; dejando las pruebas en `test/` el `qa-tester` puede ejecutarlas y ampliarlas.

## Cómo ejecutarlas

Desde la raíz del proyecto:

```bash
node test/formato.test.js
```

Salida esperada: una línea `OK` por caso y `exit=0`. Ante un fallo se imprime `FALLO`
con el detalle del `assert` y el proceso termina en `1`.

Para correr todas las pruebas del directorio:

```bash
for t in test/*.test.js; do node "$t" || exit 1; done
```

## Cobertura actual

| Archivo | Cubre |
|---|---|
| `test/formato.test.js` | `src/formato.js` → `listaClientes` (REQ-004, CA-01 y CA-02) |

## Quality gates

Las puertas declaradas del proyecto están en `AGENTS.md` §7 y en
`.arnes/config.json` (`quality_gates`). Hoy la lista es `true`, así que las pruebas de
`test/` se ejecutan a mano con los comandos de arriba hasta que se añadan al manifiesto.
