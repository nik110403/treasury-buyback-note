# Retained claims and exhibit mapping

| Retained statement | Recomputed from | Result | Status |
| --- | --- | --- | --- |
| Gross long-nominal purchases after the Sep 2 baseline through the locked Nov 4 window | `inputs/treasury/buybacks_operations.json` | Sep 10 $5.187bn + Sep 24 $4.078bn + Oct 1 $6.000bn = $15.265bn | Descriptive gross accepted par |
| Ten-common-date US-minus-Japan 30y-minus-10y averages | DGS10/DGS30 frozen FRED API-result CSVs plus MoF JGB CSVs | -63.24bp (Sep 2) to -71.33bp (Oct 2), -8.09bp | Descriptive; Nov 4 pending |
| Benchmark duration and scale | Fixed 4.625% coupon, fixed 5.28% yield, 9-15y assumptions, $800bn/25bp illustration | 7.851538709; .546807627-.911346045bp | Assumption-driven arithmetic only |
| Policy condition | Fed statement receipt | Sep 16 statement raises target range by 25bp to 3.75-4.00% | The unchanged-policy condition failed |

No claim in this release estimates a causal yield effect, actual/net duration removal, term premium, or liquidity effect.
