local present, tabnine = pcall(require, "cmp_tabnine.config")

if not present then
   return
end

tabnine:setup({
  max_lines = 1000;
  max_num_results = 3;
  sort = true;
  run_on_every_keystroke = true;
  snippet_placeholder = '..';
  ignored_file_types = { -- default is not to ignore
    -- uncomment to ignore in lua:
    -- lua = true
  };
})
