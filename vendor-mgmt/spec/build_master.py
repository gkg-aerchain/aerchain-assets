#!/usr/bin/env python3
"""Concatenate the whole spec package into a single MASTER.md for one-shot upload
into Lovable. Run:  python3 vendor-mgmt/spec/build_master.py"""
import os, datetime

HERE = os.path.dirname(os.path.abspath(__file__))

DOCS = [
    "README.md", "00-OVERVIEW.md", "01-SCOPE.md", "02-DEMO-SCRIPT.md",
    "03-RBAC.md", "04-STATE-MACHINE.md", "05-SCREENS.md",
    "06-AI-RISK-DUEDILIGENCE.md", "07-REALTIME-NOTIFICATIONS.md",
    "08-EXECUTION-AND-KILLSWITCH.md", "09-ERP-INTEGRATION.md",
    "10-ADANI-REQUIREMENTS-MAP.md", "11-ENTERPRISE-ARCHITECTURE.md",
]
MIGRATIONS = [f"migrations/{f}" for f in sorted(os.listdir(os.path.join(HERE, "migrations"))) if f.endswith(".sql")]
EDGE = [
    "edge-functions/README.md",
    "edge-functions/_shared/cors.ts", "edge-functions/_shared/ai.ts",
    "edge-functions/extract-document/index.ts", "edge-functions/mca-fetch/index.ts",
    "edge-functions/risk-screening/index.ts", "edge-functions/vendor-web-insights/index.ts",
    "edge-functions/due-diligence/index.ts", "edge-functions/erp-sync/index.ts",
    "edge-functions/vendor-classify/index.ts", "edge-functions/vendor-dedupe/index.ts",
    "edge-functions/ai-evaluate/index.ts", "edge-functions/vendor-assistant/index.ts",
]

def read(rel):
    with open(os.path.join(HERE, rel), "r", encoding="utf-8") as f:
        return f.read()

def fence_for(rel):
    if rel.endswith(".sql"): return "sql"
    if rel.endswith(".ts"): return "ts"
    return None  # markdown inlined as-is

def main():
    out = []
    out.append(f"<!-- AUTO-GENERATED {datetime.date.today()} by build_master.py — do not edit; edit the source files. -->\n")
    out.append("# AERCHAIN VENDOR MANAGEMENT + DUE DILIGENCE — MASTER SPEC (single-file)\n")
    out.append("This file concatenates the entire spec package (docs + SQL migrations + edge\n"
               "functions) in apply-order. Upload it to Lovable in one shot. When a section is a\n"
               "code file, its path is shown in the heading just above the code block — create the\n"
               "file at that path.\n")
    out.append("\n---\n\n# PART A — DOCUMENTATION\n")
    for rel in DOCS:
        out.append(f"\n\n<!-- ===== {rel} ===== -->\n\n" + read(rel))
    out.append("\n\n---\n\n# PART B — SQL MIGRATIONS (apply in order)\n")
    for rel in MIGRATIONS:
        out.append(f"\n\n### FILE: `vendor-mgmt/spec/{rel}`\n\n```sql\n" + read(rel).rstrip() + "\n```\n")
    out.append("\n\n---\n\n# PART C — EDGE FUNCTIONS (Deno / Supabase)\n")
    for rel in EDGE:
        fence = fence_for(rel)
        if fence:
            out.append(f"\n\n### FILE: `vendor-mgmt/spec/{rel}`\n\n```{fence}\n" + read(rel).rstrip() + "\n```\n")
        else:
            out.append(f"\n\n<!-- ===== {rel} ===== -->\n\n" + read(rel))
    master = "".join(out)
    with open(os.path.join(HERE, "MASTER.md"), "w", encoding="utf-8") as f:
        f.write(master)
    words = len(master.split())
    print(f"MASTER.md written: {len(master):,} chars, ~{words:,} words")

if __name__ == "__main__":
    main()
