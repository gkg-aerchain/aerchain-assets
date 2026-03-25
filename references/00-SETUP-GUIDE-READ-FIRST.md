# 🛠️ SETUP GUIDE — Aerchain Sales Bible → Notion

> **Time needed:** ~45-60 minutes for full setup
> **Who should do this:** Whoever manages the Notion workspace (Harsha or delegate)

---

## STEP 1: Create the Workspace Structure (5 min)

1. In your Notion sidebar, create a **new page** called **"Aerchain Sales Bible v2.0"**
2. Give it an icon: 📖 and a cover image (use Aerchain brand gradient or a procurement image)
3. Inside this page, you'll import all the markdown files below

---

## STEP 2: Import the Markdown Files (15 min)

For **each .md file** in this zip:

1. Open the **Sales Bible** parent page in Notion
2. Click the `...` menu (top-right) → **Import** → **Text & Markdown**
3. Select the .md file → it imports as a **sub-page** with all formatting intact
4. Notion automatically converts:
   - `# Headings` → Notion headings (H1, H2, H3)
   - `| Tables |` → Notion tables
   - `- [ ] Checkboxes` → Interactive toggleable checkboxes
   - `> Callouts` → Quote blocks (you'll upgrade these to callouts — see Step 4)
   - `**Bold**` and `*italic*` → Formatted text
   - Emojis → Native emoji icons

### Import Order (recommended):
```
1.  00-Home-Sales-Bible.md          ← This becomes your homepage
2.  Stage-0-Lead-Generation.md
3.  Stage-1-Discovery-Call.md
4.  Stage-2-Deep-Dive-Demo.md
5.  Stage-3-Workshop.md
6.  Stage-4-Spend-Analysis.md
7.  Stage-5-Customized-Demo.md
8.  Stage-6-Post-Demo-Closing.md
9.  Stage-7-Commercial-Proposal.md
10. Stage-8-Implementation-Handover.md
11. The-10-Commandments.md
12. P0-P1-P2-Guardrails.md
13. Competitive-Differentiation.md
14. Master-Collateral-Index.md
```

---

## STEP 3: Add Icons + Covers to Each Page (5 min)

Give each Stage page a **unique icon** so the sidebar is scannable at a glance:

| Page | Icon | Suggested Cover Color |
|---|---|---|
| Home | 📖 | Dark navy gradient |
| Stage 0 | 🎯 | Cyan/teal |
| Stage 1 | 📞 | Blue |
| Stage 2 | 🖥️ | Indigo |
| Stage 3 | 🏢 | Purple |
| Stage 4 | 📊 | Green |
| Stage 5 | 🎯 | Orange |
| Stage 6 | 🏁 | Red/amber |
| Stage 7 | 💰 | Gold |
| Stage 8 | 🚀 | Green |
| 10 Commandments | ⭐ | Dark |
| P0/P1/P2 | 🚦 | Traffic light gradient |
| Competitive | ⚔️ | Navy |
| Collateral Index | 📋 | Teal |

**How:** Click the icon area at the top of each page → pick emoji. Click "Add Cover" → choose a gradient or upload brand image.

---

## STEP 4: Upgrade Quote Blocks → Callout Blocks (10 min)

Markdown `> blockquotes` import as plain quote blocks. To make them pop with color:

1. Click on any quote block (the ones with 💡, ⚠️, 💬 prefixes)
2. Type `/callout` and select **Callout**
3. Paste the text into the callout
4. Choose icon + color:

| Prefix in the markdown | Callout Icon | Callout Color |
|---|---|---|
| 💡 KEY INSIGHT | 💡 | Yellow background |
| ⚠️ WARNING / CRITICAL | ⚠️ | Red background |
| 💬 Script / Quote | 💬 | Blue background |
| ✅ EXIT GATE YES | ✅ | Green background |
| ❌ EXIT GATE NO | ❌ | Red background |

**This is the single biggest visual upgrade** — callout blocks with color backgrounds make the bible scannable and beautiful.

---

## STEP 5: Link the Pages Together (10 min)

The markdown files have navigation links like `[Stage 1 →](Stage-1-Discovery-Call.md)`. These won't auto-link in Notion. Replace them:

1. Select the link text (e.g., "Stage 1 →")
2. Type `@` and search for the page name → select it
3. This creates a **live Notion page link** that updates if you rename the page

Do this for:
- The **Home page table** (link each stage name to its page)
- The **← Previous | Home | Next →** navigation at the bottom of each stage
- Any cross-references between stages

**Pro tip:** On the Home page, turn the pipeline table into a **Notion linked database** (see Step 7) for even more power.

---

## STEP 6: Convert the Collateral Index into a Notion Database (10 min)

This is where Notion really shines vs. the HTML version.

1. Go to the **Master Collateral Index** page
2. Delete the markdown table
3. Type `/database` → select **Database - Full Page**
4. Add these **properties:**

| Property Name | Type | Options |
|---|---|---|
| Name | Title | (default) |
| Stage | Select | 0, 1, 2, 3, 4, 5, 6, 7, 8 |
| Owner | Person | (tag team members) |
| Priority | Select | 🔴 Must-Have, 🟡 High, 🟢 Important |
| Status | Status | Not Started, In Progress, Done |
| Due Date | Date | |
| Link/File | URL or Files | Link to actual collateral doc |
| Notes | Text | |

5. Enter the 25+ collaterals from the markdown tables
6. Create **Views:**
   - **By Stage** → Group by Stage property
   - **By Owner** → Group by Owner (who needs to create what)
   - **By Status** → Kanban board (Not Started → In Progress → Done)
   - **My Collaterals** → Filter by Owner = Me

Now every collateral is **trackable, assignable, and linkable** to the actual document.

---

## STEP 7: Create a Pipeline Tracker Database (Optional, 10 min)

For the Home page, create a **second database** for deal tracking:

| Property | Type | Purpose |
|---|---|---|
| Deal Name | Title | Company name |
| Current Stage | Select | 0 through 8 |
| Deal Size | Number | $ value |
| Champion | Text | Internal champion name |
| Next Action | Text | What needs to happen |
| Gate Status | Select | Passed / Blocked / Nurture |
| Owner | Person | Aerchain sales lead |
| Last Activity | Date | |

Views: **Pipeline Board** (Kanban by Stage), **My Deals**, **Stalled Deals** (filter: no activity in 2+ weeks)

---

## STEP 8: Final Polish (5 min)

### Add dividers between sections
Type `/divider` between major sections for visual breathing room.

### Add toggle blocks for long content
For sections like Objection Handling (Stage 1), convert to **Toggle Headings:**
1. Type `/toggle heading` 
2. Put the objection as the heading, response inside the toggle
3. Team members can expand only what they need

### Add a Table of Contents on the Home page
Type `/table of contents` at the top of the Home page. Notion auto-generates linked anchors to every heading.

### Lock the structure (optional)
If you don't want people accidentally restructuring:
1. `...` menu → **Lock page** on the Home page
2. Keep individual stage pages editable

---

## NOTION STYLING CHEAT SHEET

| What You Want | How to Do It in Notion |
|---|---|
| Colored callout box | `/callout` → pick icon + background color |
| Collapsible section | `/toggle` or `/toggle heading` |
| Kanban board | Database → Board view |
| Linked page reference | Type `@` + page name |
| Embed a file | `/file` or drag-drop PDF/doc |
| Visual divider | `/divider` |
| Table of contents | `/table of contents` |
| Banner/cover image | Click "Add cover" at top of page |
| 2-column layout | Drag a block to the right edge of another block |
| Synced block | `/synced block` — edit once, updates everywhere |

---

## KEY NOTION ADVANTAGES OVER THE HTML VERSION

| HTML Version | Notion Version |
|---|---|
| Developer needed to edit | Anyone on the team can edit |
| Static file | Live, collaborative, real-time |
| No tracking | Collateral database with status tracking |
| No assignments | Tag owners, set due dates |
| Read-only | Interactive checklists, toggles, databases |
| Single file | Linked pages, cross-references, search |
| No deal tracking | Pipeline database with Kanban views |
| No notifications | Mention @person → they get notified |
| No version history | Built-in page history and restore |

---

## MAINTENANCE GUIDE

| Frequency | Action | Who |
|---|---|---|
| After every deal | Update objection handling with new objections learned | Sales lead |
| Monthly | Review collateral status, update completion % | Marketing |
| Quarterly | Review and refresh L1 business case benchmarks | BA |
| After product release | Update P0/P1/P2 guardrails, demo flow, feature matrix | Product |
| After new customer win | Add to reference list, update case studies | CS |
| Semi-annually | Full Sales Bible review — what's working, what's not | Harsha |

---

*This guide is part of the Aerchain Sales Bible Notion Package.*
