#!/usr/bin/env python3
"""Campos que QA r7 escribe en las cabeceras: el texto exacto (viejo -> nuevo) por REQ.
Uso: campos-nuevos.py <dir de requirements origen> <dir destino> -> escribe las copias con los campos nuevos
y, en <destino>/../ediciones/, un JSON por edición {file, old, new} para probarlas con la puerta real."""
import json, os, sys, re

src, dst = sys.argv[1], sys.argv[2]
os.makedirs(dst, exist_ok=True)
ed_dir = os.path.join(os.path.dirname(dst.rstrip('/')), 'ediciones'); os.makedirs(ed_dir, exist_ok=True)

Q14 = ("QA-023-14 (instrumento, introducido por 3bc7d3c: _arnes_repone_cr recorre el file_path y el tool_name "
       "con una sustitucion de bash que crece mas que linealmente, antes de cualquier techo de tamaño; medido a nivel "
       "de hook, un Bash de la coordinadora con echo x > src/a.ts y un tool_input.file_path de 500000 bytes con CR "
       "final tarda 63,3 s en el candidato frente a 5,0 a 5,3 s en cd6afa6, 9596e39 y 1.33.2, y un Write con un "
       "file_path de 600000 bytes, 89,3 s frente a 0,4 s; por encima de 60 s el hook muere sin decidir, clase de "
       "SEC-115; sin efecto medido: un file_path de mas de 4096 bytes no lo abre ninguna herramienta y no esta medido "
       "que el host entregue un file_path en un Bash; dueño desarrollador; vence con la decision de publicacion de "
       "1.35.0, ficha 1; docs/qa/REQ-023.md)")
Q15 = ("QA-023-15 (instrumento, preexistente en los cuatro arboles y es P-023-13-A: el texto del comando de Bash "
       "pierde en el transporte su CR final y el que precede a un salto, y un destino cuyo nombre acaba asi se juzga "
       "sin el; medido a nivel de hook, fuera de /tmp: printf x > k<CR> desde docs con docs/k<CR> enlazado a "
       "src/a.ts, y un sed -i que cierra un REQ en rojo por el enlace docs/r<CR>, salen allow en el candidato, "
       "cd6afa6, 9596e39 y 1.33.2, y el shell escribe el destino protegido; exige crear antes un enlace con ese "
       "nombre, ofuscacion deliberada AGENTS.md §13; CA-47 punto 11 lo declara con verdad y no es movimiento; lo "
       "decide el propietario en P-023-13-A; dueño desarrollador si se repara y analista-requerimientos si se "
       "declara frontera; docs/qa/REQ-023.md)")

R007_QA_OLD = "VEREDICTO NO FAVORABLE, no se despacha seguridad; docs/qa/REQ-023.md)"
R007_QA_NEW = ("VEREDICTO NO FAVORABLE, no se despacha seguridad; 2026-10-02, vuelta excepcional de la séptima "
               "autorización, árbol fa070b7 (código de 3bc7d3c): QA-023-13 cerrado —la reproducción original deniega "
               "con el motivo del cwd con retorno de carro en guard-codigo, guard-completado y guard.sh, donde cd6afa6 "
               "permitía, y la puerta ya no ancla en otro directorio—; CA-47 puntos 1, 7, 11, 12 y 13, notas de CA-24 "
               "y CA-60 y CA-66 versionado del 2026-10-02 verificados contra la conducta y rotos con casos propios a "
               "nivel de hook; sección 44 con 247 casos, y con los hooks de cd6afa6 24 FAIL, todos del bloque R; "
               "secciones 08 y 41 a 44 sin regresión; ningún deny a allow nuevo frente a 9596e39 salvo instancias de "
               "L8; el caso del retorno de carro no se ejerció en el host; banco completo 1569 PASS, 0 FAIL, 12 SKIP "
               "con 1 INCONCLUSO de rendimiento, cuadre 1581; autoprueba 117/0; gates rc 0; QA-023-10 sigue abierto; "
               "NUEVOS QA-023-14 y QA-023-15, instrumento; VEREDICTO FAVORABLE para la reparación; docs/qa/REQ-023.md)")
m = None
cambios = {
  'REQ-007.md': [
    (R007_QA_OLD, R007_QA_NEW),
    ('__QA02313_REQ007__', ', ' + Q14 + ', ' + Q15),
  ],
  'REQ-023.md': [
    ("; no cubre QA-023-13, nuevo, instrumento aquí y contrato en REQ-007; docs/qa/REQ-023.md)",
     "; 2026-10-02, séptima autorización, árbol fa070b7 (código de 3bc7d3c): se mantiene sobre el código final "
     "—198 casos de REQ-023 y las secciones 08, 41, 42 y 43 en verde, sin regresión frente a cd6afa6— y QA-023-13 "
     "queda CORREGIDO —el retorno de carro del cwd se cuenta antes del transporte y la ruta relativa es no "
     "determinable, con motivo—; banco completo 1569 PASS, 0 FAIL, 12 SKIP, cuadre 1581; no cubre QA-023-14 ni "
     "QA-023-15, instrumento y registrados en REQ-007, que no tocan CA-13; docs/qa/REQ-023.md)"),
    ('__QA02313_REQ023__', ''),
  ],
  'REQ-031.md': [
    ("; no cubre QA-023-13, registrado en REQ-023 y REQ-007; docs/qa/REQ-023.md)",
     "; 2026-10-02, séptima autorización, árbol fa070b7 (código de 3bc7d3c): se mantiene —los 63 casos de REQ-031 "
     "y la sección 08 en verde, sin regresión frente a cd6afa6—; QA-023-13 cerrado; QA-023-14, registrado en "
     "REQ-007, es una instancia nueva de la clase de SEC-115 introducida por 3bc7d3c; docs/qa/REQ-023.md)"),
  ],
  'REQ-001.md': [
    ("; no cubre QA-023-13, registrado en REQ-023 y REQ-007; docs/qa/REQ-023.md)",
     "; 2026-10-02, séptima autorización, árbol fa070b7 (código de 3bc7d3c): se mantiene —CA-10, CA-11 y CA-12 "
     "en verde y las secciones 41 y 42 sin cambio de decisión, sin regresión frente a cd6afa6—; QA-023-13 cerrado; "
     "docs/qa/REQ-023.md)"),
  ],
}
n_ed = 0
for f, reps in cambios.items():
    t = open(os.path.join(src, f), encoding='utf-8').read()
    for old, new in reps:
        if old == '__QA02313_REQ007__':
            mm = re.search(r', QA-023-13 \(contrato, dueño analista-requerimientos y/o desarrollador:[^)]*\)', t)
            assert mm, f; old = mm.group(0)
        elif old == '__QA02313_REQ023__':
            mm = re.search(r'QA-023-13 \(instrumento, media a nivel de hook:[^)]*\), ', t)
            assert mm, f; old = mm.group(0)
        assert t.count(old) == 1, (f, old[:60], t.count(old))
        # La edición se hace sobre la LÍNEA entera de la cabecera (old/new de la línea), como haría Edit.
        linea = next(l for l in t.split('\n') if old in l)
        linea_n = linea.replace(old, new)
        t = t.replace(old, new)
        n_ed += 1
        json.dump({'file': f, 'old': linea, 'new': linea_n}, open(os.path.join(ed_dir, f'{n_ed:02d}-{f}.json'), 'w', encoding='utf-8'), ensure_ascii=False)
    open(os.path.join(dst, f), 'w', encoding='utf-8').write(t)
print(f'{n_ed} ediciones; copias en {dst}; JSON en {ed_dir}')
