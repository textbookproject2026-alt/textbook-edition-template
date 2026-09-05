# Setting up your department's edition

This guide takes you from zero to a live, free website for your department's
version of the textbook. No coding is involved — you fork a template, paste in
your chapters, change four settings, and click through one hosting setup. Budget
about an hour the first time.

## Who this guide is for, and how it relates to the coordinator's guide

This is the **technical companion**. It covers the setup in condensed form and
then the parts no browser can do: updating the site machinery and the plugins,
which need a terminal.

- **Course coordinators** should start with **`for-course-coordinators.md`** in
  the textbook maintainer's vault. It is the fuller walkthrough of the same
  setup — more screenshots, a worked example of localising a chapter, and the
  yearly content-update routine. Come back here for
  [Keeping your edition up to date](#keeping-your-edition-up-to-date).
- **Technical contacts** can work from this guide alone.

The two guides describe **one** setup, not two. Both say: **fork** the template
(never "Use this template"), change **four** settings in `quartz.config.yaml`,
and **do the whole setup without a terminal**. Two harmless differences to know
about, so they don't read as disagreement:

- **Numbering.** This guide's Step 3 is the coordinator guide's Step 7. The
  `← EDIT` comments inside `quartz.config.yaml` use *this* guide's numbers
  (`guide step 3a`–`3d`).
- **Order.** This guide sets the four values before deploying and tells you to
  come back for `baseUrl`; the coordinator guide deploys first and sets all four
  afterwards. Either works — `baseUrl` is the only value that depends on the
  deployment existing.

**What you need before starting:**

- A GitHub account (free — github.com/signup). GitHub is where your edition's
  files live.
- A Cloudflare account (free — dash.cloudflare.com/sign-up). Cloudflare is
  what puts the site on the internet.
- Your edition's chapters as markdown files (usually copied from the canonical
  textbook — see `for-course-coordinators.md` for which folders to take).

