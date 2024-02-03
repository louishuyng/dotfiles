import glob
import os.path
import dracula.draw

# Load existing settings made via :set
config.load_autoconfig()

dracula.draw.blood(c, {
    'spacing': {
        'vertical': 6,
        'horizontal': 8
    }
})

# General
c.tabs.position = 'right'

c.content.javascript.enabled = True
c.auto_save.session = True

c.completion.shrink = True
c.completion.scrollbar.width = 0
c.completion.scrollbar.padding = 0

# Apperance
c.hints.auto_follow = 'always'
c.hints.auto_follow_timeout = 400

c.tabs.background = True
c.tabs.favicons.scale = 0.9
c.tabs.last_close = 'close'
c.tabs.padding = {'bottom': 3, 'left': 5, 'right': 5, 'top': 2}
c.tabs.mode_on_change = 'restore'
c.tabs.show = 'multiple'
c.tabs.indicator.width = 0

c.qt.args += [
    "ignore-gpu-blacklist",
    "enable-accelerated-2d-canvas",
    "enable-gpu-memory-buffer-video-frames",
    "enable-gpu-rasterization",
    "enable-native-gpu-memory-buffers",
    "enable-oop-rasterization",
    "enable-zero-copy",
]

# Search Engine
c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}',
    'wi': 'https://en.wikipedia.org/wiki/Special:Search?search={}',
    'yt': 'https://youtube.com/results?search_query={}',
}

# Start Page
c.url.start_pages = "https://google.com/"
c.url.default_page = "about:blank"

# Enconding
c.editor.encoding = 'utf-8'

# Set Font
c.fonts.hints = "bold 13px 'DejaVu Sans Mono'"
mono = '12pt FiraCode Nerd Font'
small_mono = '11pt FiraCode Nerd Font'
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

# Bind Keys
# Ports
config.bind('po3', 'open -t http://localhost:3000')
config.bind('po4', 'open -t http://localhost:4200')
config.bind('po5', 'open -t http://localhost:5100')
config.bind('po8', 'open -t http://localhost:8000')

config.bind('<shift+k>', 'tab-prev')
config.bind('<shift+j>', 'tab-next')
config.bind('gj', 'tab-move +')
config.bind('gk', 'tab-move -')

# Daily
config.bind('yt', 'open -t https://youtube.com')
config.bind('cc', 'open -t https://netflix.com')
config.bind('gm', 'open -t https://gmail.com')
config.bind('gh', 'open -t http://github.com')

# Work
config.bind(
    'wjr', 'open -t https://perxtechnologies.atlassian.net/jira/your-work')

# Social
config.bind('scm', 'open -t https://messenger.com')
config.bind('scf', 'open -t https://facebook.com')
config.bind('scr', 'open -t https://reddit.com')

# Browser handler
config.unbind('d')
config.unbind('<ctrl+w>')
config.bind('dd', 'tab-close')
config.bind('<super+w>', 'tab-close')
config.bind('<backspace>', 'tab-focus last')

# Statusbar
config.bind('<ctrl-\\>', 'config-cycle tabs.show always never;; config-cycle statusbar.show always never')
