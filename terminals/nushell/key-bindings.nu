$env.config.keybindings = [
  {
    name: "nvim-launch"
    modifier: control
    keycode: char_n
    mode: vi_insert
    event: [
      { edit: InsertString, value: "nvim" }
      { send: Enter }
    ]
  }
  {
    name: "nvim-launch"
    modifier: control
    keycode: char_y
    mode: vi_insert
    event: [
      { edit: InsertString, value: "yazi" }
      { send: Enter }
    ]
  }
]
