# ADR-002 — La guarda estática del banco declara su alcance real: barandilla, no jaula
Fecha: 2026-09-06
Estado: aceptada

## Contexto

REQ-014 partió el banco en 37 archivos de sección. La partición introduce un modo de fallo que el
monolito no tenía: una sección puede definir **su propio juez** —ejecutar un hook y dictar `PASS`/`FAIL`
sobre su salida— sin pasar por el ayudante compartido que exige que un JSON vacío sea `FAIL`. Un caso
así **pasa en verde sin haber medido nada**, que es el defecto más caro que este repositorio ha
encontrado: cuatro veces en tres ciclos.

Para cerrarlo, el corredor ganó una **guarda estática** en `awk`: antes de ejecutar nada, lee el texto
de cada archivo y aborta si alguna función ejecuta un hook y dicta veredicto sin guarda.

**Lo que la medición demostró, en dos vueltas de QA:**

1. La primera versión juzgaba cuerpos sueltos, y se evadía partiendo ejecución y veredicto en **dos**
   funciones. Se arregló: el `awk` pasó a resolver el cierre transitivo sobre la cadena de llamadas, con
   control positivo para no prohibir partir funciones (que no es la regla).
2. La segunda versión **sigue evadiéndose con tres eslabones**, porque la propiedad no se propaga más
   allá de un salto. Y se evade también **sin ninguna astucia**: un espacio antes del paréntesis en la
   definición —`mi_check ()  {`— deja la función entera invisible al reconocedor, que es
   `/^[A-Za-z_][A-Za-z_0-9]*\(\)[ \t]*\{/`.

El criterio CA-06 de REQ-014 prometía, en su letra, cazar la clase entera.

## Decisión

**El criterio se estrecha para describir lo que la máquina cumple, y el hueco se declara como residual
con dueño y vencimiento.** CA-06 pasa a prometer una guarda **estática y textual** que protege del
descuido y de la evasión ingenua, **no** de la ofuscación deliberada, y enumera las siete formas
medidas que no promete cazar. El residual queda escrito en REQ-014 con forzador medido (las dos
evasiones reproducidas por QA), **dueño REQ-011** —la puerta posterior— y **vencimiento al cierre de
1.33.0**.

Es un cambio **de fondo** —estrecha lo que promete un control en un REQ `critico` y sensible a
seguridad— y por eso existe este ADR: `AGENTS.md` §9 no admite que una promesa se recorte con una
línea de historial.

## Alternativas consideradas

- **A — Ensanchar el reconocedor hasta cubrir las dos evasiones nuevas.** Por qué no: compraría **dos
  formas** al precio de fingir que se compró **la clase**. Una variable con el nombre del hook, `eval`,
  una función anidada o una llamada indirecta por `$funcion` la reproducen, y ninguna de ellas es más
  exótica que las dos que ya se colaron. Es literalmente la misma pregunta que `AGENTS.md` §13 declara
  **no ganada** para el detector de escrituras por `Bash`, con el mismo argumento y la misma respuesta
  de fondo. Perseguirla produce además falsos positivos —la versión anterior ya abortaba sobre código
  correcto sólo por llamar `o` a una variable en vez de `out`— y un guardián que grita sobre código
  bueno acaba desactivado, que protege menos que uno parcial.
- **B — Dejar el criterio como estaba y el hallazgo abierto.** Por qué no: el criterio seguiría
  prometiendo más de lo que la máquina cumple, que es la deriva que §9 prohíbe, y con el agravante de
  que la promesa la **heredan** los proyectos. Un criterio que nadie puede satisfacer no acota nada:
  bloquea el cierre sin mejorar el control.
- **C — Bloquear REQ-014 y escalar.** Por qué no: el defecto no está en lo que REQ-014 construyó —la
  partición se verificó sin perder ni un caso ni un veredicto— sino en el alcance que su criterio
  prometió. Bloquear castigaría el trabajo correcto por un defecto de redacción, y la clase de fondo ya
  tiene ventana asignada.

## Consecuencias

- (+) La promesa vuelve a ser cierta: lo que CA-06 dice es lo que la máquina hace, verificable en las
  dos direcciones.
- (+) El hueco queda **nombrado y con dueño** en vez de olvidado. La respuesta de fondo —preguntar
  **después** si algo protegido cambió, en vez de **antes** si un comando lo iba a cambiar— ya está
  presupuestada como REQ-011 en 1.33.0.
- (+) Se evita gastar la última vuelta del bucle en la pregunta que este repositorio ya declaró no
  ganada una vez.
- (−) Durante la ventana 1.33.0, una sección del banco escrita con ofuscación deliberada puede pasar en
  verde sin medir. **Mitigación:** el cuadre por archivo sigue delatando la pérdida de casos, la
  verificación por mutación sigue exigiendo que los 37 archivos reporten `FAIL` cuando se silencia el
  mecanismo, y el vencimiento es duro — si REQ-011 no cierra en 1.33.0, el residual se reabre.
- (−) Lo que queda de este hallazgo es un defecto **de un guardián del propio arnés**, que `AGENTS.md`
  §6 define como clase `instrumento` y no como `contrato`. **Esa reclasificación la decide el
  `qa-tester`, no esta decisión**, y sin ella la puerta de cierre seguirá denegando `completado` con el
  write-back ya hecho.
