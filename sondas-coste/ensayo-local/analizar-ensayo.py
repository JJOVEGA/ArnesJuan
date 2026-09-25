#!/usr/bin/env python3
# Analiza las corridas del ensayo: veredicto propuesto por caso, veredicto VIGENTE derivado de la repetición #1,
# abstenciones, controles y duración. No descarta ninguna lectura.
import re,glob,os,sys
O=sys.argv[1]; T=1250; T3=2600
def vig08(reg):  # 'ue:ue2:uh:uh2' → veredicto del procedimiento vigente (main) sobre UN par
    p=reg.strip().split(':')
    if len(p)!=4 or any(x=='x' or not x.isdigit() for x in p): return 'SKIP(no-midió)'
    ue,ue2,uh,uh2=map(int,p)
    if ue<50000 or uh<50000: return 'SKIP(suelo)'
    if ue2*1000//ue>T or uh2*1000//uh>T: return 'SKIP(no-converge)'
    r=ue*1000//uh; return ('PASS' if r<=T else 'FAIL')+f'({r/1000:.3f})'
rows=[]; ctl={}; dur=[]
for f in sorted(glob.glob(f"{O}/corrida-*.txt")):
    n=os.path.basename(f)[8:10]; txt=open(f,encoding='utf-8',errors='replace').read()
    meta=open(f.replace('.txt','.meta')).read(); m=re.search(r'segundos=([\d.]+)',meta); dur.append((n,float(m.group(1)) if m else None))
    res={}
    for line in txt.splitlines():
        s=line.strip()
        mm=re.match(r'^(PASS|FAIL|SKIP)\s+(REQ-017 CA-03 el esc|REQ-017 CA-08 \(ii\) (?:un REQ real|una cabecera)|ENSAYO control (?:I|W0|WD) \((?:un REQ real|una cabecera))',s)
        if mm:
            key=mm.group(2).replace('REQ-017 ','').replace(' el esc','').replace(' (ii)','')
            key=key.replace('un REQ real','6l').replace('una cabecera','200l').replace('ENSAYO control ','ctl ').replace(' (','-').replace('(','')
            v=mm.group(1)+('[INC]' if '[INCONCLUSO]' in s else '')
            res[key]=(v,s)
    # vigente derivado
    d08={}
    for mm in re.finditer(r'ENSAYO dato CA-08 (REQ-\d+) rep=1 reg=\[([^\]]*)\]',txt): d08[mm.group(1)]=vig08(mm.group(2))
    m3=re.search(r'ENSAYO dato CA-03 este=\[([^\]]*)\] her=\[([^\]]*)\]',txt)
    vig3='?'
    if m3:
        e=m3.group(1).split(); h=m3.group(2).split()
        e1=e[0] if e else 'x'
        vig3=('SKIP(no-midió)' if e1=='x' else ('PASS' if int(e1)<=T3 else 'FAIL')+f'({int(e1)/1000:.3f})')
        vig3+=' | her#1='+(h[0] if h else 'x')
    for mm in re.finditer(r'ENSAYO dato (REQ-\d+) (I|W0|WD) rep=1 us=\d+ reg=\[([^\]]*)\]',txt): ctl[(n,mm.group(1),mm.group(2))]=vig08(mm.group(3))
    rows.append((n,res,d08,vig3))
print("corrida | dur(s) | CA-03 prop | CA-03 vig(#1) | CA-08 6l prop | vig | CA-08 200l prop | vig | I-6l | W0-6l | WD-6l | I-200l | W0-200l | WD-200l")
for (n,res,d08,vig3),(_,d) in zip(rows,dur):
    g=lambda k: res.get(k,('—',''))[0]
    print(f"{n} | {d:.0f} | {g('CA-03')} | {vig3} | {g('CA-08 6l')} | {d08.get('REQ-100','?')} | {g('CA-08 200l')} | {d08.get('REQ-200','?')} | {g('ctl I-6l')} | {g('ctl W0-6l')} | {g('ctl WD-6l')} | {g('ctl I-200l')} | {g('ctl W0-200l')} | {g('ctl WD-200l')}")
print("\nRECUENTOS (propuesto) por caso:")
from collections import Counter
keys=['CA-03','CA-08 6l','CA-08 200l','ctl I-6l','ctl W0-6l','ctl WD-6l','ctl I-200l','ctl W0-200l','ctl WD-200l']
for k in keys:
    c=Counter(r[1].get(k,('—',''))[0] for r in rows); print(f"  {k}: {dict(c)}")
print("\nVIGENTE derivado (#1) — CA-08 6l:",dict(Counter(r[2].get('REQ-100','?').split('(')[0] for r in rows)),"· 200l:",dict(Counter(r[2].get('REQ-200','?').split('(')[0] for r in rows)),"· CA-03 directa:",dict(Counter(r[3].split('(')[0].split(' ')[0] for r in rows)))
print("VIGENTE derivado (#1) — controles:",{k:v.split('(')[0] for k,v in sorted(ctl.items())})
ds=[d for _,d in dur if d]; print(f"\nDURACIÓN: {len(ds)} corridas, total {sum(ds):.0f} s, mín {min(ds):.0f} s, máx {max(ds):.0f} s")
print("\nMENSAJES completos (propuesto):")
for n,res,_,_ in rows:
    for k in keys: 
        if k in res: print(f"  [{n}] {res[k][1][:230]}")
