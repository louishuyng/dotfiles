local Hydra = require('hydra')

Hydra({
  name = 'Change Window',
  mode = 'n',
  body = '<C-w>',
  heads = {
    {"H", "<C-w>3<"}, {"L", "<C-w>3>"}, {"K", "<C-w>2-"}, {"J", "<C-w>2+"}
  }
})
