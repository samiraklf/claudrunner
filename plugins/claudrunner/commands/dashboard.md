---
description: Open the claudrunner status page for this repository — the crew, the queue, and what shipped today.
argument-hint: "[--stop]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/runtime/dashboard-serve.sh:*)"]
---

# claudrunner — dashboard

```!
"${CLAUDE_PLUGIN_ROOT}/runtime/dashboard-serve.sh" $ARGUMENTS
```

Tell the user the address printed above, and that the page is already open if their system
could open a browser. It refreshes by itself every twenty seconds; `/claudrunner:dashboard --stop`
shuts it down.

If the output says the page is showing its simulation, that means this repository has no run
records yet — it is not an error. Real runs appear once `/claudrunner:triage` has run here, or
once the schedule has fired.

If `.claudrunner/config.yml` sets `dashboard.where` to `github-pages` or `server`, remind the
user that the shared page lives there as well, and give its address from the config.
