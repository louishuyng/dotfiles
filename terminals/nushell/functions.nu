def "new-ws" [] {
    tmuxinator start regask
    tmuxinator start personal
}

# New git branch regask function
def gbre [ticket?: string = ""] {
    let type = "REG"
    let ticket = if $ticket == "" {
        gum input --placeholder "Jira Ticket number (If no ticket it will generate XXXX instead)"
    } else {
        $ticket
    }

    let description = (gum input --placeholder "Short description of the ticket"
        | str downcase
        | str trim -r
        | str replace --all " " "-")

    # If ticket is empty then set REG-XXXX if not it will be REG-TICKET
    if $ticket == "" {
        git checkout -b $"($type)-XXXX-($description)"
    } else {
        git checkout -b $"($type)-($ticket)-($description)"
    }
}

# Git commit regask function
def gcre [] {
    let type = (gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")

    # Get the ticket number from branch 
    # Example: if branch is REG-1234-branch-name then TICKET will be [REG-1234]
    let branch_name = (git rev-parse --abbrev-ref HEAD)
    let ticket_match = ($branch_name | parse -r '([A-Z]+-[0-9A-Z]+)')

    let ticket = if ($ticket_match | length) > 0 {
        let ticket_value = ($ticket_match.capture0 | get 0)
        $"[($ticket_value)]"
    } else {
        ""
    }

    # Pre-populate the input with the type(scope): so that the user may change it
    let summary = (gum input --value $"($type)($ticket): " --placeholder "Summary of this change")
    let description = (gum write --placeholder "Details of this change (CTRL+D to finish)")

    # Commit the changes
    git commit -m $summary -m $description --no-verify
}
