# Banco completo en CI — PR #50, `hooks-en-linux`, cabeza `a82db68` (contenido `6212e87`)

Run 34923365661 · terminado 2026-09-15T03:04:09Z · **failure**. Recuento del log: **PASS 1275 · FAIL 1 · SKIP 15 · suma 1291** = lo que declara el corredor. **Cuadre 1290 → 1291**: el caso discriminante permanente de `CA-06` entró y se ejecutó.

## Identificadores esperados (disciplina `I-6`) — presentes
```
  PASS  REQ-024 CA-06 las 2 promesas de equivalencia del apartado llevan el ACTO dentro de la promesa (2 con acto, 0 de sujeto abierto; oraciones con verbo de la familia Y término heredado, conjunto ABIERTO)
  PASS  REQ-024 CA-06 discriminante: el reconocedor sigue mordiendo lo que debe y suelta lo que no  (inyectada SIN acto -> 1 sin acto, muerde; la MISMA CON acto -> 0 sin acto y 3 con acto, pasa; la frase que protege el texto personalizado, sola -> «0 0», ni 
```
El FAIL anterior (`se queda como está`) **no aparece**: 0 ocurrencias. `REQ-024 CA-06` imprimió 24 casos, todos PASS.

## FALLIDAS (1) — distinta de la anterior, y NO atribuible al delta
```
  FAIL  REQ-017 CA-09 la pared de los 60 s de este árbol NO es menor que la de v1.32.1, pareado en la misma corrida  el MEJOR de este árbol vale 0.976× el PEOR de v1.32.1: la pared BAJÓ en todos los emparejamientos, que es lo contrario de lo único que CA-09 contrata
```
- `REQ-017 CA-09` es una **sonda de coste** que empareja, en la misma corrida, la «pared de los 60 s» de este árbol contra la de `v1.32.1`. En la corrida anterior (`2b56cb4`) fue **SKIP** por solapamiento de rangos (0,929×–1,191×); en ésta el mejor de este árbol quedó en **0,976×** del peor de `v1.32.1` en todos los emparejamientos, y el caso lo declara FAIL.
- **El delta no toca `hooks/` ni `tools/`** (0 rutas de mecanismo en `f387b1c..a82db68`): nada del candidato cambia el tiempo de pared de los hooks. La medición depende del runner y de su ruido; la propia familia `REQ-017` ya mostró variabilidad entre corridas (`CA-03` osciló FAIL/SKIP en corridas locales anteriores, registrado en `variabilidad-no-desmiente-un-fail`).
- **Se conserva como FAIL y no se relanza para buscar verde.** Su clase y la decisión sobre la puerta son del propietario; aquí sólo se atribuye: **preexistente al candidato en su causa (sonda de coste sobre runner compartido), no introducido por el delta.**

## OMITIDAS (15) — una menos que antes
  1. ruta estilo Windows con backslashes -> deny  (sin cygpath: caso solo de Windows)
  2. REQ-017 CA-10 (i) fuera del dominio este árbol decide siempre lo mismo, y lo mismo en los dos locales  36 entradas NO son clasificables: la heredada 
  3. REQ-017 CA-10 (ii) ...y esa decisión es la del ORÁCULO: la heredada bajo LC_ALL=C  36 entradas NO son clasificables: la heredada tampoco publica una
  4. REQ-017 CA-10 (iii) fail-before: la heredada bajo el locale del entorno NO cumple (i) o (ii), y se registra sin fallar por ello  36 entradas NO son cl
  5. REQ-017 CA-03 el escáner no crece más que linealmente: doblar la línea no cuadruplica  el techo 2.600× cae DENTRO de la banda: el veredicto depend
  6. REQ-017 CA-03 fail-before: la sonda distingue el árbol cuadrático  el techo 2.600× cae DENTRO de la banda: el veredicto dependería del ruido de es
  7. REQ-017 CA-05 (i) la ruta crítica cuesta no más de 0,250× lo de v1.32.1  no se pide: evidencia acreditada en el Historial de REQ-017 (0,125× — 9
  8. REQ-017 CA-05 (ii) la comparación no se compra dejando de probar  no se pide: evidencia acreditada en el Historial de REQ-017 (0,125× — 9,60 s fre
  9. REQ-017 CA-08 (ii) un REQ real de 6 líneas: el reloj no sube más de 1,25× el de v1.32.1  repetición 1 de 4: la sonda NO convergió: segundo mínim
 10. REQ-017 CA-08 (ii) una cabecera de 200 líneas: el reloj no sube más de 1,25× el de v1.32.1  el techo cae DENTRO del recorrido observado [1.109×, 1
 11. REQ-021 CA-08 (iii) calibrar sonda-reloj.sh no cuesta más de 6× una medición suya con los MISMOS mandos  reloj 1.527× (3066486µs sobre 2007787µs
 12. REQ-023 CA-12 la cola cuenta exactamente lo mismo que la versión heredada  la PRECONDICIÓN DE ATRIBUIBILIDAD no se cumple: el cuerpo del lector DIFI
 13. REQ-023 CA-09 (iii) la guarda no empeora el orden de crecimiento de arnes_campo_linea: relación emparejada contra v1.33.0  no se puede AFIRMAR el tec
 14. 46/11 CA-14 (anti-vacuidad) [AGENTS.md] toda sede DETECTADA queda interpretada, o IDENTIFICADA con su motivo y sin acreditar  2 de 4 sedes DETECTADAS 
 15. 46/11 CA-14 (anti-vacuidad) [templates/AGENTS.md.tpl] toda sede DETECTADA queda interpretada, o IDENTIFICADA con su motivo y sin acreditar  2 de 4 sed

Por causa: 6 abstenciones de coste (incl. `REQ-017 CA-08 (ii)` ×2) · 3 locale/clasificabilidad · 2 sedes mudas `46/11` · 2 acreditaciones previas · 1 atribuibilidad · 1 sólo-Windows. La diferencia con la corrida anterior es exactamente `CA-09`: pasó de SKIP a FAIL.

## ERRORES DE EJECUCIÓN (1) — el mismo, preexistente
```
723:mv: cannot stat '/tmp/tmp.kSmKZnN0EU/.arnes/c2': No such file or directory
```
Sección 33, fixture `python3 … || jq … > c2 && mv c2 …`; precedencia `(A || B) && C`. Sin efecto en veredictos. Fuera de alcance por instrucción del propietario.
