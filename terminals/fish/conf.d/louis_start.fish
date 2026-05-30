status is-interactive; or exit 0
test "$TERM_PROGRAM" = vscode; and exit 0
test "$TERM_PROGRAM" = cursor; and exit 0

function _louis_first_prompt --on-event fish_prompt
    functions -e _louis_first_prompt
    louis_greet
end
