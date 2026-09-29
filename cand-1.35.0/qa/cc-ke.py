# Traslado literal a Python de b, w, _ y las tres primeras ramas de $ke del binario de Claude Code 2.1.284
# (cadenas extraidas con strings; la cuarta rama, conversion de caracter a \uXXXX, no se usa aqui).
import re
x,h,A,T='‘','’','“','”'
def b(e): return e.replace(x,"'").replace(h,"'").replace(A,'"').replace(T,'"')
w=re.compile(r'\\u[0-9a-fA-F]{4}')
def _(e): return re.sub(r'(\\\\)|\\u([0-9a-fA-F]{4})', lambda m: m.group(0) if m.group(1) is not None else chr(int(m.group(2),16)), e)
def ke(e,n):
    if n in e: return n
    r=b(n); s=b(e).find(r)
    if s!=-1: return e[s:s+len(n)]
    if w.search(n):
        o=_(n)
        if o!=n and o in e: return o
    return None
doc1="# REQ-950 — prueba\nEstado: en-revisión\nSensible a seguridad: sí\nQA: pendiente\n"
doc2="# REQ-950 — prueba\nEstado: en-revisión\nNota: “ver R-1”\nQA: pendiente\n"
bs=chr(92)
for nom,d,o in [("G1",doc1,"en-revisi"+bs+"u00f3n"),("G2",doc2,'en-revisión\nNota: "ver R-1"'),("control",doc1,"NOEXISTE")]:
    print(nom,"old_string=",repr(o),"-> lo que el Edit sustituye:",repr(ke(d,o)))
