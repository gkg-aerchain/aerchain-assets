import os
from deck_lib import Slide, R, C, ASSETS, render_pptx, render_png

A=lambda n: os.path.join(ASSETS,n)
PAGES="04"

def header(sl, eyebrow, page):
    sl.rect(0,0,20,1.0,fill=C['white'])
    sl.line(0,1.0,20,0,C['hair'],0.75)
    # left lockup: Aerchain + x + Infosys
    sl.img(0.83,0.30,2.78,0.40,A('aerchain_dark.png'))
    sl.text(3.78,0,0.5,1.0,[R("×",18,C['muted'],"mono")],align="c",valign="m")
    sl.img(4.35,0.35,1.05,0.31,A('infosys_blue.png'))
    sl.line(5.82,0.35,0,0.30,C['hair'],0.75)
    sl.text(6.03,0,9.0,1.0,[R(eyebrow,11,C['muted'],"mono",bold=True,spc=1.2)],align="l",valign="m")
    # right: Unilever + page
    sl.text(16.5,0,1.7,1.0,[[R(page,12,C['ink'],"mono",bold=True),R(" / "+PAGES,12,C['muted'],"mono",bold=True)]],align="r",valign="m")
    sl.img(18.55,0.27,0.45,0.50,A('unilever_blue.png'))

def footer(sl):
    sl.rect(0,10.83,20,0.42,fill=C['white'])
    sl.line(0,10.83,20,0,C['hair'],0.75)
    sl.text(0.83,10.83,12,0.42,[R("AERCHAIN × INFOSYS · AUTONOMOUS SOURCING",8,C['muted'],"mono",bold=True,spc=0.8)],align="l",valign="m")
    sl.text(7.17,10.83,12,0.42,[R("CONFIDENTIAL · PREPARED FOR UNILEVER",8,C['muted'],"mono",bold=True,spc=0.8)],align="r",valign="m")

def section(sl, num, kicker, title_runs, sub):
    sl.rect(0.83,1.29,0.44,0.44,fill=C['purple'])
    sl.text(0.83,1.29,0.44,0.44,[R(num,12,C['white'],"mono",bold=True)],align="c",valign="m")
    sl.text(1.45,1.29,12,0.44,[R(kicker,11,C['purple'],"mono",bold=True,spc=1.2)],align="l",valign="m")
    sl.text(0.83,1.78,18.34,0.7,[title_runs],align="l",valign="t")
    sl.text(0.83,2.5,17.6,0.6,[R(sub,13,C['body'],"mont")],align="l",valign="t",ls=1.15)
    sl.line(0.83,3.22,18.34,0,C['hair'],0.75)

