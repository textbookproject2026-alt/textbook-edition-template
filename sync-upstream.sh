#!/usr/bin/env bash
#
# sync-upstream.sh — update your department edition's SITE MACHINERY
# ===================================================================
#
# WHAT THIS UPDATES
#   The site machinery only: the Quartz engine, build workflows and
#   plugins. It pulls the latest version from the template repository
#   your edition was forked from:
#
#       https://github.com/textbookproject2026-alt/textbook-edition-template
#
# WHAT THIS DOES *NOT* UPDATE
#   Your textbook chapters. Content updates are a separate, manual copy
#   from the canonical textbook (textbookproject2026-alt/textbook) —
#   see docs/for-course-coordinators.md, "When the textbook updates
#   (yearly)". This script treats everything inside content/ as yours:
#   if the template and your content ever disagree, your version wins.
#
# HOW TO RUN IT
#   You need Git installed from https://git-scm.com — note that GitHub
#   Desktop on its own does NOT provide the command-line "git" this
#   script uses.
#
#   Windows:  open your edition folder in File Explorer, right-click an
#             empty area, choose "Open Git Bash here", then type:
#                 bash sync-upstream.sh
#   Mac:      open Terminal (Cmd+Space, type "Terminal"), type
#             "bash " (with a trailing space), drag this file onto the
#             Terminal window, press Enter.
#
#   To cancel a half-finished update at any point:
#                 bash sync-upstream.sh --abort
#
# WHAT IT DOES, IN ORDER
#   1. Safety checks: right folder, right branch, all your work saved.
#   2. Catches up with YOUR OWN copy on GitHub first (picks up edits you
#      made directly on github.com, e.g. the Step-7 settings).
#   3. Downloads the latest template machinery ("fetch").
#   4. Combines it with your copy ("merge").
#        - No overlap with your edits: fully automatic.
#        - Overlap: it stops and prints step-by-step instructions for
#          GitHub Desktop. Nothing is lost at that point.
#   5. Uploads the result to GitHub ("push") so your live site rebuilds.
#
# NOTE FOR MAINTAINERS
#   The script body below runs inside main(), and the call to main is the
#   last line of the file. That is deliberate: the merge this script
#   performs can update sync-upstream.sh ITSELF, and bash reads script
#   files incrementally — if the file changes mid-run, bash executes
#   garbage from the new file at old byte offsets. Wrapping the body in a
#   function forces it to be fully parsed into memory before the merge
#   can touch the file. Keep it that way. (The --abort handler stays
#   outside main: it never merges, so it's safe, and it must work even if
#   a future main() is broken.)
#
# -------------------------------------------------------------------

# Fail on use of unset variables (catches script bugs). We deliberately
# do NOT use "set -e": a merge conflict makes git exit non-zero, and we
# need to keep running to print the instructions instead of dying.
set -u

UPSTREAM_URL="https://github.com/textbookproject2026-alt/textbook-edition-template.git"
BRANCH="main"
GUIDE="docs/for-course-coordinators.md"

# Always operate on the folder this script lives in, regardless of where
# it was launched from (the Mac drag-onto-Terminal method, for example,
# leaves the terminal sitting in the user's home folder).
cd "$(dirname "$0")" || exit 1

# ----- "--abort" escape hatch --------------------------------------
# Cancels a half-finished update and returns the edition to exactly the
# state it was in before this script last ran.
if [ "${1:-}" = "--abort" ]; then
    if git rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; then
        git merge --abort
        echo "Cancelled. Your edition is back exactly as it was before the update."
    else
        echo "Nothing to cancel — no update is in progress."
    fi
    exit 0
fi

