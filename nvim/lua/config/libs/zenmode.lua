local present, zenmode = pcall(require, "zen-mode")

if not (present) then return end

zenmode.setup {}