# ============ SLIDE 1 — TITLE ============
def slide_title():
    s=Slide()
    s.rect(0,0.42,20,10.83,fill=C['purple'])
    s.rect(0,0,20,1.0,fill=C['white'])
    s.line(0,1.0,20,0,C['hair'],0.75)
    s.img(0.83,0.30,2.78,0.40,A('aerchain_dark.png'))
    s.text(3.78,0,0.5,1.0,[R("×",18,C['muted'],"mono")],align="c",valign="m")
    s.img(4.35,0.35,1.05,0.31,A('infosys_blue.png'))
    s.text(6.03,0,9,1.0,[R("EXECUTIVE BRIEFING · 2026",11,C['muted'],"mono",bold=True,spc=1.2)],align="l",valign="m")
    s.text(16.5,0,1.7,1.0,[[R("01",12,C['ink'],"mono",bold=True),R(" / "+PAGES,12,C['muted'],"mono",bold=True)]],align="r",valign="m")
    s.img(18.55,0.27,0.45,0.50,A('unilever_blue.png'))
    # kicker
    s.text(1.0,1.95,16,0.3,[[R("──── ",13,C['purple_l2'],"mono",bold=True),
        R("AERCHAIN × INFOSYS · DEPLOYED AT UNILEVER",13,C['purple_l'],"mono",bold=True,spc=1.2)]],align="l",valign="m")
    # big title
    s.text(0.97,2.55,18.4,4.2,[
        [R("Autonomous Agentic",78,C['white'],"mont-med")],
        [R("Sourcing",78,C['white'],"mont-med")],
        [R("for Unilever",66,C['white'],"mont-light")],
    ],align="l",valign="t",ls=1.02)
    # one-line value
    s.text(1.0,7.35,15.5,0.9,[R("Infosys deploys Aerchain's autonomous-sourcing layer across Unilever — turning classical, manual sourcing into AI-driven, agent-run sourcing that is live and already delivering hard savings.",16,C['purple_l'],"mont-light")],align="l",valign="t",ls=1.22)
    # stat row
    s.line(1.0,8.55,18.0,0,C['purple_l2'],0.75)
    stats=[("$5M","Savings unlocked across 37 sourcing projects"),
           ("1 : 58","Return on every dollar invested in 2026"),
           ("$8M","Hard savings already delivered in 2025"),
           ("Live","In production today for Business Services")]
    for i,(big,lab) in enumerate(stats):
        x=1.0+i*4.5
        s.text(x,8.85,4.2,0.78,[R(big,44,C['white'],"mont")],align="l",valign="t")
        s.text(x,9.62,4.2,0.62,[R(lab,12,C['purple_l'],"mont")],align="l",valign="t",ls=1.1)
    # footer
    s.rect(0,10.83,20,0.42,fill=C['white'])
    s.line(0,10.83,20,0,C['hair'],0.75)
    s.text(0.83,10.83,12,0.42,[R("AERCHAIN · AGENTIC PROCUREMENT PLATFORM",8,C['muted'],"mono",bold=True,spc=0.8)],align="l",valign="m")
    s.text(7.17,10.83,12,0.42,[R("CONFIDENTIAL · PREPARED FOR UNILEVER · VIA INFOSYS",8,C['muted'],"mono",bold=True,spc=0.8)],align="r",valign="m")
    return s

