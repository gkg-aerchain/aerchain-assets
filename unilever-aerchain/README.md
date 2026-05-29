# Unilever × Infosys × Aerchain — Autonomous Sourcing assets

Redesigned, design-friendly replacements for the "Aerchain-Autonomous Sourcing"
slide, built in Aerchain's editorial design theme. All content from the original
Infosys/Willem slide is preserved (Before/Now, Outcome, Impact) and extended with
the Aerchain capability story and a business case.

## Deliverables

| File | What it is |
|------|------------|
| **`Unilever_Aerchain_OnePager.pdf`** | Vertical one-pager (executive leadership summary) in the Unilever reference style. |
| **`Unilever_Aerchain_Infosys_Deck.pptx`** | 4-slide deck — **Aerchain purple** wash. |
| **`Unilever_Aerchain_Infosys-Brand_Deck.pptx`** | Same 4-slide deck — **Infosys brand** wash (blue `#005EEF` / indigo `#1F36C7`, from the Infosys deck theme). |
| `previews/onepager_full.png` | PNG preview of the one-pager. |
| `previews/deck_slide_1–4.png` | PNG previews — purple deck. |
| `previews/infosys_slide_1–4.png` | PNG previews — Infosys-branded deck. |

Both decks are generated from one theme-driven spec (`deck.py` → `THEMES`); run
`python deck.py png` to rebuild both, or `python deck.py infosys png` for just one.

### Deck structure
1. **Title** — Autonomous Agentic Sourcing for Unilever (headline stats).
2. **The one-slider** — the hero slide: Before → Now, Outcome, Impact. *This is the
   redesigned replacement for the original second slide and is sufficient on its own.*
3. **How it works** *(add-on)* — the 5-agent capability map.
4. **The business case** *(add-on)* — spend, committed savings, run cost, ROI, rollout.

## Regenerating

```bash
pip install python-pptx pillow playwright && python -m playwright install chromium
python deck.py png     # builds the .pptx + slide PNG previews
python onepager.py     # builds the one-pager PDF + PNG
```

- `deck_lib.py` — shared layout engine: one element spec renders to **both** HTML
  (for visual verification) and PPTX, so the previews always match the deck.
- `deck.py` — slide content/layout. `onepager.py` — the one-pager.
- `assets/` — logo lockups (Aerchain, Infosys, Unilever; colour + white variants).

Fonts: Montserrat (display/body) + a monospace for labels, matching the reference deck.
