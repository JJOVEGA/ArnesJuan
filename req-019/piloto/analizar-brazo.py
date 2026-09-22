#!/usr/bin/env python3
# REQ-019 piloto: lee salida.jsonl de UN brazo y publica, por comisión (parent_tool_use_id), lecturas de los
# documentos de arranque, tokens reportados por el CLI, despachos, ediciones, denegaciones y obligaciones.
import json,sys,os,re,subprocess
O=sys.argv[1]; R=sys.argv[2]          # salidas/<brazo>  casos/<brazo>
DOCS=["requirements/README.md","docs/ESTADO.md","AGENTS.md","CHANGELOG.md","PENDING_APPROVAL.md"]
E=[json.loads(l) for l in open(f"{O}/salida.jsonl",encoding="utf-8",errors="replace") if l.strip()]
tu={}; rol_de={}; desp=[]; lect=[]; edits=[]; bash=[]; den=[]; tok={}; primer={}; res={}; r=None
def rol(pid): return rol_de.get(pid,"COORDINADORA") if pid else "COORDINADORA"
for e in E:
    pid=e.get("parent_tool_use_id"); t=e.get("type")
    if t=="assistant":
        u=e["message"].get("usage") or {}
        k=pid or "COORD"; inp=(u.get("input_tokens",0)+u.get("cache_creation_input_tokens",0)+u.get("cache_read_input_tokens",0))
        if k not in primer and inp: primer[k]=inp
        tok.setdefault(k,[0,0]); tok[k][0]+=inp; tok[k][1]+=u.get("output_tokens",0)
        for b in e["message"].get("content",[]):
            if not(isinstance(b,dict) and b.get("type")=="tool_use"): continue
            n=b.get("name"); i=b.get("input",{}) or {}; tu[b["id"]]=(n,i,pid)
            if n in("Agent","Task"): rol_de[b["id"]]=str(i.get("subagent_type","?")).replace("arnes-juan:",""); desp.append((rol(pid),rol_de[b["id"]]))
            if n=="Read":
                fp=str(i.get("file_path","")); d=[x for x in DOCS if fp.endswith(x)]
                if d: lect.append([rol(pid),d[0],"Read",i.get("offset"),i.get("limit"),b["id"],None])
            if n=="Bash":
                cmd=str(i.get("command","")); bash.append((rol(pid),cmd[:110],b["id"]))
                for x in DOCS:
                    if x in cmd or os.path.basename(x) in cmd: lect.append([rol(pid),x,"Bash",cmd[:70],None,b["id"],None])
            if n in("Grep","Glob"):
                p=str(i.get("path","")); d=[x for x in DOCS if p.endswith(x)]
                if d: lect.append([rol(pid),d[0],n,str(i.get("pattern",""))[:40],None,b["id"],None])
            if n in("Edit","Write"): edits.append((rol(pid),str(i.get("file_path","")).replace(R+"/",""),b["id"]))
    elif t=="user":
        for b in (e["message"].get("content") or []):
            if isinstance(b,dict) and b.get("type")=="tool_result" and b.get("tool_use_id") in tu:
                n,i,p=tu[b["tool_use_id"]]; s=json.dumps(b.get("content"),ensure_ascii=False); res[b["tool_use_id"]]=(len(s),bool(b.get("is_error")),s)
                if n in("Edit","Write","Bash") and (b.get("is_error") or re.search(r'guard-|deneg|deny|blocked|PreToolUse',s,re.I)): den.append((rol(p),n,os.path.basename(str(i.get("file_path",i.get("command","?"))))[:60],re.sub(r'\s+',' ',s)[:160]))
    elif t=="result": r=e
for L in lect: L[6]=res.get(L[5],(None,))[0]
print(f"== {os.path.basename(O)} ==  result: {r and r.get('subtype')} error={r and r.get('is_error')} turns={r and r.get('num_turns')} cost=${(r or {}).get('total_cost_usd',0):.2f} dur={(r or {}).get('duration_ms',0)//1000}s")
print("despachos (quién → a quién, en orden):",desp)
print("\nLECTURAS de los documentos de arranque (rol · doc · vía · offset/limit o comando · tamaño del resultado en chars):")
for L in lect: print(f"   [{L[0]}] {L[1]} · {L[2]} · {L[3]}/{L[4]} · {L[6]}")
print("\nTOKENS reportados por el CLI (comisión: primer turno input · Σ input · Σ output):")
for k,v in tok.items(): print(f"   [{rol(None) if k=='COORD' else rol_de.get(k,k)}] primer={primer.get(k)} Σin={v[0]} Σout={v[1]}")
mu=(r or {}).get("modelUsage") or {}
for m,v in mu.items(): print(f"   modelUsage {m}: in={v.get('inputTokens')} out={v.get('outputTokens')} cacheRead={v.get('cacheReadInputTokens')} cacheCreate={v.get('cacheCreationInputTokens')}")
print(f"\nEDICIONES ({len(edits)}):"); [print(f"   [{a}] {f}") for a,f,_ in edits]
print(f"DENEGACIONES/errores en Edit/Write/Bash ({len(den)}):"); [print("   ",d) for d in den[:10]]
print(f"\nBASH ({len(bash)} comandos):"); [print(f"   [{a}] {c}  -> {'ERR' if res.get(t,(0,False))[1] else 'ok'}") for a,c,t in bash]
print("\nOBLIGACIONES (del árbol final):")
out=subprocess.run(["git","-C",R,"status","--porcelain"],capture_output=True,text=True).stdout
print("   archivos cambiados vs estado inicial:"); [print("     ",l) for l in out.splitlines()]
for f in ["CHANGELOG.md","docs/ESTADO.md"]: print(f"   {f} modificado: {'sí' if f in out else 'no'}")
sec=subprocess.run(["git","-C",R,"diff","--","tests/escenarios/hooks/secciones/33-acento-y-clave-1-normalizacion.sh"],capture_output=True,text=True).stdout
print("   diff de la sección 33:"); [print("     ",l) for l in sec.splitlines() if l.startswith(("+","-")) and not l.startswith(("+++","---"))]
for f in re.findall(r'requirements/REQ-\d+\.md',out):
    p=f"{R}/{f}"
    if os.path.exists(p): print(f"   cabecera {f}: "+" | ".join(l for l in open(p,encoding='utf-8').read().splitlines()[:14] if re.match(r'^(Estado|Archivos|QA|Seguridad|Hallazgos abiertos|Rigor):',l))[:400])
ce=[a for a,f,i in edits if f.startswith("requirements/REQ") and re.search(r'Estado:\s*completado',json.dumps(tu[i][1]))]
print("   intentos de escribir 'Estado: completado':",ce or "ninguno")