# ============ SLIDE 2 — THE ONE-SLIDER ============
def slide_hero():
    s=Slide()
    s.rect(0,0,20,11.25,fill=C['bg'])
    header(s,"AERCHAIN-AUTONOMOUS SOURCING","02")
    section(s,"01","UNILEVER × INFOSYS × AERCHAIN",
        [R("From classical sourcing to ",36,C['ink'],"mont"),R("autonomous sourcing",36,C['purple'],"mont"),R(".",36,C['ink'],"mont")],
        "What changed when Infosys deployed Aerchain's autonomous-sourcing layer at Unilever — and the value it is already delivering.")
    top=3.5; bot=10.4; H=bot-top
    # ---- ZONE A: BEFORE / NOW ----
    # BEFORE card
    bx,bw=0.83,3.95
    s.rect(bx,top,bw,H,fill=C['white'],line=C['hair'],radius=0.1)
    s.rect(bx,top,bw,0.06,fill=C['muted'])
    s.text(bx+0.25,top+0.30,bw-0.5,0.2,[R("BEFORE",10,C['muted'],"mono",bold=True,spc=1.5)],align="l")
    s.text(bx+0.25,top+0.55,bw-0.5,0.5,[R("Unilever, classical sourcing",15,C['ink'],"mont-med")],align="l",ls=1.05)
    before=["Classical, manual sourcing","Heavy Excel dependency","Time & resource constraints",
            "Gaps in category expertise","Limited negotiation leverage","Reliance on past data & benchmarks"]
    iy=top+1.35
    for it in before:
        s.text(bx+0.25,iy,0.3,0.4,[R("✕",11,C['muted'],"mont-semi")],align="l")
        s.text(bx+0.6,iy-0.02,bw-0.82,0.55,[R(it,12.5,C['body'],"mont")],align="l",ls=1.05)
        iy+=0.78
    # NOW card
    nx,nw=4.95,4.15
    s.rect(nx,top,nw,H,fill=C['white'],line=C['hair'],radius=0.1)
    s.rect(nx,top,nw,0.06,fill=C['purple'])
    s.text(nx+0.25,top+0.30,nw-0.5,0.2,[R("NOW · WITH INFOSYS-AERCHAIN",10,C['purple'],"mono",bold=True,spc=1.2)],align="l")
    s.text(nx+0.25,top+0.55,nw-0.5,0.5,[R("Autonomous, agent-run sourcing",15,C['ink'],"mont-med")],align="l",ls=1.05)
    now=["AI-driven, time-saving sourcing","Automated quotes, RFx & questionnaires","Intelligent supplier ranking",
         "Automated comms with live tracking","AI-powered insights & query support","Improved negotiation & faster value"]
    iy=top+1.35
    for it in now:
        s.text(nx+0.25,iy,0.3,0.4,[R("✓",12,C['purple'],"mont-bold")],align="l")
        s.text(nx+0.62,iy-0.02,nw-0.84,0.55,[R(it,12.5,C['ink'],"mont")],align="l",ls=1.05)
        iy+=0.78
    # ---- ZONE B: OUTCOME (navy) ----
    ox,ow=9.4,3.9
    s.rect(ox,top,ow,H,fill=C['navy'],radius=0.1)
    s.text(ox+0.3,top+0.32,ow-0.6,0.3,[R("OUTCOME",12,C['white'],"mono",bold=True,spc=2.0)],align="l")
    s.line(ox+0.3,top+0.78,ow-0.6,0,"3A3F57",0.75)
    cards=[("$5M","Savings on a $54M spend across 37 sourcing projects — average yield 10%"),
           ("Live","In production today for Unilever Business Services"),
           ("Scaling","Across Marketing & IT for Infosys-managed spend, and beyond")]
    cy=top+1.05; chh=(H-1.25)/3
    for big,desc in cards:
        s.text(ox+0.3,cy+0.12,ow-0.6,0.85,[R(big,40,C['white'],"mont")],align="l")
        s.text(ox+0.3,cy+0.95,ow-0.6,1.0,[R(desc,11.5,C['purple_l'],"mont")],align="l",ls=1.18)
        cy+=chh
        if big!="Scaling": s.line(ox+0.3,cy-0.06,ow-0.6,0,"3A3F57",0.5)
    # ---- ZONE C: IMPACT (purple) ----
    ix,iw=13.6,5.57
    s.rect(ix,top,iw,H,fill=C['purple'],radius=0.1)
    s.text(ix+0.35,top+0.32,iw-0.7,0.3,[R("IMPACT",12,C['white'],"mono",bold=True,spc=2.0)],align="l")
    s.line(ix+0.35,top+0.78,iw-0.7,0,C['purple_l2'],0.75)
    mets=[("1 : 58","Return on investment","On $15.5M committed savings in 2026"),
          ("$265K","Annual cost of the platform","Fully-loaded run cost for 2026"),
          ("$8M","Hard savings in 2025","Delivered, banked, audited"),
          ("~3%","FTE efficiency gain, year on year","Plus improved negotiation efficiency")]
    my=top+1.05; mhh=(H-1.25)/4
    for big,lab,sub in mets:
        s.text(ix+0.35,my+0.05,2.3,0.7,[R(big,34,C['white'],"mont-med")],align="l",valign="m")
        s.text(ix+2.75,my-0.02,iw-3.1,0.42,[R(lab,13.5,C['white'],"mont-med")],align="l",valign="b",ls=1.0)
        s.text(ix+2.75,my+0.42,iw-3.1,0.4,[R(sub,10.5,C['purple_l'],"mont")],align="l",valign="t",ls=1.05)
        my+=mhh
        if sub!=mets[-1][2]: s.line(ix+0.35,my-0.08,iw-0.7,0,C['purple_l2'],0.5)
    footer(s)
    return s

