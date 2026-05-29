# -*- coding: utf-8 -*-
"""Vertical one-pager (HTML -> PDF/PNG) in the Unilever reference style,
populated with the Willem-slide content + Aerchain capabilities."""
import os, math
HERE=os.path.dirname(os.path.abspath(__file__)); A=os.path.join(HERE,"assets")
def f(n): return "file://"+os.path.join(A,n)

PURPLE="#7C3AED"; PURPLE_D="#5B21B6"; INK="#1B1F26"; BODY="#484E59"; MUTED="#6A707B"
HAIR="#E9EBF0"; PURPLE_L="#E0CFFA"; GREEN="#16A34A"

def donut(pct, big, label, color="#FBBF24"):
    r=52; c=2*math.pi*r; off=c*(1-pct/100)
    return f"""
    <div class="donut">
      <svg width="130" height="130" viewBox="0 0 130 130">
        <circle cx="65" cy="65" r="{r}" fill="none" stroke="rgba(255,255,255,.18)" stroke-width="11"/>
        <circle cx="65" cy="65" r="{r}" fill="none" stroke="{color}" stroke-width="11"
          stroke-linecap="round" stroke-dasharray="{c:.1f}" stroke-dashoffset="{off:.1f}"
          transform="rotate(-90 65 65)"/>
        <text x="65" y="72" text-anchor="middle" class="dnum">{big}</text>
      </svg>
      <div class="dlabel">{label}</div>
    </div>"""

def bars():
    # 2025 $8M delivered, 2026 $15.5M committed  ; max 16
    data=[("2025","$8M","delivered",8.0,"#C4A8F7"),("2026","$15.5M","committed",15.5,PURPLE)]
    mx=16.0; H=240
    out='<div class="bars">'
    for yr,v,sub,val,col in data:
        h=H*val/mx
        out+=f"""<div class="barcol">
          <div class="barval">{v}</div>
          <div class="bar" style="height:{h:.0f}px;background:{col};"></div>
          <div class="baryr">{yr}</div><div class="barsub">{sub}</div>
        </div>"""
    out+='</div>'
    return out

BEFORE=["Classical, manual sourcing","Heavy Excel dependency","Time &amp; resource constraints",
        "Gaps in category expertise","Limited negotiation leverage","Reliance on past data &amp; benchmarks"]
NOW=["AI-driven, time-saving sourcing","Automated quotes, RFx &amp; questionnaires","Intelligent supplier ranking",
     "Automated communication with live tracking","AI-powered insights &amp; query support","Improved negotiation &amp; faster value realization"]

AGENTS=[("01","Intake","Auto-ingests &amp; enriches every request; cleans maverick descriptions and classifies spend."),
        ("02","Sourcing","Builds the RFQ, runs outreach, follow-up and bid extraction across your supplier base."),
        ("03","Negotiation","Multi-round, multi-parameter autonomous negotiation across price, terms &amp; lead time."),
        ("04","Evaluation","Scores every bid and runs compliance &amp; risk checks silently in the background."),
        ("05","Award","Generates award scenarios, recommends allocation and writes the PO back to the ERP.")]

OUTCOME=[("$5M","Savings unlocked","on a $54M spend across 37 sourcing projects &mdash; 10% average yield"),
         ("Live","In production","today for Unilever Business Services"),
         ("Scaling","Marketing &amp; IT","Infosys-managed spend, and beyond")]
IMPACT=[("1 : 58","Return on investment","on $15.5M committed savings in 2026"),
        ("$265K","Annual platform cost","fully-loaded run cost for 2026"),
        ("$8M","Hard savings in 2025","delivered, banked, audited"),
        ("~3%","FTE efficiency gain","year on year, plus negotiation uplift")]
FAQ=[("Does it integrate with our existing ERP and procurement tools?","Yes &mdash; Aerchain sits above SAP / Ariba and Coupa and keeps the ERP as the system of record."),
     ("Is it secure and compliant (SOC 2, GDPR)?","Yes. Compliance, SoD and risk checks run as a built-in subroutine on every transaction."),
     ("Do users stay in control with AI in the loop?","Always. Human-in-the-loop guardrails are configurable per category and toggle-controlled."),
     ("Can it scale beyond Business Services?","Yes &mdash; the same engine extends to Marketing, IT and Infosys-managed spend enterprise-wide."),
     ("How fast do we see value?","Business Services is already live; $8M was delivered in 2025 with $15.5M committed for 2026."),
     ("Does it replace our category teams?","No. It removes the manual load so category experts focus on strategy and supplier value.")]

def li(items, mark, cls):
    return "".join(f'<li><span class="mk {cls}">{mark}</span>{x}</li>' for x in items)

