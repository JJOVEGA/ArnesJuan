import json, os, shutil, subprocess, sys, tempfile, re
REPO='/home/juan/dev/ArnesJuan-v1.35'; E=sys.argv[1]; C=E+'/campos/'
trees={'cand':REPO+'/hooks','1.33.2':'/home/juan/.claude/plugins/cache/arnes-juan/arnes-juan/1.33.2/hooks'}
def run(h, proj, payload):
    env=dict(os.environ, CLAUDE_PROJECT_DIR=proj)
    p=subprocess.run([h+'/guard.sh'], input=json.dumps(payload).encode(), capture_output=True, env=env)
    o=p.stdout.decode()
    try: j=json.loads(o.strip().splitlines()[-1]) if o.strip() else {}
    except Exception: j={}
    d=j.get('hookSpecificOutput',{}).get('permissionDecision','allow')
    return d, j.get('hookSpecificOutput',{}).get('permissionDecisionReason','')[:150]
for tname,h in trees.items():
    proj=tempfile.mkdtemp(); os.makedirs(proj+'/.arnes'); os.makedirs(proj+'/requirements')
    shutil.copy(REPO+'/.arnes/config.json', proj+'/.arnes/config.json')
    shutil.copy(REPO+'/PENDING_APPROVAL.md', proj+'/PENDING_APPROVAL.md')
    for r in ['023','031','001','007']:
        shutil.copy(f'{REPO}/requirements/REQ-{r}.md', f'{proj}/requirements/REQ-{r}.md')
    for r in ['023','031','001','007']:
        fp=f'{proj}/requirements/REQ-{r}.md'
        for campo in ['qa','hall']:
            try: nuevo=open(C+f'REQ-{r}.{campo}.nuevo',encoding='utf-8').read().rstrip('\n')
            except FileNotFoundError: continue
            antes=open(C+f'REQ-{r}.{campo}.antes',encoding='utf-8').read().rstrip('\n')
            txt=open(fp,encoding='utf-8').read(); assert txt.count(antes)==1, (r,campo,txt.count(antes))
            pl={'hook_event_name':'PreToolUse','tool_name':'Edit','cwd':proj,'agent_type':'arnes-juan:qa-tester','agent_id':'qa1',
                'tool_input':{'file_path':fp,'old_string':antes,'new_string':nuevo}}
            d,m=run(h,proj,pl); print(f'{tname:7} REQ-{r} {campo:4} Edit literal -> {d} {m}')
            open(fp,'w',encoding='utf-8').write(txt.replace(antes,nuevo))
    # interpretabilidad del campo: cierre simulado sobre la copia, con cola vacia, gates true y veredictos aprobados
    cfg=json.load(open(proj+'/.arnes/config.json')); cfg['quality_gates']=['true']; json.dump(cfg,open(proj+'/.arnes/config.json','w'))
    open(proj+'/PENDING_APPROVAL.md','w').write('## Pendientes\n\n## Resueltas\n')
    for r in ['023','031','007']:
        fp=f'{proj}/requirements/REQ-{r}.md'; txt=open(fp,encoding='utf-8').read()
        txt=re.sub(r'(?m)^QA: .*$','QA: aprobado',txt,count=1); txt=re.sub(r'(?m)^Seguridad: .*$','Seguridad: aprobado',txt,count=1)
        open(fp,'w',encoding='utf-8').write(txt)
        est=re.search(r'(?m)^Estado: .*$',txt).group(0)
        pl={'hook_event_name':'PreToolUse','tool_name':'Edit','cwd':proj,'tool_input':{'file_path':fp,'old_string':est,'new_string':'Estado: completado'}}
        d,m=run(h,proj,pl); print(f'{tname:7} REQ-{r} cierre simulado (veredictos verdes, cola vacia) -> {d} {m}')
    shutil.rmtree(proj)
