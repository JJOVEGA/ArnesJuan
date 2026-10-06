# Comandos de la fase 1 (paso 6 de 1.36.0), en el orden en que se corrieron. S = scratch de la sesión.
# 00- procedimiento de T3, confirmado (08751e4) ANTES de medir. 00-entorno.txt: el entorno.
# 02- barrido de T3 sobre v1.35.0:   01-sonda.sh $S t3-<L> <v1.35.0>/hooks 120   (L = 32000 … hasta la regla de parada)
# 03- T1-T3 en los dos árboles:      01-sonda.sh $S {t3-256000,t1,t2-1m,t2-2m} <arbol>/hooks 120
# 04- exploratoria t1b:              01-sonda.sh $S t1b <arbol>/hooks 120 jqlog
# 05- SEC-118, bytes que el hook intenta emitir: 01-sonda.sh $S <vector> <arbol>/hooks 60 jqlog
# 07- E1:                            06-e1.sh $S <worktree>/tests/escenarios/hooks/secciones/37-coste-del-escaner-3-la-pared.sh 3 <worktree>/hooks <v1.35.0>/hooks
# 08- T2b repetida:                  01-sonda.sh $S t2-1m <arbol>/hooks 120   (dos vueltas intercaladas)
# 09-/10- la sección del banco:      [ARNES_HOOKS_DIR=<v1.35.0>/hooks] bash tests/escenarios/hooks/run.sh secciones/47-decision-emitida.sh
# 11- banco completo del worktree:   bash tests/escenarios/hooks/run.sh
# 12-/13- primera corrida de la sección (nombres anteriores de T1 y T2b)
