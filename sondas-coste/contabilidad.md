# Procedencia de las lecturas (todas de CI ya guardado; ninguna nueva)
| Corrida | Cabeza | CA-03 directa | CA-03 fail-before | CA-08 (ii) 6 líneas | CA-08 (ii) 200 líneas | Fuente |
|---|---|---:|---:|---|---|---|
| PR #51 a8cbb29 | 1,33.2 porte | 2,229 | 2,669 | 0,958 | SKIP (1,000/1,780) | `porte-1.33.2/ci-pr51-a8cbb29/` |
| PR #51 b520e3b | | 1,924 | 4,082 | **1,258 F** | 1,027 | `porte-1.33.2/ci-pr51-b520e3b/` |
| PR #51 ca5ac4a | | 1,947 | 4,427 | SKIP | SKIP | `porte-1.33.2/ci-pr51-ca5ac4a/` |
| PR #52 9f908d9 | | 1,490 | 4,312 | 0,940 | SKIP | `req-025/ci-pr52-9f908d9/` |
| PR #52 6640e5a | | 2,110 | 2,777 | 1,059 | 1,047 | `req-025/ci-pr52-6640e5a/` |
| PR #52 a1e4f72 | | 2,347 | 2,707 | 1,088 | 1,106 | `req-025/ci-pr52-a1e4f72/` |
| PR #52 a3489a8 i1 | | 1,799 | 4,482 | **1,273 F** | SKIP | `req-025/ci-pr52-a3489a8/` |
| PR #52 a3489a8 i2 | | 1,654 | 5,352 | SKIP | SKIP | `req-025/ci-pr52-a3489a8-intento2/` |
| main cfb1106 | | **2,747 F** | 4,627 | 0,910 | **1,255 F** | `req-025/ci-main-cfb1106/` |
| PR #53 d413405 | | 1,820 | **2,443 F** | 1,195 | SKIP | `fidelidad-encargo/ci-d413405/` |
| PR #53 f7a6fdf | | 1,753 | 4,961 | SKIP | **1,339 F** | `fidelidad-encargo/ci-f7a6fdf/` |
Más las cuatro de cand/1.33.0 registradas en `docs/PENDIENTES.md` (200 líneas: 0,973 · 1,131 · 1,337 F · 1,364 F). Método: `grep` de las líneas `REQ-017 CA-03` y `REQ-017 CA-08 (ii)` en cada `log-completo.txt` / `hooks-en-linux-log.txt`.
Mecanismo idéntico por hash en todas (`hooks=a6810ac6`, `tools=87edb9b4`, `tests=b4cbb114`) desde `v1.34.0`.
