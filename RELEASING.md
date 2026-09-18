# Releasing Doc Harness

This repository is developed locally with full history and published in curated release commits.
The rule is deliberately simple: **the dev tree may hold material that is not part of the product;
the published tree never does.**

## What is not published

The exact path list lives in **`.publish-exclude.txt`** (local-only, versioned in git, itself never
published) so that the release build enumerates from data rather than from memory. In categories:
development correspondence with sibling projects, runtime scratch files, the notes that quote or map
those projects, and the two local-only lists themselves (`.publish-exclude.txt`,
`.publish-terms.txt`).

Everything else is public, including this project's own harness instance (`CLAUDE.md`,
`CURRENT_STATUS.md`, `events.log`, `FILE_INDEX.md`) — that is the dogfooding demo.

## Release checklist

1. **The dev tree is green.** From the dev tree:

   ```powershell
   powershell -File tools/conformance.ps1 -ProjectRoot . -Full
   ```

   All guards must pass, including the handoff regression test.

2. **Language parity.** `skill/` and `skill-zh/` must cover the same files with the same structure.

3. **Versions agree.** `skill/spec.md` `**Version**`, `skill-zh/spec.md`, the ops sentinel in
   `CLAUDE.md`, `tools/lib/doc-harness-config.json`, `.claude-plugin/marketplace.json` and both
   `plugin.json` files must name the same version.

4. **Spec copy is in sync.** `DOC_HARNESS_SPEC.md` is a copy of `skill/spec.md`:

   ```powershell
   Copy-Item skill/spec.md DOC_HARNESS_SPEC.md -Force
   ```

   **Toolbelt mirrors too**: the skill folders carry copies of `tools/`. After any change under
   `tools/`, re-copy (the gate fails on any byte difference, via `toolbelt-sync.ps1`):

   ```powershell
   Copy-Item -Path tools/* -Destination skill/tools    -Recurse -Force
   Copy-Item -Path tools/* -Destination skill-zh/tools -Recurse -Force
   ```

   (Copy the *contents* — `Copy-Item tools -Destination skill/tools` would nest the folder as
   `skill/tools/tools/`; the sync guard catches that, which is how the mistake was found.)

5. **Build the published commit** — never push the dev tree as-is. Work in a scratch clone so the
   dev tree is untouched, remove the not-published paths, prune their `FILE_INDEX.md` entries, then
   re-parent the curated tree onto the current public tip so the release lands as **one commit**:

   ```powershell
   git clone D:\Projects\doc-harness D:\Projects\_dh-release
   cd D:\Projects\_dh-release
   git remote add github https://github.com/cilidinezy-commits/doc-harness.git
   git fetch github master                       # github/master = current public tip

   # enumerate what to withhold from the data file, never from memory
   $globs = @(Get-Content .publish-exclude.txt -Encoding UTF8 |
       Where-Object { $_.Trim() -and -not $_.Trim().StartsWith('#') } | ForEach-Object { $_.Trim() })
   $concrete = @(git ls-files | Where-Object { $f = $_; @($globs | Where-Object { $f -like $_ }).Count })
   foreach ($p in $concrete) { git rm -q --cached --ignore-unmatch -- $p }

   # prune only the FILE_INDEX entries whose OWN path is withheld. Matching the path anywhere in
   # the line would also delete the entries of published files that merely mention it - that
   # mistake left two published tools unregistered, and the release gate caught it.
   $idx = 'FILE_INDEX.md'
   $kept = @(Get-Content $idx -Encoding UTF8 | Where-Object {
       $t = $_.Trim(); $first = $null
       if ($t -match '^- `([^`]+)`') { $first = $Matches[1] }
       -not ($first -and ($concrete -contains $first))
   })
   [System.IO.File]::WriteAllLines((Join-Path (Get-Location) $idx), $kept, (New-Object System.Text.UTF8Encoding($false)))
   git add FILE_INDEX.md

   # NOTE: a glob for the received letters must be `inbox/2026-*.md`, never `inbox/*.md` - git
   # pathspec `*` crosses `/`, so the latter would strip the already-published letters and leave
   # FILE_INDEX pointing at nothing.

   git reset --soft github/master
   git commit -m "Doc Harness v2.0.0"
   ```

   `git reset --soft` moves the branch to the public tip while keeping the curated index, so the
   release is one clean commit on top of the published history rather than 70+ internal WIP commits.

6. **Verify the published tree, not the dev tree.** In the scratch clone, run the gate again:

   ```powershell
   powershell -File tools/conformance.ps1 -ProjectRoot . -Full
   ```

   A published tree that fails its own guards is a broken release: `dead-pointer` and
   `unregistered` must be green *in the published tree*.

   **Then scan it for what must never be published** — a person's name, institutions, off-project
   context, sibling project names — using the persistent list kept outside the release:

   ```powershell
   powershell -File <dev-tree>/tools/publish-scan.ps1 -Root . -TermsFile <dev-tree>/.publish-terms.txt
   ```

   The list is a *file*, not a memory: a scan whose word list is recalled on the spot will miss a
   dimension, which is exactly how an off-project context reached a published release once. Extend
   the list whenever something new must not be published, and use `allow:` lines for files that
   were already public before the list existed.

7. **Push and tag.**

   ```powershell
   git push github HEAD:master
   git tag -a v2.0.0 -m "Doc Harness v2.0.0"
   git push github v2.0.0
   ```

8. **Check the front door.** Open the repository page: description, README rendering (including the
   diagram), and the plugin install commands.

## Why a curated commit instead of pushing the dev history

The dev history contains commits that name and discuss other private projects. Rewriting that
history would be possible, but the public repository is better served by a clear release commit
than by a stream of internal WIP messages — and the dev history stays complete and unrewritten
locally, which is what matters for the maintainer's own backup.
