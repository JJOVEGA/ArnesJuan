# La decisión del propietario sobre `1,28×`: el techo se queda, y lo exigido pasa de **detectar** a **bloquear**

**Fecha:** 2026-09-11. **Quien decide:** el propietario (Juan). **Sobre:** `REQ-024 CA-07 (ii)`,
tras la vuelta 4 y con la evidencia del runner sobre `f2b74d9`.

## Lo decidido, textual

> Mantengo el techo de **`1,250×`** y acepto que una regresión conocida de **`1,28×`** bloquee por
> «no se pudo acreditar», aunque el instrumento no pueda clasificarla con certeza como regresión.
> Esto **modifica expresamente** mi condición anterior de detectar `1,28×` como regresión. La
> condición ahora es: **no aprobarla ni permitir la integración**, sea por regresión demostrada o por
> incertidumbre. **No autorizo elevar el techo a `1,302×`** ni convertir esa cifra observada en un
> nuevo límite.

## Por qué importa la diferencia

La condición anterior —**detectar**— exigía que el instrumento **clasificara** `1,28×` como
regresión, y eso requiere resolver una diferencia de `30‰` contra un techo de `1,250×`. La fase 2
midió que no es alcanzable en este host: la **distribución nula subestima la dispersión real**
(recorrido real `1,066`–`1,13` contra nulas de `1,009`–`1,021`) y **subir `r` no la estrecha**.

La condición nueva —**bloquear**— es **más débil en lo epistémico y igual de fuerte en lo
operativo**: no pide saber *qué* pasa, pide que **no pase**. Un `FAIL` por regresión demostrada y un
`FAIL` por «no se pudo acreditar» la satisfacen **los dos**, con tal de que impidan integrar. Es la
forma correcta de tratar un instrumento cuyo límite está medido: no se le pide certeza que no tiene,
se le pide **fail-closed**.

## Lo que la decisión NO hace

- **No sube el techo.** Sigue en `1,250×`, y el propietario excluyó expresamente convertir el
  `1,302×` observado en un límite nuevo. Esa cifra es **incertidumbre del método**, no un umbral.
- **No acepta un residual.** Acepta una **imposibilidad medida** de clasificar, y la trata
  cerrando la puerta, que es lo contrario de dejarla pasar.
- **No cierra `QA-024-21`.** Cambia contra qué se juzga ese hallazgo, no su existencia.

## Lo que queda exigido, y es lo que QA debe acreditar

1. El caso conocido de `1,28×` **queda bloqueado**, conservando **todas** las corridas.
2. Agotados los intentos, **el proceso termina con fallo efectivo** y la puerta impide integrar —
   *«no basta con imprimir `FAIL` si el comando o workflow termina en éxito»*.
3. El candidato **sin** la regresión obtiene **acreditación válida bajo el techo**, no un verde
   basado en `SKIP`.
4. El contrato **describe fielmente** lo implementado y **distingue incumplimiento demostrado de
   imposibilidad de acreditar**, sin presentar las corridas como garantía universal ni como prueba
   de un valor verdadero exacto.

## Trazabilidad

Origen del problema: `QA-P48-01` → `v1.33.2` → el porte a `#48` → los tres `FAIL` de CI sobre
código idéntico → `docs/arnes/ci-1.34.0-no-discrimina/` → vuelta 4 (`03-`, `05-`) → esta decisión.
El write-back del criterio, ya hecho en `ab3e4cb`, **no afirma** la detección de `1,28×`: afirma que
no aprueba lo que no puede resolver. Esta decisión es la que hace que eso **baste**.