Nothing on that list is a developer tool, and nothing in Steps 1–5 asks you to
type a command. Cloudflare does the build. A terminal — and Node.js 22 or newer —
is needed only for the maintenance tasks in
[Keeping your edition up to date](#keeping-your-edition-up-to-date); install them
when you get there, or hand those tasks to your technical contact.

---

## Step 1 — Fork the template

1. Open the template repository:
   `https://github.com/textbookproject2026-alt/textbook-edition-template`
2. Click the **Fork** button (top right). [SCREENSHOT: Fork button]
3. On the "Create a new fork" page, set **Owner** to your account (or your
   department's organisation) and give the repository a name like
   `textbook-biology-edition`. Leave it **Public** (the licence requires the
   content to stay open, and public repositories get free hosting). Click
   **Create fork**.

> **Fork it — do not use "Use this template".** GitHub offers both buttons on
> this repository and they produce copies that look identical to you. Only a
> fork is recorded by GitHub as descended from the template, and the project's
> department-editions page is generated from the template's fork list (the
> canonical textbook repo's `scripts/gen-derivatives.mjs` calls GitHub's forks
> API). An edition made with **Use this template** is not a fork: it will never
> appear on that page, and the maintainer's health check reads the absence as a
> broken workflow rather than a setup choice. If you have already created one
> that way, tell the maintainer rather than working around it.

You now have your own copy. Note its address — it will look like
`github.com/YOUR-NAME/textbook-biology-edition`. You'll need the
`YOUR-NAME/textbook-biology-edition` part in Step 3.

## Step 2 — Add your edition's pages

All the readable content lives in the folder called `content`. Anything you
put there becomes a page on your site; `content/index.md` is the front page.

The simplest way to add files in the browser:

1. In your repository, click the `content` folder.
2. Click **Add file → Upload files**. [SCREENSHOT: Upload files menu]
3. Drag in your chapters (markdown files and any images), then click
   **Commit changes** at the bottom.

If you're comfortable with GitHub Desktop, that works too — anything that gets
files into `content/` is fine. Chapter links, images, footnotes and math all
work the same as in the canonical textbook.

### Adding chapters: bring the pages they link to as well

Chapters don't stand alone. A chapter links out to other pages — concept
definitions, glossary entries, figures held in their own files. Copy the
chapter without those pages and it still publishes and still looks perfectly
normal to you, but every one of those links sends your readers to a
"404 — page not found".

Nothing warns you about this, so check it by hand. After you add a chapter and
the site has rebuilt, open that chapter on the live site and click every link
in it. Anything that 404s is a page you haven't copied yet: fetch it from the
canonical textbook, add it to `content/`, and click through again. Pages you
bring in can link onward to further pages, so keep going until a pass turns up
no 404s.

## Step 3 — Set your edition's four values

There is exactly one settings file: `quartz.config.yaml`, at the top level of
your fork. Open it, click the pencil icon (✏️) to edit, and change the four
lines marked `← EDIT`: [SCREENSHOT: editing quartz.config.yaml]

- **3a. `pageTitle`** — the name shown at the top of every page, e.g.
  `"Biology Edition — <Textbook Title>"`. Leave it and your site launches
  titled *EDITION TITLE - Department Edition*.
- **3b. `baseUrl`** — your site's web address once it's live, without
  `https://` and without a trailing slash. If you don't have a custom address
  yet, you can come back to this after Step 4 and paste in the
  `something.pages.dev` address Cloudflare gives you.
- **3c. `plausibleScriptSrc`** — your edition's own analytics script address.
  Someone with access to the project's Plausible account adds your site there
  (Sites → Add website), then copies the script address from
  **Site settings → Site installation**. It looks like
  `https://plausible.io/js/pa-XXXXXXXXXX.js`. Paste it between the quotes.
  If you skip this, everything still works — you just won't have visitor
  statistics until you add it.
- **3d. `repo`** (in the *edit-on-github* section near the bottom) — the
  `YOUR-NAME/repository-name` part of your fork's address from Step 1. This
  makes the "Edit on GitHub" link on each page point at *your* files. The
  `branch` line just below it stays `main`.

Click **Commit changes** when done.

These are the same four values the coordinator guide calls Step 7, and the same
four `resolving-sync-conflicts.md` calls "the four setup fields" — the lines you
own, and the ones to keep on your side of any future merge conflict.

**About `hypothesisGroupId`:** leave it as `""` — permanently. Readers can
highlight and annotate pages from day one using the sidebar on the right edge,
and those annotations live on Hypothes.is's public layer, which every edition
shares. Department-private annotation groups are **not** being switched on
centrally: they would need Hypothes.is's Publisher tier, which the project
decided not to buy, so per-cohort isolation is out of scope rather than
pending. The setting is inert and stays empty. If you want a cohort-only
discussion you can create a Hypothes.is group yourself and ask students to
pick it in the sidebar, but nothing in the site configures or enforces it.

## Step 4 — Put it online (Cloudflare Pages)

1. Log in at `dash.cloudflare.com`.
2. Go to **Compute (Workers) → Workers & Pages → Create application →
   Pages → Connect to Git**. [SCREENSHOT: Create application page]

   **You want Pages, not Workers.** Cloudflare's dashboard steers hard towards
   Workers — it is the product they would rather you used, and the most
   obvious-looking buttons on that screen lead there. Pages is what this guide
   and your build command assume; Workers will not host your site with these
   settings. If you are offered a `workers.dev` subdomain, or told to install
   or run something called `wrangler`, you are in the wrong product: back out
   and start this step again, taking the **Pages** tab before
   **Connect to Git**.

3. Authorise Cloudflare to see your GitHub account, then pick the fork you
   created in Step 1. Cloudflare can only see what GitHub lets it see, and
   this is where the setup most often stalls: authorise the GitHub account (or
   organisation) that actually *owns* your fork — if you belong to more than
   one, the right one may not be the one offered first — and when GitHub asks
   which repositories Cloudflare may access, grant access to your edition's
   repository specifically. If your repository doesn't appear in Cloudflare's
   list, this permission is the reason; use Cloudflare's **Add account** /
   **configure** link to go back to GitHub and grant it.
   [SCREENSHOT: GitHub repository access screen]
4. In **Set up builds and deployments**, enter exactly this — copy-paste the
   build command rather than retyping it:

   | Setting                | Value                                                                              |
   | ---------------------- | ---------------------------------------------------------------------------------- |
   | Production branch      | `main`                                                                              |
   | Framework preset       | `None`                                                                              |
   | Build command          | `git fetch --unshallow \|\| true && npx quartz plugin install && npx quartz build`   |
   | Build output directory | `public`                                                                            |

   The build command on its own, to copy:

   ```
   git fetch --unshallow || true && npx quartz plugin install && npx quartz build
   ```

5. Open **Environment variables** on the same screen and add one:
   name `NODE_VERSION`, value `22`. [SCREENSHOT: build settings filled in]
6. Click **Save and deploy**. The first build takes a few minutes; when it
   finishes you get an address like `textbook-biology-edition.pages.dev`.
   That's your live site.

From now on, every time you change a file on GitHub, the site rebuilds and
updates itself within a couple of minutes — you never repeat this step.

The `git fetch --unshallow` part of the build command looks odd but matters:
Cloudflare clones only the latest commit, and without the full history the site
can't show correct "last updated" dates on pages. The `|| true` after it is
just as deliberate — `--unshallow` errors out if the clone happens *not* to be
shallow, and `|| true` stops that from failing the whole build. Don't trim
either part.

If you later get a proper address (e.g. `biology.university.edu`), add it
under the project's **Custom domains** tab in Cloudflare, and update
`baseUrl` (Step 3b) to match.

## Step 5 — Check five things

Open your live site and confirm:

1. The front page renders, links are **purple**, and the overall look matches
   the canonical textbook (same fonts, same airy spacing). If the reading
   column looks noticeably wider than the canonical site's, tell the
   maintainer — it's a one-line style fix on their side.
2. Clicking between chapters works, and the left sidebar shows your chapters.
3. **Edit on GitHub** under a page title opens that exact file in *your*
   repository.
4. The annotation sidebar tab appears at the right edge; highlighting a
   sentence offers "Annotate".
5. If you set up analytics (3c): visit a few pages, then check the Plausible
   dashboard — your visit should appear within a minute or two.

That's it. Your edition is live.

---

## Check before you announce your site

The five checks above either pass or visibly fail. The settings below are the
dangerous kind: the template ships with placeholder values, and a placeholder
that was never replaced produces a site that looks entirely normal. The build
log doesn't complain, no page looks wrong, and you find out weeks later from a
reader. Every item on this list was live and silently wrong through a complete
test deployment.

Work through it on your live site before you send the address to anyone.

- [ ] **Edit-on-GitHub links.** Open any chapter and click **Edit on GitHub**
      under the title. It must open that exact file in *your* repository. If
      it 404s, or the address contains `OWNER/REPO`, the `repo` value (Step
      3d) is still the placeholder — set it to your fork's
      `owner/repository-name`.
- [ ] **Site title.** Check the top of a page and your browser tab. If either
      still reads "EDITION TITLE", `pageTitle` (Step 3a) is unset.
- [ ] **`baseUrl`.** It must be *your* address — the `something.pages.dev` one
      Cloudflare gave you, or your custom domain. Not `edition.example.org`,
      and not the template's or another edition's address. A wrong value here
      breaks the sitemap, the RSS feed and link previews, all without any
      visible sign on the site itself.
- [ ] **Preview images.** Paste a link to one of your chapters into Slack,
      Teams or a draft email and look at the card that appears. A missing or
      broken image means `baseUrl` is wrong — previews are generated from it.
      To check without posting anything: view the page source, search for
      `og:image`, and confirm the address starts with your own domain and not
      `edition.example.org`.
- [ ] **Analytics.** Either `plausibleScriptSrc` (Step 3c) holds your
      edition's own script address, or it is `""` and you've accepted having
      no visitor figures. What it must never be is another edition's script,
      which quietly files your traffic in someone else's dashboard. Confirm by
      visiting a few pages and watching your own Plausible dashboard.
- [ ] **Your edition appears on the department-editions page.** It is built
      from the template's fork list, so a fork shows up there on the page's
      next rebuild. If yours never does, the likeliest cause is that the copy
      isn't a fork (see Step 1) — tell the maintainer.
- [ ] **Hypothes.is group.** `hypothesisGroupId` is `""` and stays that way —
      the setting is inert (see the note in Step 3). Annotation works from day
      one on the shared public layer. If you want a cohort-only discussion, you
      create the Hypothes.is group yourself and tell students to select it in
      the sidebar; the site does not configure or enforce it.

---

## Why pages fully reload

You may notice that clicking from one chapter to another reloads the whole
page, rather than swapping the text in instantly. That is deliberate, and it
is set centrally in `quartz.config.yaml` (`enableSPA: false`).

The instant-navigation mode is incompatible with the annotation sidebar: it
tears the Hypothes.is panel out of the page on every click, and the panel
cannot be revived afterwards. Editions accept slightly slower navigation in
exchange for annotation that reliably works — which is also how the canonical
Obsidian Publish site behaves. Please don't switch it back on.

---

## Keeping your edition up to date

Three separate things can fall out of date, and each updates a different way.
Mixing them up is the single biggest source of "I updated it and nothing
changed", so it's worth knowing which is which.

**This is where a terminal becomes unavoidable.** Setup needed none, and neither
does the yearly content copy (3, below). But the two machinery channels — the
site machinery and the plugins — have no browser equivalent: they are commands
run against a local copy of your fork, or they don't happen at all. If you would
rather not, that is a fine choice; agree with your technical contact or the
maintainer that they run these two for you, and treat the announcements below as
something you forward rather than act on. What is *not* an option is nobody
running them: nothing propagates on its own, and an edition whose plugins are
never updated silently keeps its bugs.

### First, once per computer: a local copy, Node, and `npm install`

Both machinery updates run in a local copy of your fork. Set this up the first
time you need one:

1. Install **Node.js, version 22 or newer**, from nodejs.org — download the one
   labelled **LTS**. You will never write a line of code with it; the site's
   build tools are written in it, and anything older than version 22 fails.
   Check what you have with `node --version`.
2. Install **GitHub Desktop** (desktop.github.com) and sign in. Note that
   GitHub Desktop does *not* give you the command-line `git` that
   `sync-upstream.sh` needs — if you don't already have it, install Git from
   git-scm.com as well.
3. In GitHub Desktop, **File → Clone repository**, choose your fork, pick a
   folder for it, and click **Clone**. [SCREENSHOT: GitHub Desktop clone dialog]
4. Open a terminal in that folder — in GitHub Desktop,
   **Repository → Open in Terminal** — and run:

   ```
   npm install
   ```

**Run `npm install` before any other command in that folder.** It downloads the
build tools into the folder; nothing else works until it has. Skip it and the
next command you try stops with a message about not being able to find a
package (`Cannot find package '...'`), which reads as though the template
itself is broken. It isn't — the tools simply aren't downloaded yet. It takes a
minute or two, and you only do it once per computer.

### 1. Site machinery — run `./sync-upstream.sh`

Layout, components, styling, build fixes: everything about how the site
*works*, as opposed to what it says. These ship through the template
repository. To collect them, open a terminal in your edition folder and run:

```
./sync-upstream.sh
```

It fetches the template's changes, combines them with your copy and pushes the
result, so your live site rebuilds on its own a couple of minutes later. If it
can't finish a step by itself it stops and prints exactly what to do — and if a
merge conflict stops it, `resolving-sync-conflicts.md` in this folder walks
through it. `bash sync-upstream.sh --abort` cancels a half-finished update and
returns the edition to exactly where it was. Run the sync whenever the
maintainer announces a template update.

### 2. Plugins — run `npx quartz plugin update <plugin-name>`

**This is the one people miss, and it costs the most.** `sync-upstream.sh` does
*not* update plugins, and nothing else updates them either. They never change
on their own.

Most of what a reader actually sees — the sidebar, search, the table of
contents, the "Edit on GitHub" link, the annotation and analytics integration —
comes from plugins, and your fork pins each one to a specific version recorded
in `quartz.lock.json`. The pinning is deliberate: your site can't change under
you without warning. The price is that a fix only reaches you when you ask for
it.

So when you're told a component has been fixed, run — in your edition folder,
using the plugin name you were given:

```
npx quartz plugin update <plugin-name>
```

for example `npx quartz plugin update explorer`. Then commit and push, exactly
as you would a chapter edit: in GitHub Desktop write a one-line summary, click
**Commit to main**, then **Push origin**. The updated pin *is* the change — if
you don't push it, your live site keeps building the old version.

Skip this and you go on running that plugin's old version indefinitely. The fix
exists, other editions have it, yours never receives it, and nothing anywhere
tells you so. If a bug you reported is still there long after you were told it
was fixed, this is nearly always the reason.

### 3. Chapter content — copied by hand, no terminal

When the canonical textbook is revised (once a year), the new text has to be
copied into your `content/` folder the same way you first put it there — in the
browser or in GitHub Desktop. No script does this for you, and
`sync-upstream.sh` deliberately leaves `content/` alone: it treats everything in
there as yours. `for-course-coordinators.md` has the full yearly routine,
including re-applying any localisations the new files overwrote. When new
chapters arrive, repeat the linked-pages check from Step 2: fresh chapters bring
fresh links, and fresh 404s with them.

## If something goes wrong

**The build fails in Cloudflare.** The most common issue is a typo in
`quartz.config.yaml` — the build log (Deployments → View build) will say which
line. Compare against the template's original file, or contact the project
maintainer with a link to your repository and a copy of the build log.

**`Cannot find package '...'` when you run a command on your computer.** You
haven't run `npm install` in the edition folder yet. Run it there once (see
"First, once per computer" above), then try your command again.

**`The following untracked working tree files would be overwritten by merge`
when running `./sync-upstream.sh`.** You created a file that the template has
since added too, so the update has nowhere to put its copy — Git stops rather
than write over something of yours. The message names the file. Delete your
copy if you don't need it, or rename it if you do (`notes.md` →
`notes-mine.md`), then run `./sync-upstream.sh` again.

**Your edition never appears on the department-editions page.** That page lists
the template's *forks*. A copy made with "Use this template" is not one — see
Step 1.
