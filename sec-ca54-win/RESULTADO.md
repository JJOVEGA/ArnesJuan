# QA-023-10 (REQ-007 CA-54) en Windows/MSYS: resultado (2026-10-02, tras el registro previo `5510675`)

Una ejecución completa, conservada en `salida-sonda.txt`. La cabecera confirma el entorno registrado: `bash` 5.3.15, `jq` 1.8.2 de Windows, `timeout` de MSYS y MINGW64_NT-10.0-26200 3.6.9. Caso máximo, 131 072 bytes. Tiempos en ms.

| Forma | `9596e39` (5 corridas) | Candidato `3bc7d3c` (5 corridas) |
|---|---|---|
| A (8258 destinos) | 60138–60237, **las 5 con rc 124** | 20396–21700, rc 0, allow |
| B (7341 destinos) | 60194–60205, **las 5 con rc 124** | 21348–28917, rc 0, allow |
| C (5506 destinos) | 60226–60264, **las 5 con rc 124** | 20976–27473, rc 0, allow |

## Lectura, la fijada antes de medir
1. **Latencia frente a CA-54:** el candidato supera los 5 000 ms en las 15 corridas (20,4–28,9 s). **CA-54 no se cumple en Windows/MSYS.**
2. **Terminar sin decisión:** el candidato no llegó al límite de 60 s en ninguna corrida. Su máximo fue 28,9 s, con un margen de unas 2,1 veces. `9596e39` lo alcanzó en las 15 corridas: el `timeout` lo cortó, y un hook cortado así termina sin decisión (la clase de SEC-115). En estas condiciones, el candidato está más lejos del límite que la base.
3. **Condiciones comprobadas:** sólo esta máquina, esta compilación de Windows y estas versiones; el hook invocado directamente, no el cliente de Claude Code en Windows; archivos en NTFS; una ejecución. Esto **no** valida Windows ni excluye que otro equipo más lento, o con más carga, llegue al límite.
