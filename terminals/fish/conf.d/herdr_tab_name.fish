status is-interactive; or exit 0
set -q HERDR_TAB_ID; or exit 0

# herdr has no automatic-rename, so drive it from the shell: this is tmux's
# automatic-rename-format "#{b:pane_current_path}" (see terminals/tmux/.tmux.conf).
# Unlike tmux, a manual prefix+, rename is clobbered by the next cd — herdr gives
# no hook on its rename action to latch off.
function _herdr_tab_name --on-variable PWD
    herdr tab rename $HERDR_TAB_ID (basename $PWD) >/dev/null 2>&1
end
