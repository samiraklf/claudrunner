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

**The caped one on the lookout tower is the review pass.** With nothing in review it keeps
watch, turning its head slowly left and right. When a unit reaches review, it points its
visor at that unit and scans it — a cyan beam, and a bar sweeping down over the robot — and
now and then says what it is looking for: *any P0s in here?*

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
| 🌆 **City** | A real skyline: window grids, water tanks, aerials. A road with traffic, and a brick corner shop whose neon sign — and the sign on its door — reads **OPEN** while the crew works and **CLOSED** when the queue is empty. Its windows go dark when it closes | Hard hats | **Sir Wigglebutt** — black and white, red collar, leaves things behind |
| 🏝 **Beach** | Sea with surf, palms, a sandcastle, bucket and spade, a starfish, a striped towel, a crab, and a lifeguard hut for the reviewer | Sunglasses and real inflatable rings | **Sandbox** — golden, fetches everything, returns nothing |
| 🌑 **Space** | Ringed planet, Earth, a launching rocket, a flag | Helmets and life support | A hovering drone |
| 🧱 **Maze** | Stone corridors, ivy, a shaft of light, something at the far end | Hoods and satchels | A lizard |

Each works in day and night, and your choice is remembered.
`?scene=city|beach|space|maze` pins one.

## They do things

Every few seconds a robot jumps, spins, shrugs, or falls flat on its back and gets up. Now
and then one dances instead — and **each robot has its own dance**, so a crew never moves in
unison: one sways side to side, one shuffles, one bounces, one spins and hops.

**When something ships, the whole crew dances at once**, each its own dance. Press **D** to
start one yourself.

**Once a minute in the city**, Sir Wigglebutt stops, has a look around, squats, and leaves
something steaming on the pavement. He walks off without looking back. A masked figure swings
in on a line, webs it, and carries it off into the sky. Press **P** to see it on demand, or
add `?slow=4` to watch every beat at a quarter speed.

## Sprint and Scope Creep, in the maze

Once a minute in the maze, the ground shakes and the gate doors start to close. **Sprint** — a
round, very out-of-shape jogger in a **404: CARDIO NOT FOUND** shirt that lost the argument with his gut —
jogs out of the gate reading his map: *"JUST A LIGHT JOG. CHECKING THE MAP."*

He stops. Something is behind him. He turns round. **Scope Creep** crawls out of the gate.

He leaps straight up — *"AAAAAAAAAAAAH!"* — and runs faster than he has moved in years, arms
flailing, sweat flying, gut going. He trips over nothing. The map goes flying. He cowers:
*"please no. i have a standup at nine."* Scope Creep looms over him… and hands the map back.
*"YOU DROPPED YOUR MAP."* *"ALSO. ONE MORE SMALL FEATURE."* He faints, X-eyed. Scope Creep,
a little hurt, goes home: *"I JUST WANTED TO ADD A BUTTON."* Sprint comes round, remembers,
screams *"NOPE."* and is gone.

`P` plays whichever scene's gag is on screen. `?gag=1` plays it as soon as the page loads — a
link you can send someone.

## Rollback, on the beach

Once a minute on the beach, Sandbox chases the ball — *"BALL. BALL. BALL. BALL."* — straight
into the sea, and discovers he cannot swim. *"BLUB. HELP. BLUB."* *"I AM A RETRIEVER. I FORGOT
THE RETURN STATEMENT."*

A whistle. From the right, in slow motion, comes **Rollback**: lifeguard, superhero, red trunks,
red cape, orange rescue can, and hair that moves on its own. He dives in, swims out, and brings
Sandbox back under one arm: *"HOLD ON, BUDDY. ROLLING YOU BACK."* Sandbox shakes himself dry
all over him. *"ROLLED BACK TO LAST KNOWN GOOD STATE."* Then Sandbox notices the ball is still
out there. Rollback puts his face in his hand: *"NO. NO NO NO NO."*

## Crawler, saviour of the city

Crawler patrols the skyline to protect the city from its own code, and often announces
himself on the way in:

> FEAR NOT, CITIZENS! NO FRIDAY DEPLOYS ON MY WATCH!
> STAND BACK! THAT CODE HAS NO TESTS!
> CITIZEN, PUT DOWN THAT CONSOLE.LOG. SLOWLY.

## Hover to meet them

Hover over a character to see its name, who it is, and what it is thinking right now. The
thought changes every time.

| | Who | Thinking, for example |
|---|---|---|
| **Sir Wigglebutt** | the city dog · very good boy · leaves things behind | *my full name is Sir Wigglebutt the Third. the first two also did this.* |
| **Rollback** | lifeguard · superhero · rolls back anything that goes under | *i have never walked anywhere. only run. in slow motion.* |
| **Sandbox** | the beach dog · fetches everything, returns nothing | *the crab owes me money.* |
| **Crawler** | saviour of the city · protects you from your own code | *tonight i hunt the most dangerous villain of all: works on my machine.* |
| **Sprint** | runner · maps the maze · always late | *i ran twelve miles today. the ticket is still in progress.* |
| **Scope Creep** | lives in the maze · follows every project | *i get bigger every time someone says "quick".* |
| **Professor Well-Actually** | the review pass · trusts nobody | *well, actually… nit: this whole feature.* |

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
