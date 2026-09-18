function Get-DocState {
    param([string]$ProjectRoot = '.', [string]$EventsFile = 'events.log')
    $root = (Resolve-Path -LiteralPath $ProjectRoot).Path
    $ev = Join-Path $root $EventsFile
    if (-not (Test-Path -LiteralPath $ev)) {
        return [pscustomobject]@{ Root = $root; Ok = $false; Error = 'events.log not found' }
    }
    $lines = [System.IO.File]::ReadAllLines($ev, [System.Text.Encoding]::UTF8)

    $state = @{}; $desc = @{}; $evidence = @{}; $part = @{}; $order = @()
    $next = ''; $judgment = ''; $readFirst = @(); $plan = ''
    $lastDate = ''; $deadEnds = @(); $notes = @()
    $errors = @()

    foreach ($L in $lines) {
        $t = $L.Trim()
        if (-not $t) { continue }
        if ($t.StartsWith('#')) { continue }   # comment line - allowed, ignored by replay
        $p = $t -split ' ', 3
        if ($p.Count -lt 2) { $errors += "malformed: $t"; continue }
        $lastDate = $p[0]
        $verb = $p[1]
        $rest = if ($p.Count -ge 3) { $p[2] } else { '' }
        switch -Regex ($verb) {
            '^unit:open$' {
                $id = ($rest -split ' ', 2)[0]
                if ($id -and -not $state.ContainsKey($id)) {
                    $state[$id] = 'future'
                    $desc[$id] = if ($rest -match ' ') { $rest.Substring($rest.IndexOf(' ') + 1) } else { '' }
                    # Hierarchical unit ids (`part/unit`) carry structure for free: the segment
                    # before the first `/` is the part. Flat ids stay valid (part = '').
                    $part[$id] = if ($id -match '/') { $id.Substring(0, $id.IndexOf('/')) } else { '' }
                    $order += $id
                } else { $errors += "duplicate/empty open: $t" }
            }
            '^unit:activate$' {
                $id = $rest.Trim()
                if ($state.ContainsKey($id)) { $state[$id] = 'active' } else { $errors += "activate before open: $t" }
            }
            '^unit:close$' {
                $id = ($rest -split ' ', 2)[0]
                if ($state.ContainsKey($id)) {
                    $state[$id] = 'done'
                    $evidence[$id] = if ($rest -match ' ') { $rest.Substring($rest.IndexOf(' ') + 1) } else { '' }
                } else { $errors += "close before open: $t" }
            }
            '^unit:pause$' {
                $id = $rest.Trim()
                if ($state.ContainsKey($id)) { $state[$id] = 'paused' } else { $errors += "pause before open: $t" }
            }
            '^next:set$' { $next = $rest.Trim() }
            '^judgment:set$' { $judgment = $rest.Trim() }
            '^read-first:set$' { $readFirst = @($rest -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
            '^plan:set$' { $plan = $rest.Trim() }
            '^dead-end:set$' { $deadEnds += $rest.Trim() }
            # Housekeeping that changes state documents without being a unit/decision/plan change
            # (ops re-embed, migration, guard fixes). Without this verb such work is unnotable, and
            # the freshness guard would keep reporting it as unrecorded - which it then truly is.
            '^note:set$' { $notes += [pscustomobject]@{ Date = $lastDate; Text = $rest.Trim() } }
            default { $errors += "unknown verb: $t" }
        }
    }

    $active = @($order | Where-Object { $state[$_] -eq 'active' })
    [pscustomobject]@{
        Root         = $root
        Ok           = $true
        Errors       = $errors
        ActiveUnitIds = $active
        Units        = @($order | ForEach-Object { [pscustomobject]@{ Id = $_; State = $state[$_]; Description = $desc[$_]; Evidence = $evidence[$_]; Part = $part[$_] } })
        Next         = $next
        Judgment     = $judgment
        ReadFirst    = $readFirst
        Plan         = $plan
        LastEventDate = $lastDate
        DeadEnds      = $deadEnds
        Notes         = @($notes)
    }
}

function Split-DocPlan {
    param([string]$Plan)
    if (-not $Plan) { return @() }
    # A plan is a ` | `- or arrow-separated list of top-level parts, rendered one bullet each.
    # NOTE: tools must stay ASCII-only (PowerShell 5.1 reads BOM-less scripts as ANSI), so the
    # arrow is built from its code point instead of being written literally.
    $arrow = [string][char]0x2192
    $pattern = '\s*(?:[|]|' + $arrow + '|->)\s*'
    return @($Plan -split $pattern | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

function Render-CurrentStatus {
    param([object]$State)
    $rf = ($State.ReadFirst | ForEach-Object { '"' + $_ + '"' }) -join ', '
    $L = New-Object System.Collections.Generic.List[string]
    $L.Add('---')
    $L.Add('now_refreshed: ' + $State.LastEventDate)
    $L.Add('active_unit_ids: [' + ($State.ActiveUnitIds -join ', ') + ']')
    $L.Add('read_first: [' + $rf + ']')
    $L.Add('---')
    $L.Add('')
    $L.Add('# CURRENT_STATUS')
    $L.Add('')
    $L.Add('## NOW')
    $L.Add('')
    $paused = @($State.Units | Where-Object { $_.State -eq 'paused' })
    $activeLabel = if ($State.ActiveUnitIds.Count -gt 0) { ($State.ActiveUnitIds -join ', ') }
                   elseif ($paused.Count -gt 0) { '(paused)' }
                   else { '(idle)' }
    $L.Add('- **Active**: ' + $activeLabel)
    $L.Add('- **Next**: ' + $State.Next)
    $L.Add('- **Read-first**: ' + ($State.ReadFirst -join ', '))
    $L.Add('- **Key-judgment**: ' + $State.Judgment)
    $L.Add('- **Refreshed**: ' + $State.LastEventDate)
    $L.Add('')
    $L.Add('## Work Surface')
    $L.Add('')
    $L.Add('### Plan')
    $parts = @(Split-DocPlan -Plan $State.Plan)
    if ($parts.Count -eq 0) { $L.Add('(none)') } else { foreach ($p in $parts) { $L.Add('- ' + $p) } }
    $L.Add('')
    $L.Add('### Units')
    if ($State.Units.Count -eq 0) {
        $L.Add('(none)')
    } elseif (@($State.Units | Where-Object { $_.Part }).Count -gt 0) {
        $groups = @()
        foreach ($u in $State.Units) {
            $key = if ($u.Part) { $u.Part } else { '(unassigned)' }
            if ($groups -notcontains $key) { $groups += $key }
        }
        foreach ($g in $groups) {
            $L.Add('#### ' + $g)
            foreach ($u in ($State.Units | Where-Object { $k = if ($_.Part) { $_.Part } else { '(unassigned)' }; $k -eq $g })) {
                $L.Add('- [' + $u.State + '] `' + $u.Id + '` ' + $u.Description)
            }
        }
    } else {
        foreach ($u in $State.Units) { $L.Add('- [' + $u.State + '] `' + $u.Id + '` ' + $u.Description) }
    }
    $L.Add('')
    $L.Add('## Recent History (closed units)')
    $closed = @($State.Units | Where-Object { $_.State -eq 'done' })
    if ($closed.Count -eq 0) { $L.Add('(none)') } else { foreach ($u in $closed) { $L.Add('- [done] `' + $u.Id + '` ' + $u.Evidence) } }
    $L.Add('')
    $L.Add('## Notes (housekeeping)')
    $noteLimit = 10
    if ($State.Notes.Count -eq 0) {
        $L.Add('(none)')
    } else {
        $shown = if ($State.Notes.Count -gt $noteLimit) { $State.Notes[($State.Notes.Count - $noteLimit)..($State.Notes.Count - 1)] } else { $State.Notes }
        foreach ($n in $shown) { $L.Add('- ' + $n.Date + ' ' + $n.Text) }
        if ($State.Notes.Count -gt $noteLimit) { $L.Add('- (+' + ($State.Notes.Count - $noteLimit) + ' older in events.log)') }
    }
    $L.Add('')
    $L.Add('## Dead ends (negative ledger)')
    if ($State.DeadEnds.Count -eq 0) { $L.Add('(none)') } else { foreach ($d in $State.DeadEnds) { $L.Add('- ' + $d) } }
    return ($L -join "`n")
}
