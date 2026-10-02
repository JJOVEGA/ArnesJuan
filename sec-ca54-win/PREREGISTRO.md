# QA-023-10 (REQ-007 CA-54): comprobación acotada del caso máximo en Windows/MSYS. REGISTRO PREVIO, escrito y comiteado antes de ejecutar (2026-10-02)

**Motivo.** La séptima autorización, punto 4, dice: «Si Windows/MSYS está disponible, autorizo una comprobación acotada del caso máximo con procedimiento fijado antes de ejecutarla y todas las ejecuciones conservadas.» También dice: «Una medición inferior a 60 segundos no satisface por sí sola CA-54.» Es una medición para preparar la decisión 9b. No acepta nada ni cambia el contrato. La ejecuta la coordinadora.

**Entorno.** Windows 10.0.26200 (el anfitrión de esta WSL2). PortableGit del perfil del usuario: `bash` 5.3.15 (x86_64-pc-cygwin), MSYS 3.6.9, `jq` 1.8.2 nativo de Windows y `timeout` de MSYS. Se invoca desde WSL por interoperabilidad, con `bash.exe -lc`, y no se instala nada. Los árboles y los proyectos efímeros viven en NTFS, en `C:\Users\JVega\AppData\Local\Temp\arnes-ca54-r7\`.

**Árboles,** materializados con `git archive` y verificados contra Git:
- **base:** `9596e39`, con `lib.sh` 067ed6edd983096b, `guard.sh` 2e7ec8cb189d025c, `guard-codigo.sh` 0700ce03a9e37f7c y `guard-completado.sh` a48716bedc919e48;
- **candidato:** `3bc7d3c`, el código de esta vuelta, con `lib.sh` 4a9b05fab6ab92a0, `guard.sh` 2e7ec8cb189d025c, `guard-codigo.sh` 94ad57ff577d2964 y `guard-completado.sh` 872916a33041f11d.

**Procedimiento.** `sonda-ca54-win.sh` es la sonda de QA (`cand-1.35.0/evidencia-qa-sec119/sonda-ca54-qa.sh`) con dos únicos cambios: las rutas de Windows y sólo el techo 131 072, el máximo admitido.
- Tres formas de destino: A = `echo x > f$i`, B = `echo x > d$i/f` y C = `echo x > docs/../f$i`.
- Una corrida de calentamiento descartada por árbol y forma, y cinco corridas alternadas base/candidato.
- Cada corrida lleva `timeout 60`, que emula el límite con el que el cliente mata un hook.
- Se registran los ms, la decisión, el código de salida y `/proc/loadavg`.

Una sola ejecución completa, en segundo plano y sin otra carga lanzada por la sesión. Se conserva tal cual salga y no se repite.

**Lectura, fijada antes de medir:**
1. **Latencia frente a CA-54:** el criterio de esta vuelta (las 15 corridas del candidato por debajo de 5 000 ms) se informa tal cual. No se rebaja, y aquí no se espera que se cumpla.
2. **Riesgo de terminar sin decisión:** se informa cuántas corridas acaban con rc 124 (muertas por el `timeout` de 60 s), que equivalen a un hook sin decisión. Se informan también el máximo y el margen hasta 60 s. Que no haya ninguna **no** acredita ausencia de riesgo fuera de estas condiciones.
3. **Condiciones comprobadas:** esta máquina, esta compilación de Windows y estas versiones de MSYS y `jq`, el hook invocado directamente, archivos en NTFS y una ejecución. **No** el cliente de Claude Code ejecutándose en Windows, **ni** otras máquinas, **ni** Windows en general. Nada de esto presenta Windows como validado.

**Fallo de instrumentación:** que `jq` o `timeout` no se resuelvan en el `PATH` de MSYS, o que un árbol no sea el verificado. Se ve en la cabecera de la salida.
