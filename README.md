# Treasury buyback: frozen descriptive calculations

This sanitized T2 release reproduces four retained facts from frozen inputs: three gross long-nominal accepted purchases, two ten-common-date US-minus-Japan 30y-minus-10y slope averages, a benchmark modified-duration calculation, and a policy-statement receipt. It omits the historical capacity scenario, charts, rejected drafts, research notes, private tooling, credentials, and the live data pipeline.

## Run

Requirements: R >= 4.0 and `jsonlite`. No API key, network access, or other package is required.

```sh
Rscript R/replay_frozen.R
sha256sum -c SHA256SUMS
```

The replay parses frozen raw inputs in memory and asserts: $15.265bn gross accepted par across Sep 10, Sep 24, and Oct 1; -63.24bp and -71.33bp averages; -8.09bp change; 7.851538709 modified duration; and .546807627-.911346045bp arithmetic under the stated illustration. The November 4 endpoint is not present and remains pending.

## Scope and limits

The $15.265bn is gross accepted par, not net duration removal. The 9-15 year duration range and 25bp per roughly $800bn 10-year-equivalent factor are analyst assumptions/illustrative arithmetic, not measured security duration, cash paid, funding replacement, an ATI-estimated universal DV01 coefficient, a causal effect, or an upper bound. The slope comparison does not identify a buyback effect, exclude anticipated purchases or other channels, measure liquidity effects, or prove a 30-year real term-premium mechanism. The September 16 policy hike fails the original unchanged-policy condition.

See `docs/CLAIMS.md` for the calculation-to-input mapping and `docs/PROVENANCE.md` for source status, quoted provider terms, required attributions, and redistribution conclusions. Third-party data is not under any code license of this tree.
