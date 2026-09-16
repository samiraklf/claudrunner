# The status page

A single HTML file. No build, no dependencies, no network calls except to its own data file.

```
python3 -m http.server -d dashboard 8787
```

Then open `http://localhost:8787`. Anything that serves a directory works: your editor's
preview, a static host, GitHub Pages pointed at `dashboard/`, or a path on a server you
already run.

## Live data

The page polls `status.json` beside it every ten seconds. Generate it from the repository's
own run records:

```
./scripts/claudrunner-status.sh dashboard/status.json
```

Put that on a timer — a minute is plenty — or write it at the end of each run.

```json
{
  "generated_at": "2026-09-16T10:38:15Z",
  "incept": "2026-09-16",
  "queue": 2,
  "retired_today": 3,
  "review": { "findings": 4, "fixed": 4 },
  "runs": [
    { "id": "#412", "title": "Stream the CSV export", "phase": "implementing",
      "progress": 0.4, "started_at": "2026-09-16T10:31:00Z", "board": "github" }
  ],
  "ticker": ["UNIT RETIRED: STREAM THE CSV EXPORT."]
}
```

Every field is optional. A missing one renders as empty, never as an error.

## When the feed is unreachable

The page falls back to a simulation and **says so** — the badge switches from `LIVE` to
`SIMULATION`. It is never blank, and it never shows invented numbers while claiming they are
real. That distinction matters on a screen somebody leaves running.

## The scenes

Three backdrops. The page picks one from what the crew is actually doing, and cycles between
the first two while work is running.

| Scene | When | What happens in it |
|---|---|---|
| **Street** | Work is running | Rain over the skyline, one window lit orange, a car crossing now and then. The window goes dark when the queue empties |
| **Rooftop** | Work is running | A caped figure on a ledge under a signal beam. The signal dims when there is nothing to do, and the figure points when something is retired |
| **Break room** | Queue empty, nothing running | The crew on a couch with a decorative coffee, a plant, and a clock nobody is watching |

The break room is not decoration. **A crew with nothing to do should look like one** — you can
tell from the far side of the room whether anything is happening, without reading a number.

Every scene has an iris that widens while a review runs, and a folded figure for each item
retired today. Click the scene name in the header to change it by hand.

Characters say something occasionally, and when an item is retired. The lines are deadpan:

> I CANNOT FLY. I CAN OPEN A PULL REQUEST.
> QUEUE EMPTY. I HAVE READ THE README TWICE.
> THE BUG WAS COMING FROM INSIDE THE REPO.

## Options

| Query parameter | Default | Meaning |
|---|---|---|
| `?data=<url>` | `status.json` | Poll a different feed |
| `?poll=<ms>` | `10000` | Polling interval |
| `?scene=<name>` | auto | Pin one scene: `street`, `rooftop` or `breakroom` |
| `?cycle=<seconds>` | `90` | How long before the backdrop changes |

It respects `prefers-reduced-motion`: the rain stops, and every animation holds still.
