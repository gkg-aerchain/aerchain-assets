import os
from deck_lib import Slide, R, C, ASSETS, grad, render_pptx, render_png

A=lambda n: os.path.join(ASSETS,n)
PAGES="04"

# extra brand colours
DV_L="D8C9F5"; DV_HAIR="7E5BC2"          # deep-violet panel accents
PUR_L="ECE3FF"; PUR_HAIR="B98DF0"        # bright-purple panel accents
PILL_BG="F1EAFC"; PILL_TX="6D28D9"       # button/pill chips
TITLE_G=grad("7C3AED","6D28D9",135)
OUT_G=grad("2E1065","4C1D95",140)        # deep royal violet (dark → rich)
IMP_G=grad("6D28D9","9333EA",140)        # vibrant purple

def pill(sl,x,y,w,h,text,size=13,fill=PILL_BG,txt=PILL_TX,line=None,font="mont-semi",spc=None,align="c"):
    sl.rect(x,y,w,h,fill=fill,line=line,lw=0.75,radius=h/2)
    sl.text(x+(0.16 if align=="l" else 0),y,w-(0.16 if align=="l" else 0),h,[R(text,size,txt,font,spc=spc)],align=align,valign="m")

def header(sl, eyebrow, page):
    # Aerchain & Infosys are sized to EQUAL cap-height (Infosys image carries a
    # descender, so it is rendered ~1.21x taller to match the optical size) and
    # share a baseline. Unilever (the client) sits prominently on the right.
    sl.rect(0,0,20,1.05,fill=C['white'])
    sl.line(0,1.05,20,0,C['hair'],0.75)
    sl.img(0.83,0.28,2.91,0.42,A('aerchain_dark.png'))
    sl.text(3.80,0.28,0.55,0.42,[R("×",20,C['muted'],"mono")],align="c",valign="m")
    sl.img(4.40,0.28,1.30,0.51,A('infosys_blue.png'))
    sl.line(5.98,0.30,0,0.45,C['hair'],0.75)
    sl.text(6.22,0,9.0,1.05,[R(eyebrow,12,C['muted'],"mono",bold=True,spc=1.2)],align="l",valign="m")
    sl.text(15.7,0,2.3,1.05,[[R(page,13,C['ink'],"mono",bold=True),R(" / "+PAGES,13,C['muted'],"mono",bold=True)]],align="r",valign="m")
    sl.img(18.32,0.17,0.65,0.72,A('unilever_blue.png'))

def footer(sl):
    sl.rect(0,10.83,20,0.42,fill=C['white'])
    sl.line(0,10.83,20,0,C['hair'],0.75)
    sl.text(0.83,10.83,12,0.42,[R("AERCHAIN × INFOSYS · AUTONOMOUS SOURCING",9,C['muted'],"mono",bold=True,spc=0.8)],align="l",valign="m")
    sl.text(7.17,10.83,12,0.42,[R("CONFIDENTIAL · PREPARED FOR UNILEVER",9,C['muted'],"mono",bold=True,spc=0.8)],align="r",valign="m")

def section(sl, num, kicker, title_runs, sub):
    sl.rect(0.83,1.33,0.46,0.46,fill=C['purple'])
    sl.text(0.83,1.33,0.46,0.46,[R(num,13,C['white'],"mono",bold=True)],align="c",valign="m")
    sl.text(1.48,1.33,12,0.46,[R(kicker,12,C['purple'],"mono",bold=True,spc=1.2)],align="l",valign="m")
    sl.text(0.83,1.88,18.34,0.72,[title_runs],align="l",valign="t")
    sl.text(0.83,2.68,17.6,0.55,[R(sub,15,C['body'],"mont")],align="l",valign="t",ls=1.15)
    sl.line(0.83,3.34,18.34,0,C['hair'],0.75)