# ============ SLIDE 3 — 5-AGENT CAPABILITY MAP ============
def slide_agents():
    s=Slide()
    s.rect(0,0,20,11.25,fill=C['bg'])
    header(s,"HOW IT WORKS · THE AGENTIC ENGINE","03")
    section(s,"02","CAPABILITY MAP",
        [R("Five ",36,C['ink'],"mont"),R("Aerchain agents",36,C['purple'],"mont"),R(", running the sourcing cycle.",36,C['ink'],"mont")],
        "Each agent runs autonomously inside its station of the procure-to-pay flow, with human-in-the-loop guardrails configurable per category — all live in production.")
    agents=[("01","Intake Agent","Auto-ingests requests, cleans maverick descriptions, classifies & enriches.",
             "Intake & Enrichment","5 parallel sub-agents auto-tag GL, cost centre and taxonomy, and generate clarifying questions before the cycle starts."),
            ("02","Sourcing Agent","Scouts the market and runs outreach across the existing supplier base.",
             "Multi-Agent RFQ","Auto-builds SOW, scope and T&Cs, then runs outreach, follow-up, query clarification and bid extraction autonomously."),
            ("03","Negotiation Agent","Multi-parameter, asynchronous negotiations across price, terms & lead time.",
             "AI Negotiation","Multi-round, configurable-autonomy negotiations with price loading and total-cost normalisation across regions."),
            ("04","Evaluation Agent","Scores every bid; runs compliance and risk checks silently in the background.",
             "Eval + Compliance","Configurable scoring matrix per category. Compliance runs as a subroutine — single decision surface, single audit entry."),
            ("05","Award Agent","Generates award scenarios and recommends the optimal allocation.",
             "Scenario + Writeback","Constraint-aware allocation factors landed cost, capacity and terms; the approved award writes back to the ERP of record.")]
    top=3.5; cardH=6.15; cw=3.45; step=3.62; x0=0.83
    for i,(num,title,desc,cap,brief) in enumerate(agents):
        x=x0+i*step
        s.rect(x,top,cw,cardH,fill=C['white'],line=C['hair'],radius=0.08)
        s.rect(x,top,cw,0.06,fill=C['purple'])
        s.text(x+0.22,top+0.28,cw-0.44,0.2,[R("AGENT "+num,10,C['purple'],"mono",bold=True,spc=1.0)],align="l")
        s.text(x+0.22,top+0.52,cw-0.44,0.45,[R(title,17,C['ink'],"mont-med")],align="l")
        s.text(x+0.22,top+1.05,cw-0.44,1.15,[R(desc,11,C['muted'],"mont")],align="l",ls=1.18)
        s.line(x+0.22,top+2.35,cw-0.44,0,C['hair'],0.75)
        s.text(x+0.22,top+2.5,cw-0.44,0.18,[R("↓ AERCHAIN CAPABILITY",9,C['muted'],"mono",bold=True,spc=0.6)],align="l")
        s.text(x+0.22,top+2.75,cw-0.44,0.6,[R(cap,13,C['purple'],"mont-med")],align="l",ls=1.05)
        s.text(x+0.22,top+3.45,cw-0.44,1.9,[R(brief,10.5,C['body'],"mont")],align="l",ls=1.22)
        s.rect(x+0.22,top+5.45,cw-0.44,0.32,fill=C['green_bg'],line=C['green'],lw=0.75,radius=0.04)
        s.text(x+0.22,top+5.45,cw-0.44,0.32,[R("✓  LIVE · UNILEVER",9.5,C['green'],"mono",bold=True,spc=0.8)],align="c",valign="m")
    # bottom note
    s.text(0.83,9.95,18.34,0.5,[[R("Delivery posture.  ",13,C['ink'],"mont-semi"),
        R("All five agents are in production today across Aerchain customers — Intake, Sourcing, Negotiation, Evaluation and Award — orchestrated end-to-end, with the ERP kept as the system of record.",13,C['body'],"mont")]],align="l",valign="t",ls=1.2)
    footer(s)
    return s