def card_row(items, val_color=INK):
    return "".join(
        f'<div class="metric"><div class="mbig">{b}</div><div class="mlab">{l}</div><div class="msub">{s}</div></div>'
        for b,l,s in items)

HTML=f"""<!doctype html><html><head><meta charset="utf-8">
<link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@500;600&display=swap" rel="stylesheet">
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
:root{{--p:{PURPLE};--ink:{INK};--body:{BODY};--muted:{MUTED}}}
body{{font-family:'Montserrat',sans-serif;color:var(--ink);width:1240px;margin:0 auto;background:#fff;-webkit-font-smoothing:antialiased}}
.mono{{font-family:'JetBrains Mono',monospace;letter-spacing:1.5px}}
section{{padding:54px 70px}}
h2{{font-size:34px;font-weight:600;letter-spacing:-.5px;margin-bottom:6px}}
h2 .pp{{color:var(--p)}}
.sub{{color:var(--muted);font-size:15px;margin-bottom:30px}}
/* HERO */
.hero{{position:relative;background:
   radial-gradient(900px 380px at 80% -10%,#efe8ff 0%,rgba(239,232,255,0) 60%),
   linear-gradient(180deg,#fbfaff 0%,#f3effc 100%);
   padding:60px 70px 70px;text-align:center;overflow:hidden}}
.hero::before{{content:"";position:absolute;inset:0;
   background-image:linear-gradient({HAIR} 1px,transparent 1px),linear-gradient(90deg,{HAIR} 1px,transparent 1px);
   background-size:46px 46px;opacity:.5}}
.hero>*{{position:relative}}
.lock{{display:flex;align-items:center;justify-content:center;gap:22px;margin-bottom:34px}}
.lock img.aer{{height:40px}} .lock img.uni{{height:54px}} .lock img.inf{{height:28px}}
.lock .div{{width:1px;height:40px;background:#cdbfe8}}
.htitle{{font-size:60px;font-weight:700;letter-spacing:-1.5px;color:var(--p);line-height:1.04}}
.hsub{{font-size:19px;color:var(--ink);margin-top:14px;font-weight:500}}
.heyebrow{{font-size:12px;color:var(--p);margin-bottom:18px;font-weight:600}}
/* PURPLE shift band */
.shift{{background:linear-gradient(135deg,{PURPLE} 0%,{PURPLE_D} 100%);color:#fff}}
.shift h2{{color:#fff}} .shift .sub{{color:{PURPLE_L}}}
.cols2{{display:grid;grid-template-columns:1fr 1fr;gap:26px}}
.panel{{background:rgba(255,255,255,.10);border:1px solid rgba(255,255,255,.18);border-radius:16px;padding:26px 28px}}
.panel.now{{background:rgba(255,255,255,.16)}}
.ptag{{font-size:12px;font-weight:700;letter-spacing:1.5px;margin-bottom:4px}}
.ptag.b{{color:{PURPLE_L}}} .ptag.n{{color:#fff}}
.ph{{font-size:19px;font-weight:600;margin-bottom:16px}}
ul{{list-style:none}} ul li{{display:flex;align-items:flex-start;gap:12px;font-size:15px;padding:9px 0;color:#fff;line-height:1.3}}
.mk{{flex:0 0 22px;height:22px;border-radius:6px;display:flex;align-items:center;justify-content:center;font-size:13px;font-weight:700;margin-top:1px}}
.mk.x{{background:rgba(255,255,255,.14);color:{PURPLE_L}}} .mk.c{{background:#fff;color:{PURPLE}}}
.shift ul li{{border-bottom:1px solid rgba(255,255,255,.10)}} .shift ul li:last-child{{border-bottom:none}}
/* metrics */
.mgrid{{display:grid;grid-template-columns:repeat(4,1fr);gap:20px}}
.metric{{border-left:3px solid var(--p);padding:6px 0 6px 18px}}
.mbig{{font-size:42px;font-weight:600;letter-spacing:-1px;line-height:1}}
.mlab{{font-size:15px;font-weight:600;margin-top:8px}}
.msub{{font-size:12.5px;color:var(--muted);margin-top:4px;line-height:1.35}}
.outwrap{{display:grid;grid-template-columns:repeat(3,1fr);gap:20px;margin-top:14px}}
.ocard{{background:#fff;border-radius:14px;padding:22px 24px;color:var(--ink)}}
.ocard .ob{{font-size:38px;font-weight:700;color:var(--p);line-height:1}}
.ocard .ol{{font-weight:600;margin-top:8px;font-size:15px}}
.ocard .os{{color:var(--muted);font-size:13px;margin-top:5px;line-height:1.4}}
/* agents */
.agrid{{display:grid;grid-template-columns:repeat(5,1fr);gap:16px}}
.acard{{border:1px solid {HAIR};border-radius:14px;padding:20px 18px;position:relative;overflow:hidden}}
.acard::before{{content:"";position:absolute;left:0;top:0;height:4px;width:100%;background:var(--p)}}
.anum{{font-size:11px;font-weight:700;color:var(--p);letter-spacing:1px;font-family:'JetBrains Mono',monospace}}
.atitle{{font-size:18px;font-weight:600;margin:6px 0 10px}}
.adesc{{font-size:12.5px;color:var(--body);line-height:1.4}}
.alive{{margin-top:14px;font-size:10.5px;font-weight:700;color:{GREEN};letter-spacing:.5px;font-family:'JetBrains Mono',monospace}}
/* value realization */
.vr{{display:grid;grid-template-columns:1.1fr 1fr;gap:40px;align-items:center}}
.bars{{display:flex;gap:60px;align-items:flex-end;height:300px;padding:0 30px;border-bottom:1px solid {HAIR}}}
.barcol{{display:flex;flex-direction:column;align-items:center;justify-content:flex-end}}
.bar{{width:130px;border-radius:8px 8px 0 0}}
.barval{{font-size:24px;font-weight:700;margin-bottom:10px}}
.baryr{{font-weight:700;margin-top:12px;font-size:16px}} .barsub{{color:var(--muted);font-size:12px}}
.vstat{{display:flex;flex-direction:column;gap:18px}}
.vrow{{display:flex;align-items:baseline;gap:16px;border-bottom:1px solid {HAIR};padding-bottom:14px}}
.vrow .n{{font-size:34px;font-weight:600;color:var(--p);min-width:120px}}
.vrow .t{{font-size:14px;color:var(--body)}}
/* rollout */
.road{{display:grid;grid-template-columns:1fr auto 1fr auto 1fr;align-items:center;gap:14px}}
.rstep{{background:#f7f5fc;border:1px solid #ede7fa;border-radius:14px;padding:22px 24px}}
.rtag{{font-size:11px;font-weight:700;color:var(--p);letter-spacing:1.5px;font-family:'JetBrains Mono',monospace}}
.rt{{font-size:19px;font-weight:600;margin:8px 0 4px}} .rd{{font-size:13px;color:var(--muted)}}
.arrow{{color:#c4a8f7;font-size:26px;font-weight:700;text-align:center}}
/* value delivery purple */
.deliver{{background:linear-gradient(135deg,{PURPLE_D} 0%,{PURPLE} 100%);color:#fff}}
.deliver h2{{color:#fff}}
.dgrid{{display:grid;grid-template-columns:repeat(4,1fr);gap:18px}}
.donut{{background:rgba(255,255,255,.10);border-radius:16px;padding:24px 10px;text-align:center}}
.dnum{{font-size:30px;font-weight:700;fill:#fff;font-family:'Montserrat'}}
.dlabel{{font-size:14px;color:#fff;margin-top:10px;font-weight:500;line-height:1.3;padding:0 6px}}
/* faq */
.fgrid{{display:grid;grid-template-columns:1fr 1fr;gap:16px}}
.fcard{{display:flex;gap:14px;background:#faf9fe;border:1px solid {HAIR};border-radius:12px;padding:18px 20px}}
.fq{{font-weight:600;font-size:14.5px;margin-bottom:5px}} .fa{{font-size:12.5px;color:var(--muted);line-height:1.45}}
.fchk{{flex:0 0 26px;height:26px;border-radius:8px;background:{GREEN};color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:15px}}
/* footer */
.foot{{background:{INK};color:#9aa0ad;padding:26px 70px;display:flex;justify-content:space-between;font-size:11px;letter-spacing:1px}}
.foot .mono{{color:#cfd3db}}
</style></head><body>

<div class="hero">
  <div class="lock">
    <img class="aer" src="{f('aerchain_dark.png')}">
    <div class="div"></div>
    <img class="inf" src="{f('infosys_blue.png')}">
    <div class="div"></div>
    <img class="uni" src="{f('unilever_blue.png')}">
  </div>
  <div class="heyebrow mono">EXECUTIVE LEADERSHIP SUMMARY &middot; 2026</div>
  <div class="htitle">Unilever Autonomous Sourcing</div>
  <div class="hsub">Infosys &times; Aerchain &mdash; agent-run sourcing, live and delivering value</div>
</div>

<section class="shift">
  <h2>The shift</h2>
  <div class="sub">From classical, manual sourcing to autonomous, agent-run sourcing &mdash; deployed by Infosys at Unilever.</div>
  <div class="cols2">
    <div class="panel"><div class="ptag b mono">BEFORE</div><div class="ph">Unilever before Infosys-Aerchain</div>
      <ul>{li(BEFORE,'&times;','x')}</ul></div>
    <div class="panel now"><div class="ptag n mono">NOW &middot; WITH INFOSYS-AERCHAIN</div><div class="ph">Autonomous, agent-run sourcing</div>
      <ul>{li(NOW,'&check;','c')}</ul></div>
  </div>
</section>

<section>
  <h2>Outcome <span class="pp">today</span></h2>
  <div class="sub">Already in production &mdash; and already delivering hard, banked savings.</div>
  <div class="outwrap">
    {''.join(f'<div class="ocard"><div class="ob">{b}</div><div class="ol">{l}</div><div class="os">{s}</div></div>' for b,l,s in OUTCOME)}
  </div>
  <div style="height:30px"></div>
  <h2>The <span class="pp">impact</span></h2>
  <div class="sub">A return that is underwritten by results, not projections.</div>
  <div class="mgrid">{card_row(IMPACT)}</div>
</section>

<section style="background:#fbfaff">
  <h2>How <span class="pp">Aerchain</span> works</h2>
  <div class="sub">Five agents run the sourcing cycle autonomously, with human-in-the-loop guardrails per category &mdash; all live in production.</div>
  <div class="agrid">
    {''.join(f'<div class="acard"><div class="anum">AGENT {n}</div><div class="atitle">{t}</div><div class="adesc">{d}</div><div class="alive">&check; LIVE &middot; UNILEVER</div></div>' for n,t,d in AGENTS)}
  </div>
</section>

<section>
  <h2>Value <span class="pp">realization</span></h2>
  <div class="sub">Savings are accelerating &mdash; 2025 delivered, 2026 committed.</div>
  <div class="vr">
    {bars()}
    <div class="vstat">
      <div class="vrow"><div class="n">$54M</div><div class="t">Addressable spend across 37 active sourcing projects</div></div>
      <div class="vrow"><div class="n">10%</div><div class="t">Average savings yield realised per project</div></div>
      <div class="vrow"><div class="n">&asymp;2&times;</div><div class="t">Growth in committed savings, 2025 &rarr; 2026</div></div>
      <div class="vrow" style="border-bottom:none"><div class="n">1 : 58</div><div class="t">Return on every dollar invested in the platform</div></div>
    </div>
  </div>
</section>

<section style="background:#fbfaff">
  <h2>Rollout <span class="pp">roadmap</span></h2>
  <div class="sub">A staged path from live deployment to enterprise-wide autonomous sourcing.</div>
  <div class="road">
    <div class="rstep"><div class="rtag">NOW</div><div class="rt">Business Services</div><div class="rd">Live in production</div></div>
    <div class="arrow">&rarr;</div>
    <div class="rstep"><div class="rtag">NEXT</div><div class="rt">Marketing &amp; IT</div><div class="rd">Infosys-managed spend</div></div>
    <div class="arrow">&rarr;</div>
    <div class="rstep"><div class="rtag">THEN</div><div class="rt">Enterprise-wide</div><div class="rd">Scaling beyond</div></div>
  </div>
</section>

<section class="deliver">
  <h2>Value delivery</h2>
  <div class="sub">Where the autonomous engine moves the needle.</div>
  <div class="dgrid">
    {donut(80,'80%','Requests auto-routed by the orchestrator','#FBBF24')}
    {donut(95,'95%','Policy compliance on every transaction','#34D399')}
    {donut(10,'10%','Average hard-cash savings yield','#60A5FA')}
    {donut(3,'+3%','Incremental negotiation efficiency','#F472B6')}
  </div>
</section>

<section>
  <h2>Frequently asked <span class="pp">questions</span></h2>
  <div class="fgrid">
    {''.join(f'<div class="fcard"><div class="fchk">&check;</div><div><div class="fq">{q}</div><div class="fa">{a}</div></div></div>' for q,a in FAQ)}
  </div>
</section>

<div class="foot"><span class="mono">AERCHAIN &times; INFOSYS &middot; AUTONOMOUS SOURCING FOR UNILEVER</span><span class="mono">CONFIDENTIAL &middot; 2026</span></div>
</body></html>"""

if __name__=="__main__":
    out_html=os.path.join(HERE,"_onepager.html")
    with open(out_html,"w") as fp: fp.write(HTML)
    from playwright.sync_api import sync_playwright
    with sync_playwright() as p:
        b=p.chromium.launch(); pg=b.new_page(viewport={"width":1240,"height":1400},device_scale_factor=2)
        pg.goto("file://"+out_html); pg.wait_for_timeout(1500)
        pg.screenshot(path="/tmp/onepager_full.png",full_page=True)
        pg.pdf(path=os.path.join(HERE,"Unilever_Aerchain_OnePager.pdf"),
               width="1240px",height=f"{pg.evaluate('document.body.scrollHeight')}px",print_background=True)
        b.close()
    print("one-pager done")
