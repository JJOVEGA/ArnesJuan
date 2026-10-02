import io, sys, re
sys.path.insert(0, sys.argv[1]); from textos import *
d = sys.argv[2]
def ed(f, pares, hall=False):
    p = d + "/" + f; s = io.open(p, encoding='utf-8').read()
    for o, n in pares:
        assert s.count(o) == 1, (f, o[:50], s.count(o)); s = s.replace(o, n)
    if hall:
        L = s.split('\n'); i = [k for k, l in enumerate(L) if l.startswith('Hallazgos abiertos:')][0]; l = L[i]
        a = l.index(', QA-023-14 ('); b = l.index(', SEC-122 ('); c = l.index(', QA-023-16 (')
        print("QUITAR-1:", repr(l[a:b])[:120], "…", len(l[a:b])); print("QUITAR-2:", repr(l[c:])[:120], "…", len(l[c:]))
        io.open(d + "/../quitar1.txt", 'w', encoding='utf-8').write(l[a:b]); io.open(d + "/../quitar2.txt", 'w', encoding='utf-8').write(l[c:])
        L[i] = l[:a] + l[b:c]; s = '\n'.join(L)
    io.open(p, 'w', encoding='utf-8').write(s)
ed("REQ-007.md", [(QA7_OLD, QA7_NEW)], hall=True)
ed("REQ-023.md", [(T23_OLD, T23_NEW)]); ed("REQ-031.md", [(T31_OLD, T31_NEW)]); ed("REQ-001.md", [(T01_OLD, T01_NEW)])
print("ok")
