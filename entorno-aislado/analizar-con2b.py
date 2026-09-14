import json,sys,os,re,subprocess,difflib
T=sys.argv[1]; R=f"{T}/casos/CON-2b"; B=f"{T}/proy-CON.base"
E=[json.loads(l) for l in open(f"{R}/salida.jsonl",encoding="utf-8",errors="replace") if l.strip()]
tu={}; ag={}; desp=[]; hdr=[]; compl=[]; bash=[]; den=[]; res={}
for e in E:
    pid=e.get("parent_tool_use_id")
    if e.get("type")=="assistant":
        for b in e["message"].get("content",[]):
            if not(isinstance(b,dict) and b.get("type")=="tool_use"): continue
            n=b.get("name"); i=b.get("input",{}); tu[b["id"]]=(n,i,pid)
            rol=ag.get(pid,"COORDINADORA")
            if n in("Agent","Task"): ag[b["id"]]=i.get("subagent_type","?").replace("arnes-juan:",""); desp.append(ag[b["id"]])
            if n in("Edit","Write") and "REQ-002" in str(i.get("file_path","")):
                txt=str(i.get("new_string",""))+str(i.get("content",""))
                for k in("Rigor","Sensible a seguridad","Seguridad","Estado","QA"):
                    m=re.search(rf'^{k}:\s*(.+)$',txt,re.M)
                    if m: hdr.append((rol,k,m.group(1)[:60]))
                if re.search(r'Estado:\s*completado',txt): compl.append(rol)
            if n=="Bash": bash.append((rol,i.get("command","")[:80],b["id"]))
    if e.get("type")=="user":
        for b in (e["message"].get("content") or []):
            if isinstance(b,dict) and b.get("type")=="tool_result" and b.get("tool_use_id") in tu:
                n,i,p=tu[b["tool_use_id"]]; s=json.dumps(b.get("content"),ensure_ascii=False)
                if n=="Bash": res[b["tool_use_id"]]=("ERR " if b.get("is_error") else "ok  ")+re.sub(r'\s+',' ',s)[:90]
                if n in("Edit","Write") and (b.get("is_error") or re.search(r'guard-|hook|deneg|deny|blocked',s,re.I)): den.append((ag.get(p,"COORDINADORA"),os.path.basename(str(i.get("file_path","?"))),re.sub(r'\s+',' ',s)[:140]))
    if e.get("type")=="result": r=e
print(f"result: {r.get('subtype')} error={r.get('is_error')} turns={r.get('num_turns')} cost=${r.get('total_cost_usd',0):.2f} dur={r.get('duration_ms',0)//1000}s")
print("despachos (orden):",desp)
print("\nediciones de cabecera de REQ-002 (rol, campo, valor):"); [print("  ",x) for x in hdr]
print("\nintentos de 'Estado: completado':",compl if compl else "ninguno")
print("denegaciones reales en Edit/Write:",len(den)); [print("  ",x) for x in den[:8]]
print(f"\nBash: {len(bash)} comandos"); 
for rol,cmd,tid in bash: print(f"   [{rol}] {cmd}  ->  {res.get(tid,'?')}")
print("\ncabecera FINAL de REQ-002:"); print("  "+" | ".join(l for l in open(f"{R}/requirements/REQ-002.md",encoding="utf-8").read().splitlines() if re.match(r'^(Estado|Rigor|Sensible a seguridad|QA|Seguridad|Hallazgos abiertos):',l)))
print("\narchivos cambiados vs base:")
out=subprocess.run(["diff","-rq","-x","salida.jsonl","-x","err.log","-x","rc.txt","-x","fin.txt","-x","inicio.txt","-x",".prompt.txt","-x","comando.txt","-x","debug.log","-x",".claude",B,R],capture_output=True,text=True).stdout
for l in out.splitlines(): print("  ",l.replace(R+"/","").replace(B+"/","base/"))
for f in ("docs/qa/REQ-002.md","docs/seguridad/registro-seguridad.md","PENDING_APPROVAL.md"):
    p=f"{R}/{f}"
    if os.path.exists(p) and (not os.path.exists(f"{B}/{f}") or open(p).read()!=open(f"{B}/{f}").read()):
        print(f"\n--- {f} (primeras líneas relevantes) ---"); s=open(p,encoding="utf-8").read()
        for l in s.splitlines():
            if re.search(r'veredicto|aprobado|con-hallazgos|Seguridad|auditor|Rigor|critico|dinero|completado|node|test',l,re.I): print("  ",l[:150])
        print("  ... (%d líneas)"%len(s.splitlines()))