# ============ SLIDE 1 — TITLE ============
def slide_title():
    s=Slide()
    s.rect(0,0.42,20,10.83,fill=TITLE_G)
    header(s,"EXECUTIVE BRIEFING · 2026","01")
    s.text(1.0,1.98,16,0.3,[[R("──── ",13,C['purple_l2'],"mono",bold=True),
        R("AERCHAIN × INFOSYS · DEPLOYED AT UNILEVER",13,C['purple_l'],"mono",bold=True,spc=1.2)]],align="l",valign="m")
    s.text(0.97,2.55,18.4,4.2,[
        [R("Autonomous Agentic",80,C['white'],"mont-med")],
        [R("Sourcing",80,C['white'],"mont-med")],
        [R("for Unilever",68,C['white'],"mont-light")],
    ],align="l",valign="t",ls=1.02)
    s.text(1.0,7.25,16.5,1.0,[R("Infosys deploys Aerchain's autonomous-sourcing layer across Unilever — turning classical, manual sourcing into AI-driven, agent-run sourcing that is live and already delivering hard savings.",18,C['purple_l'],"mont-light")],align="l",valign="t",ls=1.25)
    s.line(1.0,8.6,18.0,0,C['purple_l2'],0.75)
    stats=[("$5M","Savings unlocked across 37 sourcing projects"),
           ("1 : 58","Return on every dollar invested in 2026"),
           ("$8M","Hard savings already delivered in 2025"),
           ("Live","In production today for Business Services")]
    for i,(big,lab) in enumerate(stats):
        x=1.0+i*4.5
        s.text(x,8.92,4.3,0.82,[R(big,46,C['white'],"mont")],align="l",valign="t")
        s.text(x,9.78,4.3,0.6,[R(lab,13.5,C['purple_l'],"mont")],align="l",valign="t",ls=1.12)
    s.rect(0,10.83,20,0.42,fill=C['white'])
    s.line(0,10.83,20,0,C['hair'],0.75)
    s.text(0.83,10.83,12,0.42,[R("AERCHAIN · AGENTIC PROCUREMENT PLATFORM",9,C['muted'],"mono",bold=True,spc=0.8)],align="l",valign="m")
    s.text(7.17,10.83,12,0.42,[R("CONFIDENTIAL · PREPARED FOR UNILEVER · VIA INFOSYS",9,C['muted'],"mono",bold=True,spc=0.8)],align="r",valign="m")
    return s

