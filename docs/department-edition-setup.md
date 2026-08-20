# Setting up your department's edition

This guide takes you from zero to a live, free website for your department's
version of the textbook. No coding is involved — you will copy a template,
paste in your chapters, change four settings, and click through one hosting
setup. There are a handful of commands to type into a terminal along the way;
each one is given in full, and you only have to copy it. Budget about an hour
the first time.

**What you need before starting:**

- A GitHub account (free — github.com/signup). GitHub is where your edition's
  files live.
- A Cloudflare account (free — dash.cloudflare.com/sign-up). Cloudflare is
  what puts the site on the internet.
- Node.js, version 22 or newer, installed on your computer from nodejs.org —
  download the one labelled **LTS**. You will never write a line of code with
  it; the site's build tools are written in it, and anything older than
  version 22 fails. If you're not sure what you have, open a terminal and run
  `node --version`.
- Your edition's chapters as markdown files (usually your fork of the
  canonical textbook — see `for-course-coordinators.md` for how to make one).

---

## Step 1 — Create your own copy of the template

1. Open the template repository:
   `https://github.com/textbookproject2026-alt/textbook-edition-template`
2. Click the green **Use this template** button (top right), then
   **Create a new repository**. [SCREENSHOT: Use this template button]
3. Give it a name like `textbook-biology-edition`. Leave it set to **Public**
   (the licence requires the content to stay open, and public repos get free
   hosting). Click **Create repository**.

You now have your own copy. Note its address — it will look like
`github.com/YOUR-NAME/textbook-biology-edition`. You'll need the
`YOUR-NAME/textbook-biology-edition` part in Step 3.

### Get a copy on your computer, then run `npm install`

A few jobs can only be done on your own machine rather than in the browser:
updating the site machinery, updating plugins, and checking a build before you
push it. Set that up now, while you're here.

1. Install GitHub Desktop (desktop.github.com) and sign in.
2. **File → Clone repository**, choose the repository you just created, pick a
   folder for it, and click **Clone**. [SCREENSHOT: GitHub Desktop clone dialog]
3. Open a terminal in that folder — in GitHub Desktop,
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
your repository. Open it, click the pencil icon (✏️) to edit, and change the
four lines marked `← EDIT`: [SCREENSHOT: editing quartz.config.yaml]

- **3a. `pageTitle`** — the name shown at the top of every page, e.g.
  `"Biology Edition — <Textbook Title>"`.
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
  `YOUR-NAME/repository-name` part of your repository's address from Step 1.
  This makes the "Edit on GitHub" link on each page point at *your* files.

Click **Commit changes** when done.

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

3. Authorise Cloudflare to see your GitHub account, then pick the repository
   you created in Step 1. Cloudflare can only see what GitHub lets it see, and
   this is where the setup most often stalls: authorise the GitHub account (or
   organisation) that actually *owns* your fork — if you belong to more than
   one, the right one may not be the one offered first — and when GitHub asks
   which repositories Cloudflare may access, grant access to your edition's
   repository specifically. If your repository doesn't appear in Cloudflare's
   list, this permission is the reason; use Cloudflare's **Add account** /
   **configure** link to go back to GitHub and grant it.
   [SCREENSHOT: GitHub repository access screen]
4. In **Set up builds and deployments**, enter exactly:

   | Setting                | Value                                                                       |
   | ---------------------- | --------------------------------------------------------------------------- |
   | Production branch      | `main`                                                                       |
   | Framework preset       | `None`                                                                       |
   | Build command          | `git fetch --unshallow && npx quartz plugin install && npx quartz build`     |
   | Build output directory | `public`                                                                     |

5. Open **Environment variables** on the same screen and add one:
   name `NODE_VERSION`, value `22`. [SCREENSHOT: build settings filled in]
6. Click **Save and deploy**. The first build takes a few minutes; when it
   finishes you get an address like `textbook-biology-edition.pages.dev`.
   That's your live site.

From now on, every time you change a file on GitHub, the site rebuilds and
updates itself within a couple of minutes — you never repeat this step.

The `git fetch --unshallow` part of the build command looks odd but matters:
it lets the site show correct "last updated" dates on pages. Don't trim it.

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
changed", so it's worth knowing which is which. All three are run from your
edition folder on your computer (Step 1).

### 1. Site machinery — run `./sync-upstream.sh`

Layout, components, styling, build fixes: everything about how the site
*works*, as opposed to what it says. These ship through the template
repository. To collect them, open a terminal in your edition folder and run:

```
./sync-upstream.sh
```

It fetches the template's changes, combines them with your copy and pushes the
result, so your live site rebuilds on its own a couple of minutes later. If it
can't finish a step by itself it stops and prints exactly what to do. Run it
whenever the maintainer announces a template update.

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

### 3. Chapter content — copied by hand

When the canonical textbook is revised (once a year), the new text has to be
copied into your `content/` folder the same way you first put it there. No
script does this for you, and `sync-upstream.sh` deliberately leaves `content/`
alone — it treats everything in there as yours. See `for-course-coordinators.md`.
When new chapters arrive, repeat the linked-pages check from Step 2: fresh
chapters bring fresh links, and fresh 404s with them.

## If something goes wrong

**The build fails in Cloudflare.** The most common issue is a typo in
`quartz.config.yaml` — the build log (Deployments → View build) will say which
line. Compare against the template's original file, or contact the project
maintainer with a link to your repository and a copy of the build log.

**`Cannot find package '...'` when you run a command on your computer.** You
haven't run `npm install` in the edition folder yet. Run it there once (Step 1),
then try your command again.

**`The following untracked working tree files would be overwritten by merge`
when running `./sync-upstream.sh`.** You created a file that the template has
since added too, so the update has nowhere to put its copy — Git stops rather
than write over something of yours. The message names the file. Delete your
copy if you don't need it, or rename it if you do (`notes.md` →
`notes-mine.md`), then run `./sync-upstream.sh` again.
