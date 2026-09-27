# Updating department editions

**Audience: the technical contact.** How a change you make reaches the department
editions — and why, most of the time, it doesn't until somebody asks for it.

> **Moved 27 Sep 2026** from book one's `docs/` (BOOK-ONE-TO-QUARTZ §8 step 18 and
> 22). It describes this repository, so it lives here now. "The book's guides" below
> means `textbook-template/docs/`, the set every book's maintainer uses.

The book's `troubleshooting.md` ("A department edition didn't pick up a fix") tells the
author to hand this to you and says "the technical contact gives them the exact
update step". This is that step, plus the model behind it.

The instructions to send a coordinator are beside this file:
[`department-edition-setup.md`](department-edition-setup.md) ("Keeping your edition
up to date") and [`resolving-sync-conflicts.md`](resolving-sync-conflicts.md). That
first file is the *technical* companion to [`for-course-coordinators.md`](for-course-coordinators.md) — the
two agree on how an edition is created (fork) and configured (four settings), and
it is the one that carries the terminal work. Send coordinators there for the
commands; this page is for you.

---

## The one thing to understand: three channels, three mechanisms

A department edition is a fork — and after the 3.4 decision (4 Sep 2026) that is
the *only* supported shape: forking is what both setup guides now instruct, because
the derivatives page's script (`gen-derivatives.mjs`, in the platform's
`quartz-book`) discovers editions through GitHub's forks API and a
"Use this template" copy is invisible to it. **Nothing propagates automatically** —
that is the design, not a defect, because a coordinator teaching from a frozen site
all year is the behaviour the whole system is built around
(the book's `how-versioning-works.md`).

Three different kinds of change reach an edition three different ways, and they
never travel together. Getting these confused is the single biggest source of
"I updated it and nothing changed".

| What changed | Where you change it | How it reaches an edition | Who runs it |
|---|---|---|---|
| **Site machinery** — layout, build config, workflows, the Quartz engine | `textbook-edition-template` | somebody runs `./sync-upstream.sh` | coordinator, **or you on their behalf** |
| **Plugins** — the sidebar, search, table of contents, *Edit on GitHub*, the annotation and analytics integration | `quartz-edition-extras` (ours) or upstream `quartz-community` | somebody runs `npx quartz plugin update <name>` | coordinator, **or you on their behalf** |
| **Chapter content** | `textbook` (this repo) | the coordinator copies files by hand, yearly | coordinator (no terminal) |

Note what is *not* in that table: nothing you can do reaches a live edition on its
own. Every row ends with somebody running something in that edition's own fork.
Your job in all three cases is to publish the change and then **tell coordinators,
naming which channel it is and which command to run.**

**Who runs the two terminal channels is now a per-edition arrangement, not a rule.**
The 3.4 decision kept the coordinators' guide terminal-free for *setup* and the
yearly content copy, and made channels 1 and 2 explicitly optional for them: a
coordinator who doesn't want a terminal is told to hand those two to you or to a
technical contact. So when you take on a new edition, settle that question once and
write down the answer — the failure mode is not a coordinator refusing, it is both
of you assuming the other is doing it while the edition quietly ages.

---

## Channel 1 — site machinery

**You publish it by:** merging to `main` on
`textbookproject2026-alt/textbook-edition-template`.

**They collect it by:** running `./sync-upstream.sh` in their edition folder.

That script fetches the template as a remote, merges it into their copy, and
pushes, so their Cloudflare Pages build kicks off on its own a couple of minutes
later. Things worth knowing before you tell someone to run it:

- **It needs command-line git.** GitHub Desktop on its own does not provide it.
  The script says so, but coordinators who installed only GitHub Desktop during
  setup will hit this.
- **`content/` is theirs, always.** The script treats everything under `content/`
  as the coordinator's: if the template and their content disagree, their version
  wins and it prints `kept your version of: …`. Machinery files are the only place
  a conflict surfaces and waits for a human — most often `quartz.config.yaml`,
  because that is the one machinery file they deliberately edited during setup.
- **`bash sync-upstream.sh --abort`** cancels a half-finished merge and returns the
  edition to exactly where it was. Give coordinators this line at the same time as
  the update instruction; it is the difference between a stuck edition and a
  two-minute retry.
- **The script can update itself.** Its body is wrapped in `main()` with the call on
  the last line, deliberately, because bash reads scripts incrementally and the
  merge can rewrite the file mid-run. If you edit `sync-upstream.sh`, keep that
  shape.

**If a coordinator gets stuck in a conflict**, point them at
[`resolving-sync-conflicts.md`](resolving-sync-conflicts.md) rather than talking
them through it — it is written for someone using Obsidian and GitHub Desktop and
covers the back-out route.

---

## Channel 2 — plugins, and the pinning model

**This is the channel people miss, and it costs the most.**

`sync-upstream.sh` does **not** update plugins, and nothing else does either. They
never change on their own.

Every edition pins each plugin to an exact commit in `quartz.lock.json`. Most come
from the upstream `quartz-community` organisation, and three are the platform's
(since §8 step 22, 27 Sep 2026, all pinned at one extras commit):

| Plugin | What it does |
|---|---|
| `edition-integrations` | the platform's design (`design.yaml`), Hypothes.is, the per-site Plausible script, the tag helper, the annotation badge, paragraph numbers, and the citation and title transforms |
| `edit-on-github` | the controls row under every page title: *Edit on GitHub* and *View revision history* |
| `textbook-graph` | the graph in the right rail, coloured by topic |

Both are installed at build time from
`https://github.com/textbookproject2026-alt/quartz-edition-extras.git`, by subdir.
See that repository's `README.md`.

The pinning is deliberate — an edition's site cannot change under its coordinator
without warning. The price is that a fix only arrives when somebody asks for it:

```
npx quartz plugin update <plugin-name>
```

run in the edition folder, then committed and pushed. **The updated pin *is* the
change** — a coordinator who runs the command but doesn't push keeps building the
old version. `npm install` must have been run in that folder at least once or the
command fails with `Cannot find package '...'`, which reads as though the template
is broken.

### How you publish a plugin change

1. Commit to `quartz-edition-extras` on `main`.
2. Update the pin in the **template's** `quartz.lock.json` — otherwise every new
   edition forked from that point still starts on the old commit.
3. Announce it, naming the plugin, so coordinators can run the update command with
   the right name.

Step 2 is easy to forget and invisible when it is. Which brings us to:

> **Resolved 4 September 2026.** `textbook-edition-template/quartz.lock.json`
> pinned both `edition-integrations` and `edit-on-github` at `eece8e6`, behind
> `quartz-edition-extras` `main` — holding back the whole
> Hypothes.is-across-SPA-navigation fix series and the correction removing the
> Publisher-tier group-lock references. Both pins are now at `8f4e323`, and the
> template builds the current plugin. See `textbook-registry/docs/history/DOCS-REMEDIATION.md` (3.5).

> **Fixed 27 Sep 2026 (§8 step 22), for an edition that has synced since.** The
> note that stood here was half the story. Upstream Quartz's `npx quartz plugin
> install` never installed the locked commit of a `subdir` plugin at all: it cloned
> the extras repo's default branch, copied the subdir, and printed the *lockfile*
> commit. A cached copy was then kept whatever the lock said. So every one of the
> platform's plugins in an edition was extras' `main` as of that edition's last
> fresh install, not its pin. `quartz/cli/plugin-git-handlers.js` now carries a
> *platform patch*: it fetches the pinned commit, fails if it gets another, records
> it in `.quartz/plugins/<name>/.quartz-locked-commit`, and re-clones a copy from
> any other commit. An edition gets the patch with `sync-upstream.sh` (it's site
> machinery). Until then, a deploy that must pick up a plugin bump should clear the
> build cache, or delete the plugin directories, first.

---

## Channel 3 — chapter content

**You publish it by:** the yearly release (the book's `releasing-versions.md`).

**They collect it by:** copying the changed chapter files and the `assets` folder
into their `content/` by hand. `sync-upstream.sh` deliberately leaves `content/`
alone.

Nothing here is yours to run. The one thing worth saying in the release email, and
the one coordinators most often get wrong, is that **a localised chapter that was
overwritten needs its localisation re-applied** — which is why the coordinators'
guide tells them to keep a `LOCAL-CHANGES.md` in their `content/` folder.

---

## Diagnosing "the fix didn't arrive"

Work down this list; it separates the three channels quickly.

1. **Has their site rebuilt at all recently?** Check the Deployments list in their
   Cloudflare Pages project. If the newest deployment predates your change, nothing
   has been picked up regardless of channel, and the question is why their build
   stopped — not which command to run.
2. **Is it text, or is it behaviour?** Text is channel 3 and may well be
   deliberate: a frozen site during a teaching year is what
   the book's `how-versioning-works.md` recommends.
3. **Is it a button, the sidebar, the annotation layer, or analytics?** That is
   channel 2, a plugin, and the answer is `npx quartz plugin update <name>` plus a
   push. Nine times in ten this is the one, because it is the channel nothing
   prompts them about.
4. **Is it layout, styling or the build itself?** Channel 1, `./sync-upstream.sh`.
5. **Still nothing?** Check that the pin you expect actually shipped — see the
   notes above. The fix may never have left the plugin repo, or the build may have
   reused a stale plugin cache and reported the new commit regardless.

---

## Announcing an update

Whatever the channel, an announcement that doesn't name the channel produces a
round of confused email. Include:

- **which of the three** it is, in plain words ("this is a plugin fix");
- **the exact command**, copy-pasteable, including the plugin name;
- **`bash sync-upstream.sh --abort`** as the escape hatch, if it is channel 1;
- **that the change is only live once they push**, for channels 1 and 2 both.

---

## Settled: the 3.4 decision, and what it changed here

`textbook-registry/docs/history/DOCS-REMEDIATION.md` item **3.4** was decided on 4 September 2026. It used to
be the open question on this page: [`for-course-coordinators.md`](for-course-coordinators.md) promised
coordinators they would never type a terminal command, while both machinery
channels above require one.

What was decided, and what it means for you:

- **Forking is the canonical way to create an edition**, and "Use this template" is
  now warned against in both setup guides. Discovery via the forks API stands;
  `gen-derivatives.mjs` needs no change. An edition missing from the
  department-editions page is worth checking as a possible template-copy before you
  chase it as a workflow fault (`textbook-registry/docs/SCHEDULED-JOBS.md`, `derivatives`).
- **The no-terminal promise was scoped, not dropped.** Setup and the yearly content
  copy stay terminal-free; channels 1 and 2 are stated plainly as needing one, and
  as reassignable to you.
- **Both setup guides survive, with an explicit split.**
  [`for-course-coordinators.md`](for-course-coordinators.md) is the coordinator's walkthrough;
  [`department-edition-setup.md`](department-edition-setup.md) is the technical
  companion and now carries the maintenance commands. Each names the other and
  states where their step numbers differ.

The mechanics on this page were never affected by the decision — `sync-upstream.sh`
works over a git remote either way. Only the "who runs it" column moved.
