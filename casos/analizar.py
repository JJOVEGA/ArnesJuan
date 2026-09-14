import json,sys,os,subprocess,glob
T=sys.argv[1]; casos=["CON-1","CON-2","CON-3","SIN-1","SIN-2","SIN-3"]
def ev(path):
    out=[]
    for l in open(path,encoding="utf-8",errors="replace"):
        try: out.append(json.loads(l))
        except: pass
    return out
for c in casos:
    d=f"{T}/casos/{c}"; base=f"{T}/proy-{c[:3]}.base"
    print(f"\n=== {c} ===")
    if not os.path.exists(f"{d}/salida.jsonl"): print("  (sin salida)"); continue
    E=ev(f"{d}/salida.jsonl")
    rc=open(f"{d}/rc.txt").read().strip() if os.path.exists(f"{d}/rc.txt") else "?"
    # despachos y escrituras, en orden
    desp=[];escr=[];deny=[]
    for e in E:
        if e.get("type")=="assistant":
            for b in e["message"].get("content",[]):
                if isinstance(b,dict) and b.get("type")=="tool_use":
                    n=b.get("name"); i=b.get("input",{})
                    if n=="Agent": desp.append(i.get("subagent_type","?").replace("arnes-juan:",""))
                    if n in("Edit","Write"): escr.append(os.path.relpath(i.get("file_path","?"),d) if str(i.get("file_path","")).startswith(d) else i.get("file_path","?"))
        if e.get("type")=="user":
            for b in (e["message"].get("content") or []):
                if isinstance(b,dict) and b.get("type")=="tool_result":
                    s=json.dumps(b.get("content"),ensure_ascii=False)
                    if "deny" in s.lower() or "denegad" in s.lower() or "requested permissions" in s.lower(): deny.append(s[:160])
        if e.get("type")=="result":
            print(f"  result: {e.get('subtype')} error={e.get('is_error')} turns={e.get('num_turns')} cost=${e.get('total_cost_usd',0):.2f} dur={e.get('duration_ms',0)//1000}s rc={rc}")
    print(f"  despachos (orden): {desp if desp else 'NINGUNO'}")
    print(f"  escrituras de la coordinadora: {escr if escr else 'ninguna'}")
    if deny: print(f"  denegaciones/permisos ({len(deny)}):"); [print("    -",x) for x in deny[:6]]
    # diff contra base: qué archivos del proyecto cambiaron / aparecieron
    r=subprocess.run(["diff","-rq","-x","salida.jsonl","-x","err.log","-x","rc.txt","-x","fin.txt","-x",".prompt.txt","-x",".claude",base,d],capture_output=True,text=True).stdout
    cambios=[]
    for l in r.splitlines():
        if l.startswith("Files"): cambios.append("M "+l.split()[3].replace(d+"/",""))
        elif l.startswith("Only in "+d): cambios.append("+ "+l.split(": ")[1])
        elif l.startswith("Only in "+base): cambios.append("- "+l.split(": ")[1])
    print(f"  archivos del proyecto cambiados: {cambios if cambios else 'ninguno'}")
    # write-back: ¿cambió el REQ pertinente? ¿nació un REQ nuevo?
    req={"1":"REQ-001.md","2":"REQ-002.md"}.get(c[-1])
    if req:
        a=open(f"{base}/requirements/{req}").read(); b=open(f"{d}/requirements/{req}").read() if os.path.exists(f"{d}/requirements/{req}") else ""
        print(f"  write-back en {req}: {'SÍ' if a!=b else 'NO'}", end="")
        if a!=b:
            import difflib
            dl=[x for x in difflib.unified_diff(a.splitlines(),b.splitlines(),lineterm="",n=0) if x.startswith(("+","-")) and not x.startswith(("+++","---"))]
            print(f" ({len(dl)} líneas): "+" | ".join(x[:70] for x in dl[:4]))
        else: print()
    else:
        nuevos=[os.path.basename(x) for x in glob.glob(f"{d}/requirements/REQ-*.md") if not os.path.exists(f"{base}/requirements/{os.path.basename(x)}")]
        print(f"  REQ nuevo creado: {nuevos if nuevos else 'NO'}")
        for n in nuevos:
            s=open(f"{d}/requirements/{n}").read()
            cab={k:[l for l in s.splitlines() if l.startswith(k+':')] for k in ("Rigor","Sensible a seguridad","Estado","QA","Seguridad")}
            print("    cabecera:", {k:(v[0] if v else 'AUSENTE') for k,v in cab.items()})
    # subagentes: transcripciones propias en ~/.claude/projects
    slug="-"+d.strip("/").replace("/","-")
    pj=glob.glob(os.path.expanduser(f"~/.claude/projects/{slug}/*.jsonl"))
    print(f"  transcripciones en ~/.claude/projects/{slug}: {len(pj)}")
