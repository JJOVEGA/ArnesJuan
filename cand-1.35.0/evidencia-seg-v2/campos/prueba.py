import json, subprocess, os, shutil, sys
E2=os.environ["E2"]; R="/home/juan/dev/ArnesJuan-v1.35"; CAND=R+"/hooks"
P=E2+"/campos/proy"; shutil.rmtree(P, ignore_errors=True); os.makedirs(P+"/.arnes"); os.makedirs(P+"/requirements")
shutil.copy(E2+"/proy/.arnes/config.json", P+"/.arnes/config.json")
def juzga(j):
    r=subprocess.run(["bash",CAND+"/guard.sh"],input=json.dumps(j).encode(),capture_output=True,env=dict(os.environ,CLAUDE_PROJECT_DIR=P))
    o=r.stdout.decode().strip()
    if not o: return "allow",""
    d=json.loads(o); h=d.get("hookSpecificOutput",{})
    return h.get("permissionDecision","aviso"), (h.get("permissionDecisionReason") or d.get("systemMessage",""))[:160]
nuevas={}
for l in open(E2+"/campos/nuevas.txt",encoding="utf-8"):
    req,n,txt=l.rstrip("\n").split("|",2); nuevas.setdefault(req,[]).append((int(n),txt))
for req,cambios in nuevas.items():
    f=P+"/requirements/"+req+".md"; src=open(R+"/requirements/"+req+".md",encoding="utf-8").read(); lines=src.split("\n")
    open(f,"w",encoding="utf-8").write(src)
    for n,txt in cambios:
        old=lines[n-1]; assert src.count(old)==1, (req,n,"no unica")
        d,m=juzga({"tool_name":"Edit","cwd":P,"agent_type":"auditor-seguridad","agent_id":"x","tool_input":{"file_path":f,"old_string":old,"new_string":txt,"replace_all":False}})
        print(f"{req} linea {n}: Edit literal -> {d} {m}")
        src=src.replace(old,txt,1); lines=src.split("\n"); open(f,"w",encoding="utf-8").write(src)
    # cierre simulado: QA y Seguridad aprobados, cola vacia
    ls=src.split("\n"); est=[x for x in ls[:15] if x.startswith("Estado:")][0]
    sim=src.replace(est,"Estado: en-revisión",1)
    for x in ls[:15]:
        if x.startswith("QA:"): sim=sim.replace(x,"QA: aprobado (copia)",1)
        if x.startswith("Seguridad:") and not x.startswith("Seguridad: aprobado"): sim=sim.replace(x,"Seguridad: aprobado (copia)",1)
    open(f,"w",encoding="utf-8").write(sim)
    d,m=juzga({"tool_name":"Edit","cwd":P,"agent_type":"auditor-seguridad","agent_id":"x","tool_input":{"file_path":f,"old_string":"Estado: en-revisión","new_string":"Estado: completado","replace_all":False}})
    print(f"{req}: cierre simulado en verde -> {d} {m}")
    # el lector: que no haya ambiguedad y que Seguridad se lea como veredicto
    open(f,"w",encoding="utf-8").write(src)
    out=subprocess.run(["bash","-c",f'. {CAND}/lib.sh; arnes_campos_req "$(cat {f})" ""; echo "AMB=$ARNES_AMBIGUA SEG=<$ARNES_SEG> HALL_N=$ARNES_HALL_N"'],capture_output=True).stdout.decode().strip()
    print(f"{req}: lector -> {out}")
