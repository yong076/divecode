# humanize — English taxonomy

Patterns that mark English text as AI-written. Original compilation for
divecode; some patterns overlap with widely-cited AI-detection signals
(em-dash burst, "delve" vocabulary, mechanical parallel triplets).

Severity: same scheme as Korean taxonomy.

Do-NOT touch: proper nouns, product/model/org names, numbers, dates,
direct quotes inside "…", code, file paths, industry abbreviations.

Change-rate hard guard: > 30% warn, > 50% halt.

| ID | Pattern | Severity | Detection signal | Rewrite |
|---|---|---|---|---|
| EN-1 | Em-dash burst (` — `) | S2 | count ≥ 8 per 1000 words | Convert to comma, period, or parentheses |
| EN-2 | "It's not just X, it's Y" mechanical contrast | S1 | regex `\b(it'?s\|this is) not just\b` | Drop or restructure as direct claim |
| EN-3 | LLM hype vocabulary | S1 | `\b(delve\|leverage\|robust\|seamless\|cutting-edge\|state-of-the-art\|paradigm shift)\b` count ≥ 3 | Replace with concrete domain word |
| EN-4 | Closing pivot lexicon | S1 | `\b(In conclusion\|In summary\|To summarize\|All in all\|Ultimately,)\b` | Drop entirely or replace with concrete final claim |
| EN-5 | "Let me X" / "I'll X" self-narration | S1 | `^(Let me \|I'll \|I will )` line start count ≥ 2 | Drop the narration; just state the result |
| EN-6 | "First, Second, Finally" mechanical 3-step | S2 | `\bFirst,\b.*\bSecond,\b.*\b(Finally\|Third),` in same paragraph | Use prose connectives or actual structure |
| EN-7 | "X, Y, and Z" triplet overuse | S2 | triplet count ≥ 8 per 1000 words | Vary to pairs, singletons, or longer lists |
| EN-8 | Bullet-overuse where prose belongs | S2 | `^- ` count > 30% of body lines | Convert short bullet runs to a single sentence |
| EN-9 | Bold `**` overuse | S2 | `**` count ≥ 16 per 1000 words | Keep 1-3 truly load-bearing emphases; drop the rest |
| EN-10 | Title-sentence + paragraph template | S2 | bold one-liner immediately followed by indented prose, 3+ times | Merge title and body into a single sentence |
| EN-11 | "You'll find that..." / "you can..." reader-address | S2 | `\byou\b` count > 40 per 1000 words | Switch to declarative or first-person where natural |
| EN-12 | Marketing speak | S1 | `\b(powered by\|built with cutting-edge\|world-class\|industry-leading\|next-generation\|revolutionary)\b` | Drop; state what it actually is |
| EN-13 | Excessive headings | S2 | heading count > 1 per 100 body words | Merge sections or move minor topics into prose |
| EN-14 | "It's worth noting that" / "It's important to note" | S1 | `\bit'?s (worth noting\|important to note)\b` | Drop the preamble; just state the thing |
| EN-15 | Hedging stacks | S2 | `\b(might possibly\|could potentially\|may perhaps\|seems to suggest)\b` count ≥ 2 | Single hedge or none |

## Self-check after rewrite

1. Proper nouns, numbers, dates, direct quotes preserved exactly.
2. Change rate ≤ 30%.
3. Genre preserved — a technical doc stays technical, a blog stays a blog.
4. Register preserved — formal stays formal.
5. S1 IDs left: 0 (EN-2, EN-3, EN-4, EN-5, EN-12, EN-14 all gone).
6. No fabricated metaphors or rhetorical flourishes added.

## Quality grade

Same scheme as Korean:
- **A**: S1 = 0, S2 ≤ 2, change rate 10–25%, self-check 6/6
- **B**: S1 = 0, S2 ≤ 4, self-check 5/6+
- **C**: S1 in 1–2 — re-run recommended
- **D**: S1 ≥ 3 or change rate > 50% — halt
