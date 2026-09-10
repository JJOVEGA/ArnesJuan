import re,glob,os
os.chdir('/home/juan/dev/ArnesJuan-1.34-reparaciones')
reg=open('docs/seguridad/registro-seguridad.md',encoding='utf-8').read().split('\n')
idx={}; inidx=False
for i,l in enumerate(reg,1):
    if l.startswith('## Índice de hallazgos de clase bloqueante'): inidx=True; continue
    if inidx and l.startswith('## '): break
    if inidx and l.startswith('| `'):
        c=[x.strip() for x in l.strip('|').split('|')]
        idx[c[0].strip('`')]=(c[1].replace('*',''),c[2].replace('`','').replace('*',''),i)
bloq={}
for f in sorted(glob.glob('requirements/REQ-*.md')):
    head=open(f,encoding='utf-8').read().split('\n## ')[0]
    m=re.search(r'^[*_`> ]*Hallazgos abiertos[*_` ]*:(.*)$',head,re.M)
    if not m: continue
    for mm in re.finditer(r'([A-Z][A-Z]+-[0-9]+(?:-[0-9]+)?|H-[0-9]+)\s*\(([^,)]*)',m.group(1)):
        cl=mm.group(2).strip().replace('`','')
        if cl.startswith(('contrato','usuario/dinero')): bloq.setdefault(mm.group(1),[]).append((os.path.basename(f),cl))
print("A) IDs bloqueantes declarados en campos `Hallazgos abiertos:` de requirements/ :",len(bloq))
print("   ausentes del indice:", [k for k in bloq if k not in idx] or "NINGUNO")
bl=[k for k,(c,e,i) in idx.items() if e in ('abierto','en-mitigación')]
print("B) filas del indice con estado bloqueante (abierto|en-mitigación) :",len(bl))
print("C) de esas, cuantas estan en un campo :",len([k for k in bl if k in bloq]))
print()
print("Celdas de la 3a columna comprobadas contra el arbol:")
for k in ('SEC-014','SEC-055','SEC-083','SEC-052'):
    en=[r for r in bloq if r==k]
    print(f"  {k}: en campo AHORA = {'SI ('+bloq[k][0][0]+')' if k in bloq else 'NO'} | celda del indice dice: {idx[k][2]} -> {reg[idx[k][2]-1].split('|')[-2].strip()[:110]}")
