# Cost

An agent that works while you sleep bills while you sleep. Read this before you schedule
anything.

## What drives the bill

1. **How often the fast loop looks.** A poll that finds nothing is cheap but not free. At
   ten minutes that is 144 checks a day.
2. **How much work it finds.** A cycle that implements and reviews an item is the expensive
   part, by a wide margin.
3. **Whether you enable a second reviewer.** It roughly doubles review cost for a real
   increase in caught defects.
4. **How large your items are.** A vague item burns turns on investigation and often parks
   itself anyway. Well-specified items are cheaper as well as better.
5. **Escalation.** The `deep-work` agent is deliberately expensive and should be rare. If it
   fires often, your items are too large.

## Estimate yours before turning anything on

Run one cycle by hand, with the run log written out:

```
claude -p "/claudrunner:triage" --output-format json > run.json
jq -r '"cost=\(.total_cost_usd) turns=\(.num_turns)"' run.json
```

Do it for an empty queue and for a real item. Those two numbers — the idle poll and the
working cycle — are all you need:

```
daily ≈ (polls per day × idle cost) + (items per day × working cycle cost)
```

Multiply by twenty working days. If that number would surprise you at the end of the month,
lower the poll frequency first. It is the cheapest lever and costs almost nothing in
responsiveness.

## Conservative defaults

The shipped defaults are deliberately modest: a ten-minute poll, three items per cycle, a
weekday nightly sweep, fifteen new cards per sweep, and hard run caps per day and week.

Set `limits.max_runs_per_week` before the first schedule. It is a spend stop, and it is
much easier to raise than to explain.

## Cheaper without being worse

- Poll less often. Responsiveness is usually a feeling, not a requirement.
- Sweep weekly instead of nightly on a stable codebase. The board is better too.
- Write better items. Specific items finish; vague ones burn turns and park.
- Keep `max_changed_lines` low. Large diffs cost more and get reviewed worse.
- Enable the second reviewer for the areas that matter, not for everything.
