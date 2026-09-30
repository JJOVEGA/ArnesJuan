import json, subprocess, os, shutil
E2=os.environ["E2"]; R="/home/juan/dev/ArnesJuan-v1.35"; CAND=R+"/hooks"; P=E2+"/campos/proy2"
shutil.rmtree(P, ignore_errors=True); os.makedirs(P+"/.arnes"); os.makedirs(P+"/requirements"); shutil.copy(E2+"/proy/.arnes/config.json", P+"/.arnes/config.json")
for req in ["REQ-023","REQ-031","REQ-001","REQ-007"]:
    src=open(R+"/requirements/"+req+".md",encoding="utf-8").read(); f=P+"/requirements/"+req+".md"
    ls=src.split("\n"); est=[x for x in ls[:15] if x.startswith("Estado:")][0]; sim=src.replace(est,"Estado: en-revisión",1)
    for x in ls[:15]:
        if x.startswith("QA:") and not x.startswith("QA: aprobado"): sim=sim.replace(x,"QA: aprobado (copia)",1)
    open(f,"w",encoding="utf-8").write(sim)
    r=subprocess.run(["bash",CAND+"/guard.sh"],input=json.dumps({"tool_name":"Edit","cwd":P,"agent_type":"auditor-seguridad","agent_id":"x","tool_input":{"file_path":f,"old_string":"Estado: en-revisión","new_string":"Estado: completado","replace_all":False}}).encode(),capture_output=True,env=dict(os.environ,CLAUDE_PROJECT_DIR=P))
    o=r.stdout.decode().strip(); d="allow" if not o else json.loads(o)["hookSpecificOutput"]["permissionDecision"]; m="" if not o else json.loads(o)["hookSpecificOutput"]["permissionDecisionReason"][:120]
    print(f"{req} (archivo final, QA forzado a aprobado en la copia, cola vacía): cierre -> {d} {m}")
