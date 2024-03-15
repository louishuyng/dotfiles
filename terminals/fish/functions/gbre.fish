function gbre -d 'new git branch regask'
  set -l TYPE "REG"
  set -l TICKET $(gum input --placeholder "Jira Ticket number (If no ticket it will generate XXXX instead)")

  set -l DESCRIPTION $(gum write --placeholder "Short description of the ticket" | tr '[:upper:]' '[:lower:]' | sed 's/ *$//' | tr ' ' '-')

  # If ticket is empty then set REG-XXXX if not it will be REG-TICKET
  if test -z $TICKET
    git checkout -b "$TYPE-XXXX-$DESCRIPTION"
  else
    git checkout -b "$TYPE-$TICKET-$DESCRIPTION"
  end
end
