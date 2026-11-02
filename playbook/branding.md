# Branding & naming standard

A concrete checklist for naming and positioning a project, grounded in what
actually-successful developer tools do — not branding theory. Sources at the
bottom (Product Hunt Golden Kitty winners, the Evil Martians study of 100 dev-tool
landing pages, npm naming rules). The throughline from the data: **for developer
tools, plain and concrete beats clever and hyped.**

## What the winners actually share (the evidence)
- **Short, one-word, often a plain noun.** 2024 Golden Kitty dev-tool winners and
  Product-of-the-Year: *Supabase, Cursor, Figma*. The pattern is a single
  pronounceable word, not a phrase.
- **Two live naming patterns:** a coined/short word (*Supabase*, *Cursor*) or the
  `.new` / domain-as-name trick (*postgres.new*, *bolt.new*). `AI` suffixes
  (*Figma AI*) and version bumps (*Langfuse 2.0*) are extensions of an existing
  name, not a way to name something new.
- **Landing pages: "No salesy BS. Clever and simple wins."** Evil Martians studied
  100 dev-tool pages: centered, max-width, clean layouts outperform flashy
  animated marketing sites. Devs decide in ~3 seconds, above the fold.
- **Headline describes the user's outcome, not the product.** Weak heroes describe
  features; strong ones state what the user gets.
- **Show the code/product in the hero.** Tailwind puts a snippet front-and-center
  so devs gauge it instantly. A code block or real UI > a stock illustration.
- **Social proof right after the hero**; **a specific CTA** ("Start building",
  "Download") beats generic "Get started"; offer two CTAs (try / read docs).
- **Positioning grounded in technical truth.** "best-in-class", "revolutionary",
  "next-gen" without substantiation *damages* credibility with developers.

## Name-availability check (do before committing to a name)
- [ ] **npm:** `npm view <name>` returns 404 (free). Lowercase kebab-case only —
      no camelCase, PascalCase, underscores, or uppercase (npm rule). If taken,
      use a scope you own: `@yourorg/<name>` guarantees the namespace.
- [ ] **npm near-collision:** names differing only by punctuation are *rejected* by
      npm (anti-typosquat) — so don't pick `my-tool` if `mytool` exists.
- [ ] **Web:** the `.com` or a credible `.dev`/`.sh`/`.io` is gettable; a `.new`
      shortcut is a bonus, not required.
- [ ] **GitHub:** the org/repo handle is free.
- [ ] **Collision with known tools:** search the name + "cli"/"npm"/"github". Reject
      anything that collides with a well-known tool, language keyword, or trademark
      — discoverability and credibility both suffer.
- [ ] **Sayable + spellable:** you can say it on a call and the other person can
      type it without spelling it out.

## Naming patterns that win (pick one)
1. **Plain noun / short coined word** — *Cursor, Supabase*. Default choice.
2. **Domain-as-name** — `thing.new`, `thing.sh`. Memorable, implies "just go".
3. **Compound of two short real words** — only if it stays short and sayable.
   Avoid generic stems (`utils`, `tools`, `lib`, `kit`) — taken and ambiguous.
Avoid: hype words, random vowel-drops, three-word phrases, `AI`-stuffing a brand
that isn't already established.

## One-line positioning formula
Customer-facing one-liner (the README hero + PRD one-liner):

> **`<Tool>` is <the thing it is> that <the concrete outcome for the user>.**

e.g. "A local-first RAG search that answers from your own repositories — no API key,
no cloud." Rules: name the category in plain words, lead with the user's outcome,
no superlatives, claims must equal what the code does (the honesty rule from
`docs/ways-of-working.md` applies to marketing too).

Internal positioning (for your own clarity, not the page): *To `<audience>`,
`<Tool>` is the `<category>` that `<differentiator>`, because `<reason to
believe>`.*

## Landing page / README section structure
In order (the structure the winners converge on):
1. **Hero** — outcome headline + one-line sub + one specific primary CTA + a code
   snippet or real UI shot. Everything essential above the fold.
2. **Social proof / "used by"** — immediately after the hero, if you have it.
3. **The problem → how it works** — concrete, with a code example.
4. **Key capabilities** — 3-5, each tied to a real benefit, no feature soup.
5. **Quickstart** — copy-pasteable install + first run.
6. **Secondary CTA** — docs / GitHub / try.
Keep it centered, max-width, calm. No autoplay carousels, no hype.

## Voice
Plain and understated > hype. Say what it does, show it doing it, state limits
honestly. Developers reward technical truth and punish marketing adjectives. If a
sentence would embarrass you in a code review, cut it.

## Sources
- [Golden Kitty Awards 2024 — winners (Product Hunt)](https://www.producthunt.com/golden-kitty-awards/hall-of-fame?year=2024)
- [Who Won Product Hunt Golden Kitty Awards 2024 (DEV Community)](https://dev.to/web_dev-usman/who-won-product-hunt-golden-kitty-awards-2024-find-out-the-best-products-14nd)
- [We studied 100 devtool landing pages — what actually works in 2025 (Evil Martians)](https://evilmartians.com/chronicles/we-studied-100-devtool-landing-pages-here-is-what-actually-works-in-2025)
- [Hero section best practices (LogRocket)](https://blog.logrocket.com/ux-design/hero-section-examples-best-practices/)
- [npm package name guidelines](https://docs.npmjs.com/package-name-guidelines/)
- [npm new package naming rules — anti-typosquat (npm, Inc.)](https://medium.com/npm-inc/npm-weekly-127-new-npm-package-naming-rules-how-to-handle-an-outage-a-teacup-update-4f5e601f3e16)
- [Value prop vs positioning statement (Open Strategy Partners)](https://openstrategypartners.com/blog/value-proposition-vs-positioning-statement/)
</content>
