"""Generate original, deterministic PCM sound effects. Python standard library only."""
from pathlib import Path
import math, random, struct, wave
RATE = 44100
OUT = Path(__file__).resolve().parents[1] / "assets/audio/sfx"

def render(name, duration, kind, notes=()):
    rng = random.Random(name)
    samples = []
    low = 0.0
    for i in range(int(duration * RATE)):
        t = i / RATE
        noise = rng.uniform(-1, 1)
        low = low * .86 + noise * .14
        x = 0.0
        if kind == "wood":
            x = (math.sin(2*math.pi*780*t) + .5*math.sin(2*math.pi*1237*t) + noise*.22)*math.exp(-t*55)
        elif kind == "paper":
            x = (noise-low)*.5 * math.sin(math.pi*t/duration)**2 * (.65+.35*math.sin(2*math.pi*31*t))
        elif kind == "metal":
            x = sum(math.sin(2*math.pi*f*t)*math.exp(-t*(8+j*3))/(j+1) for j,f in enumerate([530, 887, 1421, 2317])) + noise*.3*math.exp(-t*60)
        elif kind == "whoosh":
            x = low*2.5*math.sin(math.pi*t/duration)**2
        elif kind == "shot":
            x = noise*math.exp(-t*32) + low*2*math.exp(-t*10) + .4*math.sin(2*math.pi*75*t)*math.exp(-t*12)
        elif kind == "march":
            u = t % .18
            x = (low*2 + .4*math.sin(2*math.pi*110*u))*math.exp(-u*35)
        elif kind == "bow":
            x = math.sin(2*math.pi*(390*t-80*t*t))*math.exp(-t*22) + low*math.sin(math.pi*t/duration)**2
        else:
            for start, freq, gain in notes:
                u = t-start
                if u >= 0:
                    if kind == "drum":
                        x += gain*(math.sin(2*math.pi*(freq*u+3*(1-math.exp(-u*30)))) + noise*.12)*math.exp(-u*9)
                    else:
                        x += gain*(math.sin(2*math.pi*freq*u)+.25*math.sin(2*math.pi*freq*2.003*u))*math.exp(-u*5)*min(1,u/.008)
        x *= min(1,t/.003) * min(1,(duration-t)/.025)
        samples.append(x)
    peak = max(abs(x) for x in samples) or 1
    pcm = b"".join(struct.pack("<h", round(x/peak*.72*32767)) for x in samples)
    with wave.open(str(OUT / (name+".wav")), "wb") as f:
        f.setparams((1,2,RATE,0,"NONE","not compressed")); f.writeframes(pcm)

if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for name,duration,kind in [("ui_click",.09,"wood"),("scroll",.28,"paper"),("city_select",.18,"wood"),("sword",.28,"whoosh"),("impact",.32,"metal"),("guard",.45,"metal"),("march",.60,"march"),("arrow",.32,"bow"),("gunshot",.48,"shot"),("spy",.7,"whoosh")]:
        render(name,duration,kind)
    for name,duration,kind,notes in [
        ("turn_end",.85,"drum",[(0,95,1),(.23,72,.9)]),
        ("round_start",1,"drum",[(0,85,.8),(.2,85,.7),(.43,65,1)]),
        ("reinforcement",1.15,"drum",[(0,85,1),(.17,95,.8),(.34,105,.8),(.55,70,1)]),
        ("skill",1.15,"drum",[(0,60,1),(.20,120,.7),(.42,80,1)]),
        ("trade",.65,"bell",[(0,1200,.7),(.09,1500,.5),(.20,1800,.4)]),
        ("diplomacy",.8,"bell",[(0,392,.7),(.18,523,.7)]),
        ("success",.85,"bell",[(0,523,.7),(.16,659,.7),(.32,784,.8)]),
        ("failure",.65,"bell",[(0,261,.8),(.20,196,1)]),
        ("research",1.1,"bell",[(0,523,.7),(.18,784,.6),(.36,1046,.7)]),
        ("victory",1.8,"bell",[(0,392,1),(.23,523,1),(.46,659,.8),(.70,784,1)]),
        ("defeat",1.5,"bell",[(0,293,.8),(.30,220,1),(.60,146,1)])]:
        render(name,duration,kind,notes)
    print(f"Generated {len(list(OUT.glob('*.wav')))} original WAV effects")
