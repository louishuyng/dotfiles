import glob
import os.path

c.content.javascript.enabled = True
c.auto_save.session = True

c.completion.shrink = True
c.completion.scrollbar.width = 0
c.completion.scrollbar.padding = 0

## Apperance
c.hints.auto_follow = 'always'
c.hints.auto_follow_timeout = 400
c.hints.mode = 'number'

c.tabs.background = True
c.tabs.favicons.scale = 0.9
c.tabs.last_close = 'close'
c.tabs.padding = {'bottom': 3, 'left': 5, 'right': 5, 'top': 2}
c.tabs.mode_on_change = 'restore'
c.tabs.show = 'multiple'
c.tabs.indicator.width = 0

## Search Engine
c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}',
    'wi': 'https://en.wikipedia.org/wiki/Special:Search?search={}',
    'yt': 'https://youtube.com/results?search_query={}',
}

## Start Page
c.url.start_pages = "https://google.com/"
c.url.default_page = "about:blank"

## Enconding
c.editor.encoding = 'utf-8'

## Set Font
c.fonts.hints = "bold 13px 'DejaVu Sans Mono'"
mono = '12pt Hack Nerd Font'
small_mono = '10pt Hack Nerd Font'
c.fonts.completion.entry = mono
c.fonts.completion.category = 'bold ' + mono
c.fonts.debug_console = mono
c.fonts.downloads = mono
c.fonts.hints = 'bold 11pt monospace'
c.fonts.keyhint = small_mono
c.fonts.messages.error = small_mono
c.fonts.messages.info = small_mono
c.fonts.messages.warning = small_mono
c.fonts.statusbar = mono

## Bind Keys
config.bind('po3', 'open -t http://localhost:3000')
config.bind('po4', 'open -t http://localhost:4200')
config.bind('po8', 'open -t http://localhost:8000')
config.bind('po88', 'open -t http://localhost:8080')
config.bind('gh', 'open -t http://github.com')
config.bind('po14', 'open -t http://kenh14.com')
config.bind('<ctrl+d>', 'wq')
