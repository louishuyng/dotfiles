function gbre -d 'new git branch regask'
  set -l TYPE "REG"

  set -l TICKET $argv[1]

  # If Ticket has no value then ask gum
  if test -z $TICKET
    set TICKET $(gum input --placeholder "Jira Ticket number (If no ticket it will generate XXXX instead)")
  end

  set -l DESCRIPTION $(gum input --placeholder "Short description of the ticket" | tr '[:upper:]' '[:lower:]' | sed 's/ *$//' | tr ' ' '-')

  # If ticket is empty then set REG-XXXX if not it will be REG-TICKET
  if test -z $TICKET
    git checkout -b "$TYPE-XXXX-$DESCRIPTION"
  else
    git checkout -b "$TYPE-$TICKET-$DESCRIPTION"
  end
end