main() {

echo ""
echo "Updating site machinery from the template repository."
echo "(Textbook chapters are NOT updated by this — that is a separate"
echo "manual copy from the canonical textbook. See $GUIDE.)"
echo ""

# ----- Safety check 1: are we inside the edition repo? --------------
# Two tests: inside a git repo at all, AND it's the edition (any stray
# git folder would pass the first test alone).
if ! git rev-parse --git-dir >/dev/null 2>&1 || [ ! -f quartz.config.yaml ]; then
    echo "PROBLEM: this doesn't look like your edition folder."
    echo "Move this script back to the top level of your edition folder"
    echo "(next to quartz.config.yaml) and run it from there."
    exit 1
fi

# ----- Safety check 2: is a previous update half-finished? ----------
# Happens if a past run hit a conflict that was never resolved. Running
# a second merge on top would only deepen the confusion, so stop here.
if git rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; then
    echo "PROBLEM: a previous update is still half-finished."
    echo ""
    echo "Either finish it in GitHub Desktop (resolve the listed files,"
    echo "then click \"Continue merge\"), or cancel it by running:"
    echo ""
    echo "    bash sync-upstream.sh --abort"
    exit 1
fi

# ----- Safety check 3: are we on the main branch? -------------------
# Coordinators shouldn't have other branches, but GitHub Desktop makes
# it easy to create one by accident.
CURRENT_BRANCH=$(git symbolic-ref --short -q HEAD || echo "")
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    echo "PROBLEM: your edition is currently on \"$CURRENT_BRANCH\","
    echo "but updates go onto \"$BRANCH\"."
    echo ""
    echo "In GitHub Desktop, click the \"Current Branch\" dropdown at the"
    echo "top, choose \"$BRANCH\", then run this script again."
    exit 1
fi

# ----- Safety check 4: is all your work saved to Git? ---------------
# Merging on top of unsaved edits can tangle your changes together with
# the template's. Insisting on a commit first means a conflict can
# always be cancelled cleanly with --abort, losing nothing.
if [ -n "$(git status --porcelain)" ]; then
    echo "PROBLEM: you have changes that aren't saved to Git yet."
    echo ""
    echo "Open GitHub Desktop, write a short summary in the box at the"
    echo "bottom-left, click \"Commit to main\", then run this script again."
    exit 1
fi

# ----- Safety check 5: does git know who you are? -------------------
# The merge below creates a commit, and commits need a name and email.
# GitHub Desktop configures this on first sign-in, so this only fires
# on unusual setups.
if [ -z "$(git config user.email || true)" ]; then
    echo "PROBLEM: git doesn't know who you are yet, so it can't record"
    echo "the update under your name."
    echo ""
    echo "Open GitHub Desktop once and sign in (File > Options > Accounts"
    echo "on Windows, GitHub Desktop > Settings > Accounts on Mac), then"
    echo "run this script again."
    exit 1
fi

# ----- Catch up with YOUR OWN copy on GitHub first ------------------
# The setup guide (Step 7) has coordinators edit quartz.config.yaml
# directly on github.com, so the fork on GitHub is often ahead of this
# computer. Without this step, the final upload would be rejected and
# the coordinator stranded. Fast-forward only: this step must never
# invent a merge of its own.
if ! git fetch origin "$BRANCH" --quiet; then
    echo "PROBLEM: couldn't reach GitHub."
    echo "Check your internet connection and run this script again."
    exit 1
fi
LOCAL_BEFORE=$(git rev-parse HEAD)
if ! git merge --ff-only "origin/$BRANCH" >/dev/null 2>&1; then
    echo "PROBLEM: this computer and your copy on GitHub each have"
    echo "changes the other doesn't have yet. GitHub Desktop knows how"
    echo "to knit them together:"
    echo ""
    echo " 1. Open GitHub Desktop."
    echo " 2. Click \"Fetch origin\" (top bar), then \"Pull origin\"."
    echo " 3. If it reports conflicts, follow its on-screen steps."
    echo " 4. Run this script again."
    exit 1
fi
if [ "$LOCAL_BEFORE" != "$(git rev-parse HEAD)" ]; then
    echo "(First picked up edits you had made directly on github.com.)"
    echo ""
fi

# ----- Connect to the template repository ---------------------------
# Register the template as a second remote named "upstream" ("origin"
# is your own fork on GitHub). The URL is re-pointed on every run so a
# renamed or hand-edited remote heals itself instead of erroring.
if git remote get-url upstream >/dev/null 2>&1; then
    git remote set-url upstream "$UPSTREAM_URL"
else
    git remote add upstream "$UPSTREAM_URL"
fi
echo "Checking for updates from:"
echo "    $(git remote get-url upstream)"
echo ""

if ! git fetch upstream "$BRANCH" --quiet; then
    echo "PROBLEM: couldn't reach GitHub."
    echo "Check your internet connection and run this script again."
    exit 1
fi

# ----- Anything new? -------------------------------------------------
BEHIND=$(git rev-list --count "HEAD..upstream/$BRANCH")
if [ "$BEHIND" -eq 0 ]; then
    echo "OK: your site machinery is already up to date. Nothing to do."
    exit 0
fi

# Show what's coming, so the update isn't a black box. The three-dot
# form lists only what changed on the template's side.
echo "Found $BEHIND update(s) to the site machinery. Files affected:"
git diff --name-only "HEAD...upstream/$BRANCH" | sed 's/^/    /' | head -15
TOTAL=$(git diff --name-only "HEAD...upstream/$BRANCH" | wc -l | tr -d ' ')
if [ "$TOTAL" -gt 15 ]; then
    echo "    ...and $((TOTAL - 15)) more"
fi
echo ""

# ----- Merge ----------------------------------------------------------
# Output is captured because git's own merge messages are noisy and
# alarming for this audience; we translate the outcome ourselves.
MERGE_OUTPUT=$(git merge --no-edit "upstream/$BRANCH" 2>&1)
MERGE_STATUS=$?
MERGED="no"

if [ "$MERGE_STATUS" -eq 0 ]; then
    MERGED="yes"
else
    CONFLICTS=$(git diff --name-only --diff-filter=U)

    if [ -z "$CONFLICTS" ]; then
        # Merge failed for some reason other than a normal conflict.
        # Rare; hand the raw output to the maintainer rather than guess.
        echo "PROBLEM: the update failed in an unexpected way."
        echo "Nothing has been changed. Please email the maintainer and"
        echo "include everything below the line:"
        echo "--------------------------------------------------------"
        echo "$MERGE_OUTPUT"
        git merge --abort 2>/dev/null || true
        exit 1
    fi

    # --- Auto-resolve clashes inside content/ in YOUR favour ---------
    # Policy: content/ belongs to the coordinator. The template's own
    # content/ holds only placeholders, so on any clash there, your
    # version is correct by definition. (The -z / read -d '' pairing
    # keeps filenames with spaces intact.)
    git diff --name-only --diff-filter=U -z | while IFS= read -r -d '' F; do
        case "$F" in
            content/*)
                if git checkout --ours -- "$F" 2>/dev/null; then
                    git add -- "$F"
                else
                    # checkout --ours fails when YOU deleted the file and
                    # the template modified it. Your deletion stands.
                    git rm --quiet --force -- "$F" 2>/dev/null || true
                fi
                echo "    kept your version of: $F"
                ;;
        esac
    done

    REMAINING=$(git diff --name-only --diff-filter=U)
    if [ -z "$REMAINING" ]; then
        # Every clash was inside content/ and has been settled in your
        # favour; finish the merge with the message git already prepared.
        git commit --no-edit --quiet
        MERGED="yes"
    else
        # Real overlap in the machinery files: a human has to choose.
        echo "--------------------------------------------------------------"
        echo "ACTION NEEDED — the update overlaps with edits you made."
        echo "This is normal, and nothing is lost. Finish it in GitHub"
        echo "Desktop. These files need your decision:"
        echo ""
        echo "$REMAINING" | sed 's/^/    /'
        echo ""
        echo "These steps use GitHub Desktop (free, desktop.github.com) —"
        echo "the same app from the setup guide. If it isn't installed,"
        echo "install it, sign in with your GitHub account, then"
        echo "File -> Add Local Repository and choose this folder."
        echo ""
        echo "Step by step:"
        echo ""
        echo " 1. Open GitHub Desktop. It shows a yellow box saying"
        echo "    \"Resolve conflicts before merging\", listing the files"
        echo "    above."
        echo " 2. For each file, click \"Open in editor\" next to it. Inside,"
        echo "    look for markers like <<<<<<<, =======, >>>>>>>."
        echo "    Between <<<<<<< and ======= is YOUR version; between"
        echo "    ======= and >>>>>>> is the template's new version."
        echo " 3. Keep the lines you want, delete the rest INCLUDING the"
        echo "    three marker lines themselves. Save the file."
        echo ""
        echo "    SPECIAL CASE — quartz.config.yaml: keep YOUR version of"
        echo "    any line you deliberately changed (your pageTitle,"
        echo "    baseUrl, Edit-on-GitHub repo and branch, Plausible line,"
        echo "    and anything else you customised), and take the"
        echo "    template's version of lines you never touched. Rule of"
        echo "    thumb: your settings are the ones naming YOUR edition,"
        echo "    YOUR site, and YOUR repo."
        echo ""
        echo " 4. Back in GitHub Desktop, once every file is dealt with,"
        echo "    click \"Continue merge\"."
        echo " 5. Click \"Push origin\" at the top. Your site rebuilds in"
        echo "    about 2–3 minutes."
        echo ""
        echo "Too messy, or unsure? Cancel safely — your edition returns to"
        echo "exactly how it was — by running:"
        echo ""
        echo "    bash sync-upstream.sh --abort"
        echo ""
        echo "...then email the maintainer the list of files above."
        echo "--------------------------------------------------------------"
        exit 1
    fi
fi

# ----- Success: upload so the live site actually rebuilds ------------
# Forgetting to push is the most common "I updated but nothing changed"
# mistake, so the script pushes itself. GitHub Desktop's stored login
# normally covers this; if it can't, we fall back to a Desktop click.
if [ "$MERGED" = "yes" ]; then
    echo ""
    echo "OK: updates combined cleanly with your edition."
    echo "Uploading to GitHub so your live site rebuilds..."
    if git push origin "$BRANCH" --quiet 2>/dev/null; then
        echo ""
        echo "Done. Your site rebuilds automatically — allow 2–3 minutes,"
        echo "then hard-refresh your browser (Ctrl+Shift+R / Cmd+Shift+R)."
        echo ""
        echo "Reminder: textbook chapter updates are separate — see"
        echo "$GUIDE, \"When the textbook updates (yearly)\"."
    else
        echo ""
        echo "The update is combined on this computer, but the upload to"
        echo "GitHub didn't go through automatically. To finish: open"
        echo "GitHub Desktop and click \"Push origin\" at the top."
    fi
fi

}

# Last line on purpose — see NOTE FOR MAINTAINERS in the header.
main "$@"
