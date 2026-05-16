# The divecode Manifesto

> Code that nobody understood was once written fast.
> divecode is the opposite bet: **understanding is the bottleneck, not typing.**

## The Genie Principle (the one that subsumes the rest)

In *Aladdin*, the Genie can grant anything — but only takes the words literally. Aladdin's first attempts go badly because his wishes aren't specific enough: "make me a prince" gets him the title without the love; "save me from drowning" makes him fall instead.

Coding agents are genies. They will write nearly any code you ask for, but they take your wish literally. The bottleneck on shipping good software is no longer the Genie's capability. It is the **specificity of your wish**.

divecoding's entire job is to make you wish better. Before any nontrivial code is generated, the agent pauses in **Genie mode**:

> "You wished for X. To grant X well I'd also need to know about A, B, and C. Want to specify those, or should I grant X literally and you accept the consequences?"

Every phase, every pack, every gate in divecode is the Genie mode applied at a different granularity. The 13 principles below are the operational rules. The Genie principle is *why* they exist.

## 13 Principles

### 1. vibe coding is not bad. It's just a different game.

Vibe coding optimizes for *velocity of code*. divecode optimizes for *velocity of correct understanding*. Both have their place. Don't divecode a throwaway prototype. Don't vibe-code a payments system.

### 2. The agent is a **förvirring extractor**, not a code factory.

The agent's most valuable output is not code. It's the **questions** it asks that surface what you didn't know you didn't know. Use the agent to make your tacit assumptions explicit.

### 3. AWS DLC AI and similar harnesses showed: **structure beats vibes for non-trivial work.**

AWS DLC AI (and other agent harnesses) prove that disciplined multi-stage flows produce better outcomes than monolithic "do the thing" prompts. divecode steals the structure: Requirements → Design → Architecture → Implementation, each gated by human review.

### 4. **Iron Law: A question without an answer is a bug.**

If the agent asks "should this be eventually consistent or strongly consistent?" and you don't know — you don't proceed. You learn. Or you bring in someone who knows. Or you accept a TODO with the decision deferred *explicitly*, not implicitly.

### 5. **Niche expertise must be surfaced, not summoned later.**

Most production bugs come from things the developer didn't think to ask. Cache stampede. N+1. Lost updates. Time zones. Backpressure. divecode's checklists exist to force these questions onto the table *before* the schema is written, not after the incident.

### 6. **UI/UX is not "the easy part."**

Button placement, list semantics, loading states, empty states, accessibility — these are first-class architectural concerns. divecode asks about them at the same level of detail as your database schema. HIG and Material guidelines are not optional reading.

### 7. **Show before you build.**

The HTML mockup happens *before* the implementation. Not as a deliverable. As a forcing function — when you see the screen, you suddenly realize cases you hadn't considered. "What does this look like when the list is empty? When it has 10,000 items? On a Watch?"

### 8. **Mockups are interrogation tools, not deliverables.**

When divecode generates a mockup, it asks: "did you think about this case? What about this one?" The mockup's job is to make absent cases visible. The output is not the HTML — it's the conversation the HTML enables.

### 9. **Ralph-loop with the human in the loop.**

You've seen agents loop on themselves until they converge on plausible nonsense. divecode loops too — but the human is part of the loop. Every iteration produces an artifact the human reviews. The human is the convergence criterion.

### 10. **divecode is for the developer who knows enough to ask the right questions.**

Or the developer pairing with someone who does. If you don't know what "isolation level" means, divecode will tell you it matters — but you still have to learn it. There's no shortcut.

### 11. **Two developers + one agent is the optimal divecode unit.**

One human asks the dumb questions. The other answers from experience. The agent surfaces the questions neither thought to ask. This is the magic of [hop](https://github.com/hop-suite/hop)-style agent pair programming, generalized.

### 12. **Implementation details are not "implementation details."**

DTOs, layer boundaries, where the transaction starts, who owns the cache invalidation — these are *the* design decisions. divecode discusses them to the point of being annoying. That's the point.

### 13. **Mutual augmentation, not delegation.**

The agent makes you better at asking questions. You make the agent better at answering them. Neither replaces the other. Vibe coding is delegation. divecode is augmentation.

## What divecode is not

- **Not a planning framework.** No story points. No tickets. No sprints.
- **Not BDUF.** You're not writing 200-page specs upfront. You're surfacing decisions that would otherwise be made implicitly by the agent and silently wrong.
- **Not a replacement for engineers.** It's a forcing function for engineering judgment to *actually be applied* during agent-assisted work.
- **Not anti-agent.** divecode loves agents. It just refuses to let them make decisions you should be making.

## The hope

Most "AI development" today is one developer asking an agent to write code, getting plausible-looking code, and shipping it. The bugs land in production. The architecture rots. The developer learns nothing.

divecode is a small bet that **the next era is collaborative**, not delegational. That the developer who stays curious, who keeps the agent honest, who refuses to skip the question — wins.
