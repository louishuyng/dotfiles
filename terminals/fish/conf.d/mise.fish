# Homebrew ships share/fish/vendor_conf.d/mise-activate.fish, which activates mise
# before config.fish is even read. config.fish activates it again via __init_cached,
# so every shell paid for two `mise hook-env` runs plus one uncached `mise activate`
# — ~58ms of a ~190ms startup. Turn the vendor copy off and keep the cached one.
#
# fish globs $__fish_config_dir/conf.d before $__fish_vendor_confdirs, so this lands
# first. The file must stay named something other than mise-activate.fish: fish
# dedupes conf.d by basename, and shadowing the vendor file would silently drop
# whatever else Homebrew puts in it on a future mise release.
set -g MISE_FISH_AUTO_ACTIVATE 0
