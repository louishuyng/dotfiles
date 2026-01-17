function fish_user_key_bindings
    fish_vi_key_bindings
    fzf_bindings
    atuin_bindings
    custom_bindings
end

function fzf_bindings
    fzf_configure_bindings --directory=\cf --git_log=\cg --process=\cp --variables=\cv --git_status=\cs
end

function custom_bindings
    bind --mode insert \cn 'clear; nvim'

    # C-e to edit the current command line in nvim
    bind --mode insert \ce edit_command_buffer

    bind --mode insert \cy yazi
end

function atuin_bindings
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search
end
