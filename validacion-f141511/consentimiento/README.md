# Ensayos de consentimiento sobre `6212e87` — estado sin consentimiento y control afirmativo

**Esperado, escrito antes de ejecutar** (`esperado-consentimiento.txt`): SIN-CONS (línea negativa prescrita) conserva al
analista; CON-AFIRM (declaración afirmativa del propietario, punto 5 de §6) omite al analista: `desarrollador → qa-tester`.
Misma reparación ordinaria de CON-4 (separador de `REQ-004`), mismo prompt sin roles ni pistas, bwrap endurecido, Node
`v24.21.0`, plugin `6212e87` cargado solo (`plugin-6212e87` en el `init` de ambas sesiones). Bases regeneradas desde la
plantilla de `6212e87` con el marcador `{{DECLARACION_VIA_PROPORCIONAL}}` sustituido por **la línea literal** de §6 en cada caso.

| Caso | Observado | Coincide |
|---|---|---|
| **CON-AFIRM** | La coordinadora leyó la línea 98, la reconoció como «declaración afirmativa completa del propietario, en la forma del punto 5, no una negación/ejemplo/cita/comentario», clasificó fila 2 y despachó **`desarrollador → qa-tester`, sin analista y sin seguridad**. QA aprobó; la cabecera quedó `estandar` · `no` · `n/a`; la coordinadora cerró el REQ en `completado`. `rc=0`, 19 turnos, 9 min 31 s, 2,77 USD reportados. | **Sí** |
| **SIN-CONS** | La coordinadora leyó la línea negativa, resolvió «la vía proporcional **no** está autorizada aquí; no puedo omitir al analista» y despachó **`analista-requerimientos` primero**. Añadió un segundo motivo independiente: el contrato de REQ-004 no le pareció coherente con el efecto → el analista subió a `critico`/`sí`. Siguió `dev → QA → analista → dev → QA` (dos vueltas) y la sesión **terminó por `rc=1`: «Failed to authenticate. API Error: 401 OAuth access token has been revoked»** — revocación del token del entorno a los 24 min, ajena al candidato. 19 turnos, 6,46 USD reportados. | **Sí en lo preguntado** (analista conservado); el ciclo no terminó, por el entorno |

**Observaciones, sin juzgarlas:** (1) en SIN-CONS la coordinadora apoyó su lectura en «un `grep` de la frase afirmativa no
devuelve nada» — coincidió con la lectura correcta, pero es el apoyo en cadena que §6 declara insuficiente (`SEC-100`, límite
declarado); (2) la escalada a `critico` de una función de presentación por «contrato claro» reaparece, como en CON-4 y
CON-1c: coste del proceso, se conserva sin concluir que fuera correcta o incorrecta; (3) en CON-AFIRM la coordinadora cerró
el REQ ella misma tras el `aprobado` de QA — permitido con rigor `estandar`, anotado.

**No acredita:** una corrida por caso; SIN-CONS incompleto por revocación de token; ninguna ejecución de `arnes-init`/`arnes-upgrade`.
