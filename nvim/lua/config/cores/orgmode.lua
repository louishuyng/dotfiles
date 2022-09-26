local present, orgmode = pcall(require, "orgmode")
if not present then return end

orgmode.setup_ts_grammar()
orgmode.setup({
  org_agenda_files = '~/louis-org/*.org',
  org_default_notes_file = '~/louis-org/note.org'
})