# ============ SLIDE 4 — BUSINESS CASE ============
def slide_case():
    s=Slide()
    s.rect(0,0,20,11.25,fill=C['bg'])
    header(s,"THE BUSINESS CASE","04")
    section(s,"03","VALUE & RETURN",
        [R("A ",36,C['ink'],"mont"),R("1 : 58 return",36,C['purple'],"mont"),R(" — and it is already banked.",36,C['ink'],"mont")],
        "The numbers behind the deployment: addressable spend, committed savings, run cost, and the rollout path from here.")
    top=3.5
    # LEFT: stat grid (2x3)
    gx,gw=0.83,9.0; gy=top
    stats=[("$54M","Addressable spend","Across 37 active sourcing projects"),
           ("10%","Average yield","Realised savings rate per project"),
           ("$5M","Savings unlocked","Across projects at various stages"),
           ("$15.5M","Committed savings · 2026","Target the platform is underwriting"),
           ("$265K","Annual platform cost","Fully-loaded run cost for 2026"),
           ("1 : 58","Return on investment","Every $1 returns $58 in 2026")]
    cw=(gw-0.4)/2; chh=2.18
    for i,(big,lab,sub) in enumerate(stats):
        r,c=divmod(i,2)
        x=gx+c*(cw+0.4); y=gy+r*(chh+0.12)
        s.rect(x,y,cw,chh,fill=C['white'],line=C['hair'],radius=0.08)
        s.rect(x,y,0.06,chh,fill=C['purple'])
        s.text(x+0.3,y+0.28,cw-0.5,0.85,[R(big,40,C['ink'],"mont-med")],align="l",valign="t")
        s.text(x+0.3,y+1.15,cw-0.5,0.4,[R(lab,14,C['ink'],"mont-semi")],align="l")
        s.text(x+0.3,y+1.55,cw-0.5,0.5,[R(sub,11,C['muted'],"mont")],align="l",ls=1.1)
    # RIGHT: savings momentum + rollout
    rx,rw=10.2,8.97
    # momentum panel
    s.rect(rx,top,rw,3.0,fill=C['white'],line=C['hair'],radius=0.1)
    s.text(rx+0.4,top+0.32,rw-0.8,0.3,[R("SAVINGS MOMENTUM",11,C['purple'],"mono",bold=True,spc=1.2)],align="l")
    # two bars: 2025 $8M delivered, 2026 $15.5M committed
    baseY=top+2.55; maxH=1.55; maxV=15.5
    bars=[("2025","$8M delivered",8.0,C['purple_l2']),("2026","$15.5M committed",15.5,C['purple'])]
    bx=rx+0.6; bw=1.5
    for i,(yr,lab,val,col) in enumerate(bars):
        h=maxH*val/maxV; x=bx+i*2.6
        s.rect(x,baseY-h,bw,h,fill=col,radius=0.03)
        s.text(x-0.3,baseY-h-0.42,bw+0.6,0.4,[R(("$%g"%val)+"M",18,C['ink'],"mont-med")],align="c")
        s.text(x-0.3,baseY+0.05,bw+0.6,0.25,[R(yr,12,C['ink'],"mont-semi")],align="c")
        s.text(x-0.3,baseY+0.32,bw+0.6,0.25,[R(lab,10,C['muted'],"mont")],align="c")
    s.line(bx-0.15,baseY,5.4,0,C['hair'],0.75)
    # callout on right of bars
    s.text(rx+5.9,top+1.0,rw-6.2,1.8,[
        [R("≈2×",30,C['purple'],"mont-med")],
        [R("growth in committed savings, 2025 → 2026",12,C['body'],"mont")]],align="l",valign="t",ls=1.15)
    # rollout roadmap panel
    ry=top+3.25
    s.rect(rx,ry,rw,3.4,fill=C['navy'],radius=0.1)
    s.text(rx+0.4,ry+0.32,rw-0.8,0.3,[R("ROLLOUT ROADMAP",11,C['purple_l'],"mono",bold=True,spc=1.2)],align="l")
    steps=[("NOW","Business Services","Live in production"),
           ("NEXT","Marketing & IT","Infosys-managed spend"),
           ("THEN","Enterprise-wide","Scaling beyond")]
    sw=(rw-0.8-0.6)/3; sx=rx+0.4; sy=ry+0.95
    for i,(tag,t,d) in enumerate(steps):
        x=sx+i*(sw+0.3)
        s.rect(x,sy,sw,1.9,fill="20243B",radius=0.06)
        s.text(x+0.25,sy+0.25,sw-0.5,0.25,[R(tag,10,C['purple_l2'],"mono",bold=True,spc=1.2)],align="l")
        s.text(x+0.25,sy+0.62,sw-0.5,0.55,[R(t,16,C['white'],"mont-med")],align="l",ls=1.0)
        s.text(x+0.25,sy+1.28,sw-0.5,0.5,[R(d,11,C['purple_l'],"mont")],align="l",ls=1.1)
        if i<2:
            s.text(x+sw-0.02,sy+0.6,0.34,0.7,[R("→",18,C['purple_l2'],"mont")],align="c",valign="m")
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
