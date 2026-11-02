# Demo fixtures — seeded, not random

When a product needs demo-first sample data (a UI walkthrough, a screenshot, a
sales demo), generate it **deterministically from a fixed seed**, not randomly
per run — so the same demo reproduces byte-for-byte every time and a diff shows
real changes, not noise. Give generated entities plausible "personalities"
(varied but internally consistent shapes/behaviour) so the demo reads as real
data without needing a live source. Commit the generator script, not just its
output; regenerate on demand and review the diff. Reference implementation:
a deterministic sample-data generator in the consuming project.
