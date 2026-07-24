# Resolving Sync Conflicts

*A companion to the instructions `./sync-upstream.sh` prints when it hits a conflict. If the script sent you here, you're in the right place. Nothing is broken, and nothing you wrote is lost.*

This guide is written for course coordinators, not developers. It assumes you edit your edition in Obsidian and use GitHub Desktop — no command line needed beyond running the sync script itself.

---

## First, take a breath

A merge conflict looks alarming — strange symbols appear inside your files, and the sync stops halfway. But here is the important thing: **a conflict is not an error, and no work has been lost.** Both versions of the disputed text — yours and the template's — are sitting safely in the file, side by side, waiting for you to pick. Git never throws either one away. It just refuses to guess which one you want, because guessing wrong would be worse.

There is also always a safe exit. If at any point you feel out of your depth, skip to [If you're overwhelmed: how to back out safely](#if-youre-overwhelmed-how-to-back-out-safely). Backing out returns everything to exactly how it was before you ran the sync, and you can ask for help with nothing at risk.

## What can — and can't — conflict

Before the mechanics, it helps to know where conflicts actually come from. There are three kinds of file in your edition, and only one kind ever stops the sync:

- **Files you created yourself** — your chapters, images, any new file that only exists in your edition. The template has no version of these at all, so there is *nothing to disagree with*. They can **never** conflict. The sync simply carries them along untouched.
- **Shared content files** (anything under `content/`) — files that exist in both the template and your edition. If both sides changed the same lines, the sync **auto-resolves in your favour** and prints a line like `kept your version of: content/chapters/03-cell-structure.md`. You won't be asked to do anything. (See [Why you'll rarely see content conflicts](#why-youll-rarely-see-content-conflicts-at-all) for the one caveat.)
- **Machinery files** — the site's engine and configuration: `quartz.config.yaml`, `package.json`, anything under `.github/` or `quartz/`. These are **the only place a conflict actually surfaces and waits for you.** They're shared, they're not auto-resolved, and updating them is the whole point of syncing.

So if the sync ever stops and asks you to resolve something, it is almost certainly a machinery file — and most often `quartz.config.yaml`, because that's the one machinery file you deliberately edited during setup. The rest of this guide focuses there.

## What a merge conflict actually is

Your edition is a copy (a "fork") of the shared textbook template. From time to time you run `./sync-upstream.sh` to pull in updates made upstream — improved machinery, fixed workflows, new features. Git's job during a sync is to weave the upstream changes into your copy without disturbing your own edits.

Most of the time this works silently, even when both sides changed the *same file* — as long as they changed *different parts* of it. A conflict only happens when both sides changed the **same lines, or immediately adjacent lines, of the same file** in different ways. At that point git has two competing versions of one passage and no way to know which is right. So it stops, marks the spot, and asks you — the human who understands your edition — to decide.

That's all a conflict is: a question, addressed to you, embedded in the file.

## Reading the conflict markers

When git asks the question, it writes both versions into the file between three markers. Here is the most common real case, and the one we'll use throughout.

During setup you gave your edition its own title, and its own title suffix, in `quartz.config.yaml`:

```yaml
  pageTitle: "Biology Edition — Principles of Life"
  pageTitleSuffix: " · Biology Dept"
```

Meanwhile, upstream changed the *default* suffix that ships with the template (from `" - Department Edition"` to something new). Those two lines sit right next to each other, so git groups them into a single question. Opening `quartz.config.yaml` you find:

```
<<<<<<< HEAD
  pageTitle: "Biology Edition — Principles of Life"
  pageTitleSuffix: " · Biology Dept"
=======
  pageTitle: "EDITION TITLE"
  pageTitleSuffix: " — Department Edition"
>>>>>>> upstream/main
```

Read it like this:

- `<<<<<<< HEAD` — everything below this line, down to the `=======`, is **your version**: your real edition title and your chosen suffix.
- `=======` — the divider between the two versions.
- `>>>>>>> upstream/main` — everything between the divider and this line is **the incoming version** from the template: the placeholder `"EDITION TITLE"` and the template's new default suffix.

The rest of the file, above and below the markers, is untouched and fine. One file can contain several of these blocks — each is a separate question, and each is resolved the same way.

Here, the right answer is to **keep both of your lines** and delete the incoming version entirely — because `pageTitle` and `pageTitleSuffix` are both settings you deliberately changed to name *your* edition. Taking the template's side would silently revert your title to the `"EDITION TITLE"` placeholder. The finished passage should read:

```yaml
  pageTitle: "Biology Edition — Principles of Life"
  pageTitleSuffix: " · Biology Dept"
```

with all three marker lines gone.

## Choosing between the versions

For a machinery conflict you have three honest options. The governing rule — the same one `sync-upstream.sh` prints — is simple: **keep YOUR version of any line you deliberately changed; take the template's version of lines you never touched.**

1. **Keep yours.** The hunk is entirely lines you set on purpose. This is the example above: both `pageTitle` and `pageTitleSuffix` are yours, so you delete the incoming version and the three markers and keep your two lines. The lines you own are the ones naming *your* edition and *your* site — in this template that's the four setup fields: `pageTitle`, `baseUrl`, your Edit-on-GitHub `repo`/`branch`, and `plausibleScriptSrc` (plus `hypothesisGroupId` if you ever set it).
2. **Take theirs.** The hunk is entirely template machinery you never customised — git only flagged it because your edits sat nearby. Delete your version and the markers, keep the incoming text. For machinery you didn't touch, the template's version is the point of syncing.
3. **Combine them.** Often a single hunk mixes one line you own with one line you don't. Suppose you had customised `pageTitle` but left `pageTitleSuffix` at the template default, and upstream improved that default suffix. Then the right resolution keeps *your* `pageTitle` line and takes *their* new `pageTitleSuffix` line:

```yaml
  pageTitle: "Biology Edition — Principles of Life"
  pageTitleSuffix: " — Department Edition"
```

If you're ever unsure which lines are yours, the rule of thumb is: **your lines are the ones naming your edition, your site, and your repo.** Everything else belongs to the template. When even that isn't clear, this is a fine moment to ask for help rather than guess.

Whatever you choose, the finished file must be valid YAML with **all three marker lines deleted**. If any `<<<<<<<`, `=======`, or `>>>>>>>` survives, the site build will fail — so a final read-through of the block is worth the ten seconds.

## Resolving the conflict in GitHub Desktop

The sync script leaves your repository in a paused, mid-merge state. GitHub Desktop understands this state and walks you through it.

1. **Open GitHub Desktop** and make sure your edition's repository is selected in the top-left corner.

   [SCREENSHOT: GitHub Desktop with the edition repository selected, showing the "Resolve conflicts before merge" banner]

2. GitHub Desktop shows a banner or dialog saying there are **conflicted files**, with a list. Each conflicted file has a warning marker next to it; files that merged cleanly are not listed and need nothing from you.

   [SCREENSHOT: the conflicted-files list, one file showing the orange warning icon]

3. Click a conflicted file and choose **"Open in editor"** (or right-click → *Open in Default Editor*). Any plain-text editor is fine — `quartz.config.yaml` also opens in Obsidian if you prefer, where the markers appear as ordinary text.

4. In the editor, find each conflict block (search for `<<<<<<<` to jump straight to them), decide as described above, delete the markers, and **save the file**.

   *Shortcut for clear-cut cases:* if you already know you want one whole side for a given file, right-click the file in GitHub Desktop's list — it offers **"Use the modified file from…"** for each side, resolving the whole file in one click without opening it. (Be careful with `quartz.config.yaml`: a whole-file "use theirs" would wipe your settings, so open that one and resolve it line by line.)

   [SCREENSHOT: the right-click menu on a conflicted file showing the "Use the modified file from…" options]

5. As each file is saved with no markers left, GitHub Desktop's warning icon turns into a **checkmark**. When every file is checked, the **"Continue merge"** button becomes clickable.

   [SCREENSHOT: all conflicts resolved, the "Continue merge" button active]

6. Click **"Continue merge"**. This records the resolved merge in your edition's history.

7. Finally, click **"Push origin"** at the top so your resolved version reaches GitHub. Your site's automatic deployment picks it up from there, same as any other edit.

   [SCREENSHOT: the "Push origin" button with pending commits]

Afterwards, open your site and confirm your title, address, and other settings still read the way you set them. That's the whole job.

## Why you'll rarely see content conflicts at all

The template repository ships a rule — enforced by `sync-upstream.sh` — that tells git: *for files inside the `content/` folder, when both sides changed the same lines, keep the coordinator's version automatically.* Your prose is presumed deliberate — the sync will never silently overwrite a paragraph you rewrote. So content conflicts resolve themselves in your favour before you ever see them, and the sync notes each one with a line like `kept your version of: content/chapters/03-cell-structure.md`.

Two things to understand about this safety net:

**It means upstream text improvements can be silently skipped.** If the template improves a paragraph you also edited, your version wins and you won't be prompted. This is why it's worth **skimming the sync script's summary after each run** — every `kept your version of:` line is a spot where an upstream improvement to that file was set aside in your favour. If the template's release notes mention content improvements, check those files by hand to see whether anything is worth copying into your edition.

**It does not apply outside `content/`.** The machinery of the site — `quartz.config.yaml`, `package.json`, anything under `.github/` or `quartz/` — is not auto-resolved, and conflicts there *will* surface. That's the case this guide is really about, and the [three options above](#choosing-between-the-versions) are how you handle it: keep the lines you deliberately set, take the template's version of everything you didn't touch.

Occasionally a conflict can still surface even inside `content/` — for instance when a file was renamed or deleted upstream rather than edited. The resolution process is exactly the same as above.

## A different problem: "untracked working tree files would be overwritten by merge"

Sometimes the sync stops before any merging happens, with a message like:

```
error: The following untracked working tree files would be overwritten by merge:
        content/glossary.md
Please move or remove them before you merge.
Aborting
```

This is not a merge conflict — there are no markers in any file, and the sync simply refused to start. It happens when **you created a file that the template later added under the same name**. You made your own `content/glossary.md`; a template update now ships its own `content/glossary.md`; git refuses to overwrite yours because, from its point of view, your file is unsaved work it has never been told about.

Because the sync aborted before doing anything, your repository is untouched and completely safe. The fix:

1. **Rename your copy** — e.g. `glossary.md` → `glossary-biology.md` — or move it temporarily out of the folder (your Desktop is fine). Renaming is usually better, because you keep your file inside the edition.
2. **Run `./sync-upstream.sh` again.** It will now complete (or proceed to a normal conflict, handled as above).
3. **Compare the two files.** Open the template's incoming version next to yours and decide: keep the template's, keep yours, or merge the useful parts of both by copy-paste. Delete whichever file you no longer need.

If the error lists several files, do the same for each before re-running.

## If you're overwhelmed: how to back out safely

At any point during conflict resolution — before you click "Continue merge" — you can abandon the whole sync and lose nothing. There are two equivalent ways to do it; use whichever is in front of you.

- **From the command line:** run `bash sync-upstream.sh --abort`. The script's built-in escape hatch calls `git merge --abort` for you and confirms with *"Cancelled. Your edition is back exactly as it was before the update."* This is the same command the sync script points you to when it stops.
- **In GitHub Desktop:** the conflict banner or dialog includes an **"Abort merge"** button. Click it.

[SCREENSHOT: the "Abort merge" button in the conflicts dialog]

Either way, aborting rewinds the sync completely: the conflict markers vanish, the upstream changes are set aside, and every file returns to exactly the state it was in before you ran `./sync-upstream.sh`. Your own edits are untouched. The upstream updates aren't lost either — they're still sitting upstream, and running the sync again next week will offer them again.

Then ask for help. Send the maintainer a short message with three things: which file(s) were conflicted, roughly what you had changed there, and (if you have it) the message the sync script printed. That's everything needed to talk you through it — or to resolve it with you on a call in a few minutes.

Backing out is not failure and not fragile. Coordinators are expected to do it whenever a conflict looks non-obvious. The one thing *not* to do when overwhelmed is to keep editing with markers still in the files — abort instead, and the system guarantees you a clean slate.
