# Ways of working — context & memory engineering

Part of the build standard. How AI-assisted work is run so it's durable, honest, and not dependent
on any one session or model. Inherited by every project built from ai-starter.

## Principles
1. **State lives in artifacts; the model is stateless working memory.** Source of truth = git commits + docs + structured memory. Never "in the chat."
2. **Capture at each milestone, not at the context cliff.** Every completed unit → commit + memory/handoff update. Context filling up then becomes a non-event.
3. **Subagents for offload.** Heavy / file-noisy work runs in a sub-context; only a short summary returns to the main thread. Keeps the main context lean (the real token lever).
4. **Structured memory, not a dump.** A tiny always-loaded index + retrievable detail files. One fact per file.
5. **Spec + gate.** Build to acceptance criteria; an independent reviewer (human-owned, *versioned* rubric — it suggests bar changes, never self-mutates) checks the work. Verifiable regardless of who/what built it.
6. **Don't depend on the model's memory.** Everything important must survive a fresh session — or a different model — picking up cold from the durable record.
7. **Honesty over polish.** Claims must equal reality; "verified" means tested, "mocked/unproven" is said so. Watch for the failure mode where *true claims drift into false*.
8. **Sync beats style for verbatim harvests.** When a file is pulled in byte-identical from another repo (a harvested script, a canonical copy), `biome-ignore`/lint-exempt it rather than reformatting. Keeping it identical to its source makes future re-syncs a clean diff; reformatting on landing creates permanent drift for no benefit.

## Honest limits (no false comfort)
- **Auto-compaction is lossy** — it keeps decisions, can drop nuance. Mitigated by (a) the full raw transcript on disk (recoverable backstop) and (b) the curated memory/docs. The curated record is *judgment*, so the per-milestone discipline (principle 2) is what keeps it complete.
- If it's not committed or in memory, it doesn't count as done.

## Cadence
Milestone-scoped sessions over one mega-thread: a focused session per workstream, entering via the project's handoff/exec doc + memory, ending with capture. Resume cold, anytime.
