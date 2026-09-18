# The status page

A full-screen scene showing what the crew is doing. One HTML file and one JSON file, so any
host that can serve a folder can serve it.

## Where it lives

`/claudrunner:init` asks. You can change it later in `.claudrunner/config.yml`.

| Choice | How you open it | Who can see it |
|---|---|---|
| **On this computer** | `/claudrunner:dashboard` — starts a small local server and opens the page | only you |
| **GitHub Pages** | `https://<owner>.github.io/<repo>/`, or your own domain | anyone with the link |
| **Your own server** | a subdomain like `crew.example.com`, or a path like `example.com/claudrunner/` | whoever your server lets in |
| **No page** | — | — |

**Every installation has its own page.** claudrunner has no central server and never sees your
data: each repository publishes its own runs to its own address. Nobody sees another team's
crew unless they have that team's link.

**A GitHub Pages site is public**, even the link nobody has shared. So on Pages the page shows
task numbers instead of titles by default. Set `dashboard.show_titles: true` if your titles are
safe to show.

**On GitHub Pages**, runs publish to a branch called `claudrunner-status`, and Pages serves that
branch. Switch it on once: **Settings → Pages → Deploy from a branch → `claudrunner-status` /
root**. The branch appears after the first run. For your own domain, set `dashboard.domain` and
add a CNAME record pointing at `<owner>.github.io`.

**On your own server**, runs copy the page into `dashboard.server.webroot` when the crew runs on
that server, or upload it to `dashboard.server.ssh_target` from CI. nginx snippets for a
subdomain and for a path ship in the plugin's `templates/hosting/`.

## What you are looking at

**Every active run is a robot typing at a laptop**, with its task and progress on a card
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

Four, on the **SCENE** button. The crew changes with the world — different uniform,
different animal, different jokes.

| Scene | The world | The crew | Who follows them |
|---|---|---|---|
| 🌆 **City** | A real skyline: window grids, water tanks, aerials. A road with traffic, and a brick corner shop whose neon sign — and the sign on its door — reads **OPEN** while the crew works and **CLOSED** when the queue is empty. Its windows go dark when it closes | Hard hats | **Sir Wigglebutt** — black and white, red collar, leaves things behind |
| 🏝 **Beach** | Sea with surf, palms, a sandcastle, bucket and spade, a starfish, a striped towel, a crab, and a lifeguard hut for the reviewer | Sunglasses and real inflatable rings | **Sandbox** — golden, fetches everything, returns nothing |
| 🌑 **Space** | Black sky with the galaxy band, a ringed planet, Earth with its atmosphere, craters, boulders, a lunar base, a rocket on its pad. The sun only by day | Helmets and life support | A hovering drone |
| 🧱 **Maze** | Stone corridors, ivy, a shaft of light, something at the far end | Hoods and satchels | A lizard |

Each works in day and night, and your choice is remembered.
`?scene=city|beach|space|maze` pins one.

## They do things

Every few seconds a robot jumps, spins, shrugs, or falls flat on its back and gets up. Now
and then one dances instead — and **each robot has its own dance**, so a crew never moves in
unison: one sways side to side, one shuffles, one bounces, one spins and hops.

**When something ships, the whole crew dances at once**, each its own dance. Press **D** to
start one yourself.

**Every minute or so in the city**, Sir Wigglebutt stops, has a look around, squats, and leaves
something steaming on the pavement. He walks off without looking back. A masked figure swings
in on a line, webs it, and carries it off into the sky. Press **P** to see it on demand, or
add `?slow=4` to watch every beat at a quarter speed.

## Sprint and Scope Creep, in the maze

Every minute or so in the maze, the ground shakes and the gate doors start to close. **Sprint** — a
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

## The pep talk, in every scene

About once a minute, Professor Well-Actually takes the rope off his belt. He bonks every robot
on the head, one at a time, nearest first — *"WE ARE FRIENDS. TYPE FASTER, FRIEND."* The robot
sees stars and types twice as fast for a few seconds (*"is this team building?"*). He aims
at where each robot is right now, so one robot gets one bonk and three get three. An empty
crew gets none.

`R` starts it. `?rope=1` starts it as soon as the page loads.

## Rollback, on the beach

Every half minute or so on the beach, Sandbox chases the ball — *"BALL. BALL. BALL. BALL."* — straight
into the sea, and discovers he cannot swim. *"BLUB. HELP. BLUB."* *"I AM A RETRIEVER. I FORGOT
THE RETURN STATEMENT."*

A whistle. From the right, in slow motion, comes **Rollback**: lifeguard, superhero, red trunks,
red cape, orange rescue can, and hair that moves on its own. He dives in, swims out, and brings
Sandbox back under one arm: *"HOLD ON, BUDDY. ROLLING YOU BACK."* Sandbox shakes himself dry
all over him. *"ROLLED BACK TO LAST KNOWN GOOD STATE."* Then Sandbox notices the ball is still
out there. Rollback puts his face in his hand: *"NO. NO NO NO NO."*

## Captain Latency, in space

Every half minute or so in space, **the Intern** — first day on the moon, still onboarding —
steps out of the base. *"LOW GRAVITY. DAY ONE. WHEEE!"* Three hops, each bigger than he meant.
The fourth goes up and keeps going. *"…uh."* *"GRAVITY? HELLO? GRAVITY?"*

A streak across the sky: **Captain Latency** catches him and flies him back down in under a
second. Not a word is said. They stand there. Then his messages arrive, one at a time, each
marked with when he sent it: *"HOLD ON!"* *(sent 6 seconds ago)*, *"I'M COMING!"*, *"GOT YOU!"*
The Intern: *"…thanks? your messages are only arriving now."* Captain Latency: *"YES. THEY DO
THAT."* *"also, why does your cape stick out? there is no air up here."* *"BRAND
CONSISTENCY."* He leaves in a streak. His *"BYE!"* arrives a second later.

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
| **The Intern** | astronaut · first day on the moon · still onboarding | *they said low gravity. they did not say how low.* |
| **Captain Latency** | space superhero · always arrives, eventually | *i travel at the speed of light. my messages do not.* |
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

Every run refreshes the page when work starts and again when it ends. On this computer,
`/claudrunner:dashboard` also refreshes it every twenty seconds.

**With no run records yet, the page runs a simulation and says so** — the chip reads
`SIMULATION` instead of `LIVE`. It is never blank, and it never shows invented numbers while
implying they are real.

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