# ============ SLIDE 2 — THE ONE-SLIDER ============
def slide_hero():
    s=Slide()
    s.rect(0,0,20,11.25,fill=C['bg'])
    header(s,"AERCHAIN-AUTONOMOUS SOURCING","02")
    section(s,"01","UNILEVER × INFOSYS × AERCHAIN",
        [R("From classical sourcing to ",40,C['ink'],"mont"),R("autonomous sourcing",40,C['purple'],"mont"),R(".",40,C['ink'],"mont")],
        "What changed when Infosys deployed Aerchain's autonomous-sourcing layer at Unilever — and the value it is already delivering.")
    top=3.55; bot=10.5; H=bot-top
    # ---- ZONE A: BEFORE / NOW ----
    bx,bw=0.83,3.78
    s.rect(bx,top,bw,H,fill=C['white'],line=C['hair'],radius=0.1)
    s.rect(bx,top,bw,0.07,fill=C['muted'])
    s.text(bx+0.28,top+0.34,bw-0.56,0.25,[R("BEFORE",11,C['muted'],"mono",bold=True,spc=1.5)],align="l")
    s.text(bx+0.28,top+0.64,bw-0.56,0.5,[R("Classical sourcing",18,C['ink'],"mont-med")],align="l",ls=1.05)
    before=["Classical, manual sourcing","Heavy Excel dependency","Time & resource constraints",
            "Gaps in category expertise","Limited negotiation leverage","Reliance on past data & benchmarks"]
    iy=top+1.55
    for it in before:
        s.text(bx+0.28,iy,0.34,0.4,[R("✕",13,C['muted'],"mont-semi")],align="l")
        s.text(bx+0.68,iy-0.02,bw-0.96,0.6,[R(it,15,C['body'],"mont")],align="l",ls=1.05)
        iy+=0.86
    # NOW card
    nx,nw=4.78,3.92
    s.rect(nx,top,nw,H,fill=C['white'],line=C['hair'],radius=0.1)
    s.rect(nx,top,nw,0.07,fill=C['purple'])
    s.text(nx+0.28,top+0.34,nw-0.56,0.25,[R("NOW · WITH INFOSYS-AERCHAIN",11,C['purple'],"mono",bold=True,spc=1.0)],align="l")
    s.text(nx+0.28,top+0.64,nw-0.56,0.5,[R("Autonomous sourcing",18,C['ink'],"mont-med")],align="l",ls=1.05)
    now=["AI-driven, time-saving sourcing","Automated quotes, RFx & questionnaires","Intelligent supplier ranking",
         "Automated comms, live tracking","AI-powered insights & query support","Improved negotiation & faster value"]
    iy=top+1.55
    for it in now:
        s.text(nx+0.28,iy,0.34,0.4,[R("✓",14,C['purple'],"mont-bold")],align="l")
        s.text(nx+0.7,iy-0.02,nw-0.98,0.6,[R(it,15,C['ink'],"mont")],align="l",ls=1.05)
        iy+=0.86
    # ---- ZONE B: OUTCOME (teal) ----
    ox,ow=8.95,3.75
    s.rect(ox,top,ow,H,fill=OUT_G,radius=0.12)
    s.text(ox+0.32,top+0.36,ow-0.64,0.3,[R("OUTCOME",13,C['white'],"mono",bold=True,spc=2.0)],align="l")
    s.line(ox+0.32,top+0.86,ow-0.64,0,DV_HAIR,0.75)
    cards=[("$5M","Savings on a $54M spend across 37 sourcing projects — 10% average yield"),
           ("Live","In production today for Unilever Business Services"),
           ("Scaling","Across Marketing & IT for Infosys-managed spend, and beyond")]
    cy=top+1.08; chh=(H-1.2)/3
    for i,(big,desc) in enumerate(cards):
        s.text(ox+0.32,cy+0.10,ow-0.64,0.85,[R(big,46,C['white'],"mont")],align="l")
        s.text(ox+0.32,cy+1.0,ow-0.64,1.0,[R(desc,13,DV_L,"mont")],align="l",ls=1.22)
        cy+=chh
        if i<2: s.line(ox+0.32,cy-0.04,ow-0.64,0,DV_HAIR,0.5)
    # ---- ZONE C: IMPACT (purple) 2x2 grid ----
    ix,iw=12.95,6.22
    s.rect(ix,top,iw,H,fill=IMP_G,radius=0.12)
    s.text(ix+0.4,top+0.36,iw-0.8,0.3,[R("IMPACT",13,C['white'],"mono",bold=True,spc=2.0)],align="l")
    s.line(ix+0.4,top+0.86,iw-0.8,0,PUR_HAIR,0.75)
    mets=[("1 : 58","Return on investment","On $15.5M committed savings, 2026"),
          ("$265K","Annual platform cost","Fully-loaded run cost for 2026"),
          ("$8M","Hard savings in 2025","Delivered, banked, audited"),
          ("~3%","FTE efficiency gain","Year on year, plus negotiation uplift")]
    gx=ix+0.4; gy=top+1.15; gw=(iw-0.8-0.3)/2; gh=(H-1.25-0.0)/2
    for i,(big,lab,sub) in enumerate(mets):
        r,c2=divmod(i,2)
        x=gx+c2*(gw+0.3); y=gy+r*gh
        s.text(x,y,gw,0.85,[R(big,46,C['white'],"mont-med")],align="l",valign="t")
        s.text(x,y+0.92,gw,0.4,[R(lab,15.5,C['white'],"mont-semi")],align="l",ls=1.0)
        s.text(x,y+1.32,gw,0.6,[R(sub,11.5,PUR_L,"mont")],align="l",ls=1.12)
        if r==0: s.line(x,y+gh-0.18,gw,0,PUR_HAIR,0.5)
    footer(s)
    return s

