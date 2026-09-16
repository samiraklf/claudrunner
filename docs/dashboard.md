# The status page

A full-screen scene showing what the crew is doing. One HTML file, no build, no
dependencies, and no network calls except to its own data file.

```
python3 -m http.server -d dashboard 8787
```

Open `http://localhost:8787`. Anything that serves a directory works: your editor's preview,
a static host, a path on a server you already run.

## What you are looking at

**Every active run is a robot at a bench**, hammering, with its task and progress on a card
above its head. The colour follows the phase — orange while it works, cyan once it reaches
review. When the queue empties the robots sit down with a coffee and start snoring, so you
can tell from across the room whether anything is happening without reading a number.

The caped one on the crates at the right is the review pass. At night the signal above it
burns; in daylight it does not, because a signal beam in sunshine looks like a smudge.

## Day and night

The page picks from your clock — daylight from 07:00 to 19:00, night otherwise — and
remembers whatever you choose after that.

| | Day | Night |
|---|---|---|
| Sky | Blue into warm haze, drifting clouds | Deep navy, moon, ninety stars, a third of them twinkling |
| City | Pale, windows mostly dark | Silhouettes with lit windows |
| Ground | Grass | Asphalt with a centre line |
| Robots | White with dark outlines | The same white with dark outlines |

The robots are deliberately the same in both. A dark scene where you cannot find the
characters is a wallpaper, not a status page.

## Scenes

Three, on the **SCENE** button. The crew, their benches and the progress cards are the same
in all of them; only the world changes.

Four, on the **SCENE** button. The crew changes with the world — different uniform,
different animal, different jokes.

| Scene | The world | The crew | Who follows them |
|---|---|---|---|
| 🌆 **City** | A real skyline: window grids, water tanks, aerials. Traffic, a neon sign, and a masked figure who swings past on a line | Hard hats | A pigeon |
| 🏝 **Beach** | Sea with surf, palms, parasol, a bouncing ball | Sunglasses and swim rings | **A dog**, tail going |
| 🌑 **Space** | Ringed planet, Earth, a launching rocket, a flag | Helmets and life support | A hovering drone |
| 🧱 **Maze** | Stone corridors, ivy, a shaft of light, something at the far end | Hoods and satchels | A lizard |

Each works in day and night, and your choice is remembered.
`?scene=city|beach|space|maze` pins one.

## They do things

Every few seconds a robot jumps, spins, shrugs, or falls flat on its back and gets up. Now
and then one dances instead — and **each robot has its own dance**, so a crew never moves in
unison: one sways side to side, one shuffles, one bounces, one spins and hops.

They say something over their own heads while they do it:

> this test was green yesterday.
> who wrote this? …oh.
> that is not a number, that is a vibe.
> someone left a TODO here in 2019.

## The task list is hidden

The scene is the default view. Press **T** or click **TASKS** to slide the list in from the
right, with the full title, phase, id and progress of every run.

Close it by clicking anywhere outside it, pressing **Escape**, pressing **T** again, or
clicking the button.

## Live data

The page polls `status.json` beside it every ten seconds. Generate it from the repository's
own run records:

```
./scripts/claudrunner-status.sh dashboard/status.json
```

Put that on a timer — a minute is plenty — or write it at the end of each run.

```json
{
  "queue": 2,
  "retired_today": 3,
  "runs": [
    { "id": "#412", "title": "Stream the CSV export", "phase": "implementing",
      "progress": 0.4, "board": "github" }
  ]
}
```

Every field is optional. A missing one renders as empty, never as an error. Up to four runs
appear in the scene at once; the drawer lists them all.

**With no `status.json` the page simulates and says so** — the chip reads `SIMULATION`
instead of `LIVE`. It is never blank, and it never shows invented numbers while implying
they are real.

## Options

| Query parameter | Default | Meaning |
|---|---|---|
| `?theme=day` / `?theme=night` | from your clock | Force one |
| `?scene=<name>` | `city` | `city`, `beach` or `space` |
| `?data=<url>` | `status.json` | Poll a different feed |
| `?poll=<ms>` | `10000` | Polling interval |

Characters speak occasionally, and whenever something ships. The lines are deadpan:

> I CANNOT FLY. I CAN OPEN A PULL REQUEST.
> QUEUE EMPTY. I HAVE READ THE README TWICE.
> THE COFFEE IS DECORATIVE. I APPRECIATE THE GESTURE.

Everything stops under `prefers-reduced-motion`.
