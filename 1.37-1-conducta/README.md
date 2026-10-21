# Prueba de conducta de 1.37 · 1 (REQ-034): qué `Rigor:` escribe el analista con la política declarada

- **Fecha:** 2026-10-21. **Autorización:** P-137-R, punto 3, con la precisión del propietario: «La prueba de conducta usa la definición del analista del candidato, y el registro lo dice».
- **Definición usada:** `agents/analista-requerimientos.md` de `cand/1.37.0` en `f5f002d`, copiada aquí como `analista-candidato-f5f002d.md` (sha256 empieza por `46bf4e99dd1bf15d`). **No** es la del plugin instalado (1.36.2).
- **Modelo:** Sonnet, que es la regla de 1.37 para el analista.
- **Mecanismo, y su límite:** cada corrida es un agente general que lee esa definición entera y la sigue como su rol. Su prompt de sistema **no** es el del agente real del plugin.
- **Proyecto:** «tienda-demo», montado con las plantillas del candidato (`f5f002d`), con los cinco ámbitos declarados (`config-ambitos-declarados.json`): dinero `src/pagos/**`, sesión `src/auth/**`, seguridad `src/auth/permisos.ts`, datos `db/**`, y arnés la lista precargada. `AGENTS.md` no declara la vía proporcional.
- **Corridas:** cuatro, cada una en su propia copia del proyecto. Los encargos no dicen qué se mide.

| Corrida | Encargo | `Estado:` | `Rigor:` | `Sensible a seguridad:` | `QA:` / `Seguridad:` | Tokens |
|---|---|---|---|---|---|---|
| normal-1 | Filtro por color en `src/catalogo/filtro.ts` | pendiente | **ligero** | no | pendiente / n/a | 90 309 |
| normal-2 | (igual) | pendiente | **ligero** | no | pendiente / n/a | 88 347 |
| dinero-1 | 10 % de descuento en el total del carrito (`src/pagos/total.ts`) | borrador (6 preguntas) | **critico** | no | pendiente / pendiente | 89 793 |
| dinero-2 | (igual) | borrador (4 preguntas) | **critico** | no | pendiente / pendiente | 86 197 |

**Resultado:** 4 de 4 corridas clasificaron como pide la política: el cambio normal, `ligero`, sin QA ni seguridad; el cambio de dinero, `critico`, con seguridad. Ninguna escribió fuera de `requirements/`.

**Lo que esta prueba NO acredita:**
- **Tamaño de la muestra:** son dos corridas por caso.
- **Dificultad:** los casos son nítidos y caen claramente dentro o fuera de un ámbito; un caso ambiguo o en la frontera no se probó.
- **El agente real:** el agente del plugin no se probó, porque su definición instalada es la de 1.36.2.
- **El riesgo de fondo sigue:** SEC-139 (el ahorro descansa en el juicio del analista) sigue siendo un riesgo; F-137-18 es su comprobación.

**Coste:** 354 646 tokens en total, ≈ 88 k por corrida, frente a ≈ 60 k presupuestados para toda la prueba: casi seis veces más. Cada corrida escribió un REQ de 3,4–5,0 KB, y la mayor parte del coste es **leer las reglas**: la definición, `AGENTS.md`, que sale de la plantilla, y `requirements/README.md`. Es el coste de base de una comisión del analista, y un dato para el adelgazamiento de `AGENTS.md` (1.37 · 4).