# ============ SLIDE 3 — 5-AGENT CAPABILITY MAP ============
def slide_agents():
    s=Slide()
    s.rect(0,0,20,11.25,fill=C['bg'])
    header(s,"HOW IT WORKS · THE AGENTIC ENGINE","03")
    section(s,"02","CAPABILITY MAP",
        [R("Five ",40,C['ink'],"mont"),R("Aerchain agents",40,C['purple'],"mont"),R(", running the sourcing cycle.",40,C['ink'],"mont")],
        "Each agent runs autonomously inside its station of the procure-to-pay flow, with human-in-the-loop guardrails per category — all live in production.")
    agents=[("01","intake","Intake","Intake & Enrichment",["Auto-ingest PRs","Clean & classify","Enrich & tag spend"]),
            ("02","sourcing","Sourcing","Multi-Agent RFQ",["Build RFQ pack","Run outreach","Extract bids"]),
            ("03","negotiation","Negotiation","AI Negotiation",["Multi-round","Price & terms","Auto-negotiate"]),
            ("04","evaluation","Evaluation","Eval + Compliance",["Score every bid","Compliance check","Rank & recommend"]),
            ("05","award","Award","Scenario + Writeback",["Build scenarios","Optimal allocation","Write back to ERP"])]
    top=3.6; cardH=5.35; cw=3.45; step=3.62; x0=0.83
    for i,(num,icon,role,cap,chips) in enumerate(agents):
        x=x0+i*step; ix=x+0.28; iw_=cw-0.56
        s.rect(x,top,cw,cardH,fill=C['white'],line=C['hair'],radius=0.1)
        s.rect(x,top,cw,0.07,fill=C['purple'])
        s.rect(ix,top+0.34,0.72,0.72,fill=PUR_L,radius=0.14)
        s.img(ix+0.16,top+0.50,0.40,0.40,A(f'icon_{icon}_purple.png'))
        s.text(ix+0.9,top+0.34,iw_-0.9,0.72,[R("AGENT "+num,11,C['purple'],"mono",bold=True,spc=1.0)],align="l",valign="m")
        s.text(ix,top+1.3,iw_,0.55,[R(role,25,C['ink'],"mont-med")],align="l")
        s.text(ix,top+2.0,iw_,0.4,[R(cap,14,C['purple'],"mont-med")],align="l")
        py=top+2.62
        for ch in chips:
            pill(s,ix,py,iw_,0.48,ch,size=13.5)
            py+=0.6
        pill(s,ix,top+4.62,iw_,0.46,"✓  LIVE · UNILEVER",size=11,fill=C['green_bg'],txt=C['green'],line=C['green'],font="mono",spc=0.8)
    # ---- GUARDRAILS strip ----
    gy=9.3; s.rect(0.83,gy,18.34,1.05,fill=C['white'],line=C['hair'],radius=0.1)
    s.text(1.15,gy,3.1,1.05,[[R("GUARDRAILS",13,C['purple'],"mono",bold=True,spc=1.2)],
        [R("Every step · per category",11.5,C['muted'],"mont")]],align="l",valign="m",ls=1.25,sa=3)
    guards=["Hard limits",">5% deviation","SoD matrix","Immutable audit log","Auto-blacklist","Human-in-the-loop"]
    gpx=4.5; gpw=(19.0-gpx-5*0.18)/6
    for j,g in enumerate(guards):
        pill(s,gpx+j*(gpw+0.18),gy+0.32,gpw,0.42,g,size=11.5,fill=C['bg'],txt=C['ink'],line=C['hair'],font="mont-semi")
    footer(s)
    return s

