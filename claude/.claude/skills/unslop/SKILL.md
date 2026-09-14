---
name: unslop
description: Use when writing or editing prose that a human will read as a document - plans, specs, design docs, PR bodies, commit bodies, release notes, READMEs, ONBOARDING, presentations, published artifacts, or Norwegian customer-facing text. Not for chat replies, code comments, or log messages.
---

# Unslop

Strip AI tells from written artifacts. Two tiers: mechanical tells you can grep, and judgment calls you cannot.

Run the mechanical pass first, then read every sentence against the judgment rules. The mechanical pass is cheap and finite; the judgment rules are where the actual slop lives.

## Mechanical pass

```bash
~/.claude/skills/unslop/scan.sh <file-or-dir>...
```

It reports counts per tell. Fix every hit, or say why the hit is a false positive.

| Tell | Fix |
|---|---|
| Title Case Heading | Sentence case. `### Test Count Targets` becomes `### Test count targets`. |
| Decorative emoji (✅ ❌ 🚀 💡 🎯 in headings/bullets) | Delete. Keep only where the glyph carries state a reader acts on (a pass/fail column). |
| `ensure` / `ensuring` | Name the actor and mechanism. "ensuring the cache is warm" becomes "the handler warms the cache on first read". |
| `additionally` / `furthermore` / `moreover` | Delete. Start the sentence. |
| `-ing` tail clauses (`..., enabling X`, `..., allowing Y`) | Delete, or promote to its own sentence with a real subject. |
| Fancy "is" (`serves as`, `stands as`, `acts as a`, `boasts`) | `is` or `has`. |
| Abstract metaphor nouns (`API surface`, `substrate`, `wedge`, `scaffolding`, `north star`, `flywheel`, `primitive` as noun) | The concrete word. `surface` becomes `the endpoints`, `wedge in` becomes `add`. |
| Curly quotes | Straight quotes. |

## NOT tells in technical docs

Do not "fix" these. Both were measured across 74 plans and specs and are overwhelmingly correct usage. Flagging them churns thousands of correct lines.

- **Em dash as an annotation separator.** `OrderCache.cs:73 — schema-hash read` is a label and its note, not prose punctuation. Leave it. Only rewrite an em dash used mid-sentence in flowing prose as a connector.
- **`**Label:** value` where the value is structured data.** `**Requirements:** R1, R4, R5` and `**Key:** {tenantId}_{ticks}` are fields. The tell is only the restating kind: `**Performance:** Performance improved...`.

## Judgment pass

Grep cannot catch these, and they are the ones that matter.

1. **Could this sentence appear unchanged in another project's doc?** Then it says nothing about this one. Cut it.
2. **Name the mechanism or the number, not the feeling.** "the cache keeps lookups fast" becomes "one Redis round trip per tenant per 10 min". If you cannot restate a sentence as a concrete instruction, fact, or number, cut it.
3. **Active voice.** Catch `is/are/was/were` + past participle and name the actor. "queries are validated" becomes "the handler validates queries".
4. **Cut the adverb or fix the verb.** `significantly improves` becomes the measured delta. An adverb propping up a weak verb means the verb is wrong.
5. **One idea per sentence.** If a reader has to backtrack to parse it, split it.
6. **Mark the evidence level.** Distinguish confirmed fact, qualified assumption, and estimate. An unproven claim written as settled is the worst slop in a technical doc, because it survives into the next decision.
7. **Self-audit.** Ask "what makes this obviously machine-written?" and fix what you find.

## Norwegian text

Applies to customer-facing and external Norwegian: internal short and action-oriented, external warm and professional, never hard sell. If the project or organisation has a tone-of-voice guide, it is the authority on tone; read it before editing external copy.

**Unverified:** these Norwegian tells are not measured, because the plans and specs they were measured on are English. Treat as a starting list, and add what you actually catch: `det er viktig å merke seg`, `i tillegg`, `sømløs`, `robust`, `kraftfull`, `helhetlig`, `bidra til`, `muliggjør`, `for å kunne`, `nøkkelen til`, `ikke bare X, men også Y`, `utnytte`/`anvende` for `bruke`.

## Common mistakes

- Running this on chat replies. The caveman hook already handles conversational terseness; this skill is for files and published text.
- Removing patterns and stopping. Voiceless writing is its own tell. Have an opinion, vary sentence length, use "I" where it fits.
- Rewriting the code blocks, error strings, or quoted output inside a document. Those stay byte-exact.
- Treating the mechanical table as the whole job. It is the cheap 20%.
- Trusting a scan count without reading the hits. A document that *discusses* tells (a style guide, this file, a review write-up quoting bad copy) scores hits on its own counter-examples. Read every flagged line before editing.
