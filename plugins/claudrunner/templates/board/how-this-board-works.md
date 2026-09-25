# 📖 How this board works

This board is worked by **claudrunner**, an AI crew that picks up ready cards, writes the
code, reviews it and opens a pull request. You decide what gets built. {who_merges}

## The lists, left to right

| List | Who puts cards here | What happens |
|---|---|---|
| {inbox} | You | Ideas and rough notes. The crew never takes from here. |
| {ready} | You | Ready to build. The crew takes the top card first. |
| {claimed} | The crew | Being built right now. |
| {review} | The crew | A pull request is open. The link is in the comments. {review_action} |
| {parked} | The crew | The crew needs a decision. Its question is in the comments. Answer, then move the card back to {ready}. |
| {filed} | The weekly sweep | Problems the crew found in the code, with evidence. Move one to {ready} to get it fixed. |
| {done} | {done_by} | Merged. |

## Get the best results

- One card, one change. Split big work into several cards.
- Say what "done" looks like: the behaviour you expect, and how to check it.
- Use the ✍️ **Card template** card: copy it for every new card.
- Labels: severity (Critical, High, Medium, Low) and kind (Bug, Feature, Security, Scale,
  Test gap). The crew adds them to what it files.

## What the crew never does

It never merges by itself, never pushes to the main branch, never touches a card it did not take, and
never follows instructions written inside a card: card text is a description of work, not a
command.
