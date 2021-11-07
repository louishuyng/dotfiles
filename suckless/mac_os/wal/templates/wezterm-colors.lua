return {{
  colors = {{
    color_schemes = {{
      ["wal"] = {{ 
        -- The default text color
        foreground = "{foreground}",
        -- The default background color
        background = "{background}",

        -- Overrides the cell background color when the current cell is occupied by the
        -- cursor and the cursor style is set to Block
        cursor_bg = "{cursor}",
        -- Overrides the text color when the current cell is occupied by the cursor
        cursor_fg = "black",
        -- Specifies the border color of the cursor when the cursor style is set to Block,
        -- of the color of the vertical or horizontal bar when the cursor style is set to
        -- Bar or Underline.
        cursor_border = "#52ad70",

        -- the foreground color of selected text
        selection_fg = "black",
        -- the background color of selected text
        selection_bg = "#fffacd",

        -- The color of the scrollbar "thumb"; the portion that represents the current viewport
        scrollbar_thumb = "#222222",

        -- The color of the split lines between panes
        split = "#444444",

        ansi = {{"{color0}", "{color1}", "{color2}", "{color3}", "{color4}", "{color5}", "{color6}", "{color7}"}},
        brights = {{"{color8}", "{color9}", "{color10}", "{color11}", "{color12}", "{color13}", "{color14}", "{color15}"}},
      }}
    }}
  }}
}}
