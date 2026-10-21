## [1.37.0] — (borrador)

### Rigor proporcional (REQ-034): el riesgo declarado

El flujo ligero ahorra QA y auditoría de seguridad a todo cambio que un proyecto, con sus cinco ámbitos declarados
(dinero, sesión, seguridad, datos y el propio arnés), no considere alcanzado por ninguno de ellos. **El ahorro del
`ligero` descansa en el juicio del analista al clasificar** (decisión del propietario, P-137-P, 2026-10-21; hallazgo
SEC-139 de R-061).

- **Qué puede pasar:** si el analista clasifica como normal un cambio que alcanza uno de los cinco ámbitos, el REQ
  **cierra sin ninguna revisión de QA ni de seguridad**. Las salvaguardas —el suelo de `Sensible a seguridad: sí`,
  «ante la duda, completo» y la facultad del auditor de subir el rigor— dependen de ese mismo juicio o de que alguien
  despache al auditor, y **ninguna puerta lo detecta**: `guard-completado` no lee la política.
- **Antes de 1.37.0** el mismo error tenía techo, porque `ligero` era sólo «sin lógica»; con REQ-034, sin la política
  declarada el proyecto sigue como hoy, y con ella declarada el riesgo es el de arriba.
- **Quién baja la política:** todo cambio que reduzca lo que alcanza un ámbito (quitar o estrechar un glob, declarar
  `"ninguno"`; ejemplos no exhaustivos) exige la firma del auditor. Es una norma para quien lee, sin comprobación
  mecánica, y en un proyecto con `.arnes/config.json` fuera de `codigo_app.globs` cualquier agente puede editar la
  política (SEC-138).
- **Comprobación futura (pieza b, no en esta versión):** ficha F-137-18 de `docs/PENDIENTES.md`: al cerrar un REQ
  `ligero`, si sus cambios tocan rutas de los cinco ámbitos declarados, el cierre exige `estandar`, y así la máquina
  comprueba el juicio del analista.
