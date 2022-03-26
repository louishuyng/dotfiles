vim.cmd([[
  let g:dbs = [
  \ { 'name': 'local-productpine', 'url': 'postgres://postgres:xxxx@localhost:5432/productpine_portal_development' }
  \ ]

  let g:db_ui_use_nerd_fonts = 1
  let g:db_ui_default_query = 'select * from "{table}" limit 100'
  let g:db_ui_save_location = '~/Dev/dad_bod_queries'

  let g:db_ui_table_helpers = {
  \   'postgresql': {
  \     'Delete': 'delete from "{table}" where id = :id',
  \   }
  \ }

  let g:db_ui_auto_execute_table_helpers = 1
]])
