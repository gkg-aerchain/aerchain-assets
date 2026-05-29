import os
from deck_lib import Slide, R, C, ASSETS, grad, render_pptx, render_png

A=lambda n: os.path.join(ASSETS,n)
PAGES="04"

# extra brand colours
TEAL0="0F766E"; TEAL1="13B5A6"; TEAL_L="CCFBF1"; TEAL_HAIR="3FBFB0"
PUR0="6D28D9"; PUR1="9333EA"; PUR_L="ECE3FF"; PUR_HAIR="B98DF0"
TITLE_G=grad("7C3AED","6D28D9",135)
OUT_G=grad(TEAL0,TEAL1,140)
IMP_G=grad(PUR0,PUR1,140)

def header(sl, eyebrow, page):
    sl.rect(0,0,20,1.05,fill=C['white'])
    sl.line(0,1.05,20,0,C['hair'],0.75)
    sl.img(0.83,0.32,2.78,0.40,A('aerchain_dark.png'))
    sl.text(3.78,0,0.5,1.05,[R("×",18,C['muted'],"mono")],align="c",valign="m")
    sl.img(4.35,0.37,0.82,0.32,A('infosys_blue.png'))
    sl.line(5.55,0.37,0,0.31,C['hair'],0.75)
    sl.text(5.78,0,9.5,1.05,[R(eyebrow,12,C['muted'],"mono",bold=True,spc=1.2)],align="l",valign="m")
    sl.text(16.4,0,1.8,1.05,[[R(page,13,C['ink'],"mono",bold=True),R(" / "+PAGES,13,C['muted'],"mono",bold=True)]],align="r",valign="m")
    sl.img(18.5,0.28,0.5,0.52,A('unilever_blue.png'))

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
    s.rect(0,0,20,1.05,fill=C['white'])
    s.line(0,1.05,20,0,C['hair'],0.75)
    s.img(0.83,0.32,2.78,0.40,A('aerchain_dark.png'))
    s.text(3.78,0,0.5,1.05,[R("×",18,C['muted'],"mono")],align="c",valign="m")
    s.img(4.35,0.37,0.82,0.32,A('infosys_blue.png'))
    s.text(5.78,0,9,1.05,[R("EXECUTIVE BRIEFING · 2026",12,C['muted'],"mono",bold=True,spc=1.2)],align="l",valign="m")
    s.text(16.4,0,1.8,1.05,[[R("01",13,C['ink'],"mono",bold=True),R(" / "+PAGES,13,C['muted'],"mono",bold=True)]],align="r",valign="m")
    s.img(18.5,0.28,0.5,0.52,A('unilever_blue.png'))
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
    s.line(ox+0.32,top+0.86,ow-0.64,0,TEAL_HAIR,0.75)
    cards=[("$5M","Savings on a $54M spend across 37 sourcing projects — 10% average yield"),
           ("Live","In production today for Unilever Business Services"),
           ("Scaling","Across Marketing & IT for Infosys-managed spend, and beyond")]
    cy=top+1.08; chh=(H-1.2)/3
    for i,(big,desc) in enumerate(cards):
        s.text(ox+0.32,cy+0.10,ow-0.64,0.85,[R(big,46,C['white'],"mont")],align="l")
        s.text(ox+0.32,cy+1.0,ow-0.64,1.0,[R(desc,13,TEAL_L,"mont")],align="l",ls=1.22)
        cy+=chh
        if i<2: s.line(ox+0.32,cy-0.04,ow-0.64,0,TEAL_HAIR,0.5)
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
    agents=[("01","intake","Intake Agent","Auto-ingests requests, cleans maverick descriptions, classifies & enriches spend.",
             "Intake & Enrichment","Parallel sub-agents auto-tag GL, cost centre and taxonomy, and raise clarifying questions before the cycle starts."),
            ("02","sourcing","Sourcing Agent","Scouts the market and runs outreach across the existing supplier base.",
             "Multi-Agent RFQ","Auto-builds SOW, scope and T&Cs, then runs outreach, follow-up, query clarification and bid extraction autonomously."),
            ("03","negotiation","Negotiation Agent","Multi-parameter, asynchronous negotiation across price, terms & lead time.",
             "AI Negotiation","Multi-round, configurable-autonomy negotiations with price loading and total-cost normalisation across regions."),
            ("04","evaluation","Evaluation Agent","Scores every bid; runs compliance and risk checks silently in the background.",
             "Eval + Compliance","Configurable scoring per category. Compliance runs as a subroutine — single decision surface, single audit entry."),
            ("05","award","Award Agent","Generates award scenarios and recommends the optimal allocation.",
             "Scenario + Writeback","Constraint-aware allocation factors landed cost, capacity and terms; the approved award writes back to the ERP of record.")]
    top=3.55; cardH=6.35; cw=3.45; step=3.62; x0=0.83
    for i,(num,icon,title,desc,cap,brief) in enumerate(agents):
        x=x0+i*step
        s.rect(x,top,cw,cardH,fill=C['white'],line=C['hair'],radius=0.1)
        s.rect(x,top,cw,0.07,fill=C['purple'])
        # icon badge
        s.rect(x+0.24,top+0.32,0.66,0.66,fill=PUR_L,radius=0.12)
        s.img(x+0.37,top+0.45,0.40,0.40,A(f'icon_{icon}_purple.png'))
        s.text(x+1.02,top+0.34,cw-1.24,0.62,[R("AGENT "+num,11,C['purple'],"mono",bold=True,spc=1.0)],align="l",valign="m")
        s.text(x+0.24,top+1.15,cw-0.48,0.5,[R(title,20,C['ink'],"mont-med")],align="l")
        s.text(x+0.24,top+1.72,cw-0.48,1.2,[R(desc,13,C['muted'],"mont")],align="l",ls=1.2)
        s.line(x+0.24,top+3.05,cw-0.48,0,C['hair'],0.75)
        s.text(x+0.24,top+3.22,cw-0.48,0.2,[R("↓ AERCHAIN CAPABILITY",9.5,C['muted'],"mono",bold=True,spc=0.6)],align="l")
        s.text(x+0.24,top+3.5,cw-0.48,0.6,[R(cap,15,C['purple'],"mont-med")],align="l",ls=1.05)
        s.text(x+0.24,top+4.22,cw-0.48,1.5,[R(brief,12,C['body'],"mont")],align="l",ls=1.22)
        s.rect(x+0.24,top+5.78,cw-0.48,0.36,fill=C['green_bg'],line=C['green'],lw=0.75,radius=0.05)
        s.text(x+0.24,top+5.78,cw-0.48,0.36,[R("✓  LIVE · UNILEVER",11,C['green'],"mono",bold=True,spc=0.8)],align="c",valign="m")
    s.text(0.83,10.15,18.34,0.5,[[R("Delivery posture.  ",14.5,C['ink'],"mont-semi"),
        R("All five agents are in production today — Intake, Sourcing, Negotiation, Evaluation and Award — orchestrated end-to-end, with the ERP kept as the system of record.",14.5,C['body'],"mont")]],align="l",valign="t",ls=1.2)
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
    s.rect(rx,ry,rw,rp_h,fill=grad(TEAL0,TEAL1,140),radius=0.12)
    s.text(rx+0.45,ry+0.34,rw-0.9,0.3,[R("ROLLOUT ROADMAP",12,TEAL_L,"mono",bold=True,spc=1.2)],align="l")
    steps=[("NOW","Business Services","Live in production"),
           ("NEXT","Marketing & IT","Infosys-managed spend"),
           ("THEN","Enterprise-wide","Scaling beyond")]
    sw=(rw-0.9-0.6)/3; sx=rx+0.45; sy=ry+0.95
    for i,(tag,t,d) in enumerate(steps):
        x=sx+i*(sw+0.3)
        s.rect(x,sy,sw,1.7,fill="0B5B55",radius=0.08)
        s.text(x+0.28,sy+0.26,sw-0.56,0.25,[R(tag,10.5,TEAL_L,"mono",bold=True,spc=1.2)],align="l")
        s.text(x+0.28,sy+0.6,sw-0.56,0.55,[R(t,17,C['white'],"mont-med")],align="l",ls=1.0)
        s.text(x+0.28,sy+1.18,sw-0.56,0.4,[R(d,12,TEAL_L,"mont")],align="l",ls=1.05)
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
