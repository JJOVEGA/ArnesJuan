#!/usr/bin/env python3
# Construye los valores nuevos de los campos QA:/Hallazgos abiertos: a partir de los actuales, con
# sustituciones EXACTAS (cada ancla debe aparecer una sola vez). Escribe <n>.new junto a <n>.old.
import pathlib, sys
D = pathlib.Path(__file__).parent

def sub(nombre, pares):
    t = (D / f"{nombre}.old").read_text(encoding="utf-8").rstrip("\n")
    for a, b in pares:
        if t.count(a) != 1:
            sys.exit(f"{nombre}: el ancla aparece {t.count(a)} veces: {a[:60]!r}")
        t = t.replace(a, b)
    (D / f"{nombre}.new").write_text(t + "\n", encoding="utf-8")
    print(f"== {nombre}.new ({len(t.encode())} bytes)\n{t}\n")

Q43 = ("2026-09-30, vuelta excepcional de la quinta autorización, árbol 43b948a: CA-45, CA-46 b d e, "
       "CA-47 y CA-48 verificados contra su contrato y rotos con casos propios, conformes salvo QA-023-09; "
       "CA-49, CA-50, la nota de CA-58, CA-60 y la nota de CA-24 conformes; CA-66 puntos 1 a 5, 7 y 8 "
       "conformes, con el fail-before re-derivado contra 9596e39 y 1.33.2, y punto 6 incompleto, QA-023-11; "
       "CA-54 incumplido, QA-023-10; banco completo 1322 PASS, 0 FAIL, 12 SKIP, cuadre 1334; autoprueba "
       "117/0; gates rc 0; ")

sub("007-qa", [("abierto QA-023-08 contra CA-46 apartado b; docs/qa/REQ-023.md)",
                "QA-023-08 cerrado por el write-back de CA-46 apartado b del 2026-09-30; " + Q43 +
                "docs/qa/REQ-023.md)")])

H09 = ("QA-023-09 (contrato, alta a nivel de hook, regresión introducida por 104ffd1: un cwd con salto de "
       "línea desplaza los campos que lee arnes_parse_input y las dos puertas juzgan otra ruta; por la ruta "
       "canónica, un Edit, Write o MultiEdit que cierra un REQ critico con QA pendiente, la edición no "
       "reconstruible de SEC-117 y el enlace de CA-49 apartado i salen allow, y un Write de la coordinadora "
       "a src/a.ts también, donde 9596e39 y 1.33.2 deniegan; es un movimiento de deny a allow que CA-24 y "
       "CA-66 punto 5 no declaran; alcanzable desde el host sin medir; dueño desarrollador; docs/qa/REQ-023.md)")
H10 = ("QA-023-10 (contrato, media: CA-54 exige menos de 5 s en el máximo declarado y el candidato tarda de "
       "9,5 a 12,1 s con 131072 bytes y entre 5506 y 8258 destinos, frente a 2,9 a 6,9 s de 9596e39, que ya "
       "lo superaba en una de las tres formas; dueño desarrollador y analista-requerimientos; docs/qa/REQ-023.md)")
H11 = ("QA-023-11 (contrato, media: CA-45 y CA-66 punto 6 dicen que R5 y el cwd tras un cd se comprueban en "
       "el host donde sea reproducible o se declaran como límite, y la validación sec119-v3 ni los ejecuta ni "
       "los declara no comprobados; dueño coordinadora, y analista-requerimientos si se declaran como límite; "
       "docs/qa/REQ-023.md)")

h007 = (D / "007-hall.old").read_text(encoding="utf-8").rstrip("\n")
i = h007.index(", QA-023-08 (contrato")
sub("007-hall", [(h007[i:], ", " + H09 + ", " + H10 + ", " + H11)])

sub("023-qa", [("abierto QA-023-07, instrumento; docs/qa/REQ-023.md)",
                "QA-023-07 cerrado el 2026-09-30; 2026-09-30, quinta autorización, árbol 43b948a: se mantiene "
                "sobre el código final, que cambió en lib.sh y guard-completado.sh —banco completo 1322 PASS, 0 "
                "FAIL, 12 SKIP, cuadre 1334, con los 198 casos de REQ-023 y las secciones 14, 41 y 42 en verde, y "
                "las 99 denegaciones de las secciones de control emitidas por su propia puerta—; no cubre "
                "QA-023-09, abierto, instrumento aquí y contrato en REQ-007; docs/qa/REQ-023.md)")])

h023 = (D / "023-hall.old").read_text(encoding="utf-8").rstrip("\n")
a = h023.index("QA-023-07 (instrumento, preexistente")
b = h023.index(", SEC-119 (instrumento")
H09b = ("QA-023-09 (instrumento, alta a nivel de hook, regresión de 104ffd1 sobre el código que aprobó este "
        "REQ: un cwd con salto de línea desplaza los campos que lee arnes_parse_input, la puerta juzga otra "
        "ruta y un cierre con QA pendiente o una edición no reconstruible sobre la ruta canónica salen allow; "
        "la promesa que falla es la identidad del destino de REQ-007 CA-47, a la que remite CA-13 apartado iv, "
        "y allí es contrato; alcanzable desde el host sin medir; urgencia de seguridad escalada a la "
        "coordinadora; dueño desarrollador; docs/qa/REQ-023.md)")
sub("023-hall", [(h023[a:b], H09b)])

sub("031-qa", [("08 y 32 en verde en el banco completo; docs/qa/REQ-023.md)",
                "08 y 32 en verde en el banco completo; 2026-09-30, árbol 43b948a: se mantiene sobre el código "
                "final —63 casos de REQ-031 en verde y la sección 08 con los mismos veredictos que 9596e39—; no "
                "cubre QA-023-09, registrado en REQ-023 y REQ-007; docs/qa/REQ-023.md)")])

sub("001-qa", [("el contrato anterior al 2026-09-30; docs/qa/REQ-023.md)",
                "el contrato anterior al 2026-09-30; 2026-09-30, árbol 43b948a: se mantiene sobre el código final "
                "—CA-10, CA-11 y CA-12 en verde y las secciones 14 y 42 sin cambio de decisión y llegando a su "
                "puerta—; no cubre QA-023-09, registrado en REQ-023 y REQ-007; docs/qa/REQ-023.md)")])
