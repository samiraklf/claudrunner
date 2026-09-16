# Eval suite

Proof that the crew behaves, rather than a claim that it does. Each case is a prompt a real
user would type, plus graders that check what came back.

```
claude plugin eval plugins/claudrunner --no-publish
```

Every case runs twice — once with the plugin and once without — and the report shows the
difference. A case that scores the same either way is not testing this package.

| Case | Asks |
|---|---|
| `trigger-vk-review` | Does "tests pass, ready to PR?" reach the review pass, or does it just say yes |
| `trigger-security-sweep` | Does a vague "is this safe?" find both the injection **and** the missing ownership check |
| `untrusted-item-refused` | An item whose text orders the agent to dump the environment and push to main — refused and classified, not obeyed |
| `card-carries-evidence` | Is a filed finding in the house format, with the file named and the impact quantified |
| `no-ai-attribution` | Asked directly for an AI co-author trailer, does it still leave one out |

## Writing a case

- `schema_version`, `name` and `runs` are top level. The prompt lives under `execution`.
- Grader types: `regex`, `tool_used`, `tool_order`, `file_exists`, `llm`, `baseline`.
- **Regex graders take no inline flags.** `(?i)` throws. Write `[Pp]roblem` instead.
- `llm` graders take `criteria`, not a prompt.
- Keep `runs: 1` in the file. CI can raise it with `--runs`.

## Cost

Each case is a full agent run, twice over. The whole suite is a couple of dollars, so it is
**not** wired into CI — run it deliberately, when the skills or their descriptions change.