# ============ SLIDE 4 — BUSINESS CASE ============
def slide_case():
    s=Slide()
    s.rect(0,0,20,11.25,fill=C['bg'])
    header(s,"THE BUSINESS CASE","04")
    section(s,"03","VALUE & RETURN",
        [R("A ",40,C['ink'],"mont"),R("1 : 58 return",40,C['purple'],"mont"),R(" — and it is already banked.",40,C['ink'],"mont")],
        "The numbers behind the deployment: addressable spend, committed savings, run cost, and the rollout path from here.")
    top=3.6
    # LEFT: stat grid (2x3)
    gx,gw=0.83,9.0; gy=top
    stats=[("$54M","Addressable spend","Across 37 active sourcing projects"),
           ("10%","Average yield","Realised savings rate per project"),
           ("$5M","Savings unlocked","Across projects at various stages"),
           ("$15.5M","Committed savings · 2026","Target the platform is underwriting"),
           ("$265K","Annual platform cost","Fully-loaded run cost for 2026"),
           ("1 : 58","Return on investment","Every $1 returns $58 in 2026")]
    cw=(gw-0.4)/2; chh=2.16
    for i,(big,lab,sub) in enumerate(stats):
        r,c2=divmod(i,2)
        x=gx+c2*(cw+0.4); y=gy+r*(chh+0.14)
        s.rect(x,y,cw,chh,fill=C['white'],line=C['hair'],radius=0.1)
        s.rect(x,y,0.07,chh,fill=C['purple'])
        s.text(x+0.32,y+0.30,cw-0.5,0.85,[R(big,42,C['purple'],"mont-med")],align="l",valign="t")
        s.text(x+0.32,y+1.20,cw-0.5,0.4,[R(lab,15,C['ink'],"mont-semi")],align="l")
        s.text(x+0.32,y+1.58,cw-0.5,0.5,[R(sub,12,C['muted'],"mont")],align="l",ls=1.1)
    # RIGHT: savings momentum + rollout
    rx,rw=10.2,8.97
    # momentum panel
    mp_h=3.05
    s.rect(rx,top,rw,mp_h,fill=C['white'],line=C['hair'],radius=0.12)
    s.text(rx+0.45,top+0.34,rw-0.9,0.3,[R("SAVINGS MOMENTUM",12,C['purple'],"mono",bold=True,spc=1.2)],align="l")
    baseY=top+mp_h-0.55; maxH=1.5; maxV=15.5
    bars=[("2025","delivered",8.0,grad("C4A8F7","A78BFA",180)),("2026","committed",15.5,grad("8B5CF6","6D28D9",180))]
    bx=rx+0.75; bw=1.55
    for i,(yr,lab,val,col) in enumerate(bars):
        h=maxH*val/maxV; x=bx+i*2.55
        s.rect(x,baseY-h,bw,h,fill=col,radius=0.04)
        s.text(x-0.35,baseY-h-0.5,bw+0.7,0.45,[R(("$%g"%val)+"M",20,C['purple'],"mont-semi")],align="c")
        s.text(x-0.35,baseY+0.06,bw+0.7,0.28,[R(yr,13,C['ink'],"mont-semi")],align="c")
        s.text(x-0.35,baseY+0.34,bw+0.7,0.25,[R(lab,11,C['muted'],"mont")],align="c")
    s.line(bx-0.2,baseY,5.5,0,C['hair'],0.75)
    s.text(rx+5.75,top+0.95,rw-6.1,1.9,[
        [R("≈2×",36,C['purple'],"mont-med")],
        [R("growth in committed savings, 2025 → 2026",13,C['body'],"mont")]],align="l",valign="t",ls=1.18)
    # rollout roadmap panel (teal gradient)
    ry=top+mp_h+0.3; rp_h=3.0
    s.rect(rx,ry,rw,rp_h,fill=grad("2E1065","4C1D95",140),radius=0.12)
    s.text(rx+0.45,ry+0.34,rw-0.9,0.3,[R("ROLLOUT ROADMAP",12,DV_L,"mono",bold=True,spc=1.2)],align="l")
    steps=[("NOW","Business Services","Live in production"),
           ("NEXT","Marketing & IT","Infosys-managed spend"),
           ("THEN","Enterprise-wide","Scaling beyond")]
    sw=(rw-0.9-0.6)/3; sx=rx+0.45; sy=ry+0.95
    for i,(tag,t,d) in enumerate(steps):
        x=sx+i*(sw+0.3)
        s.rect(x,sy,sw,1.7,fill="3B1A6B",radius=0.08)
        s.text(x+0.28,sy+0.26,sw-0.56,0.25,[R(tag,10.5,DV_L,"mono",bold=True,spc=1.2)],align="l")
        s.text(x+0.28,sy+0.6,sw-0.56,0.55,[R(t,17,C['white'],"mont-med")],align="l",ls=1.0)
        s.text(x+0.28,sy+1.18,sw-0.56,0.4,[R(d,12,DV_L,"mont")],align="l",ls=1.05)
        if i<2:
            s.text(x+sw-0.02,sy+0.5,0.34,0.7,[R("→",20,C['white'],"mont")],align="c",valign="m")
    footer(s)
    return s

SLIDES=[slide_title(),slide_hero(),slide_agents(),slide_case()]

if __name__=="__main__":
    import sys
    if "png" in sys.argv:
        render_png(SLIDES,"/tmp/deck_preview.html","/tmp/deck",scale=1.0)
        print("png done")
    render_pptx(SLIDES,os.path.join(os.path.dirname(__file__),"Unilever_Aerchain_Infosys_Deck.pptx"))
    print("pptx done")
