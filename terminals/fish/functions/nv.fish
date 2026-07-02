function nv --description 'Open Neovide in a folder (default: cwd)'
    set -l target (test (count $argv) -gt 0; and echo $argv[1]; or pwd)
    set -l bin /Applications/Neovide.app/Contents/MacOS/neovide
    if not test -x $bin
        echo "nv: Neovide binary not found at $bin" >&2
        return 1
    end
    # config.toml has fork = true, so Neovide detaches itself; no need for & / disown.
    $bin $target
end
